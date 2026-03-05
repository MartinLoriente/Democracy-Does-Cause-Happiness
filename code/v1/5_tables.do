/*==============================================================================
// MAIN TABLES

Table 1: Exposure to Democracy and Well-Being. IY & LT Democracy
Table 2 & 3: The Timing of Democracy’s Imprint on Well-Being. Horse Races
Table 4: Persistence of Impressionable Years Exposure
Table 5 & 6: Exposure to Successful Democracy. IY & LT (Interactions)

// APPENDIX TABLES

Table A1, A2 & A3: Summary Statistics, and Survey Respondents by Region
Table A4: Exposure to Democracy 18-25 — Diverse Fixed Effects 
Table A5: Exposure to Democracy 18-25 — Diverse Clusters
Table A6: Lifetime Exposure to Democracy — Capping Exposure to Democracy at 40
Table A7: Exposure to Democracy 18–25 — Leave-One-Out and Europe-Only 
Table A8: Lifetime Exposure to Democracy — Leave-One-Out and Europe-Only 
Table A9: Exposure to Democracy 18-25 — Heterogeneities
Table A10, A11, A12 & A13: Exposure to Democracy 18-25 — Alternative Mechanisms
Table A14: 2SLS Estimation 18-25 — First-Stage Regression
Table A15: IV Exposure to Democracy 18-25
Table A16: 2SLS Estimation Lifetime — First-Stage Regression
Table A17: IV Lifetime Exposure to Democracy
Table A18: Exposure to Democracy — Event-specific Estimates (WOOLRIDGE)
Table A19: Exposure to Democracy and Well-Being — ESS Sample
Table A20: Exposure to Democracy and Well-Being — Immigrants

// ONLINE APPENDIX TABLES

Table O1: Lifetime Exposure to Democracy, Diverse Fixed Effects
Table O2: Lifetime Exposure to Democracy, Diverse Clusters
Table O3: Lifetime Exposure to Democracy — Different Exposure Cuts (Continuous)
Table O4: Lifetime Exposure to Democracy — Different Exposure Cuts (Dichotomous)
Table O5: Alternative Sample Construction
Table O6 & O7: Heterogeneity IY & LT (Dichotomous)
Table O8, O9 & O10: Exposure to Successful Democracy. IY (Dichotomous) & LT
Table O11 & O12: Exposure to Democracy, Leave one Out. IY & LT (Dichotomous)
Table O13 & O14: Impressionable Years Exposure, Different Time Windows 
Table O15: Exposure to Democracy 18-25, Alternative Variables

// SOME USEFUL NUMBERS
==============================================================================*/
/**/

do "${code}/utils/reghdfestd.ado"
do "${code}/utils/droptabular.ado"
do "${code}/utils/descstatistics.ado"

/*==============================================================================
MAIN TABLES
*=============================================================================*/
/*==============================================================================
Table 1: Exposure to Democracy and Well-Being. IY & LT Democracy
*=============================================================================*/
** IY DEMOCRACY **
*ESTIMATES
gl saveout "${savee}/tot/olsMainIY"
u "temp/ivs",replace
forv x=1/2{
	foreach y in $a {
		reghdfestd `y' demiy`x' [aw=weight] if age>24 , a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1iy",replace
	}
}

*TABLE: IY DEMOCRACY
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/olsMainIY/y`y'x`x's1c1iy.ster"
		outreg,${opt} merge(x`x's1c1iy) drop(_cons)
		}
	outreg using "${savet}/x`x's1c1iy.tex", replay(x`x's1c1iy) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/x`x's1c1iy.tex", spaceb("^Mean")
}

** LT DEMOCRACY **
*ESTIMATES
gl saveout "${savee}/tot/olsMainLT"
u "temp/ivs",replace
forv x=1/2{
	foreach y in $a {
		reghdfestd `y' demlt`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1lt",replace
	}
}

