/*------------------------------------------------------------------------------
En este codigo se limpian las bases de democracia. La variable explicativa es exposure
to democracy (ETD). ETD esta definida a nivel de pais-anio de encuesta-cohorte. 
Ejemplo: si soy un argentino nacido en 1970 y me encuestan en 2010, mi exposure to
democracy va a ser la cantidad de años entre 1976 (cuando tenia 6 anios) y 2010
en los que hubo democracia en Argentina (y todos los argentinos nacidos en 1970
y encuestados en 2010 van a tener esa misma exposure). 

Para crear exposure to democracy necesitas primero saber si hubo o no democracia
en cada pais en cada anio. Es decir, necesitas un panel a nivel pais-anio que 
indique cuando hubo democracia en cada pais. Ese es el panel que se crea en 
este codigo.

Tenes dos medidas de democracia: una binaria y una continua.
------------------------------------------------------------------------------*/

/*==============================================================================
A. CREATE PANEL OF DEMOCRACY
A1. CENSUS COUNTRIES
A2. BINARY
A3. CONTINUOUS

B. ADDITIONAL VARIABLES
B1. GROWTH
B2. TRANSPARENCY
B3. CAPACITY
B4. REDISTRIBUTION
B5. ESS
*=============================================================================*/

/*==============================================================================
A. CREATE PANEL OF DEMOCRACY
*=============================================================================*/

/*==============================================================================
A1. CENSUS COUNTRIES (we need to go beyond the census of the countries in the surveys as we need to include for democracy in the region)
*=============================================================================*/
usezipped using "${g_dem}/AcemogluNaiduRestrepoRobinson2019/DDCGdata_final.zip",clear
replace country=trim(itrim(upper(ustrto(ustrnormalize(country_name,"nfd"),"ascii",2))))
keep country year dem dem* region
replace country="BOSNIA AND HERZEGOVINA" if country=="BOSNIA & HERZEGOVINA"
replace country="SERBIA AND MONTENEGRO" if country=="SERBIA & MONTENEGRO"
replace country="COTE DIVOIRE" if country=="CTE D'IVOIRE"
replace country="SAINT KITTS AND NEVIS" if country=="ST. KITTS AND NEVIS"
replace country="CENTRAL AFRICAN REPUBLIC" if country=="CENTRAL AFRICAN REP."
replace country="CONGO (REPUBLIC)" if country=="CONGO, REPUBLIC OF"
replace country="SAO TOME AND PRINCIPE" if country=="SO TOM & PRNCIPE"
replace country="MACEDONIA" if country=="MACEDONIA, FYR"
replace country="SAINT LUCIA" if country=="ST. LUCIA"
replace country="GAMBIA" if country=="GAMBIA, THE"
replace country="SAINT VINCENT AND THE GRENADINES" if country=="ST. VINCENT & GRENS."
replace country="MYANMAR (BURMA)" if country=="MYANMAR"
replace country="SOUTH KOREA" if country=="KOREA"
replace country="VENEZUELA" if country=="VENEZUELA, REP. BOL."
replace country="CONGO DR (ZAIRE)" if country=="CONGO, DEM. REP. OF"
replace country="IRAN" if country=="IRAN, I.R. OF"
replace country="YEMEN" if country=="YEMEN, REPUBLIC OF"
replace country="SYRIA" if country=="SYRIAN ARAB REPUBLIC"
replace country="SLOVAKIA" if country=="SLOVAK REPUBLIC"
replace country="LAOS" if country=="LAO PEOPLE'S DEM.REP"
replace country="KYRGYZSTAN" if country=="KYRGYZ REPUBLIC"
replace country="SAMOA (WESTERN SAMOA)" if country=="SAMOA"
sa "temp",replace

u "${g_pop}/population",replace
keep if year==1995
mer 1:m country using "temp",keep(2 3) nogen keepus(country region)
keep country region pop
duplicates drop
drop if pop<1000000
mer 1:1 country using "${temp}/1_survey/censusCountry",keepus(country) nogen
keep country region
strrec region ("MNA"=1 "Middle East and North of Africa") ("ECA"=2 "Eastern Europe and Central Asia") ("AFR"=3 "Rest of Africa") ("LAC"=4 "Latin America and the Caribbean") ("INL"=5 "Western Europe and other developed countries") ("SAS"=6 "South Asia") ("EAP"=7 "East Asia and the Pacific"),g(regionanrr)
drop region
replace regionanrr=1 if inlist(country,"BAHRAIN","QATAR","CYPRUS","NORTHERN CYPRUS","PALESTINE")
replace regionanrr=2 if inlist(country,"KOSOVO","MONTENEGRO","SERBIA")
replace regionanrr=3 if inlist(country,"CAPE VERDE","COMOROS","DJIBOUTI","SAO TOME AND PRINCIPE","SWAZILAND")
replace regionanrr=4 if inlist(country,"ANGUILLA","PUERTO RICO","BAHAMAS","BARBADOS","SAINT LUCIA","BELIZE","DOMINICA")
replace regionanrr=4 if inlist(country,"GRENADA","GUYANA","SAINT KITTS AND NEVIS","SAINT VINCENT AND THE GRENADINES")
replace regionanrr=4 if inlist(country,"SURINAME","ARUBA","BONAIRE, SINT EUSTATIUS AND SABA","CURACAO","NETHERLANDS ANTILLES")
replace regionanrr=5 if inlist(country,"ANDORRA","FAROE ISLANDS","GIBRALTAR","ICELAND","GREENLAND","ISLE OF MAN","LIECHTENSTEIN","LUXEMBOURG","MALTA")
replace regionanrr=7 if inlist(country,"BRUNEI DARUSSALAM","HONG KONG (CHINA)","FIJI","TIMOR LESTE (EAST TIMOR)","SAMOA (WESTERN SAMOA)")
mer 1:1 country using "$dfcountrycod",keep(1 3) keepus(region) nogen
replace region="West Indies" if country=="CURACAO"
replace region="West Indies" if country=="BONAIRE, SINT EUSTATIUS AND SABA"
replace region="South West Asia" if country=="NORTHERN CYPRUS"
la var regionanrr "Region from ANRR"
la var region "More disaggregated region"
la da "Countries for which democracy is constructed"
compress
sa "${temp}/2_democracy/censusCountry",replace

/*==============================================================================
*A2. BINARY
*=============================================================================*/
*A2.1 ANRR
u "temp",clear
order country year
ren dem demANRR
keep country year demANRR
compress
sa "temp",replace

*A2.1 POLITY 4 AND FREEDOM HOUSE
*CGV only available until 2008 https://sites.google.com/site/joseantoniocheibub/datasets/democracy-and-dictatorship-revisited
*BMR only available until 2010 https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/28468

use "${g_dem}/FOfWv2.dta",clear
replacevaluescountry,country("PALESTINE") input("WEST BANK") minyear(2010) maxyear(2019) vars(status pr cl)
drop if inlist(country,"WEST BANK","GAZA STRIP")
mer 1:1 country year using "temp",nogen
sa "temp",replace

u "${g_dem}/Polity2018.dta",clear
drop if country=="ETHIOPIA"&year==1993&polity2==1 //Same category as Daron's paper
keep country year polity2
duplicates drop
mer 1:1 country year using "temp",nogen
sa "temp",replace

/*==============================================================================
*A1.3 CGV: Cheibub, Gandhi, and Vreeland (2010)
*=============================================================================*/
u "${g_dem}/ddrevisited_data_v1",clear
g country=trim(itrim(upper(ustrto(ustrnormalize(ctryname,"nfd"),"ascii",2))))
replace country="SAINT KITTS AND NEVIS" if country=="ST. KITTS AND NEVIS"
replace country="SAINT LUCIA" if country=="ST. LUCIA"
replace country="MYANMAR (BURMA)" if country=="MYANMAR"
replace country="SAMOA (WESTERN SAMOA)" if country=="SAMOA"
replace country="LIBYA" if country=="LIBYAN ARAB JAMAHIRIYA"
replace country="UNITED STATES" if country=="UNITED STATES OF AMERICA"
replace country="USSR" if country=="U.S.S.R."
ren democracy demCGV
keep country year demCGV
mer 1:1 country year using "temp",nogen
sa "temp",replace

/*==============================================================================
*A1.4 BMR: Carles Boix, Michael K. Miller, and Sebastian Rosato
*=============================================================================*/
u "${g_dem}/bmr.dta",clear
ren democracy demBMR
keep country year demBMR
mer 1:1 country year using "temp",nogen
compress
sa "${temp}/2_democracy/allSources",replace

