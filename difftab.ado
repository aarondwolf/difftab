*! version 2.0.4  16dec2020 Aaron Wolf, aaron.wolf@yale.edu	
cap program drop difftab
program define difftab, eclass

	syntax anything [using] [=exp] [if] [in] , [*]

	* Require esttab
	cap which esttab
	if _rc {
		di as error "difftab requires estout. Installing now."
		ssc install estout
	}

//	Capture write or store option
	gettoken cmd anything: anything
	cap assert inlist("`cmd'","store","write","add","mean")
		if _rc error 198

//	Run appropriate program
	difftab_`cmd' `anything' `using' `if' `in' `exp', `options'

//	If difftab_store is run, add e-class results and store estimates
	if "`cmd'" == "store" {
		* Add est name
		qui ereturn local name `r(name)'

		* Add reference (if non-missing)
		if "`r(reference)'" != "" qui ereturn local reference = r(reference)

		* Add difftab matrix
		tempname DT
		matrix `DT' = r(b_difftab)
		qui ereturn matrix b_difftab = `DT'
				
		* Store results and hold to restore later with difftab write
		qui eststo `r(name)'
		cap _estimates drop DT_`r(name)'
		_estimates hold DT_`r(name)', copy
	}

//	If difftab_mean is run, convert r-class results to e-class results
	if "`cmd'" == "mean" {
		*return list

		* Collect all r-class results and save as e-class results instead
		foreach type in scalars macros matrices {
			* Collect names of all results of a certain type
			local names: r(`type')

			* Rename type to singular
			if "`type'" == "scalars" local type scalar
			if "`type'" == "macros" local type local
			if "`type'" == "matrices" local type matrix

			* Return all names as r-class result
			foreach name of local names {
				if inlist("`type'","scalar","local") ereturn `type' MEAN_`name' = r(`name')
				else {
					tempname `name'
					mat ``name'' = r(`name')
					ereturn matrix MEAN_`name' = ``name''
				}
			}
		}
	}


end

cap program drop difftab_store
program define difftab_store, rclass

	syntax name , Varlist(string) [REFerence(string) ]

	confirm name `namelist'

//	Check to see 'reference' specified. If so, check it is a mean or a number
	if "`reference'" == "mean" {
		* Ensure mean command was run
		cap assert "`e(MEAN_table)'" != ""
		if _rc {
			di as error "{it:mean} can only be specified after {bf:difftab mean} has been run."
			error 198
		}
		else {
			tempname mean
			mat `mean' = e(MEAN_table)
		}
	}
	else if "`reference'" != "" {
		confirm number `reference'
	}

//	Parse Factor Variable list from varlist
	difftab_fvparse `varlist'

	forvalues i = 1/3 {
		* Create "on" version of variable for lincom
		if "`r(type`i')'" == "factor" local var`i' `r(on`i')'.`r(varname`i')'
		else if "`r(type`i')'" == "continuous" local var`i' c.`r(varname`i')'

		* Store results as locals
		foreach x in off on varname type {
			local `x'`i' `r(`x'`i')'
		}
	}
	
	* Return locals
	foreach j in 3 2 1 {
		return scalar on`j' = `on`j''
		return scalar off`j' = `off`j''

		return local type`j' `type`j''
		return local factor`j' `r(factor`j')'
		return local varname`j' `varname`j''
		return local fvlist`j' `r(fvlist`j')'
	}
	

//	Store each set of interactions as a letter (A, B, C, D ... for _cons, 1.level1 1.level2 1.level1#1.level2, etc.)
	* If reference == mean pull b from MEAN_table, else use reference, else use _cons
	if "`reference'" == "mean" local A = `mean'["b",1]
	else if "`reference'" != "" local A = `reference'
	else local A _cons

	local B `var1'
	local C `var2'
	local D `var1'#`var2'
	local E `var3'
	local F `var1'#`var3'
	local G `var2'#`var3'
	local H `var1'#`var2'#`var3'

//	Construct vectors of all 27 possible linear combinations
	tempname A11 A12 A13 A21 A22 A23 A31 A32 A33 B11 B12 B13 B21 B22 B23 B31 B32 B33 C11 C12 C13 C21 C22 C23 C31 C32 C33

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

	* If reference = mean, use results from mean, else lincom
	if "`reference'" == "mean" mat `B22' = `mean'["b",1], `mean'["se",1],`mean'["t",1],`mean'["pvalue",1],`mean'["ll",1],`mean'["ul",1],`mean'["df",1]
	else {
		lincom `A'
			mat `B22' = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	}

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

	* Store all 3 panels to estimate name
	tempname `namelist'
	mat ``namelist'' = 		`A11' , `A12' , `A13' \ ///
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
	if "`reference'" != "" qui return local reference `reference'

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
			
			* If i = 2, noclear (removes eclass results from 1 and 3)
			if `i' == 2 local noclear noclear
			else local noclear

			* Repost column 1 as b
			local colnames: colnames `tmp'
			mat colnames `tmp' = `colnames'
			mat coleq `tmp' = ""
			mat `b' = `tmp'[1...,"estimate"]'
			ereturn post `b', `noclear'

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

	syntax anything [=exp], [*]

	* Run esttad command
	estadd `anything' `exp', `options'

	* Store results and hold to restore later with difftab write
	qui eststo `e(name)'
	cap _estimates drop DT_`e(name)'
	_estimates hold DT_`e(name)', copy


end

cap program drop difftab_fvparse
program difftab_fvparse , rclass

	syntax anything

//	Confirm that anything can be expanded
	fvexpand `anything'
	cap assert "`r(fvops)'" == "true"
	if _rc {
		di as error "{opt v:arlist} must contain factor variable operations."
		error 198
	}

//	Parse anything to collect vars 1-3
	tokenize `anything', parse("##")
	cap assert "`2'" == "#" & "`3'" == "#" & "`5'" == "#" & "`6'" == "#" & "`8'" == ""
		if _rc {
			di as error "Must specify complete 3-way interactions."
			error 198
		}
	local factor1 `1'
	local factor2 `4'
	local factor3 `7'

//	For each variable, parse c/i options and varname
	forvalues j = 1/3 {
		* Add i. if missing
		tokenize "`factor`j''", parse(".")
		if "`2'" == "" local factor`j' i.`factor`j''

		* Split into pre, . , and varname
		tokenize "`factor`j''", parse(".")
		local varname`j' `3'
	}

//	Expand each list to extract base level (off) and comparison level (on)
	foreach j in 3 2 1 {
		qui fvexpand `factor`j''
		local fvlist`j' `r(varlist)'

		if "`r(fvops)'" == "true" {
			local type`j' factor
			if regexm("`r(varlist)'","([0-9]+)b.`varname`j''") local off`j' = regexs(1)

			* Remove base level from list (if factor var)
			local fvlist `r(varlist)'
			local base `off`j''b.`varname`j''
			local fvlist: list fvlist - base

			* Remove omitted levels from list
			while regexm("`fvlist'","([0-9]+)o.`varname`j''") {
				local fvlist = regexr("`fvlist'","([0-9]+)o.`varname`j''","")
			}
			local fvlist: list uniq fvlist
			local omitted delete.`varname`j''
			local fvlist: list fvlist - omitted

			* Choose first item in list as "on" level
			tokenize `fvlist'
			tokenize `1', parse(".")
			local on`j' `1'
		}
		else {
			local type`j' continuous
			local on`j' 1
			local off`j' 0
		}
	}

//	Return locals
	foreach j in 3 2 1 {
		return scalar on`j' = `on`j''
		return scalar off`j' = `off`j''

		return local type`j' `type`j''
		return local factor`j' `factor`j''
		return local varname`j' `varname`j''
		return local fvlist`j' `fvlist`j''
	}

//	Unabbreviate FV list
	fvunab fvunab: `anything'
	return local fvunab `fvunab'

end

cap program drop difftab_mean
program define difftab_mean, rclass

	syntax varname [if] [in] [fweight  aweight  pweight  iweight], [*]

	* Preserve estimates in memory
	tempname estimates
	_estimates hold `estimates', copy

	* Run mean command
	mean `varlist' `if' `in' `weight'`exp', `options'
	*ereturn list
	*return list

	* Collect r(table) and store as temporary matrix
	tempname table
	mat `table' = r(table)

	* Collect all e-class results and save as r-class results instead
	foreach type in scalars macros matrices {
		* Collect names of all results of a certain type
		local names: e(`type')

		* Rename type to singular
		if "`type'" == "scalars" local type scalar
		if "`type'" == "macros" local type local
		if "`type'" == "matrices" local type matrix

		* Return all names as r-class result
		foreach name of local names {
			if inlist("`type'","scalar","local") return `type' `name' = e(`name')
			else {
				tempname `name'
				mat ``name'' = e(`name')
				return matrix `name' = ``name''
			}
		}
	}

	* Store results and hold to restore later with difftab write
	_estimates unhold `estimates'
	return matrix table = `table'

end
