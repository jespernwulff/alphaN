* Stata output for "Get started in Stata" and the home page.
do "_prelude.do" getting-started

* >>> first
alphan 1000
* <<<

* >>> home
alphan 1000, bf(3)
* <<<

* >>> targets
alphan 1000, bf(1 3 10)
* <<<

* >>> grows
alphan 100 1000 10000 100000, bf(3)
* <<<

* >>> balanced
alphan 1000, bf(3) method(balanced)
* <<<

* >>> klauer
alphan 100 1000 10000, bf(3) method(es) de(.5)
alphan 100 1000 10000, bf(3) method(moment) de(.5)
* <<<

* >>> regress
sysuse auto, clear
regress price mpg weight i.foreign
alphan jab
* <<<

* >>> jab-one
alphan jab weight, method(min)
* <<<

* >>> logit
logit foreign mpg weight
alphan jab
* <<<

* >>> reported
alphan jabt 2.695, n(200)
alphan jabp .007038863, n(200) df(190)
* <<<

* >>> klauerbf
alphan klauerbf, n(80) t(2.24) de(.5)
* <<<

* >>> joint
alphan 200, bf(3) method(es) q(2) p(2) de(sqrt(.15))
* <<<

* >>> power
alphan power 1000, d(.1) bf(3)
alphan power 1000, d(.1) bf(3) method(balanced)
* <<<

* >>> report
alphan report 1000, bf(3) method(es) de(.5) p(4) powerat(.1 .5)
* <<<

* >>> stored
alphan 1000, bf(3)
display r(alpha)
* <<<

* >>> plot
alphan plot, bf(3) methods(jab min robust balanced es moment)
* <<<
quietly graph export "$pc_out/gs-plot.svg", replace

* >>> jabplot
alphan jabplot 1000, bf(3)
* <<<
quietly graph export "$pc_out/gs-jabplot.svg", replace

* >>> powerplot
alphan powerplot, d(.1 .5) bf(3) methods(jab min robust balanced es moment)
* <<<
quietly graph export "$pc_out/gs-powerplot.svg", replace

log close pc
exit, clear
