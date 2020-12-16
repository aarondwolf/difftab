clear

net install difftab, from("aarondwolf.github.io/difftab")

sysuse nlsw88, clear

reg wage married##collgrad##union, r
	difftab store mat1, varlist(married##collgrad##union)
reg hours married##collgrad##union, r
	difftab store mat2, varlist(married##collgrad##union)

difftab write mat1 mat2, ///
	eqlabels("Panel A: Union" "Panel B: Non-Union" "Panel C: Difference (Union - Non-Union)") ///
	mtitles(Married Single "Difference (Married - Single)" Married Single "Difference (Married - Single)") ///
	varlabels(1.collgrad "College Graduate" 0.collgrad "Non-College Graduate" D.collgrad "Difference (Grad - Non-Grad)") ///
	mgroups("Wages" "Hours", pattern(1 0 0 1 0 0))
