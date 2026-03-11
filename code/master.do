/*=================================================================
*SET UP
A. SET ROOT
B. MAIN GLOBALS FOR ANALYSIS
C. LOAD UTILS
D. MAKE DIRECTORIES
E. SET HEADERS 
F. EXECUTE CODE 
*================================================================*/

clear all
cap set maxvar 11000, permanently
set type double, permanently
set more off, permanently
cap set matsize 11000, permanently
set scheme s2color, permanently
mata: mata set matafavor speed, permanently
cap set min_memory 6g, permanently
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
cd "C:/Users/`c(username)'/Desktop/Democracy-Does-Cause-Happiness"

/*==============================================================================
*B. MAIN GLOBALS FOR ANALYSIS
*=============================================================================*/
cap parallel numprocessors
gl processors = cond(_rc==0, r(numprocessors), 1)

*Folder paths
gl raw   "data/1_raw"
gl temp  "data/2_processed"
gl paper "output"
gl utils "code/utils"

*Raw data subfolders
gl g_ivs     "${raw}/1_survey/1_ivs"
gl g_asian   "${raw}/1_survey/2_asianBarometer"
gl g_lapop   "${raw}/1_survey/3_lapop"
gl g_latibar "${raw}/1_survey/4_latinobarometer"
gl g_ess     "${raw}/1_survey/6_ess"
gl g_dem     "${raw}/2_democracy"
gl g_gdp     "${raw}/3_additional_vars/1_gdp"
gl g_redis   "${raw}/3_additional_vars/5_redistribution"
gl g_pop     "${raw}/3_additional_vars/6_population"

gl dfcountrycod "${raw}/CountryCod.dta"

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

gl version 1
gl code code/v${version} //path to code
gl savee ${paper}/1_estimates/v${version} //path to save estimates
gl savef ${paper}/2_figures/v${version} //path to save figures
gl savet ${paper}/3_tables/v${version} //path to save tables

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
gl fepla male townsize wavenum languagenum subregion yearb country year


/*=================================================================
C. LOAD UTILS & PACKAGES
*================================================================*/
foreach p in "droptabular" "ivreghdfestd" "qvalues" "readvaras" "reghdfestd" "usezipped" "savezipped" "descstatistics" "psacalc2" {
	do "${utils}/`p'.ado"
}
do "${utils}/addUtils.do"

// do code/0_install Si no corre el código probar correr esto y frenar la actualización de Dropbox

/*==============================================================================
D. MAKE DIRECTORIES
*=============================================================================*/
makedirs,base(.) dirs(output)
makedirs,base(${paper}) dirs(1_estimates 2_figures 3_tables 4_reports)
makedirs,base(${temp}) dirs(1_survey 2_democracy 3_addVars)
makedirs,base(${temp}/1_survey) dirs(gps ivs)
makedirs,base(${temp}/2_democracy) dirs(tot sucM sucF cnts others event)
makedirs,base(${temp}/2_democracy/cnts) dirs(dem bef)
makedirs,base(${temp}/2_democracy/sucF) dirs(dem bef)
makedirs,base(${temp}/2_democracy/sucM) dirs(dem bef inst instBef age others)
makedirs,base(${temp}/3_addVars) dirs(cnts gdp heF heM hecnts vdem spatial)
makedirs,base(${paper}/1_estimates ${paper}/2_figures ${paper}/3_tables) dirs(v${version})
makedirs,base(${savee}) dirs(tot sucM sucF cnts FigBef wFigBef mFigBef FigBefSuciy FigBefSuclt FigBefCntslt FigBefRFiy FigBefRF FigBefRFSuciy FigBefRFSuc)
makedirs,base(${savef}) dirs(FigComp)
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
do code/v${version}/1_surveys
do code/v${version}/2_others
do code/v${version}/3_exposure
do code/v${version}/4_consolidate
do code/v${version}/5_tables
do code/v${version}/6_figures