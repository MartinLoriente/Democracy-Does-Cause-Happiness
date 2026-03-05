cap program drop ivreghdfestd
program define ivreghdfestd
syntax [anything(name=0)] [if] [in] [aw fw pw iw/],Absorb(varlist) [Cluster(varlist) *]
loc varlist `0'
*Identify variables
if regexm("`varlist'","(.*)\((.*)=(.*)\)") loc y=regexs(1)
if regexm("`varlist'","(.*)\((.*)=(.*)\)") loc x=regexs(2)
if regexm("`varlist'","(.*)\((.*)=(.*)\)") loc z=regexs(3)

tempvar touse t0
if !mi("`weight'") loc weights "[`weight'=`exp']"
else loc weights ""

qui marktouse `touse' `y' `x' `z' `exp' `absorb' `cluster' `if' `in'
foreach v of varlist `y' `x' `z'{
	tempvar `v'nostd
	ren `v' ``v'nostd'
	qui su ``v'nostd' `weights' if `touse'
	qui g `v'=(``v'nostd'-`r(mean)')/`r(sd)' if `touse'
	la var `v' "`: var label ``v'nostd''"
}
ivreghdfe `varlist' `weights' if `touse',a(`absorb') cl(`cluster') `noconstant' `options'
foreach v of varlist `y' `x' `z'{
	drop `v'
	ren ``v'nostd' `v' 
}

end
