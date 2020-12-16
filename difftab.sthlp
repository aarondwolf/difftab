{smcl}
{* *! version 1.0.1 Aaron Wolf 14dec2020}{...}
{title:Title}

{phang}
{cmd:difftab} {hline 2} Create triple difference tables with estout

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: difftab} {opt store} {help name} {opt ,} {opth v:arlist(fvvarlist)} [{opth i(numlist)}]

{p 8 17 2}
{cmd: difftab} {opt write} {help namelist} [{opt using} {it:filename}] [{opt ,} {help esttab:esttab_options} ]



{* Using -help odkmeta- as a template.}{...}
{* 24 is the position of the last character in the first column + 3.}{...}
{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opth v:arlist(fvvarlist)}}3-way interaction {help fvvarlist:factor} variable list (e.g. var1##var2##var3). {p_end}
{synopt:{opth i(numlist)}}List of levels for each variable in {opth v:arlist(fvvarlist)} to be considered "on". Default is {opt i(1 1 1)}. {p_end}
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
{cmd: difftab store} is the equivalent post-estimation command to {help eststo},
storing the factor combinations in matrix {help name}.

{pstd}
{cmd: difftab write} writes matrices prepared using {cmd: difftab store} using
{help esttab}. Any valid esttab or estout options can be added to {cmd: difftab write}.
Users can specify a file with {hepl using}, or choose not to specify a filename
(this will write the table to the Stata output window). {cmd: difftab write} is,
at its core, a wrapper for {help esttab}.

{title:Formatting}

{pstd}
{cmd: difftab write} will return a default table with the following equation,
variable, and model labels:

	{cmd:. reg y var1##var2##var3}
	{cmd:. difftab store est1, varlist(var1##var2##var3)}
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
will display the point estimate, as well as standard errors and p-values by defatult.

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
We can results from multiple models:

	{cmd:.} {cmd: reg hours married##collgrad##union, r}
	{cmd:.} {cmd: difftab store est2, varlist(married##collgrad##union)}
	{cmd:.} {cmd: difftab write est1 est2}


{title:Author}

{pstd}Aaron Wolf, Yale University {p_end}
{pstd}aaron.wolf@yale.edu{p_end}


{title:References}

{phang}Duflo, E. (2001). Schooling and labor market consequences of school construction in Indonesia: Evidence from an unusual policy experiment. American Economic Review, 91(4), 795–813. https://doi.org/10.1257/aer.91.4.795
