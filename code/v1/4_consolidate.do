/*==============================================================================
CONSOLIDATE

A. IVS
A1. NON-IMMIGRANTS
A2. PLACEBO VARIABLES
A3. ALTERNATIVE OUTCOMES

B. OTHER SURVEYS
B1. ASIANBAROMETER
B2. LAPOP
B3. LATINOBAROMETER
B4. ESS
B5. ESS: IMMIGRANTS

C. OTHERS
C1. COHORT EVENT
==============================================================================*/

/*==============================================================================
*A. IVS
*=============================================================================*/
/*==============================================================================
*A1. NON IMMIGRANTS
*=============================================================================*/
usezipped using "${temp}/1_survey/ivs",clear
replace country="CZECH REPUBLIC" if country=="CZECHIA"  //CountryCod key
replace country="TURKEY"         if country=="TURKIYE"  //CountryCod key
isid country using "${raw}/CountryCod" // guard: CountryCod must have unique country keys
mer m:1 country using "${raw}/CountryCod",keep(1 3) keepus(continent region)
qui count if _merge==1
noi di as error "DIAGNOSTIC CountryCod (A1): `r(N)' IVS respondents from countries missing in CountryCod (dropped)"
drop _merge
replace country="CZECHIA"  if country=="CZECH REPUBLIC" //Restore canonical
replace country="TURKIYE"  if country=="TURKEY"         //Restore canonical
replace region="South West Asia" if country=="NORTHERN CYPRUS" //Same as CYPRUS
replace region = "East Asia" if country == "TAIWAN (CHINA)" & missing(region)

gen region2 = ""
replace region2 = "Africa"        if inlist(region, "Central Africa", "Eastern Africa", "Northern Africa", "Southern Africa", "Western Africa")
replace region2 = "Asia"          if inlist(region, "Central Asia", "East Asia", "South Asia", "South East Asia", "South West Asia", "Northern Asia")
replace region2 = "Europe"        if inlist(region, "Central Europe", "Eastern Europe", "Northern Europe", "South East Europe", "South West Europe", "Southern Europe", "Western Europe")
replace region2 = "Latin America" if inlist(region, "Central America", "South America", "West Indies") 
replace region2 = "Latin America" if country=="MEXICO"
replace region2 = "AS America" if region == "North America" & country!="MEXICO"
replace region2 = "Oceania"       if region == "Pacific"
ren region subregion
ren region2 region
drop if bornincountry==0 //Exluding immigrants
g survey=regexm(wave,"^WVS") 
egen feregion_year=group(region year) 
egen fect_wave=group(country wave) 
egen fect_year=group(country year)  
encode wave,g(wavenum) 
encode language,g(languagenum) 
gen cohort10 = floor(yearb/10)*10 //grupos de cohorte por década

* Trust
* Most People Trusted: AM - trustmost
gen trust_most = trustmost
* Trust Family
gen trust_family=trustfamraw2
replace trust_family=trustfamraw1 if wave=="WVS2" || wave=="EVS2"
replace trust_family=strlower(trust_family)
strrec trust_family("-1. don´t know" "-1. dont know" "-10. multiple answers Mail" "-2. no answer" "-3. Not applicable" "-6. na (survey break-off)" "-8. follow-up non response" "-9. no follow-up" "a."=.) ("5. do not trust them at all" "4. do not trust at all"=1) ("4. do not trust them very much" "3. do not trust very much"=2) ("3. neither trust nor distrust them"=3) ("2. trust somewhat" "2. Trust them a little"=4) ("1. trust completely" "1. Trust them completely"=5),g(trustfam)
* Trust in Family: AM - trustfam
recode trustfam (1/4=0) (5=1),g(trust_fam)
* Trust in Neighbors: AM - trustneig
gen trust_nei = inlist(trustneig,3,4)
replace trust_nei = . if !inlist(trustneig,1,2,3,4)
* Trust in people you know: AM - trustknow
gen trust_know = inlist(trustknow,3,4)
replace trust_know = . if !inlist(trustknow,1,2,3,4)
* Trust in people you meet for the 1st time: AM - trustknowno
gen trust_strangers = inlist(trustknowno,3,4)
replace trust_strangers = . if !inlist(trustknowno,1,2,3,4)
* Trust people another religion: AM - trustrelig
gen trust_religion = inlist(trustrelig,3,4)
replace trust_religion = . if !inlist(trustrelig,1,2,3,4)
* Trust people another nationality: AM - trustctno
gen trust_nationality = inlist(trustctno,3,4)
replace trust_nationality = . if !inlist(trustctno,1,2,3,4)
* Creating Ben Enke versions of In-Group, Out-Group and Out-In-Group Trust
cap drop trust_in
egen t0=rowmiss(trust_fam trust_nei trust_know)
egen trust_in = rowmean(trust_fam trust_nei trust_know) if t0==0
la var trust_in "Trust: In-Group"
drop t0
cap drop trust_out
egen t0=rowmiss(trust_strangers trust_religion trust_nationality)
egen trust_out = rowmean(trust_strangers trust_religion trust_nationality) if t0==0
label var trust_out "Trust: Out-Group"
drop t0
cap drop trust_out_in
egen t0=rowmiss(trust_out trust_in)
gen trust_out_in = trust_out-trust_in  if t0==0
drop t0
* Most people would take advantage
replace takeadvmost = 1 if inrange(takeadvmostraw,1,5) & takeadvmost==.
replace takeadvmost = 0 if inrange(takeadvmostraw,6,10) & takeadvmost==.
rename takeadvmost takeadvmostoriginal
recode takeadvmostoriginal (1=0) (0=1) , g(takeadvmost)
la variable takeadvmost "Most People NOT Take Advantage"

la var wavenum "Wave"
la var yearb "Cohort"
la var year "Year of survey"
la var subregion "Subregion"
la var region "Region"
la var fect_year "Country x year of survey"
la var cohort10 "Cohort by decade"
la var feregion_year "Region x year of survey"
la var fect_wave "Country x wave"

keep svyid wave survey male townsize wavenum yearb country age year languagenum subregion region fect_year cohort10 feregion_year fect_wave weight income health satisfaction happiness ${alli} political childindepend childobed free2
order svyid wave survey country year
so svyid
g svyCounter=_n
order svyid svyCounter
mer m:1 country year yearb using "${temp}/2_democracy/tot/dem",keepus(dem*) keep(1 3)
qui count if _merge==1
noi di as error "DIAGNOSTIC dem.dta (A1): `r(N)' IVS obs unmatched in ETD file (country×yearb×year not in census)"
drop _merge
qui count if demlt2==.
noi di as error "LINEAGE CHECK: `r(N)' obs missing demlt2 after ETD merge (V-Dem coverage gaps — excluded from all LT/IY regressions)"
qui count if demiy2==.
noi di as error "LINEAGE CHECK: `r(N)' obs missing demiy2 after ETD merge"
mer m:1 country year yearb using "${temp}/2_democracy/tot/demComponents", ///
    keepus(comp*) keep(1 3) nogen
qui count if compiy_v2x_polyarchy==.
noi di as error "LINEAGE CHECK: `r(N)' obs missing component ETDs (V-Dem coverage or age<18)"
sa "${temp}/ivs3",replace

u "${temp}/ivs3",replace
egen z_childindepend = std(childindepend)
egen z_childobed     = std(childobed)
egen z_free2   = std(free2)
gen autonomynew = (z_childindepend + z_childobed + z_free2) / 3 if !missing(z_childindepend, z_childobed, z_free2)
sum autonomynew
*Save min/max from the full pre-removal sample; reused in ivs to ensure both datasets use the same scale
gl autonomy_min = r(min)
gl autonomy_max = r(max)
gen autonomy = (autonomynew - r(min)) / (r(max) - r(min)) + 1 if !missing(autonomynew)
la var autonomy "Autonomy"
drop autonomynew
sa "${temp}/ivs2",replace // pre-singleton-removal sample; kept for autonomy robustness checks

u "${temp}/ivs3",replace
* We make the number of observations between specifications and measures equal:
gduplicates drop 
duplicates drop 
drop if (male==. | townsize==. | wavenum==. | yearb==. | country=="" | age==. | year==. | languagenum==. | subregion=="" | region=="" | fect_year==. | cohort10==. | feregion_year==. | fect_wave==. | demlt1==. | demlt2==. | demiy1==. | demiy2==. | weight==. | income==. | health==. | satisfaction==. | happiness==.)
reghdfe health demlt2 [aw=weight], a(${fe1}) cl(${cl1}) // we avoid singletons
gen sample_keep = e(sample)
keep if sample_keep == 1
drop sample_keep

