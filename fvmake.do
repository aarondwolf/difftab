cap program drop difftab_fvmake
program difftab_fvmake , rclass
	
	syntax varname(fv)
	fvexpand `varlist'
	
	local split: subinstr local varlist "." " "
	local varname = cond(wordcount("`split'")==2,word("`split'",2),"`split'")
	local level = cond(wordcount("`split'")==2,"i."+word("`split'",2),"`split'")

	* Find base level
	if regexm("`r(varlist)'","([0-9]+)b.`varname'") local baselevel = regexs(1)
	
	return local level `level'
	return local varname `varname'
	return local original `varlist'
	return local expand `r(varlist)'
	return local baselevel `baselevel'

end


	difftab_fvmake 1b3.industry
	return list
	
	
	
	