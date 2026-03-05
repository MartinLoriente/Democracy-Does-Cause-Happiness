/*==============================================================================
// MAIN FIGURES

Figure 1: Pathway from Democracy to Well-Being
Figure 2: Pre-Birth Exposure to Democracy and Democracy 18-25
Figure 3: Placebo Variables 18-25

// APPENDIX FIGURES

Figure A1: Democracy and Exposure to Democracy by Year/Cohort
Figure A2: Pre-Birth Exposure to Democracy and Lifetime Democracy
Figure A3: Pre-Birth Exposure to Successful Democracy and Successful Democracy 18-25
Figure A4: Pre-Birth Exposure to Unsuccessful Democracy and Unsuccessful Autocracy, 18-25
Figure A5: Pre-Birth Exposure to Successful Democracy and Lifetime Successful Democracy
Figure A6: Pre-Birth Exposure to Unsuccessful Democracy and Unsuccessful Autocracy, Lifetime
Figure A7: Success in Europe and Asia
Figure A8: Democracy and Well-Being
Figure A9: Pre-Birth Exposure to Democracy and Democracy 18-25 — IV
Figure A10: Pre-Birth Exposure to Democracy and Lifetime Democracy — IV

// ONLINE APPENDIX FIGURES

Figure O1 & O2: Pre-Birth Exposure to Successful & Unsuccessful Democracy, IV IY
Figure O3 & O4: Pre-Birth Exposure to Successful & Unsuccessful Democracy, IV LT
Figure O5: Lifetime Exposure to Democracy and Placebo Variables — IV IY
Figure O6: Lifetime Exposure to Democracy and Placebo Variables — IV LT
Figure O7, O8, O9, O10 & O11: Binned Scatterplots of Democracy and Well-Being
Figure O12 & O13: Quantile Effects of Democracy on Well-Being
Figure O14 & O15: Results by 18-25 Democratic Exposure 
Figure O16: Placebo Variables Lifetime
==============================================================================*/
/**/

do "${code}/utils/reghdfestd.ado"
do "${code}/utils/droptabular.ado"
do "${code}/utils/descstatistics.ado"

/*==============================================================================
MAIN FIGURES
*=============================================================================*/
/*==============================================================================
Figure 1: Pathway from Democracy to Well-Being
*=============================================================================*/
*Created in LaTeX


/*==============================================================================
Figure 2: Pre-Birth Exposure to Democracy and Democracy 18-25
*=============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/tot/olsBef"
u "temp/ivs",replace
mer m:1 country yearb year using "temp/2democracy/tot/bef",nogen keep(1 3)
forv c=1/1{
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
		loc dep=word("$a",`y')
		reghdfestd `dep' demiy`x' bef`x' [aw=weight] if age>24 , a(${fe`s'}) cl(${cl`c'}) version(5)
		estimates save "${saveout}/y`y'x`x's`s'c`c'iy",replace
			}
		}
	}
}

forv c=1/1{
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
			clear all
			estimates use "${savee}/tot/olsBef/y`y'x`x's`s'c`c'iy"
			test dem=bef
			local pval=`r(p)'
			ereturn display
			mat t0=r(table)'
			clear
			svmat2 t0,rnames(var) names(col)
			gen pval=`pval'
			g y=`y'
			g x=`x'
			g s=`s'
			save "${savee}/FigBef/y`y'x`x's`s'c`c'iy", replace
			}
		}
	}
}

*c=1
clear
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
			append using "${savee}/FigBef/y`y'x`x's`s'c1iy.dta"
			}
		}
	}
sa "${savee}/FigBefc1iy",replace
shell rm -r "${savee}/FigBefc1iy"

*FIGURE
forv c=1/1{
u "${savee}/FigBefc`c'iy",replace
drop pvalue
replace var=regexr(var,"[1-2]$","")
keep if inlist(s,1,2)
drop if var=="_cons"
keep y x s var b* ll* ul* pval
greshape wide b ll ul pval,i(y x s) j(var)
g diff=(pvaldem<0.05)
replace y=y+0.1 if s==2
replace y=y-0.1 if s==1
la def x ${xlabel}
la val x x
tw (rcap llbef ulbef y,horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc y bbef if s==1,mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*1.2)) ///
(sc y bbef if s==2,mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*1.2)) ///
(sc y bdem if s==1&diff==1,mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==2&diff==1,mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==1&diff==0,mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==2&diff==0,mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(x,note("")) ///
subtitle(,size(*1) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2" 4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.8) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none))
gr export "${savef}/befc`c'iy.pdf",replace
}


/*==============================================================================
Figure 3: Placebo Variables 18-25
*=============================================================================*/
gl saveout "${savee}/tot/olsPlaIY"
do "${code}/utils/reghdfestd.ado"
cap estimates clear
local files: dir "${savee}/tot/olsPlaIY" files "*"
foreach f of local files {
    cap erase "${savee}/tot/olsPlaIY/`f'"
}
u "temp/ivs",replace
keep if age>24
mer 1:1 svyid using "temp/1survey/placebo",nogen keep(1 3)
forv s=1/1{
	forv x=1/2{
		forv y=1/${placeboN} {
					loc dep=word("${placebo}",`y')
					reghdfestd `dep' demiy`x' [aw=weight], a(${fepla}) cl(${cl1}) version(5)
					estimates save "${saveout}/y`y'x`x's`s'iy.ster",replace
		}
	}
}
clear
cap frame drop temp
frame create temp
foreach e in olsPlaIY{ 
	noi di "processing files in folder `e'"
	loc files:dir "${savee}/tot/`e'" files "*.ster"
	foreach f of local files {
		qui frame temp {
			estimates use "${savee}/tot/`e'/`f'"
			ereturn display
			mat t0=r(table)'
			clear
			svmat2 t0,rnames(var) names(col)
			g file="`f'"
			g type="`e'"
			sa "temp",replace
		}
		qui append using "temp"
	}
}
drop eform
loc vc=0
foreach v in y x s {
	loc ++vc
	g `v'=real(regexs(`vc')) if regexm(file,"y([0-9][0-9]?)x([0-9])s([0-9])")
}
g fs=regexm(file,"Fs.ster$")
drop file
order type y x s fs var
so type y x s fs var
compress
sa "${savee}/totiy",replace

*FIGURE
u "${savee}/totiy",replace
keep if type=="olsPlaIY"
replace var=regexr(var,"[1-2]$","")
keep if inlist(s,1)
drop if var=="_cons"
keep y x s b* ll* ul*
la def x ${xlabel}
la val x x
g ulc=min(0.3,ul)
g llc=max(-0.3,ll)
g ulcapped=ulc!=ul
g llcapped=llc!=ll
tw (rspike llc ulc y,horizontal lcolor(gs1) lwidth(*0.5)) ///
(rcap ulc ulc y if ulcapped==0,horizontal lcolor(gs1) lwidth(*0.5)) ///
(rcap llc llc y if llcapped==0,horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc y b if s==1,mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*1)) ///
, by(x,note("") legend(off)) ///
subtitle(,size(*1) lcolor(none)) ///
legend(off) ///
xline(0,lcolor(gs1)) ylabel(${placebolabel},value angle(h) grid labsize(*1)) ///
xlabel(-0.3(0.1)0.3,format(%10.1fc)) ///
ytitle("") xtitle("") ///
 yscale(reverse) plotregion(style(none))
gr export "${savef}/plaiy.pdf",replace



/*==============================================================================
APPENDIX FIGURES
*=============================================================================*/
/*==============================================================================
Figure A1: Democracy and Exposure to Democracy by Year/Cohort
*=============================================================================*/
use "temp/2democracy/panelDem2", clear
keep if year>=1900
keep country year dem
encode country, gen(country_code)
bysort year: egen world_avg=mean(dem)
egen tag = tag(year)
xtset country_code year 
keep if year>=1900 & year<=2023

