# difftab
## Syntax

        difftab store name , varlist(fvvarlist) [i(numlist)]
    
        difftab write namelist [using filename] [, esttab_options ]

Options
-----------------------------------------------------------------------------------------------

-   **varlist(fvvarlist)** 3-way interaction factor variable list (e.g. var1##var2##var3).
-  **i(numlist)** List of levels for each variable in *varlist(fvvarlist)* to be considered "on". Default is i(1 1 1).
- **esttab_options** Any valid options specified in esttab.

Description

**difftab** is a post-estimation command that takes the results of a regression command containing
varlist(fvvarlist) and returns a 2x2x2 table containing the predicted value of Y for every
possible linear combination of factor levels, and their differences. For example, see Duflo
(2001), Table 3.

**difftab store** is the equivalent post-estimation command to eststo, storing the factor
combinations in matrix name.

**difftab write** writes matrices prepared using difftab store using esttab. Any valid esttab or
estout options can be added to difftab write.  Users can specify a file with {hepl using}, or
choose not to specify a filename (this will write the table to the Stata output window).
difftab write is, at its core, a wrapper for esttab.

## Formatting

difftab write will return a default table with the following equation, variable, and model
labels:

```
    . reg y var1##var2##var3
    . difftab store est1, varlist(var1##var2##var3)
    . difftab write est1
```

        +----------------------------------------+
        |               1.var1  0.var1  D.var1   |
        |----------------------------------------|
        | 1.var3                                 |
        |   1.var2                               |
        |   0.var2                               |
        |   D.var2                               |
        |----------------------------------------|
        | 0.var3                                 |
        |   1.var2                               |
        |   0.var2                               |
        |   D.var2                               |
        |----------------------------------------|
        | D.var3                                 |
        |   1.var2                               |
        |   0.var2                               |
        |   D.var2                               |
        +----------------------------------------+
Where #.varname represents variable varname evaluated at #, and D.varname represents the
difference, (1.varname - 0.varname).  difftab write will display the point estimate, as well as
standard errors and p-values by defatult.

To change the labels for var1, use the mtitles() option in esttab. For example:

​    

```
. difftab write est1, mlabels("On" "Off" "Difference")
```

To change the labels for var2, use the varlabels() option in esttab.

```
 . difftab write est1, varlabels(1.var2 "On" 0.var2 "Off" D.var2 "Difference")
```

To change the labels for var3, use the eqlabels() option in esttab.

```
    . difftab write est1, eqlabels("On" "Off" "Difference")
```

To remove the lines between panels, use the nolines option in esttab

```
    . difftab write est1, nolines
```

## Examples

Load NLSW data:

```
    .  sysuse nlsw88, clear
```

Regress wage on 3 different demographic indicators:

```
    .  reg wage married##collgrad##union, r
```

Store results and write a basic table:

```
    .  difftab store est1, varlist(married##collgrad##union)
    .  difftab write est1
```

We can combine results from multiple models:

```
    .  reg hours married##collgrad##union, r
    .  difftab store est2, varlist(married##collgrad##union)
    .  difftab write est1 est2
```

## Author

Aaron Wolf, Yale University
aaron.wolf@yale.edu

## References

Duflo, E. (2001). Schooling and labor market consequences of school construction in Indonesia:
    Evidence from an unusual policy experiment. American Economic Review, 91(4), 795–813.
    https://doi.org/10.1257/aer.91.4.795