cap program drop difftab
program define difftab, rclass eclass

	syntax anything [ using] [, i(numlist max=3 ) fmt(string) SCALEbox(real 1) notes(string asis) * ]

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

	* Ensure there are 3-way interactions or 2-way interactions
	local varlist _cons `varlist'
	local numvars: word count `varlist'
	cap assert `numvars' == 8 | `numvars' == 4
	if _rc {
		di as error "Factor variable varlist must contain 2 or 3-way interactions"
		error 198
	}
	
	
	
preserve


//	Use i option to sustitute in the correct levels
	* Isolate variable 1, 2, and 3
	local level1: word 2 of `varlist'
	local level2: word 3 of `varlist'
	local level3: word 5 of `varlist'

	* Get clean version (for pulling titles)
	local varname1: subinstr local level1 "i." ""
	local varname2: subinstr local level2 "i." ""
	local varname3: subinstr local level3 "i." ""

	* Replace i.version with #.version (if specified) [Ignore c.]
	if "`i'" == "" local i 1 1 1
	forvalues j = 1/3 {
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
	}

	* Get off and on values (0 for now, add base level funcitonality later)
	local off1 0
	local off2 0
	local off3 0


	* Replace "i." in varlist with appropriate levels
	local varlist: subinstr local varlist "`level1'" "`var1'", all
	local varlist: subinstr local varlist "`level2'" "`var2'", all
	local varlist: subinstr local varlist "`level3'" "`var3'", all

//	Store each set of interactions as a letter (A, B, C, ...)
	forvalues i = 1/8 {
		local alpha: word `i' of `c(ALPHA)'
		local `alpha': word `i' of `varlist'
	}

//	Write Matrix
qui {
	* Panel A: Level 3 On
	lincom `A' + `B' + `C' + `D' + `E' +  `F' + `G' + `H'
		mat A11 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A' + `C' + `E' + `G'
		mat A12 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `B' + `D' + `F' + `H'
		mat A13 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A' + `B' + `E' + `F'
		mat A21 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A' + `E'
		mat A22 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `B' + `F'
		mat A23 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `C' + `D' + `G' + `H'
		mat A31 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `C' + `G'
		mat A32 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `D' + `H'
		mat A33 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'

	* Panel B: Level 3 Off
	lincom `A'+`B'+`C'+`D'
		mat B11 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A'+`C'
		mat B12 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `D'+`B'
		mat B13 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A'+`B'
		mat B21 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `A'
		mat B22 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `B'
		mat B23 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `C' + `D'
		mat B31 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `C'
		mat B32 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `D'
		mat B33 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'

	* Panel C: Panel A - Panel B
	lincom `E' + `F' + `G' + `H'
		mat C11 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `E' + `G'
		mat C12 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `F'+`H'
		mat C13 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `E'+`F'
		mat C21 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `E'
		mat C22 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `F'
		mat C23 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `G'+`H'
		mat C31 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `G'
		mat C32 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
	lincom `H'
		mat C33 = `r(estimate)', `r(se)',`r(t)',`r(p)',`r(lb)',`r(ub)',`r(df)'
}


//	Write to Esttab
	* Get varlabels & levels of each variable
	forvalues i = 1/3 {
		local varlab`i': variable label `varname`i''
		if substr("`level`i''",1,2) == "i." {
			local vallabel`i'_on: label (`varname`i'') `on`i''
			local vallabel`i'_off: label (`varname`i'') `off`i''
		}
		else {
			local vallabel`i'_on 1
			local vallabel`i'_off 0
		}
	}

//	Write Matrices to columns

	*eststo clear
	forvalues i = 1/3 {
		matrix tmp = A1`i' \ A2`i' \ A3`i' \ B1`i' \ B2`i' \ B3`i' \ C1`i' \ C2`i' \ C3`i'
		mat colnames tmp = estimate se t p lb ub df
		mat rownames tmp = r1 r2 r3 r4 r5 r6 r7 r8 r9
		ereturn post
		foreach matrix in estimate se t p lb ub df  {
			qui estadd matrix `matrix' = tmp[1...,"`matrix'"]'
		}
		eststo col`i'
	}

	esttab col1 col2 col3 `using', noobs booktabs nonumbers `options' /// `options' provides any other esttab options the user specifies
		main(estimate `fmt') aux(se `fmt') ///
		refcat(	r1 "\multicolumn{4}{l}{\textit{Panel A: `varlab3' = `vallabel3_on'}} \\ %" ///
				r4 "\midrule \multicolumn{4}{l}{\textit{Panel B: `varlab3' = `vallabel3_off'}} \\ %" ///
				r7 "\midrule \multicolumn{4}{l}{\textit{Panel C: `varlab3' Diff. (`vallabel3_on' - `vallabel3_off')}} \\ %" ///
				, nolab) ///
		mgroups("`varlab1'" "Diff.", pattern(1 0 1) ///
			prefix(\multicolumn{@span}{c}{) suffix(}) span 	///
			erepeat(\cmidrule(lr){@span}))					///
		coeflabels( r1 "\multicolumn{1}{r}{`varlab2': `vallabel2_on'}" ///
					r2 "\multicolumn{1}{r}{`vallabel2_off'}" ///
					r3 "\cmidrule[0.01em](lr){2-4} \multicolumn{1}{r}{Diff. (`vallabel2_on' - `vallabel2_off')}" ///
					r4 "\multicolumn{1}{r}{`varlab2': `vallabel2_on'}" ///
					r5 "\multicolumn{1}{r}{`vallabel2_off'}" ///
					r6 "\cmidrule[0.01em](lr){2-4} \multicolumn{1}{r}{Diff. (`vallabel2_on' - `vallabel2_off')}" ///
					r7 "\multicolumn{1}{r}{`varlab2': `vallabel2_on'}" ///
					r8 "\multicolumn{1}{r}{`vallabel2_off'}" ///
					r9 "\cmidrule[0.01em](lr){2-4} \multicolumn{1}{r}{Diff. (`vallabel2_on' - `vallabel2_off')}" ) ///
		mtitles("`vallabel1_on'" "`vallabel1_off'" "(`vallabel1_on' - `vallabel1_off')") ///
		prehead(	"\begin{table}[htbp]\centering"	///
					"%\addtocounter{table}{-1}" ///
					"%\renewcommand{\thetable}{\arabic{table}a}" ///
					"%\renewcommand{\theHtable}{\thetable B}% To keep hyperref happy" ///
					"\scalebox{`scalebox'}{"	///
					"\begin{threeparttable}[b]" ///
					"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"	///
					"\caption{@title}"	///
					"\begin{tabular}{l c c | c}"	///
					"\toprule"			)	///
		postfoot(	"\bottomrule"	///
					"\end{tabular}"	///
					`notes' ///
					"\end{threeparttable}"	///
					"}"				///
					"\end{table}"	)

restore



//	Return r-class results
	return local var3 `var3'
	return local var2 `var2'
	return local var1 `var1'
	return local varlist `varlist'

end


cap program drop difftab_store
program define difftab_store, rclass eclass


end


cap program drop difftab_write
program define difftab_write, rclass


end





