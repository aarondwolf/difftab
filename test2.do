clear
sysuse nlsw88, clear

* Install, from Github
*net install difftab, from("https://aarondwolf.github.io/difftab")

* Use difftab mean after an estimation command
reg wage married##collgrad##union i.industry, r
	difftab mean `e(depvar)' if e(sample) & married == 0 & collgrad==0 & union == 0
	difftab store est1, varlist(married##collgrad##union) reference(mean)
	difftab add local FE "No"
	
difftab write est1
