*! Carlos Molina
cap program drop droptabular
cap program droptabular
syntax using/ [,HLINEBefore(string) HLINEAfter(string) SPACEAfter(string) SPACEBefore(string)]
di in white `"`using'"'
confirm file `"`using'"'
if regexm(`"`using'"',"\.(.*)$") loc ext=regexs(1)
if "`ext'"!="tex" {
	di as err `"File `using' does not have text ".tex" extension"'
	exit 601
}
preserve
import delimited "`using'",clear delim("ñ")
drop if regexm(v1,"^\\begin{tabular}")
replace v1=regexr(v1,"^\\hline ","")
drop if v1=="\hline\end{tabular}\\"
if "`hlineafter'"!=""{
		replace v1=v1+" \hline " if regexm(v1,"`hlineafter'")
}
if "`hlinebefore'"!=""{
		replace v1=" \hline "+v1 if regexm(v1,"`hlinebefore'")
}
if "`spaceafter'"!=""{
		replace v1=v1+" \\ " if regexm(v1,"`spaceafter'")
}
if "`spacebefore'"!=""{
		replace v1=" \\ "+v1 if regexm(v1,"`spacebefore'")
}
export delimited "`using'",replace delim(";") novarnames
restore
end
