* The figure on the home page. Copied to pkgdown/assets, which pkgdown serves
* from the root of the site and which is not part of the CRAN package.
do "_prelude.do" figures

alphan plot, bf(3) methods(jab min robust balanced es moment) log(xy) ///
    xsize(7.2) ysize(4.2) title("")
quietly graph export "../../pkgdown/assets/home-alpha.svg", replace

log close pc
exit, clear
