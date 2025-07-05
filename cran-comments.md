## R CMD check results

## Test environments
- local windows-x86_64, R version 4.2.1, Intel(R) Xeon(R) W-2223 CPU 
- win-builder (devel and release). Full build log [here](https://win-builder.r-project.org/o6kqVVxft4S7/)
- R-hub windows-x86_64-devel (r-devel). Full build log [here](https://builder.r-hub.io/status/alphaN_0.1.0.tar.gz-e9b05b28935440c79724e08c8926c968)
- R-hub ubuntu-gcc-release (r-release). Full build log [here](https://builder.r-hub.io/status/alphaN_0.1.0.tar.gz-3f8632a7d3cd473ba3f1c85ec476be1e)
- R-hub fedora-clang-devel (r-devel). Full build log [here](https://builder.r-hub.io/status/alphaN_0.1.0.tar.gz-d5ee07206a244fd99d65b3cc264a0db7)

## R CMD check results
0 errors ✔ | 0 warnings ✔ | 3 notes ✖

- ONLY on R-hub fedora-clang-devel, ubuntu-gcc-release, and win-builder: R Under development (unstable) (2025-07-04 r88383 ucrt)

- ONLY on fedora-clang-devel: checking HTML version of manual ... NOTE Skipping checking HTML validation: no command 'tidy' found. I cannot change that Tidy is not on the path, or update Tidy on the external Fedora Linux server.

## R CMD check results
❯ On ubuntu-gcc-release (r-release)
checking CRAN incoming feasibility ... NOTE
Maintainer: ‘Jesper Wulff <jwulff@econ.au.dk>’

New submission

Possibly misspelled words in DESCRIPTION:
  Jeffreys (10:5)
Lindley's (11:67)
    Wulff (12:31)

❯ On fedora-clang-devel (r-devel)
  checking CRAN incoming feasibility ... [6s/20s] NOTE
  Maintainer: ‘Jesper Wulff <jwulff@econ.au.dk>’
  
  New submission
  
  Possibly misspelled words in DESCRIPTION:
    Jeffreys (10:5)
    Lindley's (11:67)
Wulff (12:31)

❯ On fedora-clang-devel (r-devel)
checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found

* This is a new release.
