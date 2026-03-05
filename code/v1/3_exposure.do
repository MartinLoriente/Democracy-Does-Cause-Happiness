/*==============================================================================
WORK CULTURE 

This code creates exposure to democracy by country-year of survey-cohort.
Example: all argentinians born in 1980 that respond the survey in 2005 have the 
same exposure to democracy.
Exposure to democracy is simply the sum of the exposure during each year from age 6
until the moment of the survey.
Ejemplo: si soy un argentino nacido en 1970 y me encuestan en 2010, mi exposure to
democracy va a ser la cantidad de años entre 1976 (cuando tenia 6 anios) y 2010
en los que hubo democracia en Argentina.
*=============================================================================*/

/*==============================================================================
EXPOSURE 

A. ADDITIONAL DATA FOR EXPOSURE
A1. INSTRUMENT
A2. HETEROGENEOUS EFFECTS: MAIN 
A3. CREATE PROCESSORS

B. TOTAL EFFECT
B1. OLS (LT)
B2. OLS BEFORE (TOTAL)
B3. 2SLS
B4. 2SLS BEFORE

C. HETEROGENEOUS EFFECT
C1. OLS IY SUCCESSFUL 
C2. OLS LT SUCCESSFUL
C3. OLS SUCCESSFUL BEFORE 
C4. OLS IY INTERACTION CNTS
C5. OLS LT INTERACTION CNTS
C6. 2SLS LT
C7. 2SLS IY
C8. 2SLS BEFORE

D. AGE
*=============================================================================*/

/*==============================================================================
*A. ADDITIONAL DATA FOR EXPOSURE
*=============================================================================*/
/*==============================================================================
*A1. INSTRUMENT
*=============================================================================*/
*los instrumentos (demreg1, demreg2, y demreg3) se generan como proporciones basadas en la variable dem
clear
forv d=1/2{
	preserve
	u "temp/2democracy/panelDem`d'",clear
	mer m:1 country using "temp/2democracy/censusCountry",keepus(region regionanrr) nogen keep(1 3)

	*DROP DUPLICATED COUNTRIES TEMPORARILY (so that they are not counted twice in the instrument)
	drop if inlist(country,"SERBIA","MONTENEGRO","KOSOVO")
	drop if inlist(country,"ARUBA","BONAIRE, SINT EUSTATIUS AND SABA","CURACAO")

	*DEFINE INITIAL REGIME FOLLOWING ANRR
	bys country:g t0=inrange(sum(!missing(dem)),1,5)
	bys country:egen t1=mean(dem) if t0==1
	bys country:egen initialregime=mean(t1)
	replace initialregime=initialregime==1 if !missing(initialregime)
	if `d'==2{
		su initialregime,d
		replace initialregime=initialregime>0.25 if !missing(initialregime) //we choose 0.25 so that this there is almost the same fraction of democracies with initial regime being democracy as in the case of our discrete measure (17.98%)
	}
	replace initialregime=0 if inlist(country,"ANGUILLA","CYPRUS","NORTHERN CYPRUS","NETHERLANDS ANTILLES") //See demall
	drop t0 t1

	*DEFINE INSTRUMENTS
	bys regionanrr year initialregime:egen t0=sum(dem)
	bys regionanrr year initialregime:egen t1=count(dem)
	g demreg1=cond(dem==.,t0/t1,(t0-dem)/(t1-1))
	drop t0 t1

	bys region year:egen t0=sum(dem)
	bys region year:egen t1=count(dem)
	g demreg2=cond(dem==.,t0/t1,(t0-dem)/(t1-1))
	drop t0 t1


	bys region year initialregime:egen t0=sum(dem)
	bys region year initialregime:egen t1=count(dem)
	g demreg3=cond(dem==.,t0/t1,(t0-dem)/(t1-1))
	drop t0 t1
	*GENERATE LAGS
	keep country year dem demreg* initialregime regionanrr
	egen t0=group(country)
	xtset t0 year
	forv r=1/3{
		forv l=1/5{
			g demreg`r'l`l'=l`l'.demreg`r'
		}
	}
	drop t0

	*RECOVER DROPPED COUNTRIES
	expand cond(country=="SERBIA AND MONTENEGRO",4,1)
	bys country year:g t0=_n
	replace country="SERBIA" if t0==2
	replace country="MONTENEGRO" if t0==3
	replace country="KOSOVO" if t0==4
	drop t0
	expand cond(country=="NETHERLANDS ANTILLES",4,1)
	bys country year:g t0=_n
	replace country="ARUBA" if t0==2
	replace country="BONAIRE, SINT EUSTATIUS AND SABA" if t0==3
	replace country="CURACAO" if t0==4
	drop t0
	la var initialregime "equals one if initial regime is Democracy"
	la da "Panel jackknifed average democracy in region, binary"
	drop demreg2* demreg3*
	ren demreg1 demreg1l0
	ren demreg1* demreg*
	ren demregl* z*dem`d'
	drop dem regionanrr dem initialregime
	
	sa "temp",replace
	restore
	if `d'==1 u "temp",clear
	else if `d'==2 mer 1:1 country year using "temp",nogen 
	
}
so country year
la da "Panel Instrument"
sa "temp/2democracy/panelInst",replace


/*==============================================================================
*A2. HETEROGENEOUS EFFECTS: MAIN (these are measures of success)
*=============================================================================*/
/* We also explore alternative sources of heterogeneity. The alternative
sources of heterogeneity are temporarily in heF. */
* Growth
use country year gdppc2gr using "temp/3addVars/gdp/gdp.dta", clear
gegen t0 = standardize(gdppc2gr)
gen growth_sd = t0 >= -1 if !missing(gdppc2gr, t0)
keep country year growth_sd 
sa "temp", replace

* Corruption → Transparency
use "temp/3addVars/corruption", clear
gen t0 = 1 - corruption
gegen z = standardize(t0)
gen trans_sd2 = z >= 0.5 if !missing(t0, z)
keep country year trans_sd2
mer 1:1 country year using "temp", nogen
sa "temp", replace

* Capacity
use "temp/3addVars/statecap", clear
gegen t0 = standardize(statecapbase)
gen statecapbase_sd = t0 >= -1 if !missing(statecapbase, t0)
keep country year statecapbase_sd 
mer 1:1 country year using "temp", nogen
sa "temp", replace

*Redistribution
u "temp/3addVars/redistribution",clear
keep country year sharetop1
foreach t in 1{
	su sharetop`t',d
	g redis_top`t'=sharetop`t'>=`r(p50)' if !mi(sharetop`t')
}
foreach v of varlist redis_top1{
	replace `v'=2 if `v'==1
	replace `v'=1 if `v'==0
	replace `v'=0 if `v'==2
}
mer 1:1 country year using "temp",nogen
sa "temp",replace

