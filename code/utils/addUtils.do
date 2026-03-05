/*==============================================================================
*ADD UTILS
A. ADD UTILS
A1. makedirs
A2. balancecountry and replacevaluescountry
A3. nostars
*=============================================================================*/
*Install packages
*net install parallel, from(https://raw.github.com/gvegayon/parallel/stable/) replace
*mata mata mlib index

/*==============================================================================
*A1. makedirs
*=============================================================================*/

capture program drop makedirs
program define makedirs
syntax,dirs(string) [base(string)]
if mi("`base'") loc base .
foreach b in `base' {
	foreach d in `dirs'{
		cap confirm f "`b'/`d'"
		if _rc!=0 capture mkdir "`b'/`d'"
	}
}
end

/*==============================================================================
*A2. balancecountry and replacevaluescountry
*=============================================================================*/
*balancecountry: It fills the observations when a country does not appear in some periods (e.g. Germany during dissolution)
cap program drop balancecountry
program define balancecountry
syntax,country(string) MINyear(integer) MAXyear(integer)
qui count if country==`"`country'"'
if `r(N)'==0 {
	di as input "Note that `country' is not available in raw data"
}
tempfile temp
preserve
qui keep if _n==0
loc n=`maxyear'-`minyear'+1
qui set obs `n'
qui replace year=`minyear'+_n-1
qui replace country=`"`country'"'
qui sa "`temp'"
restore
qui mer 1:1 country year using "`temp'",nogen
so country year
end

*replacevaluescountry: Replace values of country for those of other country when missing information
*replacevaluescountry,country("ETHIOPIA") input("ETHIOPIA (INCL. ERIT)") minyear(1952) maxyear(1992) vars(democracy) replace the values "democracy" of "ETHIOPIA" for those of Ethiopia "ETHIOPIA (INCL. ERIT)") for the years between "1952" and "1992"
cap program drop replacevaluescountry
program define replacevaluescountry
syntax,country(string) MINyear(integer) MAXyear(integer) INPUT(string) VARS(varlist)
foreach w in country input {
	qui count if country==`"``w''"'
	if `r(N)'==0 {
		di as err "``w'' not found"
		exit 601
	}
}
foreach v of varlist `vars' {
	qui g t0=`v' if country==`"`input'"'
	qui bys year:egen t1=mean(t0)
	qui replace `v'=t1 if country==`"`country'"'&mi(`v')&inrange(year,`minyear',`maxyear')
	drop t0 t1
}
so country year
end



/*==============================================================================
*A3. nostars
*=============================================================================*/
cap program drop nostars
program define nostars
syntax,input(string) output(string) [replace]
confirm f `input'
confirm f `output'
if !mi("`replace'") {
	!rm -r "`output'"
	mkdir "`output'"
}
loc files: dir "`input'" files "*.tex"
qui foreach f of local files {
	if regexm("`f'","appSources") copy "`input'/`f'" "`output'/`f'",replace
	else {
		noi di as input "Processing file `f'"
		import delimited "`input'/`f'",clear delimiter("ñ")
		forv i=1/5{
			replace v1=subinstr(v1,"*","",.)
		}

		file open myfile using "`output'/`f'", write replace
		loc N=_N
		forv i=1/`N'{
			loc a=v1 in `i'
			file write myfile "`a'" _n
		}
		file close myfile
	}
}

end