*TABLE: LIFETIME DEMOCRACY
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/olsMainLT/y`y'x`x's1c1lt.ster"
		outreg,${opt} merge(x`x's1c1lt) drop(_cons)
		}
	outreg using "${savet}/x`x's1c1lt.tex", replay(x`x's1c1lt) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/x`x's1c1lt.tex", spaceb("^Mean")
}


/*==============================================================================
Table 2 & 3: The Timing of Democracy’s Imprint on Well-Being. Horse Races
*=============================================================================*/
*ESTIMATES AND TABLE: Long version
u "temp/ivs",replace
mer m:1 country year yearb using "temp/2democracy/tot/demAge",keepus(dem1* dem2*) keep(1 3) nogen
forv s=1/1{
	forv c=1/1{ 
		forv x=2/2{
			mata:mata clear 
			foreach y in $a {
			eststo clear
			eststo: reghdfestd `y' demiy`x' 			[aw=weight] if age>24  , a(${fe`s'}) cl(${cl`c'}) version(5)
			eststo: reghdfestd `y' demiy`x' dem`x'g1	[aw=weight] if age>24  , a(${fe`s'}) cl(${cl`c'}) version(5)
			eststo: reghdfestd `y' demiy`x' dem`x'g2	[aw=weight] if age>24  , a(${fe`s'}) cl(${cl`c'}) version(5)
			eststo: reghdfestd `y' demiy`x' dem`x'g4	[aw=weight] if age>32  , a(${fe`s'}) cl(${cl`c'}) version(5)
			eststo: reghdfestd `y' demiy`x' dem`x'g5	[aw=weight] if age>40  , a(${fe`s'}) cl(${cl`c'}) version(5)
			eststo: reghdfestd `y' demiy`x' dem`x'g6	[aw=weight] if age>24  , a(${fe`s'}) cl(${cl`c'}) version(5)
			esttab , se r2 starlevels(* 0.10 ** 0.05 *** 0.01) keep(demiy`x' dem`x'g1 dem`x'g2 dem`x'g4 dem`x'g5 dem`x'g6)
			esttab using "${savet}/hrly`y'x`x's`s'c`c'.tex", replace noobs nomtitle nodepvar nonumber plain fragment label ///
			cells(b(fmt(3) star) se(par fmt(3))) ///
			order(demiy`x' dem`x'g1 dem`x'g2 dem`x'g4 dem`x'g5 dem`x'g6, relax) ///
			keep(demiy`x' dem`x'g1 dem`x'g2 dem`x'g4 dem`x'g5 dem`x'g6, relax) varwidth(30) ///
			starlevels(* 0.1 ** 0.05 *** 0.01) ///                 
			mlabels("Democracy 18-25", none) collabels(, none) ///
			substitute(_ _) style(tex) ///
			stats( N , fmt(0) labels("Number of Observations")) 
			}
		}
	}
}

*ESTIMATES AND TABLE: Short version
u "temp/ivs",replace
forv s=1/1{
	forv c=1/1{ 
		forv x=2/2{
			mata:mata clear 
			foreach y in $a {
			eststo clear
			eststo: reghdfestd `y' demiy`x' 			[aw=weight] if age>24 , a(${fe`s'}) cl(${cl`c'}) version(5)
			eststo: reghdfestd `y' demlt`x'   			[aw=weight]           , a(${fe`s'}) cl(${cl`c'}) version(5)
			eststo: reghdfestd `y' demiy`x' demlt`x'	[aw=weight]           , a(${fe`s'}) cl(${cl`c'}) version(5)
			eststo: reghdfestd `y' demiy`x' demlt`x'	[aw=weight] if age>24 , a(${fe`s'}) cl(${cl`c'}) version(5)
			esttab , se r2 starlevels(* 0.10 ** 0.05 *** 0.01) keep(demiy`x' demlt`x')
			esttab using "${savet}/hrsy`y'x`x's`s'c`c'.tex", replace noobs nomtitle nodepvar nonumber plain fragment label ///
			cells(b(fmt(3) star) se(par fmt(3))) ///
			order(demiy`x' demlt`x', relax) ///
			keep(demiy`x' demlt`x', relax) varwidth(30) ///
			starlevels(* 0.1 ** 0.05 *** 0.01) ///                 
			mlabels("Democracy 18-25", none) collabels(, none) ///
			substitute(_ _) style(tex) ///
			stats( N , fmt(0) labels("Number of Observations")) 
			}
		}
	}
}


/*==============================================================================
Table 4: Persistence of Impressionable Years Exposure
*=============================================================================*/
*ESTIMATES
gl saveout "${savee}/tot/olsPersistence"
u "temp/ivs",replace
keep if age>24 
gen ageint = age-25 
egen mean_ageint = mean(ageint) 
replace ageint = ageint-mean_ageint
replace ageint=ageint*demiy2
la var ageint "Exposure to Democracy 18-25 $\times$ Age"
forv s=1/1{
	forv c=1/1{
		forv x=1/2{
			foreach y in ${a}{
				reghdfestd `y' demiy`x' ageint [aw=weight] , a(${fe`s'}) cl(${cl`c'}) version(5)
				estimates save "${saveout}/py`y'x`x's`s'c`c'iy",replace
			}
		}
	}
}

*TABLE: PERSISTENCE
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/olsPersistence/py`y'x`x's1c1iy.ster"
		outreg,${opt} merge(px`x's1c1iy) drop(_cons)
		}
	outreg using "${savet}/px`x's1c1iy.tex", replay(px`x's1c1iy) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/px`x's1c1iy.tex", spaceb("^Mean")
}


/*==============================================================================
Table 5 & 6: Exposure to Successful Democracy. IY & LT (Interactions)
*=============================================================================*/
** IY DEMOCRACY **
*Code to calculate all main IY heterogeneities (also online appendix ones)
gl saveout "${savee}/sucM/olsMain"
forv suc=1/4{
	u "temp/2democracy/sucM/dem/suc`suc'iy",clear
	mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
	la var sucdem1 "Exposure to Successful Democracy"
	la var unsdem1 "Exposure to Unsuccessful Democracy"
	la var unsaut1 "Exposure to Unsuccessful Autocracy"
	la var sucdem2 "Exposure to Successful Democracy"
	la var unsdem2 "Exposure to Unsuccessful Democracy"
	la var unsaut2 "Exposure to Unsuccessful Autocracy"
		forv x=1/2{
			foreach y in $a {
			reghdfestd `y' sucdem`x' unsdem`x' unsaut`x' [aw=weight] if age>24 , a(${fe1}) cl(${cl1}) version(5)
			estimates save "${saveout}/suc`suc'y`y'x`x's1c1iy",replace
		}
	}
}

*TABLE: IY SUCCESSFUL DEMOCRACY ON WORK
mata:mata clear
foreach suc of numlist 1/4{
	forv x=1/2{
		mata:mata clear 
		foreach y in $a {
			estimates use "${savee}/sucM/olsMain/suc`suc'y`y'x`x's1c1iy.ster"
			test sucdem`x'==unsdem`x'
			loc pvaldiff: di %5.3fc `r(p)'
			outreg, ${opt} merge(suc`suc'x`x's1iy) drop(_cons) addrows("" , "" \ "P-value for $ H_{0}:$ Exp. to Suc. Dem. = Exp. to Uns. Dem. ","`pvaldiff'")  rtitles("Exposure to Successful Democracy" \ "" \ "Exposure to Unsuccessful Democracy" \ "" \ "Exposure to Unsuccessful Autocracy")
			}
		outreg using "${savet}/suc`suc'x`x's1c1iy.tex", replay(suc`suc'x`x's1iy) tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/suc`suc'x`x's1c1iy.tex", spaceb("^Mean")
	}
}

** LT DEMOCRACY **
*Code to calculate all main LT heterogeneities (also online appendix ones)
gl saveout "${savee}/sucM/olsMain"
forv suc=1/4{
	u "temp/2democracy/sucM/dem/suc`suc'lt",clear
	mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
	la var sucdem1 "Exposure to Successful Democracy"
	la var unsdem1 "Exposure to Unsuccessful Democracy"
	la var unsaut1 "Exposure to Unsuccessful Autocracy"
	la var sucdem2 "Exposure to Successful Democracy"
	la var unsdem2 "Exposure to Unsuccessful Democracy"
	la var unsaut2 "Exposure to Unsuccessful Autocracy"
		forv x=1/2{
			foreach y in $a {
			reghdfestd `y' sucdem`x' unsdem`x' unsaut`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
			estimates save "${saveout}/suc`suc'y`y'x`x's1c1lt",replace
		}
	}
}

*TABLE: LIFETIME SUCCESSFUL DEMOCRACY ON WORK
mata:mata clear
foreach suc of numlist 1/4{
	forv x=1/2{
		mata:mata clear 
		foreach y in $a {
			estimates use "${savee}/sucM/olsMain/suc`suc'y`y'x`x's1c1lt.ster"
			test sucdem`x'==unsdem`x'
			loc pvaldiff: di %5.3fc `r(p)'
			outreg, ${opt} merge(suc`suc'x`x's1lt) drop(_cons) addrows("" , "" \ "P-value for $ H_{0}:$ Exp. to Suc. Dem. = Exp. to Uns. Dem. ","`pvaldiff'")  rtitles("Exposure to Successful Democracy" \ "" \ "Exposure to Unsuccessful Democracy" \ "" \ "Exposure to Unsuccessful Autocracy")
			}
		outreg using "${savet}/suc`suc'x`x's1c1lt.tex", replay(suc`suc'x`x's1lt) tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/suc`suc'x`x's1c1lt.tex", spaceb("^Mean")
	}
}



/*==============================================================================
APPENDIX TABLES
*=============================================================================*/
/*==============================================================================
Table A1, A2 & A3: Summary Statistics, and Survey Respondents by Region
*=============================================================================*/
*A. Exposure.
u "temp/2democracy/sucM/dem/suc1lt",clear 
keep country yearb year sucdem1 unsdem1 suc
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_growthlt
}
mer 1:1 country yearb year using "temp/2democracy/sucM/dem/suc2lt",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_translt
}
mer 1:1 country yearb year using "temp/2democracy/sucM/dem/suc3lt",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_caplt
}
mer 1:1 country yearb year using "temp/2democracy/sucM/dem/suc4lt",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_redislt
}
mer 1:1 country yearb year using "temp/2democracy/sucM/dem/suc1iy",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_growthiy
}
mer 1:1 country yearb year using "temp/2democracy/sucM/dem/suc2iy",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_transiy
}
mer 1:1 country yearb year using "temp/2democracy/sucM/dem/suc3iy",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_capiy
}
mer 1:1 country yearb year using "temp/2democracy/sucM/dem/suc4iy",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_redisiy
}
mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
la var demiy1 "Exposure to Democracy 18-25 (Dichotomous)"
la var demiy2 "Exposure to Democracy 18-25 (Continous)"
la var demlt1 "Exposure to Democracy (Dichotomous)"
la var demlt2 "Exposure to Democracy (Continous)"
la var sucdem1_growthiy "Exposure to Successful Democracy 18-25 - Growth"
la var sucdem1_transiy "Exposure to Successful Democracy 18-25 - Transparency"
la var sucdem1_capiy "Exposure to Successful Democracy 18-25 - Capacity"
la var sucdem1_redisiy "Exposure to Successful Democracy 18-25 - Redistribution"
la var sucdem1_growthlt "Exposure to Successful Democracy - Growth"
la var sucdem1_translt "Exposure to Successful Democracy - Transparency"
la var sucdem1_caplt "Exposure to Successful Democracy - Capacity"
la var sucdem1_redislt "Exposure to Successful Democracy - Redistribution"
gl vardesc demiy1 demiy2 demlt1 demlt2 sucdem1_growthiy sucdem1_transiy sucdem1_capiy sucdem1_redisiy sucdem1_growthlt sucdem1_translt sucdem1_caplt sucdem1_redislt 
descstatistics ${vardesc}, dec(2) saving("${savet}/statsexposure.tex")
	
*B. Outcomes
u "temp/ivs",replace
gl aa childindepend childobed free2
la var childindepend "Independence Important"
la var childobed "Obedience Not Important"
la var free2 "Freedom"
descstatistics $a $aa, dec(2) saving("${savet}/statsoutcomes.tex")
	
*C. Pre-Birth.
u "temp/2democracy/sucM/bef/suc1",clear 
keep country yearb year sucdem1 unsdem1 suc
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_growthlt
}
mer 1:1 country yearb year using "temp/2democracy/sucM/bef/suc2",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_translt
}
mer 1:1 country yearb year using "temp/2democracy/sucM/bef/suc3",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_caplt
}
mer 1:1 country yearb year using "temp/2democracy/sucM/bef/suc4",keep(2 3) nogen keepus(sucdem1 unsdem1 suc)
foreach x in sucdem1 unsdem1 suc{
ren `x' `x'_redislt
}
mer 1:m country yearb year using "temp/2democracy/tot/bef",keep(2 3) nogen
mer 1:m country yearb year using "temp/ivs",keep(2 3) nogen
la var bef1 "Pre-Birth Exposure to Democracy (Dichotomous)"
la var bef2 "Pre-Birth Exposure to Democracy (Continous)"
la var sucdem1_growth "Pre-Birth Exposure to Successful Democracy - Growth"
la var sucdem1_trans "Pre-Birth Exposure to Successful Democracy - Transparency"
la var sucdem1_cap "Pre-Birth Exposure to Successful Democracy - Capacity"
la var sucdem1_redis "Pre-Birth Exposure to Successful Democracy - Redistribution"
gl vardesc bef1 bef2 sucdem1_growth sucdem1_trans sucdem1_cap sucdem1_redis 
descstatistics ${vardesc}, dec(2) saving("${savet}/statsprebirth.tex")

*D. Placebo.
u "temp/ivs",replace
mer 1:1 svyid using "temp/1survey/placebo",nogen keep(1 3)
la var neigunstable "Dislikes Emotionally Unstable Neighbors"
la var neigchris "Dislikes Christians Neighbors"
la var neigjews "Dislikes Jews Neighbors"
la var neigimm "Dislikes Immigrant Neighbors"
la var neiglargefam "Dislikes Neighbors With Large Families"
la var motherbooks "Mother Liked to Read Books"
la var relatmother "Relationship Working Mother"
la var familynotimportant "Family Not at All Important"
la var trust_fam "Trust Family"
la var trust_know "Trust People you Know"
la var relatmother "Relationship Mother"
la var confsss "Confidence in Social Security"
la var deathinev "Death is Inevitable"
la var nomeaning "Life has No Meaning"
la var parentsemp14 "Father Employed at age 14"
la var age5 "Age finished in 0 or 5"
la var motherimm "Mother Immigrant"
la var fatherimm "Father Immigrant"
la var E116 "Opposes Army Ruling"
la var demimportance "Importance of Democracy"
descstatistics $placebo , dec(2) saving("${savet}/statsplacebo.tex")

*E. Mechanisms.
u "temp/ivs",replace
la var impreligion "Religion Important"
la var believegod "Believe God"
la var believehell "Believe Hell"
la var believeheaven "Believe Heaven"
la var godimportant "God Important"
la var belief "Belief Index"
la var educ2 "Completed Secondary"
la var educ3 "Completed Tertiary"
la var education "Education Level"
la var employment1 "Full Time"
la var employment2 "Part Time"
la var employment3 "Self Employed"
la var employment4 "Retired"
la var employment5 "Housewife"
la var employment6 "Student"
la var employment7 "Unemployed"
descstatistics $alli , dec(2) saving("${savet}/statsmechanisms.tex")

*F. Fixed Effects, Clusters and Groups.
u "temp/ivs",replace
encode subregion, gen(subregion_num)
drop subregion
ren subregion_num subregion
encode country, gen(country_num)
drop country
ren country_num country
encode region, gen(region_num)
drop region
ren region_num region
la var male "Gender"
la var townsize "Town Size"
la var wavenum "Wave"
la var age "Age"
la var languagenum "Language"
la var subregion "Sub-region"
la var yearb "Cohort"
la var country "Country"
la var year "Year of Survey"
la var feregion_year "Region x Year of Survey"
la var fect_wave "Country x Wave"
la var region "Region"
la var fect_year "Country x Year"
la var cohort10 "Cohort by Decade"
la var political "Political Position"
descstatistics $allfeclgr , dec(2) saving("${savet}/statsfeclgr.tex")

*G. Alternative Outcomes (Used in Online Appendix).
u "temp/appivs",replace
la var financial "Financial"
la var financial2 "Other Financial"
la var health2 "Alt-Health Definition"
la var aautonomyi "Autonomy Index B"
la var oautonomyi "Autonomy Index C"
la var happy1 "Felt on Top"
la var happy3 "Felt Your Way"
descstatistics $alt , dec(2) saving("${savet}/statsapp.tex")

*H. Alternative Outcomes from ESS
u "temp/1survey/ess",replace
la var income "Income"
la var health "Health"
la var autonomy "Autonomy"
la var satisfaction "Satisfaction"
la var happiness "Happiness"
descstatistics $a , dec(2) saving("${savet}/statsess.tex")

*Tabla que muestra la frecuencia por continente (para mostrar que Europa es parte importante de la muestra)
use "temp/ivs", clear
estpost tabulate region

esttab using "${savet}/regions.tex", replace ///
    cells("b(fmt(0)) pct(fmt(2)) cumpct(fmt(2))") ///
    collabels(none) ///
    noobs nonum label ///
    nomtitles fragment


/*==============================================================================
Table A4: Exposure to Democracy 18-25 — Diverse Fixed Effects 
*=============================================================================*/
* Programa para borrar las primeras líneas de un archivo
capture program drop clean_file
program define clean_file
    args infile outfile
    tempname in out
    file open `in' using "`infile'", read text
    file open `out' using "`outfile'", write text replace
    file read `in' line
    file read `in' line
    file read `in' line
	file read `in' line
    while r(eof) == 0 {
        file write `out' "`line'" _n
        file read `in' line
    }
    file close `in'
    file close `out'
end

* Programa para agregar & y \\ a una tabla tipo LaTeX
capture program drop latex_separators
program define latex_separators
    args infile outfile
    tempname in out
    file open `in' using "`infile'", read text
    file open `out' using "`outfile'", write text replace
    local linenum = 1
    file read `in' line
    while r(eof) == 0 {
        local line = "`line'"
        local line : subinstr local line "`=char(13)'" "", all
        local line : subinstr local line "`=char(10)'" "", all
        local line : subinstr local line `"`=char(9)'"' " ", all
        while strpos("`line'", "  ") > 0 {
            local line : subinstr local line "  " " ", all
        }
        local line = trim("`line'")
        local new_line = ""
        if `linenum' == 1 {
            local firstword = word("`line'", 1)
            if inlist("`firstword'", "demlt2", "demiy2") {
                local pos = strpos("`line'", " ")
                local line = substr("`line'", `pos'+1, .)

                local i = 1
                local label = ""
                while regexm(word("`line'", `i'), "^[0-9\(\-\+\.]") == 0 & word("`line'", `i') != "" {
                    local label "`label' `=word("`line'", `i')'"
                    local ++i
                }
                local label = trim("`label'")
                local new_line "`label'"

                while word("`line'", `i') != "" {
                    local wordi = word("`line'", `i')
                    local new_line "`new_line' & `wordi'"
                    local ++i
                }
            }
            else {
                local i = 1
                local label = ""
                while regexm(word("`line'", `i'), "^[0-9\(\-\+\.]") == 0 & word("`line'", `i') != "" {
                    local label "`label' `=word("`line'", `i')'"
                    local ++i
                }
                local label = trim("`label'")
                local new_line "`label'"
                while word("`line'", `i') != "" {
                    local wordi = word("`line'", `i')
                    local new_line "`new_line' & `wordi'"
                    local ++i
                }
            }
            local fixed_line ""
            local i = 1
            while word("`new_line'", `i') != "" {
                local w = word("`new_line'", `i')
                if regexm("`w'", "^[-+0-9\.\(].*") {
                    local fixed_line "`fixed_line' & `w'"
                }
                else {
                    local fixed_line "`fixed_line' `w'"
                }
                local ++i
            }

            while strpos("`fixed_line'", "  ") > 0 {
                local fixed_line : subinstr local fixed_line "  " " ", all
            }
            local new_line = trim("`fixed_line'")
        }
        else {
            local i = 1
            while word("`line'", `i') != "" {
                local wordi = word("`line'", `i')
                local new_line "`new_line' & `wordi'"
                local ++i
            }
            if `linenum' != 2 {
                local new_line = substr("`new_line'", 3, .)
            }
        }
        if inlist(`linenum', 1, 2) {
			local new_line "`new_line' \\"
		}
        while regexm("`new_line'", "([^&]) +&") {
            local new_line : subinstr local new_line " &" "&", all
        }
        while regexm("`new_line'", "& +([^&])") {
            local new_line : subinstr local new_line "& " "&", all
        }
        while strpos("`new_line'", "&&") {
            local new_line : subinstr local new_line "&&" "&", all
        }
        * Corrección para 18-25
		local new_line : subinstr local new_line "&18-25" " 18-25", all
		local new_line : subinstr local new_line "& 18-25" " 18-25", all
        capture file write `out' "`new_line'" _n
        if _rc {
            display as error "Error en línea `linenum': `new_line'"
            file close `in'
            file close `out'
            exit _rc
        }
        local linenum = `linenum' + 1
        file read `in' line
    }
    file close `in'
    file close `out'
end

u "temp/ivs", replace

foreach y in $a {
	cap erase ftabless_`y'iy.txt
	cap erase ftabless_`y'iy.xml
	cap erase ftables_`y'iy.txt
	cap erase ftables_`y'iy.xml
	cap erase ftable_`y'iy.txt
	cap erase ftable_`y'iy.xml
	local lvar : variable label `y'
	forv s=1/10{
    reghdfestd `y' demiy2 [aw=weight] if age>24 , a(${fes`s'}) cl(${cl1}) version(5)
	outreg2 demiy2 using "${savet}/ftabless_`y'iy.txt", $outopts2 
    }
    clean_file "${savet}/ftabless_`y'iy.txt" "${savet}/ftables_`y'iy.txt"
	erase "${savet}/ftabless_`y'iy.txt"
	latex_separators "${savet}/ftables_`y'iy.txt" "${savet}/ftable_`y'iy.txt"
	erase "${savet}/ftables_`y'iy.txt"
}

reghdfe happiness demiy2 [aw=weight] if age>24 , a(${fes1}) cl(${cl1}) 
gen used = e(sample)
count if used == 1
local num_obs = r(N)
levelsof country if used == 1, local(countries)
local num_countries : word count `countries'
drop used
file open out using "${savet}/ftable_happinessiy.txt", write append
file write out "\\ " _n
file write out "Observations & `num_obs' \\\\ " _n
file write out "Countries & `num_countries' \\\\ "
file close out

* VERIFICACIÓN DE FIXED EFFECTS EN CADA ESPECIFICACIÓN
local infile "${savet}/ftable_happinessiy.txt"
local tempfile "${savet}/ftable_happiness_tmpiy.txt"
local fevars "male townsize wavenum yearb country age year languagenum subregion region fect_year cohort10 feregion_year fect_wave"
local columna1  yearb country age
local columna2  townsize wavenum country age
local columna3  male wavenum country age
local columna4  male townsize yearb country age languagenum subregion
local columna5  male townsize wavenum age languagenum country
local columna6  male townsize wavenum age languagenum yearb country
local columna7  male townsize wavenum age languagenum yearb country year subregion
local columna8  male townsize wavenum age languagenum fect_year yearb region
local columna9  male townsize wavenum age languagenum fect_year cohort10 region
local columna10 male townsize wavenum age languagenum feregion_year fect_wave subregion
file open in using "`infile'", read
file open out using "`tempfile'", write replace
file read in line
while r(eof)==0 {
    file write out "`line'" _n
    file read in line
}
file close in
file write out "\hline \\" _n
foreach var of local fevars {
    local row = "`var'"
    forval i = 1/10 {
        local col "`columna`i''"
        local found = 0
        local nvars : word count `col'
        forval j = 1/`nvars' {
            local v : word `j' of `col'
            if "`v'" == "`var'" {
                local found = 1
                continue, break
            }
        }
        if `found' {
            local row "`row' & YES"
        }
        else {
            local row "`row' & NO"
        }
    }
    file write out "`row' \\" _n
}

file close out
copy "`tempfile'" "`infile'", replace
erase "`tempfile'"

* REPLACE VARIABLE NAMES WITH LABELS IN FINAL TABLE (ONLY FOR FEs)
use "temp/ivs", clear
local varlist male townsize wavenum yearb country age year languagenum ///
              subregion region fect_year cohort10 feregion_year fect_wave
tempfile temp
postfile handle str32 variable str80 label using "`temp'", replace
foreach v of local varlist {
    capture confirm variable `v'
    if _rc == 0 {
        local varlab : variable label `v'
        if `"`varlab'"' == "" local varlab "<no label>"
        post handle ("`v'") ("`varlab'")
    }
}
postclose handle
use "`temp'", clear
list, clean noobs
gen sortlen = length(variable)
gsort -sortlen
drop sortlen
expand 2 if _n == _N
replace variable = "skibidi" if _n == _N
replace label = "dopdop" if _n == _N
save "varlabelsiy.dta", replace

use "varlabelsiy.dta", clear
assert !missing(variable) & !missing(label)
gen id = _n
local origfile = "${savet}/ftable_happinessiy.txt"
tempfile temp1 temp2
copy "`origfile'" "`temp1'", replace
gen from = variable
gen to   = "<<LABEL" + string(id) + ">>"
forvalues i = 1/`=_N' {
    local f = from[`i']
    local t = to[`i']

    local frompat "`f' "
    local topat   "`t' "

    if mod(`i', 2) == 1 {
        filefilter "`temp1'" "`temp2'", from("`frompat'") to("`topat'") replace
    }
    else {
        filefilter "`temp2'" "`temp1'", from("`frompat'") to("`topat'") replace
    }
}
forvalues i = 1/`=_N' {
    local temp = to[`i']
    local label = label[`i']

    local frompat "`temp'"
    local topat  "`label'"

    if mod(`i', 2) == 1 {
        filefilter "`temp1'" "`temp2'", from("`frompat'") to("`topat'") replace
    }
    else {
        filefilter "`temp2'" "`temp1'", from("`frompat'") to("`topat'") replace
    }
}
local finalfile = cond(mod(`=_N', 2) == 1, "`temp1'", "`temp2'")
copy "`finalfile'" "`origfile'", replace
erase "varlabelsiy.dta"


/*==============================================================================
Table A5: Exposure to Democracy 18-25 — Diverse Clusters
*=============================================================================*/
u "temp/ivs", replace

foreach y in $a {
	cap erase ctabless_`y'iy.txt
	cap erase ctabless_`y'iy.xml
	cap erase ctables_`y'iy.txt
	cap erase ctables_`y'iy.xml
	cap erase ctable_`y'iy.txt
	cap erase ctable_`y'iy.xml
	local lvar : variable label `y'
	forv c=1/10{
    reghdfestd `y' demiy2 [aw=weight] if age>24 , a(${fe1}) cl(${clu`c'}) version(5)
	outreg2 demiy2 using "${savet}/ctabless_`y'iy.txt", $outopts2 
    }
    clean_file "${savet}/ctabless_`y'iy.txt" "${savet}/ctables_`y'iy.txt"
	erase "${savet}/ctabless_`y'iy.txt"
	latex_separators "${savet}/ctables_`y'iy.txt" "${savet}/ctable_`y'iy.txt"
	erase "${savet}/ctables_`y'iy.txt"
}

reghdfe happiness demiy2 [aw=weight] if age>24 , a(${fes1}) cl(${cl1})
gen used = e(sample)
count if used == 1
local num_obs = r(N)
levelsof country if used == 1, local(countries)
local num_countries : word count `countries'
drop used
file open out using "${savet}/ctable_happinessiy.txt", write append
file write out "\\ " _n
file write out "Observations & `num_obs' \\\\ " _n
file write out "Countries & `num_countries' \\\\ "
file close out

* VERIFICACIÓN DE CLUSTERS EN CADA ESPECIFICACIÓN
local infile "${savet}/ctable_happinessiy.txt"
local tempfile "${savet}/ctable_happiness_tmpiy.txt"
local cvars "yearb year region wavenum country subregion"
local columna1  yearb
local columna2  year
local columna3  year yearb
local columna4  region year yearb
local columna5  region yearb wavenum
local columna6  country
local columna7  country year
local columna8  country yearb
local columna9  country year yearb
local columna10 subregion
file open in using "`infile'", read
file open out using "`tempfile'", write replace
file read in line
while r(eof)==0 {
    file write out "`line'" _n
    file read in line
}
file close in
file write out "\hline \\" _n
foreach var of local cvars {
    local row = "`var'"
    forval i = 1/10 {
        local col "`columna`i''"
        local found = 0
        local nvars : word count `col'
        forval j = 1/`nvars' {
            local v : word `j' of `col'
            if "`v'" == "`var'" {
                local found = 1
                continue, break
            }
        }
        if `found' {
            local row "`row' & YES"
        }
        else {
            local row "`row' & NO"
        }
    }
    file write out "`row' \\" _n
}

file close out
copy "`tempfile'" "`infile'", replace
erase "`tempfile'"

* REPLACE VARIABLE NAMES WITH LABELS IN FINAL TABLE (ONLY FOR Clusters)
use "temp/ivs", clear
local varlist yearb year region wavenum country subregion
tempfile temp
postfile handle str32 variable str80 label using "`temp'", replace
foreach v of local varlist {
    capture confirm variable `v'
    if _rc == 0 {
        local varlab : variable label `v'
        if `"`varlab'"' == "" local varlab "<no label>"
        post handle ("`v'") ("`varlab'")
    }
}
postclose handle
use "`temp'", clear
list, clean noobs
gen sortlen = length(variable)
gsort -sortlen
drop sortlen
expand 2 if _n == _N
replace variable = "skibidi" if _n == _N
replace label = "dopdop" if _n == _N
save "varlabelsiy.dta", replace

use "varlabelsiy.dta", clear
assert !missing(variable) & !missing(label)
gen id = _n
local origfile = "${savet}/ctable_happinessiy.txt"
tempfile temp1 temp2
copy "`origfile'" "`temp1'", replace
gen from = variable
gen to   = "<<LABEL" + string(id) + ">>"
forvalues i = 1/`=_N' {
    local f = from[`i']
    local t = to[`i']

    local frompat "`f' "
    local topat   "`t' "

    if mod(`i', 2) == 1 {
        filefilter "`temp1'" "`temp2'", from("`frompat'") to("`topat'") replace
    }
    else {
        filefilter "`temp2'" "`temp1'", from("`frompat'") to("`topat'") replace
    }
}
forvalues i = 1/`=_N' {
    local temp = to[`i']
    local label = label[`i']

    local frompat "`temp'"
    local topat  "`label'"

    if mod(`i', 2) == 1 {
        filefilter "`temp1'" "`temp2'", from("`frompat'") to("`topat'") replace
    }
    else {
        filefilter "`temp2'" "`temp1'", from("`frompat'") to("`topat'") replace
    }
}
local finalfile = cond(mod(`=_N', 2) == 1, "`temp1'", "`temp2'")
copy "`finalfile'" "`origfile'", replace
erase "varlabelsiy.dta"


/*==============================================================================
Table A6: Lifetime Exposure to Democracy — Capping Exposure to Democracy at 40
*=============================================================================*/
gl saveout "${savee}/tot/olsMainLT"
u "temp/ivs",replace
foreach v of varlist demlt1 demlt2{
	replace `v'=min(`v',40) if !missing(`v')
}	
forv x=1/2{
	foreach y in $a {
		reghdfestd `y' demlt`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/demcapy`y'x`x'",replace
	}
}

*TABLE: LIFETIME DEMOCRACY
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/olsMainLT/demcapy`y'x`x'.ster"
		outreg,${opt} merge(x`x') drop(_cons)
		}
	outreg using "${savet}/demcapx`x'.tex", replay(x`x') tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/demcapx`x'.tex", spaceb("^Mean")
}


/*==============================================================================
Table A7: Exposure to Democracy 18–25 — Leave-One-Out and Europe-Only 
*=============================================================================*/
gl saveout "${savee}/tot/olsMainIY"
use "temp/ivs", clear
keep if age>24
la var demiy1 "Exposure to Democracy 18-25"
la var demiy2 "Exposure to Democracy 18-25"
local regions `" "Africa" "Asia" "Europe" "Latin America" "AS America" "Oceania" "'
forv x=1/2{
foreach excl in `regions'{
	foreach y in $a {
		reghdfestd `y' demiy`x' [aw=weight] if region != "`excl'", a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1iy_no`=subinstr("`excl'", " ", "_", .)'", replace
		}
	}
}

keep if region == "Europe"
forv x=1/2{
foreach y in $a {
	reghdfestd `y' demiy`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
	estimates save "${saveout}/y`y'x`x's1c1iy_Europe", replace
	}
}

* TABLE: LIFETIME DEMOCRACY - LEAVE-ONE-REGION
local regions "Africa Asia Europe Latin_America AS_America Oceania"
local regnames `" "Africa" "Asia" "Europe" "Latin America" "AS America" "Oceania" "'

forv x=1/2{
local i = 1
foreach excl in `regnames' {
	local r = word("`regions'", `i')
		mata:mata clear
		foreach y in $a {
			estimates use "${savee}/tot/olsMainIY/y`y'x`x's1c1iy_no`r'.ster"
			outreg, ${opt} merge(x`x's1c1iy_no`r') drop(_cons)
		}
		outreg using "${savet}/x`x's1c1iy_no`r'.tex", replay(x`x's1c1iy_no`r') tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/x`x's1c1iy_no`r'.tex", spaceb("^Mean")
	local ++i
	}
}

forv x=1/2{
foreach nat in Europe {
	mata:mata clear
		foreach y in $a {
			estimates use "${savee}/tot/olsMainIY/y`y'x`x's1c1iy_`nat'.ster"
			outreg, ${opt} merge(x`x's1c1iy_`nat') drop(_cons)
		}
		outreg using "${savet}/x`x's1c1iy_`nat'.tex", replay(x`x's1c1iy_`nat') tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/x`x's1c1iy_`nat'.tex", spaceb("^Mean")
		}
}


/*==============================================================================
Table A8: Lifetime Exposure to Democracy — Leave-One-Out and Europe-Only 
*=============================================================================*/
gl saveout "${savee}/tot/olsMainLT"
use "temp/ivs", clear
la var demlt1 "Exposure to Democracy"
la var demlt2 "Exposure to Democracy"
local regions `" "Africa" "Asia" "Europe" "Latin America" "AS America" "Oceania" "'
forv x=1/2{
foreach excl in `regions'{
	foreach y in $a {
		reghdfestd `y' demlt`x' [aw=weight] if region != "`excl'", a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1lt_no`=subinstr("`excl'", " ", "_", .)'", replace
		}
	}
}

