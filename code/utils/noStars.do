loc files: dir "${savet}" files "*.tex"
qui foreach f of local files {
	if regexm("`f'","appSources") copy "${savet}/`f'" "${savet}/noStars/`f'",replace
	else {
		noi di as input "Processing file `f'"
		import delimited "${savet}/`f'",clear delimiter("ñ")
		forv i=1/5{
			replace v1=subinstr(v1,"*","",.)
		}

		file open myfile using "${savet}/noStars/`f'", write replace
		loc N=_N
		forv i=1/`N'{
			loc a=v1 in `i'
			file write myfile "`a'" _n
		}
		file close myfile
	}
}

