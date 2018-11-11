## New package version

This is a minor package update for the package with some minor additional functionality and the addition of new citation information in the form of a new journal article.   

## Test environments

  - Local, Ubuntu 18.04.1 LTS, R 3.5.1
  
  - Travis CI, Ubuntu 14.04.5 LTS, R 3.5.1
  
  - [win-builder](https://win-builder.r-project.org/), Windows Server 2008, (R-release and R-devel)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 1 note ✖

A false positive by the spell checker (a proper noun in the description field): 

```
* checking CRAN incoming feasibility ... NOTE

Possibly mis-spelled words in DESCRIPTION:
  Carslaw (15:51)
Maintainer: 'Stuart K. Grange <stuart.grange@york.ac.uk>'
```

## R checks

This package is passing on all test environments, with the exception of `r-oldrel-windows-ix86+x86_64`. The failure has been tracked to the dependent lubridate package and the compilation process on these older systems (see https://cran.r-project.org/web/checks/check_results_lubridate.html). 

## Downstream dependencies

This package has has no downstream dependencies.