keep if region == "Europe"
forv x=1/2{
foreach y in $a {
	reghdfestd `y' demlt`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
	estimates save "${saveout}/y`y'x`x's1c1lt_Europe", replace
	}
}

* TABLE: LIFETIME DEMOCRACY - LEAVE-ONE-REGION
local regions "Africa Asia Europe Latin_America AS_America Oceania"
local regnames `" "Africa" "Asia" "Europe" "Latin America" "AS America" "Oceania" "'

forv x=1/2{
local i = 1
foreach excl in `regnames' {
	local r = word("`regions'", `i')
		mata:mata clear
		foreach y in $a {
			estimates use "${savee}/tot/olsMainLT/y`y'x`x's1c1lt_no`r'.ster"
			outreg, ${opt} merge(x`x's1c1lt_no`r') drop(_cons)
		}
		outreg using "${savet}/x`x's1c1lt_no`r'.tex", replay(x`x's1c1lt_no`r') tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/x`x's1c1lt_no`r'.tex", spaceb("^Mean")
	local ++i
	}
}

forv x=1/2{
foreach nat in Europe {
	mata:mata clear
		foreach y in $a {
			estimates use "${savee}/tot/olsMainLT/y`y'x`x's1c1lt_`nat'.ster"
			outreg, ${opt} merge(x`x's1c1lt_`nat') drop(_cons)
		}
		outreg using "${savet}/x`x's1c1lt_`nat'.tex", replay(x`x's1c1lt_`nat') tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/x`x's1c1lt_`nat'.tex", spaceb("^Mean")
		}
}


/*==============================================================================
Table A9: Exposure to Democracy 18-25 — Heterogeneities
==============================================================================*/
gl filter_male0    male==0
gl filter_male1    male==1
gl filter_town0    townsize==0
gl filter_town1    townsize==1
gl filter_age1     inrange(age,10,29)
gl filter_age2     inrange(age,30,50)
gl filter_age3     inrange(age,51,150)
gl filter_pol1     political==1
gl filter_pol2     political==2
gl filter_pol3     political==3

gl saveout "${savee}/tot/olsMainIY"
foreach sg of global subgroups {
    u "temp/ivs", clear
    keep if ${filter_`sg'}

    forv x = 1/2 {
        foreach y in $a {
            reghdfestd `y' demiy`x' [aw=weight] if age>24 , a(${fe1}) cl(${cl1}) version(5)
            estimates save "${saveout}/y`y'x`x's1c1iy_`sg'", replace
        }
    }
}

