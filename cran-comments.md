## Resubmission
This is a resubmission of alphaN, a package for setting significance levels as a function of sample size using Bayes factors. The previous submission was rejected because a dataset used in the vignette was removed from its source, causing the vignette to fail. The problematic example has been removed from the vignette.

## Test environments
- local windows-x86_64, R version 4.2.1, Intel(R) Xeon(R) W-2223 CPU 
- win-builder (devel and release). Full build log [here](https://win-builder.r-project.org/o6kqVVxft4S7/)
- R-hub ubuntu-latest on GitHub (r-devel). Full build log [here](https://github.com/jespernwulff/alphaN/actions/runs/16091645218/job/45409276574)
- R-hub m1-san (r-devel). Full build log [here](https://github.com/jespernwulff/alphaN/actions/runs/16091645218/job/45409276573)
- R-hub windows (R-devel) (r-devel). Full build log [here](https://github.com/jespernwulff/alphaN/actions/runs/16091645218/job/45409276575)

## R CMD check results
0 errors ✔ | 0 warnings ✔ | 2 notes ✖

The 2 NOTEs are:

1. **Package suggested but not available for checking: 'spelling'**
   - This is expected as 'spelling' is only suggested for development purposes and not required for package functionality.

2. **Unable to verify current time**
   - This is a system-specific NOTE from the checking environment and does not affect package functionality.



