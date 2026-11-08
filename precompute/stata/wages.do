* Stata output for the worked example.
do "_prelude.do" wages

* >>> data
webuse nlswork, clear
global controls age ttl_exp tenure not_smsa south c_city i.race collgrad msp nev_mar union hours
* <<<

* >>> ols
regress ln_wage $controls
alphan jab
* <<<

* >>> level
alphan `=e(N)', bf(1 3 10)
* <<<

* >>> joint
test 2.race 3.race
alphan klauerbf, n(`=e(N)') fstat(`=r(F)') q(2) p(12) de(sqrt(.02))
alphan `=e(N)', bf(3) method(es) q(2) p(12) de(sqrt(.02))
* <<<

quietly regress ln_wage $controls
local se_msp = _se[msp]
local se_nev = _se[nev_mar]

* >>> cluster
regress ln_wage $controls, vce(cluster idcode)
alphan jab
* <<<

* >>> neff
alphan n_effective, n(`=e(N)') se(`se_nev') se_robust(`=_se[nev_mar]')
local ne = r(n_effective)
alphan `ne', bf(3)
alphan jab nev_mar, n(`ne')
* <<<

* >>> methods
foreach m in jab min robust balanced {
    alphan `=e(N)', bf(3) method(`m')
}
alphan `=e(N)', bf(3) method(es) de(.2) p(13)
alphan `=e(N)', bf(3) method(moment) de(.2) p(13)
* <<<

* >>> logit
logit union age ttl_exp tenure not_smsa south c_city i.race collgrad msp nev_mar
alphan jab
* <<<

* >>> power
alphan power 18964, d(.02 .05 .1) bf(3)
alphan power 18964, d(.02 .05 .1) bf(3) method(balanced)
* <<<

* >>> report
alphan report 18964, bf(3) powerat(.02 .05)
* <<<

* >>> figure
alphan jabplot 18964, bf(3)
* <<<
quietly graph export "$pc_out/wages-jabplot.svg", replace

log close pc
exit, clear
