## R CMD check results

## Test environments
- local windows-x86_64, R version 4.2.1, Intel(R) Xeon(R) W-2223 CPU 
- win-builder (devel and release)
- R-hub windows-x86_64-devel (r-devel). Full build log [here](https://builder.r-hub.io/status/alphaN_0.0.0.9000.tar.gz-991d3bfd8beb4ca9ad174015d479b402)
- R-hub ubuntu-gcc-release (r-release). Full build log [here](https://builder.r-hub.io/status/alphaN_0.0.0.9000.tar.gz-4441cfd78abe4f4b801363e75e1e9b28)
- R-hub fedora-clang-devel (r-devel). Full build log [here](https://builder.r-hub.io/status/alphaN_0.0.0.9000.tar.gz-79dfa80cbddc4888af7e85a3874c35b2)

## R CMD check results
0 errors ✔ | 0 warnings ✔ | 3 notes ✖

- ONLY on R-hub fedora-clang-devel and ubuntu-gcc-release: Possibly misspelled words in DESCRIPTION: Jeffreys (10:5), Lindley's (11:67), Wulff (12:31). These names are spelled correctly.

- ONLY on fedora-clang-devel: checking HTML version of manual ... NOTE Skipping checking HTML validation: no command 'tidy' found. I cannot change that Tidy is not on the path, or update Tidy on the external Fedora Linux server.

❯ On ubuntu-gcc-release (r-release)
  checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Jesper Wulff <jwulff@econ.au.dk>’
  
  New submission
  
  Version contains large components (0.0.0.9000)
  
  Possibly misspelled words in DESCRIPTION:
    Jeffreys (10:5)
    Lindley's (11:67)
    Wulff (12:31)

❯ On fedora-clang-devel (r-devel)
  checking CRAN incoming feasibility ... [6s/19s] NOTE
  Maintainer: ‘Jesper Wulff <jwulff@econ.au.dk>’
  
  New submission
  
  Version contains large components (0.0.0.9000)
  
  Possibly misspelled words in DESCRIPTION:
    Jeffreys (10:5)
    Lindley's (11:67)
    Wulff (12:31)

❯ On fedora-clang-devel (r-devel)
  checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

* This is a new release.
