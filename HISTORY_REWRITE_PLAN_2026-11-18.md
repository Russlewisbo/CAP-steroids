# History-rewrite plan: CAP-steroids repository (draft for review, 18 November 2026)

Drafted by the AI assistant from read-only checks on 18 November 2026. Nothing has been run. **Do not commit this file**:
it names the second assessor. It is untracked; move it to `~/Desktop/CAP-steroids-resources/` or add it to `.gitignore`.

## 0. Decisions needed before anything is run

| # | Decision | Proposed default |
|---|---|---|
| D-a | Rewrite at all, given the repository goes private after the thesis is submitted (section 1) | Decide after reading section 1 |
| D-b | Replacement for the name in text | `Assessor 2` |
| D-c | Spreadsheets to remove from all history | All `*.xlsx` and the whole `student_control/` folder (section 3) |
| D-d | Also remove `.posit/` (tracked although ignored; not sensitive) | Yes, while history is being rewritten anyway |
| D-e | Check the CSV files for verbatim publisher quotes first (78 CSV paths in history; not yet checked) | Yes; add any file found to the removal list |
| D-f | When to rewrite: before the thesis cites commit hashes or the site, and before any release/DOI | As soon as D-a to D-e are settled |

## 1. What the check found, and how going private changes it

- The name appears in one form only, "M. Annes": 91 lines in 14 text files at HEAD, and inside three spreadsheets
  (`cap_steroids_extraction.xlsx` 13 times in every version; `student_control/cap_steroids_extraction_2_verified (1).xlsx` 50;
  `student_control/verification_worklist_2026-10-30 (2).xlsx` 1). It is not in any commit message or author field. The
  `renv.lock` matches for "annes" are "Hannes"/"Johannes" and are not affected by the replacement.
- Earliest affected commits: `2a66cf1` (4 Nov; text files) and `82d4a43` (5 Nov; spreadsheets). All affected commits are
  already on GitHub. The repository has 0 forks.
- **Making the repository private** hides the history from the public but does not remove copies that already exist (the
  clones on the student's and the second assessor's machines, anything fetched while public). A rewrite does not reach those
  either. What a rewrite adds over going private: the name and the publisher text are gone from the repository itself, so
  it can later be made public again, archived (release/DOI) or shared without them.