twoway line dem year, c(L) lcolor(gs12) lwidth(vthin) ///
|| line dem year if country=="ARGENTINA", c(L) lcolor(eltblue) lwidth(thick) ///
|| line dem year if country=="SOUTH KOREA", c(L) lcolor(dkgreen) lwidth(thick) lpattern(dash_dot) ///
|| line dem year if country=="TURKIYE", c(L) lcolor(maroon) lwidth(thick) lpattern(dash) ///
|| line dem year if country=="UNITED STATES", c(L) lcolor(navy) lwidth(thick) lpattern(shortdash) ///
xlabel(1900(20)2020, labsize(*1.2)) ///
plotregion(style(none)) ytitle("") xtitle("") ///
legend(order(2 "Argentina" 3 "South Korea" 4 "Turkey" 5 "United States") col(2) size(*1.2) rowgap(.5) region(lcolor(none))) /// 
xscale(titlegap(3)) yscale(titlegap(3)) graphregion(color(white)) ylabel(,angle(h) form(%3.1fc) labsize(*1.2))
gr export "${savef}/dem2_selected_countries.pdf",replace

*------------------------------------------------------------------------------*
* Exposure to Democracy by country-cohort
*------------------------------------------------------------------------------*
* Create average exposure to democracy from age 18 until age 25 by country-cohort
u "temp/1survey/censusCountryYearbYear",replace
drop id
duplicates drop country yearb, force
keep if yearb>=1900 & yearb<=2018
bysort country: replace yearb=1900 if _n==1
bysort country: replace yearb=2018 if _n==_N
encode country, gen(country_code)
tsset country_code yearb
tsfill
replace country=country[_n-1] if country==""
ren year yearsvy
replace yearsvy=2018
expand yearsvy-yearb+1
bys country yearb:g year=yearb-1+_n
sort country yearb year
bys country yearb: gen obs=_n
keep if obs>=18 & obs<25
drop obs
bysort country yearb: gen obs=_N // to calculate average exposure
replace country = "TURKIYE" if country == "TURKEY"
forv d=1/2{
	mer m:1 country year using "temp/2democracy/panelDem`d'",keep(1 3) nogen keepus(dem)
	ren dem dem`d'
}
foreach v of varlist dem1 dem2{
	bys country yearb: egen t0=sum(missing(`v')) 
	bys country yearb: egen t1=sum(`v') if t0==0
	drop `v'
	bys country yearb: egen `v'=mean(t1)
	drop t0 t1
}
keep country yearsvy yearb dem1 dem2 obs
ren yearsvy year
duplicates drop
la var dem1 "Exposure to Democracy"
la var dem2 "Exposure to Democracy"
la data "Exposure to Democracy"
compress
keep country yearb dem1 dem2 obs
sa "temp/2democracy/tot/dem_full",replace

* Plot
use "temp/2democracy/tot/dem_full", clear
keep if yearb>=1900 & yearb<=2000
rename dem2 dem
gen avg_dem = dem/obs // average exposure
encode country, gen(country_code)
bysort yearb: egen world_avg=mean(avg_dem)
egen tag = tag(yearb)
xtset country_code yearb
drop dem
rename avg_dem dem

twoway line dem year, c(L) lcolor(gs12) lwidth(vthin) ///
|| line dem year if country=="ARGENTINA", c(L) lcolor(eltblue) lwidth(thick) ///
|| line dem year if country=="SOUTH KOREA", c(L) lcolor(dkgreen) lwidth(thick) lpattern(dash_dot) ///
|| line dem year if country=="TURKIYE", c(L) lcolor(maroon) lwidth(thick) lpattern(dash) ///
|| line dem year if country=="UNITED STATES", c(L) lcolor(navy) lwidth(thick) lpattern(shortdash) ///
xlabel(1900(20)2000, labsize(*1.2)) ///
plotregion(style(none)) ytitle("") xtitle("") ///
legend(order(2 "Argentina" 3 "South Korea" 4 "Turkey" 5 "United States") col(2) size(*1.2) rowgap(.5) region(lcolor(none))) /// 
xscale(titlegap(3)) yscale(titlegap(3)) graphregion(color(white)) ylabel(,angle(h) form(%3.1fc) labsize(*1.2))
gr export "${savef}/exp_dem2_selected_countries.pdf",replace


/*==============================================================================
Figure A2: Pre-Birth Exposure to Democracy and Lifetime Democracy
*=============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/tot/olsBef"
u "temp/ivs",replace
mer m:1 country yearb year using "temp/2democracy/tot/bef",nogen keep(1 3)
forv c=1/1{
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
		loc dep=word("$a",`y')
		reghdfestd `dep' demlt`x' bef`x' [aw=weight], a(${fe`s'}) cl(${cl`c'}) version(5)
		estimates save "${saveout}/y`y'x`x's`s'c`c'lt",replace
			}
		}
	}
}

forv c=1/1{
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
			clear all
			estimates use "${savee}/tot/olsBef/y`y'x`x's`s'c`c'lt"
			test dem=bef
			local pval=`r(p)'
			ereturn display
			mat t0=r(table)'
			clear
			svmat2 t0,rnames(var) names(col)
			gen pval=`pval'
			g y=`y'
			g x=`x'
			g s=`s'
			save "${savee}/FigBef/y`y'x`x's`s'c`c'lt", replace
			}
		}
	}
}

*c=1
clear
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
			append using "${savee}/FigBef/y`y'x`x's`s'c1lt.dta"
			}
		}
	}
sa "${savee}/FigBefc1lt",replace
shell rm -r "${savee}/FigBefc1lt"

