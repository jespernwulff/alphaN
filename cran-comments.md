## Resubmission
This is a resubmission of alphaN, a package for setting significance levels as a function of sample size using Bayes factors. The previous submission was rejected because a dataset used in the vignette was removed from its source, causing the vignette to fail. In this version I have:

* Removed the problematic example from the vignette. 
* Removed the CITATION file because it did not pass the incoming checks 

## Test environments
- local windows-x86_64, R version 4.2.1, Intel(R) Xeon(R) W-2223 CPU 
- win-builder (devel and release). Full build log [here](https://win-builder.r-project.org/w1T42QsZTysx/)
- R-hub linux (r-devel). Full build log [here](https://github.com/jespernwulff/alphaN/actions/runs/16252758236)
- R-hub m1-san (R-devel). Full build log [here](https://github.com/jespernwulff/alphaN/actions/runs/16252758236)
- R-hub windows (R-devel). Full build log [here](https://github.com/jespernwulff/alphaN/actions/runs/16252758236)

## R CMD check results
0 errors ✔ | 0 warnings ✔ | 2 notes ✖

The 2 NOTES are:

1. **Package suggested but not available for checking: 'spelling'**
   - This is expected as 'spelling' is only suggested for development purposes and not required for package functionality.

2. **Unable to verify current time**
   - This is a system-specific NOTE from the checking environment and does not affect package functionality.
   
## win-builder (devel and release)
0 errors ✔ | 0 warnings ✔ | 1 note ✖

1. **Package CITATION file contains call(s) to old-style citEntry().  Please use bibentry() instead.**
    - I have removed the CITATION file completely, but still get this note. 

