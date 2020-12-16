clear

*net install difftab, from("https://aarondwolf.github.io/difftab")

sysuse nlsw88, clear


reg wage married##collgrad##union, r
	sum `e(depvar)' if e(sample) & married==0 & collgrad==0 & union==0
	difftab store mat1, varlist(married##collgrad##union) reference(`r(mean)')
	
difftab write mat1, ///
	eqlabels("Panel A: Union" "Panel B: Non-Union" "Panel C: Difference (Union - Non-Union)") ///
	mtitles(Married Single "Difference (Married - Single)" Married Single "Difference (Married - Single)") ///
	varlabels(1.collgrad "College Graduate" 0.collgrad "Non-College Graduate" D.collgrad "Difference (Grad - Non-Grad)") ///
	mgroups("Wages" "Hours", pattern(1 0 0 1 0 0))

	