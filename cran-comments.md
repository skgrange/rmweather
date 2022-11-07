## New package version

This is a package update to include some extra functionality to allow users to use nested tibbles in their modelling pipeline. 

## Resubmissiom

This is also a resubmission after a 301 URL error was found in the previous version.

## Test environments

  - Local, Ubuntu 20.04.5 LTS, R 4.2.2
  
  - `check_rhub`, Windows Server 2022, R-devel, 64 bit, Ubuntu Linux 20.04.1 LTS, R-release, Fedora Linux, R-devel
  
  - [win-builder](https://win-builder.r-project.org/), Windows Server 2008, (R-release and R-devel)

## R CMD check results

```
0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

Depending on checking settings, I can get 1 NOTE where three examples take longer than five seconds to run. All three examples have been wrapped in `donttest` so will not be run during routine testing. 

## Downstream dependencies

This package has has no downstream dependencies.
