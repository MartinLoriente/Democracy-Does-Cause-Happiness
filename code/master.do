/*=================================================================
*SET UP
A. SET ROOT
B. MAIN GLOBALS FOR ANALYSIS
C. LOAD UTILS
D. MAKE DIRECTORIES
E. SET HEADERS 
F. EXECUTE CODE 
*================================================================*/
/*Si no corre el código probar correr esto y frenar la actualización de Dropbox:
cap ado uninstall _gwmean
cap ado uninstall dm79
cap ado uninstall distinct
cap ado uninstall eventdd
cap ado uninstall estout
cap ado uninstall ftools
cap ado uninstall grc1leg
cap ado uninstall grstyle
cap ado uninstall gtools
cap ado uninstall ivreg2
cap ado uninstall ivreghdfe
cap ado uninstall labutil
cap ado uninstall marktouse
cap ado uninstall matsort
cap ado uninstall moremata
cap ado uninstall outreg
cap ado uninstall parallel
cap ado uninstall personage
cap ado uninstall psmatch2
cap ado uninstall rangestat
cap ado uninstall ranktest
cap ado uninstall reghdfe
cap ado uninstall strrec
cap ado uninstall tabout
cap ado uninstall wbopendata
cap ado uninstall winsor2

ssc install _gwmean, replace
net install dm79, from("http://www.stata.com/stb/stb56/") replace
ssc install distinct, replace
ssc install eventdd, replace
ssc install estout, replace
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/") replace
net install grc1leg, from("http://www.stata.com/users/vwiggins/") replace
ssc install grstyle, replace
ssc install gtools, replace
ssc install ivreg2, replace
net install ivreghdfe, from("https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/") replace
ssc install labutil, replace
ssc install marktouse, replace
ssc install matsort, replace
ssc install moremata, replace
ssc install outreg, replace
net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/") replace
ssc install personage, replace
ssc install psmatch2, replace
ssc install rangestat, replace
ssc install ranktest, replace
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/") replace
ssc install strrec, replace
ssc install tabout, replace
ssc install wbopendata, replace
ssc install winsor2, replace
ssc install estout, replace
ssc install sxpose, replace
ssc install psacalc
mata mata mlib index
*/

clear all
cap set maxvar 11000, permanently
set type double, permanently
set more off, permanently
set matsize 11000, permanently
set scheme s2color, permanently
mata: mata set matafavor speed, permanently
set min_memory 6g, permanently
set excelxlsxlargefile on
grstyle init
grstyle color background white
grstyle anglestyle vertical_tick horizontal
grstyle gsize axis_title_gap tiny
grstyle linestyle legend none
grstyle color major_grid white
grstyle set ci
grstyle set compact
grstyle set plain, grid dotted
graph set window fontface "Times New Roman"
grstyle set size 14pt: heading
grstyle set size 14pt: subheading axis_title
grstyle set size 12pt: tick_label key_label

/*=================================================================
A. SET ROOT
*================================================================*/
cd "C:/Users/`c(username)'/Desktop/Tesis MAE/Democracy"

/*==============================================================================
*B. MAIN GLOBALS FOR ANALYSIS
*=============================================================================*/
parallel numprocessors
gl processors=r(numprocessors)

gl dfcountrycod "raw/CountryCod.dta"

