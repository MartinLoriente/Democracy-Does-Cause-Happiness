*! Carlos Molina
cap program drop usezipped
cap program usezipped
syntax using/ [,Pattern(string) clear]
loc dir="`c(pwd)'"

*Homogenize extension
loc name=`"`using'"'
if regexm(`"`name'"',"\.dta$") loc name=regexr(`"`name'"',"\.dta$","")
else if regexm(`"`name'"',"\.zip$") loc name=regexr(`"`name'"',"\.zip$","")


confirm f `"`name'.zip"'
if regexm(`"`name'"',"(.*)/(.*)") {
	loc path=regexs(1)
	loc file=regexs(2)
}
else {
	loc path="."
	loc file="`name'"
}

*We create a temporal folder
tempfile tempfolder
cap shell rm -R "`tempfolder'"
mkdir `tempfolder'

*Unzipping file
di as text "1. Unzipping file " as inp `"`file'"'
di as inp "Path: " as res `"`path'"'
di as inp "Zipped file: " as res `"`file'"'

if "`pattern'"=="" loc pattern `"*.dta"'
di as inp "Pattern to find in zipped file: " as res `"`pattern'"'

copy `"`name'.zip"' `"`tempfolder'/`file'.zip"'
qui cd `tempfolder'
unzipfile `"`file'.zip"'

*Using file
loc files1: dir . files "`pattern'"
loc num1: list sizeof local(files1)
cap loc files2: dir "`file'" files "`pattern'"
if _rc==0 {
	loc num2: list sizeof local(files2)
}
else loc num2=0
if `num1'+`num2'>1 {
	qui cd "`dir'"
	*shell rm -R "`dir'/tempfolder"
	di as err "More than one file with pattern " as inp `"`pattern'"' as err `" were found in `file'.zip"'
	di as err "Files found are: " as inp `files1' `files2'
	exit 601	
}
else if `num1'+`num2'==0 {
	qui cd "`dir'"
	*shell rm -R "`dir'/tempfolder"
	di as err "No file with pattern " as inp `"`pattern'"' as err `" was found in basedir nor in folder "' as inp `"`file'.zip"'
	exit 601
}
else if `num1'==1 {
	use `files1',`clear'
	di as text "2. Reading file " as inp `"`files1'"' as text " in " as inp `"`file'"'
}
else if `num2'==1 {
	loc temp `files2'
	di as text "2. Reading file " as inp `"`files2'"' as text " in " as inp `"`file'"'
	u `"`file'/`temp'"',`clear'
}
qui cd "`dir'"
*shell rm -R "`dir'/tempfolder"

if "`c(os)'"=="MacOSX" {
	!rm -R "`tempfolder'"
}
end
