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

	*set trace on
	difftab_fvparse 2b3.industry##married##union
	return list
	
	difftab_fvparse married##collgrad##union
	return list


