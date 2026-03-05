cap program drop reghdfestd
program define reghdfestd
syntax varlist [if] [in] [fw aw pw/],Absorb(varlist) [Cluster(varlist) *]


tempvar touse
if !mi("`weight'") loc weights "[`weight'=`exp']"
else loc weights ""
qui marktouse `touse' `varlist' `exp' `absorb' `cluster' `if' `in'
foreach v of varlist `varlist'{
	tempvar `v'nostd
	ren `v' ``v'nostd'
	qui su ``v'nostd' `weights' if `touse'
	qui g `v'=(``v'nostd'-`r(mean)')/`r(sd)' if `touse'
	la var `v' "`: var label ``v'nostd''"
}
preserve
keep if `touse'
reghdfe `varlist' `weights',a(`absorb') cl(`cluster') `noconstant' `options'
restore
foreach v of varlist `varlist'{
	drop `v'
	ren ``v'nostd' `v' 
}
drop `touse'
end

