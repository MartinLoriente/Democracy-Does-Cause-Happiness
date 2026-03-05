/*------------------------------------------------------------------------------
En este codigo se limpian las bases que tienen los outcomes (encuestas). Para limpiar
IVS se combina codigo de Stata con el excel "raw/1survey/1ivs/readSurveys.xlsx".
Si queres agregar variables, tenes que ir a ese excel. 
Las bases censuses simplemente registran las distintas combinaciones de pais-año de encuesta-cohorte
para las que tenemos datos. Despues de usan en el do que crea las exposures.
------------------------------------------------------------------------------*/

/*==============================================================================
READ SURVEY DATA

A. CLEAN SURVEYS
A1. IVS

B. CENSUSES
B1. COUNTRY-YEARB-YEAR
B2. COUNTRY-YEAR
B3. COUNTRY
*=============================================================================*/

/*==============================================================================
A. CLEAN SURVEYS
*=============================================================================*/
/*==============================================================================
*A1. IVS
*=============================================================================*/
usezipped using "raw/1survey/1ivs/Ivs19812022.zip",clear

clear
gl file "raw/1survey/1ivs/Ivs19812022.zip"
gl wave "ivs"
gl keepvaradd S001 S002 S002EVS x049a G027A X002_02 regionadm*

di as input "wave"
preserve
*Use "Ivs" from "readSurveys.xlsx" 
import excel using "raw/1survey/1ivs/readSurveys.xlsx",clear sheet("Ivs") first case(l) 
*Deletes the variables with "read" different from 1
keep if name${wave}!=""&read==1
replace recode${wave}=recodeivs if recode${wave}=="="
g sort=_n
gl N=_N
forv i=1/$N{
	gl oldname`i'=name${wave} in `i'
	gl newname`i'=varname in `i'
	gl output`i'=output in `i'
	gl recode`i'=recode${wave} in `i'
	gl label`i'=label in `i'
	gl valuelabel`i'=valuelabel in `i'
}
usezipped using "${file}",clear
gl keepvar
forv i=1/$N{
	di as input "`i'. ${newname`i'}"
	di `"readvaras,oldname(${oldname`i'}) newname(${newname`i'}) output(${output`i'}) recode(${recode`i'}) label(${label`i'}) valuelabel(`"${valuelabel`i'}"') replace"'
	readvaras,oldname(${oldname`i'}) newname(${newname`i'}) output(${output`i'}) recode(${recode`i'}) label(${label`i'}) valuelabel(`"${valuelabel`i'}"') replace
	gl keepvar ${keepvar} ${newname`i'}
}
keep ${keepvar} ${keepvaradd}
g wave="${wave}"
sa "temp",replace
restore
append using "temp"

sort svyid
gen new_svyid = _n
replace svyid = new_svyid
drop new_svyid

*VARIABLES THAT NEED MORE THAN A RECODE
replace wave=cond(S001==2,"WVS"+string(S002),"EVS"+string(S002EVS))
replace wave=upper(wave)
replace yeara=. if yearb>yeara
replace age=year-yearb if !mi(yearb)
replace yearb=year-age if !mi(age)
replace townsize = 0 if townsize >= 3
replace townsize = 1 if townsize == 1 | townsize == 2
replace townsize2 = 0 if townsize2 >= 3
replace townsize2 = 1 if townsize2 == 1 | townsize == 2
label define size_label 0 "Over 20k" 1 "Under 20k"
label values townsize size_label
label values townsize2 size_label
replace townsize=townsize2 if townsize==.&!missing(townsize2) //complete townsize
replace rural=rural2 if rural==.&!missing(rural2) //complete rural
gen smalltown_rural=.
replace smalltown_rural=townsize if !missing(townsize) 
replace smalltown_rural=rural if smalltown_rural==.&!missing(rural) 
label define size_label2 0 "Big/Medium Town" 1 "Small Town or Rural"
label values smalltown_rural size_label2
replace incomeevs=incomewvs if incomeevs==.&!missing(incomewvs) //complete income
ren incomeevs income
gen income2 = (income == 3)
la var income "Income"
la var income2 "Income"
gen belief = (believegod + believehell + believeheaven + godimportant) / 4 if !missing(believegod, believehell, believeheaven, godimportant)
la var belief "Belief"
*Revisemos a ver qué mierda hacemos con lo de autonomía y freedom. Planteamos 3 opciones: promedio simple de las 3 versionadas entre 0 y 1, un promedio estandarizado, o un promedio estandarizado reescalado.

replace bornincountry=1 if bornincountry==.&G027A==1 //Complete bornincountry
replace bornincountry=0 if bornincountry==.&G027A==2
replace bornincountry=1 if bornincountry==.&X002_02==1
replace bornincountry=0 if bornincountry==.&X002_02==0
replace ageeduc=14 if ageeduc==14.5
drop S001 S002 S002EVS x049a G027A X002_02 

*CLEAN COUNTRY VARIABLE
foreach c of varlist country countryb countryb countrybm countrybf{
	
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
	replace `c'="USSR" if `c'=="U.S.S.R. (FORMER COUNTRY)" //We deal with this case below, here we just homogenize the name
	replace `c'="CZECHOSLOVAKIA" if `c'=="CZECHOSLOVAKIA (FORMER COUNTRY)" //We deal with this case below, here we just homogenize the name
	replace `c'="YUGOSLAVIA" if `c'=="YUGOSLAVIA (FORMER COUNTRY)" //We deal with this case below, here we just homogenize the name
	replace `c'="YUGOSLAVIA" if `c'=="YUGOSLAVIA, SOCIALIST FEDERAL REPUBLIC OF" //We deal with this case below, here we just homogenize the name
	
}

*AGGREGATIONS 
foreach c of varlist country countryb countrybm countrybf{
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

*DISSULUTIONS. Some judgment calls have to be made here To deal with them we follow two steps 1. If someone was born in a country that does not longer exist, we use the current country if this is part of the former, otherwise choose largest country. 2. If the person is in a new country, we assign the largest country after the dissolution
g countrybraw=countryb
replace countryb=countrybm if inlist(countrybm,"SLOVAKIA")&countryb=="CZECHOSLOVAKIA"
replace countryb=countrybm if countryb=="USSR"&inlist(countrybm,"BELARUS","KAZAKHSTAN")
replace countryb=country if inlist(country,"BOSNIA AND HERZEGOVINA","KOSOVO","MACEDONIA","CROATIA","SERBIA","SLOVENIA")&countryb=="YUGOSLAVIA"
replace countryb=countrybf if inlist(countrybf,"BOSNIA AND HERZEGOVINA","MACEDONIA")&countryb=="YUGOSLAVIA"
replace countryb="CZECHIA" if countryb=="CZECHOSLOVAKIA" //CZECHOSLOVAKIA broken in Slovakia and Czech Republic. The latter is the largest in population https://en.wikipedia.org/wiki/Czechoslovakia
replace countryb="RUSSIA" if countryb=="USSR"
replace countryb="SERBIA" if countryb=="YUGOSLAVIA" //Serbia is largest country https://en.wikipedia.org/wiki/Yugoslavia#New_states

foreach c in "AUSTRIA-HUNGARY" "CZECHOSLOVAKIA" "USSR" "YUGOSLAVIA"{
	replace countrybm=countryb if countrybm=="`c'"
	replace countrybf=countryb if countrybf=="`c'"
}

bys country /*year*/ wave:egen t0=sum(weightraw)
g weight=1000*weightraw/t0
drop t0
foreach v of varlist svyid year weightraw {
	la val `v' .
}
*Language
replace language=trim(itrim(upper(ustrto(ustrnormalize(language,"nfd"),"ascii",2))))
replace language=regexs(1) if regexm(language,":(.*)")
replace language="NOT IDENTIFIED" if inlist(language,"DONT KNOW","NOT ASKED","")
replace language="NOT IDENTIFIED" if regexm(language,"OTHER")

keep if !missing(country,yearb,year)
order wave country svyid year
so wave country svyid year
compress
savezipped using "temp/1survey/ivs",replace

/*==============================================================================
*B. CENSUSES
*=============================================================================*/
/*==============================================================================
*B1. COUNTRY-YEARB-YEAR
*=============================================================================*/
usezipped using "temp/1survey/ivs",clear
sa "temp0",replace

*Base
u country year yearb if !missing(yearb) using "temp0",replace
sa "temp",replace

*Country of birth
u countryb year yearb if !missing(yearb,countryb) using "temp0",replace
ren countryb country
append using "temp"
sa "temp",replace

*Country of birth and year came country
u countryb yeara yearb if !missing(yearb,countryb,yeara) using "temp0",replace
ren (countryb yeara) (country year)
append using "temp"
sa "temp",replace

*Democracy before being born
u country yearb if !missing(yearb) using "temp0",replace
ren yearb year
g yearb=year-20
append using "temp"
sa "temp",replace

*Country of birth and year of arrival-1
u countryb yeara yearb if !missing(yearb,countryb,yeara) using "temp0",replace
ren (countryb yeara) (country year)
replace year=cond(year-yearb>0,year-1,year)
append using "temp"
sa "temp",replace
/*
*Asianbarometer
u country yearb year if !missing(country,yearb,year) using "raw/1survey/2asianBarometer/data",clear
append using "temp"
sa "temp",replace

*Lapop
u country yearb year if !missing(country,yearb,year) using "raw/1survey/3lapop/data",clear
append using "temp"
sa "temp",replace

*Latinobarometer
u country yearb year if !missing(country,yearb,year) using "raw/1survey/4latinobarometer/data",clear
append using "temp"
sa "temp",replace

*ESS
u country yearb year if !missing(country,yearb,year) using "raw/1survey/6ess/ESS",clear
append using "temp"
sa "temp",replace
*/
*Immigrants
u countryb yeara yearb wave if !missing(yearb,countryb,yeara)&inlist(wave,"EVS4","EVS5") using "temp0",replace
ren (countryb yeara) (country year)
keep country year yearb
append using "temp"
sa "temp",replace

bys country yearb year: keep if _n==1
gegen id=group(country yearb year)
la da "Individuals census by country, year of birth and year of survey"
compress
sa "temp/1survey/censusCountryYearbYear",replace
erase "temp0.dta"

/*==============================================================================
*B2. COUNTRY-YEAR
*=============================================================================*/
u "temp/1survey/censusCountryYearbYear",replace
ren year yearsvy
expand yearsvy-yearb+1
bys country yearb yearsvy:g year=yearb-1+_n
keep country year
bys country year:keep if _n==1
la da "Census of years/country where information of democracy is required"
compress
sa "temp/1survey/censusCountryYear",replace

/*==============================================================================
*B3. COUNTRY
*=============================================================================*/
u "temp/1survey/censusCountryYear",replace
keep country
duplicates drop
la da "Countries where a measure of democracy is required"
compress
sa "temp/1survey/censusCountry",replace
erase "temp.dta"