# Export every figure on the website report at print resolution (400 dpi) into "../thesis figures/".
#
# Run from analysis/ (renv active):  Rscript thesis_figures.R
#
# Files are named <page>_Figure<NN>_<website label>.png, where NN is the figure number shown on that page of the
# site (Quarto numbers figures within each page) and the label is the chunk label (fig-...) used in the .qmd.
# Figure_index.csv maps each file to its page, number, label, caption, size and resolution.
#
# Figures made by pipeline targets are rebuilt from the targets store with the same plotting code, saved at 400 dpi
# in place of the pipeline's 200 dpi. Figures drawn inside a .qmd are rebuilt by running that page's code chunks.
# Each figure is also saved as a vector PDF (same name, .pdf). The PRISMA diagram is vector (PDF); the PNG is rasterised from it with Ghostscript. Nothing in output/ or docs/
# is touched, and no model is refitted.

library(targets)
library(ggplot2)

dpi <- 400
out <- normalizePath(file.path("..", "thesis figures"), mustWork = FALSE)
dir.create(out, showWarnings = FALSE)

# ---- Parse the figures from the .qmd files, in site (navbar) order --------------------------------------------
pages <- sub("\\.qmd$", "", yaml::read_yaml("_quarto.yml")$project$render)

read_chunks <- function(f) {
  x <- readLines(f)
  starts <- grep("^```\\{r", x)
  lapply(starts, function(s) {
    e <- s + which(grepl("^```\\s*$", x[(s + 1):length(x)]))[1]
    body <- x[(s + 1):(e - 1)]
    opt <- function(key) {
      m <- grep(paste0("^#\\| ", key, ":"), body, value = TRUE)
      if (length(m)) trimws(gsub('^"|"$', "", trimws(sub(paste0("^#\\| ", key, ":"), "", m[1])))) else NA_character_
    }
    list(label = opt("label"), caption = opt("fig-cap"), width = as.numeric(opt("fig-width")),
         height = as.numeric(opt("fig-height")), eval = opt("eval"),
         code = paste(body[!grepl("^#\\|", body)], collapse = "\n"))
  })
}

figs <- list()
for (pg in pages) {
  ch <- read_chunks(paste0(pg, ".qmd"))
  n <- 0
  for (i in seq_along(ch)) {
    if (!is.na(ch[[i]]$label) && grepl("^fig-", ch[[i]]$label)) {
      n <- n + 1
      tgt <- regmatches(ch[[i]]$code, regexec("include_graphics\\(tar_read\\(([A-Za-z0-9_]+)\\)\\)", ch[[i]]$code))[[1]][2]
      figs[[length(figs) + 1]] <- list(page = pg, number = n, label = ch[[i]]$label, caption = ch[[i]]$caption,
                                       chunk = i, target = tgt, width = ch[[i]]$width, height = ch[[i]]$height)
    }
  }
}

# ---- Environment holding the pipeline's functions and globals -------------------------------------------------
env_t <- new.env(parent = globalenv())
sys.source("_targets.R", env_t)
for (p in c(tar_option_get("packages"), "ggplot2", "ggdist")) suppressPackageStartupMessages(library(p, character.only = TRUE))
man <- tar_manifest(fields = c("name", "command"))
state <- new.env()
state$saved <- NULL
env_t$save_fig <- function(p, path, w, h) {
  ggsave(state$path, p, width = w, height = h, dpi = dpi)
  ggsave(sub("\\.png$", ".pdf", state$path), p, width = w, height = h)
  state$saved <- c(width = w, height = h)
  path
}

make_target_fig <- function(target, path) {
  cmd <- parse(text = man$command[man$name == target])[[1]]
  for (d in intersect(all.vars(cmd), man$name)) assign(d, tar_read_raw(d), env_t)
  state$path <- path
  eval(cmd, env_t)
  state$saved
}

page_env <- list()
make_inline_fig <- function(f, path) {
  if (is.null(page_env[[f$page]])) page_env[[f$page]] <<- new.env(parent = globalenv())
  e <- page_env[[f$page]]
  ch <- read_chunks(paste0(f$page, ".qmd"))
  for (i in seq_len(f$chunk)) {
    if (!is.na(ch[[i]]$eval) && ch[[i]]$eval == "false") next
    if (i < f$chunk && !is.null(e$.done) && i <= e$.done) next
    res <- NULL
    for (ex in parse(text = ch[[i]]$code)) res <- withVisible(eval(ex, e))
    e$.done <- i
    if (i == f$chunk) {
      stopifnot(inherits(res$value, "ggplot"))
      ggsave(path, res$value, width = f$width, height = f$height, dpi = dpi)
      ggsave(sub("\\.png$", ".pdf", path), res$value, width = f$width, height = f$height)
      return(c(width = f$width, height = f$height))
    }
  }
}

png_size <- function(f) {
  b <- readBin(f, "raw", 24)
  c(sum(as.integer(b[17:20]) * 256^(3:0)), sum(as.integer(b[21:24]) * 256^(3:0)))
}

# ---- Build -----------------------------------------------------------------------------------------------------
index <- list()
for (f in figs) {
  stem <- sprintf("%s_Figure%02d_%s", f$page, f$number, sub("^fig-", "", f$label))
  path <- file.path(out, paste0(stem, ".png"))
  size <- if (f$label == "fig-prisma") {
    pdf <- normalizePath("output/figures/prisma_flow_draft.pdf")
    file.copy(pdf, file.path(out, paste0(stem, ".pdf")), overwrite = TRUE)
    status <- system2("gs", c("-q", "-dNOPAUSE", "-dBATCH", "-sDEVICE=png16m", sprintf("-r%d", dpi),
                              "-dTextAlphaBits=4", "-dGraphicsAlphaBits=4", shQuote(paste0("-sOutputFile=", path)), shQuote(pdf)))
    stopifnot(status == 0)
    NULL
  } else if (!is.na(f$target)) {
    make_target_fig(f$target, path)
  } else {
    make_inline_fig(f, path)
  }
  px <- png_size(path)
  index[[length(index) + 1]] <- data.frame(
    file = basename(path), page = f$page, figure = f$number, website_label = f$label, caption = f$caption,
    width_px = px[1], height_px = px[2], dpi = dpi,
    width_in = round(px[1] / dpi, 2), height_in = round(px[2] / dpi, 2),
    vector_pdf = file.exists(sub("\\.png$", ".pdf", path)))
  message("saved ", basename(path))
}
index <- do.call(rbind, index)
utils::write.csv(index, file.path(out, "Figure_index.csv"), row.names = FALSE)
print(index[, c("file", "width_px", "height_px")])
