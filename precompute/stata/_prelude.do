* Shared set-up for the Stata runs behind the website articles. Not shown on
* the site. Each run file calls it as
*     do "_prelude.do" <name of the run>
* and is started from this folder (precompute/stata).
*
* Environment variable:
*   ALPHAN_STATA_DIR  folder holding alphan.ado, if the version to document is
*                     not the installed one
args run

clear all
set more off
set graphics off
set linesize 100

* Everything a run produces goes to output/: the log the articles quote from
* (<run>.txt) and graphs. Stata's own batch log, <run>.log in this folder,
* starts with the licence banner and is not kept.
capture mkdir "output"
global pc_out "`c(pwd)'/output"

local adodir : environment ALPHAN_STATA_DIR
if "`adodir'" != "" {
    adopath ++ "`adodir'"
}
capture program drop alphan

* The log that the articles quote from. It is opened last: after Stata's
* start-up banner (no licence details) and after the set-up above (no local
* paths).
capture log close pc
log using "$pc_out/`run'.txt", text replace nomsg name(pc)
