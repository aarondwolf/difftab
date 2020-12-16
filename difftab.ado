*! version 1.0.1  14dec2020 Aaron Wolf, aaron.wolf@yale.edu	
cap program drop difftab
program define difftab, rclass

	syntax anything [using] [, Varlist(passthru) i(passthru) * ]

	* Require esttab
	cap which esttab
	if _rc {
		di as error "difftab requires estout. Installing now."
		ssc install estout
	}

//	Capture write or store option
	gettoken cmd namelist: anything
	cap assert inlist("`cmd'","store","write")
		if _rc error 198

//	Run appropriate program
	difftab_`cmd' `namelist' `using', `varlist' `i' `options'

end

cap program drop difftab_store
program define difftab_store, rclass

	syntax name [, Varlist(varlist fv) i(numlist max=3 ) ]

	confirm name DT_`namelist'

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

//	Create "N" vector
	mat `namelist'N = . , `e(N)' , .

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

	cap mat drop `namelist'
	mat `namelist' = 	`A11' , `A12' , `A13' \ ///
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

	mat colnames `namelist' = `colnames'
	mat rownames `namelist' = `rownames'


end

cap program drop difftab_write
program define difftab_write, eclass

	syntax namelist [using] [, *]
	confirm matrix `namelist'

	local nmat: word count `namelist'
	local ncol = `nmat'*3

	* For each result, create three columns in ereturn post
	tempname tmp b
	foreach mat in `namelist' {
		local coleq: coleq `mat'
		local coleq: list uniq coleq
		local mtitles `mtitles' `coleq'
		forvalues i = 1/3 {
			local col1 = (`i'-1)*7 + 1
			local col7 = (`i'-1)*7 + 7
			mat `tmp' = `mat'[1...,`col1'..`col7']
			local colnames: colnames `tmp'
			mat colnames `tmp' = `colnames'
			mat coleq `tmp' = ""
			mat `b' = `tmp'[1...,"estimate"]'
			ereturn post `b'
			foreach col of local colnames {
				qui estadd matrix `col' = `tmp'[1...,"`col'"]'
			}
			if `i' == 2 qui estadd scalar N = `mat'N[1,2]
			eststo `mat'`i'
			local models `models' `mat'`i'
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
