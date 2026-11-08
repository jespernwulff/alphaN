# Worked example: wages in the NLSW panel

The National Longitudinal Survey of Young Women followed a cohort of
women from 1968 on. Stata Press distributes an extract, so the code
below runs as it stands in either language. We regress log wages on age,
experience, tenure, where the respondent lives, race, education, marital
status, union membership and hours worked. With nearly 19,000
observations, *p*-values come cheap, and this is exactly where a fixed
level of .05 stops being informative.

## The data and the model

- R
- Stata

``` r

library(alphaN)
library(haven)

nls <- read_dta("https://www.stata-press.com/data/r19/nlswork.dta")
nls$race <- factor(nls$race, labels = c("white", "black", "other"))

f <- ln_wage ~ age + ttl_exp + tenure + not_smsa + south + c_city + race +
  collgrad + msp + nev_mar + union + hours
```

``` stata
webuse nlswork, clear
global controls age ttl_exp tenure not_smsa south c_city i.race collgrad msp nev_mar union hours
```

``` stata-output
(National Longitudinal Survey of Young Women, 14-24 years old in 1968)
```

## A *p*-value of .003 that favors the null

We start with the conventional standard errors.
[`JAB()`](https://jespernwulff.github.io/alphaN/reference/JAB.md) and
`alphan jab` report the Bayes factor of every coefficient.

- R
- Stata

``` r

m <- lm(f, data = nls)
n <- nobs(m)
n
#> [1] 18964
round(summary(m)$coefficients[-1, ], 4)
#>           Estimate Std. Error  t value Pr(>|t|)
#> age        -0.0112     0.0006 -17.5205   0.0000
#> ttl_exp     0.0346     0.0010  34.5677   0.0000
#> tenure      0.0157     0.0009  18.1270   0.0000
#> not_smsa   -0.1957     0.0069 -28.4180   0.0000
#> south      -0.1063     0.0060 -17.7771   0.0000
#> c_city      0.0057     0.0067   0.8517   0.3944
#> raceblack  -0.1148     0.0067 -17.0358   0.0000
#> raceother   0.0255     0.0260   0.9822   0.3260
#> collgrad    0.3343     0.0070  47.7897   0.0000
#> msp        -0.0216     0.0073  -2.9463   0.0032
#> nev_mar    -0.0659     0.0092  -7.1400   0.0000
#> union       0.1373     0.0066  20.7412   0.0000
#> hours       0.0005     0.0003   1.6820   0.0926
signif(JAB(m), 3)
#>       age   ttl_exp    tenure  not_smsa     south    c_city raceblack raceother 
#>  3.30e+64 2.16e+257  1.63e+69 1.68e+173  3.06e+66  1.04e-02  7.60e+60  1.18e-02 
#>  collgrad       msp   nev_mar     union     hours 
#>       Inf  5.57e-01  8.53e+08  1.89e+91  2.99e-02
```

``` stata
regress ln_wage $controls
alphan jab
```

``` stata-output
      Source |       SS           df       MS      Number of obs   =    18,964
-------------+----------------------------------   F(13, 18950)    =    841.00
       Model |  1513.71169        13  116.439361   Prob > F        =    0.0000
    Residual |  2623.69348    18,950  .138453482   R-squared       =    0.3659
-------------+----------------------------------   Adj R-squared   =    0.3654
       Total |  4137.40517    18,963   .21818305   Root MSE        =    .37209

------------------------------------------------------------------------------
     ln_wage | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         age |   -.011186   .0006385   -17.52   0.000    -.0124374   -.0099346
     ttl_exp |   .0346187   .0010015    34.57   0.000     .0326557    .0365816
      tenure |    .015735    .000868    18.13   0.000     .0140336    .0174365
    not_smsa |  -.1957447   .0068881   -28.42   0.000    -.2092459   -.1822435
       south |  -.1063478   .0059823   -17.78   0.000    -.1180736    -.094622
      c_city |   .0057278   .0067248     0.85   0.394    -.0074535     .018909
             |
        race |
      Black  |  -.1148343   .0067408   -17.04   0.000    -.1280468   -.1016218
      Other  |   .0255307   .0259943     0.98   0.326    -.0254204    .0764818
             |
    collgrad |   .3343134   .0069955    47.79   0.000     .3206016    .3480252
         msp |  -.0216217   .0073385    -2.95   0.003    -.0360057   -.0072376
     nev_mar |  -.0659129   .0092315    -7.14   0.000    -.0840074   -.0478183
       union |   .1373209   .0066207    20.74   0.000     .1243438     .150298
       hours |   .0005011   .0002979     1.68   0.093    -.0000828     .001085
       _cons |   1.816862   .0227791    79.76   0.000     1.772213    1.861511
------------------------------------------------------------------------------

Jeffreys' approximate Bayes factor after regress      method: JAB
n = 18,964

-------------------------------------------------------------------------------
         Coefficient |           b  Std. err.        t     P>|t| BF (H1 vs H0)
---------------------+---------------------------------------------------------
                 age |  -.01118603  .00063845   -17.52    0.0000    3.3007e+64
             ttl_exp |   .03461866  .00100148    34.57    0.0000   2.1637e+257
              tenure |   .01573503  .00086805    18.13    0.0000    1.6326e+69
            not_smsa |   -.1957447  .00688806   -28.42    0.0000   1.6787e+173
               south |  -.10634778  .00598228   -17.78    0.0000    3.0574e+66
              c_city |   .00572775  .00672483     0.85    0.3944       .010437
              2.race |  -.11483429  .00674077   -17.04    0.0000    7.6035e+60
              3.race |   .02553071  .02599426     0.98    0.3260       .011763
            collgrad |   .33431342  .00699551    47.79    0.0000   8.2184e+307
                 msp |  -.02162166  .00733846    -2.95    0.0032        .55729
             nev_mar |  -.06591286  .00923149    -7.14    0.0000     853354279
               union |    .1373209  .00662069    20.74    0.0000    1.8927e+91
               hours |   .00050107   .0002979     1.68    0.0926        .02988
-------------------------------------------------------------------------------
```

Look at `msp`, whether the respondent is married with the spouse
present. Its *p*-value is .003, which would earn two stars in most
tables. The Bayes factor is 0.56: the data are somewhat more likely
under the null hypothesis than under the alternative. This is Lindley’s
paradox in an ordinary regression. (Bayes factors too large to store are
`Inf` in R and about 8e+307 in Stata.)

The level that would have prevented this follows from the sample size
alone, so it can be set before the regression is run.

- R
- Stata

``` r

alphaN(n, BF = c(1, 3, 10))
#> [1] 0.0016980428 0.0005186127 0.0001435126
```

``` stata
alphan `=e(N)', bf(1 3 10)
```

``` stata-output
Significance level calibrated to a Bayes factor       method: JAB

           n |         BF       alpha
-------------+------------------------
      18,964 |          1   .00169804
      18,964 |          3  .000518613
      18,964 |         10  .000143513
```

For moderate evidence the coefficient has to clear a level of .00052,
about 96 times stricter than .05.

## Clustered standard errors

Each woman appears in several survey years, so observations are not
independent. With cluster-robust standard errors the picture changes:
`msp` is no longer significant even at .05, and its Bayes factor drops
to 0.045.

- R
- Stata

``` r

library(sandwich)
library(lmtest)

V <- vcovCL(m, cluster = ~ idcode)
tc <- coeftest(m, vcov. = V)[-1, "t value"]
signif(JABt(n, tc), 3)
#>       age   ttl_exp    tenure  not_smsa     south    c_city raceblack raceother 
#>  1.46e+21  3.08e+69  2.68e+18  3.66e+50  3.61e+18  8.20e-03  2.04e+17  7.95e-03 
#>  collgrad       msp   nev_mar     union     hours 
#> 2.42e+122  4.51e-02  1.22e+01  1.19e+29  9.89e-03
```

``` stata
regress ln_wage $controls, vce(cluster idcode)
alphan jab
```

``` stata-output
Linear regression                               Number of obs     =     18,964
                                                F(13, 4133)       =     285.64
                                                Prob > F          =     0.0000
                                                R-squared         =     0.3659
                                                Root MSE          =     .37209

                             (Std. err. adjusted for 4,134 clusters in idcode)
------------------------------------------------------------------------------
             |               Robust
     ln_wage | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         age |   -.011186   .0010798   -10.36   0.000    -.0133031    -.009069
     ttl_exp |   .0346187   .0019061    18.16   0.000     .0308817    .0383556
      tenure |    .015735   .0016168     9.73   0.000     .0125652    .0189049
    not_smsa |  -.1957447   .0125647   -15.58   0.000    -.2203782   -.1711112
       south |  -.1063478   .0108932    -9.76   0.000    -.1277043   -.0849912
      c_city |   .0057278    .011629     0.49   0.622    -.0170713    .0285268
             |
        race |
      Black  |  -.1148343   .0121337    -9.46   0.000    -.1386229   -.0910457
      Other  |   .0255307   .0598475     0.43   0.670    -.0918026     .142864
             |
    collgrad |   .3343134   .0139607    23.95   0.000      .306943    .3616839
         msp |  -.0216217   .0113138    -1.91   0.056    -.0438028    .0005595
     nev_mar |  -.0659129   .0171024    -3.85   0.000    -.0994427    -.032383
       union |   .1373209   .0114534    11.99   0.000      .114866    .1597758
       hours |   .0005011   .0006374     0.79   0.432    -.0007485    .0017506
       _cons |   1.816862   .0408016    44.53   0.000     1.736868    1.896855
------------------------------------------------------------------------------

Jeffreys' approximate Bayes factor after regress      method: JAB
n = 18,964

-------------------------------------------------------------------------------
         Coefficient |           b  Std. err.        t     P>|t| BF (H1 vs H0)
---------------------+---------------------------------------------------------
                 age |  -.01118603  .00107983   -10.36    0.0000    1.4557e+21
             ttl_exp |   .03461866   .0019061    18.16    0.0000    3.0836e+69
              tenure |   .01573503  .00161681     9.73    0.0000    2.6794e+18
            not_smsa |   -.1957447  .01256466   -15.58    0.0000    3.6620e+50
               south |  -.10634778  .01089321    -9.76    0.0000    3.6113e+18
              c_city |   .00572775  .01162895     0.49    0.6224      .0081981
              2.race |  -.11483429   .0121337    -9.46    0.0000    2.0449e+17
              3.race |   .02553071  .05984751     0.43    0.6697      .0079534
            collgrad |   .33431342  .01396069    23.95    0.0000   2.4193e+122
                 msp |  -.02162166   .0113138    -1.91    0.0561       .045093
             nev_mar |  -.06591286  .01710235    -3.85    0.0001        12.202
               union |    .1373209  .01145345    11.99    0.0000    1.1897e+29
               hours |   .00050107  .00063735     0.79    0.4318      .0098911
-------------------------------------------------------------------------------
```

Wulff and Taylor (2024) recommend calibrating with the total number of
observations, the conservative choice, and then checking whether a
conclusion survives at the effective sample size, which deflates the
total by the squared ratio of the classical to the cluster-robust
standard error. Take `nev_mar`, never married.

- R
- Stata

``` r

se  <- sqrt(diag(vcov(m)))[["nev_mar"]]
rob <- sqrt(diag(V))[["nev_mar"]]
ne  <- n_effective(n, se, rob)
ne
#> [1] 5525.372

alphaN(ne, BF = 3)
#> [1] 0.001007174
JABt(ne, tc[["nev_mar"]])
#> [1] 22.6055
```

``` stata
alphan n_effective, n(`=e(N)') se(`se_nev') se_robust(`=_se[nev_mar]')
local ne = r(n_effective)
alphan `ne', bf(3)
alphan jab nev_mar, n(`ne')
```

``` stata-output
Effective sample size from cluster-robust standard errors

           n |         se   se_robust n_effective
-------------+------------------------------------
      18,964 |    .009231       .0171     5,525.37

Significance level calibrated to a Bayes factor       method: JAB

           n |         BF       alpha
-------------+------------------------
 5,525.37202 |          3   .00100717

Jeffreys' approximate Bayes factor after regress      method: JAB
n = 5,525.37202

-------------------------------------------------------------------------------
         Coefficient |           b  Std. err.        t     P>|t| BF (H1 vs H0)
---------------------+---------------------------------------------------------
             nev_mar |  -.06591286  .01710235    -3.85    0.0001        22.606
-------------------------------------------------------------------------------
```

The effective sample size is less than a third of the total. The
calibrated level roughly doubles, and the Bayes factor rises to 22.6.
The coefficient clears the bar under either sample size, so the
conclusion does not hinge on the choice.

## A joint test

Is race related to wages at all? The test has two restrictions, so `q`
is 2, and `p` is the 12 parameters that remain in the model, the
intercept included. For joint tests the targeted effect is on Cohen’s
*f* scale, and `sqrt(0.02)` is what Cohen (1988) calls a small effect.

- R
- Stata

``` r

m0 <- update(m, . ~ . - race)
Fs <- anova(m0, m)$F[2]
Fs
#> [1] 146.7599

klauerBF(n, Fstat = Fs, q = 2, p = 12, de = sqrt(0.02))
#> [1] 4.440275e+60
alphaN(n, BF = 3, method = "ES", q = 2, p = 12, de = sqrt(0.02))
#> [1] 0.0003748979
```

``` stata
test 2.race 3.race
alphan klauerbf, n(`=e(N)') fstat(`=r(F)') q(2) p(12) de(sqrt(.02))
alphan `=e(N)', bf(3) method(es) q(2) p(12) de(sqrt(.02))
```

``` stata-output
 ( 1)  2.race = 0
 ( 2)  3.race = 0

       F(  2, 18950) =  146.76
            Prob > F =    0.0000

Klauer et al. (2025) Bayes factor                     method: ES
prior: de = .1414, nu = 3, r = .05774, q = 2, p = 12

           n |          F          BF
-------------+------------------------
      18,964 |   146.7599  4.4403e+60

Significance level calibrated to a Bayes factor       method: ES
prior: de = .1414, nu = 3, r = .05774, q = 2 (joint F test), p = 12

           n |         BF       alpha
-------------+------------------------
      18,964 |          3  .000374898
```

## How much does the method matter?

Here are all six calibrations at this sample size, for a target of 3.
For the two Klauer calibrations we target a standardized effect of 0.2
and give `p`, the 13 other coefficients including the intercept.

- R
- Stata

``` r

c(sapply(c("JAB", "min", "robust", "balanced"),
         function(mm) alphaN(n, BF = 3, method = mm)),
  ES     = alphaN(n, BF = 3, method = "ES", de = 0.2, p = 13),
  moment = alphaN(n, BF = 3, method = "moment", de = 0.2, p = 13))
#>          JAB          min       robust     balanced           ES       moment 
#> 0.0005186127 0.0007527044 0.0076127859 0.0104883658 0.0011279310 0.0001079127
```

``` stata
foreach m in jab min robust balanced {
    alphan `=e(N)', bf(3) method(`m')
}
alphan `=e(N)', bf(3) method(es) de(.2) p(13)
alphan `=e(N)', bf(3) method(moment) de(.2) p(13)
```

``` stata-output
Significance level calibrated to a Bayes factor       method: JAB

           n |         BF       alpha