egen z_childindepend = std(childindepend)
egen z_childobed     = std(childobed)
egen z_free2   = std(free2)
gen autonomynew = (z_childindepend + z_childobed + z_free2) / 3 if !missing(z_childindepend, z_childobed, z_free2)
*Use min/max from ivs2 (full pre-removal sample) so both ivs and ivs2 autonomy are on the same scale
gen autonomy = (autonomynew - ${autonomy_min}) / (${autonomy_max} - ${autonomy_min}) + 1 if !missing(autonomynew)
la var autonomy "Autonomy"
drop autonomynew
drop if autonomy==.

*Mediator variables for mechanism analysis (country×year level)
mer m:1 country year using "${temp}/3_addVars/gdp/gdp", ///
    keepus(gdppc2gr) keep(1 3) nogen
mer m:1 country year using "${temp}/3_addVars/corruption", ///
    keepus(corruption) keep(1 3) nogen
gen transparency = 1 - corruption
la var transparency "Transparency (1 - V-Dem corruption)"
mer m:1 country year using "${temp}/3_addVars/statecap", ///
    keepus(statecapbase) keep(1 3) nogen
mer m:1 country year using "${temp}/3_addVars/healthexp", ///
    keepus(healthexp) keep(1 3) nogen
qui count if healthexp==.
noi di as error "LINEAGE CHECK: `r(N)' obs missing healthexp (expected large — WB starts 2000)"

so country yearb year
compress
sa "${temp}/ivs",replace
erase "${temp}/ivs3.dta" // intermediate file no longer needed


/*==============================================================================
*A2. PLACEBO VARIABLES
*=============================================================================*/
usezipped using "${temp}/1_survey/ivs",clear

* Trust
* Most People Trusted: AM - trustmost
gen trust_most = trustmost
* Trust Family
gen trust_family=trustfamraw2
replace trust_family=trustfamraw1 if wave=="WVS2" || wave=="EVS2"
replace trust_family=strlower(trust_family)
strrec trust_family("-1. don´t know" "-1. dont know" "-10. multiple answers Mail" "-2. no answer" "-3. Not applicable" "-6. na (survey break-off)" "-8. follow-up non response" "-9. no follow-up" "a."=.) ("5. do not trust them at all" "4. do not trust at all"=1) ("4. do not trust them very much" "3. do not trust very much"=2) ("3. neither trust nor distrust them"=3) ("2. trust somewhat" "2. Trust them a little"=4) ("1. trust completely" "1. Trust them completely"=5),g(trustfam)
* Trust in Family: AM - trustfam
recode trustfam (1/4=0) (5=1),g(trust_fam)
* Trust in Neighbors: AM - trustneig
gen trust_nei = inlist(trustneig,3,4)
replace trust_nei = . if !inlist(trustneig,1,2,3,4)
* Trust in people you know: AM - trustknow
gen trust_know = inlist(trustknow,3,4)
replace trust_know = . if !inlist(trustknow,1,2,3,4)
* Trust in people you meet for the 1st time: AM - trustknowno
gen trust_strangers = inlist(trustknowno,3,4)
replace trust_strangers = . if !inlist(trustknowno,1,2,3,4)
* Trust people another religion: AM - trustrelig
gen trust_religion = inlist(trustrelig,3,4)
replace trust_religion = . if !inlist(trustrelig,1,2,3,4)
* Trust people another nationality: AM - trustctno
gen trust_nationality = inlist(trustctno,3,4)
replace trust_nationality = . if !inlist(trustctno,1,2,3,4)

* Creating Ben Enke versions of In-Group Trust
cap drop trust_in
egen t0=rowmiss(trust_fam trust_nei trust_know)
egen trust_in = rowmean(trust_fam trust_nei trust_know) if t0==0
la var trust_in "Trust: In-Group"
drop t0

gen age5 = inlist(mod(age,10),0,5)
replace age5 = 0 if missing(age5)

keep svyid ${placebo} 
compress
sa "${temp}/1_survey/placebo",replace		


/*==============================================================================
*A3. ALTERNATIVE OUTCOMES
*=============================================================================*/
usezipped using "${temp}/1_survey/ivs",clear
replace country="CZECH REPUBLIC" if country=="CZECHIA"  //CountryCod key
replace country="TURKEY"         if country=="TURKIYE"  //CountryCod key
mer m:1 country using "${raw}/CountryCod",keep(1 3) nogen keepus(continent region)
replace country="CZECHIA"  if country=="CZECH REPUBLIC" //Restore canonical
replace country="TURKIYE"  if country=="TURKEY"         //Restore canonical
replace region="South West Asia" if country=="NORTHERN CYPRUS" //Same as CYPRUS
replace region = "East Asia" if country == "TAIWAN (CHINA)" & missing(region)

gen region2 = ""
replace region2 = "Africa"        if inlist(region, "Central Africa", "Eastern Africa", "Northern Africa", "Southern Africa", "Western Africa")
replace region2 = "Asia"          if inlist(region, "Central Asia", "East Asia", "South Asia", "South East Asia", "South West Asia", "Northern Asia")
replace region2 = "Europe"        if inlist(region, "Central Europe", "Eastern Europe", "Northern Europe", "South East Europe", "South West Europe", "Southern Europe", "Western Europe")
replace region2 = "Latin America" if inlist(region, "Central America", "South America", "West Indies") 
replace region2 = "Latin America" if country=="MEXICO"
replace region2 = "AS America" if region == "North America" & country!="MEXICO"
replace region2 = "Oceania"       if region == "Pacific"
ren region subregion
ren region2 region
drop if bornincountry==0 //Exluding immigrants
g survey=regexm(wave,"^WVS") 
egen feregion_year=group(region year) 
egen fect_wave=group(country wave) 
egen fect_year=group(country year)  
encode wave,g(wavenum) 
encode language,g(languagenum) 
gen cohort10 = floor(yearb/10)*10 //grupos de cohorte por década

la var wavenum "Wave"
la var yearb "Cohort"
la var year "Year of survey"
la var subregion "Subregion"
la var region "Region"
la var fect_year "Country x year of survey"
la var cohort10 "Cohort by decade"
la var feregion_year "Region x year of survey"
la var fect_wave "Country x wave"

keep svyid wave survey male townsize wavenum yearb country age year languagenum subregion region fect_year cohort10 feregion_year fect_wave weight ${alt}
order svyid wave survey country year
so svyid
g svyCounter=_n
order svyid svyCounter
mer m:1 country year yearb using "${temp}/2_democracy/tot/dem",keepus(dem*) keep(1 3) nogen

* We make the number of observations between specifications and measures equal:
gduplicates drop 
duplicates drop 
drop if (male==. | townsize==. | wavenum==. | yearb==. | country=="" | age==. | year==. | languagenum==. | subregion=="" | region=="" | fect_year==. | cohort10==. | feregion_year==. | fect_wave==. | demlt1==. | demlt2==. | demiy1==. | demiy2==. | weight==.)

so country yearb year
compress
sa "${temp}/appivs",replace