*FIGURE
forv c=1/1{
u "${savee}/FigBefc`c'lt",replace
drop pvalue
replace var=regexr(var,"[1-2]$","")
keep if inlist(s,1,2)
drop if var=="_cons"
keep y x s var b* ll* ul* pval
greshape wide b ll ul pval,i(y x s) j(var)
g diff=(pvaldem<0.05)
replace y=y+0.1 if s==2
replace y=y-0.1 if s==1
la def x ${xlabel}
la val x x
tw (rcap llbef ulbef y,horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc y bbef if s==1,mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*1.2)) ///
(sc y bbef if s==2,mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*1.2)) ///
(sc y bdem if s==1&diff==1,mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==2&diff==1,mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==1&diff==0,mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==2&diff==0,mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(x,note("")) ///
subtitle(,size(*1) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2" 4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.8) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none))
gr export "${savef}/befc`c'lt.pdf",replace
}


/*==============================================================================
Figure A3 & A4: Pre-Birth Exposure to Successful & Unsuccessful Democracy, IY
*=============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/sucM/olsBef"
forv suc=1/4{	
	u "temp/2democracy/sucM/bef/suc`suc'",clear
	ren (aut* dem* suc* uns*) b=
	mer 1:m country yearb using "temp/2democracy/sucM/dem/suc`suc'iy",nogen
	mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
	
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
					loc dep=word("$a",`y')
					reghdfestd `dep' sucdem`x' unsdem`x' unsaut`x' bsucdem`x' bunsdem`x' bunsaut`x' [aw=weight] if age>24 , a(${fe`s'}) cl(${cl1}) version(5)
					estimates save "${saveout}/suc`suc'y`y'x`x's`s'iy",replace
			}
		}
	}
}

forv suc=1/4{
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				clear all
				estimates use "${savee}/sucM/olsBef/suc`suc'y`y'x`x's`s'iy"
				test sucdem=bsucdem
				local pvalsucdem=`r(p)'
				test unsdem=bunsdem
				local pvalunsdem=`r(p)'
				test unsaut=bunsaut
				local pvalunsaut=`r(p)'
				ereturn display
				mat t0=r(table)'
				clear
				svmat2 t0,rnames(var) names(col)
				gen pvalsucdem=`pvalsucdem'
				gen pvalunsdem=`pvalunsdem'
				gen pvalunsaut=`pvalunsaut'
				g suc=`suc'
				g y=`y'
				g x=`x'
				g s=`s'
				save "${savee}/FigBefSuciy/suc`suc'y`y'x`x's`s'iy", replace
			}
		}
	}
}

clear
forv suc=1/4{
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				append using "${savee}/FigBefSuciy/suc`suc'y`y'x`x's`s'iy.dta"
			}
		}
	}
}
sa "${savee}/FigBefSuciy",replace
shell rm -r "${savee}/FigBefSuciy"

*FIGURE
u "${savee}/FigBefSuciy",replace
drop pvalue
keep if inlist(suc,1,2,3,4)&x==1&inrange(s,1,2)
la def suc 1 "Growth" 2 "Transparency" 3 "Capacity" 4 "Redistribution"
la val suc suc
replace var=regexr(var,"[1-2]$","")
keep if regexm(var,"dem") | regexm(var,"unsaut")
strrec var ("bsucdem" "sucdem"=1 "Successful Democracy") ("bunsdem" "unsdem"=2 "Unsuccessful Democracy") ("bunsaut" "unsaut"=3 "Unsuccessful Autocracy"),g(success)
decode suc,g(t0)
decode success,g(t1)
gegen byvar=group(success suc)
replace byvar=byvar-4 if t1!="Successful Democracy"
tostring byvar,replace
levelsof byvar
foreach n in `r(levels)'{
	replace byvar=word("`c(ALPHA)'",`=real("`n'")') if byvar=="`n'"
}
replace byvar=byvar+". "+t0
replace var=regexr(var,"(suc|uns)","")
g yaxis=cond(s==2,y+0.1,y-0.1)
la def x ${xlabel}
la val x x
g diffsucdem=(pvalsucdem<0.05)
g diffunsdem=(pvalunsdem<0.05)
g diffunsaut=(pvalunsaut<0.05)
sa temp,replace

u temp if t1=="Successful Democracy",replace
tw (rcap ll ul yaxis if var=="bdem",horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc yaxis b if s==1&var=="bdem",mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==2&var=="bdem",mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==1&var=="dem"&diffsucdem==1,mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffsucdem==1,mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffsucdem==0,mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffsucdem==0,mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(byvar,xrescale note("") cols(12)) ///
subtitle(,size(*0.8) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2"4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.85) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc) labsize(*0.6)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none)) ysize(4) xsize(8)
gr export "${savef}/befsuc1iy.pdf",replace

u temp if t1!="Successful Democracy",replace
replace var="bdem" if var=="baut"
replace var="dem" if var=="aut"
tw (rcap ll ul yaxis if var=="bdem",horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc yaxis b if s==1&var=="bdem",mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==2&var=="bdem",mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==1&var=="dem"&diffunsdem==1&t1=="Unsuccessful Democracy",mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsdem==1&t1=="Unsuccessful Democracy",mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsdem==0&t1=="Unsuccessful Democracy",mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsdem==0&t1=="Unsuccessful Democracy",mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsaut==1&t1=="Unsuccessful Autocracy",mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsaut==1&t1=="Unsuccessful Autocracy",mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsaut==0&t1=="Unsuccessful Autocracy",mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsaut==0&t1=="Unsuccessful Autocracy",mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(byvar,xrescale note("") cols(12) subtitle("                                         Unsuccessful Democracy (Panels A-D)                                        Unsuccessful Autocracy (Panels E-H)",size(*0.8))) ///
subtitle(,size(*0.8) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2"4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.85) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc) labsize(*0.6)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none)) ysize(4) xsize(8)
gr export "${savef}/befsuc2iy.pdf",replace


/*==============================================================================
Figure A5 & A6: Pre-Birth Exposure to Successful & Unsuccessful Democracy, LT
*=============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/sucM/olsBef"
forv suc=1/4{	
	u "temp/2democracy/sucM/bef/suc`suc'",clear
	ren (aut* dem* suc* uns*) b=
	mer 1:m country yearb using "temp/2democracy/sucM/dem/suc`suc'lt",nogen
	mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
	
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
					loc dep=word("$a",`y')
					reghdfestd `dep' sucdem`x' unsdem`x' unsaut`x' bsucdem`x' bunsdem`x' bunsaut`x' [aw=weight], a(${fe`s'}) cl(${cl1}) version(5)
					estimates save "${saveout}/suc`suc'y`y'x`x's`s'lt",replace
			}
		}
	}
}

forv suc=1/4{
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				clear all
				estimates use "${savee}/sucM/olsBef/suc`suc'y`y'x`x's`s'lt"
				test sucdem=bsucdem
				local pvalsucdem=`r(p)'
				test unsdem=bunsdem
				local pvalunsdem=`r(p)'
				test unsaut=bunsaut
				local pvalunsaut=`r(p)'
				ereturn display
				mat t0=r(table)'
				clear
				svmat2 t0,rnames(var) names(col)
				gen pvalsucdem=`pvalsucdem'
				gen pvalunsdem=`pvalunsdem'
				gen pvalunsaut=`pvalunsaut'
				g suc=`suc'
				g y=`y'
				g x=`x'
				g s=`s'
				save "${savee}/FigBefSuclt/suc`suc'y`y'x`x's`s'lt", replace
			}
		}
	}
}

clear
forv suc=1/4{
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				append using "${savee}/FigBefSuclt/suc`suc'y`y'x`x's`s'lt.dta"
			}
		}
	}
}
sa "${savee}/FigBefSuclt",replace
shell rm -r "${savee}/FigBefSuclt"

*FIGURE
u "${savee}/FigBefSuclt",replace
drop pvalue
keep if inlist(suc,1,2,3,4)&x==1&inrange(s,1,2)
la def suc 1 "Growth" 2 "Transparency" 3 "Capacity" 4 "Redistribution"
la val suc suc
replace var=regexr(var,"[1-2]$","")
keep if regexm(var,"dem") | regexm(var,"unsaut")
strrec var ("bsucdem" "sucdem"=1 "Successful Democracy") ("bunsdem" "unsdem"=2 "Unsuccessful Democracy") ("bunsaut" "unsaut"=3 "Unsuccessful Autocracy"),g(success)
decode suc,g(t0)
decode success,g(t1)
gegen byvar=group(success suc)
replace byvar=byvar-4 if t1!="Successful Democracy"
tostring byvar,replace
levelsof byvar
foreach n in `r(levels)'{
	replace byvar=word("`c(ALPHA)'",`=real("`n'")') if byvar=="`n'"
}
replace byvar=byvar+". "+t0
replace var=regexr(var,"(suc|uns)","")
g yaxis=cond(s==2,y+0.1,y-0.1)
la def x ${xlabel}
la val x x
g diffsucdem=(pvalsucdem<0.05)
g diffunsdem=(pvalunsdem<0.05)
g diffunsaut=(pvalunsaut<0.05)
sa temp,replace

u temp if t1=="Successful Democracy",replace
tw (rcap ll ul yaxis if var=="bdem",horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc yaxis b if s==1&var=="bdem",mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==2&var=="bdem",mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==1&var=="dem"&diffsucdem==1,mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffsucdem==1,mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffsucdem==0,mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffsucdem==0,mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(byvar,xrescale note("") cols(12)) ///
subtitle(,size(*0.8) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2"4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.85) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc) labsize(*0.6)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none)) ysize(4) xsize(8)
gr export "${savef}/befsuc1lt.pdf",replace

u temp if t1!="Successful Democracy",replace
replace var="bdem" if var=="baut"
replace var="dem" if var=="aut"
tw (rcap ll ul yaxis if var=="bdem",horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc yaxis b if s==1&var=="bdem",mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==2&var=="bdem",mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==1&var=="dem"&diffunsdem==1&t1=="Unsuccessful Democracy",mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsdem==1&t1=="Unsuccessful Democracy",mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsdem==0&t1=="Unsuccessful Democracy",mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsdem==0&t1=="Unsuccessful Democracy",mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsaut==1&t1=="Unsuccessful Autocracy",mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsaut==1&t1=="Unsuccessful Autocracy",mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsaut==0&t1=="Unsuccessful Autocracy",mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsaut==0&t1=="Unsuccessful Autocracy",mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(byvar,xrescale note("") cols(12) subtitle("                                         Unsuccessful Democracy (Panels A-D)                                        Unsuccessful Autocracy (Panels E-H)",size(*0.8))) ///
subtitle(,size(*0.8) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2"4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.85) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc) labsize(*0.6)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none)) ysize(4) xsize(8)
gr export "${savef}/befsuc2lt.pdf",replace


/*==============================================================================
Figure A7: Success in Europe and Asia
*=============================================================================*/
*code to graph a comparisson between our two main regions 
use "temp/ivs", clear
keep country region
bys country (region): keep if _n==1
save "temp/ivs_region", replace

u "temp/3addVars/heM/he",replace
merge m:1 country using "temp/ivs_region", keepusing(region) 
drop if missing(region) // después revisar porqué descartamos varios países
drop _merge
keep if region == "Europe" | region == "Asia"

graph bar (mean) suc1 suc2 suc3 suc4, over(region) ///
    asyvars ///
    legend(label(1 "Growth") label(2 "Transparency") ///
           label(3 "Capacity") label(4 "Redistribution") ///
           rows(2) position(6) cols(2) size(medium)) ///
    blabel(bar, format(%4.2f)) ///
    bargap(20) ///
    ytitle("Mean Success") 
graph export "${savef}/europevsasia.pdf", replace


/*==============================================================================
Figure A8: Democracy and Well-Being
*=============================================================================*/
* Code for graphs of correlations of Democracy and the main variables  
local titles `" "Income" "Health" "Autonomy" "Satisfaction" "Happiness" "' 

local vars $a
forvalues i = 1/5{
        local var : word `i' of `vars'
        local title : word `i' of `titles'
        use "temp/ivs", clear
        keep if inrange(year, 2000, 2020)
        keep country `var'
        collapse (mean) `var', by(country)
        cap su `var'
        replace `var' = (`var' - r(min)) / (r(max) - r(min))
        preserve
        use "temp/2democracy/panelDem2", clear
        keep if inrange(year, 2000, 2020)
        keep country dem
        collapse (mean) dem, by(country)
        tempfile dem
        save `dem'
        restore
        merge 1:1 country using `dem', nogen keep(3)
        scatter dem `var' ///
        || lfit dem `var', lcolor(maroon) lwidth(thick) ///
        plotregion(style(none)) ///
        ytitle("Democracy Index 2000-2020") ///
        xtitle("`title' 2000-2020") ///
        graphregion(color(white)) legend(off) ///
        yscale(titlegap(3)) xscale(titlegap(3))
        graph export "${savef}/correlation_`var'.pdf", replace
}


