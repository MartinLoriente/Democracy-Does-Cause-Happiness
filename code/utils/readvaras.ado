*! Carlos Molina, version 1 (27dec2020)
cap program drop readvaras
program define readvaras
syntax,OLDName(string) NEWName(string) [OUTPUT(integer 1) RECODE(string) LABEL(string) VALUELabel(string) replace] 

*CASES
/*
Output 1: Want output to be numeric
Output 2: Want output to be string value
Output 3: Want output to be string value+value label if any
Output 4: Want output to be string value label if any

Conversion 1: Value to string. Recode=>conversion
Conversion 2: Value+Value label to string. Recode=>Value label=>Conversion
Conversion 3: Value label to string. Recode=>Value label=>Conversion
Conversion 4: String to value. Conversion=>Recode=>Value label
Valuelabel can be either the word "none" or can be the value label
*/



*SET UP AND INITIAL WARNINGS

*Check output is an integer that ranges between 1 and 4
if inlist(`output',1,2,3,4)==0 {
	di as err "{opt output} can take as input only integers value between 1 and 4"
	exit 601
}


*Check if newname exists
cap confirm v `newname',ex
if _rc==0&mi("`replace'") {
	di as err "Input {bf:`newname'} already exists, use another name or the option {bf:replace}"
	exit 601
}
else if _rc==0&!mi("`replace'") loc dropvar=1

*Check if old value label exists
loc typestr=regexm(`"`:type `oldname''"',"^str")
loc oldvlabel=`"`:value label `oldname''"'

*It could happen (it happens in the latinobarometer 2000 for the variable P14CG_A) that the value label has a dot so that the name is invalid. Unfortunatelly Stata throws a red flag but does not exit the procedure. This is a problem becuase we cannot copy the label. We solve that problem decoding the variable and using labmask.
if !mi("`oldvlabel'") {
	cap confirm names `oldvlabel'
	qui if _rc!=0{
		di as input "Value label {bf:`oldvlabel'} has invalid character and was renamed to match the variable name: `oldname'"
		tempvar temp
		decode `oldname',g(`temp')
		labmask `oldname',values(`temp')
		loc oldvlabel=`"`:value label `oldname''"'
	}
}
if !mi("`oldvlabel'") {
	loc hadoldvlabel=real(`"`: label `oldvlabel' maxlength'"')>0
}
else loc hadoldvlabel=0
loc valueldefined=`hadoldvlabel'==1|(!mi(`"`valuelabel'"')&`"`valuelabel'"'!="none")





*DEFINE CONVERSION
if `typestr'==1&`output'==1 {
	di as input "String to numeric"
	loc conversion=4
}

if `typestr'==1&inlist(`output',2,3,4) {
	di as input "String to string"
	if !mi(`"`valuelabel'"')&`"`valuelabel'"'!="none" di as input "{opt valuelabel} ommited"
	if !mi("`recode'") di as input "{opt recode} ommited"
	loc conversion=0
}

if `typestr'==0&`output'==1 {
	di as input "Numeric to numeric"
	loc conversion=0
}

if `typestr'==0&`output'==2 {
	di as input "Value to string"
	loc conversion=1
	if !mi(`"`valuelabel'"')&`"`valuelabel'"'!="none" di as input "{opt valuelabel} ommited"
}

if `typestr'==0&`output'==3 {
	if `valueldefined'==1 {
		di as input "Value plus value label to string"
		loc conversion=2
	}
	else {
		di as input "Value label is not defined for Value+value label to string procedure, so procedure changed to value to string"
		loc conversion=1
	}	
}

if `typestr'==0&`output'==4 {
	if `valueldefined'==1 {
		di as input "Value label to string"
		loc conversion=3
	}
	else {
		di as input "Value label is not defined for value label to string procedure, so procedure changed to value to string"
		loc conversion=1
	}	
}


*SAVE RAW VARIABLE (oldname) AND VALUE LABEL
tempvar t0 t1 t2 t3
tempname t0value t1value
g `t0'=`oldname'
if `hadoldvlabel'==1 {
	label copy `oldvlabel' `t0value'
}
if !mi("`replace'")&!mi("`dropvar'") drop `oldname'

*DROP VALUE LABEL STORAGED AS `newname' IF EXISTS
if real(`"`: label `newname' maxlength'"')>0{
	la drop `newname'
	di as input "Value label {bf:`newname'} will be replaced"
}

*CASES
*0.1 NUMERIC TO NUMERIC
if `typestr'==0&`conversion'==0{
	*Recode
	if mi("`recode'") qui g `newname'=`t0'
	else qui recode `t0' `recode',g(`newname')
	*Value label
	if !mi(`"`valuelabel'"')&`"`valuelabel'"'!="none" {
		la def `newname' `valuelabel'
		la value `newname' `newname'
	}
	else if mi(`"`valuelabel'"')&`hadoldvlabel'==1 {
		label copy `t0value' `newname'
		la value `newname' `newname'
	}
}

*0.2 STRING TO STRING
if `typestr'==1&`conversion'==0{
	g `newname'=`t0'
}

*1. VALUE TO STRING
if `conversion'==1{
	*Recode
	if mi("`recode'") qui g `t1'=`t0'
	else qui recode `t0' `recode',g(`t1') 
	
	*Conversion
	g `newname'=string(`t1')
}

*2. VALUE+VALUE LABEL TO STRING
if `conversion'==2{
	*Recode
	if mi("`recode'") qui g `t1'=`t0'
	else qui recode `t0' `recode',g(`t1')
	*Value label
	if !mi(`"`valuelabel'"')&`"`valuelabel'"'!="none" {
		la def `t1value' `valuelabel'
		la value `t1' `t1value'
	}
	else if mi(`"`valuelabel'"')&`hadoldvlabel'==1 {
		
		label copy `t0value' `t1value'
		la value `t1' `t1value'
	}
	*Conversion
	
	decode `t1',g(`t2')
	g `t3'=string(`t1')
	
	g `newname'=cond(`t2'=="",`t3',`t3'+". "+`t2')
	qui replace `newname'="" if `newname'=="."
}

*3. VALUE LABEL TO STRING
if `conversion'==3{
	*Recode
	if mi("`recode'") qui g `t1'=`t0'
	else qui recode `t0' `recode',g(`t1')
	*Value label
	if !mi(`"`valuelabel'"')&`"`valuelabel'"'!="none" {
		la def `t1value' `valuelabel'
		la value `t1' `t1value'
	}
	else if mi(`"`valuelabel'"')&`hadoldvlabel'==1 {
		label copy `t0value' `t1value'
		la value `t1' `t1value'
	}
	*Conversion
	decode `t1',g(`newname')
}


*4. STRING TO VALUE
if `conversion'==4{
	*Conversion
	qui destring `t0',replace
	if regexm(`"`:type `t0''"',"^str")==1 {
		di as error "Variable cannot be converted using {cmd:destring}"
		exit 601
	}	
	*Recode
	if mi("`recode'") g `newname'=`t0'
	else recode `t0' `recode',g(`newname')
	
	*Value label
	if !mi(`"`valuelabel'"')&`"`valuelabel'"'!="none" {
		la def `newname' `valuelabel'
		la value `newname' `newname'
	}
	else if mi(`"`valuelabel'"')&`hadoldvlabel'==1 {
		label copy `t0value' `newname'
		la value `newname' `newname'
	}
}
cap la drop `t0value'
cap la drop `t1value'
la var `newname' `"`label'"'
end