/*==============================================================================
*DEMOCRACY BINARY
*=============================================================================*/
*usezipped using "1_Raw/2_Democracy/AcemogluNaiduRestrepoRobinson2019/DDCGdata_final.zip",clear
*replace country=trim(itrim(upper(ustrto(ustrnormalize(country_name,"nfd"),"ascii",2))))
*ed country_name year dem* if regexm(country,"GERMAN")
u "${g_dem}/bmr.dta",clear
drop if inlist(country,"BADEN","BAVARIA","CENTRAL AMERICAN UNION","GREAT COLOMBIA","MODENA","ORANGE FREE STATE","PARMA","SARDINIA","SAXONY")|inlist(country,"SICILY","TUSCANY","WURTTEMBERG") //We exclude very old countries that stop existing over time
drop if inlist(country,"HOLY SEE (VATICAN CITY)") //No data after 1870 and not in the survey
keep country year democracy
drop if democracy==.
ren democracy dem

*FIXING GERMANY UNIFICATION (Since one of the two portions was a non-democracy, we do not recode Germany as a Democracy in this period)
balancecountry,country("GERMANY") minyear(1946) maxyear(1989)
replacevaluescountry,country("GERMANY") input("GERMANY, EAST") minyear(1946) maxyear(1989) vars(dem)
drop if inlist(country,"GERMANY, EAST","GERMANY, WEST")
replace dem=0 if country=="GERMANY"&inrange(year,1946,1948)

*FIXING YEMEN UNIFICATION //Both were non democracies
balancecountry,country("YEMEN") minyear(1918) maxyear(1991)
replacevaluescountry,country("YEMEN") input("YEMEN, NORTH") minyear(1918) maxyear(1991) vars(dem)
drop if inlist(country,"YEMEN, NORTH","YEMEN, SOUTH")


*FIXING SUDAN (both have the same value)
balancecountry,country("SUDAN") minyear(2011) maxyear(2015)
replacevaluescountry,country("SUDAN") input("SUDAN, SOUTH") minyear(2011) maxyear(2015) vars(dem)
drop if inlist(country,"SUDAN, SOUTH","SUDAN, NORTH")

*FIXING ETHIOPIA-ERITREA
foreach c in "ETHIOPIA" "ERITREA"{
	balancecountry,country("`c'") minyear(1952) maxyear(1992)
	replacevaluescountry,country("`c'") input("ETHIOPIA (INCL. ERIT)") minyear(1952) maxyear(1992) vars(dem)
}
drop if country=="ETHIOPIA (INCL. ERIT)"

*FIXING PAKISTAN-BANGLADESH
foreach c in "PAKISTAN" "BANGLADESH"{
	balancecountry,country("`c'") minyear(1947) maxyear(1971)
	replacevaluescountry,country("`c'") input("PAKISTAN (INCL. BANGLAD.)") minyear(1947) maxyear(1971) vars(dem)
}
drop if country=="PAKISTAN (INCL. BANGLAD.)"

*FIXING POST-YUGOSLAVIA
drop if country=="YUGOSLAVIA, FED. REP."&year==1991 //Duplicated with country=="YUGOSLAVIA"
replace country="YUGOSLAVIA" if country=="YUGOSLAVIA, FED. REP."
balancecountry,country("YUGOSLAVIA") minyear(1878) maxyear(1920)
replacevaluescountry,country("YUGOSLAVIA") input("SERBIA") minyear(1878) maxyear(1920) vars(dem)

foreach c in "SERBIA" "BOSNIA AND HERZEGOVINA" "CROATIA" "SLOVENIA" "MONTENEGRO" "KOSOVO" "MACEDONIA" "SERBIA AND MONTENEGRO"{
	balancecountry,country("`c'") minyear(1878) maxyear(2015)
	replacevaluescountry,country("`c'") input("YUGOSLAVIA") minyear(1878) maxyear(2006) vars(dem) //note, it replace it if it is missing
}
replacevaluescountry,country("KOSOVO") input("SERBIA") minyear(2007) maxyear(2011) vars(dem) //KOSOVO part of SERBIA until 2011
replacevaluescountry,country("SERBIA AND MONTENEGRO") input("SERBIA") minyear(2007) maxyear(2015) vars(dem) //KOSOVO part of SERBIA until 2011
drop if country=="YUGOSLAVIA"

*FIXING POST-CZECHOSLOVAKIA
foreach c in "CZECH REPUBLIC" "SLOVAKIA" {
	balancecountry,country("`c'") minyear(1918) maxyear(1992)
	replacevaluescountry,country("`c'") input("CZECHOSLOVAKIA") minyear(1918) maxyear(1992) vars(dem)
}
drop if country=="CZECHOSLOVAKIA"

*FIXING POST-KOREA
foreach c in "SOUTH KOREA" "NORTH KOREA" {
	balancecountry,country("`c'") minyear(1800) maxyear(1947)
	replacevaluescountry,country("`c'") input("KOREA") minyear(1800) maxyear(1910) vars(dem)
	replace dem=0 if country=="`c'"&inrange(year,1911,1947) //Korea under Japannese rule
}
drop if country=="KOREA"

*FIXING POST-SOVIET UNION
replace country="RUSSIA" if country=="USSR"
foreach c in "ARMENIA" "AZERBAIJAN" "BELARUS" "ESTONIA" "GEORGIA" "KAZAKHSTAN" "KYRGYZSTAN" "LATVIA" "LITHUANIA" "MOLDOVA" "TAJIKISTAN" "TURKMENISTAN" "UKRAINE" "UZBEKISTAN"{
	balancecountry,country("`c'") minyear(1800) maxyear(2015)
	replacevaluescountry,country("`c'") input("RUSSIA") minyear(1800) maxyear(2015) vars(dem)
}

*FIXING VIETNAM
su year if country=="VIETNAM"
balancecountry,country("VIETNAM") minyear(1954) maxyear(1975)
replace dem=0 if country=="VIETNAM"&inrange(year,1954,1975) //Both SOUTH VIETNAM AND NORTH VIETNAM were non democracies
drop if inlist(country,"VIETNAM, NORTH","VIETNAM, SOUTH")

*FIXING SINGAPORE //See polity, transit to non-democracy
balancecountry,country("SINGAPORE") minyear(1959) maxyear(1964) //Part of Malasya in 1963-1964 that has zero  https://en.wikipedia.org/wiki/Singapore
replacevaluescountry,country("SINGAPORE") input("MALAYSIA") minyear(1963) maxyear(1964) vars(dem)
replace dem=1 if country=="SINGAPORE"&inrange(year,1959,1962)

*IRELAND, GIBRALTAR, ISLE OF MAN
balancecountry,country("IRELAND") minyear(1800) maxyear(1920)
replacevaluescountry,country("IRELAND") input("UNITED KINGDOM") minyear(1800) maxyear(1920) vars(dem)
balancecountry,country("GIBRALTAR") minyear(1966) maxyear(2015) //1966 referendum https://en.wikipedia.org/wiki/Gibraltar
replacevaluescountry,country("GIBRALTAR") input("UNITED KINGDOM") minyear(1966) maxyear(2015) vars(dem)
balancecountry,country("ISLE OF MAN") minyear(1800) maxyear(2015) //1966 referendum https://en.wikipedia.org/wiki/Gibraltar
replacevaluescountry,country("ISLE OF MAN") input("UNITED KINGDOM") minyear(1800) maxyear(2015) vars(dem)

*FAROE ISLANDS AND GREENLAND //Part of Denmark https://en.wikipedia.org/wiki/Faroe_Islands
foreach c in "FAROE ISLANDS" "GREENLAND"{
	balancecountry,country("`c'") minyear(1800) maxyear(2015)
	replacevaluescountry,country("`c'") input("DENMARK") minyear(1800) maxyear(2015) vars(dem)
}

*FINLAND //Independent from Russia https://en.wikipedia.org/wiki/Grand_Duchy_of_Finland
balancecountry,country("FINLAND") minyear(1901) maxyear(1916)
replace dem=1 if country=="FINLAND"&inrange(year,1901,1916)

*TAIWAN //part of China that was a non-demallocracy in that period //https://en.wikipedia.org/wiki/Taiwan
balancecountry,country("TAIWAN") minyear(1912) maxyear(1948)
replacevaluescountry,country("TAIWAN") input("CHINA") minyear(1912) maxyear(1948) vars(dem)