*Config for tables
gl opt `"summstat(N \ N_clust1) summtitles("Observations" \ "Countries") varlabels se starlevels(10 5 1) starloc(1) bdec(3) ctitle("")"'
gl outopts1 keep(demlt2) dec(3) se noobs nor2 nonotes nocons label append
gl outopts2 keep(demiy2) dec(3) se noobs nor2 nonotes nocons label append
gl xlabel `" 1 "Dichotomous" 2 "Continuous" "'
gl ylabel `" 1 "Income" 2 "Health" 3 "Autonomy" 4 "Satisfaction" 5 "Happiness" "'

*Fixed effects
gl febase male townsize wavenum age languagenum subregion
gl fe1 ${febase} yearb country year 
gl fe2 ${febase} feregion_year fect_wave 
gl fes1 yearb country age 
gl fes2 townsize wavenum country age 
gl fes3 male wavenum country age 
gl fes4 male townsize yearb country age languagenum region
gl fes5 ${febase} country 
gl fes6 ${febase} yearb country 
gl fes7 ${febase} yearb country year 
gl fes8 ${febase} fect_year yearb region
gl fes9 ${febase} fect_year cohort10 region
gl fes10 ${febase} feregion_year fect_wave 
*REVISAR LOS FE DE ACÁ ABAJO
gl febasei age countryb 
gl fei1 ${febasei} fect_yeara subregion yearb 
gl fei2 ${febasei} fect_wave year agea cohort10
gl fei3 ${febasei} fect_year yeara agea region
gl fei4 ${febasei} fect_yeara_year
gl feess male wave yearb age country year
gl feessi1 "year cohort10 yeara age male wave"
gl feessi2 "fect_year_yearb country male age"
gl feessi3 "fect_yearb_yeara year male age"

*Clusters:
gl cl1 "country year"
gl clu1 "yearb"
gl clu2 "year"
gl clu3 "year yearb"
gl clu4 "region year yearb"
gl clu5 "region yearb wavenum"
gl clu6 "country"
gl clu7 "country year"
gl clu8 "country yearb"
gl clu9 "country year yearb"
gl clu10 "subregion"

gl allfeclgr male townsize wavenum age languagenum subregion yearb country year feregion_year fect_wave region fect_year cohort10 political 

*Subgroups
gl subgroups male0 male1 town0 town1 age1 age2 age3 pol1 pol2 pol3

*Outcomes
gl a income health autonomy satisfaction happiness
gl alt financial financial2 health2 aautonomyi oautonomyi happy1 happy3 

*mechanisms
gl i1 impreligion believegod believehell believeheaven godimportant belief
gl i2 educ2 educ3 education 
gl i3 employment1 employment2 employment3 employment4 employment5 employment6 employment7
gl i4 secure h1 h2 victim familyvictim worriedwar worriedterrorist
gl alli impreligion believegod believehell believeheaven godimportant belief educ2 educ3 education employment1 employment2 employment3 employment4 employment5 employment6 employment7 secure h1 h2 victim familyvictim worriedwar worriedterrorist

gl version 18
gl code code/v${version} //path to code
gl savee paper/1estimates/v${version} //path to save estimates
gl savef paper/2figures/v${version} //path to save figures
gl savet paper/3tables/v${version} //path to save tables

gl estimator reghdfestd //no estaba corriendo así que tuve que reemplazar a mano
gl k 6 //min age for lifetime exposure
gl he_elements M

*VARIABLES PLACEBO OUTCOMES
*Non-immigrants
gl placeboneig neigrace neiggypsies neigcriminals neigdrug neigaid neigunstable neigdrinkers neighomo neigmuslims neigchris neigjews neigimm neiglargefam 
gl placeboothers motherbooks fatherbooks relatmother familynotimportant concernedfamily churchfamily
gl placebobefore childreligion godimportant personalgod religionconfort prayerfreq prayermeditate believegod believelifedeath believereincarnation catholic protestant
gl placebo neigunstable neigchris neigjews neigimm neiglargefam motherbooks relatmother familynotimportant trust_fam trust_know relatmother confsss deathinev nomeaning parentsemp14 age5 motherimm fatherimm E116 demimportance  
gl placebolabel `" 1 "Emotionally Unstable Neighbors" 2 "Christians Neighbors" 3 "Jews Neighbors" 4 "Immigrant Neighbors" 5 "Neighbors With Large Families" 6 "Mother Liked to Read Books" 7 "Relationship Working Mother" 8 "Family Not at All Important" 9 "Trust Family" 10 "Trust People you Know" 11 "Relationship Mother" 12 "Confidence in Social Security" 13 "Death is Inevitable" 14 "Life has No Meaning" 15 "Father Employed at age 14" 16 "Age finished in 0 or 5" 17 "Mother Immigrant" 18 "Father Immigrant" 19 "Opposes Army Ruling" 20 "Importance of Democracy" "'
gl placeboN=wordcount("${placebo}")
forv i=1/`=wordcount("${placebo}")'{
	di "`i'."`"`=word("${placebo}",`i')'"'
}
gl placeboiN=wordcount("${placeboi}")
gl fepla male townsize wavenum languagenum subregion yearb country year 