/*==============================================================================
Figure A9: Pre-Birth Exposure to Democracy and Democracy 18-25 — IV
*=============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/tot/rfBefiy"
use "temp/ivs", clear
keep if age>24
merge m:1 country yearb year using "temp/2democracy/tot/instiy.dta", keep(1 3) nogen keepus(z1dem1 z2dem2)
rename (z1dem1 z2dem2) (zdem1 zdem2)
merge m:1 country yearb using "temp/2democracy/tot/instBef", keep(1 3) nogen
forvalues s = 1/2 {
	forvalues x = 1/2 {
		forvalues y = 1/5 {
			local dep = word("${a}", `y')
			reghdfestd `dep' zdem`x' zbef`x' [aw=weight], a(${fe`s'}) cl(${cl1}) version(5)
			estimates save "${saveout}/y`y'x`x's`s'iy", replace
		}
	}
}

cap mkdir "${savee}/FigBefRFiy"
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
			clear all
			estimates use "${savee}/tot/rfBefiy/y`y'x`x's`s'iy"
			test zdem=zbef
			local pval=`r(p)'
			ereturn display
			mat t0=r(table)'
			clear
			svmat2 t0,rnames(var) names(col)
			gen pval=`pval'
			g y=`y'
			g x=`x'
			g s=`s'
			save "${savee}/FigBefRFiy/y`y'x`x's`s'iy", replace
		}
	}
}

clear
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
			append using "${savee}/FigBefRFiy/y`y'x`x's`s'iy.dta"
		}
	}
}
sa "${savee}/FigBefRFiy",replace
shell rm -r "${savee}/FigBefRFiy"

u "${savee}/FigBefRFiy",replace
drop pvalue
keep if inlist(s,1,2)
replace var=regexr(var,"[1-2]$","")
replace var=regexr(var,"^z","")
drop if var=="_cons"
keep y x s var b* ll* ul* pval
greshape wide b ll ul pval,i(y x s) j(var)
g diff=(pvaldem<0.05)
replace y=y+0.1 if s==2
replace y=y-0.1 if s==1
la def x ${xlabel}
la val x x
tw (rcap llbef ulbef y,horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc y bbef if s==1,mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*1.2)) ///
(sc y bbef if s==2,mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*1.2)) ///
(sc y bdem if s==1&diff==1,mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==2&diff==1,mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==1&diff==0,mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==2&diff==0,mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(x,note("")) ///
subtitle(,lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2"4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.8) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none))
gr export "${savef}/rfBefiy.pdf",replace


/*==============================================================================
Figure A10: Pre-Birth Exposure to Democracy and Lifetime Democracy — IV
*=============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/tot/rfBef"
use "temp/ivs", clear
merge m:1 country yearb year using "temp/2democracy/tot/instlt.dta", keep(1 3) nogen keepus(z1dem1 z2dem2)
rename (z1dem1 z2dem2) (zdem1 zdem2)
merge m:1 country yearb using "temp/2democracy/tot/instBef", keep(1 3) nogen
forvalues s = 1/2 {
	forvalues x = 1/2 {
		forvalues y = 1/5 {
			local dep = word("${a}", `y')
			reghdfestd `dep' zdem`x' zbef`x' [aw=weight], a(${fe`s'}) cl(${cl1}) version(5)
			estimates save "${saveout}/y`y'x`x's`s'", replace
		}
	}
}

cap mkdir "${savee}/FigBefRF"
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
			clear all
			estimates use "${savee}/tot/rfBef/y`y'x`x's`s'"
			test zdem=zbef
			local pval=`r(p)'
			ereturn display
			mat t0=r(table)'
			clear
			svmat2 t0,rnames(var) names(col)
			gen pval=`pval'
			g y=`y'
			g x=`x'
			g s=`s'
			save "${savee}/FigBefRF/y`y'x`x's`s'", replace
		}
	}
}


clear
forv s=1/2{
	forv x=1/2{
		forv y=1/5{
			append using "${savee}/FigBefRF/y`y'x`x's`s'.dta"
		}
	}
}
sa "${savee}/FigBefRF",replace
shell rm -r "${savee}/FigBefRF"

u "${savee}/FigBefRF",replace
drop pvalue
keep if inlist(s,1,2)
replace var=regexr(var,"[1-2]$","")
replace var=regexr(var,"^z","")
drop if var=="_cons"
keep y x s var b* ll* ul* pval
greshape wide b ll ul pval,i(y x s) j(var)
g diff=(pvaldem<0.05)
replace y=y+0.1 if s==2
replace y=y-0.1 if s==1
la def x ${xlabel}
la val x x
tw (rcap llbef ulbef y,horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc y bbef if s==1,mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*1.2)) ///
(sc y bbef if s==2,mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*1.2)) ///
(sc y bdem if s==1&diff==1,mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==2&diff==1,mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==1&diff==0,mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc y bdem if s==2&diff==0,mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(x,note("")) ///
subtitle(,lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2"4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.8) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none))
gr export "${savef}/rfBef.pdf",replace



/*==============================================================================
ONLINE APPENDIX FIGURES
*=============================================================================*/
/*==============================================================================
Figure O1 & O2: Pre-Birth Exposure to Successful & Unsuccessful Democracy, IV IY
==============================================================================*/
do "${code}/utils/reghdfestd.ado"

