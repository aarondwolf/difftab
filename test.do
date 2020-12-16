clear
sysuse nlsw88, clear

* Install, from Github
*net install difftab, from("https://aarondwolf.github.io/difftab")

* Use difftab store after an estimation command
reg wage married##collgrad##union, r
	difftab store est1, varlist(married##collgrad##union)
	difftab add local FE "No"

* The reference option will replace _cons as the base group	
reg wage married##collgrad##union i.industry, r
	qui sum `e(depvar)' if e(sample) & married==0 & collgrad==0 & union==0
	difftab store est2, varlist(married##collgrad##union) reference(`r(mean)')
	difftab add local FE "Yes"	
	
* esttab will still provde a table of estimates for the model
esttab est1 est2, scalars(FE reference) nobaselevels

* difftab write will write the differences matrix (stored in e(b_difftab))
difftab write est1 est2, scalars(FE)

* All esttab options can be added (difftab write is a wrapper for esttab)
difftab write est1 est2, scalars(FE) ///
	eqlabels("Panel A: Union" "Panel B: Non-Union" "Panel C: Difference (Union - Non-Union)") ///
	mtitles(Married Single "Difference (Married - Single)" Married Single "Difference (Married - Single)") ///
	varlabels(1.collgrad "College Graduate" 0.collgrad "Non-College Graduate" D.collgrad "Difference (Grad - Non-Grad)") ///
	mgroups("Wages" "Wages", pattern(1 0 0 1 0 0))

	