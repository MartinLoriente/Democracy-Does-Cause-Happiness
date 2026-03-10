*! Carlos Molina
cap program drop savezipped
cap program savezipped
syntax using/ [,NOCompress replace /*tar*/]
loc dir="`c(pwd)'"

*Homogenize extension
loc name=`"`using'"'
if regexm(`"`name'"',"\.dta$") loc name=regexr(`"`name'"',"\.dta$","")
else if regexm(`"`name'"',"\.zip$") loc name=regexr(`"`name'"',"\.zip$","")

*Check that there is no other file with same name
cap confirm f "`name'.dta"
loc rc1=_rc
cap confirm f "`name'.zip"
loc rc2=_rc

if missing("`replace'")&(`rc1'==601|`rc2'==601) {
	di as err "file `name'.dta or `name'.zip already exists"
}

*Erase files if replace
if !missing("`replace'")&(`rc1'==0|`rc2'==0){
	cap erase "`name'.dta"
	cap erase "`name'.zip"
}

*Path and file
if regexm(`"`name'"',"(.*)/(.*)") {
	loc path=regexs(1)
	loc file=regexs(2)
}
else {
	loc path="."
	loc file="`name'"
}

qui cd "`path'"

*Compress
if missing("`nocompress'") compress
sa `"`file'.dta"',`label' `replace' `all'
*if !mi("`tar'"){
*	!tar cfz "`file'.tgz" "`file'"
*}
zipfile `"`file'.dta"',saving(`"`file'"',`replace')
erase `"`file'.dta"'
qui cd "`dir'"
end


