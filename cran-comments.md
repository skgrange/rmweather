## Resubmission

This is a resubmission to address failure of the manual CRAN checks. I have: 

  - Expanded the package's description and added a reference which uses the method to conduct an analysis (https://doi.org/10.5194/acp-18-6223-2018)
  
  - Replaced \dontrun{} with \donttest{} for examples. Most examples cannot be run because they will take minutes rather than seconds. 

## Test environments

  - Local, Ubuntu 16.04.4 LTS, R 3.4.4
  
  - Travis CI, Ubuntu 14.04.5 LTS, R 3.5.0
  
  - [win-builder](https://win-builder.r-project.org/), Windows Server 2008, (R-release and R-devel)

## R CMD check results

No errors or warnings, but one note. 

  - `checking CRAN incoming feasibility ... NOTE`
  
    - This is the first submission of this package

## Downstream dependencies

This is a new package and therefore has it has no downstream dependencies.

## Other comments

This is a new package. I have followed the instructions outlined by Hadley Wickham's R packages book and have used the **devtools** package.
