* Convert the help file of the Stata command to plain text for the website
* article "Stata help file". Start from this folder; ALPHAN_STATA_DIR must
* point to the folder that holds alphan.sthlp.
clear all
set more off
local adodir : environment ALPHAN_STATA_DIR
if "`adodir'" == "" {
    display as error "set ALPHAN_STATA_DIR to the folder with alphan.sthlp"
    exit 198
}
capture mkdir "output"
translator set smcl2txt linesize 80
quietly translate "`adodir'/alphan.sthlp" "output/alphan-help.txt", ///
    translator(smcl2txt) replace
exit, clear
