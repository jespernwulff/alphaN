
<!-- README.md is generated from README.Rmd. Please edit that file -->

# alphaN

<!-- badges: start -->
<!-- badges: end -->

The goal of alphaN is to …

## Installation

You can install the development version of alphaN from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jespernwulff/alphaN")
```

## Example

This is a basic example which shows you how to set the alpha level as a
function of sample size. Here, we imagine we have 200 observations and
want to run a linear regression with 5 variables in total. Specifically,
we want to set the alpha level such that we avoid Lindley’s Paradox:

``` r
library(alphaN)
set_alpha(200, p = 5)
#> Registered S3 methods overwritten by 'BFpack':
#>   method               from
#>   get_estimates.lm     bain
#>   get_estimates.t_test bain
#> $alpha
#> [1] 0.02880158
#> 
#> $evidence
#> [1] 1
```