u "temp",replace
la var growth_sd "Growth"
la var trans_sd2 "Transparency"
la var statecapbase_sd "Capacity"
la var redis_top1 "Redistribution"

ren (growth_sd trans_sd2 statecapbase_sd redis_top1) suc#,addnumber
keep country year suc*
order *,seq
order country year
so country year
compress
sa "temp/3addVars/heM/he",replace


/*==============================================================================
*A3. CREATE PROCESSORS
*=============================================================================*/
*Total effect (we create four processors to loop over specifications)
gl max=4
clear
set obs ${max}
g n=_n
gl processorsTask=min(${processors},${max})
gen c0=min(${processorsTask},ceil(n*${processorsTask}/_N))
bys c0:g c1=_n
sa "temp/3addVars/processors",replace

foreach w in $he_elements{
	u "temp/3addVars/he`w'/he",replace
	des suc*,clear replace
	g suc=real(regexr(name,"suc",""))
	keep suc
	qui su suc
	gl Nsuc`w'=`r(max)'
	gl processorsTask=min(${processors},${Nsuc`w'})
	gen c0=min(${processorsTask},ceil(suc*${processorsTask}/_N))
	bys c0:g c1=_n
	compress
	sa "temp/3addVars/he`w'/processors",replace
}


/*==============================================================================
*B. TOTAL EFFECT
*=============================================================================*/
/*==============================================================================
*B1. OLS
*=============================================================================*/
u "temp/1survey/censusCountryYearbYear",replace
ren year yearsvy
expand yearsvy-yearb+1
bys id:g year=yearb-1+_n
forv d=1/2{
	mer m:1 country year using "temp/2democracy/panelDem`d'",keep(1 3) nogen keepus(dem)
	ren dem dem`d'
}

*lifetime (lt) exposure to democracy (since age k until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=${k}
	bys id: gegen t1=sum(`v') if year-yearb>=${k}&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 0 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt0" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=0
	bys id: gegen t1=sum(`v') if year-yearb>=0&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 2 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt2" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=2
	bys id: gegen t1=sum(`v') if year-yearb>=2&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 4 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt4" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=4
	bys id: gegen t1=sum(`v') if year-yearb>=4&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 6 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt6" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=6
	bys id: gegen t1=sum(`v') if year-yearb>=6&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 8 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt8" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=8
	bys id: gegen t1=sum(`v') if year-yearb>=8&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 10 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt10" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=10
	bys id: gegen t1=sum(`v') if year-yearb>=10&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 12 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt12" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=12
	bys id: gegen t1=sum(`v') if year-yearb>=12&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 14 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt14" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=14
	bys id: gegen t1=sum(`v') if year-yearb>=14&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*lifetime (lt) exposure to democracy (since age 16 until year of survey)
foreach v of varlist dem1 dem2{
	local newvar = "demlt16" + substr("`v'",4,1)
	bys id: gegen t0=sum(missing(`v')) if year-yearb>=16
	bys id: gegen t1=sum(`v') if year-yearb>=16&t0==0
    bys id: gegen `newvar'=mean(t1)
	drop t0 t1
}

*exposure to democracy during impressionable years (iy)
foreach v of varlist dem1 dem2{
    local newvar = "demiy" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=18&year-yearb<26
    bys id: gegen t1=sum(`v') if year-yearb>=18&year-yearb<26&t0==0
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

*exposure to democracy during impressionable years (17-24)
foreach v of varlist dem1 dem2{
    local newvar = "demiy1724" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=17&year-yearb<25
    bys id: gegen t1=sum(`v') if year-yearb>=17&year-yearb<25&t0==0
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

*exposure to democracy during impressionable years (19-26)
foreach v of varlist dem1 dem2{
    local newvar = "demiy1926" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=19&year-yearb<27
    bys id: gegen t1=sum(`v') if year-yearb>=19&year-yearb<27&t0==0
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

*exposure to democracy during impressionable years (16-20)
foreach v of varlist dem1 dem2{
    local newvar = "demiy1620" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=16&year-yearb<21
    bys id: gegen t1=sum(`v') if year-yearb>=16&year-yearb<21&t0==0
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

*exposure to democracy during impressionable years (17-21)
foreach v of varlist dem1 dem2{
    local newvar = "demiy1721" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=17&year-yearb<22
    bys id: gegen t1=sum(`v') if year-yearb>=17&year-yearb<22&t0==0
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

*exposure to democracy during impressionable years (18-22)
foreach v of varlist dem1 dem2{
    local newvar = "demiy1822" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=18&year-yearb<23
    bys id: gegen t1=sum(`v') if year-yearb>=18&year-yearb<23&t0==0
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

*exposure to democracy during impressionable years (18-27)
foreach v of varlist dem1 dem2{
    local newvar = "demiy1827" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=18&year-yearb<28
    bys id: gegen t1=sum(`v') if year-yearb>=18&year-yearb<28&t0==0
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

*exposure to democracy during impressionable years (18-30)
foreach v of varlist dem1 dem2{
    local newvar = "demiy1830" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=18&year-yearb<31
    bys id: gegen t1=sum(`v') if year-yearb>=18&year-yearb<31&t0==0
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

*exposure to democracy during impressionable years (20-32)
foreach v of varlist dem1 dem2{
    local newvar = "demiy2032" + substr("`v'",4,1)
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=20&year-yearb<33
    bys id: gegen t1=sum(`v') if year-yearb>=20&year-yearb<33&t0==0
    drop `v'
    bys id: gegen `newvar'=mean(t1)
    drop t0 t1
}

keep country yearsvy yearb dem*
ren yearsvy year
duplicates drop
la var demlt1 "Exposure to Democracy"
la var demlt2 "Exposure to Democracy"
la var demiy1 "Exposure to Democracy 18-25"
la var demiy2 "Exposure to Democracy 18-25"
la var demiy17241 "Exposure to Democracy 17-24"
la var demiy17242 "Exposure to Democracy 17-24"
la var demiy19261 "Exposure to Democracy 19-26"
la var demiy19262 "Exposure to Democracy 19-26"
la var demiy16201 "Exposure to Democracy 16-20"
la var demiy16202 "Exposure to Democracy 16-20"
la var demiy17211 "Exposure to Democracy 17-21"
la var demiy17212 "Exposure to Democracy 17-21"
la var demiy18221 "Exposure to Democracy 18-22"
la var demiy18222 "Exposure to Democracy 18-22"
la var demiy18271 "Exposure to Democracy 18-27"
la var demiy18272 "Exposure to Democracy 18-27"
la var demiy18301 "Exposure to Democracy 18-30"
la var demiy18302 "Exposure to Democracy 18-30"
la var demiy20321 "Exposure to Democracy 20-32"
la var demiy20322 "Exposure to Democracy 20-32"
la data "Exposure to Democracy"
compress
sa "temp/2democracy/tot/dem",replace


/*==============================================================================
*B2. OLS BEFORE
*=============================================================================*/
u "temp/1survey/censusCountryYearbYear",replace
drop id
ren year yearsvy
g yearmin=yearb-1-max(yearsvy-yearb,1) 
g yearmax=yearb-1
expand yearmax-yearmin+1
egen id=group(country yearmin yearmax)
bys id:g year=yearmin-1+_n
forv d=1/2{
	mer m:1 country year using "temp/2democracy/panelDem`d'",keep(1 3) nogen keepus(dem)
	ren dem dem`d'
}
forv d=1/2{
	foreach y of numlist 10{
		bys id: egen t0=sum(missing(dem`d')) if inrange(yearmax-year,0,`y'-1)
		bys id: egen t1=sum(dem`d') if inrange(yearmax-year,0,`y'-1)&t0==0
		bys id: egen bef`d'=mean(t1)
		drop t0 t1
	}
	drop dem`d'
}
keep country yearsvy yearb bef*
la var bef1 "Pre-Birth Exposure to Democracy"
la var bef2 "Pre-Birth Exposure to Democracy"
ren yearsvy year
duplicates drop
la data "Pre-Birth Exposure to Democracy"
compress
sa "temp/2democracy/tot/bef",replace


/*==============================================================================
*B3. 2SLS
*=============================================================================*/
*2SLS (IY)
u "temp/1survey/censusCountryYearbYear",replace
ren year yearsvy
expand yearsvy-yearb+1
bys id:g year=yearb-1+_n
mer m:1 country year using "temp/2democracy/panelInst",keep(1 3) nogen
*exposure during impressionable years (iy)
foreach v of varlist z*dem*{
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=18&year-yearb<26
    bys id: gegen t1=sum(`v') if year-yearb>=18&year-yearb<26&t0==0
    drop `v'
    bys id: egen `v'=mean(t1)
    drop t0 t1
}
keep country yearsvy yearb z*dem*
duplicates drop
ren yearsvy year
la da "Instruments, exposure to democracy of neighbors"
compress
sa "temp/2democracy/tot/instiy",replace

*2SLS (LT)
u "temp/1survey/censusCountryYearbYear",replace
ren year yearsvy
expand yearsvy-yearb+1
bys id:g year=yearb-1+_n
mer m:1 country year using "temp/2democracy/panelInst",keep(1 3) nogen
*exposure during lifetime (lt)
foreach v of varlist z*dem*{
    bys id: gegen t0=sum(missing(`v')) if year-yearb>=${k}
    bys id: gegen t1=sum(`v') if year-yearb>=${k}&t0==0
    drop `v'
    bys id: egen `v'=mean(t1)
    drop t0 t1
}
keep country yearsvy yearb z*dem*
duplicates drop
ren yearsvy year
la da "Instruments, exposure to democracy of neighbors"
compress
sa "temp/2democracy/tot/instlt",replace


/*==============================================================================
*B4. 2SLS BEFORE
*=============================================================================*/
u "temp/1survey/censusCountryYearbYear",replace
keep country yearb
duplicates drop
g yearmin=yearb-1-(10-1) //Min between 50 years age and age reversed
g yearmax=yearb-1
g id=_n
expand yearmax-yearmin+1
bys id:g year=yearmin-1+_n
mer m:1 country year using "temp/2democracy/panelInst",keep(1 3) nogen keepus(z1dem1 z1dem2)
ren (z1dem1 z1dem2) (dem1 dem2)
forv d=1/2{	
	bys id: egen t0=sum(missing(dem`d')) if inrange(yearmax-year,0,10-1)
	bys id: egen t1=sum(dem`d') if inrange(yearmax-year,0,10-1)&t0==0
	*bys id: egen dem`d'b`y'=mean(t1)
	bys id: egen zbef`d'=mean(t1)
	drop t0 t1
	drop dem`d'
}
keep country yearb zbef*
la var zbef1 "Pre-Birth Instrument"
la var zbef2 "Pre-Birth Instrument"
duplicates drop
la data "Pre-Birth Exposure to Democracy of the Neighbors"
compress
sa "temp/2democracy/tot/instBef",replace



/*==============================================================================
*C. HETEROGENEOUS EFFECT (SUCCESSFUL DEMOCRACIES)
*=============================================================================*/
/*==============================================================================
*C1. OLS 18-25 SUCCESSFUL 
*=============================================================================*/
cap program drop tempprocess
program define tempprocess
args word
qui forv suc=1/`=_N'{
	u if c0==${pll_instance}&c1==`suc' using "temp/3addVars/he`word'/processors",clear
	assert _N==1
	loc suci=suc in 1
	di as input "processing `suci' out of `=_N'"
	
	u id country yearb year yearsvy aut1 aut2 dem1 dem2 suc`suci' using "temp",replace
	ren suc`suci' suc
	local labelsuc `"`: var label suc'"' 
	g uns=(1-suc)
	gl vars "aut1 aut2 dem1 dem2 suc uns"
	foreach v2 of varlist aut1 aut2 dem1 dem2{
		foreach v1 of varlist suc uns{
			g `v1'`v2'=`v1'*`v2'
			gl vars "${vars} `v1'`v2'"
		}
	}
	gl varsmiss
	foreach v of varlist $vars{
		gl varsmiss "${varsmiss} miss`v'=`v'"
	}
	gcollapse (sum) ${vars} (nmissing) ${varsmiss},by(country yearb yearsvy)
	ren yearsvy year
	foreach v of varlist $vars{
		replace `v'=. if miss`v'>0
		drop miss`v'
	}
	order country yearb year
	so country yearb year
	local labeldem "Exposure to Democracy 18-25"
	if "`word'"=="F"{
	forv d=1/2{
		la var dem`d' "`labeldem'"
		la var sucdem`d' "`labeldem' $\times$ `labelsuc'"
		}
	}
	else if "`word'"=="M"{
	forv d=1/2{
		la var aut`d' "Exposure to Autocracy 18-25"
		la var dem`d' "Exposure to Democracy 18-25"
		la var sucaut`d' "Exposure to Successful Autocracy 18-25"
		la var unsaut`d' "Exposure to Unsuccessful Autocracy 18-25"
		la var sucdem`d' "Exposure to Successful Democracy 18-25"
		la var unsdem`d' "Exposure to Unsuccessful Democracy 18-25"
		la var suc "Exposure to Successful Performance"
		la var uns "Exposure to Unsuccessful Performance"
		}
	}
	compress
	sa "temp/2democracy/suc`word'/dem/suc`suci'iy",replace
}
end

qui foreach w in $he_elements {
	noi di as input "processing `w'"
	u "temp/1survey/censusCountryYearbYear",replace
	ren year yearsvy
	expand yearsvy-yearb+1
	bys id:g year=yearb-1+_n
	forv d=1/2{
		mer m:1 country year using "temp/2democracy/panelDem`d'",keep(1 3) nogen keepus(dem)
		ren dem dem`d'
		g aut`d'=(1-dem`d')
	}
	mer m:1 country year using "temp/3addVars/he`w'/he",nogen keep(1 3)
	keep if year-yearb>=18&year-yearb<26 // IY
	sa "temp",replace
	
	u "temp/3addVars/he`w'/processors",replace
	qui su c0
	loc processors=`r(max)'
	parallel initialize `processors',f
	noi parallel, prog(tempprocess): tempprocess `w'
	noi di as input "child processes which stopped with an error: " `r(pll_errs)'
}

/*==============================================================================
*C2. OLS LIFETIME SUCCESSFUL
*=============================================================================*/	
cap program drop tempprocess
program define tempprocess
args word
qui forv suc=1/`=_N'{
	u if c0==${pll_instance}&c1==`suc' using "temp/3addVars/he`word'/processors",clear
	assert _N==1
	loc suci=suc in 1
	di as input "processing `suci' out of `=_N'"
	
	u id country yearb year yearsvy aut1 aut2 dem1 dem2 suc`suci' using "temp",replace
	ren suc`suci' suc
	g uns=(1-suc)
	gl vars "aut1 aut2 dem1 dem2 suc uns"
	foreach v2 of varlist aut1 aut2 dem1 dem2{
		foreach v1 of varlist suc uns{
			g `v1'`v2'=`v1'*`v2'
			gl vars "${vars} `v1'`v2'"
		}
	}
	gl varsmiss
	foreach v of varlist $vars{
		gl varsmiss "${varsmiss} miss`v'=`v'"
	}
	local labelsuc `"`: var label suc'"' 
	gcollapse (sum) ${vars} (nmissing) ${varsmiss},by(country yearb yearsvy)
	la var suc "`labelsuc'"
	ren yearsvy year
	foreach v of varlist $vars{
		replace `v'=. if miss`v'>0
		drop miss`v'
	}
	order country yearb year
	so country yearb year
	local labelsuc `"`: var label suc'"' 
	local labeldem "Lifetime Democracy"
	if "`word'"=="F"{
	forv d=1/2{
		la var dem`d' "`labeldem'"
		la var sucdem`d' "`labeldem' $\times$ `labelsuc'"
		}
	}
	else if "`word'"=="M"{
	forv d=1/2{
		la var aut`d' "Exposure to Autocracy"
		la var dem`d' "Exposure to Democracy"
		la var sucaut`d' "Exposure to Successful Autocracy"
		la var unsaut`d' "Exposure to Unsuccessful Autocracy"
		la var sucdem`d' "Exposure to Successful Democracy"
		la var unsdem`d' "Exposure to Unsuccessful Democracy"
		la var suc "Exposure to Successful Performance"
		la var uns "Exposure to Unsuccessful Performance"
		}
	}
	compress
	sa "temp/2democracy/suc`word'/dem/suc`suci'lt",replace // lo guardamos como LT
}
end

foreach w in $he_elements{
	noi di as input "processing `w'"
	u "temp/1survey/censusCountryYearbYear",replace
	ren year yearsvy
	expand yearsvy-yearb+1
	bys id:g year=yearb-1+_n
	forv d=1/2{
		mer m:1 country year using "temp/2democracy/panelDem`d'",keep(1 3) nogen keepus(dem)
		ren dem dem`d'
		g aut`d'=(1-dem`d')
	}
	mer m:1 country year using "temp/3addVars/he`w'/he",nogen keep(1 3)
	keep if year-yearb>=${k} // LT
	sort id year
	ds suc*
	local suclist `r(varlist)'
	local nvars : word count `suclist'
	forv i=1/`nvars' { 
		local labelsuc`i' `"`: var label suc`i''"' 
		by id: gen suc`i'_temp=suc`i' if _n==1
		by id: replace suc`i'_temp=suc`i'_temp[_n-1] if suc`i'_temp==.	
		drop suc`i'
		rename suc`i'_temp suc`i'
		la var suc`i' "`labelsuc`i''"
	}
	sa "temp",replace
	u "temp/3addVars/he`w'/processors",replace
	qui su c0
	loc processors=`r(max)'
	parallel initialize `processors',f
	noi parallel, prog(tempprocess): tempprocess `w'
	noi di as input "child processes which stopped with an error: " `r(pll_errs)'
}


/*==============================================================================
*C3. OLS BEFORE SUCCESSFUL
*=============================================================================*/
/*==============================================================================
*C3.A OLS BEFORE SUCCESSFUL, MAIN
*=============================================================================*/
u "temp/1survey/censusCountryYearbYear",replace
keep country yearb
duplicates drop
g yearmin=yearb-1-(10-1) //Min between 50 years age and age reversed
g yearmax=yearb-1
g id=_n
expand yearmax-yearmin+1
bys id:g year=yearmin-1+_n
forv d=1/2{
	mer m:1 country year using "temp/2democracy/panelDem`d'",keep(1 3) nogen keepus(dem)
	ren dem dem`d'
	g aut`d'=(1-dem`d')
}
mer m:1 country year using "temp/3addVars/heM/he",nogen keep(1 3)
sa "temp",replace

qui forv suc=1/4{	
	u id country yearb year aut1 aut2 dem1 dem2 suc`suc' using "temp",replace
	ren suc`suc' suc
	g uns=(1-suc)
	gl vars "aut1 aut2 dem1 dem2 suc uns"
	foreach v2 of varlist aut1 aut2 dem1 dem2{
		foreach v1 of varlist suc uns{
			g `v1'`v2'=`v1'*`v2'
			gl vars "${vars} `v1'`v2'"
		}
	}
	gl varsmiss
	foreach v of varlist $vars{
		gl varsmiss "${varsmiss} miss`v'=`v'"
	}
	gcollapse (sum) ${vars} (nmissing) ${varsmiss},by(country yearb)
	foreach v of varlist $vars{
		replace `v'=. if miss`v'>0
		drop miss`v'
	}
	order country yearb year
	so country yearb year
	forv d=1/2{
		la var aut`d' "Exposure to Autocracy"
		la var dem`d' "Exposure to Democracy"
		la var sucaut`d' "Exposure to Successful Autocracy"
		la var unsaut`d' "Exposure to Unsuccessful Autocracy"
		la var sucdem`d' "Exposure to Successful Democracy"
		la var unsdem`d' "Exposure to Unsuccessful Democracy"
	}
	la var suc "Exposure to Successful Performance"
	la var uns "Exposure to Unsuccessful Performance"
	compress
	sa "temp/2democracy/sucM/bef/suc`suc'",replace 
}


/*==============================================================================
*C6. 2SLS LT
*=============================================================================*/
cap program drop tempprocess
program define tempprocess
args word
qui forv suc=1/`=_N'{
	u if c0==${pll_instance}&c1==`suc' using "temp/3addVars/he`word'/processors",clear
	assert _N==1
	loc suci=suc in 1
	di as input "processing `suci' out of `=_N'"
	
	u id country yearb year yearsvy aut1 aut2 dem1 dem2 suc`suci' using "temp",replace
	ren suc`suci' suc
	g uns=(1-suc)
	gl vars "aut1 aut2 dem1 dem2 suc uns"
	foreach v2 of varlist aut1 aut2 dem1 dem2{
		foreach v1 of varlist suc uns{
			g `v1'`v2'=`v1'*`v2'
			gl vars "${vars} `v1'`v2'"
		}
	}
	gl varsmiss
	foreach v of varlist $vars{
		gl varsmiss "${varsmiss} miss`v'=`v'"
	}
	gcollapse (sum) ${vars} (nmissing) ${varsmiss},by(country yearb yearsvy)
	ren yearsvy year
	foreach v of varlist $vars{
		replace `v'=. if miss`v'>0
		drop miss`v'
	}
	order country yearb year
	so country yearb year
	forv d=1/2{
		la var aut`d' "Exposure to Autocracy"
		la var dem`d' "Exposure to Democracy"
		la var sucaut`d' "Exposure to Successful Autocracy"
		la var unsaut`d' "Exposure to Unsuccessful Autocracy"
		la var sucdem`d' "Exposure to Successful Democracy"
		la var unsdem`d' "Exposure to Unsuccessful Democracy"
	}
	la var suc "Exposure to Successful Performance"
	la var uns "Exposure to Unsuccessful Performance"
	compress
	sa "temp/2democracy/suc`word'/inst/suc`suci'",replace
}
end

qui foreach w in $he_elements{
	noi di as input "processing `w'"
	
	u "temp/1survey/censusCountryYearbYear",replace
	ren year yearsvy
	expand yearsvy-yearb+1
	bys id:g year=yearb-1+_n
	mer m:1 country year using "temp/2democracy/panelInst",keep(1 3) nogen keepus(z1dem1 z1dem2)
	ren (z1dem1 z1dem2) (dem1 dem2)
	forv d=1/2{
		g aut`d'=(1-dem`d')
	}
	mer m:1 country year using "temp/3addVars/he`w'/he",nogen keep(1 3)
	keep if year-yearb>=${k}
	sa "temp",replace

	u "temp/3addVars/he`w'/processors",replace
	qui su c0
	loc processors=`r(max)'
	parallel initialize `processors',f
	noi parallel, prog(tempprocess): tempprocess `w'
	noi di as input "child processes which stopped with an error: " `r(pll_errs)'
}

/*==============================================================================
*C7. 2SLS IY
*=============================================================================*/
cap program drop tempprocess
program define tempprocess
args word
qui forv suc=1/`=_N'{
	u if c0==${pll_instance}&c1==`suc' using "temp/3addVars/he`word'/processors",clear
	assert _N==1
	loc suci=suc in 1
	di as input "processing `suci' out of `=_N'"
	
	u id country yearb year yearsvy aut1 aut2 dem1 dem2 suc`suci' using "temp",replace
	ren suc`suci' suc
	g uns=(1-suc)
	gl vars "aut1 aut2 dem1 dem2 suc uns"
	foreach v2 of varlist aut1 aut2 dem1 dem2{
		foreach v1 of varlist suc uns{
			g `v1'`v2'=`v1'*`v2'
			gl vars "${vars} `v1'`v2'"
		}
	}
	gl varsmiss
	foreach v of varlist $vars{
		gl varsmiss "${varsmiss} miss`v'=`v'"
	}
	gcollapse (sum) ${vars} (nmissing) ${varsmiss},by(country yearb yearsvy)
	ren yearsvy year
	foreach v of varlist $vars{
		replace `v'=. if miss`v'>0
		drop miss`v'
	}
	order country yearb year
	so country yearb year
	forv d=1/2{
		la var aut`d' "Exposure to Autocracy"
		la var dem`d' "Exposure to Democracy"
		la var sucaut`d' "Exposure to Successful Autocracy"
		la var unsaut`d' "Exposure to Unsuccessful Autocracy"
		la var sucdem`d' "Exposure to Successful Democracy"
		la var unsdem`d' "Exposure to Unsuccessful Democracy"
	}
	la var suc "Exposure to Successful Performance"
	la var uns "Exposure to Unsuccessful Performance"
	compress
	sa "temp/2democracy/suc`word'/inst/suc`suci'iy",replace
}
end

qui foreach w in $he_elements{
	noi di as input "processing `w'"
	
	u "temp/1survey/censusCountryYearbYear",replace
	ren year yearsvy
	expand yearsvy-yearb+1
	bys id:g year=yearb-1+_n
	mer m:1 country year using "temp/2democracy/panelInst",keep(1 3) nogen keepus(z1dem1 z1dem2)
	ren (z1dem1 z1dem2) (dem1 dem2)
	forv d=1/2{
		g aut`d'=(1-dem`d')
	}
	mer m:1 country year using "temp/3addVars/he`w'/he",nogen keep(1 3)
	keep if year-yearb>=18&year-yearb<26 // IY
	sa "temp",replace

	u "temp/3addVars/he`w'/processors",replace
	qui su c0
	loc processors=`r(max)'
	parallel initialize `processors',f
	noi parallel, prog(tempprocess): tempprocess `w'
	noi di as input "child processes which stopped with an error: " `r(pll_errs)'
}

/*==============================================================================
*C8. 2SLS BEFORE
*=============================================================================*/
cap program drop tempprocess
program define tempprocess
args word
qui forv suc=1/`=_N'{
	u if c0==${pll_instance}&c1==`suc' using "temp/3addVars/he`word'/processors",clear
	assert _N==1
	loc suci=suc in 1
	di as input "processing `suci' out of `=_N'"
	
	u id country yearb year aut1 aut2 dem1 dem2 suc`suci' using "temp",replace
	ren suc`suci' suc
	g uns=(1-suc)
	gl vars "aut1 aut2 dem1 dem2 suc uns"
	foreach v2 of varlist aut1 aut2 dem1 dem2{
		foreach v1 of varlist suc uns{
			g `v1'`v2'=`v1'*`v2'
			gl vars "${vars} `v1'`v2'"
		}
	}
	gl varsmiss
	foreach v of varlist $vars{
		gl varsmiss "${varsmiss} miss`v'=`v'"
	}
	gcollapse (sum) ${vars} (nmissing) ${varsmiss},by(country yearb)
	foreach v of varlist $vars{
		replace `v'=. if miss`v'>0
		drop miss`v'
	}
	order country yearb year
	so country yearb year
	forv d=1/2{
		la var aut`d' "Exposure to Autocracy"
		la var dem`d' "Exposure to Democracy"
		la var sucaut`d' "Exposure to Successful Autocracy"
		la var unsaut`d' "Exposure to Unsuccessful Autocracy"
		la var sucdem`d' "Exposure to Successful Democracy"
		la var unsdem`d' "Exposure to Unsuccessful Democracy"
	}
	la var suc "Exposure to Successful Performance"
	la var uns "Exposure to Unsuccessful Performance"
	compress
	sa "temp/2democracy/suc`word'/instBef/suc`suci'",replace
}
end

qui foreach w in $he_elements{
	noi di as input "processing `w'"
	
	u "temp/1survey/censusCountryYearbYear",replace
	keep country yearb
	duplicates drop
	g yearmin=yearb-1-(10-1) //Min between 50 years age and age reversed
	g yearmax=yearb-1
	g id=_n
	expand yearmax-yearmin+1
	bys id:g year=yearmin-1+_n
	mer m:1 country year using "temp/2democracy/panelInst",keep(1 3) nogen keepus(z1dem1 z1dem2)
	ren (z1dem1 z1dem2) (dem1 dem2)
	forv d=1/2{
		g aut`d'=(1-dem`d')
	}
	mer m:1 country year using "temp/3addVars/he`w'/he",nogen keep(1 3)
	sa "temp",replace

	u "temp/3addVars/he`w'/processors",replace
	qui su c0
	loc processors=`r(max)'
	parallel initialize `processors',f
	noi parallel, prog(tempprocess): tempprocess `w'
	noi di as input "child processes which stopped with an error: " `r(pll_errs)'
}



/*==============================================================================
*D. AGE 
*=============================================================================*/
*TOTAL EFFECT 
gl g1 "2 9"
gl g2 "10 17"
gl g3 "18 25"
gl g4 "26 33"
gl g5 "34 41"
gl g6 "0 200"

u "temp/1survey/censusCountryYearbYear",replace
ren year yearsvy
expand yearsvy-yearb+1
bys id:g year=yearb-1+_n
forv d=1/2{
	mer m:1 country year using "temp/2democracy/panelDem`d'",keep(1 3) nogen keepus(dem)
	ren dem dem`d'
}
sa "temp",replace

u "temp",replace
foreach v of varlist dem1 dem2{
	forv g=1/6{
		loc min=real(word("${g`g'}",1))
		loc max=real(word("${g`g'}",2))
		bys id: egen t0=sum(missing(`v')) if inrange(year-yearb,`min',`max')
		bys id: egen t1=sum(`v') if t0==0&inrange(year-yearb,`min',`max')
		bys id: egen `v'g`g'=mean(t1)
		drop t0 t1
	}
}
keep country yearsvy yearb dem*g*
ren yearsvy year
duplicates drop
forv d=1/2{
	la var dem`d'g1 "Exposure to Democracy $2-9$"
	la var dem`d'g2 "Exposure to Democracy $10-17$"
	la var dem`d'g3 "Exposure to Democracy $18-25$"
	la var dem`d'g4 "Exposure to Democracy $26-33$"
	la var dem`d'g5 "Exposure to Democracy $34-41$"
	la var dem`d'g6 "Exposure to Democracy (Lifetime)"
}
compress
sa "temp/2democracy/tot/demAge",replace
