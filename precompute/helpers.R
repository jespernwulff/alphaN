# Helpers for the *.Rmd.orig sources, used when precompute/precompile.R knits
# them. Nothing here is part of the package.

.pc_dir <- function() {
  d <- getOption("alphaN.precompute.dir")
  if (is.null(d)) stop("Knit the *.Rmd.orig files with precompute/precompile.R")
  d
}

# ---- Stata ------------------------------------------------------------------
# The do-files in precompute/stata/ mark every block an article shows:
#
#     * >>> name
#     ...commands...
#     * <<<
#
# stata_code()   returns the commands of a block, read from the do-file;
# stata_output() returns what Stata printed for it, read from the log that the
#                run wrote, without the echoed commands;
# stata_show()   writes both as fenced code blocks (chunk option results = "asis").

# The do-file is precompute/stata/<run>.do; the log it wrote is
# precompute/stata/output/<run>.txt.
.stata_file <- function(run, what = c("do", "log")) {
  what <- match.arg(what)
  f <- if (what == "do") file.path(.pc_dir(), "stata", paste0(run, ".do"))
       else file.path(.pc_dir(), "stata", "output", paste0(run, ".txt"))
  if (!file.exists(f)) stop("Missing ", f, ": run precompute/stata/", run, ".do first")
  readLines(f, warn = FALSE, encoding = "UTF-8")
}

.block <- function(lines, start, end, what) {
  i <- grep(start, lines)
  if (length(i) != 1) stop(sprintf("%s: found %d start markers, expected 1", what, length(i)))
  j <- grep(end, lines)
  j <- j[j > i]
  if (!length(j)) stop(sprintf("%s: no end marker", what))
  if (j[1] == i + 1) character(0) else lines[(i + 1):(j[1] - 1)]
}

.trim_blank <- function(x) {
  keep <- which(nzchar(trimws(x)))
  if (!length(keep)) return(character(0))
  x <- x[min(keep):max(keep)]
  # at most one blank line in a row
  blank <- !nzchar(trimws(x))
  x[!(blank & c(FALSE, head(blank, -1)))]
}

stata_code <- function(run, name) {
  x <- .stata_file(run, "do")
  .trim_blank(.block(x, sprintf("^\\* >>> %s\\s*$", name), "^\\* <<<\\s*$",
                     sprintf("%s.do, block '%s'", run, name)))
}

stata_output <- function(run, name) {
  x <- .stata_file(run, "log")
  b <- .block(x, sprintf("^\\. \\* >>> %s\\s*$", name), "^\\. \\* <<<\\s*$",
              sprintf("%s.log, block '%s'", run, name))
  # echoed commands: ". command", "> continuation line", "  2. line of a loop", "."
  b <- b[!grepl("^(\\. |> |\\.$|\\s+[0-9]+\\.( |$))", b)]
  .trim_blank(sub("\\s+$", "", b))
}

stata_show <- function(run, name, code = TRUE, output = TRUE) {
  if (code)   cat("```stata", stata_code(run, name), "```", "", sep = "\n")
  if (output) {
    out <- stata_output(run, name)
    if (length(out)) cat("```{.stata-output}", out, "```", "", sep = "\n")
  }
  invisible(NULL)
}

# Full path of a graph exported by a Stata run, for knitr::include_graphics().
# (precompile.R embeds figures in the generated file, so no copy is needed.)
stata_graph <- function(file) {
  src <- file.path(.pc_dir(), "stata", "output", file)
  if (!file.exists(src)) stop("Missing ", src)
  src
}

# ---- Numbers in running text ---------------------------------------------------
# `lead = FALSE` drops the leading zero of quantities that cannot exceed 1.
num <- function(x, digits = 2, lead = TRUE) {
  s <- formatC(x, format = "f", digits = digits, big.mark = ",")
  minus <- intToUtf8(8722)                          # a proper minus sign
  s <- sub("^-", minus, s)
  if (!lead) s <- sub(paste0("^(", minus, "?)0\\."), "\\1.", s)
  s
}
sig <- function(x, digits = 2) format(signif(x, digits), big.mark = ",",
                                      scientific = FALSE, trim = TRUE)

# ---- R | Stata tabs -----------------------------------------------------------
# Used as inline R code in the *.Rmd.orig sources, each call on a line of its
# own with a blank line before and after:
#
#     `r tabs_r("id")`
#     ...R chunk(s)...
#     `r tabs_stata("id")`
#     ...Stata block(s)...
#     `r tabs_end()`
#
# `id` must be unique on the page. The markup is plain Bootstrap 5; the script
# in pkgdown/extra.js keeps all tabs on a page on the same language.
.tab_button <- function(id, lang, label, active) sprintf(
  paste0('<li class="nav-item" role="presentation"><button class="nav-link%s" ',
         'id="%s-%s-tab" data-bs-toggle="tab" data-bs-target="#%s-%s" type="button" ',
         'role="tab" aria-controls="%s-%s" aria-selected="%s" data-lang="%s">%s</button></li>'),
  if (active) " active" else "", id, lang, id, lang, id, lang,
  if (active) "true" else "false", lang, label)

tabs_r <- function(id) paste(
  '<div class="lang-tabs">',
  '<ul class="nav nav-tabs" role="tablist">',
  .tab_button(id, "r", "R", TRUE),
  .tab_button(id, "stata", "Stata", FALSE),
  '</ul>',
  '<div class="tab-content">',
  sprintf('<div class="tab-pane active" id="%s-r" role="tabpanel" aria-labelledby="%s-r-tab">', id, id),
  sep = "\n")

tabs_stata <- function(id) paste(
  '</div>',
  sprintf('<div class="tab-pane" id="%s-stata" role="tabpanel" aria-labelledby="%s-stata-tab">', id, id),
  sep = "\n")

tabs_end <- function() paste('</div>', '</div>', '</div>', sep = "\n")