gl saveout "${savee}/sucM/rfBefiy"
forv suc=1/4{
	u "temp/2democracy/sucM/instBef/suc`suc'",clear
	ren (aut* dem* suc* uns*) zb=
	mer 1:m country yearb using "temp/2democracy/sucM/inst/suc`suc'iy",nogen
	ren (aut* dem* suc* uns*) z=
	mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
	keep if age>24
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				loc dep=word("${a}",`y')
				reghdfestd `dep' zsucdem`x' zunsdem`x' zunsaut`x' zbsucdem`x' zbunsdem`x' zbunsaut`x' [aw=weight], a(${fe`s'}) cl(${cl1}) version(5)
				estimates save "${saveout}/suc`suc'y`y'x`x's`s'iy",replace
			}
		}
	}
}

cap mkdir "${savee}/FigBefRFSuciy"
forv suc=1/4{
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				clear all
				estimates use "${savee}/sucM/rfBefiy/suc`suc'y`y'x`x's`s'iy"
				test zsucdem=zbsucdem
				local pvalsucdem=`r(p)'
				test zunsdem=zbunsdem
				local pvalunsdem=`r(p)'
				test zunsaut=zbunsaut
				local pvalunsaut=`r(p)'
				ereturn display
				mat t0=r(table)'
				clear
				svmat2 t0,rnames(var) names(col)
				gen pvalsucdem=`pvalsucdem'
				gen pvalunsdem=`pvalunsdem'
				gen pvalunsaut=`pvalunsaut'
				g suc=`suc'
				g y=`y'
				g x=`x'
				g s=`s'
				save "${savee}/FigBefRFSuciy/suc`suc'y`y'x`x's`s'iy", replace
			}
		}
	}
}

clear
forv suc=1/4{
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				append using "${savee}/FigBefRFSuciy/suc`suc'y`y'x`x's`s'iy.dta"
			}
		}
	}
}
sa "${savee}/FigBefRFSuciy",replace
shell rm -r "${savee}/FigBefRFSuciy"

u "${savee}/FigBefRFSuciy",replace
keep if inlist(suc,1,2,3,4)&x==1&inrange(s,1,2)
la def suc 1 "Growth" 2 "Transparency" 3 "Capacity" 4 "Redistribution"
la val suc suc
replace var=regexr(var,"[1-2]$","")
replace var=regexr(var,"^z","")
keep if regexm(var,"dem") | regexm(var,"unsaut")
strrec var ("bsucdem" "sucdem"=1 "Successful Democracy") ("bunsdem" "unsdem"=2 "Unsuccessful Democracy") ("bunsaut" "unsaut"=3 "Unsuccessful Autocracy"),g(success)
decode suc,g(t0)
decode success,g(t1)
gegen byvar=group(success suc)
replace byvar=byvar-4 if t1!="Successful Democracy"
tostring byvar,replace
levelsof byvar
foreach n in `r(levels)'{
	replace byvar=word("`c(ALPHA)'",`=real("`n'")') if byvar=="`n'"
}
replace byvar=byvar+". "+t0
replace var=regexr(var,"(suc|uns)","")
g yaxis=cond(s==2,y+0.1,y-0.1)
la def x ${xlabel}
la val x x
g diffsucdem=(pvalsucdem<0.05)
g diffunsdem=(pvalunsdem<0.05)
g diffunsaut=(pvalunsaut<0.05)
sa temp,replace

u temp if t1=="Successful Democracy",replace
tw (rcap ll ul yaxis if var=="bdem",horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc yaxis b if s==1&var=="bdem",mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==2&var=="bdem",mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==1&var=="dem"&diffsucdem==1,mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffsucdem==1,mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffsucdem==0,mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffsucdem==0,mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(byvar,xrescale note("") cols(12)) ///
subtitle(,size(*0.8) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2"4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.85) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc) labsize(*0.6)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none)) ysize(4) xsize(8)
gr export "${savef}/rfBefSuc1iy.pdf",replace

u temp if t1!="Successful Democracy",replace
replace var="bdem" if var=="baut"
replace var="dem" if var=="aut"
tw (rcap ll ul yaxis if var=="bdem",horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc yaxis b if s==1&var=="bdem",mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==2&var=="bdem",mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==1&var=="dem"&diffunsdem==1&t1=="Unsuccessful Democracy",mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsdem==1&t1=="Unsuccessful Democracy",mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsdem==0&t1=="Unsuccessful Democracy",mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsdem==0&t1=="Unsuccessful Democracy",mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsaut==1&t1=="Unsuccessful Autocracy",mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsaut==1&t1=="Unsuccessful Autocracy",mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsaut==0&t1=="Unsuccessful Autocracy",mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsaut==0&t1=="Unsuccessful Autocracy",mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(byvar,xrescale note("") cols(12) subtitle("                                         Unsuccessful Democracy (Panels A-D)                                        Unsuccessful Autocracy (Panels E-H)",size(*0.8))) ///
subtitle(,size(*0.8) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2" 4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.85) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc) labsize(*0.6)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none)) ysize(4) xsize(8)
gr export "${savef}/rfBefSuc2iy.pdf",replace


/*==============================================================================
Figure O3 & O4: Pre-Birth Exposure to Successful & Unsuccessful Democracy, IV LT
==============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/sucM/rfBef"
forv suc=1/4{
	u "temp/2democracy/sucM/instBef/suc`suc'",clear
	ren (aut* dem* suc* uns*) zb=
	mer 1:m country yearb using "temp/2democracy/sucM/inst/suc`suc'",nogen
	ren (aut* dem* suc* uns*) z=
	mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				loc dep=word("${a}",`y')
				reghdfestd `dep' zsucdem`x' zunsdem`x' zunsaut`x' zbsucdem`x' zbunsdem`x' zbunsaut`x' [aw=weight], a(${fe`s'}) cl(${cl1}) version(5)
				estimates save "${saveout}/suc`suc'y`y'x`x's`s'",replace
			}
		}
	}
}

cap mkdir "${savee}/FigBefRFSuc"
forv suc=1/4{
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				clear all
				estimates use "${savee}/sucM/rfBef/suc`suc'y`y'x`x's`s'"
				test zsucdem=zbsucdem
				local pvalsucdem=`r(p)'
				test zunsdem=zbunsdem
				local pvalunsdem=`r(p)'
				test zunsaut=zbunsaut
				local pvalunsaut=`r(p)'
				ereturn display
				mat t0=r(table)'
				clear
				svmat2 t0,rnames(var) names(col)
				gen pvalsucdem=`pvalsucdem'
				gen pvalunsdem=`pvalunsdem'
				gen pvalunsaut=`pvalunsaut'
				g suc=`suc'
				g y=`y'
				g x=`x'
				g s=`s'
				save "${savee}/FigBefRFSuc/suc`suc'y`y'x`x's`s'", replace
			}
		}
	}
}

clear
forv suc=1/4{
	forv s=1/2{
		forv x=1/1{
			forv y=1/5{
				append using "${savee}/FigBefRFSuc/suc`suc'y`y'x`x's`s'.dta"
			}
		}
	}
}
sa "${savee}/FigBefRFSuc",replace
shell rm -r "${savee}/FigBefRFSuc"

