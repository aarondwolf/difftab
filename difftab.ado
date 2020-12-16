*! version 2.0.1  16dec2020 Aaron Wolf, aaron.wolf@yale.edu	
cap program drop difftab
program define difftab, eclass

	syntax anything, [*]

	* Require esttab
	cap which esttab
	if _rc {
		di as error "difftab requires estout. Installing now."
		ssc install estout
	}

//	Capture write or store option
	gettoken cmd anything: anything
	cap assert inlist("`cmd'","store","write","add")
		if _rc error 198

//	Run appropriate program
	difftab_`cmd' `anything', `options'
	
//	If difftab_store is run, add e-class results
	if "`cmd'" == "store" {
		* Add est name
		qui ereturn local name `r(name)'
		
		* Add reference (if non-missing)
		if "`r(reference)'" != "" qui ereturn scalar reference = r(reference)
		
		* Add difftab matrix
		tempname DT
		matrix `DT' = r(b_difftab)
		qui ereturn matrix b_difftab = `DT'
		
		* Store results and hold to restore later with difftab write
		qui eststo `r(name)'
		cap _estimates drop DT_`r(name)'
		_estimates hold DT_`r(name)', copy
	}


end

cap program drop difftab_store
program define difftab_store, rclass

	syntax name , Varlist(varlist fv) [i(numlist max=3 ) REFerence(string) ]

	confirm name `namelist'
	if "`reference'" != "" confirm number `reference'

//	Syntax Checks
	* Ensure there are 3-way interactions
	local varlist _cons `varlist'
	local numvars: word count `varlist'
	cap assert `numvars' == 8
	if _rc {
		di as error "Factor variable varlist must contain 3-way interactions"
		error 198
	}

	* Replace i with 1s if not specified
	if "`i'" == "" local i 1 1 1
	
//	Isolate the 2/3 variables, and the appropriate factor levels
	* Isolate variable 1, 2, and 3
	local level1: word 2 of `varlist'
	local level2: word 3 of `varlist'
	local level3: word 5 of `varlist'

	* Replace i.version with #.version (if specified) [Ignore c.]
	forvalues j = 1/3 {
		* Get clean version (for pulling titles)
		local varname`j': subinstr local level`j' "i." ""
		* Replace "i." in varlist with appropriate levels
		if substr("`level`j''",1,2) == "i." {
			gettoken level i: i
			if "`level'" == "" local level 1
			local var`j': subinstr local level`j' "i." "`level'."
			local on`j' `level'
		}
		else {
			local var`j' `level`j''
			local on`j' 1
		}
		local varlist: subinstr local varlist "`level`j''" "`var`j''", all
		* Get off and on values (0 for now, add base level funcitonality later)
		local off`j' 0
	}

//	Store each set of interactions as a letter (A, B, C, D ... for _cons, 1.level1 1.level2 1.level1#1.level2, etc.)
	forvalues i = 1/8 {
		local alpha: word `i' of `c(ALPHA)'
		local `alpha': word `i' of `varlist'
	}
	
	* Replace the constant (A) with the value of reference if specified
	if "`reference'" != "" local A `reference'
	else local A _cons

//	Construct vectors of all 27 possible linear combinations
	tempname A11 A12 A13 A21 A22 A23 A31 A32 A33 B11 B12 B13 B21 B22 B23 B31 B32 B33 C11 C12 C13 C21 C22 C23 C31 C32 C33

//	Write Matrix
qui {
	* Panel A: Level 3 On
	lincom `A' + `B' + `C' + `D' + `E' +  `F' + `G' + `H'
		mat `A11' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A' + `C' + `E' + `G'
		mat `A12' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `B' + `D' + `F' + `H'
		mat `A13' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A' + `B' + `E' + `F'
		mat `A21' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A' + `E'
		mat `A22' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `B' + `F'
		mat `A23' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `C' + `D' + `G' + `H'
		mat `A31' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `C' + `G'
		mat `A32' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `D' + `H'
		mat `A33' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'

	* Panel B: Level 3 Off
	lincom `A'+`B'+`C'+`D'
		mat `B11' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A'+`C'
		mat `B12' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `D'+`B'
		mat `B13' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A'+`B'
		mat `B21' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A'
		mat `B22' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `B'
		mat `B23' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `C' + `D'
		mat `B31' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `C'
		mat `B32' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `D'
		mat `B33' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'

	* Panel C: Panel A - Panel B
	lincom `E' + `F' + `G' + `H'
		mat `C11' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `E' + `G'
		mat `C12' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `F'+`H'
		mat `C13' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `E'+`F'
		mat `C21' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `E'
		mat `C22' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `F'
		mat `C23' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `G'+`H'
		mat `C31' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `G'
		mat `C32' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `H'
		mat `C33' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
}

	tempname `namelist'
	mat ``namelist'' = 	`A11' , `A12' , `A13' \ ///
							`A21' , `A22' , `A23' \ ///
							`A31' , `A32' , `A33' \ ///
							`B11' , `B12' , `B13' \ ///
							`B21' , `B22' , `B23' \ ///
							`B31' , `B32' , `B33' \ ///
							`C11' , `C12' , `C13' \ ///
							`C21' , `C22' , `C23' \ ///
							`C31' , `C32' , `C33'

	* Create column names
	foreach x in `on1'.`varname1' `off1'.`varname1' d.`varname1' {
		foreach y in estimate se t p lb ub df {
			local colnames `colnames' `x':`y'
		}
	}

	* Create Rownames
	foreach x in `on3'.`varname3' `off3'.`varname3' d.`varname3' {
		foreach y in `on2'.`varname2' `off2'.`varname2' d.`varname2' {
			local rownames `rownames' `x':`y'
		}
	}

	mat colnames ``namelist'' = `colnames'
	mat rownames ``namelist'' = `rownames'
	
	* Return namelist in r
	qui return local name  "`namelist'"
	qui return matrix b_difftab = ``namelist''
	if "`reference'" != "" qui return scalar reference = `reference'

end

cap program drop difftab_write
program define difftab_write, eclass

	syntax namelist [using] [, *]
	
	* Parse scalars added in options
	
	
	* For each result, create three columns in ereturn post
	tempname mat tmp b
	foreach est in `namelist' {
		* Load estimation results stored in temp matrix
		_estimates unhold DT_`est'
		_estimates hold DT_`est', copy
		
		* Get unique column eq titles for use as mtitles
		local coleq: coleq e(b_difftab)
		local coleq: list uniq coleq
		local mtitles `mtitles' `coleq'
		
		* Store each column set as separate model
		forvalues i = 1/3 {
			* Load estimation results stored in temp matrix
			_estimates unhold DT_`est'
			_estimates hold DT_`est', copy
			mat `mat' = e(b_difftab)
			
			* Pull first/second/third 7 columns into temp mat
			local col1 = (`i'-1)*7 + 1
			local col7 = (`i'-1)*7 + 7
			mat `tmp' = `mat'[1...,`col1'..`col7']
			
			* Repost column 1 as b
			local colnames: colnames `tmp'
			mat colnames `tmp' = `colnames'
			mat coleq `tmp' = ""
			mat `b' = `tmp'[1...,"estimate"]'
			ereturn post `b', noclear
			
			* Loop over column names and write matrices of lincom results
			foreach col of local colnames {
				qui estadd matrix `col' = `tmp'[1...,"`col'"]'
			}
			eststo `est'`i'
			local models `models' `est'`i'
		}
	}
	

	
	* If mtitles is specified in options, do not print mtitles
	if 	regexm(`"`options'"',"(mti\()") | ///
		regexm(`"`options'"',"(mtit\()") | ///
		regexm(`"`options'"',"(mtitl\()") | ///
		regexm(`"`options'"',"(mtitle\()") | ///
		regexm(`"`options'"',"(mtitles\()") local mtitles
	else if regexm(`"`options'"',"(nomti)") local mtitles
	else local mtitles mtitles(`mtitles')

	* Write table using esttab
	esttab `models' `using', `options' `mtitles'


end

cap program drop difftab_add
program define difftab_add

	syntax anything, [*]
	
	* Run esttad command
	estadd `anything', `options'
	
	* Store results and hold to restore later with difftab write
	qui eststo `e(name)'
	cap _estimates drop DT_`e(name)'
	_estimates hold DT_`e(name)', copy
	

end