/*=================================================================
C. LOAD UTILS
*================================================================*/
foreach p in "droptabular" "ivreghdfestd" "qvalues" "readvaras" "reghdfestd" "usezipped" "savezipped" "descstatistics" "psacalc2" {
	do "${code}/utils/`p'.ado"
}
do "${code}/utils/addUtils.do"

/*==============================================================================
D. MAKE DIRECTORIES
*=============================================================================*/
makedirs,base(.) dirs(raw temp paper)
makedirs,base(raw) dirs(1survey 2democracy 3addVars)
makedirs,base(raw/1survey) dirs(1ivs 2asianBarometer 3lapop 4latinobarometer 5gps 6ess)
makedirs,base(raw/3addVars) dirs(1gdp 2peace 3coup 4govExpenditure 5redistribution 6population 7inflation)
makedirs,base(paper) dirs(1estimates 2figures 3tables 4Reports)
makedirs,base(temp) dirs(1survey 2democracy 3addVars)
makedirs,base(temp/1survey) dirs(gps ivs)
makedirs,base(temp/2democracy) dirs(tot sucM sucF cnts others event)
makedirs,base(temp/2democracy/cnts) dirs(dem bef)
makedirs,base(temp/2democracy/sucF) dirs(dem bef)
makedirs,base(temp/2democracy/sucM) dirs(dem bef inst instBef age others)
makedirs,base(temp/3addVars) dirs(cnts gdp heF heM hecnts vdem spatial)
makedirs,base(paper/1estimates paper/2figures paper/3tables) dirs(v${version})
makedirs,base(${savee}) dirs(tot sucM sucF cnts FigBef wFigBef mFigBef FigBefSuciy FigBefSuclt FigBefCntslt)
makedirs,base(${savee}/sucM ${savee}/sucF ${savee}/cnts) dirs(olsMain olsBef)
makedirs,base(${savee}/tot) dirs(olsMainLT olsMainIY olsPersistence olsTabellini olsQuantile olsQuantileiy olsBef olsMain olsMainK)
makedirs,base(${savee}/tot ${savee}/sucM) dirs(olsPlaIY olsPlaLT olsPla_conf ivMain ivBef ivPla rfBef rfBefiy rfPla rfPlaiy rfMain iOlsMainIY iOlsMainLT iOlsBef iOlsPla surOlsMain surOlsBef surIvMain others others/region others/event others/age others/olsMainNoStd others/olsMainNoStdNsDem others/olsMainNoStdNsAut others/bootstrapBef)
makedirs,base(${savee}/tot/olsTabellini) dirs(V1 V2 V3 V4)
makedirs,base(${savee}/tot/olsQuantile) dirs(s1 s2)

/*==============================================================================
E. SET HEADERS
*=============================================================================*/
file open myfile using "${savet}/header.tex", write replace
file write myfile "& (1) & (2) & (3) & (4) & (5) \\ \hline \\" _n
file write myfile "& Income & Health & Autonomy & Satisfaction & Happiness \\ \cline{2-6}" _n
file close myfile

file open myfile using "${savet}/headerHRL.tex", write replace
file write myfile "& (1) & (2) & (3) & (4) & (5) & (6) \\ \hline \\" _n
file write myfile "& Age $\ge$ 25 & Age $\ge$ 25 & Age $\ge$ 25 & Age $\ge$ 33 & Age $\ge$ 41 & Age $\ge$ 25 \\ \cline{2-7}"
file close myfile

file open myfile using "${savet}/headerHR.tex", write replace
file write myfile "& (1) & (2) & (3) & (4) \\ \hline \\" _n
file write myfile "& Age $\ge$ 25 & Age $\ge$ 6 & Age $\ge$ 6 & Age $\ge$ 25 \\ \cline{2-5}"
file close myfile

file open myfile using "${savet}/headerFE.tex", write replace
file write myfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\" _n
file close myfile

file open myfile using "${savet}/headerFS.tex", write replace
file write myfile "& Exposure to Democracy \\ \cline{2-3}" _n
file close myfile

file open myfile using "${savet}/headerFSIY.tex", write replace
file write myfile "& Exposure to Democracy 18-25 \\ \cline{2-3}" _n
file close myfile

