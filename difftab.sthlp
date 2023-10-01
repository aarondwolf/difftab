{smcl}
{* *! version 2.0.4 Aaron Wolf 14dec2020}{...}
{title:Title}

{phang}
{cmd:difftab} {hline 2} Create triple difference tables with estout

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: difftab} {opt mean} {help varname} [{it:{help if}}] [{it:{help in}}] [{it:{help weight}}] [{opt ,} {help mean:mean_options} ]

{p 8 17 2}
{cmd: difftab} {opt store} {help name} {opt ,} {opth v:arlist(fvvarlist)} [{opt ref:erence}{cmd:(}{{help real} | {cmd:mean}}{cmd:)}]

{p 8 17 2}
{cmd: difftab} {opt add} {help anything} [{opt ,} {help estadd:estadd_options} ]

{p 8 17 2}
{cmd: difftab} {opt write} {help namelist} [{opt using} {it:filename}] [{opt ,} {help esttab:esttab_options} ]


{* Using -help odkmeta- as a template.}{...}
{* 24 is the position of the last character in the first column + 3.}{...}
{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}

{p 4}{it:difftab mean} {p_end}
{synopt:{help mean:mean_options}}Any valid options specified in {help mean}. {p_end}

{p 4}{it:difftab store} {p_end}
{synopt:{opth v:arlist(fvvarlist)}}3-way interaction {help fvvarlist:factor} variable list (e.g. var1##var2##var3). {p_end}
{synopt:{opt ref:erence}{cmd:(}{{help real} | {cmd:mean}}{cmd:})}Reference level for base catagory. Default is {it:_b[_cons]}. May specify a real value, or {cmd:mean} to use the results from a previously run {cmd:difftab mean} command.{p_end}

{p 4}{it:difftab add} {p_end}
{synopt:{help estadd:estadd_options}}Any valid options specified in {help estadd}. {p_end}

{p 4}{it:difftab write} {p_end}
{synopt:{help esttab:esttab_options}}Any valid options specified in {help esttab}. {p_end}
{synoptline}

{title:Description}

{pstd}
{cmd:difftab} is a post-estimation command that takes the results of a
regresion command containing {opth v:arlist(fvvarlist)} and returns a
2x2x2 table containing the predicted value of Y for every possible
linear combination of factor levels, and their differences. For example, see
Duflo (2001), Table 3.

{pstd}
{cmd:difftab mean} is a wrapper for {help mean} which ensures the e-class
results from your previous estimation are preserved. You
may use the same syntax and options with {cmd:difftab mean} as you would with
{help mean}, though {cmd:difftab mean} will only allow you to specify one
variable in {help varlist}. Using {help mean} alone would cause the previous
estimation results in e() to be overwritten.

{pstd}
{cmd: difftab store} is the equivalent post-estimation command to {help eststo},
storing the factor combinations in e(b_difftab) for estimate {help name}.

{pstd}
{cmd: difftab add} is a wrapper for {help estadd}, and ensures that added
scalars, macros, and matrices are added to the model for use in {cmd: difftab write}.
Scalars and macros added using {help estadd} alone will not appear in a table
created using {cmd: difftab write}. {cmd:difftab add} can be used exactly as
{help estadd}.

{pstd}
{cmd: difftab write} writes matrices prepared using {cmd: difftab store} using
{help esttab}. Any valid esttab or estout options can be added to {cmd: difftab write}.
Users can specify a file with {help using}, or choose not to specify a filename
(this will write the table to the Stata output window). {cmd: difftab write} is,
at its core, a wrapper for {help esttab}.

{title:Specifying base and comparison levels}

{pstd}
By default, {cmd: difftab store} will detect the base level used in the estimation,
and use the first non-omitted, non-base-level factor level for any non-continuous
variables in {opt v:arlist} as the "comparison" level (i.e. off and on).

{pstd}
For exmaple, suppose you had three variables, all 0/1 indicators. Then {cmd: difftab}
would know that the base ("off") level for each is 0b.varname, and the comparison ("on") level for
each is 1.varname.

{pstd}
If one (or more) of your variables has multiple factor levels (e.g. varname
takes on the values 1, 2, 3, and 4), then {cmd: difftab} would likewise detect
that the base level is 1b.varname, and would assume the "on" level was
the first non-omitted level (2.varname).

{pstd}
You can control which cmparisons{cmd: difftab} chooses to report using standard
factor variable controls. Suppose you wanted to compare 4.varname (on) to
2.varname (off). Instead of making a new indicator, you could simply run your
regression using the same command:

	{cmd:. reg y var1##var2##var3}

{pstd}
Then in {cmd: difftab store} you would specify {cmd:4b2.varname} for the sppropriate
variable in your {opt v:arlist}. If this was var3, then you would type:

	{cmd:. difftab store est1, varlist(var1}##{cmd:var2}##{cmd:4b2.var3)}
	{cmd:. difftab write est1}

{pstd}
Note that this works even though you specified {it:var1##var2##var3} in your
regerssion. The factor variable list in {opt v:arlist} affacts only the set of
comparisons reported in the table, not your estimation itself.

{title:Formatting}

{pstd}
{cmd: difftab write} will return a default table with the following equation,
variable, and model labels:

	{cmd:. reg y var1##var2##var3}
	{cmd:. difftab store est1, varlist(var1}##{cmd:var2}##{cmd:var3)}
	{cmd:. difftab write est1}

        {c TLC}{hline 40}{c TRC}
        {c |} {it:      	1.var1	0.var1	D.var1}   {c |}
        {c |}{hline 40}{c |}
        {c |} 1.var3			   	     {c |}
        {c |} 	1.var2			   	     {c |}
        {c |} 	0.var2			   	     {c |}
        {c |} 	D.var2			   	     {c |}
        {c |}{hline 40}{c |}
        {c |} 0.var3			   	     {c |}
        {c |} 	1.var2			   	     {c |}
        {c |} 	0.var2			   	     {c |}
        {c |} 	D.var2			   	     {c |}
        {c |}{hline 40}{c |}
        {c |} D.var3			   	     {c |}
        {c |} 	1.var2			   	     {c |}
        {c |} 	0.var2			   	     {c |}
        {c |} 	D.var2			   	     {c |}
        {c BLC}{hline 40}{c BRC}

{pstd}
Where {it:#.varname} represents variable {help varname} evaluated at {it:#}, and
{it:D.varname} represents the difference, (1.varname - 0.varname). {cmd: difftab write}
will display the point estimate, as well as t-statistics and p-values by default.

{pstd}
For example, the first cell in the above table would represent the average value
of Y when all factor variable are "on". Suppose var1, var2, and var3 were simple
0/1 indicators. Then the first cell would represent:

{phang}	_cons + 1.var1 + 1.var2 + 1.var1#1.var2 + 1.var3 + 1.var1#1.var3 + 1.var2#1.var3 + 1.var1#1.var2#1.var3{p_end}

{pstd}
To change the labels for {it:var1}, use the {opt mtitles()} option in {help esttab}. For example:

	{cmd:. difftab write est1, mlabels("On" "Off" "Difference")}

{pstd}
To change the labels for {it:var2}, use the {opt varlabels()} option in {help esttab}.

	{cmd:. difftab write est1, varlabels(1.var2 "On" 0.var2 "Off" D.var2 "Difference")}

{pstd}
To change the labels for {it:var3}, use the {opt eqlabels()} option in {help esttab}.

	{cmd:. difftab write est1, eqlabels("On" "Off" "Difference")}

{pstd}
To remove the lines between panels, use the {opt  nolines} option in {help esttab}

	{cmd:. difftab write est1, nolines}


{title:Examples}

{pstd}
Load NLSW data:

	{cmd:.} {cmd: sysuse nlsw88, clear}

{pstd}
Regress wage on 3 different demographic indicators:

	{cmd:.} {cmd: reg wage married##collgrad##union, r}

{pstd}
Store results and write a basic table:

	{cmd:.} {cmd: difftab store est1, varlist(married##collgrad##union)}
	{cmd:.} {cmd: difftab write est1}

{pstd}
We can results from multiple models, as well as add scalars and/or macros:

	{cmd:.} {cmd: reg wage married##collgrad##union i.industry, r}
	{cmd:.} {cmd: sum `e(depvar)' if e(sample) & married==0 & collgrad==0 & union==0}
	{cmd:.} {cmd: difftab store est2, varlist(married##collgrad##union) reference(`r(mean)')}
	{cmd:.} {cmd: difftab add local FE "Yes"}

	{cmd:.} {cmd: difftab write est1 est2, scalars(FE)}

{title:Changing the Reference Value}

{pstd}
We may wish to specify the "base" value for the caste when all indicators are off
(=0 by default). For example, suppose we ran the following regression:

	{cmd:.} {cmd: reg hours married##collgrad##union i.industry, r}

{pstd}
Now, our base value, _cons, is no longer as informative, as it represents the
average number of hours worked for workers where {it:married == 0}, {it:collgrad == 0},
and {it:union == 0}, but {it:also} where {it:industry = "Ag/Forestry/Fisheries"} (the
base category).

{pstd}
Often, we would prefer to set all cells relative to the average level of hours
for all workers. We could do this with the following:

	{cmd:.} {cmd: reg hours married##collgrad##union i.industry, r}
	{cmd:.} {cmd: sum `e(depvar)' if e(sample) & married==0 & collgrad==0 & union==0}
	{cmd:.} {cmd: difftab store est, varlist(married##collgrad##union) reference(`r(mean)')}

{pstd}
However, as we are now using a real value (instead of a coeficient) for our
reference category, our standard errors will be missing. If you wish to
include a test that your base level is non-zero, you must first use the
{cmd:difftab mean} function to complete a {help mean} test. You can then
specify {opt ref:erence(mean)}, and {cmd:difftab store} will use the results of
the {help mean} command. For example:

	{cmd:.} {cmd: reg hours married##collgrad##union i.industry, r}
	{cmd:.} {cmd: difftab mean `e(depvar)' if e(sample) & married==0 & collgrad==0 & union==0}
	{cmd:.} {cmd: difftab store est, varlist(married##collgrad##union) reference(mean)}

{pstd}
{cmd:difftab mean} is a wrapper for {help mean} which ensures the e-class
results from your estimation are preserved, and the resulting r(table) vector
from {help mean} is stored in e() to be called from {cmd:difftab store}. You
may use the same syntax and options with {cmd:difftab mean} as you would with
{help mean}, though {cmd:difftab mean} will only allow you to specify one
variable in {help varlist}.

{pstd}
When using {opt ref:erence}, {cmd: difftab store} will automatically store the
reference value in e(reference) for the active model.

{pstd}
{bf: Note:} Using a reference category affects the standard errors when
calculating the other cells. This is because {cmd: difftab} calculates F-tests
for the linear combination (e.g. _cons + 1.married = 0). When _cons is replaced
with a real value, the standard errors change (as the real value no longer has
any variation).

{title:Author}

{pstd}Aaron Wolf, Northwestern University {p_end}
{pstd}aaron.wolf@u.northwestern.edu{p_end}


{title:References}

{phang}Duflo, E. (2001). Schooling and labor market consequences of school construction in Indonesia: Evidence from an unusual policy experiment. American Economic Review, 91(4), 795–813. https://doi.org/10.1257/aer.91.4.795
