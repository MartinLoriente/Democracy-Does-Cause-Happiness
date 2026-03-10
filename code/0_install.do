/*-------------------------------------------------------
Install all required packages
Run once before master.do
-------------------------------------------------------*/

*Clean install
cap ado uninstall _gwmean
cap ado uninstall dm79
cap ado uninstall distinct
cap ado uninstall eventdd
cap ado uninstall estout
cap ado uninstall ftools
cap ado uninstall grc1leg
cap ado uninstall grstyle
cap ado uninstall gtools
cap ado uninstall ivreg2
cap ado uninstall ivreghdfe
cap ado uninstall labutil
cap ado uninstall marktouse
cap ado uninstall matsort
cap ado uninstall moremata
cap ado uninstall outreg
cap ado uninstall parallel
cap ado uninstall personage
cap ado uninstall psmatch2
cap ado uninstall rangestat
cap ado uninstall ranktest
cap ado uninstall reghdfe
cap ado uninstall strrec
cap ado uninstall tabout
cap ado uninstall wbopendata
cap ado uninstall winsor2
cap ado uninstall sxpose
cap ado uninstall psacalc
cap ado uninstall palettes
cap ado uninstall colrspace
cap ado uninstall qreg2

*Install packages
ssc install _gwmean, replace
net install dm79, from("http://www.stata.com/stb/stb56/") replace
ssc install distinct, replace
ssc install eventdd, replace
ssc install estout, replace
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/") replace
net install grc1leg, from("http://www.stata.com/users/vwiggins/") replace
ssc install grstyle, replace
ssc install gtools, replace
ssc install ivreg2, replace
net install ivreghdfe, from("https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/") replace
ssc install labutil, replace
ssc install marktouse, replace
ssc install matsort, replace
ssc install moremata, replace
ssc install outreg, replace
net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/") replace
ssc install personage, replace
ssc install psmatch2, replace
ssc install rangestat, replace
ssc install ranktest, replace
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/") replace
ssc install strrec, replace
ssc install tabout, replace
ssc install wbopendata, replace
ssc install winsor2, replace
ssc install sxpose, replace
ssc install psacalc, replace
ssc install palettes, replace
ssc install colrspace, replace
ssc install qreg2, replace

mata mata mlib index