*ANDORRA //elected head of state https://en.wikipedia.org/wiki/List_of_heads_of_government_of_Andorra
balancecountry,country("ANDORRA") minyear(1981) maxyear(1993)
replace dem=1 if country=="ANDORRA"&inrange(year,1981,1993)

*INDIA //Available from CGV
balancecountry,country("INDIA") minyear(1947) maxyear(1949)
replace dem=1 if country=="INDIA"&inrange(year,1947,1949) //See CGV

*LIECHTENSTEIN//Available from CGV
balancecountry,country("LIECHTENSTEIN") minyear(1961) maxyear(1990)
replace dem=1 if country=="LIECHTENSTEIN"&inrange(year,1961,1990) //See CGV

*NORWAY //Available from polity
balancecountry,country("NORWAY") minyear(1883) maxyear(1899)
replace dem=0 if country=="NORWAY"&inrange(year,1883,1897)
replace dem=1 if country=="NORWAY"&inrange(year,1898,1899)

*HONG KONG //Available from FH
balancecountry,country("HONG KONG (CHINA)") minyear(1972) maxyear(2015)
replace dem=1 if country=="HONG KONG (CHINA)"&inrange(year,1972,2015) //See FH

*PALESTINE //Available from FH
balancecountry,country("PALESTINE") minyear(1977) maxyear(2015)
replace dem=inrange(year,1977,1988)|inrange(year,2007,2015) if country=="PALESTINE" //See FH

*PUERTO RICO //Available from FH
balancecountry,country("PUERTO RICO") minyear(1972) maxyear(2015)
replace dem=1 if country=="PUERTO RICO" //See FH

*MOROCCO
balancecountry,country("MOROCCO") minyear(1913) maxyear(1955)
replace dem=1 if country=="MOROCCO"&inrange(year,1913,1955) //Spanish controlled https://en.wikipedia.org/wiki/Morocco

*IRAQ //polity
balancecountry,country("IRAQ") minyear(1924) maxyear(1931)
replace dem=0 if country=="IRAQ"&inrange(year,1924,1931)

*NORTHERN CYPRUS//Polity 
balancecountry,country("NORTHERN CYPRUS") minyear(1960) maxyear(2015)
replacevaluescountry,country("NORTHERN CYPRUS") input("CYPRUS") minyear(1960) maxyear(1975) vars(dem)
replace dem=1 if country=="NORTHERN CYPRUS"&inrange(year,1976,2015) //fh

*RWANDA
balancecountry,country("RWANDA") minyear(1961) maxyear(1961)
replace dem=0 if country=="RWANDA"&inrange(year,1961,1961) //polity

*SAO TOME AND PRINCIPE
balancecountry,country("SAO TOME AND PRINCIPE") minyear(1975) maxyear(1975)
replace dem=0 if country=="SAO TOME AND PRINCIPE"&inrange(year,1975,1975) //CGV

*SAINT KITTS AND NEVIS
balancecountry,country("SAINT KITTS AND NEVIS") minyear(1983) maxyear(1983)
replace dem=0 if country=="SAINT KITTS AND NEVIS"&inrange(year,1983,1983) //CGV

*BRUNEI DARUSSALAM
balancecountry,country("BRUNEI DARUSSALAM") minyear(1984) maxyear(1984)
replace dem=0 if country=="BRUNEI DARUSSALAM"&inrange(year,1984,1984) //CGV

*CAMBODIA
balancecountry,country("CAMBODIA") minyear(1953) maxyear(1954)
replace dem=0 if country=="CAMBODIA"&inrange(year,1953,1954) //CGV

*JAMAICA
balancecountry,country("JAMAICA") minyear(1959) maxyear(1961)
replace dem=1 if country=="JAMAICA"&inrange(year,1959,1961) //Polity

*TIMOR LESTE (EAST TIMOR) //Part of Indonesia before 1999 https://en.wikipedia.org/wiki/East_Timor
balancecountry,country("TIMOR LESTE (EAST TIMOR)") minyear(1960) maxyear(2001)
replace dem=1 if country=="TIMOR LESTE (EAST TIMOR)"&inrange(year,1999,2001) //Fh
replacevaluescountry,country("TIMOR LESTE (EAST TIMOR)") input("INDONESIA") minyear(1960) maxyear(1998) vars(dem)

*ANDORRA
balancecountry,country("ANDORRA") minyear(1972) maxyear(1981)
replace dem=1 if country=="ANDORRA"&inrange(year,1972,1981) //Fh and https://en.wikipedia.org/wiki/History_of_Andorra

*ADD 2016-2019
sa "temp",replace
u country using "temp",replace
duplicates drop
expand 4
bys country:g year=2016+_n-1
append using "temp"
so country year
compress
sa "temp",replace

*COMPLETING THE INFORMATION FOR 2016-2019
*Define jumps in polity2 and fh that make a transition believable.
u "temp",replace
mer 1:1 country year using "${temp}/2_democracy/allSources",keep(1 3) keepus(status polity2 cl pr) nogen
egen fhindex=rowmean(cl pr)
replace fhindex=7-fhindex
ren (polity2 status) (pol fhstatus)
egen countryid=group(country)
xtset countryid year
replace pol=l.pol if year==2019 //We use the polity of 2018 for 2019 since data for 2019 is not available yet
foreach v of varlist dem pol fhindex fhstatus{
	g t0=`v' if year==2015
	bys country (year):egen `v'2015=mean(t0)
	drop t0
}
sa "temp",replace

u "temp",replace
keep if inrange(year,1972,2015)
xtset countryid year
g transition=dem!=l.dem if !mi(dem,l.dem)
g cutofffh=abs(fhindex-l.fhindex) if !mi(dem,l.dem)
g cutoffpol=abs(pol-l.pol) if !mi(dem,l.dem)
collapse (mean) cutoff* if !mi(transition),by(transition)
foreach v of varlist cutoff*{
	su `v' if transition==1,d
	gl `v'=`r(mean)'/2
}

u "temp",replace
*Changes based on Freedom House and Polity2
marktouse t0 fhindex fhindex2015 pol pol2015 if inrange(year,2015,2019)
g change=0 if t0==1
replace change=1 if change==0&pol-pol2015<-${cutoffpol}&fhindex-fhindex2015<-${cutofffh}&pol<=0&fhstatus==0
replace change=2 if change==0&pol-pol2015>${cutoffpol}&fhindex-fhindex2015>${cutofffh}&pol>0&inlist(fhstatus,1,2)
xtset countryid year
replace dem=0 if inrange(year,2016,2019)&dem2015==1&change==1
replace dem=1 if inrange(year,2016,2019)&dem2015==0&change==2
replace dem=dem2015 if inrange(year,2016,2019)&(change==0|(change==1&dem2015==0)|(change==2&dem2015==1))
drop t0 change

*Changes based on Freedom House (note no changes)
marktouse t0 fhindex fhindex2015 if inrange(year,2015,2019)&dem==.
g change=0 if t0==1
replace change=1 if change==0&fhindex-fhindex2015<-${cutofffh}&pol<=0&fhstatus==0
replace change=2 if change==0&fhindex-fhindex2015>${cutofffh}&pol>0&inlist(fhstatus,1,2)
xtset countryid year
replace dem=0 if inrange(year,2016,2019)&dem2015==1&change==1
replace dem=1 if inrange(year,2016,2019)&dem2015==0&change==2
replace dem=dem2015 if inrange(year,2016,2019)&(change==0|(change==1&dem2015==0)|(change==2&dem2015==1))
drop t0 change

*Extend aggregation below here
replacevaluescountry,country("FAROE ISLANDS") input("DENMARK") minyear(2015) maxyear(2019) vars(dem)
replacevaluescountry,country("GREENLAND") input("DENMARK") minyear(2015) maxyear(2019) vars(dem)
replacevaluescountry,country("ISLE OF MAN") input("UNITED KINGDOM") minyear(2015) maxyear(2019) vars(dem)
replacevaluescountry,country("GIBRALTAR") input("UNITED KINGDOM") minyear(2015) maxyear(2019) vars(dem)
replacevaluescountry,country("SERBIA AND MONTENEGRO") input("SERBIA") minyear(2015) maxyear(2019) vars(dem)
keep country year dem
*mer m:1 country using "3_Output/2_Democracy/CensusCountry",keep(1) nogen keepus(country) //There are some 2, mainly pacific islands.
*Canonical names: CZECHIA (from V-Dem), TURKIYE (V-Dem v14 renamed Turkey)
replace country="CZECHIA"  if country=="CZECH REPUBLIC"
replace country="TURKIYE"  if country=="TURKEY"
so country year
la da "Country/year level data on democracy, binary"
compress
sa "${temp}/2_democracy/panelDem1",replace

