cap program drop qvalues
program define qvalues,byable(onecall)
syntax varlist(min=1 max=1 numeric),[Generate(name)]
*di "varlist=`varlist'"
*di "name=`generate'"
*di "by=`_byvars'"
qui {
tempvar original_sorting_order byvarid touse totalpvals rank qval_adj  fdr_temp1 reject_temp1 reject_rank1 total_rejected1 qval_2st fdr_temp2 reject_temp2 reject_rank2 total_rejected2
qui g int `original_sorting_order'=_n
if !mi("`_byvars'") gegen `byvarid'=group(`_byvars')
else g `byvarid'=1

marktouse `touse' `varlist'
bys `byvarid':gegen `totalpvals'=sum(`touse')



* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
bys `byvarid' (`varlist'):g `rank'=_n if `varlist'~=.
loc qval=1
g `generate'=1 if `varlist'~=. //Generate the variable that will contain the BKY (2006) sharpened q-values

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.
while `qval' > 0 {
	* First Stage
	g `qval_adj'=`qval'/(1+`qval') //Generate the adjusted first stage q level we are testing: q' = q/1+q
	g `fdr_temp1'=`qval_adj'*`rank'/`totalpvals' //Generate value q'*r/M
	g `reject_temp1'=(`fdr_temp1'>=`varlist') if `varlist'~=. //Generate binary variable checking condition p(r) <= q'*r/M
	g `reject_rank1'=`reject_temp1'*`rank' //Generate variable containing p-value ranks for all p-values that meet above condition
	bys `byvarid':gegen `total_rejected1'=max(`reject_rank1') //Record the rank of the largest p-value that meets above condition

	* Second Stage
	g `qval_2st'=`qval_adj'*(`totalpvals'/(`totalpvals'-`total_rejected1')) //Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	g `fdr_temp2'=`qval_2st'*`rank'/`totalpvals' //Generate value q_2st*r/M
	g `reject_temp2'=(`fdr_temp2'>=`varlist') if `varlist'~=. //Generate binary variable checking condition p(r) <= q_2st*r/M
	g `reject_rank2'=`reject_temp2'*`rank' //Generate variable containing p-value ranks for all p-values that meet above condition
	bys `byvarid':egen `total_rejected2'=max(`reject_rank2') //Record the rank of the largest p-value that meets above condition
	qui replace `generate'=`qval' if `rank'<=`total_rejected2'&`rank'~=. //A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	* Reduce q by 0.001 and repeat loop
	drop `qval_adj' `fdr_temp1' `reject_temp1' `reject_rank1' `total_rejected1' `qval_2st' `fdr_temp2' `reject_temp2' `reject_rank2' `total_rejected2'
	local qval=`qval'-0.001
}
qui sort `original_sorting_order'
* Note: Sharpened FDR q-vals can be LESS than unadjusted p-vals when many hypotheses are rejected, because if you have many true rejections, then you can tolerate several false rejections too (this effectively just happens for p-vals that are so large that you are not going to reject them regardless).
}
end
