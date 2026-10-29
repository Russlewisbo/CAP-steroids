# GitHub Pages: stop Jekyll from processing the rendered site
out <- Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR", unset = "../docs")
file.create(file.path(out, ".nojekyll"))