/*==============================================================================
*A3. CONTINUOUS
*=============================================================================*/
gl vdemhigh v2x_polyarchy v2x_libdem v2x_partipdem v2x_delibdem v2x_egaldem
gl vdemcomponents v2x_elecoff v2xel_frefair v2x_frassoc_thick v2x_suffr v2x_freexp_altinf v2x_liberal v2x_partip v2xdl_delib v2x_egal
usezipped using "${g_dem}/V-Dem-CY-Full+Others-v14.zip",clear
g country=trim(itrim(upper(ustrto(ustrnormalize(country_name,"nfd"),"ascii",2))))
replace country="MACEDONIA" if country=="NORTH MACEDONIA"
replace country="GAMBIA" if country=="THE GAMBIA"
replace country="UNITED STATES" if country=="UNITED STATES OF AMERICA"
replace country="HONG KONG (CHINA)" if country=="HONG KONG"
replace country="TIMOR LESTE (EAST TIMOR)" if country=="TIMOR-LESTE"
replace country="PALESTINE" if inlist(country,"PALESTINE/BRITISH MANDATE","PALESTINE/GAZA","PALESTINE/WEST BANK")
replace country="CONGO DR (ZAIRE)" if country=="DEMOCRATIC REPUBLIC OF THE CONGO"
replace country="COTE DIVOIRE" if country=="IVORY COAST"
replace country="MYANMAR (BURMA)" if country=="BURMA/MYANMAR"
replace country="SWAZILAND" if country=="ESWATINI"
replace country="CONGO (REPUBLIC)" if country=="REPUBLIC OF THE CONGO"
drop if inlist(country,"MODENA","TUSCANY","BAVARIA","HAMBURG","ZANZIBAR","HESSE-DARMSTADT","GERMAN DEMOCRATIC REPUBLIC","BRUNSWICK","HANOVER")
drop if inlist(country,"TWO SICILIES","WURTEMBERG","SOMALILAND","OLDENBURG","HESSE-KASSEL","SOUTH YEMEN","SAXONY","BADEN","MECKLENBURG SCHWERIN")
drop if inlist(country,"PARMA","SAXE-WEIMAR-EISENACH","NASSAU","PIEDMONT-SARDINIA","REPUBLIC OF VIETNAM")
drop if country=="PAPAL STATES" //No infopost 1861 and no in surveys
gcollapse (mean) ${vdemhigh} ${vdemcomponents} (min) v2x_regime v2x_elecreg,by(country year) //PALESTINE has some changes within year and divides West Bank and Gaza Strip
egen t0=rownonmiss(${vdemhigh})
egen t1=rownonmiss(v2x_polyarchy v2x_liberal v2x_partip v2xdl_delib v2x_egal)
egen demhigh=rowmean(${vdemhigh}) if t0==5
egen dem=rowmean(v2x_polyarchy v2x_liberal v2x_partip v2xdl_delib v2x_egal) if t1==5
drop t0 t1
recode v2x_regime (0 1=0) (2 3=1),g(dembin)
g demelec=v2x_elecreg
drop v2x_elecoff v2xel_frefair v2x_frassoc_thick v2x_suffr v2x_freexp_altinf v2x_regime v2x_elecreg
sa "temp",replace

u "temp",replace
*WE REPLICATE THE SAME STEPS AS ABOVE WHEN POSSIBLE
gl vdemvars dem dembin demelec demhigh v2x_polyarchy v2x_libdem v2x_partipdem v2x_delibdem v2x_egaldem v2x_liberal v2x_partip v2xdl_delib v2x_egal

*FIXING POST-YUGOSLAVIA
foreach c in "BOSNIA AND HERZEGOVINA" "CROATIA" "SLOVENIA" "MONTENEGRO" "KOSOVO" "MACEDONIA" "SERBIA AND MONTENEGRO"{
	balancecountry,country("`c'") minyear(1878) maxyear(2019)
	replacevaluescountry,country("`c'") input("SERBIA") minyear(1878) maxyear(2019) vars(${vdemvars})
}

*FIXING POST-CZECHOSLOVAKIA
balancecountry,country("SLOVAKIA") minyear(1918) maxyear(1992)
replacevaluescountry,country("SLOVAKIA") input("CZECHIA") minyear(1918) maxyear(1992) vars(${vdemvars})

*FIXING POST-KOREA
balancecountry,country("NORTH KOREA") minyear(1789) maxyear(1944)
replacevaluescountry,country("NORTH KOREA") input("SOUTH KOREA") minyear(1789) maxyear(1944) vars(${vdemvars})

*FIXING POST-SOVIET UNION
foreach c in "ARMENIA" "AZERBAIJAN" "BELARUS" "ESTONIA" "GEORGIA" "KAZAKHSTAN" "KYRGYZSTAN" "LATVIA" "LITHUANIA" "MOLDOVA" "TAJIKISTAN" "TURKMENISTAN" "UKRAINE" "UZBEKISTAN"{
	balancecountry,country("`c'") minyear(1789) maxyear(2019)
	replacevaluescountry,country("`c'") input("RUSSIA") minyear(1789) maxyear(1995) vars(${vdemvars})
}

*IRELAND, GIBRALTAR, ISLE OF MAN
balancecountry,country("GIBRALTAR") minyear(1966) maxyear(2015) //1966 referendum https://en.wikipedia.org/wiki/Gibraltar
replacevaluescountry,country("GIBRALTAR") input("UNITED KINGDOM") minyear(1800) maxyear(1920) vars(${vdemvars})

*NORTHERN CYPRUS//Polity
so country year
assert inrange(dem, 0, 1) if !missing(dem) // V-Dem index must stay in [0,1] after panel balancing
la da "Country/year level data on democracy, continuous"
compress
sa "${temp}/2_democracy/panelDem2",replace


/*==============================================================================
*B. ADDITIONAL VARIABLES
*=============================================================================*/
/*==============================================================================
*B1. GROWTH
*Our main gdp datasource is Madison. However, there are some countries that are not available
in that database and we use World Bank (since 1960) and StatUN (since 1970) to complete the series
*=============================================================================*/
/*==============================================================================
*B1.1 WORLD BANK
*=============================================================================*/
u "${g_gdp}/WorldBank.dta",replace
replace country="COTE DIVOIRE" if country=="COTE D'IVOIRE"
replace country="CAPE VERDE" if country=="CABO VERDE"
replace country="HONG KONG (CHINA)" if country=="HONG KONG SAR, CHINA"
replace country="VENEZUELA" if country=="VENEZUELA, RB"
replace country="MACEDONIA" if country=="NORTH MACEDONIA"
replace country="IRAN" if country=="IRAN, ISLAMIC REP."
replace country="SAMOA (WESTERN SAMOA)" if country=="SAMOA"
replace country="MYANMAR (BURMA)" if country=="MYANMAR"
replace country="YEMEN" if country=="YEMEN, REP."
replace country="CONGO DR (ZAIRE)" if country=="CONGO, DEM. REP."
replace country="LAOS" if country=="LAO PDR"
replace country="SYRIA" if country=="SYRIAN ARAB REPUBLIC"
replace country="RUSSIA" if country=="RUSSIAN FEDERATION"
replace country="EGYPT" if country=="EGYPT, ARAB REP."
replace country="CONGO (REPUBLIC)" if country=="CONGO, REP."
replace country="NORTH KOREA" if country=="KOREA, DEM. PEOPLES REP."
replace country="SOUTH KOREA" if country=="KOREA, REP."
replace country="PALESTINE" if country=="WEST BANK AND GAZA"
replace country="CZECHIA"  if inlist(country,"CZECH REPUBLIC","Czech Republic")
replace country="TURKIYE"  if inlist(country,"TURKEY","Turkey")
compress
sa "${temp}/3_addVars/gdp/worldBank",replace