file open myfile using "${savet}/i1.tex", write replace
file write myfile "& (1) & (2) & (3) & (4) & (5) & (6) \\ \hline \\" _n
file write myfile "& Religion Important & Believe God & Believe Hell & Believe Heaven & God Important & Belief Index \\ \cline{2-7}" _n
file close myfile

file open myfile using "${savet}/i2.tex", write replace
file write myfile "& (1) & (2) & (3) \\ \hline \\" _n
file write myfile "& Completed Secondary & Completed Tertiary & Education Level \\ \cline{2-4}" _n
file close myfile

file open myfile using "${savet}/i3.tex", write replace
file write myfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\ \hline \\" _n
file write myfile "& Full Time & Part Time & Self Employed & Retired & Housewife & Student & Unemployed \\ \cline{2-8}" _n
file close myfile

file open myfile using "${savet}/i4.tex", write replace
file write myfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) \\ \hline \\" _n
file write myfile "& Secure & Not Carry Money & Not Go Out & Victim & Family Victim & Worried War & Worried Terrorist \\ \cline{2-8}" _n
file close myfile

file open myfile using "${savet}/headerapp.tex", write replace
file write myfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) \\ \hline \\" _n
file write myfile "& Financial & Other Financial & Alt-Health Definition & Autonomy Index B & Autonomy Index C & Felt on Top & Felt Your Way \\ \cline{2-8}" _n
file close myfile

/*=================================================================
*F. EXECUTE CODE 
*================================================================*/
do code/v${version}/1surveys
do code/v${version}/2others
do code/v${version}/3exposure
do code/v${version}/4consolidate
do code/v${version}/analysis/5tables
do code/v${version}/analysis/6figures	

******************************************************************************** 
/**/
	

*Códigos que pueden llegar a ser útiles
/*

do "${code}/utils/reghdfestd.ado"
do "${code}/utils/droptabular.ado"
do "${code}/utils/descstatistics.ado"

*LA TABLA DE HR PUEDE SER ÚTIL PERO MI OPINIÓN ES QUE LOS IY VAN A PERDER ALGUNOS PORQUE SU EFECTO FUE HACE MUCHO TIEMPO. PENSAR SI NO VALE LA PENA ARMARMARLO DISTINTO PARA QUE DE MEJOR, O SINO, SI ENCONTRAMOS QUE GANA LA CERCANÍA, MOSTRAR QUE EL EFECTO ESTÁ CUANDO VIVIS DEMOCRACIA HACE POCO. SI NO ENCONTRAMOS ESO ES UN ARGUMENTO FUERTE A FAVOR DE IY. Entonces, argumentar que en las horse race los IY se mantienen significativos incluso cuando "compiten" con otras etapas más recientes en muestras de gente que vivió los años impresionables hace más de 10 años.


En este análisis buscamos descomponer el efecto de la exposición a la democracia durante los años formativos sobre la satisfacción con la vida en distintos canales, utilizando regresiones con efectos fijos múltiples y robustez a la correlación intra-cluster en país y año. Incluimos como efectos fijos todas las variables definidas en la primera specification (sexo, tamaño de localidad, ola de encuesta, edad, número de idioma, subregión, cohorte de nacimiento, país y año) y ajustamos los errores estándar por clusters según país y año, ponderando por los pesos correspondientes y restringiendo la muestra a individuos de 25 años o más.

Primero, estimamos el efecto total de vivir más años en democracia sobre la satisfacción, obteniendo un coeficiente de 0.052844 desviaciones estándar, positivo y estadísticamente significativo al 1 por ciento. Para entender los mecanismos que transmiten este efecto, analizamos dos canales potenciales: ingresos y salud. La exposición a la democracia incrementó los ingresos en 0.081908 desviaciones estándar, positivo y significativo al 1 por ciento, mientras que los ingresos impactaron la satisfacción en 0.169198 desviaciones estándar, también positivo y significativo al 1 por ciento. La democracia mejoró la salud en 0.090271 desviaciones estándar, positivo y significativo al 1 por ciento, y la salud elevó la satisfacción en 0.203044 desviaciones estándar, positivo y significativo al 1 por ciento. Al incluir ambos mediadores en un modelo conjunto, el efecto directo de la democracia sobre la satisfacción se redujo a 0.025275 desviaciones estándar, positivo y significativo al 5 por ciento, indicando la parte del efecto no explicada por estos canales.

A partir de estos coeficientes, calculamos los efectos indirectos multiplicando el efecto de la democracia sobre cada mediador por el efecto del mediador sobre la satisfacción. El efecto indirecto vía ingresos fue 0.01385 desviaciones estándar y vía salud 0.01834 desviaciones estándar. El efecto total combinado, sumando los efectos directo e indirectos, fue aproximadamente 0.057465 desviaciones estándar. La contribución relativa de cada componente al efecto total se distribuye en 24.1% para el canal de ingresos, 31.9% para el canal de salud y 44% corresponde al efecto directo de la democracia no mediado por estas variables.

Estos resultados buscan mostrar cómo la exposición a la democracia se relaciona con la satisfacción a través de los canales de ingresos y salud, usando la información disponible y controlando por múltiples efectos fijos y errores estándar robustos por cluster. No podemos afirmar que los efectos sean causales ni precisos. Este análisis constituye un intento exploratorio de identificar mecanismos potenciales vinculados a la relación observada. Los porcentajes calculados ofrecen solo una idea aproximada de la contribución de cada canal dentro del modelo y podrían cambiar sustancialmente al considerar otros factores no observados.


u "temp/ivs",replace
*democracia 
reghdfestd satisfaction demiy2 [aw=weight] if age>24, a(${fe1}) cl(${cl1}) version(5)
*income
reghdfestd income demiy2 [aw=weight] if age>24, a(${fe1}) cl(${cl1}) version(5)
reghdfestd satisfaction income [aw=weight] if age>24, a(${fe1}) cl(${cl1}) version(5)
*health
reghdfestd health demiy2 [aw=weight] if age>24, a(${fe1}) cl(${cl1}) version(5)
reghdfestd satisfaction health [aw=weight] if age>24, a(${fe1}) cl(${cl1}) version(5)
*todo
reghdfestd satisfaction demiy2 health income [aw=weight] if age>24, a(${fe1}) cl(${cl1}) version(5)


/*==============================================================================
TABLE X: LIFETIME DEMOCRACY – OSTER 
==============================================================================*/
foreach y in $a {
    forvalues x = 1/2 {
        use "temp/ivs", clear
        reghdfe `y' demlt`x' [aw=weight], a(${fe1}) 
        scalar rtilde = e(r2)
        scalar rmax = min(1.3 * rtilde, 1)
        psacalc2 delta demlt`x', rmax(`=rmax')
    }
}
*Falta poder extraer los delta o betas y ponerlos en una tabla automáticamente que además muestre el valor de Rmax y el delta o beta correspondiente