u "${savee}/FigBefRFSuc",replace
keep if inlist(suc,1,2,3,4)&x==1&inrange(s,1,2)
la def suc 1 "Growth" 2 "Transparency" 3 "Capacity" 4 "Redistribution"
la val suc suc
replace var=regexr(var,"[1-2]$","")
replace var=regexr(var,"^z","")
keep if regexm(var,"dem") | regexm(var,"unsaut")
strrec var ("bsucdem" "sucdem"=1 "Successful Democracy") ("bunsdem" "unsdem"=2 "Unsuccessful Democracy") ("bunsaut" "unsaut"=3 "Unsuccessful Autocracy"),g(success)
decode suc,g(t0)
decode success,g(t1)
gegen byvar=group(success suc)
replace byvar=byvar-4 if t1!="Successful Democracy"
tostring byvar,replace
levelsof byvar
foreach n in `r(levels)'{
	replace byvar=word("`c(ALPHA)'",`=real("`n'")') if byvar=="`n'"
}
replace byvar=byvar+". "+t0
replace var=regexr(var,"(suc|uns)","")
g yaxis=cond(s==2,y+0.1,y-0.1)
la def x ${xlabel}
la val x x
g diffsucdem=(pvalsucdem<0.05)
g diffunsdem=(pvalunsdem<0.05)
g diffunsaut=(pvalunsaut<0.05)
sa temp,replace

u temp if t1=="Successful Democracy",replace
tw (rcap ll ul yaxis if var=="bdem",horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc yaxis b if s==1&var=="bdem",mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==2&var=="bdem",mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==1&var=="dem"&diffsucdem==1,mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffsucdem==1,mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffsucdem==0,mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffsucdem==0,mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(byvar,xrescale note("") cols(12)) ///
subtitle(,size(*0.8) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2" 4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.85) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc) labsize(*0.6)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none)) ysize(4) xsize(8)
gr export "${savef}/rfBefSuc1.pdf",replace

u temp if t1!="Successful Democracy",replace
replace var="bdem" if var=="baut"
replace var="dem" if var=="aut"
tw (rcap ll ul yaxis if var=="bdem",horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc yaxis b if s==1&var=="bdem",mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==2&var=="bdem",mcolor(navy) msymbol(triangle) mlabsize(*1) msize(*0.8)) ///
(sc yaxis b if s==1&var=="dem"&diffunsdem==1&t1=="Unsuccessful Democracy",mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsdem==1&t1=="Unsuccessful Democracy",mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsdem==0&t1=="Unsuccessful Democracy",mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsdem==0&t1=="Unsuccessful Democracy",mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsaut==1&t1=="Unsuccessful Autocracy",mcolor(black) msymbol(circle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsaut==1&t1=="Unsuccessful Autocracy",mcolor(black) msymbol(triangle) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==1&var=="dem"&diffunsaut==0&t1=="Unsuccessful Autocracy",mcolor(black%50) msymbol(circle_hollow) mlabsize(*1) msize(*1)) ///
(sc yaxis b if s==2&var=="dem"&diffunsaut==0&t1=="Unsuccessful Autocracy",mcolor(black%50) msymbol(triangle_hollow) mlabsize(*1) msize(*1)) ///
, by(byvar,xrescale note("") cols(12) subtitle("                                         Unsuccessful Democracy (Panels A-D)                                        Unsuccessful Autocracy (Panels E-H)",size(*0.8))) ///
subtitle(,size(*0.8) lcolor(none)) ///
legend(order(2 "Pre-birth Exposure, Specification 1" 3 "Pre-birth Exposure, Specification 2"4 "Exposure, Specification 1 ({&ne}Pre-Birth Exp.)" 5 "Exposure, Specification 2 ({&ne}Pre-Birth Exp.)" 6 "Exposure, Specification 1 (=Pre-Birth Exp.)" 7 "Exposure, Specification 2 (=Pre-Birth Exp.)") size(*0.85) rows(3) region(lcolor(none))) ///
xline(0,lcolor(gs1)) ylabel(${ylabel},value angle(h) grid labsize(*1)) ///
xlabel(,format(%10.2fc) labsize(*0.6)) ///
ytitle("") xtitle("") ///
yscale(range(0 5) reverse) plotregion(style(none)) ysize(4) xsize(8)
gr export "${savef}/rfBefSuc2.pdf",replace


/*==============================================================================
Figure O5: Lifetime Exposure to Democracy and Placebo Variables — IV IY
*=============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/tot/rfPlaiy"
cap estimates clear
local files: dir "${savee}/tot/rfPlaiy" files "*"
foreach f of local files {
    cap erase "${savee}/tot/rfPlaiy/`f'"
}
use "temp/ivs", clear
keep if age>24
merge 1:1 svyid using "temp/1survey/placebo", nogen keep(1 3)
merge m:1 country yearb year using "temp/2democracy/tot/instiy.dta", keep(1 3) nogen keepus(z1dem1 z2dem2)
rename (z1dem1 z2dem2) (zdem1 zdem2)
forvalues s = 1/1 {
	forvalues x = 1/2 {
		forvalues y = 1/${placeboN} {
			local dep = word("${placebo}", `y')
			reghdfestd `dep' zdem`x' [aw=weight], a(${fepla}) cl(${cl1}) version(5)
				estimates save "${saveout}/y`y'x`x's`s'iy", replace
		}
	}
}
clear
cap frame drop temp
frame create temp
foreach e in rfPlaiy { 
	noi di "processing files in folder `e'"
	loc files:dir "${savee}/tot/`e'" files "*.ster"
	foreach f of local files {
		qui frame temp {
			estimates use "${savee}/tot/`e'/`f'"
			ereturn display
			mat t0=r(table)'
			clear
			svmat2 t0,rnames(var) names(col)
			g file="`f'"
			g type="`e'"
			sa "temp",replace
		}
		qui append using "temp"
	}
}
drop eform
loc vc=0
foreach v in y x s {
	loc ++vc
	g `v'=real(regexs(`vc')) if regexm(file,"y([0-9][0-9]?)x([0-9])s([0-9])")
}
g fs=regexm(file,"Fs.ster$")
drop file
order type y x s fs var
so type y x s fs var
compress
sa "${savee}/rftotiy",replace

u "${savee}/rftotiy",replace
keep if type=="rfPlaiy"
replace var=regexr(var,"[1-2]$","")
keep if inlist(s,1)
drop if var=="_cons"
keep y x s b* ll* ul*
la def x ${xlabel}
la val x x
g ulc=min(0.3,ul)
g llc=max(-0.3,ll)
g ulcapped=ulc!=ul
g llcapped=llc!=ll
drop if s==2
tw (rspike llc ulc y,horizontal lcolor(gs1) lwidth(*0.5)) ///
(rcap ulc ulc y if ulcapped==0,horizontal lcolor(gs1) lwidth(*0.5)) ///
(rcap llc llc y if llcapped==0,horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc y b if s==1,mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*1)) ///
, by(x,note("") legend(off)) ///
subtitle(,lcolor(none)) ///
legend(off) ///
xline(0,lcolor(gs1)) ylabel(${placebolabel},value angle(h) grid labsize(*1)) ///
xlabel(-0.3(0.1)0.3,format(%10.1fc)) ///
ytitle("") xtitle("") ///
 yscale(reverse) plotregion(style(none))
gr export "${savef}/rfPlaiy.pdf",replace


