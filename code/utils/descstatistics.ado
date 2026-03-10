cap program drop descstatistics
program define descstatistics
syntax varlist,[DECimals(integer 3)] SAVing(string asis) [weight(varname) sort]

if !mi("`sort'"){
	preserve
	keep `varlist'
	des,clear replace
	loc N=_N
	so varlab
	loc varlist
	forv i=1/`N'{
		loc t0=name in `i'
		loc varlist `varlist' `t0'
	}	
	restore
}


tempvar ifweight
if "`weight'"=="" g `ifweight'=1
else g `ifweight'=`weight'
tempfile t0 t1
qui sa "`t0'",replace
clear
foreach v in `varlist' {
	preserve
	qui u "`t0'",replace
	loc vlab "`: var label `v''"
	egen obs=count(`v')
	collapse (mean) obs mean=`v' (p50) median=`v' (sd) sd=`v' (min) min=`v' (max) max=`v' [iw=`ifweight']
	g var="`vlab'"
	qui sa "`t1'",replace
	restore
	qui append using "`t1'"
}
foreach v of varlist obs mean median sd min max {
	ren `v' t0
	g `v'=string(t0,"%20.`decimals'fc")
	drop t0
}
qui replace obs=regexs(1) if regexm(obs,"(.*)\.")
egen latex=concat(var obs mean median sd min max),p(" & ")
di `"file open myfile using "`saving'",write text replace"'
file open myfile using `saving',write text replace
loc N=_N
forv i=1/`N'{
loc t0=latex in `i'
	file write myfile "`t0' \\" _n
}
file close myfile
end