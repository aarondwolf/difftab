clear
sysuse nlsw88, clear

* Install, from Github
*net install difftab, from("https://aarondwolf.github.io/difftab")

* Use difftab store after an estimation command
reg wage married##collgrad##industry, r
	difftab store est1, varlist(married##collgrad##2b1.industry)
	difftab add local FE "No"
	
difftab write est1
