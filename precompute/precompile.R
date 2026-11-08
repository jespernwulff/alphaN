# Precompute the website articles.
#
# Several articles show Stata output, and GitHub Actions, which builds the
# site, has no Stata. Each `*.Rmd.orig` source under vignettes/articles/ is
# therefore knitted once, here, into a plain `*.Rmd` that already contains the
# code, its output and its figures; pkgdown then only formats that file.
#
# Usage, from the package root:
#
#     Rscript precompute/precompile.R              # every *.Rmd.orig
#     Rscript precompute/precompile.R wages        # one or more, by name
#
# What it needs is listed in precompute/README.md.

args <- commandArgs(trailingOnly = TRUE)
root <- normalizePath(".", winslash = "/")
if (!file.exists(file.path(root, "DESCRIPTION")))
  stop("Run this script from the package root.")
options(alphaN.precompute.dir = file.path(root, "precompute"))

sources <- list.files(file.path(root, "vignettes", "articles"), pattern = "\\.Rmd\\.orig$",
                      full.names = TRUE)
names(sources) <- sub("\\.Rmd\\.orig$", "", basename(sources))
# The home page of the site: pkgdown/index.Rmd.orig -> pkgdown/index.md
home <- file.path(root, "pkgdown", "index.Rmd.orig")
if (file.exists(home)) sources <- c(sources, index = home)
if (length(args)) {
  unknown <- setdiff(args, names(sources))
  if (length(unknown)) stop("No such source: ", paste(unknown, collapse = ", "))
  sources <- sources[args]
}

knit_one <- function(name, orig) {
  dir <- dirname(orig)
  out <- file.path(dir, paste0(name, if (name == "index") ".md" else ".Rmd"))
  message("== ", name)

  knitr::opts_knit$restore()
  knitr::opts_chunk$restore()
  # Figures are written into the generated file itself (as data URIs), so that
  # it does not depend on separate image files.
  knitr::opts_knit$set(base.dir = paste0(dir, "/"), upload.fun = knitr::image_uri)
  knitr::opts_chunk$set(
    collapse   = TRUE,
    comment    = "#>",
    fig.path   = paste0("figures/", name, "-"),
    fig.width  = 7,
    fig.height = 4.5,
    dpi        = 144,
    dev        = "png"
  )

  knitr::knit(orig, out, envir = new.env(parent = globalenv()), quiet = TRUE)

  # Say where the file comes from: right after the YAML header, or at the top
  # if there is none.
  x   <- readLines(out, warn = FALSE, encoding = "UTF-8")
  end <- which(x == "---")[2]
  note <- sprintf("<!-- Generated from %s.Rmd.orig by precompute/precompile.R. Edit the .orig file, not this one. -->", name)
  x <- if (is.na(end)) c(note, "", x) else append(x, c("", note), after = end)
  # A file sync program (Dropbox) can hold the just-written file for a moment.
  for (attempt in 1:40) {
    done <- tryCatch({
      writeLines(enc2utf8(x), out, useBytes = TRUE)
      TRUE
    }, error = function(e) FALSE, warning = function(w) FALSE)
    if (done) break
    Sys.sleep(0.5)
  }
  if (!done) stop("Could not write ", out)
  message("   wrote ", sub(paste0(root, "/"), "", out, fixed = TRUE))
}

for (n in names(sources)) knit_one(n, sources[[n]])