/*==============================================================================
*B1.2 UNSTATS
*=============================================================================*/
import excel using "${g_gdp}/UNStats.xlsx",clear first case(l)
g country=trim(itrim(upper(ustrto(ustrnormalize(countryarea,"nfd"),"ascii",2))))
ren grossdomesticproductgdp gdppc2010
replace gdppc2010="" if gdppc2010=="..."
destring year gdppc2010,replace
keep country year gdppc2010
order country year gdppc2010
replace country="COTE DIVOIRE" if country=="COTE D'IVOIRE"
replace country="VIETNAM" if country=="VIET NAM"
replace country="CAPE VERDE" if country=="CABO VERDE"
replace country="NETHERLANDS ANTILLES" if country=="FORMER NETHERLANDS ANTILLES"
replace country="PALESTINE" if country=="STATE OF PALESTINE"
replace country="MYANMAR (BURMA)" if country=="MYANMAR"
replace country="HONG KONG (CHINA)" if country=="CHINA, HONG KONG SAR"
replace country="MOLDOVA" if country=="REPUBLIC OF MOLDOVA"
replace country="RUSSIA" if country=="RUSSIAN FEDERATION"
replace country="CONGO (REPUBLIC)" if country=="CONGO"
replace country="UNITED KINGDOM" if country=="UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND"
replace country="VENEZUELA" if country=="VENEZUELA (BOLIVARIAN REPUBLIC OF)"
replace country="SYRIA" if country=="SYRIAN ARAB REPUBLIC"
replace country="SAMOA (WESTERN SAMOA)" if country=="SAMOA"
replace country="MACEDONIA" if country=="THE FORMER YUGOSLAV REPUBLIC OF MACEDONIA"
replace country="BOLIVIA" if country=="BOLIVIA (PLURINATIONAL STATE OF)"
replace country="TANZANIA" if country=="UNITED REPUBLIC OF TANZANIA: MAINLAND"
replace country="CHINA" if country=="CHINA, PEOPLE'S REPUBLIC OF"
replace country="IRAN" if country=="IRAN, ISLAMIC REPUBLIC OF"
replace country="CONGO DR (ZAIRE)" if country=="DEMOCRATIC REPUBLIC OF THE CONGO"
*CZECHIA is the canonical name — do NOT convert to CZECH REPUBLIC here
replace country="TURKIYE"  if inlist(country,"TURKEY","Turkey")
replace country="NORTH KOREA" if country=="DEMOCRATIC PEOPLE'S REPUBLIC OF KOREA"
replace country="SOUTH KOREA" if country=="REPUBLIC OF KOREA"
replace country="LAOS" if country=="LAO PEOPLE'S DEMOCRATIC REPUBLIC"
compress
sa "${temp}/3_addVars/gdp/unStats",replace

/*==============================================================================
*B1.3 MADISON
*=============================================================================*/
u "${g_gdp}/GdpMaddison",clear
keep if year>=1840
drop if mi(cgdppc)&mi(rgdpnapc)
egen t0=group(country)
xtset t0 year
replace rgdpnapc=l.rgdpnapc*(cgdppc/l.cgdppc) if rgdpnapc==.
ren rgdpnapc gdppc2011
keep country year gdppc2011
replace country="COTE DIVOIRE" if country=="COTE D'IVOIRE"
compress
sa "${temp}/3_addVars/gdp/madison",replace

/*==============================================================================
*B1.4 MERGE
*=============================================================================*/
u "${temp}/3_addVars/gdp/unStats",replace
keep if inlist(country,"ANDORRA","ARUBA","BRUNEI DARUSSALAM","CURACAO","FIJI","SAMOA (WESTERN SAMOA)","SOMALIA","SURINAME","ANGUILLA")| ///
inlist(country,"NETHERLANDS ANTILLES","GREENLAND","KOSOVO","LIECHTENSTEIN","UNITED ARAB EMIRATES","QATAR","KUWAIT","ALGERIA","ANGOLA")
g t0=inlist(country,"NETHERLANDS ANTILLES","CURACAO")
preserve
keep if t0==1
replace country=lower(strtoname(country))
reshape wide gdppc2010,i(year) j(country) string
tsset year
replace gdppc2010netherlands_antilles=l.gdppc2010netherlands_antilles*(gdppc2010curacao/l.gdppc2010curacao) if gdppc2010netherlands_antilles==.
reshape long gdppc2010,i(year) j(country) string
replace country=upper(subinstr(country,"_"," ",.))
drop if country=="CURACAO"
sa "temp",replace
restore
drop if t0==1
append using "temp"
drop t0
sa "temp",replace

*WORLD BANK
u "${temp}/3_addVars/gdp/worldBank",replace
keep if inlist(country,"FIJI","SOMALIA","SURINAME","ISLE OF MAN","KUWAIT","ALGERIA")
keep country year gdppc_2010 gdppc_gr gdppc_lcu
mer 1:1 country year using "temp",nogen
egen t0=group(country)
xtset t0 year
replace gdppc2010=gdppc_2010 if country=="ISLE OF MAN"
forv i=1/11{
	replace gdppc2010=f.gdppc2010/(f.gdppc_2010/gdppc_2010) if gdppc2010==.
}
forv i=1/11{
	replace gdppc2010=f.gdppc2010/(f.gdppc_lcu/gdppc_lcu) if gdppc2010==.
}
drop gdppc_2010 gdppc_gr gdppc_lcu t0
sa "temp0",replace


*MADISON
gl g1 `""GIBRALTAR" "UNITED KINGDOM""'
gl g2 `""FAROE ISLANDS" "DENMARK""'
gl g3 `""SERBIA AND MONTENEGRO" "YUGOSLAVIA""'
gl g4 `""GREENLAND" "DENMARK""'
gl g5 `""ISLE OF MAN" "UNITED KINGDOM""'
gl g6 `""KOSOVO" "YUGOSLAVIA""'
gl g7 `""LIECHTENSTEIN" "GERMANY""'

u "${temp}/3_addVars/gdp/madison",replace
forv g=1/7{
	preserve
	loc t1:word 1 of ${g`g'}
	loc t2:word 2 of ${g`g'}
	keep if country=="`t2'"
	replace country="`t1'"
	sa "temp",replace
	restore
	append using "temp"

}
*Yugoslavia
g t0=inlist(country,"YUGOSLAVIA","SERBIA","SERBIA AND MONTENEGRO","KOSOVO","MONTENEGRO","CROATIA","SLOVENIA","BOSNIA AND HERZEGOVINA","MACEDONIA")
preserve
keep if t0==1
replace country=lower(strtoname(country))
reshape wide gdppc2011,i(year) j(country) string
foreach v of varlist gdppc2011*{
	replace `v'=gdppc2011yugoslavia if `v'==.
}
reshape long gdppc2011,i(year) j(country) string
replace country=upper(subinstr(country,"_"," ",.))
sa "temp",replace
restore
drop if t0==1
append using "temp"

*Czechoslovakia
replace t0=inlist(country,"CZECHOSLOVAKIA","SLOVAKIA","CZECH REPUBLIC")
preserve
keep if t0==1
replace country=lower(strtoname(country))
reshape wide gdppc2011,i(year) j(country) string
foreach v of varlist gdppc2011*{
	replace `v'=gdppc2011czechoslovakia if `v'==.
}
reshape long gdppc2011,i(year) j(country) string
replace country=upper(subinstr(country,"_"," ",.))
replace country="CZECHIA" if country=="CZECH REPUBLIC" //Canonical name
sa "temp",replace
restore
drop if t0==1
append using "temp"

*Soviet Union
replace t0=inlist(country,"FORMER USSR","RUSSIA","ARMENIA","AZERBAIJAN","BELARUS","ESTONIA","GEORGIA")| ///
inlist(country,"KAZAKHSTAN","KYRGYZSTAN","LATVIA","LITHUANIA","MOLDOVA","TAJIKISTAN","TURKMENISTAN","UKRAINE","UZBEKISTAN")
preserve
keep if t0==1
replace country=lower(strtoname(country))
reshape wide gdppc2011,i(year) j(country) string
foreach v of varlist gdppc2011*{
	replace `v'=gdppc2011former_ussr if `v'==.
}
reshape long gdppc2011,i(year) j(country) string
replace country=upper(subinstr(country,"_"," ",.))
sa "temp",replace
restore
drop if t0==1
append using "temp"
drop t0
sa "temp",replace

u "temp",replace
keep country
duplicates drop
expand 2016-1840+1
bys country:g year=1840+_n-1
mer 1:1 country year using "temp",nogen