foreach sg of global subgroups {
    forv x = 1/2 {
        mata:mata clear
        foreach y in $a {
            estimates use "${savee}/tot/olsMainIY/y`y'x`x's1c1iy_`sg'.ster"
            outreg, ${opt} merge(x`x's1c1`sg'iy) drop(_cons)
        }
        outreg using "${savet}/x`x's1c1iy_`sg'.tex", replay(x`x's1c1`sg'iy) tex plain replace fragment nocenter varlabels
        droptabular using "${savet}/x`x's1c1iy_`sg'.tex", spaceb("^Mean")
    }
}


/*==============================================================================
Table A10, A11, A12 & A13: Exposure to Democracy 18-25 — Alternative Mechanisms
*=============================================================================*/
*code for plausible mechanisms, IY  
*ESTIMATES 1
gl saveout "${savee}/tot/olsMain"
u "temp/ivs",replace
forv s=1/1{
	forv c=1/1{
		forv x=1/2{
			foreach y in $i1 {
				reghdfestd `y' demiy`x' [aw=weight] if age>24, a(${fe`s'}) cl(${cl`c'}) version(5)
				estimates save "${saveout}/i1y`y'x`x's`s'c`c'iy",replace
			}
		}
	}
}

*TABLE: DEMOCRACY 1
forv s=1/1{
	forv c=1/1{
		forv x=1/2{
			mata:mata clear 
			foreach y in $i1 {
				estimates use "${savee}/tot/olsMain/i1y`y'x`x's`s'c`c'iy.ster"
				outreg,${opt} merge(tx`x's`s'iy1) drop(_cons)
			}
			outreg using "${savet}/i1x`x's`s'c`c'iy.tex",replay(tx`x's`s'iy1) tex plain replace fragment nocenter varlabels
			droptabular using "${savet}/i1x`x's`s'c`c'iy.tex", spaceb("^Mean")
		}	
	}	
}

*ESTIMATES 2
gl saveout "${savee}/tot/olsMain"
u "temp/ivs",replace
forv s=1/1{
	forv c=1/1{
		forv x=1/2{
			foreach y in $i2 {
				reghdfestd `y' demiy`x' [aw=weight] if age>24, a(${fe`s'}) cl(${cl`c'}) version(5)
				estimates save "${saveout}/i2y`y'x`x's`s'c`c'iy",replace
			}
		}
	}
}

*TABLE: DEMOCRACY 2
forv s=1/1{
	forv c=1/1{
		forv x=1/2{
			mata:mata clear 
			foreach y in $i2 {
				estimates use "${savee}/tot/olsMain/i2y`y'x`x's`s'c`c'iy.ster"
				outreg,${opt} merge(tx`x's`s'iy2) drop(_cons)
			}
			outreg using "${savet}/i2x`x's`s'c`c'iy.tex",replay(tx`x's`s'iy2) tex plain replace fragment nocenter varlabels
			droptabular using "${savet}/i2x`x's`s'c`c'iy.tex", spaceb("^Mean")
		}	
	}	
}

*ESTIMATES 3
gl saveout "${savee}/tot/olsMain"
u "temp/ivs",replace
forv s=1/1{
	forv c=1/1{
		forv x=1/2{
			foreach y in $i3 {
				reghdfestd `y' demiy`x' [aw=weight] if age>24, a(${fe`s'}) cl(${cl`c'}) version(5)
				estimates save "${saveout}/i3y`y'x`x's`s'c`c'iy",replace
			}
		}
	}
}

*TABLE: DEMOCRACY 3
forv s=1/1{
	forv c=1/1{
		forv x=1/2{
			mata:mata clear 
			foreach y in $i3 {
				estimates use "${savee}/tot/olsMain/i3y`y'x`x's`s'c`c'iy.ster"
				outreg,${opt} merge(tx`x's`s'iy3) drop(_cons)
			}
			outreg using "${savet}/i3x`x's`s'c`c'iy.tex",replay(tx`x's`s'iy3) tex plain replace fragment nocenter varlabels
			droptabular using "${savet}/i3x`x's`s'c`c'iy.tex", spaceb("^Mean")
		}	
	}	
}

*ESTIMATES 4
gl saveout "${savee}/tot/olsMainIY"
u "temp/ivs",replace
forv x=1/2{
	foreach y in $i4 {
		reghdfestd `y' demiy`x' [aw=weight] if age>24 , a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/i4y`y'x`x's1c1iy",replace
	}
}

*TABLE: DEMOCRACY 4
forv x=1/2{
	mata:mata clear
	foreach y in $i4 {
		estimates use "${savee}/tot/olsMainIY/i4y`y'x`x's1c1iy.ster"
		outreg,${opt} merge(i4x`x's1c1iy) drop(_cons)
		}
	outreg using "${savet}/i4x`x's1c1iy.tex", replay(i4x`x's1c1iy) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/i4x`x's1c1iy.tex", spaceb("^Mean")
}


/*==============================================================================
Table A14: 2SLS Estimation 18-25 — First-Stage Regression
*=============================================================================*/
gl saveout "${savee}/tot/ivMain"
do "${code}/utils/reghdfestd.ado"
do "${code}/utils/droptabular.ado"
u "temp/ivs",replace
mer m:1 country yearb year using "temp/2democracy/tot/instiy.dta",keep(1 3) nogen keepus(z1dem1 z2dem2)
ren (z1dem1 z2dem2) (zdem1 zdem2)
forv x=1/2{
	la var zdem`x' "Exposure to Democracy Wave t-1"
	reghdfestd demiy`x' zdem`x' [aw=weight] if age>24 , a(${fe1}) cl(${cl1}) version(5)
	estimates save "${saveout}/fsx`x'iy",replace
	qui test zdem`x'
    scalar Fstat_x`x'_iy = r(F)
}

*TABLES IY DEMOCRACY 2SLS
mata:mata clear
forv x=1/2{
		estimates use "${saveout}/fsx`x'iy.ster"
		local fstat: display %5.3f scalar(Fstat_x`x'_iy)
		outreg, ${opt} merge(x`x'iy) ///
        rtitles("Exposure to Democracy Wave t-1") ///
        keep(zdem`x') ///
        addrows("F-stat excluded instruments", "`fstat'")
		outreg using "${savet}/fsdemx`x'iy.tex", ///
        replay(x`x'iy) tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/fsdemx`x'iy.tex", spaceb("^Mean")
}
	

/*==============================================================================
Table A15: IV Exposure to Democracy 18-25
*=============================================================================*/
gl saveout "${savee}/tot/ivMain"
do "${code}/utils/ivreghdfestd.ado"
do "${code}/utils/droptabular.ado"
u "temp/ivs",replace
mer m:1 country yearb year using "temp/2democracy/tot/instiy.dta",keep(1 3) nogen keepus(z1dem1 z2dem2)
ren (z1dem1 z2dem2) (zdem1 zdem2)
forv x=1/2{
	forv y=1/5{
		loc dep=word("$a",`y')
		la var zdem`x' "Exposure to Democracy Wave t-1"
		ivreghdfestd `dep' (demiy`x'=zdem`x') [aw=weight] if age>24 , a(${fe1}) cl(${cl1}) savefirst
		estimates save "${saveout}/y`y'x`x's1iy",replace
	}
}

*TABLES IY DEMOCRACY 2SLS
mata:mata clear
forv x=1/2{
	forv y=1/5{
		estimates use "${savee}/tot/ivMain/y`y'x`x's1iy.ster"
		outreg, ${opt} merge(ivx`x's1iy) rtitles("Exposure to Democracy 18-25")
		}
		outreg using "${savet}/ivdemx`x's1iy.tex", replay(ivx`x's1iy) tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/ivdemx`x's1iy.tex", spaceb("^Mean")
}


/*==============================================================================
Table A16: 2SLS Estimation Lifetime — First-Stage Regression
*=============================================================================*/
gl saveout "${savee}/tot/ivMain"
do "${code}/utils/reghdfestd.ado"
do "${code}/utils/droptabular.ado"
u "temp/ivs", replace
mer m:1 country yearb year using "temp/2democracy/tot/instlt.dta", keep(1 3) nogen keepus(z1dem1 z2dem2)
ren (z1dem1 z2dem2) (zdem1 zdem2)
forv x=1/2{
    la var zdem`x' "Exposure to Democracy Wave t-1"
    reghdfestd demlt`x' zdem`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
    estimates save "${saveout}/fsx`x'lt", replace
    qui test zdem`x'
    scalar Fstat_x`x'_lt = r(F)
}

*TABLES LT DEMOCRACY 2SLS
mata:mata clear
forv x=1/2{
    estimates use "${saveout}/fsx`x'lt.ster"
    local fstat: display %5.3f scalar(Fstat_x`x'_lt)
    outreg, ${opt} merge(x`x'lt) ///
        rtitles("Exposure to Democracy Wave t-1") ///
        keep(zdem`x') ///
        addrows("F-stat excluded instruments", "`fstat'")
		outreg using "${savet}/fsdemx`x'lt.tex", ///
        replay(x`x'lt) tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/fsdemx`x'lt.tex", spaceb("^Mean")
}


/*==============================================================================
Table A17: IV Lifetime Exposure to Democracy
*=============================================================================*/
gl saveout "${savee}/tot/ivMain"
do "${code}/utils/ivreghdfestd.ado"
do "${code}/utils/droptabular.ado"
u "temp/ivs",replace
mer m:1 country yearb year using "temp/2democracy/tot/instlt.dta",keep(1 3) nogen keepus(z1dem1 z2dem2)
ren (z1dem1 z2dem2) (zdem1 zdem2)
forv x=1/2{
	forv y=1/5{
		loc dep=word("$a",`y')
		la var zdem`x' "Exposure to Democracy Wave t-1"
		ivreghdfestd `dep' (demlt`x'=zdem`x') [aw=weight], a(${fe1}) cl(${cl1}) savefirst
		estimates save "${saveout}/y`y'x`x's1lt",replace
	}
}

*TABLES LIFETIME DEMOCRACY 2SLS
mata:mata clear
forv x=1/2{
	forv y=1/5{
		estimates use "${savee}/tot/ivMain/y`y'x`x's1lt.ster"
		outreg, ${opt} merge(ivx`x's1lt) rtitles("Exposure to Democracy")
		}
		outreg using "${savet}/ivdemx`x's1lt.tex", replay(ivx`x's1lt) tex plain replace fragment nocenter varlabels
		droptabular using "${savet}/ivdemx`x's1lt.tex", spaceb("^Mean")
}


/*==============================================================================
Table A18: Exposure to Democracy — Event-specific Estimates (WOOLRIDGE)
*=============================================================================*/
use "temp/ivs", clear
merge m:1 country year yearb using "temp/2democracy/event/cohortsEvent", keep(1 3) nogen
assert demlt1 == totdemevent
drop totdemevent
qui foreach v of varlist demevent* {
	su `v'
	if r(sum) == 0 drop `v'
}
save temp, replace
use temp, clear
forvalues y = 1/5 {
    display _n "ITERACIÓN `y'"
    local dep = word("$a", `y')
    display "Variable dependiente: `dep'"
    marktouse touse `dep' demevent* ${fe1}
    su `dep' [aw=weight] if touse
    gen y = (`dep' - r(mean)) / r(sd) if touse
    display "Corriendo reghdfe..."
    reghdfe y demevent*, a(${fe1}) cl(${cl1}) nocon verbose(1)
    estimates save "${savee}/tot/others/event/y`y'x1s1.ster", replace
    drop touse y
}

use "temp/ivs", clear
merge m:1 country year yearb using "temp/2democracy/event/cohortsEventValue5", keep(1 3) nogen
drop totdemevent
quietly foreach v of varlist demevent* {
	su `v'
	if r(sum) == 0 drop `v'
}
save temp1, replace
forvalues s = 1/1 { 
	forvalues x = 1/1 { 
		forvalues yi = 1/5 {
			local dep = word("${a}", `yi')
			use temp1, clear
			marktouse touse `dep' demevent* ${fe`s'} weight
			su `dep' [aw=weight] if touse
			gen y = (`dep' - r(mean)) / r(sd) if touse
			reghdfe y demevent* [aw=weight], a(${fe`s'}) cl(${cl1}) nocon
			estimates save "${savee}/tot/others/event/y`yi'x`x's`s'Years5.ster", replace
			drop y touse
		}
	}
}

*PANEL A
u "temp/ivs",clear
mer m:1 country year yearb using "temp/2democracy/event/cohortsEvent",keep(1 3) nogen //1 are cohorts for which demlt1 is not defined

cap matrix drop output
forv s=1/1{
forv x=1/1{
forv y=1/5{
	loc dep=word("$a",`y')
	marktouse touse `dep' demlt`x' ${fe`s'}
	su demlt`x' if touse==1
	loc demsd=`r(sd)'
	drop touse
	estimates use "${savee}/tot/others/event/y`y'x`x's`s'.ster"
	mata:b=st_matrix("e(b)")'
	mata:V=st_matrix("e(V)")
	mata:w=mm_cond(b:==0,0,1:/(diagonal(V)))
	*mata:w=mm_cond(b:==0,0,1)
	mata:w=w/sum(w)
	mata:beta=w'*b
	mata:se=sqrt(w'*V*w)
	mata:st_local("beta", strofreal(beta))
	mata:st_local("se", strofreal(se))
	mat t0=[`s',`x',`y',`beta',`se',`demsd',e(N_full),e(N_clust1)]
	cap confirm matrix output
	if _rc!=0 mat output=t0
	else mat output=output\t0
}
}
}
clear
svmat output
ren * (s x y beta se xsd N countries)
keep if x==1
drop s x
foreach v of varlist beta se {
	replace `v'=`v'*xsd //standarding coefficients to make it comparable
}
gen p=2*(1-normal(abs(beta/se)))
foreach v of varlist beta se N countries{
	ren `v' t0
	if inlist("`v'","beta","se") g `v'=string(t0,"%20.3fc")
	else  g `v'=string(t0,"%20.0fc")
	drop t0
}
replace beta=beta+cond(p<0.01,"***",cond(p<0.05,"**",cond(p<0.1,"*","")))
replace se="("+se+")"
so y
keep beta se N countries
sxpose,clear
g name=""
replace name="Exposure to Democracy" if _n==1
replace name="\\ Observations" if _n==3
replace name="Countries" if _n==4

egen latex=concat(name _var*),p(" & ")
cap file close myfile
file open myfile using "${savet}/eventdemx1s1.tex", write replace
forv i=1/`=_N'{
	loc t0=latex in `i'
	file write myfile `"`t0' \\"' _n 
}
file close myfile

*PANEL B
use "temp/2democracy/event/cohortsEventValue5",clear
sa temp,replace

u "temp/ivs",clear
mer m:1 country year yearb using "temp",keep(1 3) nogen //1 are cohorts for which demlt1 is not defined
cap matrix drop output
forv s=1/1{
forv x=1/1{
forv y=1/5{
	loc dep=word("$a",`y')
	marktouse touse `dep' demevent* ${fe`s'}
	qui su totdemevent if touse==1
	loc demsd=`r(sd)'
	drop touse
	estimates use "${savee}/tot/others/event/y`y'x`x's`s'Years5.ster"
	mata:b=st_matrix("e(b)")'
	mata:V=st_matrix("e(V)")
	mata:w=mm_cond(b:==0,0,1:/(diagonal(V)))
	*mata:w=mm_cond(b:==0,0,1)
	mata:w=w/sum(w)
	mata:beta=w'*b
	mata:se=sqrt(w'*V*w)
	mata:st_local("beta", strofreal(beta))
	mata:st_local("se", strofreal(se))
	mat t0=[`s',`x',`y',`beta',`se',`demsd',e(N_full),e(N_clust1)]
	cap confirm matrix output
	if _rc!=0 mat output=t0
	else mat output=output\t0
}
}
}
clear
svmat output
ren * (s x y beta se xsd N countries)
keep if x==1
drop s x
foreach v of varlist beta se {
	replace `v'=`v'*xsd //standarding coefficients to make it comparable
}
gen p=2*(1-normal(abs(beta/se)))
foreach v of varlist beta se N countries{
	ren `v' t0
	if inlist("`v'","beta","se") g `v'=string(t0,"%20.3fc")
	else  g `v'=string(t0,"%20.0fc")
	drop t0
}
replace beta=beta+cond(p<0.01,"***",cond(p<0.05,"**",cond(p<0.1,"*","")))
replace se="("+se+")"
so y
keep beta se N countries
sxpose,clear
g name=""
replace name="Exposure to Democracy" if _n==1
replace name="\\ Observations" if _n==3
replace name="Countries" if _n==4
egen latex=concat(name _var*),p(" & ")
cap file close myfile
file open myfile using "${savet}/eventdemx1s1Years5.tex", write replace
forv i=1/`=_N'{
	loc t0=latex in `i'
	file write myfile `"`t0' \\"' _n 
}
file close myfile


/*==============================================================================
Table A19: Exposure to Democracy and Well-Being — ESS Sample
*=============================================================================*/
*ESTIMATES
gl saveout "${savee}/tot/surOlsMain"
u "temp/1survey/ess",replace
forv x=1/2{
	foreach y in $a {
		reghdfestd `y' demiy`x' [aw=weight] if age>24 , a(${feess}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1iyess",replace
	}
}

*TABLE: IY DEMOCRACY
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/surOlsMain/y`y'x`x's1c1iyess.ster"
		outreg,${opt} merge(x`x's1c1iyess) drop(_cons)
		}
	outreg using "${savet}/x`x's1c1iyess.tex", replay(x`x's1c1iyess) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/x`x's1c1iyess.tex", spaceb("^Mean")
}

*ESTIMATES
gl saveout "${savee}/tot/surOlsMain"
u "temp/1survey/ess",replace
forv x=1/2{
	foreach y in $a {
		reghdfestd `y' demlt`x' [aw=weight], a(${feess}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1ltess",replace
	}
}

*TABLE: LIFETIME DEMOCRACY
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/surOlsMain/y`y'x`x's1c1ltess.ster"
		outreg,${opt} merge(x`x's1c1ltess) drop(_cons)
		}
	outreg using "${savet}/x`x's1c1ltess.tex", replay(x`x's1c1ltess) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/x`x's1c1ltess.tex", spaceb("^Mean")
}	
				

/*==============================================================================
Table A20: Exposure to Democracy and Well-Being — Immigrants (ESS)
*=============================================================================*/
*ESTIMATES
gl saveout "${savee}/tot/surOlsMain"
u "temp/1survey/essi",replace
gen cohort10 = floor(yearb/10)*10
egen fect_year_yearb = group(year yearb)
egen fect_yearb_yeara = group(yearb yeara)
forv s=1/3{
forv x=1/2{
	foreach y in $a {
		reghdfestd `y' demiy`x' [aw=weight] if age>24 , a(${feessi`s'}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1iyessi`s'",replace
		}
	}
}

*TABLE: IY DEMOCRACY
forv s=1/3{
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/surOlsMain/y`y'x`x's1c1iyessi`s'.ster"
		outreg,${opt} merge(x`x's1c1iyessi`s') drop(_cons)
		}
	outreg using "${savet}/x`x's1c1iyessi`s'.tex", replay(x`x's1c1iyessi`s') tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/x`x's1c1iyessi`s'.tex", spaceb("^Mean")
	}
}



/*==============================================================================
ONLINE APPENDIX TABLES
*=============================================================================*/
/*==============================================================================
Table O1: Lifetime Exposure to Democracy, Diverse Fixed Effects
*=============================================================================*/
u "temp/ivs", replace

foreach y in $a {
	cap erase ftabless_`y'.txt
	cap erase ftabless_`y'.xml
	cap erase ftables_`y'.txt
	cap erase ftables_`y'.xml
	cap erase ftable_`y'.txt
	cap erase ftable_`y'.xml
	local lvar : variable label `y'
	forv s=1/10{
    reghdfestd `y' demlt2 [aw=weight], a(${fes`s'}) cl(${cl1}) version(5)
	outreg2 demlt2 using "${savet}/ftabless_`y'.txt", $outopts1 
    }
    clean_file "${savet}/ftabless_`y'.txt" "${savet}/ftables_`y'.txt"
	erase "${savet}/ftabless_`y'.txt"
	latex_separators "${savet}/ftables_`y'.txt" "${savet}/ftable_`y'.txt"
	erase "${savet}/ftables_`y'.txt"
}

reghdfe happiness demlt2 [aw=weight], a(${fes1}) cl(${cl1})
gen used = e(sample)
count if used == 1
local num_obs = r(N)
levelsof country if used == 1, local(countries)
local num_countries : word count `countries'
drop used
file open out using "${savet}/ftable_happiness.txt", write append
file write out "\\ " _n
file write out "Observations & `num_obs' \\\\ " _n
file write out "Countries & `num_countries' \\\\ "
file close out

* VERIFICACIÓN DE FIXED EFFECTS EN CADA ESPECIFICACIÓN
local infile "${savet}/ftable_happiness.txt"
local tempfile "${savet}/ftable_happiness_tmp.txt"
local fevars "male townsize wavenum yearb country age year languagenum subregion region fect_year cohort10 feregion_year fect_wave"
local columna1  yearb country age
local columna2  townsize wavenum country age
local columna3  male wavenum country age
local columna4  male townsize yearb country age languagenum subregion
local columna5  male townsize wavenum age languagenum country
local columna6  male townsize wavenum age languagenum yearb country
local columna7  male townsize wavenum age languagenum yearb country year subregion
local columna8  male townsize wavenum age languagenum fect_year yearb region
local columna9  male townsize wavenum age languagenum fect_year cohort10 region
local columna10 male townsize wavenum age languagenum feregion_year fect_wave subregion
file open in using "`infile'", read
file open out using "`tempfile'", write replace
file read in line
while r(eof)==0 {
    file write out "`line'" _n
    file read in line
}
file close in
file write out "\hline \\" _n
foreach var of local fevars {
    local row = "`var'"
    forval i = 1/10 {
        local col "`columna`i''"
        local found = 0
        local nvars : word count `col'
        forval j = 1/`nvars' {
            local v : word `j' of `col'
            if "`v'" == "`var'" {
                local found = 1
                continue, break
            }
        }
        if `found' {
            local row "`row' & YES"
        }
        else {
            local row "`row' & NO"
        }
    }
    file write out "`row' \\" _n
}

file close out
copy "`tempfile'" "`infile'", replace
erase "`tempfile'"

* REPLACE VARIABLE NAMES WITH LABELS IN FINAL TABLE (ONLY FOR FEs)
use "temp/ivs", clear
local varlist male townsize wavenum yearb country age year languagenum ///
              subregion region fect_year cohort10 feregion_year fect_wave
tempfile temp
postfile handle str32 variable str80 label using "`temp'", replace
foreach v of local varlist {
    capture confirm variable `v'
    if _rc == 0 {
        local varlab : variable label `v'
        if `"`varlab'"' == "" local varlab "<no label>"
        post handle ("`v'") ("`varlab'")
    }
}
postclose handle
use "`temp'", clear
list, clean noobs
gen sortlen = length(variable)
gsort -sortlen
drop sortlen
expand 2 if _n == _N
replace variable = "skibidi" if _n == _N
replace label = "dopdop" if _n == _N
save "varlabels.dta", replace

use "varlabels.dta", clear
assert !missing(variable) & !missing(label)
gen id = _n
local origfile = "${savet}/ftable_happiness.txt"
tempfile temp1 temp2
copy "`origfile'" "`temp1'", replace
gen from = variable
gen to   = "<<LABEL" + string(id) + ">>"
forvalues i = 1/`=_N' {
    local f = from[`i']
    local t = to[`i']

    local frompat "`f' "
    local topat   "`t' "

    if mod(`i', 2) == 1 {
        filefilter "`temp1'" "`temp2'", from("`frompat'") to("`topat'") replace
    }
    else {
        filefilter "`temp2'" "`temp1'", from("`frompat'") to("`topat'") replace
    }
}
forvalues i = 1/`=_N' {
    local temp = to[`i']
    local label = label[`i']

    local frompat "`temp'"
    local topat  "`label'"

    if mod(`i', 2) == 1 {
        filefilter "`temp1'" "`temp2'", from("`frompat'") to("`topat'") replace
    }
    else {
        filefilter "`temp2'" "`temp1'", from("`frompat'") to("`topat'") replace
    }
}
local finalfile = cond(mod(`=_N', 2) == 1, "`temp1'", "`temp2'")
copy "`finalfile'" "`origfile'", replace
erase "varlabels.dta"


/*==============================================================================
Table O2: Lifetime Exposure to Democracy, Diverse Clusters
*=============================================================================*/
u "temp/ivs", replace

foreach y in $a {
	cap erase ctabless_`y'.txt
	cap erase ctabless_`y'.xml
	cap erase ctables_`y'.txt
	cap erase ctables_`y'.xml
	cap erase ctable_`y'.txt
	cap erase ctable_`y'.xml
	local lvar : variable label `y'
	forv c=1/10{
    reghdfestd `y' demlt2 [aw=weight], a(${fe1}) cl(${clu`c'}) version(5)
	outreg2 demlt2 using "${savet}/ctabless_`y'.txt", $outopts1 
    }
    clean_file "${savet}/ctabless_`y'.txt" "${savet}/ctables_`y'.txt"
	erase "${savet}/ctabless_`y'.txt"
	latex_separators "${savet}/ctables_`y'.txt" "${savet}/ctable_`y'.txt"
	erase "${savet}/ctables_`y'.txt"
}

reghdfe happiness demlt2 [aw=weight], a(${fes1}) cl(${cl1})
gen used = e(sample)
count if used == 1
local num_obs = r(N)
levelsof country if used == 1, local(countries)
local num_countries : word count `countries'
drop used
file open out using "${savet}/ctable_happiness.txt", write append
file write out "\\ " _n
file write out "Observations & `num_obs' \\\\ " _n
file write out "Countries & `num_countries' \\\\ "
file close out

* VERIFICACIÓN DE CLUSTERS EN CADA ESPECIFICACIÓN
local infile "${savet}/ctable_happiness.txt"
local tempfile "${savet}/ctable_happiness_tmp.txt"
local cvars "yearb year region wavenum country subregion"
local columna1  yearb
local columna2  year
local columna3  year yearb
local columna4  region year yearb
local columna5  region yearb wavenum
local columna6  country
local columna7  country year
local columna8  country yearb
local columna9  country year yearb
local columna10 subregion
file open in using "`infile'", read
file open out using "`tempfile'", write replace
file read in line
while r(eof)==0 {
    file write out "`line'" _n
    file read in line
}
file close in
file write out "\hline \\" _n
foreach var of local cvars {
    local row = "`var'"
    forval i = 1/10 {
        local col "`columna`i''"
        local found = 0
        local nvars : word count `col'
        forval j = 1/`nvars' {
            local v : word `j' of `col'
            if "`v'" == "`var'" {
                local found = 1
                continue, break
            }
        }
        if `found' {
            local row "`row' & YES"
        }
        else {
            local row "`row' & NO"
        }
    }
    file write out "`row' \\" _n
}

file close out
copy "`tempfile'" "`infile'", replace
erase "`tempfile'"

* REPLACE VARIABLE NAMES WITH LABELS IN FINAL TABLE (ONLY FOR Clusters)
use "temp/ivs", clear
local varlist yearb year region wavenum country subregion
tempfile temp
postfile handle str32 variable str80 label using "`temp'", replace
foreach v of local varlist {
    capture confirm variable `v'
    if _rc == 0 {
        local varlab : variable label `v'
        if `"`varlab'"' == "" local varlab "<no label>"
        post handle ("`v'") ("`varlab'")
    }
}
postclose handle
use "`temp'", clear
list, clean noobs
gen sortlen = length(variable)
gsort -sortlen
drop sortlen
expand 2 if _n == _N
replace variable = "skibidi" if _n == _N
replace label = "dopdop" if _n == _N
save "varlabels.dta", replace

use "varlabels.dta", clear
assert !missing(variable) & !missing(label)
gen id = _n
local origfile = "${savet}/ctable_happiness.txt"
tempfile temp1 temp2
copy "`origfile'" "`temp1'", replace
gen from = variable
gen to   = "<<LABEL" + string(id) + ">>"
forvalues i = 1/`=_N' {
    local f = from[`i']
    local t = to[`i']

    local frompat "`f' "
    local topat   "`t' "

    if mod(`i', 2) == 1 {
        filefilter "`temp1'" "`temp2'", from("`frompat'") to("`topat'") replace
    }
    else {
        filefilter "`temp2'" "`temp1'", from("`frompat'") to("`topat'") replace
    }
}
forvalues i = 1/`=_N' {
    local temp = to[`i']
    local label = label[`i']

    local frompat "`temp'"
    local topat  "`label'"

    if mod(`i', 2) == 1 {
        filefilter "`temp1'" "`temp2'", from("`frompat'") to("`topat'") replace
    }
    else {
        filefilter "`temp2'" "`temp1'", from("`frompat'") to("`topat'") replace
    }
}
local finalfile = cond(mod(`=_N', 2) == 1, "`temp1'", "`temp2'")
copy "`finalfile'" "`origfile'", replace
erase "varlabels.dta"


/*==============================================================================
Table O3 & O4: Lifetime Exposure to Democracy — Different Exposure Cuts
*=============================================================================*/
*ESTIMATES
gl saveout "${savee}/tot/olsMainK"
u "temp/ivs",replace
la var demlt01 "Exposure to Democracy (Start at Birth)"
la var demlt02 "Exposure to Democracy (Start at Birth)"
la var demlt21 "Exposure to Democracy (Start at 2)"
la var demlt22 "Exposure to Democracy (Start at 2)"
la var demlt41 "Exposure to Democracy (Start at 4)"
la var demlt42 "Exposure to Democracy (Start at 4)"
la var demlt61 "Exposure to Democracy (Start at 6)"
la var demlt62 "Exposure to Democracy (Start at 6)"
la var demlt81 "Exposure to Democracy (Start at 8)"
la var demlt82 "Exposure to Democracy (Start at 8)"
la var demlt101 "Exposure to Democracy (Start at 10)"
la var demlt102 "Exposure to Democracy (Start at 10)"
la var demlt121 "Exposure to Democracy (Start at 12)"
la var demlt122 "Exposure to Democracy (Start at 12)"
la var demlt141 "Exposure to Democracy (Start at 14)"
la var demlt142 "Exposure to Democracy (Start at 14)"
la var demlt161 "Exposure to Democracy (Start at 16)"
la var demlt162 "Exposure to Democracy (Start at 16)"

local ks 0 2 4 6 8 10 12 14 16
forvalues x = 1/2 {
    foreach y in $a {
        foreach k of local ks {
            reghdfestd `y' demlt`k'`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
            estimates save "${saveout}/dem`k'y`y'x`x's1c1lt", replace
        }
    }
}

*TABLE: LIFETIME DEMOCRACY, DIFFERENT CUTS
forvalues x = 1/2 {
    foreach k of local ks {
        mata: mata clear
        foreach y in $a {
            estimates use "${savee}/tot/olsMainK/dem`k'y`y'x`x's1c1lt.ster"
            outreg, ${opt} merge(dem`k'x`x's1c1lt) drop(_cons)
        }
        outreg using "${savet}/dem`k'x`x's1c1lt.tex", replay(dem`k'x`x's1c1lt) tex plain replace fragment nocenter varlabels
        droptabular using "${savet}/dem`k'x`x's1c1lt.tex", spaceb("^Mean")
    }
}


/*==============================================================================
Table O5: Alternative Sample Construction
*=============================================================================*/
*ESTIMATES
gl saveout "${savee}/tot/olsMainIY"
u "temp/ivs2",replace
forv x=1/2{
	foreach y in $a {
		reghdfestd `y' demiy`x' [aw=weight] if age>24 , a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1iy2",replace
	}
}

*TABLE: IY DEMOCRACY
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/olsMainIY/y`y'x`x's1c1iy2.ster"
		outreg,${opt} merge(x`x's1c1iy2) drop(_cons)
		}
	outreg using "${savet}/x`x's1c1iy2.tex", replay(x`x's1c1iy2) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/x`x's1c1iy2.tex", spaceb("^Mean")
}

*ESTIMATES
gl saveout "${savee}/tot/olsMainLT"
u "temp/ivs2",replace
forv x=1/2{
	foreach y in $a {
		reghdfestd `y' demlt`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/y`y'x`x's1c1lt2",replace
	}
}

*TABLE: LIFETIME DEMOCRACY
forv x=1/2{
	mata:mata clear
	foreach y in $a {
		estimates use "${savee}/tot/olsMainLT/y`y'x`x's1c1lt2.ster"
		outreg,${opt} merge(x`x's1c1lt2) drop(_cons)
		}
	outreg using "${savet}/x`x's1c1lt2.tex", replay(x`x's1c1lt2) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/x`x's1c1lt2.tex", spaceb("^Mean")
}


/*==============================================================================
Table O6 & O7: Heterogeneity IY & LT (Dichotomous)
*=============================================================================*/
*When creating Table 5 & 6 we create them


/*==============================================================================
Table O8, O9 & O10: Exposure to Democracy — Heterogeneities. IY (Dichotomous) & LT
*=============================================================================*/
*When creating Table A9 we create IY table
gl saveout "${savee}/tot/olsMainLT"
foreach sg of global subgroups {
    u "temp/ivs", clear
    keep if ${filter_`sg'}

    forv x = 1/2 {
        foreach y in $a {
            reghdfestd `y' demlt`x' [aw=weight], a(${fe1}) cl(${cl1}) version(5)
            estimates save "${saveout}/y`y'x`x's1c1lt_`sg'", replace
        }
    }
}

foreach sg of global subgroups {
    forv x = 1/2 {
        mata:mata clear
        foreach y in $a {
            estimates use "${savee}/tot/olsMainLT/y`y'x`x's1c1lt_`sg'.ster"
            outreg, ${opt} merge(x`x's1c1`sg'lt) drop(_cons)
        }
        outreg using "${savet}/x`x's1c1lt_`sg'.tex", replay(x`x's1c1`sg'lt) tex plain replace fragment nocenter varlabels
        droptabular using "${savet}/x`x's1c1lt_`sg'.tex", spaceb("^Mean")
    }
}


/*==============================================================================
Table O11 & O12: Exposure to Democracy, Leave one Out. IY & LT (Dichotomous)
*=============================================================================*/
*When creating Table A8 & A9 we create these tables


/*==============================================================================
Table O13 & O14: Impressionable Years Exposure, Different Time Windows 
*=============================================================================*/
*ESTIMATES
gl saveout "${savee}/tot/olsMainIY"
u "temp/ivs", replace
ren demiy1 demiy18251
ren demiy2 demiy18252
local windows 1825 1724 1926 1620 1721 1822 1827 1830 2032
local r = 1
foreach w of local windows {
    forv x = 1/2 {
        local iv = "demiy`w'`x'"
        foreach y in ${a} {
            reghdfestd `y' `iv' [aw=weight] if age>24, a(${fe1}) cl(${cl1}) version(5)
            estimates save "${saveout}/R`r'y`y'x`x's1c1iy", replace
        }
    }
    local ++r
}

*TABLE: IY DEMOCRACY
local windows 1825 1724 1926 1620 1721 1822 1827 1830 2032
local r = 1
foreach w of local windows {
    forv x = 1/2 {
        mata: mata clear
        foreach y in ${a} {
            estimates use ///
                "${savee}/tot/olsMainIY/R`r'y`y'x`x's1c1iy.ster"
            outreg, ${opt} merge(R`r'x`x's1c1iy) drop(_cons)
        }
        outreg using ///
            "${savet}/R`r'x`x's1c1iy.tex", ///
            replay(R`r'x`x's1c1iy) tex plain replace ///
            fragment nocenter varlabels

        droptabular using ///
            "${savet}/R`r'x`x's1c1iy.tex", spaceb("^Mean")
    }
    local ++r
}


/*==============================================================================
Table O15: Exposure to Democracy 18-25, Alternative Variables
*=============================================================================*/
*ESTIMATES
gl saveout "${savee}/tot/olsMainIY"
u "temp/appivs",replace
forv x=2/2{
	foreach y in ${alt} {
		reghdfestd `y' demiy`x' [aw=weight] if age>24 , a(${fe1}) cl(${cl1}) version(5)
		estimates save "${saveout}/appy`y'x`x's1c1iy",replace
	}
}

*TABLE: IY DEMOCRACY
forv x=2/2{
	mata:mata clear
	foreach y in ${alt} {
		estimates use "${savee}/tot/olsMainIY/appy`y'x`x's1c1iy.ster"
		outreg,${opt} merge(appx`x's1c1iy) drop(_cons)
		}
	outreg using "${savet}/appx`x's1c1iy.tex", replay(appx`x's1c1iy) tex plain replace fragment nocenter varlabels
	droptabular using "${savet}/appx`x's1c1iy.tex", spaceb("^Mean")
}



/*==============================================================================
SOME USEFUL NUMBERS
*=============================================================================*/
*WOOLRIDGE NUMBERS
use "temp/2democracy/event/eventsDem1", clear
count
use "temp/2democracy/event/cohortsEventValue5", clear
ds demevent*
local Y = wordcount("`r(varlist)'")
display `Y'