*REGRESIÓN DOBLEMENTE ROBUSTA, no funciona

* Globals (asegurate de haberlas definido antes si no están en tu do-file)
gl a married together divorced separated widowed single health satisfaction happiness wb_index
gl febase male townsize wavenum age languagenum subregion
gl fe1 male townsize wavenum age languagenum subregion yearb country year

* Loop sobre outcomes
*foreach y in $a {
foreach y in married {
    
    * Cargar base limpia
    use "temp/ivs", clear

    * Crear identificador de unidad si no existe
    gen id = _n 

    * Verifica que 'g' (año de tratamiento) esté correctamente definida
    * Por ejemplo, si 'demlt2' es 1 si tratado, 0 si no:
    gen g = .
    replace g = yearb if demlt2 == 1
    egen min_g = min(g), by(id)
    replace g = min_g
    drop min_g

    * Asegurar que las unidades nunca tratadas tengan g = 0
    replace g = 0 if missing(g)

    * Estimación del efecto dinámico con wild bootstrap
    csdid `y' $febase , ///
        ivar(id) ///
        time(yearb) ///
        gvar(g) ///
        method(dripw) ///
        agg(event) ///
        notyet ///
        wboot reps(999) rseed(123)

    * Guardar gráfico
    graph export "output/csdid_`y'.png", replace
}




*código para interacciónes o grupos interesantes
keep if languagenum==3 // arabic
keep if languagenum==32 // english
keep if languagenum==104 // russian
keep if languagenum==119 // spanish
keep if male==1 // male
keep if male==0 // female
keep if townsize==0 // Over 20k
keep if townsize==1 // Under 20k
keep if inrange(age, 10, 30) // young
keep if inrange(age, 31, 50) // middle aged
keep if inrange(age, 51, 150) // old
keep if political==1 // Left
keep if political==2 // Centrists
keep if political==3 // Right

*código para argumentar que las variables de estado civil son las que causan la diferencia en felicidad y satisfacción, y cuales son las más relevantes. Este análisis es correlacional por lo que no permite afirmar causalidad.
use "temp/ivs", replace
reghdfestd happiness married together divorced separated widowed single demlt2 [aw=weight] if age>${k}, a(${fe1}) cl(${cl1}) version(5)
reghdfestd lifesatisf married together divorced separated widowed single demlt2 [aw=weight] if age>${k}, a(${fe1}) cl(${cl1}) version(5)



*códigos relacionados con cuantiles y lo raro que es que vayan al revés
use "temp/ivs", replace
drop if demlt1>75

gen demlt1_bin = floor(demlt1/2)*2  
collapse (mean) talentjob [aw=weight], by(demlt1_bin)
twoway connected talentjob demlt1_bin, msymbol(o) lcolor(green)

gen demlt2_bin = floor(demlt2/2)*2  
collapse (mean) talentjob [aw=weight], by(demlt2_bin)
twoway connected talentjob demlt2_bin, msymbol(o) lcolor(green)


xtile t02 = demlt2, n(10)
tab t02, gen(decile2_)

sum demlt2 if decile2_1==1
sum demlt2 if decile2_2==1
sum demlt2 if decile2_3==1
sum demlt2 if decile2_4==1
sum demlt2 if decile2_5==1
sum demlt2 if decile2_6==1
sum demlt2 if decile2_7==1
sum demlt2 if decile2_8==1
sum demlt2 if decile2_9==1
sum demlt2 if decile2_10==1

tab decile2_1, summarize(talentjob)
tab decile2_2, summarize(talentjob)
tab decile2_3, summarize(talentjob)
tab decile2_4, summarize(talentjob)
tab decile2_5, summarize(talentjob)
tab decile2_6, summarize(talentjob)
tab decile2_7, summarize(talentjob)
tab decile2_8, summarize(talentjob)
tab decile2_9, summarize(talentjob)
tab decile2_10, summarize(talentjob)




*código para mirar el impacto de los cuantiles según democracia en las variables 
use "temp/ivs", replace
xtile t02 = demlt2, n(10)
count if missing(demlt2)
tab t02 if missing(t02)
tab t02, gen(decile2_)
sum demlt2 if decile2_1==1
sum demlt2 if decile2_10==1
collapse (mean) talentjob, by(t02)
graph bar talentjob, over(t02) ytitle("Share with talentjob=1") ylabel(0(.05)1)


*código para waves por variables
clear
local vars ${t}
foreach var of local vars {
    use "temp/ivs", clear
    levelsof wave if !missing(`var'), local(waves)
    local formatted_waves ""
    foreach wave of local waves {
        local formatted_waves "`formatted_waves' `wave'"
    }
    di "`var': `formatted_waves'"
}


*código para correlaciones
u "temp/ivs",replace
asdoc corr democratic_system opposes_strong opposes_army government_above trust_most trust_strangers trust_religion trust_nationality, label replace

asdoc corr jobfirst jobpay talentjob chief genderjobs democratic_system opposes_army opposes_strong government_above, label replace

trust_most trust_strangers trust_religion trust_nationality
democratic_system opposes_army opposes_strong government_above

jobfirst jobpay talentjob chief genderjobs 


*código para mirar interacciones
keep country year phone4 phone6 trade2 trade4 school04
order country year phone4 phone6 trade2 trade4 school04
ren (*) cnts#, addnumber
ren (cnts1 cnts2) (country year)
foreach var of varlist cnts3-cnts7 {
    // Guardar etiqueta original
    local lbl : variable label `var'

    // ----------- GLOBAL PERCENTILES -----------
    su `var', detail
    gen `var'_p25 = `var' >= r(p25) if !missing(`var')
    gen `var'_p50 = `var' >= r(p50) if !missing(`var')
    gen `var'_p75 = `var' >= r(p75) if !missing(`var')
    label variable `var'_p25 "`lbl' ≥ global 25th percentile"
    label variable `var'_p50 "`lbl' ≥ global median"
    label variable `var'_p75 "`lbl' ≥ global 75th percentile"

    // ----------- LOCAL PERCENTILES (by country) -----------
    egen p25_ctry = pctile(`var'), p(25) by(country)
    egen p50_ctry = pctile(`var'), p(50) by(country)
    egen p75_ctry = pctile(`var'), p(75) by(country)
    gen `var'_p25_ctry = `var' >= p25_ctry if !missing(`var')
    gen `var'_p50_ctry = `var' >= p50_ctry if !missing(`var')
    gen `var'_p75_ctry = `var' >= p75_ctry if !missing(`var')
    label variable `var'_p25_ctry "`lbl' ≥ 25th percentile (country)"
    label variable `var'_p50_ctry "`lbl' ≥ median (country)"
    label variable `var'_p75_ctry "`lbl' ≥ 75th percentile (country)"
    drop p25_ctry p50_ctry p75_ctry

    // ----------- MIN-MAX GLOBAL -----------
    su `var', meanonly
    gen `var'_scaled_global = (`var' - r(min)) / (r(max) - r(min)) if !missing(`var')
    label variable `var'_scaled_global "`lbl' (rescaled 0–1 globally)"

    // ----------- MIN-MAX LOCAL -----------
    egen min_ctry = min(`var'), by(country)
    egen max_ctry = max(`var'), by(country)
    gen `var'_scaled_ctry = (`var' - min_ctry) / (max_ctry - min_ctry) if !missing(`var') & max_ctry != min_ctry
    label variable `var'_scaled_ctry "`lbl' (rescaled 0–1 within country)"
    drop min_ctry max_ctry
}
drop cnts3 cnts4 cnts5 cnts6 cnts7
ren (cnts3_p50 cnts3_p25 cnts3_p75 cnts3_p50_ctry cnts3_p25_ctry cnts3_p75_ctry cnts3_scaled_global cnts3_scaled_ctry ///
    cnts4_p50 cnts4_p25 cnts4_p75 cnts4_p50_ctry cnts4_p25_ctry cnts4_p75_ctry cnts4_scaled_global cnts4_scaled_ctry ///
    cnts5_p50 cnts5_p25 cnts5_p75 cnts5_p50_ctry cnts5_p25_ctry cnts5_p75_ctry cnts5_scaled_global cnts5_scaled_ctry ///
    cnts6_p50 cnts6_p25 cnts6_p75 cnts6_p50_ctry cnts6_p25_ctry cnts6_p75_ctry cnts6_scaled_global cnts6_scaled_ctry ///
    cnts7_p50 cnts7_p25 cnts7_p75 cnts7_p50_ctry cnts7_p25_ctry cnts7_p75_ctry cnts7_scaled_global cnts7_scaled_ctry) cnts#, addnumber
order year country cnts1 cnts2 cnts3 cnts4 cnts5 cnts6 cnts7 cnts8 cnts9 cnts10 cnts11 cnts12 cnts13 cnts14 cnts15 cnts16 cnts17 cnts18 cnts19 cnts20 cnts21 cnts22 cnts23 cnts24 cnts25 cnts26 cnts27 cnts28 cnts29 cnts30 cnts31 cnts32 cnts33 cnts34 cnts35 cnts36 cnts37 cnts38 cnts39 cnts40

foreach var of varlist cnts3-cnts7 {
    local lbl : variable label `var'

    // Mediana
    su `var', detail
    gen `var'_p50 = `var' >= r(p50) if !missing(`var')
    label variable `var'_p50 "`lbl' ≥ global median"

    // Estandarizar
    gegen z_`var' = standardize(`var')

    // Z ≥ -2
    gen `var'_sdm2 = z_`var' >= -2 if !missing(`var', z_`var')
    label variable `var'_sdm2 "`lbl' ≥ -2 SD"

    // Z ≥ 1
    gen `var'_sd1 = z_`var' >= 1 if !missing(`var', z_`var')
    label variable `var'_sd1 "`lbl' ≥ 1 SD"

    // Z ≥ 2
    gen `var'_sd2 = z_`var' >= 2 if !missing(`var', z_`var')
    label variable `var'_sd2 "`lbl' ≥ 2 SD"

    // Limpieza
    drop z_`var' `var'
}