*Ipolate GDP per capita when gap inferior to 10 years
g t0=gdppc2011!=.
g t1=gdppc2011==.
bys country:g t2=sum(t0)
replace t2=. if gdppc2011!=.
bys country t2:egen yearsipolate=sum(t1)
drop t0 t1 t2
g t0=ln(gdppc2011)
so country year
bys country:ipolate t0 year,g(t1)
replace gdppc2011=exp(t1) if gdppc2011==.&yearsipolate<=10
drop t0 t1 yearsipolate
replace gdppc2011=. if inlist(country,"UNITED ARAB EMIRATES","QATAR","KUWAIT","ALGERIA","ANGOLA") //more complete information in UNStats
mer 1:1 country year using "temp0",nogen
erase "temp0.dta"
g t0=inlist(country,"GREENLAND","ISLE OF MAN","KOSOVO","LIECHTENSTEIN")
preserve
keep if t0==1
egen t1=group(country)
xtset t1 year
forv i=1/150{
	replace gdppc2010=f.gdppc2010/(f.gdppc2011/gdppc2011) if gdppc2010==.
}
replace gdppc2011=gdppc2010
drop gdppc2010 t0 t1
sa "temp",replace
restore
drop if t0==1
append using "temp"
replace gdppc2011=gdppc2010 if gdppc2011==. //Information for the whole country
drop t0 gdppc2010
mer m:1 country using "${temp}/2_democracy/censusCountry",nogen keep(3) keepus(country)
so country year
drop if gdppc2011==.
egen t0=group(country)
xtset t0 year
drop t0
compress
sa "temp",replace


