## New package version

This is a minor package update submission with the primary changes relating to replacing depricated functions.     

## Test environments

  - Local, Ubuntu 18.04.1 LTS, R 3.6.3
  
  - Travis CI, Ubuntu 16.04.6 LTS, R 3.6.2
  
  - [win-builder](https://win-builder.r-project.org/), Windows Server 2008, (R-release and R-devel)
  
  - R-Hub
    - Windows Server 2008 R2 SP1, R-devel, 32/64 bit
    - Ubuntu Linux 16.04 LTS, R-release, GCC
    - Fedora Linux, R-devel, clang, gfortran

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
