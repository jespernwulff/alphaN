# Precomputing the website

GitHub Actions builds the site but has no Stata, so everything that shows
Stata output is computed here, once, and committed. `pkgdown` then only formats
the generated files.

Edit the `*.Rmd.orig` sources (in `vignettes/articles/`, and
`pkgdown/index.Rmd.orig`) and the do-files in `precompute/stata/`, not the
generated `.Rmd` and `index.md`.

To regenerate, you need Stata 14 or later, and R with `alphaN`, `knitr`,
`haven`, `sandwich` and `lmtest`:

1. Point `ALPHAN_STATA_DIR` at a checkout of
   <https://github.com/jespernwulff/alphaN-stata>.
2. From `precompute/stata/`, run `getting-started.do`, `wages.do`, `figures.do`
   and `stata-help.do` in Stata. Output goes to `precompute/stata/output/`.
3. From the package root, run `Rscript precompute/precompile.R`.

The folder is listed in `.Rbuildignore`, as are the articles: none of this is
part of the CRAN package.