u "${temp}/3_addVars/gdp/unStats",replace
mer 1:1 country year using "${temp}/3_addVars/gdp/worldBank",keepus(gdppc_2010 gdppc_gr gdppc_lcu) nogen
mer m:1 country using "${temp}/2_democracy/censusCountry",nogen keep(3) keepus(country)
egen t0=group(country)
xtset t0 year
forv i=1/30{
	replace gdppc2010=f.gdppc2010/(f.gdppc_2010/gdppc_2010) if gdppc2010==.
}
forv i=1/11{
	replace gdppc2010=f.gdppc2010/(f.gdppc_lcu/gdppc_lcu) if gdppc2010==.
}
replace gdppc2010=gdppc_2010 if country=="ISLE OF MAN"
keep country year gdppc2010
mer 1:1 country year using "temp",nogen
so country year
bys country:g t1=_n
egen t0=group(country)
xtset t0 t1
replace gdppc2011=l.gdppc2011*(gdppc2010/l.gdppc2010) if gdppc2011==.
replace gdppc2010=l.gdppc2010*(gdppc2011/l.gdppc2011) if gdppc2010==.
forv i=1/150{
	replace gdppc2010=f.gdppc2010/(f.gdppc2011/gdppc2011) if gdppc2010==.
}
replace gdppc2010=gdppc2011 if inlist(country,"FAROE ISLANDS","GIBRALTAR","NETHERLANDS ANTILLES","SERBIA AND MONTENEGRO","TAIWAN")
drop if gdppc2010==.
xtset t0 year
ren (gdppc2010 gdppc2011) (gdppc1 gdppc2)
forv i=1/2{
	g gdppc`i'gr=gdppc`i'/l.gdppc`i'-1
	g gdppc`i'grpost=f.gdppc`i'gr
	g gdppc`i'grpre=l.gdppc`i'gr
}
foreach w in gr grpost grpre{
	bys country:egen t2=sum(!missing(gdppc2`w'))
	replace gdppc2`w'=gdppc1`w' if t2==0
	drop t2
}
drop t0 t1
la var gdppc1 "GDP per capita: base UNStats"
la var gdppc2 "GDP per capita: base Madison"
la var gdppc1gr "GDP per capita growth: base UNStats"
la var gdppc2gr "GDP per capita growth: base Madison"
la var gdppc1grpost "GDP per capita growth post: base UNStats"
la var gdppc2grpost "GDP per capita growth post: base Madison"
la var gdppc1grpre "GDP per capita growth pre: base UNStats"
la var gdppc2grpre "GDP per capita growth pre: base Madison"
*Final canonical name enforcement before save
replace country="CZECHIA"  if inlist(country,"CZECH REPUBLIC","Czech Republic")
replace country="TURKIYE"  if inlist(country,"TURKEY","Turkey")
compress
sa "${temp}/3_addVars/gdp/gdp",replace


/*==============================================================================
*B2. TRANSPARENCY
*=============================================================================*/
usezipped using "${g_dem}/V-Dem-CY-Full+Others-v14.zip",clear
g country=trim(itrim(upper(ustrto(ustrnormalize(country_name,"nfd"),"ascii",2))))
replace country="MACEDONIA" if country=="NORTH MACEDONIA"
replace country="GAMBIA" if country=="THE GAMBIA"
replace country="UNITED STATES" if country=="UNITED STATES OF AMERICA"
replace country="HONG KONG (CHINA)" if country=="HONG KONG"
replace country="TIMOR LESTE (EAST TIMOR)" if country=="TIMOR-LESTE"
replace country="PALESTINE" if inlist(country,"PALESTINE/BRITISH MANDATE","PALESTINE/GAZA","PALESTINE/WEST BANK")
replace country="CONGO DR (ZAIRE)" if country=="DEMOCRATIC REPUBLIC OF THE CONGO"
replace country="COTE DIVOIRE" if country=="IVORY COAST"
replace country="MYANMAR (BURMA)" if country=="BURMA/MYANMAR"
replace country="SWAZILAND" if country=="ESWATINI"
replace country="CONGO (REPUBLIC)" if country=="REPUBLIC OF THE CONGO"
drop if inlist(country,"MODENA","TUSCANY","BAVARIA","HAMBURG","ZANZIBAR","HESSE-DARMSTADT","GERMAN DEMOCRATIC REPUBLIC","BRUNSWICK","HANOVER")
drop if inlist(country,"TWO SICILIES","WURTEMBERG","SOMALILAND","OLDENBURG","HESSE-KASSEL","SOUTH YEMEN","SAXONY","BADEN","MECKLENBURG SCHWERIN")
drop if inlist(country,"PARMA","SAXE-WEIMAR-EISENACH","NASSAU","PIEDMONT-SARDINIA","REPUBLIC OF VIETNAM")
drop if country=="PAPAL STATES" //No infopost 1861 and no in surveys

keep country year v2x_corr
gcollapse (mean) v2x_corr,by(country year) //PALESTINE has some changes within year and divides West Bank and Gaza Strip
sa "temp",replace

u "temp",replace

gl vdemvars v2x_corr

*FIXING POST-YUGOSLAVIA
foreach c in "BOSNIA AND HERZEGOVINA" "CROATIA" "SLOVENIA" "MONTENEGRO" "KOSOVO" "MACEDONIA" "SERBIA AND MONTENEGRO"{
	balancecountry,country("`c'") minyear(1878) maxyear(2019)
	replacevaluescountry,country("`c'") input("SERBIA") minyear(1878) maxyear(2019) vars(${vdemvars})
}

*FIXING POST-CZECHOSLOVAKIA
balancecountry,country("SLOVAKIA") minyear(1918) maxyear(1992)
replacevaluescountry,country("SLOVAKIA") input("CZECHIA") minyear(1918) maxyear(1992) vars(${vdemvars})

*FIXING POST-KOREA
balancecountry,country("NORTH KOREA") minyear(1789) maxyear(1944)
replacevaluescountry,country("NORTH KOREA") input("SOUTH KOREA") minyear(1789) maxyear(1944) vars(${vdemvars})

*FIXING POST-SOVIET UNION
foreach c in "ARMENIA" "AZERBAIJAN" "BELARUS" "ESTONIA" "GEORGIA" "KAZAKHSTAN" "KYRGYZSTAN" "LATVIA" "LITHUANIA" "MOLDOVA" "TAJIKISTAN" "TURKMENISTAN" "UKRAINE" "UZBEKISTAN"{
	balancecountry,country("`c'") minyear(1789) maxyear(2019)
	replacevaluescountry,country("`c'") input("RUSSIA") minyear(1789) maxyear(1995) vars(${vdemvars})
}

*IRELAND, GIBRALTAR, ISLE OF MAN
balancecountry,country("GIBRALTAR") minyear(1966) maxyear(2015) //1966 referendum https://en.wikipedia.org/wiki/Gibraltar
replacevaluescountry,country("GIBRALTAR") input("UNITED KINGDOM") minyear(1800) maxyear(1920) vars(${vdemvars})

so country year
la da "Country/year level data on corruption"
rename v2x_corr corruption
compress
sa "${temp}/3_addVars/corruption",replace


/*==============================================================================
*B3. CAPACITY
*=============================================================================*/
gl vdemvars statecapbase statecapfiscal statecapcomp
usezipped using "${g_dem}/V-Dem-CY-Full+Others-v14.zip",clear
mer 1:m country_name year using "${g_dem}/statecap_finalv14",keep(2 3) nogen
rename (statecap_baseline statecap_base_fiscal statecap_base_fiscal_edu) (statecapbase statecapfiscal statecapcomp)

g country=trim(itrim(upper(ustrto(ustrnormalize(country_name,"nfd"),"ascii",2))))
replace country="MACEDONIA" if country=="NORTH MACEDONIA"
replace country="GAMBIA" if country=="THE GAMBIA"
replace country="UNITED STATES" if country=="UNITED STATES OF AMERICA"
replace country="HONG KONG (CHINA)" if country=="HONG KONG"
replace country="TIMOR LESTE (EAST TIMOR)" if country=="TIMOR-LESTE"
replace country="PALESTINE" if inlist(country,"PALESTINE/BRITISH MANDATE","PALESTINE/GAZA","PALESTINE/WEST BANK")
replace country="CONGO DR (ZAIRE)" if country=="DEMOCRATIC REPUBLIC OF THE CONGO"
replace country="COTE DIVOIRE" if country=="IVORY COAST"
replace country="MYANMAR (BURMA)" if country=="BURMA/MYANMAR"
replace country="SWAZILAND" if country=="ESWATINI"
replace country="CONGO (REPUBLIC)" if country=="REPUBLIC OF THE CONGO"
drop if inlist(country,"MODENA","TUSCANY","BAVARIA","HAMBURG","ZANZIBAR","HESSE-DARMSTADT","GERMAN DEMOCRATIC REPUBLIC","BRUNSWICK","HANOVER")
drop if inlist(country,"TWO SICILIES","WURTEMBERG","SOMALILAND","OLDENBURG","HESSE-KASSEL","SOUTH YEMEN","SAXONY","BADEN","MECKLENBURG SCHWERIN")
drop if inlist(country,"PARMA","SAXE-WEIMAR-EISENACH","NASSAU","PIEDMONT-SARDINIA","REPUBLIC OF VIETNAM")
drop if country=="PAPAL STATES" //No infopost 1861 and no in surveys

gcollapse (mean) ${vdemvars}, by(country year) 
ds ${vdemvars}
foreach var of varlist `r(varlist)' {
    local oldlabel : variable label `var'
    local newlabel = subinstr("`oldlabel'", "(mean)", "", .)
    label variable `var' "`newlabel'"
}

*FIXING POST-YUGOSLAVIA (just copied what Carlos did for other VDEM variables)
foreach c in "BOSNIA AND HERZEGOVINA" "CROATIA" "SLOVENIA" "MONTENEGRO" "KOSOVO" "MACEDONIA" "SERBIA AND MONTENEGRO"{
	balancecountry,country("`c'") minyear(1878) maxyear(2019)
	replacevaluescountry,country("`c'") input("SERBIA") minyear(1878) maxyear(2019) vars(${vdemvars})
}
*FIXING POST-CZECHOSLOVAKIA
balancecountry,country("SLOVAKIA") minyear(1918) maxyear(1992)
replacevaluescountry,country("SLOVAKIA") input("CZECHIA") minyear(1918) maxyear(1992) vars(${vdemvars})
*FIXING POST-KOREA
balancecountry,country("NORTH KOREA") minyear(1789) maxyear(1944)
replacevaluescountry,country("NORTH KOREA") input("SOUTH KOREA") minyear(1789) maxyear(1944) vars(${vdemvars})
*FIXING POST-SOVIET UNION
foreach c in "ARMENIA" "AZERBAIJAN" "BELARUS" "ESTONIA" "GEORGIA" "KAZAKHSTAN" "KYRGYZSTAN" "LATVIA" "LITHUANIA" "MOLDOVA" "TAJIKISTAN" "TURKMENISTAN" "UKRAINE" "UZBEKISTAN"{
	balancecountry,country("`c'") minyear(1789) maxyear(2019)
	replacevaluescountry,country("`c'") input("RUSSIA") minyear(1789) maxyear(1995) vars(${vdemvars})
}

la var statecapbase "State Capacity Baseline"
la var statecapfiscal "State Capacity Fiscal"
la var statecapcomp "State Capacity Comprehensive"

keep country year statecapbase statecapfiscal statecapcomp
so country year
la da "State Capacity"
compress
sa "${temp}/3_addVars/statecap",replace


/*==============================================================================
*B4. REDISTRIBUTION
*=============================================================================*/
usezipped using "${g_redis}/wid/Data",clear
drop if regexm(alpha2,"-")
foreach v of varlist percentile type concept pop{
	ren `v' t0
	decode t0,g(`v')
	drop t0
}
tostring age,replace

mer m:1 alpha2 using "${g_redis}/wid/CountryCodes",keepus(country region) nogen keep(1 3) assert(2 3)
drop if region==""
drop alpha2 region
g sharetop=.
replace sharetop=1 if percentile=="p99p100"
replace sharetop=5 if percentile=="p95p100"
replace sharetop=10 if percentile=="p90p100"
keep if inlist(sharetop,1,5,10)
keep if type=="s"
drop percentile
egen group=concat(pop concept age),p("_")
drop pop type concept age
ren value measure
sa "temp",replace

clear
foreach s of numlist 1 10{
	preserve
	u "temp",replace
	gcollapse (count) grouporder=year,by(group)
	gsort - grouporder group
	replace grouporder=_n-1
	mer 1:m group using "temp",nogen
	drop group
	greshape wide measure,i(country year sharetop) j(grouporder) string
	keep if sharetop==`s'
	drop sharetop
	order country year 
	so country year
	egen t0=group(country)
	keep country year measure0
	ren measure0 sharetop`s'
	sa "temp1",replace
	restore
	if `s'==1 u "temp1",clear
	else mer 1:1 country year using "temp1",nogen
}
compress
sa "temp",replace
erase "temp1.dta"

gl vars sharetop1 sharetop10
u "temp",replace
collapse (min) yearmin=year (max) yearmax=year,by(country)
expand yearmax-yearmin+1
bys country:g year=_n-1+yearmin
drop yearmax yearmin
mer 1:1 country year using "temp", assert(1 3) nogen
foreach v of varlist $vars {
	g t0=`v'!=.
	g t1=`v'==.
	bys country:g t2=sum(t0)
	replace t2=. if !mi(`v')
	bys country t2:egen yearsipolate=sum(t1)
	drop t0 t1 t2
	g t0=ln(`v')
	so country year
	bys country:ipolate t0 year,g(t1)
	replace `v'=exp(t1) if `v'==.&yearsipolate<=10
	drop t0 t1 yearsipolate
}

*ADD SAME COUNTRIES
gl g1 `""GIBRALTAR" "UNITED KINGDOM""'
gl g2 `""FAROE ISLANDS" "DENMARK""'
gl g3 `""SERBIA AND MONTENEGRO" "SERBIA""'
gl g4 `""GREENLAND" "DENMARK""'
gl g5 `""ISLE OF MAN" "UNITED KINGDOM""'
gl g6 `""LIECHTENSTEIN" "GERMANY""'

forv g=1/6{
	loc t1:word 1 of ${g`g'}
	loc t2:word 2 of ${g`g'}
	qui su year if country=="`t2'"
	loc rmin=`r(min)'
	loc rmax=`r(max)'
	balancecountry,country("`t1'") minyear(`rmin') maxyear(`rmax')
	replacevaluescountry,country("`t1'") input("`t2'") minyear(`rmin') maxyear(`rmax') vars(${vars})
}

*WID CountryCodes uses title-case — enforce canonical names before save
replace country="CZECHIA"  if inlist(country,"CZECH REPUBLIC","Czech Republic")
replace country="TURKIYE"  if inlist(country,"TURKEY","Turkey")
compress
sa "${temp}/3_addVars/redistribution",replace

erase "temp.dta"


/*==============================================================================
*B5. ESS
*=============================================================================*/
u "${g_ess}/ESS", replace

*we drop inmigrants and non-citizens
drop if brncntr == 2
drop if ctzcntr == 2

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

ren pplhlp people_help
ren pplfair people_fair
ren ppltrst trust_people
ren trstep trust_euparliament
ren trstlgl trust_legalsystem
ren trstplc trust_police
ren trstplt trust_politicians
ren trstprl trust_parliament
ren trstprt trust_politicalparties
ren trstun trust_un
ren trstsci trust_scientists
ren tstfnch trust_financial
ren tstpboh trust_publicofficials
ren tstrprh trust_serviceproviders
ren gvimpc19 trust_govtcovid

ren gndr male 
ren rlgblg belongreligion
replace belongreligion = 0 if belongreligion == 2
replace belongreligion = 1 if scrlgblg == 1 & belongreligion == .
replace belongreligion = 0 if (scrlgblg == 2 & belongreligion == .) | (scrlgblg == 3 & belongreligion == .)
label define yesno 0 "No" 1 "Yes"
label values belongreligion yesno

ren mnrsphm men_responsability
ren ppwwkp women_workplace
ren wmcpwrk women_cutwork
ren trwkcnt fair_treat
ren eqwrkbg women_paid
ren eqpolbg women_politics
ren eqmgmbg women_management
ren eqpaybg equal_pay
ren eqparep equal_seats
ren freinsw fire_insulting
ren fineqpy fine_notequal
ren wsekpwr women_seekpower
ren weasoff women_offended
ren wlespdm often_paidless
ren wexashr often_exagerate
ren wprtbym women_protected
ren wbrgwrm women_bettersense
ren mnrgtjb men_job

keep idno year yearb male eduyrs belongreligion country age essround dweight people_help people_fair trust_people trust_euparliament trust_legalsystem trust_police trust_politicians trust_parliament trust_politicalparties trust_un trust_scientists trust_financial trust_publicofficials trust_serviceproviders trust_govtcovid men_responsability women_workplace women_cutwork fair_treat women_paid women_politics women_management equal_pay equal_seats fire_insulting fine_notequal women_seekpower women_offended often_paidless often_exagerate women_protected women_bettersense men_job aesfdrk atncrse badge bctprd blgetmg brncntr clsprty cmsrv cmsrvp contplt crmvct ctzcntr domicil dsbld dsbldp edctn edctnp eisced emplrel emprf14 emprm14 estsz facntr freehms gincdif happy health hhmmb hincsrca hincfel hlthhmp hswrk hswrkp imbgeco imdfetn impcntr impdiff impenv impfree impfun imprich impsafe imptrad imsmetn imueclt imwbcnt iorgact ipadvnt ipbhprp ipcrtiv ipeqopt ipfrule ipgdtim iphlppl iplylfr ipmodst iprspot ipshabt ipstrgv ipsuces ipudrst jbspv lrscale mbtru mnactic mocntr pbldmn pdwrk pdwrkp polintr pray rlgatnd rlgblg rlgdgr rtrd rtrdp sclact sclmeet sgnptit stfdem stfeco stfedu stfgov stfhlth stflife uemp3m uempla uemplap uempli uemplip vote wkdcorga wkhct wkhtot wrkac6m wrkorg wrkprty

la data "ESS"
compress
sa "${temp}/3_addVars/ess",replace

/*==============================================================================
*B5.2. COUNTRY-YEARB-YEAR ESS
*=============================================================================*/
*Country-Year born-Year
u "${temp}/3_addVars/ess",clear
keep country yearb year
keep if !missing(country,yearb,year)

bys country yearb year: keep if _n==1
gegen id=group(country yearb year)
la da "Individuals census by country, year of birth and year of survey"
compress
sa "${temp}/1_survey/censusCountryYearbYearess",replace


/*==============================================================================
*B6. HEALTH EXPENDITURE (World Bank SH.XPD.CHEX.GD.ZS, % GDP)
*Coverage: 2000–2021 for most countries; 2022–2023 sparse.
*Format: wide (one column per year); rows 1–4 are preamble, row 5 is header.
*Stata renames year columns with leading digit to v1960, v1961 ... v2023.
*=============================================================================*/
import delimited using "${raw}/3_additional_vars/10_health/health_exp_wb.csv", ///
    varnames(1) rowrange(5:) encoding("utf-8") clear

*Keep country name + year columns 2000–2021
keep countryname v2000 v2001 v2002 v2003 v2004 v2005 v2006 v2007 ///
     v2008 v2009 v2010 v2011 v2012 v2013 v2014 v2015 v2016 v2017 ///
     v2018 v2019 v2020 v2021

*Reshape wide → long
reshape long v, i(countryname) j(year)
ren v healthexp
drop if missing(healthexp)

*Normalize country names to pipeline canonical form (uppercase ASCII)
gen country = upper(ustrto(ustrnormalize(countryname,"nfd"),"ascii",2))
drop countryname

*Harmonize WB country names to canonical pipeline names
replace country = "CZECHIA"           if country == "CZECH REPUBLIC"
*TURKIYE is already correct after ASCII normalization of "Turkiye"
replace country = "SOUTH KOREA"       if country == "KOREA, REP."
replace country = "RUSSIA"            if country == "RUSSIAN FEDERATION"
replace country = "IRAN"              if country == "IRAN, ISLAMIC REP."
replace country = "EGYPT"             if country == "EGYPT, ARAB REP."
replace country = "VENEZUELA"         if country == "VENEZUELA, RB"
replace country = "LAOS"              if country == "LAO PDR"
replace country = "VIETNAM"           if country == "VIET NAM"
replace country = "CONGO DR (ZAIRE)"  if country == "CONGO, DEM. REP."
replace country = "CONGO (REPUBLIC)"  if country == "CONGO, REP."
replace country = "SYRIA"             if country == "SYRIAN ARAB REPUBLIC"
replace country = "PALESTINE"         if country == "WEST BANK AND GAZA"
replace country = "SLOVAKIA"          if country == "SLOVAK REPUBLIC"
replace country = "KYRGYZSTAN"        if country == "KYRGYZ REPUBLIC"
replace country = "MACEDONIA"         if country == "NORTH MACEDONIA"
replace country = "CAPE VERDE"        if country == "CABO VERDE"
replace country = "GAMBIA"            if country == "GAMBIA, THE"
replace country = "BAHAMAS"           if country == "BAHAMAS, THE"

*Drop WB regional aggregates (not country-level rows)
drop if inlist(country, "WORLD", "EAST ASIA & PACIFIC", "EUROPE & CENTRAL ASIA", ///
    "LATIN AMERICA & CARIBBEAN", "MIDDLE EAST & NORTH AFRICA", ///
    "NORTH AMERICA", "SOUTH ASIA", "SUB-SAHARAN AFRICA", ///
    "LOW INCOME", "LOWER MIDDLE INCOME", "UPPER MIDDLE INCOME", "HIGH INCOME", ///
    "LOW & MIDDLE INCOME", "MIDDLE INCOME", "FRAGILE AND CONFLICT AFFECTED SITUATIONS", ///
    "HEAVILY INDEBTED POOR COUNTRIES (HIPC)", "LEAST DEVELOPED COUNTRIES: UN CLASSIFICATION", ///
    "EARLY-DEMOGRAPHIC DIVIDEND", "LATE-DEMOGRAPHIC DIVIDEND", ///
    "POST-DEMOGRAPHIC DIVIDEND", "PRE-DEMOGRAPHIC DIVIDEND", ///
    "EURO AREA", "EUROPEAN UNION", "IBRD ONLY", "IDA & IBRD TOTAL", ///
    "IDA BLEND", "IDA ONLY", "IDA TOTAL", "NOT CLASSIFIED", ///
    "SMALL STATES", "OTHER SMALL STATES", "PACIFIC ISLAND SMALL STATES", ///
    "CARIBBEAN SMALL STATES", "AFRICA EASTERN AND SOUTHERN", ///
    "AFRICA WESTERN AND CENTRAL", "ARAB WORLD", "CENTRAL EUROPE AND THE BALTICS", ///
    "CHANNEL ISLANDS", "EAST ASIA & PACIFIC (EXCLUDING HIGH INCOME)", ///
    "EAST ASIA & PACIFIC (IDA & IBRD COUNTRIES)", ///
    "EUROPE & CENTRAL ASIA (EXCLUDING HIGH INCOME)", ///
    "EUROPE & CENTRAL ASIA (IDA & IBRD COUNTRIES)", ///
    "LATIN AMERICA & CARIBBEAN (EXCLUDING HIGH INCOME)", ///
    "LATIN AMERICA & THE CARIBBEAN (IDA & IBRD COUNTRIES)", ///
    "MIDDLE EAST & NORTH AFRICA (EXCLUDING HIGH INCOME)", ///
    "MIDDLE EAST & NORTH AFRICA (IDA & IBRD COUNTRIES)", ///
    "SOUTH ASIA (IDA & IBRD)", "SUB-SAHARAN AFRICA (EXCLUDING HIGH INCOME)", ///
    "SUB-SAHARAN AFRICA (IDA & IBRD COUNTRIES)")

keep country year healthexp
sort country year
compress
la var healthexp "Health expenditure, total (% of GDP) — World Bank SH.XPD.CHEX.GD.ZS"
la da "Health expenditure panel (World Bank, 2000-2021)"
sa "${temp}/3_addVars/healthexp", replace