/*==============================================================================
Figure O6: Lifetime Exposure to Democracy and Placebo Variables — IV LT
*=============================================================================*/
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/tot/rfPla"
cap estimates clear
local files: dir "${savee}/tot/rfPla" files "*"
foreach f of local files {
    cap erase "${savee}/tot/rfPla/`f'"
}
use "temp/ivs", clear
merge 1:1 svyid using "temp/1survey/placebo", nogen keep(1 3)
merge m:1 country yearb year using "temp/2democracy/tot/instlt.dta", keep(1 3) nogen keepus(z1dem1 z2dem2)
rename (z1dem1 z2dem2) (zdem1 zdem2)
forvalues s = 1/1 {
	forvalues x = 1/2 {
		forvalues y = 1/${placeboN} {
			local dep = word("${placebo}", `y')
			reghdfestd `dep' zdem`x' [aw=weight], a(${fepla}) cl(${cl1}) version(5)
				estimates save "${saveout}/y`y'x`x's`s'", replace
		}
	}
}
clear
cap frame drop temp
frame create temp
foreach e in rfPla { 
	noi di "processing files in folder `e'"
	loc files:dir "${savee}/tot/`e'" files "*.ster"
	foreach f of local files {
		qui frame temp {
			estimates use "${savee}/tot/`e'/`f'"
			ereturn display
			mat t0=r(table)'
			clear
			svmat2 t0,rnames(var) names(col)
			g file="`f'"
			g type="`e'"
			sa "temp",replace
		}
		qui append using "temp"
	}
}
drop eform
loc vc=0
foreach v in y x s {
	loc ++vc
	g `v'=real(regexs(`vc')) if regexm(file,"y([0-9][0-9]?)x([0-9])s([0-9])")
}
g fs=regexm(file,"Fs.ster$")
drop file
order type y x s fs var
so type y x s fs var
compress
sa "${savee}/rftot",replace

u "${savee}/rftot",replace
keep if type=="rfPla"
replace var=regexr(var,"[1-2]$","")
keep if inlist(s,1)
drop if var=="_cons"
keep y x s b* ll* ul*
la def x ${xlabel}
la val x x
g ulc=min(0.3,ul)
g llc=max(-0.3,ll)
g ulcapped=ulc!=ul
g llcapped=llc!=ll
drop if s==2
tw (rspike llc ulc y,horizontal lcolor(gs1) lwidth(*0.5)) ///
(rcap ulc ulc y if ulcapped==0,horizontal lcolor(gs1) lwidth(*0.5)) ///
(rcap llc llc y if llcapped==0,horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc y b if s==1,mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*1)) ///
, by(x,note("") legend(off)) ///
subtitle(,lcolor(none)) ///
legend(off) ///
xline(0,lcolor(gs1)) ylabel(${placebolabel},value angle(h) grid labsize(*1)) ///
xlabel(-0.3(0.1)0.3,format(%10.1fc)) ///
ytitle("") xtitle("") ///
 yscale(reverse) plotregion(style(none))
gr export "${savef}/rfPla.pdf",replace


/*==============================================================================
Figure O7, O8, O9, O10 & O11: Binned Scatterplots of Democracy and Well-Being
*=============================================================================*/
/*------------------------------------------------------------------------------
*TOT
*-----------------------------------------------------------------------------*/
gl bins=15
clear
forv s=1/1{
	forv x=1/2{
		forv y=1/5{
			loc dep=word("${a}",`y')
			preserve
			di as input `"s=>`s'. x=>`x'. dep=>`y'."'
			u "temp/ivs",clear
			ren demlt`x' dem
			ren `dep' dep
			marktouse touse ${fe`s'} country year dem dep
			egen depstd=std(dep)  if touse==1
			egen demstd=std(dem) if touse==1
			reghdfe depstd [aw=weight],cl(${cl1}) a(${fe`s'},save) nocon resid
			keep if e(sample)
			predict double depstdhat,residuals
			reghdfe demstd [aw=weight],cl(${cl1}) a(${fe`s'},save) nocon resid
			keep if e(sample)
			predict double demstdhat,residuals
			xtile xtile=demstdhat,n(${bins})
			gcollapse (mean) dep depstd depstdhat dem demstd demstdhat [aw=weight],by(xtile)
			g y=`y'
			g s=`s'
			g x=`x'
			sa "temp",replace
			restore
			append using "temp"
		}
	}
}
la def y ${ylabel}
la def x ${xlabel}
la val x x
la val y y
order s x y xtile
so s x y xtile
compress
sa "${savee}/tot/others/scatterplot.dta",replace

u "${savee}/tot/others/scatterplot.dta",replace
la def y ${ylabel},replace
g name="Democracy - Dichotomous" if x==1
replace name="Democracy - Continuous" if x==2
forv s=1/1{
forv x=1/2{
forv y=1/5{
	tw (sc depstdhat demstdhat,msymbol(circle) mcolor(gs10)) ///
	(lfit depstdhat demstdhat,lcolor(gs1) lwidth(*1.5)) ///
	if s==`s'&y==`y'&x==`x', ///
	by(name,iscale(*1.5) yrescale xrescale note("") legend(off)) ///
	subtitle(, size(*1.2) lcolor(none)) ///
	xlabel(,format(%4.1fc)) ylabel(,angle(h) format(%4.2fc)) ytitle("") ///
	xscale(range(0 100)) xtitle("") plotregion(style(none))
	gr export "${savef}/scattery`y'x`x's`s'v2.pdf",replace
}
}
}

/*------------------------------------------------------------------------------
*SUC
------------------------------------------------------------------------------*/
clear
forv suc=1/4{
	forv s=1/1{
	forv x=1/1{
		forv y=1/5{
			loc dep=word("${a}",`y')
			preserve
			di as input `"s=>`s'. x=>`x'. dep=>`y'."'
			u "temp/2democracy/sucM/dem/suc`suc'lt",clear
			mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
			ren sucdem`x' dem
			ren `dep' dep
			marktouse touse ${fe`s'} country year dem dep
			egen depstd=std(dep)  if touse==1
			egen demstd=std(dem) if touse==1
			reghdfe depstd [aw=weight],cl(${cl1}) a(${fe`s'},save) nocon resid
			keep if e(sample)
			predict double depstdhat,residuals
			reghdfe demstd [aw=weight],cl(${cl1}) a(${fe`s'},save) nocon resid
			keep if e(sample)
			predict double demstdhat,residuals
			xtile xtile=demstdhat,n(${bins})
			gcollapse (mean) dep depstd depstdhat dem demstd demstdhat [aw=weight],by(xtile)
			g y=`y'
			g s=`s'
			g x=`x'
			sa "temp",replace
			restore
			append using "temp"
			}
		}
	}
	cap la def y ${ylabel}
	cap la def x ${xlabel}
	la val x x
	la val y y
	order s x y xtile
	so s x y xtile
	compress
	sa "${savee}/sucM/others/scatterplotsuc`suc'.dta",replace	
}

clear
forv suc=1/4{
	u "${savee}/sucM/others/scatterplotsuc`suc'.dta",replace
	la def y ${ylabel},replace
	if `suc'==1{
		g name="Growth" 
	}
	else if `suc'==2{
	g name="Transparency"
	}
	else if `suc'==3{
	g name="Peace"
	}
	else if `suc'==4{
	g name="Capacity"
	}
	
	forv s=1/1{
	forv x=1/1{
	forv y=1/5{
		tw (sc depstdhat demstdhat,msymbol(circle) mcolor(gs10)) ///
		(lfit depstdhat demstdhat,lcolor(gs1) lwidth(*1.5)) ///
		if s==`s'&y==`y'&x==`x', ///
		by(name,iscale(*1.5) yrescale xrescale note("") legend(off)) ///
		subtitle(, size(*1.2) lcolor(none)) ///
		xlabel(,format(%4.1fc)) ylabel(,angle(h) format(%4.2fc)) ytitle("") ///
		xtitle("Exposure to Democracy") xscale(range(0 100)) xtitle("") plotregion(style(none))
		gr export "${savef}/scattery`y'x`x's`s'suc`suc'v2.pdf",replace
	}
	}
	}
}


/*==============================================================================
Figure O12 & O13: Quantile Effects of Democracy on Well-Being
*=============================================================================*/
*IY
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/tot/olsQuantileiy"
* ESTIMATES
use "temp/ivs", clear
keep if age>24
forvalues x=2/2{
	xtile t0`x' = demiy`x', n(10)
	tab t0`x', gen(decile`x'_)
	forvalues s=1/1{
		forvalues c=1/1{
			foreach y in $a {
				reghdfestd `y' decile2_2-decile2_10 [aw=weight], a(${fe`s'}) cl(${cl`c'}) version(5)
				estimates save "${saveout}/`y'x`x's`s'c`c'iy", replace
			}
		}
	}
}
* FIGURES
clear
cap frame drop temp
frame create temp
local files : dir "${saveout}" files "*.ster"
foreach f of local files{
	qui frame temp{
		estimates use "${saveout}/`f'"
		ereturn display
		mat t0 = r(table)'
		clear
		svmat2 t0, rnames(var) names(col)
		gen file = "`f'"
		save "temp", replace
	}
	qui append using "temp"
}
drop if var == "_cons"
foreach y in $a {
	preserve
	keep if strpos(file, "`y'") > 0
	gen decile = _n + 1
	twoway (rcap ll ul decile, lcolor(maroon) lwidth(*1.5)) ///
		   (scatter b decile, msymbol(circle) mcolor(gs4) msize(*1.5)), ///
		   xtitle("") ytitle("") legend(off) xlabel(2(1)10) ///
		   yline(0, lpattern(dash))
	graph export "${savef}/deciles`y'iy.pdf", replace
	restore
}

*LT
do "${code}/utils/reghdfestd.ado"
gl saveout "${savee}/tot/olsQuantile"
* ESTIMATES
use "temp/ivs", clear
forvalues x=2/2{
	xtile t0`x' = demlt`x', n(10)
	tab t0`x', gen(decile`x'_)
	forvalues s=1/1{
		forvalues c=1/1{
			foreach y in $a {
				reghdfestd `y' decile2_2-decile2_10 [aw=weight], a(${fe`s'}) cl(${cl`c'}) version(5)
				estimates save "${saveout}/`y'x`x's`s'c`c'lt", replace
			}
		}
	}
}
* FIGURES
clear
cap frame drop temp
frame create temp
local files : dir "${saveout}" files "*.ster"
foreach f of local files{
	qui frame temp{
		estimates use "${saveout}/`f'"
		ereturn display
		mat t0 = r(table)'
		clear
		svmat2 t0, rnames(var) names(col)
		gen file = "`f'"
		save "temp", replace
	}
	qui append using "temp"
}
drop if var == "_cons"
foreach y in $a {
	preserve
	keep if strpos(file, "`y'") > 0
	gen decile = _n + 1
	twoway (rcap ll ul decile, lcolor(maroon) lwidth(*1.5)) ///
		   (scatter b decile, msymbol(circle) mcolor(gs4) msize(*1.5)), ///
		   xtitle("") ytitle("") legend(off) xlabel(2(1)10) ///
		   yline(0, lpattern(dash))
	graph export "${savef}/deciles`y'lt.pdf", replace
	restore
}


/*==============================================================================
Figure O14 & O15: Results by 18-25 Democratic Exposure 
*=============================================================================*/
*IY
local titles `" "Income" "Health" "Autonomy" "Satisfaction" "Happiness" "' 
local vars $a
forvalues i = 1/5{
  local var : word `i' of `vars'
  local title : word `i' of `titles'
  use "temp/ivs", clear
  keep if age>24
  gen demiy2_bin = floor(demiy2/4)*4  
  collapse (mean) `var' [aw=weight], by(demiy2_bin)
  twoway connected `var' demiy2_bin, ///
      msymbol(o) lcolor(green) ///
      ytitle("`title'") ///
      xtitle("Exposure to Democracy 18-25")
  graph export "${savef}/binsy`var'x2iy.pdf", replace
}

*LT
local titles `" "Income" "Health" "Autonomy" "Satisfaction" "Happiness" "' 
local vars $a
forvalues i = 1/5{
  local var : word `i' of `vars'
  local title : word `i' of `titles'
  use "temp/ivs", clear
  keep if demlt2<71
  gen demlt2_bin = floor(demlt2/4)*4  
  collapse (mean) `var' [aw=weight], by(demlt2_bin)
  twoway connected `var' demlt2_bin, ///
      msymbol(o) lcolor(green) ///
      ytitle("`title'") ///
      xtitle("Exposure to Democracy")
  graph export "${savef}/binsy`var'x2.pdf", replace
}