-------------+------------------------
      18,964 |          3  .000518613

Significance level calibrated to a Bayes factor       method: min

           n |         BF       alpha
-------------+------------------------
      18,964 |          3  .000752704

Significance level calibrated to a Bayes factor       method: robust

           n |         BF       alpha
-------------+------------------------
      18,964 |          3   .00761279

Significance level calibrated to a Bayes factor       method: balanced
realistic effects: uniform on [0, 1]

           n |         BF       alpha
-------------+------------------------
      18,964 |          3    .0104884

Significance level calibrated to a Bayes factor       method: ES
prior: de = .2, nu = 3, r = .1155, p = 13

           n |         BF       alpha
-------------+------------------------
      18,964 |          3   .00112793

Significance level calibrated to a Bayes factor       method: moment
prior: de = .2, nu = 5, p = 13

           n |         BF       alpha
-------------+------------------------
      18,964 |          3  .000107911
```

The levels span two orders of magnitude, from about .0001 under the
moment prior to about .01 under the balanced prior, so the method is a
substantive choice to be made and reported in advance. [Choosing a
calibration](https://jespernwulff.github.io/alphaN/articles/choosing.md)
goes through the options.

## Other models

Nothing here is specific to linear regression.
[`JAB()`](https://jespernwulff.github.io/alphaN/reference/JAB.md)
accepts [`glm()`](https://rdrr.io/r/stats/glm.html) fits and
`alphan jab` runs after any Stata estimator that stores `e(b)`, `e(V)`
and `e(N)`.

- R
- Stata

``` r

g <- glm(union ~ age + ttl_exp + tenure + not_smsa + south + c_city + race +
           collgrad + msp + nev_mar, data = nls, family = binomial)
signif(JAB(g), 3)
#>       age   ttl_exp    tenure  not_smsa     south    c_city raceblack raceother 
#>  1.30e-02  4.12e+01  2.77e+69  5.08e-02  4.75e+94  5.40e-01  3.01e+67  9.69e-03 
#>  collgrad       msp   nev_mar 
#>  2.18e+18  5.42e-02  1.08e+00
```

``` stata
logit union age ttl_exp tenure not_smsa south c_city i.race collgrad msp nev_mar
alphan jab
```

``` stata-output
Iteration 0:  Log likelihood = -10360.082
Iteration 1:  Log likelihood = -9712.8826
Iteration 2:  Log likelihood = -9694.8972
Iteration 3:  Log likelihood = -9694.8713
Iteration 4:  Log likelihood = -9694.8713

Logistic regression                                    Number of obs =  18,997
                                                       LR chi2(11)   = 1330.42
                                                       Prob > chi2   =  0.0000
Log likelihood = -9694.8713                            Pseudo R2     =  0.0642

------------------------------------------------------------------------------
       union | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         age |  -.0045575   .0042306    -1.08   0.281    -.0128494    .0037344
     ttl_exp |  -.0285789   .0068734    -4.16   0.000    -.0420506   -.0151072
      tenure |    .102121   .0056246    18.16   0.000     .0910969     .113145
    not_smsa |  -.0929933   .0471302    -1.97   0.048    -.1853668   -.0006197
       south |  -.8710804   .0412536   -21.12   0.000     -.951936   -.7902248
      c_city |   .1271884   .0433234     2.94   0.003     .0422761    .2121007
             |
        race |
      Black  |    .775809   .0433282    17.91   0.000     .6908872    .8607308
      Other  |  -.1326003   .1742295    -0.76   0.447    -.4740838    .2088832
             |
    collgrad |   .4221663   .0434727     9.71   0.000     .3369613    .5073714
         msp |  -.0945112   .0471299    -2.01   0.045    -.1868841   -.0021383
     nev_mar |  -.1865813   .0589945    -3.16   0.002    -.3022083   -.0709542
       _cons |  -1.184003   .1236324    -9.58   0.000    -1.426318   -.9416879
------------------------------------------------------------------------------

Jeffreys' approximate Bayes factor after logit        method: JAB
n = 18,997

-------------------------------------------------------------------------------
         Coefficient |           b  Std. err.        z     P>|z| BF (H1 vs H0)
---------------------+---------------------------------------------------------
                 age |  -.00455747  .00423064    -1.08    0.2814       .012961
             ttl_exp |  -.02857892  .00687345    -4.16    0.0000        41.179
              tenure |   .10212096  .00562462    18.16    0.0000    2.7644e+69
            not_smsa |  -.09299326  .04713022    -1.97    0.0485       .050822
               south |   -.8710804  .04125361   -21.12    0.0000    4.7490e+94
              c_city |   .12718838  .04332339     2.94    0.0033        .53978
              2.race |     .775809  .04332823    17.91    0.0000    3.0111e+67
              3.race |  -.13260029  .17422949    -0.76    0.4466      .0096925
            collgrad |   .42216633  .04347275     9.71    0.0000    2.1810e+18
                 msp |   -.0945112   .0471299    -2.01    0.0449       .054186
             nev_mar |  -.18658127  .05899447    -3.16    0.0016        1.0782
-------------------------------------------------------------------------------
```

In this model `nev_mar` has a *p*-value of .002 and a Bayes factor of
1.08. It would pass a conventional test while the data do not
distinguish the two hypotheses.

## What the level costs

A lower level means less power, and at design time the two should be
chosen together. The standardized effect `d` is what the *t* statistic
divided by the square root of the sample size estimates.

- R
- Stata

``` r

alphaN_power(n, d = c(0.02, 0.05, 0.1), BF = 3)
#> [1] 0.2366270 0.9996793 1.0000000
alphaN_power(n, d = c(0.02, 0.05, 0.1), BF = 3, method = "balanced")
#> [1] 0.5771707 0.9999924 1.0000000
```

``` stata
alphan power 18964, d(.02 .05 .1) bf(3)
alphan power 18964, d(.02 .05 .1) bf(3) method(balanced)
```

``` stata-output
Power at the calibrated significance level            method: JAB

           n |          d          BF       alpha       power
-------------+------------------------------------------------
      18,964 |        .02           3  .000518613      0.2366
      18,964 |        .05           3  .000518613      0.9997
      18,964 |         .1           3  .000518613      1.0000

Power at the calibrated significance level            method: balanced

           n |          d          BF       alpha       power
-------------+------------------------------------------------
      18,964 |        .02           3    .0104884      0.5772
      18,964 |        .05           3    .0104884      1.0000
      18,964 |         .1           3    .0104884      1.0000
```

With this sample the JAB calibration detects effects of 0.05 almost with
certainty and an effect of 0.02 only about a quarter of the time.

## Reporting

The report records the settings and the decision rule, ready to attach
to a preregistration.

- R
- Stata

``` r

alphaN_report(n, BF = 3, power_at = c(0.02, 0.05))
#> # alphaN settings report
#> 
#> Generated on 2026-11-08 with alphaN 0.3.0.
#> 
#> ## Inputs
#> 
#> - Sample size (n): 18,964
#> - Target Bayes factor: 3 (moderate evidence)
#> - Calibration method: JAB: Jeffreys' approximate Bayes factor
#>   (unit-information prior, b = 1/n)
#> 
#> ## Result
#> 
#> - Calibrated alpha level: 0.000519
#> - Decision rule: Reject H0 if the two-sided p-value of the coefficient
#>   is at or below 0.000519.
#> - Interpretation: a significant result then corresponds to a Bayes
#>   factor of at least 3 in favor of the alternative under this prior.
#> 
#> ## Power at the calibrated alpha
#> 
#> - Against a standardized effect of 0.02: 0.24
#> - Against a standardized effect of 0.05: 1.00
#> 
#> ## Please cite
#> 
#> - Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on
#>   sample size: A Bayesian-frequentist compromise for significance
#>   testing. Strategic Organization, 22(3), 550-581.
#>   doi:10.1177/14761270231214429
```

``` stata
alphan report 18964, bf(3) powerat(.02 .05)
```

``` stata-output
# alphaN settings report

Generated on 2026-11-08 with alphaN for Stata 0.3.0.

## Inputs

- Sample size (n): 18,964
- Target Bayes factor: 3 (moderate evidence)
- Calibration method: JAB: Jeffreys' approximate Bayes factor
  (unit-information prior, b = 1/n)

## Result

- Calibrated alpha level: 0.000519
- Decision rule: Reject H0 if the two-sided p-value of the coefficient
  is at or below 0.000519.
- Interpretation: a significant result then corresponds to a Bayes
  factor of at least 3 in favor of the alternative under this prior.

## Power at the calibrated alpha

- Against a standardized effect of 0.02: 0.24
- Against a standardized effect of 0.05: 1.00

## Please cite

- Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on
  sample size: A Bayesian-frequentist compromise for significance
  testing. Strategic Organization, 22(3), 550-581.
  doi:10.1177/14761270231214429