/*
/*==============================================================================
*B. OTHER SURVEYS
*=============================================================================*/
/*==============================================================================
*B1. ASIANBAROMETER
*=============================================================================*/
u "${g_asian}/data",replace
recode moralpoliticians (-1 7/9=.),g(opposeoneman)
drop moralpoliticians
gl raw strongleader armyrule opposition experts
gl new opposeleader opposearmy supportopposition opposeexperts
gl vmax=wordcount("${raw}")
forv i=1/$vmax{
	loc raw=word("${raw}",`i')
	loc new=word("${new}",`i')
	replace `raw'=lower(`raw')
	strrec `raw' ("strongly agree" "strongly approve"=0) ///
("somewhat agree" "approve" "somewhat approve" "agree"=1) ///
("somewhat disagree" "disapprove" "somewhat disapprove" "disagree"=2) ///
("strongly disagree" "strongly disapprove"=3) ///
("can't choose" "decline to answer" "do not understand the question" "don't understand the question" "missing"=.),g(`new')
	drop `raw'
}

la var opposeoneman "Oppose one-man rule"
la var opposeleader "Oppose strong leader"
la var opposearmy "Oppose army ruling"
la var supportopposition "Opposition allowed"
la var opposeexperts "Government over experts"
mer m:1 country year yearb using "${temp}/2_democracy/tot/dem",nogen keep(1 3) keepus(dem*)
mer m:1 country using "${raw}/CountryCod",keep(1 3) nogen keepus(continent region)

keep if inrange(age,18,90)
egen fect_year=group(country year)
egen feregion_age=group(region age)
egen feregion_age_year=group(region age year)

egen fect_age=group(country age)

bys country svy:egen t0=sum(weightraw)
g weight=1000*weightraw/t0
drop weightraw
drop t0
compress
sa "${temp}/1_survey/asianbarometer",replace

/*==============================================================================
*B1.2. COUNTRY-YEARB-YEAR ASIANBAROMETER
*=============================================================================*/
*Country-Year born-Year
u "${temp}/1_survey/asianbarometer",clear
keep country yearb year
keep if !missing(country,yearb,year)

bys country yearb year: keep if _n==1
gegen id=group(country yearb year)
la da "Individuals census by country, year of birth and year of survey"
compress
sa "${temp}/1_survey/censusCountryYearbYearasia",replace


/*==============================================================================
*B2. LAPOP
*=============================================================================*/
u "${g_lapop}/data",replace
decode wave,g(svy)
encode svy,g(wavenum)
recode aut1 (1=0) (2=1) (nonm=.) (miss=.),g(opposeleader)
su ing4,d
g dembetter=ing4>`r(p50)' if !missing(ing4)
la var dembetter "Democracy is better"
la var opposeleader "Oppose strong leader"
mer m:1 country year yearb using "${temp}/2_democracy/tot/dem",nogen keep(1 3) keepus(dem*)
mer m:1 country using "${raw}/CountryCod",keep(1 3) nogen keepus(continent region)
keep if inrange(age,18,90)
egen fect_year=group(country year)
egen feregion_age=group(region age)
egen feregion_age_year=group(region age year)

egen fect_age=group(country age)
bys country svy:egen t0=sum(weight1500)
g weight=1000*weight1500/t0

compress
sa "${temp}/1_survey/lapop",replace

/*==============================================================================
*B2.2. COUNTRY-YEARB-YEAR LAPOP
*=============================================================================*/
*Country-Year born-Year
u "${temp}/1_survey/lapop",clear
keep country yearb year
keep if !missing(country,yearb,year)

bys country yearb year: keep if _n==1
gegen id=group(country yearb year)
la da "Individuals census by country, year of birth and year of survey"
compress
sa "${temp}/1_survey/censusCountryYearbYearlapop",replace


/*==============================================================================
*B3. LATINOBAROMETER
*=============================================================================*/
u "${g_latibar}/data",replace
ren dembetter t0
recode t0 (1=3 "Strongly agree") (2=2 "agree") (3=1 "Disagree") (4=0 "Strongly disagree"),g(dembetter)
drop t0
recode demsupport (1=1) (2 3=0)
recode armyrule (2=1) (1=0),g(opposearmy)
g opposenondemocgov=autocracy
recode demparties (2=0) (1=1),g(opposedemnoparties)
recode demcongress (2=0) (1=1),g(opposedemnocongress)

la var dembetter "Democracy is better"
la var demsupport "Democracy is preferable"
la var armyrule "Oppose army ruling"
la var opposenondemocgov "Oppose non-democratic government"
la var demparties "Oppose to a democracy without parties"
la var demcongress "Oppose to a democracy without congress"
mer m:1 country year yearb using "${temp}/2_democracy/tot/dem",nogen keep(1 3) keepus(dem*)
mer m:1 country using "${raw}/CountryCod",keep(1 3) nogen keepus(continent region)
keep if inrange(age,18,90)
g male=gender==1
egen fect_year=group(country year)
egen feregion_age=group(region age)
egen feregion_age_year=group(region age year)

egen fect_age=group(country age)
bys country wave:egen t0=sum(weight)
replace weight=1000*weight/t0

compress
sa "${temp}/1_survey/latinobarometer",replace

/*==============================================================================
*B3.2. COUNTRY-YEARB-YEAR LATINOBAROMETER
*=============================================================================*/
*Country-Year born-Year
u "${temp}/1_survey/latinobarometer",clear
keep country yearb year
keep if !missing(country,yearb,year)

bys country yearb year: keep if _n==1
gegen id=group(country yearb year)
la da "Individuals census by country, year of birth and year of survey"
compress
sa "${temp}/1_survey/censusCountryYearbYearlat",replace
*/


/*==============================================================================
*B4. ESS
*=============================================================================*/
u "${g_ess}/ESS", replace

*we drop inmigrants and non-citizens
drop if brncntr == 2
drop if ctzcntr == 2
*livecntr livecnta cntbrth cntbrtha cntbrthb cntbrthc cntbrthd

gen year = .
* Asignar los valores correspondientes a year según el valor de essround
replace year = 2002 if essround == 1
replace year = 2004 if essround == 2
replace year = 2006 if essround == 3
replace year = 2008 if essround == 4
replace year = 2010 if essround == 5
replace year = 2012 if essround == 6
replace year = 2014 if essround == 7
replace year = 2016 if essround == 8
replace year = 2018 if essround == 9
replace year = 2020 if essround == 10
replace year = 2023 if essround == 11
ren yrbrn yearb
drop if missing(yearb)
drop if missing(year)

replace age = agea if missing(age)
replace age = year-yearb if missing(age)
ren gndr male 

*CLEAN COUNTRY VARIABLE
ren cntry country
foreach c of varlist country {
    replace `c' = "ALBANIA" if `c' == "AL"
    replace `c' = "AUSTRIA" if `c' == "AT"
    replace `c' = "BELGIUM" if `c' == "BE"
    replace `c' = "BULGARIA" if `c' == "BG"
    replace `c' = "SWITZERLAND" if `c' == "CH"
    replace `c' = "CYPRUS" if `c' == "CY"
    replace `c' = "CZECHIA" if `c' == "CZ"
    replace `c' = "GERMANY" if `c' == "DE"
    replace `c' = "DENMARK" if `c' == "DK"
    replace `c' = "ESTONIA" if `c' == "EE"
    replace `c' = "SPAIN" if `c' == "ES"
    replace `c' = "FINLAND" if `c' == "FI"
    replace `c' = "FRANCE" if `c' == "FR"
    replace `c' = "UNITED KINGDOM" if `c' == "GB"
    replace `c' = "GREECE" if `c' == "GR"
    replace `c' = "CROATIA" if `c' == "HR"
    replace `c' = "HUNGARY" if `c' == "HU"
    replace `c' = "IRELAND" if `c' == "IE"
    replace `c' = "ISRAEL" if `c' == "IL"
    replace `c' = "ICELAND" if `c' == "IS"
    replace `c' = "ITALY" if `c' == "IT"
    replace `c' = "LITHUANIA" if `c' == "LT"
    replace `c' = "LUXEMBOURG" if `c' == "LU"
    replace `c' = "LATVIA" if `c' == "LV"
    replace `c' = "MONTENEGRO" if `c' == "ME"
    replace `c' = "MACEDONIA" if `c' == "MK"
    replace `c' = "NETHERLANDS" if `c' == "NL"
    replace `c' = "NORWAY" if `c' == "NO"
    replace `c' = "POLAND" if `c' == "PL"
    replace `c' = "PORTUGAL" if `c' == "PT"
    replace `c' = "ROMANIA" if `c' == "RO"
    replace `c' = "SERBIA" if `c' == "RS"
    replace `c' = "RUSSIA" if `c' == "RU"
    replace `c' = "SWEDEN" if `c' == "SE"
    replace `c' = "SLOVENIA" if `c' == "SI"
    replace `c' = "SLOVAKIA" if `c' == "SK"
    replace `c' = "TURKIYE" if `c' == "TR"
    replace `c' = "UKRAINE" if `c' == "UA"
    replace `c' = "KOSOVO" if `c' == "XK"
}

*============================================================*
* Harmonize ESS outcomes to match IVS naming and structure   *
*============================================================*
*-------------------------------*
* 1. Income (Low / Medium / High)
*-------------------------------*
gen income = .
replace income = 3 if hincfel == 1   // living comfortably
replace income = 2 if hincfel == 2   // coping
replace income = 1 if inlist(hincfel, 3, 4)  // difficult / very difficult
label define income 1 "Low" 2 "Medium" 3 "High"
label values income income
label var income "Household income group (Low/Med/High)"

*-------------------------------*
* 2. Health (0 = Poor, 1 = Good)
*-------------------------------*
gen health2 = .
replace health2 = 1 if inlist(health, 1, 2)  // Very good, Good
replace health2 = 0 if inlist(health, 3, 4, 5)  // Fair, Bad, Very bad
label define health2 0 "Poor" 1 "Good"
label values health2 health2
label var health2 "Self-rated health (Good=1)"
drop health
ren health2 health

*-------------------------------*
* 3. Autonomy (1–2 scale)
*-------------------------------*
* impfree: 1 = very much like me → 6 = not like me at all
* invert so higher = more autonomy, then rescale 1–2
gen impfree_inv = 7 - impfree if inrange(impfree,1,6)
egen z_impfree = std(impfree_inv)
summ z_impfree, meanonly
gen autonomy = (z_impfree - r(min)) / (r(max) - r(min)) + 1
label var autonomy "Perceived autonomy (1–2 scale)"

*-------------------------------*
* 4. Life satisfaction (1–10)
*-------------------------------*
gen satisfaction = .
replace satisfaction = stflife
replace satisfaction = . if stflife < 1 | stflife > 10
label var satisfaction "Life satisfaction (1–10)"

*-------------------------------*
* 5. Happiness (1–10, to match WVS coding)
*-------------------------------*
gen happiness = .
replace happiness = happy
replace happiness = . if happy < 1 | happy > 10
label var happiness "Happiness (1–10)"

ren essround wave
ren idno id

keep id year yearb male eduyrs country age wave dweight income health autonomy satisfaction happiness
ren dweight weight

mer m:1 country year yearb using "${temp}/2_democracy/tot/dem",keepus(dem*) keep(1 3) nogen

* We make the number of observations between specifications and measures equal:
gduplicates drop 
duplicates drop 
drop if (male==. | wave==. | yearb==. | country=="" | age==. | year==. | demlt1==. | demlt2==. | demiy1==. | demiy2==. | weight==. | income==. | health==. | autonomy==. | satisfaction==. | happiness==.)
reghdfe health demlt2 [aw=weight], a(${feess}) cl(${cl1}) // we avoid singletons
gen sample_keep = e(sample)
keep if sample_keep == 1
drop sample_keep

la data "ESS"
compress
sa "${temp}/1_survey/ess",replace

/*==============================================================================
*B4.2. COUNTRY-YEARB-YEAR ESS
*=============================================================================*/
*Country-Year born-Year
u "${temp}/1_survey/ess",clear
keep country yearb year
keep if !missing(country,yearb,year)

bys country yearb year: keep if _n==1
gegen id=group(country yearb year)
la da "Individuals census by country, year of birth and year of survey"
compress
sa "${temp}/1_survey/censusCountryYearbYearess",replace


/*==============================================================================
*B5. ESS: IMMIGRANTS
*=============================================================================*/
u "${g_ess}/ESS", replace

*we drop non-immigrants 
drop if brncntr == 1

gen year = .
* Asignar los valores correspondientes a year según el valor de essround
replace year = 2002 if essround == 1
replace year = 2004 if essround == 2
replace year = 2006 if essround == 3
replace year = 2008 if essround == 4
replace year = 2010 if essround == 5
replace year = 2012 if essround == 6
replace year = 2014 if essround == 7
replace year = 2016 if essround == 8
replace year = 2018 if essround == 9
replace year = 2020 if essround == 10
replace year = 2023 if essround == 11
ren yrbrn yearb
drop if missing(yearb)
drop if missing(year)

replace age = agea if missing(age)
replace age = year-yearb if missing(age)
ren gndr male 
ren essround wave
ren idno id

gen birth_country = cntbrth
replace birth_country = cntbrtha if birth_country == ""
replace birth_country = cntbrthb if birth_country == ""
replace birth_country = cntbrthc if birth_country == ""
replace birth_country = cntbrthd if birth_country == ""
drop cntbrth cntbrtha cntbrthb cntbrthc cntbrthd brncntr 
drop if ctzcntr == .a
drop if ctzcntr == .b
drop if ctzcntr == .c

gen years_arrival = . 
replace years_arrival = year - livecnta if livecnta < . 
replace years_arrival = 0.5 if years_arrival==. & livecntr==1
replace years_arrival = 3   if years_arrival==. & livecntr==2
replace years_arrival = 8   if years_arrival==. & livecntr==3
replace years_arrival = 15  if years_arrival==. & livecntr==4
replace years_arrival = 25  if years_arrival==. & livecntr==5
replace years_arrival = 0 if years_arrival < 0
replace years_arrival = age if years_arrival > age

*CLEAN COUNTRY VARIABLE
ren cntry country
foreach c of varlist country {
    replace `c' = "ALBANIA" if `c' == "AL"
    replace `c' = "AUSTRIA" if `c' == "AT"
    replace `c' = "BELGIUM" if `c' == "BE"
    replace `c' = "BULGARIA" if `c' == "BG"
    replace `c' = "SWITZERLAND" if `c' == "CH"
    replace `c' = "CYPRUS" if `c' == "CY"
    replace `c' = "CZECHIA" if `c' == "CZ"
    replace `c' = "GERMANY" if `c' == "DE"
    replace `c' = "DENMARK" if `c' == "DK"
    replace `c' = "ESTONIA" if `c' == "EE"
    replace `c' = "SPAIN" if `c' == "ES"
    replace `c' = "FINLAND" if `c' == "FI"
    replace `c' = "FRANCE" if `c' == "FR"
    replace `c' = "UNITED KINGDOM" if `c' == "GB"
    replace `c' = "GREECE" if `c' == "GR"
    replace `c' = "CROATIA" if `c' == "HR"
    replace `c' = "HUNGARY" if `c' == "HU"
    replace `c' = "IRELAND" if `c' == "IE"
    replace `c' = "ISRAEL" if `c' == "IL"
    replace `c' = "ICELAND" if `c' == "IS"
    replace `c' = "ITALY" if `c' == "IT"
    replace `c' = "LITHUANIA" if `c' == "LT"
    replace `c' = "LUXEMBOURG" if `c' == "LU"
    replace `c' = "LATVIA" if `c' == "LV"
    replace `c' = "MONTENEGRO" if `c' == "ME"
    replace `c' = "MACEDONIA" if `c' == "MK"
    replace `c' = "NETHERLANDS" if `c' == "NL"
    replace `c' = "NORWAY" if `c' == "NO"
    replace `c' = "POLAND" if `c' == "PL"
    replace `c' = "PORTUGAL" if `c' == "PT"
    replace `c' = "ROMANIA" if `c' == "RO"
    replace `c' = "SERBIA" if `c' == "RS"
    replace `c' = "RUSSIA" if `c' == "RU"
    replace `c' = "SWEDEN" if `c' == "SE"
    replace `c' = "SLOVENIA" if `c' == "SI"
    replace `c' = "SLOVAKIA" if `c' == "SK"
    replace `c' = "TURKIYE" if `c' == "TR"
    replace `c' = "UKRAINE" if `c' == "UA"
    replace `c' = "KOSOVO" if `c' == "XK"
}

*============================================================*
* Harmonize EVS outcomes to match IVS naming and structure   *
*============================================================*
*-------------------------------*
* 1. Income (Low / Medium / High)
*-------------------------------*
gen income = .
replace income = 3 if hincfel == 1   // living comfortably
replace income = 2 if hincfel == 2   // coping
replace income = 1 if inlist(hincfel, 3, 4)  // difficult / very difficult
label define income 1 "Low" 2 "Medium" 3 "High"
label values income income
label var income "Household income group (Low/Med/High)"

*-------------------------------*
* 2. Health (0 = Poor, 1 = Good)
*-------------------------------*
gen health2 = .
replace health2 = 1 if inlist(health, 1, 2)  // Very good, Good
replace health2 = 0 if inlist(health, 3, 4, 5)  // Fair, Bad, Very bad
label define health2 0 "Poor" 1 "Good"
label values health2 health2
label var health2 "Self-rated health (Good=1)"
drop health
ren health2 health

*-------------------------------*
* 3. Autonomy (1–2 scale)
*-------------------------------*
* impfree: 1 = very much like me → 6 = not like me at all
* invert so higher = more autonomy, then rescale 1–2
gen impfree_inv = 7 - impfree if inrange(impfree,1,6)
egen z_impfree = std(impfree_inv)
summ z_impfree, meanonly
gen autonomy = (z_impfree - r(min)) / (r(max) - r(min)) + 1
label var autonomy "Perceived autonomy (1–2 scale)"

*-------------------------------*
* 4. Life satisfaction (1–10)
*-------------------------------*
gen satisfaction = .
replace satisfaction = stflife
replace satisfaction = . if stflife < 1 | stflife > 10
label var satisfaction "Life satisfaction (1–10)"

*-------------------------------*
* 5. Happiness (1–10, to match WVS coding)
*-------------------------------*
gen happiness = .
replace happiness = happy
replace happiness = . if happy < 1 | happy > 10
label var happiness "Happiness (1–10)"

keep id year yearb male eduyrs country age wave dweight income health autonomy satisfaction happiness birth_country ctzcntr livecntr livecnta years_arrival
ren dweight weight

drop if missing(years_arrival)
replace age = round(age)
drop if (age - years_arrival) < 25
drop if age > 90

drop if (male==. | wave==. | yearb==. | country=="" | age==. | year==. | weight==. | income==. | autonomy==.| health==. | satisfaction==. | happiness==.)
drop livecntr livecnta

gen invalid_birth = 0
replace invalid_birth = 1 if inlist(birth_country,"1000","11","13","14","142","143","145","15","150")
replace invalid_birth = 1 if inlist(birth_country,"154","155","17","18","19","2","2000","202","21")
replace invalid_birth = 1 if inlist(birth_country,"30","3000","34","35","39","4000","419","5","5000")
replace invalid_birth = 1 if inlist(birth_country,"54","57","6000","61","6500","6666","7777","8888","9")
replace invalid_birth = 1 if inlist(birth_country,"151","29","53","9999", "66", "77", "88", "99")
replace invalid_birth = 1 if inlist(birth_country, "02","03","04","06")
drop if invalid_birth == 1
drop invalid_birth

gen countryofbirth = ""
replace countryofbirth = "Andorra" if birth_country == "AD"
replace countryofbirth = "United Arab Emirates" if birth_country == "AE"
replace countryofbirth = "Afghanistan" if birth_country == "AF"
replace countryofbirth = "Antigua and Barbuda" if birth_country == "AG"
replace countryofbirth = "Anguilla" if birth_country == "AI"
replace countryofbirth = "Albania" if birth_country == "AL"
replace countryofbirth = "Armenia" if birth_country == "AM"
replace countryofbirth = "Netherlands Antilles" if birth_country == "AN"
replace countryofbirth = "Angola" if birth_country == "AO"
replace countryofbirth = "Antarctica" if birth_country == "AQ"
replace countryofbirth = "Argentina" if birth_country == "AR"
replace countryofbirth = "American Samoa" if birth_country == "AS"
replace countryofbirth = "Austria" if birth_country == "AT"
replace countryofbirth = "Australia" if birth_country == "AU"
replace countryofbirth = "Aruba" if birth_country == "AW"
replace countryofbirth = "Azerbaijan" if birth_country == "AZ"
replace countryofbirth = "Bosnia and Herzegovina" if birth_country == "BA"
replace countryofbirth = "Barbados" if birth_country == "BB"
replace countryofbirth = "Bangladesh" if birth_country == "BD"
replace countryofbirth = "Belgium" if birth_country == "BE"
replace countryofbirth = "Burkina Faso" if birth_country == "BF"
replace countryofbirth = "Bulgaria" if birth_country == "BG"
replace countryofbirth = "Bahrain" if birth_country == "BH"
replace countryofbirth = "Burundi" if birth_country == "BI"
replace countryofbirth = "Benin" if birth_country == "BJ"
replace countryofbirth = "Bermuda" if birth_country == "BM"
replace countryofbirth = "Brunei Darussalam" if birth_country == "BN"
replace countryofbirth = "Bolivia" if birth_country == "BO"
replace countryofbirth = "Brazil" if birth_country == "BR"
replace countryofbirth = "Bahamas" if birth_country == "BS"
replace countryofbirth = "Bhutan" if birth_country == "BT"
replace countryofbirth = "Bouvet Island" if birth_country == "BV"
replace countryofbirth = "Botswana" if birth_country == "BW"
replace countryofbirth = "Belarus" if birth_country == "BY"
replace countryofbirth = "Belize" if birth_country == "BZ"
replace countryofbirth = "Canada" if birth_country == "CA"
replace countryofbirth = "Cocos (Keeling) Islands" if birth_country == "CC"
replace countryofbirth = "Congo, The Democratic Republic of the" if birth_country == "CD"
replace countryofbirth = "Central African Republic" if birth_country == "CF"
replace countryofbirth = "Congo" if birth_country == "CG"
replace countryofbirth = "Switzerland" if birth_country == "CH"
replace countryofbirth = "Côte d'Ivoire" if birth_country == "CI"
replace countryofbirth = "Cook Islands" if birth_country == "CK"
replace countryofbirth = "Chile" if birth_country == "CL"
replace countryofbirth = "Cameroon" if birth_country == "CM"
replace countryofbirth = "China" if birth_country == "CN"
replace countryofbirth = "Colombia" if birth_country == "CO"
replace countryofbirth = "Costa Rica" if birth_country == "CR"
replace countryofbirth = "Czechoslovakia" if birth_country == "CS"
replace countryofbirth = "Cuba" if birth_country == "CU"
replace countryofbirth = "Cabo Verde" if birth_country == "CV"
replace countryofbirth = "Christmas Island" if birth_country == "CX"
replace countryofbirth = "Cyprus" if birth_country == "CY"
replace countryofbirth = "Czechia" if birth_country == "CZ"
replace countryofbirth = "Germany" if birth_country == "DE"
replace countryofbirth = "Djibouti" if birth_country == "DJ"
replace countryofbirth = "Denmark" if birth_country == "DK"
replace countryofbirth = "Dominica" if birth_country == "DM"
replace countryofbirth = "Dominican Republic" if birth_country == "DO"
replace countryofbirth = "Algeria" if birth_country == "DZ"
replace countryofbirth = "Ecuador" if birth_country == "EC"
replace countryofbirth = "Estonia" if birth_country == "EE"
replace countryofbirth = "Egypt" if birth_country == "EG"
replace countryofbirth = "Western Sahara" if birth_country == "EH"
replace countryofbirth = "Eritrea" if birth_country == "ER"
replace countryofbirth = "Spain" if birth_country == "ES"
replace countryofbirth = "Ethiopia" if birth_country == "ET"
replace countryofbirth = "Finland" if birth_country == "FI"
replace countryofbirth = "Fiji" if birth_country == "FJ"
replace countryofbirth = "Falkland Islands (Malvinas)" if birth_country == "FK"
replace countryofbirth = "Micronesia, Federated States of" if birth_country == "FM"
replace countryofbirth = "Faroe Islands" if birth_country == "FO"
replace countryofbirth = "France" if birth_country == "FR"
replace countryofbirth = "Gabon" if birth_country == "GA"
replace countryofbirth = "United Kingdom" if birth_country == "GB"
replace countryofbirth = "Grenada" if birth_country == "GD"
replace countryofbirth = "Georgia" if birth_country == "GE"
replace countryofbirth = "French Guiana" if birth_country == "GF"
replace countryofbirth = "Ghana" if birth_country == "GH"
replace countryofbirth = "Gibraltar" if birth_country == "GI"
replace countryofbirth = "Greenland" if birth_country == "GL"
replace countryofbirth = "Gambia" if birth_country == "GM"
replace countryofbirth = "Guinea" if birth_country == "GN"
replace countryofbirth = "Guadeloupe" if birth_country == "GP"
replace countryofbirth = "Equatorial Guinea" if birth_country == "GQ"
replace countryofbirth = "Greece" if birth_country == "GR"
replace countryofbirth = "South Georgia and the South Sandwich Islands" if birth_country == "GS"
replace countryofbirth = "Guatemala" if birth_country == "GT"
replace countryofbirth = "Guam" if birth_country == "GU"
replace countryofbirth = "Guinea-Bissau" if birth_country == "GW"
replace countryofbirth = "Guyana" if birth_country == "GY"
replace countryofbirth = "Hong Kong" if birth_country == "HK"
replace countryofbirth = "Heard Island and McDonald Islands" if birth_country == "HM"
replace countryofbirth = "Honduras" if birth_country == "HN"
replace countryofbirth = "Croatia" if birth_country == "HR"
replace countryofbirth = "Haiti" if birth_country == "HT"
replace countryofbirth = "Hungary" if birth_country == "HU"
replace countryofbirth = "Indonesia" if birth_country == "ID"
replace countryofbirth = "Ireland" if birth_country == "IE"
replace countryofbirth = "Israel" if birth_country == "IL"
replace countryofbirth = "India" if birth_country == "IN"
replace countryofbirth = "British Indian Ocean Territory" if birth_country == "IO"
replace countryofbirth = "Iraq" if birth_country == "IQ"
replace countryofbirth = "Iran, Islamic Republic of" if birth_country == "IR"
replace countryofbirth = "Iceland" if birth_country == "IS"
replace countryofbirth = "Italy" if birth_country == "IT"
replace countryofbirth = "Jamaica" if birth_country == "JM"
replace countryofbirth = "Jordan" if birth_country == "JO"
replace countryofbirth = "Japan" if birth_country == "JP"
replace countryofbirth = "Kenya" if birth_country == "KE"
replace countryofbirth = "Kyrgyzstan" if birth_country == "KG"
replace countryofbirth = "Cambodia" if birth_country == "KH"
replace countryofbirth = "Kiribati" if birth_country == "KI"
replace countryofbirth = "Comoros" if birth_country == "KM"
replace countryofbirth = "Saint Kitts and Nevis" if birth_country == "KN"
replace countryofbirth = "Korea, Democratic People's Republic of" if birth_country == "KP"
replace countryofbirth = "Korea, Republic of" if birth_country == "KR"
replace countryofbirth = "Kuwait" if birth_country == "KW"
replace countryofbirth = "Cayman Islands" if birth_country == "KY"
replace countryofbirth = "Kazakhstan" if birth_country == "KZ"
replace countryofbirth = "Lao People's Democratic Republic" if birth_country == "LA"
replace countryofbirth = "Lebanon" if birth_country == "LB"
replace countryofbirth = "Saint Lucia" if birth_country == "LC"
replace countryofbirth = "Liechtenstein" if birth_country == "LI"
replace countryofbirth = "Sri Lanka" if birth_country == "LK"
replace countryofbirth = "Liberia" if birth_country == "LR"
replace countryofbirth = "Lesotho" if birth_country == "LS"
replace countryofbirth = "Lithuania" if birth_country == "LT"
replace countryofbirth = "Luxembourg" if birth_country == "LU"
replace countryofbirth = "Latvia" if birth_country == "LV"
replace countryofbirth = "Libyan Arab Jamahiriya" if birth_country == "LY"
replace countryofbirth = "Morocco" if birth_country == "MA"
replace countryofbirth = "Monaco" if birth_country == "MC"
replace countryofbirth = "Moldova, Republic of" if birth_country == "MD"
replace countryofbirth = "Madagascar" if birth_country == "MG"
replace countryofbirth = "Marshall Islands" if birth_country == "MH"
replace countryofbirth = "Macedonia" if birth_country == "MK"
replace countryofbirth = "Mali" if birth_country == "ML"
replace countryofbirth = "Myanmar" if birth_country == "MM"
replace countryofbirth = "Mongolia" if birth_country == "MN"
replace countryofbirth = "Macao" if birth_country == "MO"
replace countryofbirth = "Northern Mariana Islands" if birth_country == "MP"
replace countryofbirth = "Martinique" if birth_country == "MQ"
replace countryofbirth = "Mauritania" if birth_country == "MR"
replace countryofbirth = "Montserrat" if birth_country == "MS"
replace countryofbirth = "Malta" if birth_country == "MT"
replace countryofbirth = "Mauritius" if birth_country == "MU"
replace countryofbirth = "Maldives" if birth_country == "MV"
replace countryofbirth = "Malawi" if birth_country == "MW"
replace countryofbirth = "Mexico" if birth_country == "MX"
replace countryofbirth = "Malaysia" if birth_country == "MY"
replace countryofbirth = "Mozambique" if birth_country == "MZ"
replace countryofbirth = "Namibia" if birth_country == "NA"
replace countryofbirth = "New Caledonia" if birth_country == "NC"
replace countryofbirth = "Niger" if birth_country == "NE"
replace countryofbirth = "Norfolk Island" if birth_country == "NF"
replace countryofbirth = "Nigeria" if birth_country == "NG"
replace countryofbirth = "Nicaragua" if birth_country == "NI"
replace countryofbirth = "Netherlands" if birth_country == "NL"
replace countryofbirth = "Norway" if birth_country == "NO"
replace countryofbirth = "Nepal" if birth_country == "NP"
replace countryofbirth = "Nauru" if birth_country == "NR"
replace countryofbirth = "Niue" if birth_country == "NU"
replace countryofbirth = "New Zealand" if birth_country == "NZ"
replace countryofbirth = "Oman" if birth_country == "OM"
replace countryofbirth = "Panama" if birth_country == "PA"
replace countryofbirth = "Peru" if birth_country == "PE"
replace countryofbirth = "French Polynesia" if birth_country == "PF"
replace countryofbirth = "Papua New Guinea" if birth_country == "PG"
replace countryofbirth = "Philippines" if birth_country == "PH"
replace countryofbirth = "Pakistan" if birth_country == "PK"
replace countryofbirth = "Poland" if birth_country == "PL"
replace countryofbirth = "Saint Pierre and Miquelon" if birth_country == "PM"
replace countryofbirth = "Pitcairn" if birth_country == "PN"
replace countryofbirth = "Puerto Rico" if birth_country == "PR"
replace countryofbirth = "Palestinian Territory, Occupied" if birth_country == "PS"
replace countryofbirth = "Portugal" if birth_country == "PT"
replace countryofbirth = "Palau" if birth_country == "PW"
replace countryofbirth = "Paraguay" if birth_country == "PY"
replace countryofbirth = "Qatar" if birth_country == "QA"
replace countryofbirth = "Réunion" if birth_country == "RE"
replace countryofbirth = "Romania" if birth_country == "RO"
replace countryofbirth = "Russian Federation" if birth_country == "RU"
replace countryofbirth = "Rwanda" if birth_country == "RW"
replace countryofbirth = "Saudi Arabia" if birth_country == "SA"
replace countryofbirth = "Solomon Islands" if birth_country == "SB"
replace countryofbirth = "Seychelles" if birth_country == "SC"
replace countryofbirth = "Sudan" if birth_country == "SD"
replace countryofbirth = "Sweden" if birth_country == "SE"
replace countryofbirth = "Singapore" if birth_country == "SG"
replace countryofbirth = "Saint Helena" if birth_country == "SH"
replace countryofbirth = "Slovenia" if birth_country == "SI"
replace countryofbirth = "Svalbard and Jan Mayen" if birth_country == "SJ"
replace countryofbirth = "Slovakia" if birth_country == "SK"
replace countryofbirth = "Sierra Leone" if birth_country == "SL"
replace countryofbirth = "San Marino" if birth_country == "SM"
replace countryofbirth = "Senegal" if birth_country == "SN"
replace countryofbirth = "Somalia" if birth_country == "SO"
replace countryofbirth = "Suriname" if birth_country == "SR"
replace countryofbirth = "Sao Tome and Principe" if birth_country == "ST"
replace countryofbirth = "USSR" if birth_country == "SU"
replace countryofbirth = "El Salvador" if birth_country == "SV"
replace countryofbirth = "Syrian Arab Republic" if birth_country == "SY"
replace countryofbirth = "Swaziland" if birth_country == "SZ"
replace countryofbirth = "Turks and Caicos Islands" if birth_country == "TC"
replace countryofbirth = "Chad" if birth_country == "TD"
replace countryofbirth = "French Southern Territories" if birth_country == "TF"
replace countryofbirth = "Togo" if birth_country == "TG"
replace countryofbirth = "Thailand" if birth_country == "TH"
replace countryofbirth = "Tajikistan" if birth_country == "TJ"
replace countryofbirth = "Tokelau" if birth_country == "TK"
replace countryofbirth = "Turkmenistan" if birth_country == "TM"
replace countryofbirth = "Tunisia" if birth_country == "TN"
replace countryofbirth = "Tonga" if birth_country == "TO"
replace countryofbirth = "East Timor" if birth_country == "TP"
replace countryofbirth = "Turkiye" if birth_country == "TR"
replace countryofbirth = "Trinidad and Tobago" if birth_country == "TT"
replace countryofbirth = "Tuvalu" if birth_country == "TV"
replace countryofbirth = "Taiwan, Province of China" if birth_country == "TW"
replace countryofbirth = "Tanzania, United Republic of" if birth_country == "TZ"
replace countryofbirth = "Ukraine" if birth_country == "UA"
replace countryofbirth = "Uganda" if birth_country == "UG"
replace countryofbirth = "United States Minor Outlying Islands" if birth_country == "UM"
replace countryofbirth = "United States of America" if birth_country == "US"
replace countryofbirth = "Uruguay" if birth_country == "UY"
replace countryofbirth = "Uzbekistan" if birth_country == "UZ"
replace countryofbirth = "Holy See" if birth_country == "VA"
replace countryofbirth = "Saint Vincent and the Grenadines" if birth_country == "VC"
replace countryofbirth = "Venezuela" if birth_country == "VE"
replace countryofbirth = "Virgin Islands, British" if birth_country == "VG"
replace countryofbirth = "Virgin Islands, U.S." if birth_country == "VI"
replace countryofbirth = "Viet Nam" if birth_country == "VN"
replace countryofbirth = "Vanuatu" if birth_country == "VU"
replace countryofbirth = "Wallis and Futuna" if birth_country == "WF"
replace countryofbirth = "Samoa" if birth_country == "WS"
replace countryofbirth = "Yemen" if birth_country == "YE"
replace countryofbirth = "Mayotte" if birth_country == "YT"
replace countryofbirth = "Yugoslavia" if birth_country == "YU"
replace countryofbirth = "South Africa" if birth_country == "ZA"
replace countryofbirth = "Zambia" if birth_country == "ZM"
replace countryofbirth = "Zimbabwe" if birth_country == "ZW"
replace countryofbirth = "Bonaire, Sint Eustatius and Saba" if birth_country == "BQ"
replace countryofbirth = "Curaçao" if birth_country == "CW"
replace countryofbirth = "Jersey" if birth_country == "JE"
replace countryofbirth = "Montenegro" if birth_country == "ME"
replace countryofbirth = "Serbia" if birth_country == "RS"
replace countryofbirth = "Timor-Leste" if birth_country == "TL"
replace countryofbirth = "Kosovo" if birth_country == "XK"

*CLEAN COUNTRY OF BIRTH VARIABLE
foreach c of varlist countryofbirth{
	replace `c'=trim(itrim(upper(ustrto(ustrnormalize(`c',"nfd"),"ascii",2))))
	replace `c'="BOLIVIA" if `c'=="BOLIVIA, PLURINATIONAL STATE OF"
	replace `c'="BOSNIA AND HERZEGOVINA" if `c'=="BOSNIA" //Known informally as Bosnia https://en.wikipedia.org/wiki/Bosnia_and_Herzegovina
	replace `c'="BOSNIA AND HERZEGOVINA" if `c'=="BOSNIA HERZEGOVINA"
	replace `c'="BOSNIA AND HERZEGOVINA" if `c'=="BOSNIA-HERZEGOVINA"
	replace `c'="BRUNEI DARUSSALAM" if `c'=="BRUNEI"
	replace `c'="CONGO (REPUBLIC)" if `c'=="CONGO"
	replace `c'="CONGO (REPUBLIC)" if `c'=="CONGO, REP. OF"
	replace `c'="CONGO DR (ZAIRE)" if `c'=="CONGO, DEM. REP. OF"
	replace `c'="COTE DIVOIRE" if `c'=="CTE D'IVOIRE"
	replace `c'="CZECHIA" if `c'=="CZECH REP."
	replace `c'="CZECHIA" if `c'=="CZECH REPUBLIC"
	replace `c'="CURACAO" if `c'=="CURAAO"
	replace `c'="DOMINICAN REPUBLIC" if `c'=="DOMINICAN REP."
	replace `c'="HONG KONG (CHINA)" if `c'=="HONG KONG"
	replace `c'="HONG KONG (CHINA)" if `c'=="HONG KONG SAR"
	replace `c'="MACAU (CHINA)" if `c'=="MACAU"
	replace `c'="MACAU (CHINA)" if `c'=="MACAU SAR"
	replace `c'="MACEDONIA" if `c'=="MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF"
	replace `c'="MOLDOVA" if `c'=="MOLDOVA, REPUBLIC OF"
	replace `c'="MOLDOVA" if `c'=="MOLDAVA"
	replace `c'="MYANMAR (BURMA)" if `c'=="MYANMAR"
	replace `c'="MYANMAR (BURMA)" if `c'=="BURMA (MYANMAR)"
	replace `c'="NORTH KOREA" if `c'=="KOREA, NORTH"
	replace `c'="PALESTINE" if `c'=="PALESTINE, STATE OF"
	replace `c'="PALESTINE" if `c'=="PALESTINIAN TERRITORY, OCCUPIED"
	replace `c'="RUSSIA" if `c'=="RUSSIAN FEDERATION"
	replace `c'="SAINT KITTS AND NEVIS" if `c'=="ST. KITTS AND NEVIS"
	replace `c'="SAINT MARTIN (FRENCH)" if `c'=="SAINT MARTIN"
	replace `c'="SAMOA (WESTERN SAMOA)" if `c'=="SAMOA"
	replace `c'="SAO TOME AND PRINCIPE" if `c'=="SO TOM AND PRNCIPE"
	replace `c'="SLOVAKIA" if `c'=="SLOVAK REPUBLIC"
	replace `c'="SOUTH KOREA" if `c'=="KOREA, SOUTH"
	replace `c'="SYRIA" if `c'=="SYRIAN ARAB REPUBLIC"
	replace `c'="TAIWAN (CHINA)" if `c'=="TAIWAN ROC"
	replace `c'="TANZANIA" if `c'=="TANZANIA, UNITED REPUBLIC OF"
	replace `c'="TIMOR LESTE (EAST TIMOR)" if `c'=="TIMOR-LESTE"
	replace `c'="UNITED KINGDOM" if `c'=="GREAT BRITAIN"
	replace `c'="UNITED KINGDOM" if `c'=="UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND"
	replace `c'="UNITED STATES" if `c'=="UNITED STATES OF AMERICA"
	replace `c'="VENEZUELA" if `c'=="VENEZUELA, BOLIVARIAN REPUBLIC OF"
	replace `c'="VIETNAM" if `c'=="VIET NAM"
	replace `c'="TURKIYE" if `c'=="TURKEY" //Canonical name
	replace `c'="USSR" if `c'=="U.S.S.R. (FORMER COUNTRY)" //We deal with this case below, here we just homogenize the name
	replace `c'="CZECHOSLOVAKIA" if `c'=="CZECHOSLOVAKIA (FORMER COUNTRY)" //We deal with this case below, here we just homogenize the name
	replace `c'="YUGOSLAVIA" if `c'=="YUGOSLAVIA (FORMER COUNTRY)" //We deal with this case below, here we just homogenize the name
	replace `c'="YUGOSLAVIA" if `c'=="YUGOSLAVIA, SOCIALIST FEDERAL REPUBLIC OF" //We deal with this case below, here we just homogenize the name
	replace `c'="FINLAND" if `c'=="LAND ISLANDS"
	replace `c'="FINLAND" if `c'=="LANDS ISLANDS"
	replace `c'="FRANCE" if `c'=="RUNION"
	replace `c'="FRANCE" if `c'=="GUADELOUPE"
	replace `c'="FRANCE" if `c'=="WALLIS AND FUTUNA"
	replace `c'="FRANCE" if `c'=="FRENCH POLYNESIA"
	replace `c'="FRANCE" if `c'=="MARTINIQUE"
	replace `c'="FRANCE" if `c'=="MAYOTTE"
	replace `c'="GERMANY" if `c'=="GERMAN DEMOCRATIC REPUBLIC (FORMER COUNTRY)"
	replace `c'="GERMANY" if `c'=="GERMAN DEMOCRATIC REPUBLIC"
	replace `c'="GERMANY" if `c'=="GERMAN FEDERAL REPUBLIC"
	replace `c'="GERMANY" if `c'=="GERMANY EAST"
	replace `c'="GERMANY" if `c'=="GERMANY WEST"
	replace `c'="UNITED KINGDOM" if `c'=="NORTHERN IRELAND"
	replace `c'="" if regexm(`c',"^M49 CODE:")
	replace `c'="" if inlist(`c',"NO ANSWER","NOT APPLICABLE","OTHER","NA (SURVEY BREAK-OFF)","NOT APPLICABLE","NOT ASKED IN SURVEY","DONT KNOW")
}

drop birth_country
gen yeara = year - years_arrival 
replace yeara = round(yeara)
gen year_svy = year

ren country countryrecent
ren countryofbirth country
drop year
ren yeara year

merge m:1 country year yearb using "${temp}/2_democracy/tot/dem", nogen keep(1 3) keepus(dem*)

merge m:1 country using "${raw}/CountryCod", nogen keep(1 3) keepus(continent region)
ren (continent region) =b

ren country countryb
ren countryrecent country
ren year yeara
ren year_svy year

keep id year yearb male eduyrs country age wave weight income health autonomy satisfaction happiness countryb ctzcntr yeara demiy1 demiy2

* We make the number of observations between specifications and measures equal:
gduplicates drop 
duplicates drop 
drop if (male==. | wave==. | yearb==. | country=="" | age==. | year==. | demiy1==. | demiy2==. | weight==. | income==. | health==. | satisfaction==. | happiness==.)
reghdfe health demiy2 [aw=weight], a(${feess}) cl(${cl1}) // we avoid singletons
gen sample_keep = e(sample)
keep if sample_keep == 1
drop sample_keep

la data "ESS"
compress
sa "${temp}/1_survey/essi",replace



/*==============================================================================
*C. OTHERS
*=============================================================================*/
/*==============================================================================
*C1. COHORT EVENT
*=============================================================================*/
u if dem!=. using "${temp}/2_democracy/panelDem1",clear
foreach s in min max{ 
	bys country:egen year`s'=`s'(year)
	g t0=dem if year==year`s'
	bys country:egen regime`s'=mean(t0)
	drop t0
}
ren (regimemin regimemax) (regimestart regimeend)
egen countryid=group(country)
xtset countryid year
g transition=dem!=l.dem&!mi(dem,l.dem)
bys country:egen ntransitions=sum(transition)
keep if (ntransitions==0&year==yearmin)|(ntransitions==1&(transition==1|inlist(year,yearmin)))|(ntransitions>1&(transition==1|inlist(year,yearmin,yearmax)))
bys country (year):g n=_n
xtset countryid n
replace yearmax=f.year if ntransitions>0&n==1
replace yearmin=year if ntransitions>0&inrange(n,2,ntransitions+2)
replace yearmax=f.year if ntransitions>1&inrange(n,1,ntransitions+1)
drop if yearmin==yearmax&yearmax==l.yearmax
replace yearmax=yearmax-1 if yearmax==f.yearmin
ren dem regime
keep country yearmin yearmax regime ntransitions
so country yearmin
g event=_n
la da "Events according to dem1"
compress
sa "${temp}/2_democracy/event/eventsDem1",replace

*EXPOSURE TO EVENT BY COHORT
u "${temp}/1_survey/censusCountryYearbYear",replace
drop if inlist(country,"ANGUILLA","ARUBA","BONAIRE, SINT EUSTATIUS AND SABA","CURACAO","NETHERLANDS ANTILLES","REUNION") //not in panelDem1
keep if year-yearb>=6
joinby country using "${temp}/2_democracy/event/eventsDem1"
g t0=inrange(yearb+6,yearmin,yearmax)
g t1=inrange(year,yearmin,yearmax)
g t2=(yearb+6<=yearmin&year>yearmax)
keep if t0+t1+t2>0
g t3=(min(year,yearmax)-max(yearb+6,yearmin)+1)
bys id:egen t4=sum(t3)
drop if year-(yearb+6)+1>t4 //individuals that did not have full coverage on dem1
g demevent=t3*regime
keep country year yearb id event demevent
greshape wide demevent,i(country year yearb id) j(event)
qui foreach v of varlist demevent*{
	su `v'
	if `r(sum)'==0 drop `v'
	else replace `v'=0 if mi(`v')
}
gegen totdemevent=rowtotal(demevent*)
la da "Exposure to event by cohort"
compress
sa "${temp}/2_democracy/event/cohortsEvent",replace


*EXPOSURE TO EVENT BY COHORT AND NUMBER OF YEARS
u "${temp}/2_democracy/event/cohortsEvent",clear
qui foreach v of varlist demevent*{
	noi di "`v'"
	levelsof `v'
	foreach n of numlist `r(levels)'{
		if `n'>0 g `v'v`n'=cond(`v'==`n',`n',0) if !mi(`v')
	}
	drop `v'
}
la da "Exposure to democracy by event and number of years"
compress
savezipped using "${temp}/2_democracy/event/cohortsEventValue",replace

*3, 5 and 10 year periods
foreach n of numlist 5{
	u "${temp}/2_democracy/event/cohortsEvent",clear
	gl delta=`n'
	qui foreach v of varlist demevent*{
		noi di "`v'"
		su `v'
		loc max=ceil(`r(max)'/${delta})
		forv i=1/`max'{
			count if inrange(`v',`i'*${delta}-(${delta}-1),`i'*${delta})
			if r(N)>0 g `v'v`i'=cond(inrange(`v',`i'*${delta}-(${delta}-1),`i'*${delta}),`v',0)  if !mi(`v')
		}
		drop `v'
	}
	la da "Exposure to democracy by event and number of years in groups of `n' years"
	compress
	save "${temp}/2_democracy/event/cohortsEventValue`n'",replace
}


*EXPOSURE TO EVENT BY COHORT SUCCESS
u "${temp}/2_democracy/event/eventsDem1",replace
expand yearmax-yearmin+1
bys country yearmax yearmin:g year=yearmin+_n-1
sa temp,replace

u "${temp}/1_survey/censusCountryYearbYear",replace
ren year yearsvy
expand yearsvy-yearb+1
bys id:g year=yearb-1+_n
forv d=1/1{
	mer m:1 country year using "${temp}/2_democracy/panelDem`d'",keep(1 3) nogen keepus(dem)
	ren dem dem`d'
	g aut`d'=(1-dem`d')
}
mer m:1 country year using "${temp}/3_addVars/heM/he",nogen keep(1 3)
keep if year-yearb>=${k}
mer m:1 country year using temp,keepus(event yearmin yearmax regime) keep(1 3) nogen
sa temp,replace


qui forv s=1/4{
	noi di "suc=>`s'"
	u id country yearb year yearsvy aut1 dem1 suc`s' event using temp,replace
	ren suc`s' suc
	g uns=(1-suc)
	gl vars "aut1 dem1 suc uns"
	foreach v2 of varlist aut1 dem1{
		foreach v1 of varlist suc uns{
			g `v1'`v2'=`v1'*`v2'
			gl vars "${vars} `v1'`v2'"
		}
	}
	gl varsmiss
	foreach v of varlist $vars{
		gl varsmiss "${varsmiss} miss`v'=`v'"
	}
	gcollapse (sum) ${vars} (nmissing) ${varsmiss},by(country yearb yearsvy event)
	foreach v of varlist $vars{
		replace `v'=. if miss`v'>0
		drop miss`v'
	}
	bys country yearb yearsvy:gegen t0=sum(mi(dem1,suc))
	drop if t0>0
	drop t0
	drop aut1 dem1 suc uns
	ren (/*aut1 dem1 suc uns*/ sucaut1 unsaut1 sucdem1 unsdem1) =event
	greshape wide sucaut1event unsaut1event sucdem1event unsdem1event,i(country yearb yearsvy) j(event)
	ren yearsvy year
	order country yearb year
	so country yearb year
	ds country yearb year,not
	qui foreach v of varlist `r(varlist)'{
		su `v'
		if `r(sum)'==0 drop `v'
		else replace `v'=0 if mi(`v')
	}
	la da "Exposure to event and success by cohort"
	compress
	sa "${temp}/2_democracy/event/cohortsEventSuc`s'",replace
}
