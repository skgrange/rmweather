## New package version

This is a minor package update to fix a `donttest` example error due to the release of dplyr 1.0.0. 

## Test environments

  - Local, Ubuntu 18.04.1 LTS, R 4.0.0
  
  - Travis CI, Ubuntu 16.04.6 LTS, R 4.0.0
  
  - [win-builder](https://win-builder.r-project.org/), Windows Server 2008, (R-release and R-devel)

## R CMD check results

```
0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

Depending on checking settings, I can get 1 NOTE where three examples take longer than five seconds to run. All three examples have been wrapped in `donttest` so will not be run during routine testing. 

## Downstream dependencies

This package has has no downstream dependencies.