/*==============================================================================
Figure O16: Placebo Variables Lifetime
*=============================================================================*/
gl saveout "${savee}/tot/olsPlaLT"
do "${code}/utils/reghdfestd.ado"
cap estimates clear
local files: dir "${savee}/tot/olsPlaLT" files "*"
foreach f of local files {
    cap erase "${savee}/tot/olsPlaLT/`f'"
}
u "temp/ivs",replace
mer 1:1 svyid using "temp/1survey/placebo",nogen keep(1 3)
forv s=1/1{
	forv x=1/2{
		forv y=1/${placeboN} {
					loc dep=word("${placebo}",`y')
					reghdfestd `dep' demlt`x' [aw=weight], a(${fepla}) cl(${cl1}) version(5)
					estimates save "${saveout}/y`y'x`x's`s'.ster",replace
		}
	}
}
clear
cap frame drop temp
frame create temp
foreach e in olsPlaLT{ 
	noi di "processing files in folder `e'"
	loc files:dir "${savee}/tot/`e'" files "*.ster"
	foreach f of local files {
		qui frame temp {
			estimates use "${savee}/tot/`e'/`f'"
			ereturn display
			mat t0=r(table)'
			clear
			svmat2 t0,rnames(var) names(col)
			g file="`f'"
			g type="`e'"
			sa "temp",replace
		}
		qui append using "temp"
	}
}
drop eform
loc vc=0
foreach v in y x s {
	loc ++vc
	g `v'=real(regexs(`vc')) if regexm(file,"y([0-9][0-9]?)x([0-9])s([0-9])")
}
g fs=regexm(file,"Fs.ster$")
drop file
order type y x s fs var
so type y x s fs var
compress
sa "${savee}/totlt",replace

*FIGURE
u "${savee}/totlt",replace
keep if type=="olsPlaLT"
replace var=regexr(var,"[1-2]$","")
keep if inlist(s,1)
drop if var=="_cons"
keep y x s b* ll* ul*
la def x ${xlabel}
la val x x
g ulc=min(0.3,ul)
g llc=max(-0.3,ll)
g ulcapped=ulc!=ul
g llcapped=llc!=ll
tw (rspike llc ulc y,horizontal lcolor(gs1) lwidth(*0.5)) ///
(rcap ulc ulc y if ulcapped==0,horizontal lcolor(gs1) lwidth(*0.5)) ///
(rcap llc llc y if llcapped==0,horizontal lcolor(gs1) lwidth(*0.5)) ///
(sc y b if s==1,mcolor(maroon) msymbol(circle) mlabsize(*1) msize(*1)) ///
, by(x,note("") legend(off)) ///
subtitle(,size(*1) lcolor(none)) ///
legend(off) ///
xline(0,lcolor(gs1)) ylabel(${placebolabel},value angle(h) grid labsize(*1)) ///
xlabel(-0.3(0.1)0.3,format(%10.1fc)) ///
ytitle("") xtitle("") ///
 yscale(reverse) plotregion(style(none))
gr export "${savef}/plalt.pdf",replace