```

The mapping from *p*-values to Bayes factors at this sample size shows
why a .05 threshold would mislead: the whole range of *p*-values just
below .05 corresponds to Bayes factors well below 1.

``` stata
alphan jabplot 18964, bf(3)
```

![The Bayes factor against the p-value at a sample size of 18,964, with
the levels for Bayes factors of 1, 3 and 10
marked.](data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+DQo8IS0tIFRoaXMgaXMgYSBTdGF0YSAxOS41IGdlbmVyYXRlZCBTVkcgZmlsZSAoaHR0cDovL3d3dy5zdGF0YS5jb20pIC0tPg0KDQo8c3ZnIHZlcnNpb249IjEuMSIgd2lkdGg9IjcuNTAwaW4iIGhlaWdodD0iNC41MDBpbiIgdmlld0JveD0iMCAwIDU0MDAgMzI0MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+DQoJPGRlc2M+U3RhdGEgR3JhcGggLSBHcmFwaDwvZGVzYz4NCgk8cmVjdCB4PSIwIiB5PSIwIiB3aWR0aD0iNTQwMCIgaGVpZ2h0PSIzMjQwIiBzdHlsZT0iZmlsbDojRkZGRkZGO3N0cm9rZTpub25lIi8+DQoJPHJlY3QgeD0iMC4wMCIgeT0iMC4wMCIgd2lkdGg9IjU0MDAuMDAiIGhlaWdodD0iMzI0MC4wMCIgc3R5bGU9ImZpbGw6I0ZGRkZGRiIvPg0KCTxyZWN0IHg9IjMuMjQiIHk9IjMuMjQiIHdpZHRoPSI1MzkzLjUyIiBoZWlnaHQ9IjMyMzMuNTIiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiNGRkZGRkY7c3Ryb2tlLXdpZHRoOjYuNDgiLz4NCgk8cmVjdCB4PSI1NzAuODgiIHk9IjI3Ni4wNyIgd2lkdGg9IjQ3MTUuNzIiIGhlaWdodD0iMjM5My4wNCIgc3R5bGU9ImZpbGw6I0ZGRkZGRiIvPg0KCTxyZWN0IHg9IjU3NC4xMiIgeT0iMjc5LjMxIiB3aWR0aD0iNDcwOS4yNCIgaGVpZ2h0PSIyMzg2LjU2IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojRkZGRkZGO3N0cm9rZS13aWR0aDo2LjQ4Ii8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjI2NjkuMTIiIHgyPSI3OTcuMzQiIHkyPSIyNjQzLjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMjYyMC41MiIgeDI9Ijc5Ny4zNCIgeTI9IjI1OTQuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIyNTcxLjkyIiB4Mj0iNzk3LjM0IiB5Mj0iMjU0NS45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjI1MjMuMzIiIHgyPSI3OTcuMzQiIHkyPSIyNDk3LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMjQ3NC43MiIgeDI9Ijc5Ny4zNCIgeTI9IjI0NDguNzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIyNDI2LjEyIiB4Mj0iNzk3LjM0IiB5Mj0iMjQwMC4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjIzNzcuNTIiIHgyPSI3OTcuMzQiIHkyPSIyMzUxLjUzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMjMyOC45MiIgeDI9Ijc5Ny4zNCIgeTI9IjIzMDIuOTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIyMjgwLjMyIiB4Mj0iNzk3LjM0IiB5Mj0iMjI1NC4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjIyMzEuNzIiIHgyPSI3OTcuMzQiIHkyPSIyMjA1LjczIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMjE4My4xMiIgeDI9Ijc5Ny4zNCIgeTI9IjIxNTcuMTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIyMTM0LjUyIiB4Mj0iNzk3LjM0IiB5Mj0iMjEwOC41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjIwODUuOTIiIHgyPSI3OTcuMzQiIHkyPSIyMDU5LjkzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMjAzNy4zMiIgeDI9Ijc5Ny4zNCIgeTI9IjIwMTEuMzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIxOTg4LjcyIiB4Mj0iNzk3LjM0IiB5Mj0iMTk2Mi43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjE5NDAuMTIiIHgyPSI3OTcuMzQiIHkyPSIxOTE0LjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMTg5MS41MiIgeDI9Ijc5Ny4zNCIgeTI9IjE4NjUuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIxODQyLjkyIiB4Mj0iNzk3LjM0IiB5Mj0iMTgxNi45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjE3OTQuMzIiIHgyPSI3OTcuMzQiIHkyPSIxNzY4LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMTc0NS43MiIgeDI9Ijc5Ny4zNCIgeTI9IjE3MTkuNzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIxNjk3LjEyIiB4Mj0iNzk3LjM0IiB5Mj0iMTY3MS4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjE2NDguNTIiIHgyPSI3OTcuMzQiIHkyPSIxNjIyLjUzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMTU5OS45MiIgeDI9Ijc5Ny4zNCIgeTI9IjE1NzMuOTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIxNTUxLjMyIiB4Mj0iNzk3LjM0IiB5Mj0iMTUyNS4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjE1MDIuNzIiIHgyPSI3OTcuMzQiIHkyPSIxNDc2LjczIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMTQ1NC4xMiIgeDI9Ijc5Ny4zNCIgeTI9IjE0MjguMTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIxNDA1LjUyIiB4Mj0iNzk3LjM0IiB5Mj0iMTM3OS41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjEzNTYuOTIiIHgyPSI3OTcuMzQiIHkyPSIxMzMwLjkzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMTMwOC4zMiIgeDI9Ijc5Ny4zNCIgeTI9IjEyODIuMzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIxMjU5LjcyIiB4Mj0iNzk3LjM0IiB5Mj0iMTIzMy43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjEyMTEuMTIiIHgyPSI3OTcuMzQiIHkyPSIxMTg1LjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMTE2Mi41MiIgeDI9Ijc5Ny4zNCIgeTI9IjExMzYuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI3OTcuMzQiIHkxPSIxMTEzLjkyIiB4Mj0iNzk3LjM0IiB5Mj0iMTA4Ny45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjEwNjUuMzIiIHgyPSI3OTcuMzQiIHkyPSIxMDM5LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNzk3LjM0IiB5MT0iMTAxNi43MiIgeDI9Ijc5Ny4zNCIgeTI9Ijk5MC43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9Ijk2OC4xMiIgeDI9Ijc5Ny4zNCIgeTI9Ijk0Mi4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjkxOS41MiIgeDI9Ijc5Ny4zNCIgeTI9Ijg5My41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9Ijg3MC45MiIgeDI9Ijc5Ny4zNCIgeTI9Ijg0NC45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjgyMi4zMiIgeDI9Ijc5Ny4zNCIgeTI9Ijc5Ni4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9Ijc3My43MiIgeDI9Ijc5Ny4zNCIgeTI9Ijc0Ny43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjcyNS4xMiIgeDI9Ijc5Ny4zNCIgeTI9IjY5OS4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjY3Ni41MiIgeDI9Ijc5Ny4zNCIgeTI9IjY1MC41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjYyNy45MiIgeDI9Ijc5Ny4zNCIgeTI9IjYwMS45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjU3OS4zMiIgeDI9Ijc5Ny4zNCIgeTI9IjU1My4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjUzMC43MiIgeDI9Ijc5Ny4zNCIgeTI9IjUwNC43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjQ4Mi4xMiIgeDI9Ijc5Ny4zNCIgeTI9IjQ1Ni4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjQzMy41MiIgeDI9Ijc5Ny4zNCIgeTI9IjQwNy41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjM4NC45MiIgeDI9Ijc5Ny4zNCIgeTI9IjM1OC45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjMzNi4zMiIgeDI9Ijc5Ny4zNCIgeTI9IjMxMC4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9Ijc5Ny4zNCIgeTE9IjI4Ny43MiIgeDI9Ijc5Ny4zNCIgeTI9IjI3Ni4wNyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjI2NjkuMTIiIHgyPSI2ODkuNTEiIHkyPSIyNjQzLjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjYyMC41MiIgeDI9IjY4OS41MSIgeTI9IjI1OTQuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIyNTcxLjkyIiB4Mj0iNjg5LjUxIiB5Mj0iMjU0NS45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjI1MjMuMzIiIHgyPSI2ODkuNTEiIHkyPSIyNDk3LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjQ3NC43MiIgeDI9IjY4OS41MSIgeTI9IjI0NDguNzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIyNDI2LjEyIiB4Mj0iNjg5LjUxIiB5Mj0iMjQwMC4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjIzNzcuNTIiIHgyPSI2ODkuNTEiIHkyPSIyMzUxLjUzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjMyOC45MiIgeDI9IjY4OS41MSIgeTI9IjIzMDIuOTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIyMjgwLjMyIiB4Mj0iNjg5LjUxIiB5Mj0iMjI1NC4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjIyMzEuNzIiIHgyPSI2ODkuNTEiIHkyPSIyMjA1LjczIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjE4My4xMiIgeDI9IjY4OS41MSIgeTI9IjIxNTcuMTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIyMTM0LjUyIiB4Mj0iNjg5LjUxIiB5Mj0iMjEwOC41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjIwODUuOTIiIHgyPSI2ODkuNTEiIHkyPSIyMDU5LjkzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjAzNy4zMiIgeDI9IjY4OS41MSIgeTI9IjIwMTEuMzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxOTg4LjcyIiB4Mj0iNjg5LjUxIiB5Mj0iMTk2Mi43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjE5NDAuMTIiIHgyPSI2ODkuNTEiIHkyPSIxOTE0LjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTg5MS41MiIgeDI9IjY4OS41MSIgeTI9IjE4NjUuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxODQyLjkyIiB4Mj0iNjg5LjUxIiB5Mj0iMTgxNi45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjE3OTQuMzIiIHgyPSI2ODkuNTEiIHkyPSIxNzY4LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTc0NS43MiIgeDI9IjY4OS41MSIgeTI9IjE3MTkuNzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxNjk3LjEyIiB4Mj0iNjg5LjUxIiB5Mj0iMTY3MS4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjE2NDguNTIiIHgyPSI2ODkuNTEiIHkyPSIxNjIyLjUzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTU5OS45MiIgeDI9IjY4OS41MSIgeTI9IjE1NzMuOTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxNTUxLjMyIiB4Mj0iNjg5LjUxIiB5Mj0iMTUyNS4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjE1MDIuNzIiIHgyPSI2ODkuNTEiIHkyPSIxNDc2LjczIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTQ1NC4xMiIgeDI9IjY4OS41MSIgeTI9IjE0MjguMTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxNDA1LjUyIiB4Mj0iNjg5LjUxIiB5Mj0iMTM3OS41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjEzNTYuOTIiIHgyPSI2ODkuNTEiIHkyPSIxMzMwLjkzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTMwOC4zMiIgeDI9IjY4OS41MSIgeTI9IjEyODIuMzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxMjU5LjcyIiB4Mj0iNjg5LjUxIiB5Mj0iMTIzMy43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjEyMTEuMTIiIHgyPSI2ODkuNTEiIHkyPSIxMTg1LjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTE2Mi41MiIgeDI9IjY4OS41MSIgeTI9IjExMzYuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxMTEzLjkyIiB4Mj0iNjg5LjUxIiB5Mj0iMTA4Ny45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjEwNjUuMzIiIHgyPSI2ODkuNTEiIHkyPSIxMDM5LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTAxNi43MiIgeDI9IjY4OS41MSIgeTI9Ijk5MC43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9Ijk2OC4xMiIgeDI9IjY4OS41MSIgeTI9Ijk0Mi4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjkxOS41MiIgeDI9IjY4OS41MSIgeTI9Ijg5My41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9Ijg3MC45MiIgeDI9IjY4OS41MSIgeTI9Ijg0NC45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjgyMi4zMiIgeDI9IjY4OS41MSIgeTI9Ijc5Ni4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9Ijc3My43MiIgeDI9IjY4OS41MSIgeTI9Ijc0Ny43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjcyNS4xMiIgeDI9IjY4OS41MSIgeTI9IjY5OS4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjY3Ni41MiIgeDI9IjY4OS41MSIgeTI9IjY1MC41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjYyNy45MiIgeDI9IjY4OS41MSIgeTI9IjYwMS45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjU3OS4zMiIgeDI9IjY4OS41MSIgeTI9IjU1My4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjUzMC43MiIgeDI9IjY4OS41MSIgeTI9IjUwNC43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjQ4Mi4xMiIgeDI9IjY4OS41MSIgeTI9IjQ1Ni4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjQzMy41MiIgeDI9IjY4OS41MSIgeTI9IjQwNy41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjM4NC45MiIgeDI9IjY4OS41MSIgeTI9IjM1OC45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjMzNi4zMiIgeDI9IjY4OS41MSIgeTI9IjMxMC4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjI4Ny43MiIgeDI9IjY4OS41MSIgeTI9IjI3Ni4wNyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjI2NjkuMTIiIHgyPSI2NTUuMjYiIHkyPSIyNjQzLjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMjYyMC41MiIgeDI9IjY1NS4yNiIgeTI9IjI1OTQuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIyNTcxLjkyIiB4Mj0iNjU1LjI2IiB5Mj0iMjU0NS45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjI1MjMuMzIiIHgyPSI2NTUuMjYiIHkyPSIyNDk3LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMjQ3NC43MiIgeDI9IjY1NS4yNiIgeTI9IjI0NDguNzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIyNDI2LjEyIiB4Mj0iNjU1LjI2IiB5Mj0iMjQwMC4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjIzNzcuNTIiIHgyPSI2NTUuMjYiIHkyPSIyMzUxLjUzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMjMyOC45MiIgeDI9IjY1NS4yNiIgeTI9IjIzMDIuOTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIyMjgwLjMyIiB4Mj0iNjU1LjI2IiB5Mj0iMjI1NC4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjIyMzEuNzIiIHgyPSI2NTUuMjYiIHkyPSIyMjA1LjczIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMjE4My4xMiIgeDI9IjY1NS4yNiIgeTI9IjIxNTcuMTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIyMTM0LjUyIiB4Mj0iNjU1LjI2IiB5Mj0iMjEwOC41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjIwODUuOTIiIHgyPSI2NTUuMjYiIHkyPSIyMDU5LjkzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMjAzNy4zMiIgeDI9IjY1NS4yNiIgeTI9IjIwMTEuMzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIxOTg4LjcyIiB4Mj0iNjU1LjI2IiB5Mj0iMTk2Mi43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjE5NDAuMTIiIHgyPSI2NTUuMjYiIHkyPSIxOTE0LjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMTg5MS41MiIgeDI9IjY1NS4yNiIgeTI9IjE4NjUuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIxODQyLjkyIiB4Mj0iNjU1LjI2IiB5Mj0iMTgxNi45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjE3OTQuMzIiIHgyPSI2NTUuMjYiIHkyPSIxNzY4LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMTc0NS43MiIgeDI9IjY1NS4yNiIgeTI9IjE3MTkuNzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIxNjk3LjEyIiB4Mj0iNjU1LjI2IiB5Mj0iMTY3MS4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjE2NDguNTIiIHgyPSI2NTUuMjYiIHkyPSIxNjIyLjUzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMTU5OS45MiIgeDI9IjY1NS4yNiIgeTI9IjE1NzMuOTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIxNTUxLjMyIiB4Mj0iNjU1LjI2IiB5Mj0iMTUyNS4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjE1MDIuNzIiIHgyPSI2NTUuMjYiIHkyPSIxNDc2LjczIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMTQ1NC4xMiIgeDI9IjY1NS4yNiIgeTI9IjE0MjguMTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIxNDA1LjUyIiB4Mj0iNjU1LjI2IiB5Mj0iMTM3OS41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjEzNTYuOTIiIHgyPSI2NTUuMjYiIHkyPSIxMzMwLjkzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMTMwOC4zMiIgeDI9IjY1NS4yNiIgeTI9IjEyODIuMzMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIxMjU5LjcyIiB4Mj0iNjU1LjI2IiB5Mj0iMTIzMy43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjEyMTEuMTIiIHgyPSI2NTUuMjYiIHkyPSIxMTg1LjEzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMTE2Mi41MiIgeDI9IjY1NS4yNiIgeTI9IjExMzYuNTMiIHN0eWxlPSJzdHJva2U6IzkwOTA5MDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2NTUuMjYiIHkxPSIxMTEzLjkyIiB4Mj0iNjU1LjI2IiB5Mj0iMTA4Ny45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjEwNjUuMzIiIHgyPSI2NTUuMjYiIHkyPSIxMDM5LjMzIiBzdHlsZT0ic3Ryb2tlOiM5MDkwOTA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjU1LjI2IiB5MT0iMTAxNi43MiIgeDI9IjY1NS4yNiIgeTI9Ijk5MC43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9Ijk2OC4xMiIgeDI9IjY1NS4yNiIgeTI9Ijk0Mi4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjkxOS41MiIgeDI9IjY1NS4yNiIgeTI9Ijg5My41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9Ijg3MC45MiIgeDI9IjY1NS4yNiIgeTI9Ijg0NC45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjgyMi4zMiIgeDI9IjY1NS4yNiIgeTI9Ijc5Ni4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9Ijc3My43MiIgeDI9IjY1NS4yNiIgeTI9Ijc0Ny43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjcyNS4xMiIgeDI9IjY1NS4yNiIgeTI9IjY5OS4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjY3Ni41MiIgeDI9IjY1NS4yNiIgeTI9IjY1MC41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjYyNy45MiIgeDI9IjY1NS4yNiIgeTI9IjYwMS45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjU3OS4zMiIgeDI9IjY1NS4yNiIgeTI9IjU1My4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjUzMC43MiIgeDI9IjY1NS4yNiIgeTI9IjUwNC43MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjQ4Mi4xMiIgeDI9IjY1NS4yNiIgeTI9IjQ1Ni4xMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjQzMy41MiIgeDI9IjY1NS4yNiIgeTI9IjQwNy41MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjM4NC45MiIgeDI9IjY1NS4yNiIgeTI9IjM1OC45MyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjMzNi4zMiIgeDI9IjY1NS4yNiIgeTI9IjMxMC4zMyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY1NS4yNiIgeTE9IjI4Ny43MiIgeDI9IjY1NS4yNiIgeTI9IjI3Ni4wNyIgc3R5bGU9InN0cm9rZTojOTA5MDkwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjI2NjkuMTIiIHgyPSI2ODkuNTEiIHkyPSIyNjQzLjEzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjYyMC41MiIgeDI9IjY4OS41MSIgeTI9IjI1OTQuNTMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIyNTcxLjkyIiB4Mj0iNjg5LjUxIiB5Mj0iMjU0NS45MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjI1MjMuMzIiIHgyPSI2ODkuNTEiIHkyPSIyNDk3LjMzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjQ3NC43MiIgeDI9IjY4OS41MSIgeTI9IjI0NDguNzMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIyNDI2LjEyIiB4Mj0iNjg5LjUxIiB5Mj0iMjQwMC4xMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjIzNzcuNTIiIHgyPSI2ODkuNTEiIHkyPSIyMzUxLjUzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjMyOC45MiIgeDI9IjY4OS41MSIgeTI9IjIzMDIuOTMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIyMjgwLjMyIiB4Mj0iNjg5LjUxIiB5Mj0iMjI1NC4zMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjIyMzEuNzIiIHgyPSI2ODkuNTEiIHkyPSIyMjA1LjczIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjE4My4xMiIgeDI9IjY4OS41MSIgeTI9IjIxNTcuMTMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIyMTM0LjUyIiB4Mj0iNjg5LjUxIiB5Mj0iMjEwOC41MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjIwODUuOTIiIHgyPSI2ODkuNTEiIHkyPSIyMDU5LjkzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMjAzNy4zMiIgeDI9IjY4OS41MSIgeTI9IjIwMTEuMzMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxOTg4LjcyIiB4Mj0iNjg5LjUxIiB5Mj0iMTk2Mi43MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjE5NDAuMTIiIHgyPSI2ODkuNTEiIHkyPSIxOTE0LjEzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTg5MS41MiIgeDI9IjY4OS41MSIgeTI9IjE4NjUuNTMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxODQyLjkyIiB4Mj0iNjg5LjUxIiB5Mj0iMTgxNi45MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjE3OTQuMzIiIHgyPSI2ODkuNTEiIHkyPSIxNzY4LjMzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTc0NS43MiIgeDI9IjY4OS41MSIgeTI9IjE3MTkuNzMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxNjk3LjEyIiB4Mj0iNjg5LjUxIiB5Mj0iMTY3MS4xMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjE2NDguNTIiIHgyPSI2ODkuNTEiIHkyPSIxNjIyLjUzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTU5OS45MiIgeDI9IjY4OS41MSIgeTI9IjE1NzMuOTMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxNTUxLjMyIiB4Mj0iNjg5LjUxIiB5Mj0iMTUyNS4zMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjE1MDIuNzIiIHgyPSI2ODkuNTEiIHkyPSIxNDc2LjczIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTQ1NC4xMiIgeDI9IjY4OS41MSIgeTI9IjE0MjguMTMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxNDA1LjUyIiB4Mj0iNjg5LjUxIiB5Mj0iMTM3OS41MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjEzNTYuOTIiIHgyPSI2ODkuNTEiIHkyPSIxMzMwLjkzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTMwOC4zMiIgeDI9IjY4OS41MSIgeTI9IjEyODIuMzMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxMjU5LjcyIiB4Mj0iNjg5LjUxIiB5Mj0iMTIzMy43MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjEyMTEuMTIiIHgyPSI2ODkuNTEiIHkyPSIxMTg1LjEzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTE2Mi41MiIgeDI9IjY4OS41MSIgeTI9IjExMzYuNTMiIHN0eWxlPSJzdHJva2U6I0Q1NUUwMDtzdHJva2Utd2lkdGg6OS43MiIvPg0KCTxsaW5lIHgxPSI2ODkuNTEiIHkxPSIxMTEzLjkyIiB4Mj0iNjg5LjUxIiB5Mj0iMTA4Ny45MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjEwNjUuMzIiIHgyPSI2ODkuNTEiIHkyPSIxMDM5LjMzIiBzdHlsZT0ic3Ryb2tlOiNENTVFMDA7c3Ryb2tlLXdpZHRoOjkuNzIiLz4NCgk8bGluZSB4MT0iNjg5LjUxIiB5MT0iMTAxNi43MiIgeDI9IjY4OS41MSIgeTI9Ijk5MC43MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9Ijk2OC4xMiIgeDI9IjY4OS41MSIgeTI9Ijk0Mi4xMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjkxOS41MiIgeDI9IjY4OS41MSIgeTI9Ijg5My41MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9Ijg3MC45MiIgeDI9IjY4OS41MSIgeTI9Ijg0NC45MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjgyMi4zMiIgeDI9IjY4OS41MSIgeTI9Ijc5Ni4zMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9Ijc3My43MiIgeDI9IjY4OS41MSIgeTI9Ijc0Ny43MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjcyNS4xMiIgeDI9IjY4OS41MSIgeTI9IjY5OS4xMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjY3Ni41MiIgeDI9IjY4OS41MSIgeTI9IjY1MC41MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjYyNy45MiIgeDI9IjY4OS41MSIgeTI9IjYwMS45MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjU3OS4zMiIgeDI9IjY4OS41MSIgeTI9IjU1My4zMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjUzMC43MiIgeDI9IjY4OS41MSIgeTI9IjUwNC43MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjQ4Mi4xMiIgeDI9IjY4OS41MSIgeTI9IjQ1Ni4xMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjQzMy41MiIgeDI9IjY4OS41MSIgeTI9IjQwNy41MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjM4NC45MiIgeDI9IjY4OS41MSIgeTI9IjM1OC45MyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjMzNi4zMiIgeDI9IjY4OS41MSIgeTI9IjMxMC4zMyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjY4OS41MSIgeTE9IjI4Ny43MiIgeDI9IjY4OS41MSIgeTI9IjI3Ni4wNyIgc3R5bGU9InN0cm9rZTojRDU1RTAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjU3MC44OCIgeTE9IjI1OTcuOTEiIHgyPSI2MzUuNjgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNjY4LjA4IiB5MT0iMjU5Ny45MSIgeDI9IjczMi44OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI3NjUuMjgiIHkxPSIyNTk3LjkxIiB4Mj0iODMwLjA4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9Ijg2Mi40OCIgeTE9IjI1OTcuOTEiIHgyPSI5MjcuMjgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iOTU5LjY4IiB5MT0iMjU5Ny45MSIgeDI9IjEwMjQuNDgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTA1Ni44OCIgeTE9IjI1OTcuOTEiIHgyPSIxMTIxLjY4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjExNTQuMDgiIHkxPSIyNTk3LjkxIiB4Mj0iMTIxOC44OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxMjUxLjI4IiB5MT0iMjU5Ny45MSIgeDI9IjEzMTYuMDgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTM0OC40OCIgeTE9IjI1OTcuOTEiIHgyPSIxNDEzLjI4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE0NDUuNjgiIHkxPSIyNTk3LjkxIiB4Mj0iMTUxMC40OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxNTQyLjg4IiB5MT0iMjU5Ny45MSIgeDI9IjE2MDcuNjgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTY0MC4wOCIgeTE9IjI1OTcuOTEiIHgyPSIxNzA0Ljg4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE3MzcuMjgiIHkxPSIyNTk3LjkxIiB4Mj0iMTgwMi4wOCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxODM0LjQ4IiB5MT0iMjU5Ny45MSIgeDI9IjE4OTkuMjgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTkzMS42OCIgeTE9IjI1OTcuOTEiIHgyPSIxOTk2LjQ4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjIwMjguODgiIHkxPSIyNTk3LjkxIiB4Mj0iMjA5My42OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyMTI2LjA4IiB5MT0iMjU5Ny45MSIgeDI9IjIxOTAuODgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjIyMy4yOCIgeTE9IjI1OTcuOTEiIHgyPSIyMjg4LjA4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjIzMjAuNDgiIHkxPSIyNTk3LjkxIiB4Mj0iMjM4NS4yOCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyNDE3LjY4IiB5MT0iMjU5Ny45MSIgeDI9IjI0ODIuNDgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjUxNC44OCIgeTE9IjI1OTcuOTEiIHgyPSIyNTc5LjY4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI2MTIuMDgiIHkxPSIyNTk3LjkxIiB4Mj0iMjY3Ni44OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyNzA5LjI4IiB5MT0iMjU5Ny45MSIgeDI9IjI3NzQuMDgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjgwNi40OCIgeTE9IjI1OTcuOTEiIHgyPSIyODcxLjI4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI5MDMuNjgiIHkxPSIyNTk3LjkxIiB4Mj0iMjk2OC40OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMDAwLjg4IiB5MT0iMjU5Ny45MSIgeDI9IjMwNjUuNjgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzA5OC4wOCIgeTE9IjI1OTcuOTEiIHgyPSIzMTYyLjg4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjMxOTUuMjgiIHkxPSIyNTk3LjkxIiB4Mj0iMzI2MC4wOCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMjkyLjQ4IiB5MT0iMjU5Ny45MSIgeDI9IjMzNTcuMjgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzM4OS42OCIgeTE9IjI1OTcuOTEiIHgyPSIzNDU0LjQ4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM0ODYuODgiIHkxPSIyNTk3LjkxIiB4Mj0iMzU1MS42OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzNTg0LjA4IiB5MT0iMjU5Ny45MSIgeDI9IjM2NDguODgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzY4MS4yOCIgeTE9IjI1OTcuOTEiIHgyPSIzNzQ2LjA4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM3NzguNDgiIHkxPSIyNTk3LjkxIiB4Mj0iMzg0My4yOCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzODc1LjY4IiB5MT0iMjU5Ny45MSIgeDI9IjM5NDAuNDgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzk3Mi44OCIgeTE9IjI1OTcuOTEiIHgyPSI0MDM3LjY4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQwNzAuMDgiIHkxPSIyNTk3LjkxIiB4Mj0iNDEzNC44OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0MTY3LjI4IiB5MT0iMjU5Ny45MSIgeDI9IjQyMzIuMDgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDI2NC40OCIgeTE9IjI1OTcuOTEiIHgyPSI0MzI5LjI4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQzNjEuNjgiIHkxPSIyNTk3LjkxIiB4Mj0iNDQyNi40OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0NDU4Ljg4IiB5MT0iMjU5Ny45MSIgeDI9IjQ1MjMuNjgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDU1Ni4wOCIgeTE9IjI1OTcuOTEiIHgyPSI0NjIwLjg4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ2NTMuMjgiIHkxPSIyNTk3LjkxIiB4Mj0iNDcxOC4wOCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0NzUwLjQ4IiB5MT0iMjU5Ny45MSIgeDI9IjQ4MTUuMjgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDg0Ny42OCIgeTE9IjI1OTcuOTEiIHgyPSI0OTEyLjQ4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ5NDQuODgiIHkxPSIyNTk3LjkxIiB4Mj0iNTAwOS42OCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI1MDQyLjA4IiB5MT0iMjU5Ny45MSIgeDI9IjUxMDYuODgiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNTEzOS4yOCIgeTE9IjI1OTcuOTEiIHgyPSI1MjA0LjA4IiB5Mj0iMjU5Ny45MSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjUyMzYuNDgiIHkxPSIyNTk3LjkxIiB4Mj0iNTI4Ni42MCIgeTI9IjI1OTcuOTEiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI1NzAuODgiIHkxPSIyMDA5LjQ4IiB4Mj0iNjM1LjY4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjY2OC4wOCIgeTE9IjIwMDkuNDgiIHgyPSI3MzIuODgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNzY1LjI4IiB5MT0iMjAwOS40OCIgeDI9IjgzMC4wOCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI4NjIuNDgiIHkxPSIyMDA5LjQ4IiB4Mj0iOTI3LjI4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9Ijk1OS42OCIgeTE9IjIwMDkuNDgiIHgyPSIxMDI0LjQ4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjEwNTYuODgiIHkxPSIyMDA5LjQ4IiB4Mj0iMTEyMS42OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxMTU0LjA4IiB5MT0iMjAwOS40OCIgeDI9IjEyMTguODgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTI1MS4yOCIgeTE9IjIwMDkuNDgiIHgyPSIxMzE2LjA4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjEzNDguNDgiIHkxPSIyMDA5LjQ4IiB4Mj0iMTQxMy4yOCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxNDQ1LjY4IiB5MT0iMjAwOS40OCIgeDI9IjE1MTAuNDgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTU0Mi44OCIgeTE9IjIwMDkuNDgiIHgyPSIxNjA3LjY4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE2NDAuMDgiIHkxPSIyMDA5LjQ4IiB4Mj0iMTcwNC44OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxNzM3LjI4IiB5MT0iMjAwOS40OCIgeDI9IjE4MDIuMDgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTgzNC40OCIgeTE9IjIwMDkuNDgiIHgyPSIxODk5LjI4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE5MzEuNjgiIHkxPSIyMDA5LjQ4IiB4Mj0iMTk5Ni40OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyMDI4Ljg4IiB5MT0iMjAwOS40OCIgeDI9IjIwOTMuNjgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjEyNi4wOCIgeTE9IjIwMDkuNDgiIHgyPSIyMTkwLjg4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjIyMjMuMjgiIHkxPSIyMDA5LjQ4IiB4Mj0iMjI4OC4wOCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyMzIwLjQ4IiB5MT0iMjAwOS40OCIgeDI9IjIzODUuMjgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjQxNy42OCIgeTE9IjIwMDkuNDgiIHgyPSIyNDgyLjQ4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI1MTQuODgiIHkxPSIyMDA5LjQ4IiB4Mj0iMjU3OS42OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyNjEyLjA4IiB5MT0iMjAwOS40OCIgeDI9IjI2NzYuODgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjcwOS4yOCIgeTE9IjIwMDkuNDgiIHgyPSIyNzc0LjA4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI4MDYuNDgiIHkxPSIyMDA5LjQ4IiB4Mj0iMjg3MS4yOCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyOTAzLjY4IiB5MT0iMjAwOS40OCIgeDI9IjI5NjguNDgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzAwMC44OCIgeTE9IjIwMDkuNDgiIHgyPSIzMDY1LjY4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjMwOTguMDgiIHkxPSIyMDA5LjQ4IiB4Mj0iMzE2Mi44OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMTk1LjI4IiB5MT0iMjAwOS40OCIgeDI9IjMyNjAuMDgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzI5Mi40OCIgeTE9IjIwMDkuNDgiIHgyPSIzMzU3LjI4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjMzODkuNjgiIHkxPSIyMDA5LjQ4IiB4Mj0iMzQ1NC40OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzNDg2Ljg4IiB5MT0iMjAwOS40OCIgeDI9IjM1NTEuNjgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzU4NC4wOCIgeTE9IjIwMDkuNDgiIHgyPSIzNjQ4Ljg4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM2ODEuMjgiIHkxPSIyMDA5LjQ4IiB4Mj0iMzc0Ni4wOCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzNzc4LjQ4IiB5MT0iMjAwOS40OCIgeDI9IjM4NDMuMjgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzg3NS42OCIgeTE9IjIwMDkuNDgiIHgyPSIzOTQwLjQ4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM5NzIuODgiIHkxPSIyMDA5LjQ4IiB4Mj0iNDAzNy42OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0MDcwLjA4IiB5MT0iMjAwOS40OCIgeDI9IjQxMzQuODgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDE2Ny4yOCIgeTE9IjIwMDkuNDgiIHgyPSI0MjMyLjA4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQyNjQuNDgiIHkxPSIyMDA5LjQ4IiB4Mj0iNDMyOS4yOCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0MzYxLjY4IiB5MT0iMjAwOS40OCIgeDI9IjQ0MjYuNDgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDQ1OC44OCIgeTE9IjIwMDkuNDgiIHgyPSI0NTIzLjY4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ1NTYuMDgiIHkxPSIyMDA5LjQ4IiB4Mj0iNDYyMC44OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0NjUzLjI4IiB5MT0iMjAwOS40OCIgeDI9IjQ3MTguMDgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDc1MC40OCIgeTE9IjIwMDkuNDgiIHgyPSI0ODE1LjI4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ4NDcuNjgiIHkxPSIyMDA5LjQ4IiB4Mj0iNDkxMi40OCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0OTQ0Ljg4IiB5MT0iMjAwOS40OCIgeDI9IjUwMDkuNjgiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNTA0Mi4wOCIgeTE9IjIwMDkuNDgiIHgyPSI1MTA2Ljg4IiB5Mj0iMjAwOS40OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjUxMzkuMjgiIHkxPSIyMDA5LjQ4IiB4Mj0iNTIwNC4wOCIgeTI9IjIwMDkuNDgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI1MjM2LjQ4IiB5MT0iMjAwOS40OCIgeDI9IjUyODYuNjAiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNTcwLjg4IiB5MT0iMTQ3Mi42OCIgeDI9IjYzNS42OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI2NjguMDgiIHkxPSIxNDcyLjY4IiB4Mj0iNzMyLjg4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9Ijc2NS4yOCIgeTE9IjE0NzIuNjgiIHgyPSI4MzAuMDgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iODYyLjQ4IiB5MT0iMTQ3Mi42OCIgeDI9IjkyNy4yOCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI5NTkuNjgiIHkxPSIxNDcyLjY4IiB4Mj0iMTAyNC40OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxMDU2Ljg4IiB5MT0iMTQ3Mi42OCIgeDI9IjExMjEuNjgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTE1NC4wOCIgeTE9IjE0NzIuNjgiIHgyPSIxMjE4Ljg4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjEyNTEuMjgiIHkxPSIxNDcyLjY4IiB4Mj0iMTMxNi4wOCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxMzQ4LjQ4IiB5MT0iMTQ3Mi42OCIgeDI9IjE0MTMuMjgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTQ0NS42OCIgeTE9IjE0NzIuNjgiIHgyPSIxNTEwLjQ4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE1NDIuODgiIHkxPSIxNDcyLjY4IiB4Mj0iMTYwNy42OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxNjQwLjA4IiB5MT0iMTQ3Mi42OCIgeDI9IjE3MDQuODgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTczNy4yOCIgeTE9IjE0NzIuNjgiIHgyPSIxODAyLjA4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE4MzQuNDgiIHkxPSIxNDcyLjY4IiB4Mj0iMTg5OS4yOCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxOTMxLjY4IiB5MT0iMTQ3Mi42OCIgeDI9IjE5OTYuNDgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjAyOC44OCIgeTE9IjE0NzIuNjgiIHgyPSIyMDkzLjY4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjIxMjYuMDgiIHkxPSIxNDcyLjY4IiB4Mj0iMjE5MC44OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyMjIzLjI4IiB5MT0iMTQ3Mi42OCIgeDI9IjIyODguMDgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjMyMC40OCIgeTE9IjE0NzIuNjgiIHgyPSIyMzg1LjI4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI0MTcuNjgiIHkxPSIxNDcyLjY4IiB4Mj0iMjQ4Mi40OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyNTE0Ljg4IiB5MT0iMTQ3Mi42OCIgeDI9IjI1NzkuNjgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjYxMi4wOCIgeTE9IjE0NzIuNjgiIHgyPSIyNjc2Ljg4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI3MDkuMjgiIHkxPSIxNDcyLjY4IiB4Mj0iMjc3NC4wOCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyODA2LjQ4IiB5MT0iMTQ3Mi42OCIgeDI9IjI4NzEuMjgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjkwMy42OCIgeTE9IjE0NzIuNjgiIHgyPSIyOTY4LjQ4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjMwMDAuODgiIHkxPSIxNDcyLjY4IiB4Mj0iMzA2NS42OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMDk4LjA4IiB5MT0iMTQ3Mi42OCIgeDI9IjMxNjIuODgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzE5NS4yOCIgeTE9IjE0NzIuNjgiIHgyPSIzMjYwLjA4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjMyOTIuNDgiIHkxPSIxNDcyLjY4IiB4Mj0iMzM1Ny4yOCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMzg5LjY4IiB5MT0iMTQ3Mi42OCIgeDI9IjM0NTQuNDgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzQ4Ni44OCIgeTE9IjE0NzIuNjgiIHgyPSIzNTUxLjY4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM1ODQuMDgiIHkxPSIxNDcyLjY4IiB4Mj0iMzY0OC44OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzNjgxLjI4IiB5MT0iMTQ3Mi42OCIgeDI9IjM3NDYuMDgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzc3OC40OCIgeTE9IjE0NzIuNjgiIHgyPSIzODQzLjI4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM4NzUuNjgiIHkxPSIxNDcyLjY4IiB4Mj0iMzk0MC40OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzOTcyLjg4IiB5MT0iMTQ3Mi42OCIgeDI9IjQwMzcuNjgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDA3MC4wOCIgeTE9IjE0NzIuNjgiIHgyPSI0MTM0Ljg4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQxNjcuMjgiIHkxPSIxNDcyLjY4IiB4Mj0iNDIzMi4wOCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0MjY0LjQ4IiB5MT0iMTQ3Mi42OCIgeDI9IjQzMjkuMjgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDM2MS42OCIgeTE9IjE0NzIuNjgiIHgyPSI0NDI2LjQ4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ0NTguODgiIHkxPSIxNDcyLjY4IiB4Mj0iNDUyMy42OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0NTU2LjA4IiB5MT0iMTQ3Mi42OCIgeDI9IjQ2MjAuODgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDY1My4yOCIgeTE9IjE0NzIuNjgiIHgyPSI0NzE4LjA4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ3NTAuNDgiIHkxPSIxNDcyLjY4IiB4Mj0iNDgxNS4yOCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0ODQ3LjY4IiB5MT0iMTQ3Mi42OCIgeDI9IjQ5MTIuNDgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDk0NC44OCIgeTE9IjE0NzIuNjgiIHgyPSI1MDA5LjY4IiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjUwNDIuMDgiIHkxPSIxNDcyLjY4IiB4Mj0iNTEwNi44OCIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI1MTM5LjI4IiB5MT0iMTQ3Mi42OCIgeDI9IjUyMDQuMDgiIHkyPSIxNDcyLjY4IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNTIzNi40OCIgeTE9IjE0NzIuNjgiIHgyPSI1Mjg2LjYwIiB5Mj0iMTQ3Mi42OCIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjU3MC44OCIgeTE9IjkzNS43MiIgeDI9IjYzNS42OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjY2OC4wOCIgeTE9IjkzNS43MiIgeDI9IjczMi44OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9Ijc2NS4yOCIgeTE9IjkzNS43MiIgeDI9IjgzMC4wOCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9Ijg2Mi40OCIgeTE9IjkzNS43MiIgeDI9IjkyNy4yOCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9Ijk1OS42OCIgeTE9IjkzNS43MiIgeDI9IjEwMjQuNDgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxMDU2Ljg4IiB5MT0iOTM1LjcyIiB4Mj0iMTEyMS42OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjExNTQuMDgiIHkxPSI5MzUuNzIiIHgyPSIxMjE4Ljg4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTI1MS4yOCIgeTE9IjkzNS43MiIgeDI9IjEzMTYuMDgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxMzQ4LjQ4IiB5MT0iOTM1LjcyIiB4Mj0iMTQxMy4yOCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE0NDUuNjgiIHkxPSI5MzUuNzIiIHgyPSIxNTEwLjQ4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTU0Mi44OCIgeTE9IjkzNS43MiIgeDI9IjE2MDcuNjgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxNjQwLjA4IiB5MT0iOTM1LjcyIiB4Mj0iMTcwNC44OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE3MzcuMjgiIHkxPSI5MzUuNzIiIHgyPSIxODAyLjA4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTgzNC40OCIgeTE9IjkzNS43MiIgeDI9IjE4OTkuMjgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxOTMxLjY4IiB5MT0iOTM1LjcyIiB4Mj0iMTk5Ni40OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjIwMjguODgiIHkxPSI5MzUuNzIiIHgyPSIyMDkzLjY4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjEyNi4wOCIgeTE9IjkzNS43MiIgeDI9IjIxOTAuODgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyMjIzLjI4IiB5MT0iOTM1LjcyIiB4Mj0iMjI4OC4wOCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjIzMjAuNDgiIHkxPSI5MzUuNzIiIHgyPSIyMzg1LjI4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjQxNy42OCIgeTE9IjkzNS43MiIgeDI9IjI0ODIuNDgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyNTE0Ljg4IiB5MT0iOTM1LjcyIiB4Mj0iMjU3OS42OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI2MTIuMDgiIHkxPSI5MzUuNzIiIHgyPSIyNjc2Ljg4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjcwOS4yOCIgeTE9IjkzNS43MiIgeDI9IjI3NzQuMDgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyODA2LjQ4IiB5MT0iOTM1LjcyIiB4Mj0iMjg3MS4yOCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI5MDMuNjgiIHkxPSI5MzUuNzIiIHgyPSIyOTY4LjQ4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzAwMC44OCIgeTE9IjkzNS43MiIgeDI9IjMwNjUuNjgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMDk4LjA4IiB5MT0iOTM1LjcyIiB4Mj0iMzE2Mi44OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjMxOTUuMjgiIHkxPSI5MzUuNzIiIHgyPSIzMjYwLjA4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzI5Mi40OCIgeTE9IjkzNS43MiIgeDI9IjMzNTcuMjgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMzg5LjY4IiB5MT0iOTM1LjcyIiB4Mj0iMzQ1NC40OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM0ODYuODgiIHkxPSI5MzUuNzIiIHgyPSIzNTUxLjY4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzU4NC4wOCIgeTE9IjkzNS43MiIgeDI9IjM2NDguODgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzNjgxLjI4IiB5MT0iOTM1LjcyIiB4Mj0iMzc0Ni4wOCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM3NzguNDgiIHkxPSI5MzUuNzIiIHgyPSIzODQzLjI4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzg3NS42OCIgeTE9IjkzNS43MiIgeDI9IjM5NDAuNDgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzOTcyLjg4IiB5MT0iOTM1LjcyIiB4Mj0iNDAzNy42OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQwNzAuMDgiIHkxPSI5MzUuNzIiIHgyPSI0MTM0Ljg4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDE2Ny4yOCIgeTE9IjkzNS43MiIgeDI9IjQyMzIuMDgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0MjY0LjQ4IiB5MT0iOTM1LjcyIiB4Mj0iNDMyOS4yOCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQzNjEuNjgiIHkxPSI5MzUuNzIiIHgyPSI0NDI2LjQ4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDQ1OC44OCIgeTE9IjkzNS43MiIgeDI9IjQ1MjMuNjgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0NTU2LjA4IiB5MT0iOTM1LjcyIiB4Mj0iNDYyMC44OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ2NTMuMjgiIHkxPSI5MzUuNzIiIHgyPSI0NzE4LjA4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDc1MC40OCIgeTE9IjkzNS43MiIgeDI9IjQ4MTUuMjgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0ODQ3LjY4IiB5MT0iOTM1LjcyIiB4Mj0iNDkxMi40OCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ5NDQuODgiIHkxPSI5MzUuNzIiIHgyPSI1MDA5LjY4IiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNTA0Mi4wOCIgeTE9IjkzNS43MiIgeDI9IjUxMDYuODgiIHkyPSI5MzUuNzIiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI1MTM5LjI4IiB5MT0iOTM1LjcyIiB4Mj0iNTIwNC4wOCIgeTI9IjkzNS43MiIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjUyMzYuNDgiIHkxPSI5MzUuNzIiIHgyPSI1Mjg2LjYwIiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNTcwLjg4IiB5MT0iMzQ3LjI5IiB4Mj0iNjM1LjY4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNjY4LjA4IiB5MT0iMzQ3LjI5IiB4Mj0iNzMyLjg4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNzY1LjI4IiB5MT0iMzQ3LjI5IiB4Mj0iODMwLjA4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iODYyLjQ4IiB5MT0iMzQ3LjI5IiB4Mj0iOTI3LjI4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iOTU5LjY4IiB5MT0iMzQ3LjI5IiB4Mj0iMTAyNC40OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjEwNTYuODgiIHkxPSIzNDcuMjkiIHgyPSIxMTIxLjY4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTE1NC4wOCIgeTE9IjM0Ny4yOSIgeDI9IjEyMTguODgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxMjUxLjI4IiB5MT0iMzQ3LjI5IiB4Mj0iMTMxNi4wOCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjEzNDguNDgiIHkxPSIzNDcuMjkiIHgyPSIxNDEzLjI4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTQ0NS42OCIgeTE9IjM0Ny4yOSIgeDI9IjE1MTAuNDgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxNTQyLjg4IiB5MT0iMzQ3LjI5IiB4Mj0iMTYwNy42OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE2NDAuMDgiIHkxPSIzNDcuMjkiIHgyPSIxNzA0Ljg4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMTczNy4yOCIgeTE9IjM0Ny4yOSIgeDI9IjE4MDIuMDgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIxODM0LjQ4IiB5MT0iMzQ3LjI5IiB4Mj0iMTg5OS4yOCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjE5MzEuNjgiIHkxPSIzNDcuMjkiIHgyPSIxOTk2LjQ4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjAyOC44OCIgeTE9IjM0Ny4yOSIgeDI9IjIwOTMuNjgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyMTI2LjA4IiB5MT0iMzQ3LjI5IiB4Mj0iMjE5MC44OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjIyMjMuMjgiIHkxPSIzNDcuMjkiIHgyPSIyMjg4LjA4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjMyMC40OCIgeTE9IjM0Ny4yOSIgeDI9IjIzODUuMjgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyNDE3LjY4IiB5MT0iMzQ3LjI5IiB4Mj0iMjQ4Mi40OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI1MTQuODgiIHkxPSIzNDcuMjkiIHgyPSIyNTc5LjY4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjYxMi4wOCIgeTE9IjM0Ny4yOSIgeDI9IjI2NzYuODgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIyNzA5LjI4IiB5MT0iMzQ3LjI5IiB4Mj0iMjc3NC4wOCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjI4MDYuNDgiIHkxPSIzNDcuMjkiIHgyPSIyODcxLjI4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMjkwMy42OCIgeTE9IjM0Ny4yOSIgeDI9IjI5NjguNDgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMDAwLjg4IiB5MT0iMzQ3LjI5IiB4Mj0iMzA2NS42OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjMwOTguMDgiIHkxPSIzNDcuMjkiIHgyPSIzMTYyLjg4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzE5NS4yOCIgeTE9IjM0Ny4yOSIgeDI9IjMyNjAuMDgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzMjkyLjQ4IiB5MT0iMzQ3LjI5IiB4Mj0iMzM1Ny4yOCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjMzODkuNjgiIHkxPSIzNDcuMjkiIHgyPSIzNDU0LjQ4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzQ4Ni44OCIgeTE9IjM0Ny4yOSIgeDI9IjM1NTEuNjgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzNTg0LjA4IiB5MT0iMzQ3LjI5IiB4Mj0iMzY0OC44OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM2ODEuMjgiIHkxPSIzNDcuMjkiIHgyPSIzNzQ2LjA4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iMzc3OC40OCIgeTE9IjM0Ny4yOSIgeDI9IjM4NDMuMjgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSIzODc1LjY4IiB5MT0iMzQ3LjI5IiB4Mj0iMzk0MC40OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjM5NzIuODgiIHkxPSIzNDcuMjkiIHgyPSI0MDM3LjY4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDA3MC4wOCIgeTE9IjM0Ny4yOSIgeDI9IjQxMzQuODgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0MTY3LjI4IiB5MT0iMzQ3LjI5IiB4Mj0iNDIzMi4wOCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQyNjQuNDgiIHkxPSIzNDcuMjkiIHgyPSI0MzI5LjI4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDM2MS42OCIgeTE9IjM0Ny4yOSIgeDI9IjQ0MjYuNDgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0NDU4Ljg4IiB5MT0iMzQ3LjI5IiB4Mj0iNDUyMy42OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ1NTYuMDgiIHkxPSIzNDcuMjkiIHgyPSI0NjIwLjg4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDY1My4yOCIgeTE9IjM0Ny4yOSIgeDI9IjQ3MTguMDgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI0NzUwLjQ4IiB5MT0iMzQ3LjI5IiB4Mj0iNDgxNS4yOCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjQ4NDcuNjgiIHkxPSIzNDcuMjkiIHgyPSI0OTEyLjQ4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNDk0NC44OCIgeTE9IjM0Ny4yOSIgeDI9IjUwMDkuNjgiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxsaW5lIHgxPSI1MDQyLjA4IiB5MT0iMzQ3LjI5IiB4Mj0iNTEwNi44OCIgeTI9IjM0Ny4yOSIgc3R5bGU9InN0cm9rZTojRTBFMEUwO3N0cm9rZS13aWR0aDo0Ljg2Ii8+DQoJPGxpbmUgeDE9IjUxMzkuMjgiIHkxPSIzNDcuMjkiIHgyPSI1MjA0LjA4IiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiNFMEUwRTA7c3Ryb2tlLXdpZHRoOjQuODYiLz4NCgk8bGluZSB4MT0iNTIzNi40OCIgeTE9IjM0Ny4yOSIgeDI9IjUyODYuNjAiIHkyPSIzNDcuMjkiIHN0eWxlPSJzdHJva2U6I0UwRTBFMDtzdHJva2Utd2lkdGg6NC44NiIvPg0KCTxwYXRoIGQ9IiBNMjYzNS43MSAyNTkzLjg2IEwyNjEwLjkwIDI1ODguNjMgTDI1ODYuMjYgMjU4My4yMyBMMjU2MS45NiAyNTc3LjgyIEwyNTM4LjAwIDI1NzIuNDMgTDI1MTQuMjEgMjU2Ny4wMyBMMjQ5MC41OCAyNTYxLjYzIEwyNDY3LjI5IDI1NTYuMjMgTDI0NDQuMzQgMjU1MC44MiBMMjQyMS41NiAyNTQ1LjQzIEwyMzk5LjEyIDI1NDAuMDMgTDIzNzYuODQgMjUzNC42MyBMMjM1NC43NCAyNTI5LjA2IEwyMzMyLjk3IDI1MjMuNjYgTDIzMTEuNTQgMjUxOC4wOSBMMjI5MC4yOCAyNTEyLjY5IEwyMjY5LjE4IDI1MDcuMTIgTDIyNDguNDMgMjUwMS43MiBMMjIyNy44NCAyNDk2LjE1IEwyMjA3LjQyIDI0OTAuNTggTDIxODcuMzQgMjQ4NS4wMSBMMjE2Ny40MyAyNDc5LjQ0IEwyMTQ3LjY4IDI0NzMuODggTDIxMjguMjggMjQ2OC4zMSBMMjEwOS4wNCAyNDYyLjc0IEwyMDkwLjE0IDI0NTcuMTcgTDIwNzEuMjQgMjQ1MS42MCBMMjA1Mi42OCAyNDQ1Ljg2IEwyMDM0LjQ1IDI0NDAuMjkgTDIwMTYuMjMgMjQzNC41NiBMMTk5OC4zNCAyNDI4Ljk5IEwxOTgwLjYyIDI0MjMuMjUgTDE5NjMuMDcgMjQxNy42OCBMMTk0NS42OSAyNDExLjk0IEwxOTI4LjY0IDI0MDYuMjEgTDE5MTEuNjAgMjQwMC40NyBMMTg5NC44OSAyMzk0LjczIEwxODc4LjM2IDIzODguOTkgTDE4NjEuOTkgMjM4My4yNiBMMTg0NS45NiAyMzc3LjUyIEwxODI5LjkzIDIzNzEuNzggTDE4MTQuMjMgMjM2Ni4wNCBMMTc5OC41NCAyMzYwLjE0IEwxNzgzLjE4IDIzNTQuNDAgTDE3NjcuOTkgMjM0OC42NiBMMTc1Mi45OCAyMzQyLjc2IEwxNzM4LjEzIDIzMzcuMDIgTDE3MjMuNDQgMjMzMS4xMSBMMTcwOC45MyAyMzI1LjIxIEwxNjk0LjU5IDIzMTkuMzAgTDE2ODAuNDEgMjMxMy41NiBMMTY2Ni40MSAyMzA3LjY2IEwxNjUyLjU3IDIzMDEuNzUgTDE2MzguOTAgMjI5NS44NCBMMTYyNS40MCAyMjg5Ljk0IEwxNjEyLjA3IDIyODMuODYgTDE1OTguOTEgMjI3Ny45NiBMMTU4NS45MSAyMjcyLjA1IEwxNTcyLjkyIDIyNjYuMTQgTDE1NjAuMjYgMjI2MC4wNyBMMTU0Ny43OCAyMjU0LjE2IEwxNTM1LjI5IDIyNDguMDkgTDE1MjMuMTQgMjI0Mi4wMSBMMTUxMC45OSAyMjM2LjExIEwxNDk5LjAxIDIyMzAuMDMgTDE0ODcuMTkgMjIyMy45NiBMMTQ3NS41NSAyMjE3Ljg4IEwxNDY0LjA4IDIyMTEuODEgTDE0NTIuNzcgMjIwNS43MyBMMTQ0MS40NiAyMTk5LjY2IEwxNDMwLjQ5IDIxOTMuNTggTDE0MTkuNTMgMjE4Ny41MSBMMTQwOC43MyAyMTgxLjQzIEwxMzk3LjkzIDIxNzUuMTkgTDEzODcuNDYgMjE2OS4xMSBMMTM3Ny4wMCAyMTYyLjg3IEwxMzY2LjcxIDIxNTYuNzkgTDEzNTYuNTggMjE1MC41NSBMMTM0Ni42MyAyMTQ0LjQ4IEwxMzM2LjY3IDIxMzguMjMgTDEzMjYuODggMjEzMS45OSBMMTMxNy4yNiAyMTI1Ljc0IEwxMzA3LjY0IDIxMTkuNTAgTDEyOTguMzYgMjExMy4yNiBMMTI4OC45MSAyMTA3LjAxIEwxMjc5LjgwIDIxMDAuNzcgTDEyNzAuNjkgMjA5NC41MyBMMTI2MS45MSAyMDg4LjI4IEwxMjUyLjk3IDIwODEuODcgTDEyNDQuMzYgMjA3NS42MyBMMTIzNS43NiAyMDY5LjIxIEwxMjI3LjE1IDIwNjIuOTcgTDEyMTguODggMjA1Ni41NiBMMTIxMC42MSAyMDUwLjMxIEwxMjAyLjM0IDIwNDMuOTAgTDExOTQuNDEgMjAzNy40OSBMMTE4Ni4zMSAyMDMxLjA4IEwxMTc4LjU1IDIwMjQuNjYgTDExNzAuNzkgMjAxOC4yNSBMMTE2My4xOSAyMDExLjg0IEwxMTU1LjYwIDIwMDUuNDMgTDExNDguMTggMTk5OS4wMSBMMTE0MC43NSAxOTkyLjYwIEwxMTMzLjQ5IDE5ODYuMTkgTDExMjYuNDEgMTk3OS42MSBMMTExOS4zMiAxOTczLjE5IEwxMTEyLjQwIDE5NjYuNjEgTDExMDUuNDggMTk2MC4yMCBMMTA5OC43MyAxOTUzLjYyIEwxMDkxLjk4IDE5NDcuMDQgTDEwODUuNDAgMTk0MC42MyBMMTA3OC44MiAxOTM0LjA0IEwxMDcyLjQxIDE5MjcuNDYgTDEwNjUuOTkgMTkyMC44OCBMMTA1OS43NSAxOTE0LjMwIEwxMDUzLjY4IDE5MDcuNzIgTDEwNDcuNjAgMTkwMS4xNCBMMTA0MS41MyAxODk0LjM5IEwxMDM1LjYyIDE4ODcuODEgTDEwMjkuNzEgMTg4MS4yMyBMMTAyMy45OCAxODc0LjQ4IEwxMDE4LjI0IDE4NjcuODkgTDEwMTIuNjcgMTg2MS4xNCBMMTAwNy4xMCAxODU0LjU2IEwxMDAxLjcwIDE4NDcuODEgTDk5Ni4zMCAxODQxLjA2IEw5OTAuOTAgMTgzNC4zMSBMOTg1LjY3IDE4MjcuNTYgTDk4MC40NCAxODIwLjk4IEw5NzUuMzggMTgxNC4wNiBMOTcwLjMxIDE4MDcuMzEgTDk2NS40MiAxODAwLjU2IEw5NjAuNTMgMTc5My44MSBMOTU1LjYzIDE3ODcuMDYgTDk1MC45MSAxNzgwLjE0IEw5NDYuMTggMTc3My4zOSBMOTQxLjYzIDE3NjYuNjQgTDkzNy4wNyAxNzU5LjczIEw5MzIuNTEgMTc1Mi44MSBMOTI4LjEzIDE3NDYuMDYgTDkyMy43NCAxNzM5LjE0IEw5MTkuMzUgMTczMi4yMiBMOTE1LjEzIDE3MjUuMzAgTDkxMC45MSAxNzE4LjM4IEw5MDYuNjkgMTcxMS40NiBMOTAyLjY0IDE3MDQuNTQgTDg5OC41OSAxNjk3LjYzIEw4OTQuNzEgMTY5MC43MSBMODkwLjgzIDE2ODMuNzkgTDg4Ni45NSAxNjc2Ljg3IEw4ODMuMDcgMTY2OS43OCBMODc5LjM2IDE2NjIuODYgTDg3NS42NCAxNjU1Ljc4IEw4NzIuMTAgMTY0OC44NiBMODY4LjU2IDE2NDEuNzcgTDg2NS4wMSAxNjM0LjY4IEw4NjEuNDcgMTYyNy41OSBMODU4LjA5IDE2MjAuNjggTDg1NC41NSAxNjEzLjU5IEw4NTEuMzQgMTYwNi41MCBMODQ3Ljk3IDE1OTkuNDEgTDg0NC43NiAxNTkyLjMzIEw4NDEuNTYgMTU4NS4wNyBMODM4LjM1IDE1NzcuOTggTDgzNS4zMSAxNTcwLjg5IEw4MzIuMjggMTU2My42NCBMODI5LjI0IDE1NTYuNTUgTDgyNi4yMCAxNTQ5LjQ2IEw4MjMuMzMgMTU0Mi4yMSBMODIwLjQ2IDE1MzQuOTUgTDgxNy41OSAxNTI3Ljg2IEw4MTQuODkgMTUyMC42MSBMODEyLjAzIDE1MTMuMzUgTDgwOS4zMyAxNTA2LjA5IEw4MDYuNjMgMTQ5OC44NCBMODA0LjA5IDE0OTEuNTggTDgwMS4zOSAxNDg0LjMzIEw3OTguODYgMTQ3Ny4wNyBMNzk2LjMzIDE0NjkuODEgTDc5My44MCAxNDYyLjM5IEw3OTEuNDQgMTQ1NS4xMyBMNzg4LjkxIDE0NDcuODggTDc4Ni41NCAxNDQwLjQ1IEw3ODQuMTggMTQzMy4xOSBMNzgxLjk5IDE0MjUuNzcgTDc3OS42MyAxNDE4LjM0IEw3NzcuNDMgMTQxMS4wOSBMNzc1LjI0IDE0MDMuNjYgTDc3My4wNCAxMzk2LjI0IEw3NzAuODUgMTM4OC44MSBMNzY4LjgzIDEzODEuMzkgTDc2Ni44MCAxMzczLjk2IEw3NjQuNzggMTM2Ni41NCBMNzYyLjc1IDEzNTguOTQgTDc2MC43MyAxMzUxLjUyIEw3NTguNzAgMTM0NC4wOSBMNzU2Ljg0IDEzMzYuNTAgTDc1NC45OSAxMzI5LjA4IEw3NTMuMTMgMTMyMS40OCBMNzUxLjI4IDEzMTQuMDYgTDc0OS40MiAxMzA2LjQ2IEw3NDcuNzMgMTI5OC44NyBMNzQ1Ljg4IDEyOTEuNDQgTDc0NC4xOSAxMjgzLjg1IEw3NDIuNTAgMTI3Ni4yNiBMNzQwLjgxIDEyNjguNjYgTDczOS4xMyAxMjYxLjA3IEw3MzcuNjEgMTI1My40NyBMNzM1LjkyIDEyNDUuODggTDczNC40MCAxMjM4LjEyIEw3MzIuODggMTIzMC41MyBMNzMxLjM2IDEyMjIuOTMgTDcyOS44NCAxMjE1LjE3IEw3MjguMzMgMTIwNy41OCBMNzI2LjgxIDExOTkuODEgTDcyNS40NiAxMTkyLjA1IEw3MjQuMTEgMTE4NC40NiBMNzIyLjU5IDExNzYuNjkgTDcyMS4yNCAxMTY4LjkzIEw3MTkuODkgMTE2MS4xNyBMNzE4LjU0IDExNTMuNDEgTDcxNy4zNiAxMTQ1LjY0IEw3MTYuMDEgMTEzNy44OCBMNzE0LjgzIDExMzAuMTIgTDcxMy40OCAxMTIyLjM2IEw3MTIuMjkgMTExNC40MyBMNzExLjExIDExMDYuNjYgTDcwOS45MyAxMDk4LjkwIEw3MDguNzUgMTA5MC45NyBMNzA3LjU3IDEwODMuMjEgTDcwNi41NiAxMDc1LjI4IEw3MDUuMzggMTA2Ny4zNCBMNzA0LjM2IDEwNTkuNDEgTDcwMy4xOCAxMDUxLjY1IEw3MDIuMTcgMTA0My43MiBMNzAxLjE2IDEwMzUuNzkgTDcwMC4xNCAxMDI3Ljg2IEw2OTkuMTMgMTAxOS45MyBMNjk4LjEyIDEwMTEuODIgTDY5Ny4xMSAxMDAzLjg5IEw2OTYuMDkgOTk1Ljk2IEw2OTUuMjUgOTg4LjAzIEw2OTQuMjQgOTc5LjkzIEw2OTMuMzkgOTcyLjAwIEw2OTIuNTUgOTYzLjkwIEw2OTEuNTQgOTU1Ljk3IEw2OTAuNjkgOTQ3Ljg3IEw2ODkuODUgOTM5Ljc3IEw2ODkuMDEgOTMxLjY3IEw2ODguMTYgOTIzLjc0IEw2ODcuMzIgOTE1LjY0IEw2ODYuNjQgOTA3LjU0IEw2ODUuODAgODk5LjI3IEw2ODUuMTMgODkxLjE3IEw2ODQuMjggODgzLjA3IEw2ODMuNjEgODc0Ljk3IEw2ODIuNzYgODY2Ljg3IEw2ODIuMDkgODU4LjYwIEw2ODEuNDEgODUwLjUwIEw2ODAuNzQgODQyLjIzIEw2NzkuODkgODM0LjEzIEw2NzkuMjIgODI1Ljg2IEw2NzguNzEgODE3LjU5IEw2NzguMDQgODA5LjMyIEw2NzcuMzYgODAxLjIyIEw2NzYuNjkgNzkyLjk2IEw2NzYuMDEgNzg0LjY5IEw2NzUuNTEgNzc2LjQyIEw2NzQuODMgNzY3Ljk4IEw2NzQuMzMgNzU5LjcxIEw2NzMuNjUgNzUxLjQ0IEw2NzMuMTQgNzQzLjE4IEw2NzIuNjQgNzM0Ljc0IEw2NzEuOTYgNzI2LjQ3IEw2NzEuNDYgNzE4LjAzIEw2NzAuOTUgNzA5Ljc2IEw2NzAuNDQgNzAxLjMyIEw2NjkuOTQgNjkyLjg5IEw2NjkuNDMgNjg0LjYyIEw2NjguOTMgNjc2LjE4IEw2NjguNDIgNjY3Ljc0IEw2NjcuOTEgNjU5LjMxIEw2NjcuNDEgNjUwLjg3IEw2NjYuOTAgNjQyLjQzIEw2NjYuNTYgNjMzLjk5IEw2NjYuMDYgNjI1LjM5IEw2NjUuNzIgNjE2Ljk1IEw2NjUuMjEgNjA4LjUxIEw2NjQuNzEgNTk5LjkxIEw2NjQuMzcgNTkxLjQ3IEw2NjMuODYgNTgyLjg2IEw2NjMuNTMgNTc0LjQzIEw2NjMuMTkgNTY1LjgyIEw2NjIuNjggNTU3LjIxIEw2NjIuMzQgNTQ4LjYxIEw2NjIuMDEgNTQwLjE3IEw2NjEuNjcgNTMxLjU2IEw2NjEuMzMgNTIyLjk2IEw2NjAuODMgNTE0LjM1IEw2NjAuNDkgNTA1LjU3IEw2NjAuMTUgNDk2Ljk3IEw2NTkuODEgNDg4LjM2IEw2NTkuNDggNDc5Ljc2IEw2NTkuMTQgNDcwLjk4IEw2NTguODAgNDYyLjM4IEw2NTguNjMgNDUzLjYwIEw2NTguMjkgNDQ0LjgyIEw2NTcuOTYgNDM2LjIyIEw2NTcuNjIgNDI3LjQ0IEw2NTcuMjggNDE4LjY3IEw2NTcuMTEgNDA5Ljg5IEw2NTYuNzggNDAxLjEyIEw2NTYuNDQgMzkyLjM0IEw2NTYuMjcgMzgzLjU3IEw2NTUuOTMgMzc0Ljc5IEw2NTUuNzYgMzY2LjAyIEw2NTUuNDMgMzU3LjI0IEw2NTUuMjYgMzQ4LjMwIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDA3MkIyO3N0cm9rZS13aWR0aDoxNC41OCIvPg0KCTxwb2x5Z29uIHBvaW50cz0iNjg5LjUxLDg3My41MiA2MzUuNjQsOTY2LjgyIDc0My4zOCw5NjYuODIiIHN0eWxlPSJmaWxsOiNENTVFMDAiLz4NCgk8cG9seWdvbiBwb2ludHM9IjY4OS41MSw4ODMuMjQgNjQ0LjA2LDk2MS45NiA3MzQuOTYsOTYxLjk2IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwMDAwO3N0cm9rZS13aWR0aDo5LjcyIi8+DQoJPGxpbmUgeDE9IjU3MC44OCIgeTE9IjI1OTcuOTEiIHgyPSI1MjUuODMiIHkyPSIyNTk3LjkxIiBzdHlsZT0ic3Ryb2tlOiMwMDAwMDA7c3Ryb2tlLXdpZHRoOjYuNDgiLz4NCgk8dGV4dCB4PSI1MDMuMzgiIHk9IjI2MjkuNDMiIHN0eWxlPSJmb250LWZhbWlseTonSGVsdmV0aWNhJztmb250LXNpemU6ODkuOTRweDtmaWxsOiMwMDAwMDAiIHRleHQtYW5jaG9yPSJlbmQiPjEvMTA8L3RleHQ+DQoJPGxpbmUgeDE9IjU3MC44OCIgeTE9IjIwMDkuNDgiIHgyPSI1MjUuODMiIHkyPSIyMDA5LjQ4IiBzdHlsZT0ic3Ryb2tlOiMwMDAwMDA7c3Ryb2tlLXdpZHRoOjYuNDgiLz4NCgk8dGV4dCB4PSI1MDMuMzgiIHk9IjIwNDEuMDAiIHN0eWxlPSJmb250LWZhbWlseTonSGVsdmV0aWNhJztmb250LXNpemU6ODkuOTRweDtmaWxsOiMwMDAwMDAiIHRleHQtYW5jaG9yPSJlbmQiPjEvMzwvdGV4dD4NCgk8bGluZSB4MT0iNTcwLjg4IiB5MT0iMTQ3Mi42OCIgeDI9IjUyNS44MyIgeTI9IjE0NzIuNjgiIHN0eWxlPSJzdHJva2U6IzAwMDAwMDtzdHJva2Utd2lkdGg6Ni40OCIvPg0KCTx0ZXh0IHg9IjUwMy4zOCIgeT0iMTUwNC4yMCIgc3R5bGU9ImZvbnQtZmFtaWx5OidIZWx2ZXRpY2EnO2ZvbnQtc2l6ZTo4OS45NHB4O2ZpbGw6IzAwMDAwMCIgdGV4dC1hbmNob3I9ImVuZCI+MTwvdGV4dD4NCgk8bGluZSB4MT0iNTcwLjg4IiB5MT0iOTM1LjcyIiB4Mj0iNTI1LjgzIiB5Mj0iOTM1LjcyIiBzdHlsZT0ic3Ryb2tlOiMwMDAwMDA7c3Ryb2tlLXdpZHRoOjYuNDgiLz4NCgk8dGV4dCB4PSI1MDMuMzgiIHk9Ijk2Ny4yNCIgc3R5bGU9ImZvbnQtZmFtaWx5OidIZWx2ZXRpY2EnO2ZvbnQtc2l6ZTo4OS45NHB4O2ZpbGw6IzAwMDAwMCIgdGV4dC1hbmNob3I9ImVuZCI+MzwvdGV4dD4NCgk8bGluZSB4MT0iNTcwLjg4IiB5MT0iMzQ3LjI5IiB4Mj0iNTI1LjgzIiB5Mj0iMzQ3LjI5IiBzdHlsZT0ic3Ryb2tlOiMwMDAwMDA7c3Ryb2tlLXdpZHRoOjYuNDgiLz4NCgk8dGV4dCB4PSI1MDMuMzgiIHk9IjM3OC44MSIgc3R5bGU9ImZvbnQtZmFtaWx5OidIZWx2ZXRpY2EnO2ZvbnQtc2l6ZTo4OS45NHB4O2ZpbGw6IzAwMDAwMCIgdGV4dC1hbmNob3I9ImVuZCI+MTA8L3RleHQ+DQoJPHRleHQgeD0iMjE0LjU1IiB5PSIxNDcyLjY4IiBzdHlsZT0iZm9udC1mYW1pbHk6J0hlbHZldGljYSc7Zm9udC1zaXplOjExMi41NnB4O2ZpbGw6IzAwMDAwMCIgdHJhbnNmb3JtPSJyb3RhdGUoLTkwIDIxNC41NSwxNDcyLjY4KSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QmF5ZXMgZmFjdG9yPC90ZXh0Pg0KCTxsaW5lIHgxPSI2NDIuMDkiIHkxPSIyNjY5LjEyIiB4Mj0iNjQyLjA5IiB5Mj0iMjcxNC4xOCIgc3R5bGU9InN0cm9rZTojMDAwMDAwO3N0cm9rZS13aWR0aDo2LjQ4Ii8+DQoJPHRleHQgeD0iNjczLjYyIiB5PSIyNzM2LjYyIiBzdHlsZT0iZm9udC1mYW1pbHk6J0hlbHZldGljYSc7Zm9udC1zaXplOjg5Ljk0cHg7ZmlsbDojMDAwMDAwIiB0cmFuc2Zvcm09InJvdGF0ZSgtOTAgNjczLjYyLDI3MzYuNjIpIiB0ZXh0LWFuY2hvcj0iZW5kIj4wPC90ZXh0Pg0KCTxsaW5lIHgxPSI1MjE1LjM5IiB5MT0iMjY2OS4xMiIgeDI9IjUyMTUuMzkiIHkyPSIyNzE0LjE4IiBzdHlsZT0ic3Ryb2tlOiMwMDAwMDA7c3Ryb2tlLXdpZHRoOjYuNDgiLz4NCgk8dGV4dCB4PSI1MjQ2LjkxIiB5PSIyNzM2LjYyIiBzdHlsZT0iZm9udC1mYW1pbHk6J0hlbHZldGljYSc7Zm9udC1zaXplOjg5Ljk0cHg7ZmlsbDojMDAwMDAwIiB0cmFuc2Zvcm09InJvdGF0ZSgtOTAgNTI0Ni45MSwyNzM2LjYyKSIgdGV4dC1hbmNob3I9ImVuZCI+MC4wNTwvdGV4dD4NCgk8dGV4dCB4PSIyOTI4LjY2IiB5PSIzMDcwLjMxIiBzdHlsZT0iZmlsbDojMDAwMDAwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj4NCgkJPHRzcGFuIHN0eWxlPSJmb250LWZhbWlseTonSGVsdmV0aWNhJztmb250LXN0eWxlOml0YWxpYztmb250LXNpemU6MTEyLjU2cHgiPnA8L3RzcGFuPg0KCQk8dHNwYW4gc3R5bGU9ImZvbnQtZmFtaWx5OidIZWx2ZXRpY2EnO2ZvbnQtc2l6ZToxMTIuNTZweCI+LXZhbHVlPC90c3Bhbj4NCgk8L3RleHQ+DQoJPHRleHQgeD0iMjkyOC42NiIgeT0iMjE5LjQ4IiBzdHlsZT0iZm9udC1mYW1pbHk6J0hlbHZldGljYSc7Zm9udC1zaXplOjEyMy42OXB4O2ZpbGw6IzAwMDAwMCIgdGV4dC1hbmNob3I9Im1pZGRsZSI+U2FtcGxlIHNpemU6IDE4LDk2NDwvdGV4dD4NCjwvc3ZnPg0K)

plot of chunk unnamed-chunk-12

## References

Cohen, J. (1988). *Statistical power analysis for the behavioral
sciences* (2nd ed.). Lawrence Erlbaum.

Klauer, K. C., Meyer-Grant, C. G., & Kellen, D. (2025). On Bayes factors
for hypothesis tests. *Psychonomic Bulletin & Review*, 32, 1070–1094.
<https://doi.org/10.3758/s13423-024-02612-2>

Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on
sample size: A Bayesian-frequentist compromise for significance testing.
*Strategic Organization*, 22(3), 550–581.
<https://doi.org/10.1177/14761270231214429>