- **GitHub Pages and a private repository.** Pages is currently served from `main:/docs`
  (https://russlewisbo.github.io/CAP-steroids/). On GitHub Free, Pages is not available for private repositories, so the
  site would go offline when the repository is made private and any link in the thesis would break. Check the account
  plan, and if needed archive the site (for example a release of `docs/` to Zenodo or OSF) before making the repository
  private. A release archive contains the files at that commit, so make it after the current files are cleaned.

## 2. Preparation (in the current working copy, `~/CAP-steroids`)

1. Ask the student and the second assessor not to push until told; after the rewrite they must re-clone.
2. Commit or set aside the local changes (`git status`: `.DS_Store`, `SECONDARY_VERIFICATION_INSTRUCTIONS.md`), and push
   the 4 local commits (`1f940eb`, `279d07d`, `ba00502`, `518f084`) so GitHub and the local copy agree.
3. Back up the full history outside the repository and keep it private (it contains the name):
   ```sh
   cd ~/Desktop/CAP-steroids-resources
   git clone --mirror ~/CAP-steroids CAP-steroids-pre-rewrite.git
   git -C ~/CAP-steroids bundle create ~/Desktop/CAP-steroids-resources/CAP-steroids-pre-rewrite.bundle --all
   ```
4. Stop the sources from reintroducing the name (otherwise the next export puts it back):
   - Extraction database (outside the repository): `outcomes_binary.verified` (50 rows, "Y – M. Annes 2026-10-31"),
     `rob2_judgements.assessor_2` and `.consensus` (7 rows each), `changelog.who` (59) and `changelog.new_value` (64);
     also `apply_verification_2026-11-04.py` and the database's `csv/` exports. Proposed: leave the database unchanged
     (it is private and its changelog is an audit trail) and map the name to `Assessor 2` in whatever writes the
     repository copies: `analysis/rob2_assessments.csv`, `rob2_judgements.csv`, `verification_flags_2026-11-04.csv`.
     The generator of each of these still has to be identified.
   - `build_secondary.R` line 10 (comment) and `analysis/risk_of_bias.qmd` line 59 are cleaned by the rewrite itself;
     see section 5 for a wording fix.

## 3. Files to remove from all history (D-c, D-d, D-e)

| Path | Why |
|---|---|
| `cap_steroids_extraction.xlsx` | Name (13) and verbatim publisher quotes; the pipeline reads it from disk, so keep the file on disk and ignore it |
| `student_control/` (3 xlsx and `rob2_judgements_assessor2.csv`) | Name (51 in the xlsx, 7 in the csv); student and assessor working files |
| `verification_worklist_secondary_2026-11-10.xlsx` | Extracted quotes from the papers |
| `secondary_outcomes_verification_2026-11-10.xlsx` | Template with extracted quotes |
| `student2_secondary_outcomes_verification_2026-11-10_CG.xlsx`, `student_secondary_outcomes_verification_2026-11-10.xlsx` | Already untracked; still in history |
| `.posit/` (optional, D-d) | Editor settings, tracked by mistake |
| CSV files found in the D-e check | Publisher quotes |

Before removal, confirm that nothing else in the pipeline reads a removed file from the repository
(`analysis/_targets.R` reads `../cap_steroids_extraction.xlsx` as a file target; keep that file on disk).

## 4. The rewrite (in a fresh clone; filter-repo refuses to run on a non-fresh one)

Write the two input files outside the repository:

`~/Desktop/CAP-steroids-resources/rewrite/paths-to-remove.txt`
```
glob:*.xlsx
student_control/
.posit/
```

`~/Desktop/CAP-steroids-resources/rewrite/replacements.txt`
```
M. Annes==>Assessor 2
```

Run:
```sh
cd ~/Desktop/CAP-steroids-resources/rewrite
git clone --no-local ~/CAP-steroids CAP-steroids-rewritten
cd CAP-steroids-rewritten
git filter-repo --invert-paths --paths-from-file ../paths-to-remove.txt \
                --replace-text ../replacements.txt
```

`--replace-text` changes file contents in every commit, including the current one, so the 14 text files and the rendered
`docs/` pages are cleaned without a separate edit. It does not change commit messages (none contain the name). Every
commit hash changes; commits that only touched removed files disappear, so the count may fall below 33. filter-repo
removes the `origin` remote on purpose.

## 5. Checks and follow-up commits in the rewritten clone (before pushing)

```sh
git rev-list --all | xargs git grep -l "Annes"                                         # expect no output
git log --all --format= --name-only | grep -E '\.xlsx$|^student_control/|^\.posit/'    # expect no output
git rev-list --count HEAD                                                              # compare with 33
git remote add old ~/CAP-steroids && git fetch old
git diff --stat old/main main          # expect only the removed files and the replaced lines
git remote remove old
```

Then:

1. `.gitignore`: add `cap_steroids_extraction.xlsx` (and `*.xlsx` if all spreadsheets are to stay out), so the file can
   sit on disk again without being re-added.
2. Wording: `analysis/risk_of_bias.qmd` will read "assessor 2 is a human reviewer (Assessor 2, 2 November 2026)";
   change to "assessor 2 is a human reviewer (2 November 2026)". Read the other replaced sentences (for example
   "the second assessor (Assessor 2)") and smooth them where needed.
3. Re-render `docs/`: copy the ignored working files into the new clone (`cap_steroids_extraction.xlsx` to the root,
   `analysis/_targets/`, `thesis figures/`), run `renv::restore()` in `analysis/` (cache in `~/.local/share/renv/cache`),
   check `quarto --version` is 1.9.35, then `tar_make()` with `RSTUDIO_PANDOC` set. Expect no refits; only the `site`
   target runs, and only the Risk of bias page (and `search.json`) should change.
4. Commit the source edits and the regenerated `docs/` separately; add a dated `Status.md` entry (without the name)
   recording the rewrite, the removed paths, and that commit hashes before the rewrite are no longer valid. None of the
   affected commit hashes checked is quoted in the current files.

## 6. Push

```sh
git remote add origin https://github.com/Russlewisbo/CAP-steroids.git
git push --force origin main
```

If branch protection blocks force-pushes, allow them for this push only. Pages rebuilds from `main:/docs` automatically.

## 7. GitHub clean-up request

Old commits stay reachable on GitHub by hash (and in cached views) until GitHub removes them. Before asking, list pull
requests (`gh pr list --state all`); pull-request refs keep old commits and cannot be deleted by the owner. Then ask
GitHub Support (https://support.github.com/request, sensitive-data removal) to purge cached views and unreferenced
commits for `Russlewisbo/CAP-steroids`, stating: history rewritten with git filter-repo on [date]; no forks; the
pull requests, if any; and the affected old commits, at least `2a66cf1`, `82d4a43`, `4e1ef3b`, `bcc46dc`, `a49c8eb`,
`81eceb9`, `c21d00e`, `4e73266` (full list from the backup:
`git -C ~/Desktop/CAP-steroids-resources/CAP-steroids-pre-rewrite.git log --format=%H 2a66cf1^..main`).

## 8. Afterwards

- Rename the old working copy (for example to `~/CAP-steroids-pre-rewrite`) and move the rewritten clone to
  `~/CAP-steroids`; delete the old copy once the new one has run `tar_make()` cleanly. Keep the mirror backup and the
  bundle private and offline; they contain the name.
- The student and the second assessor delete their clones and clone again.
- Close the housekeeping item in `NEXT_STEPS.md` and the checklist; make the release/DOI only after this.
- Then make the repository private as planned, after the Pages decision in section 1.
