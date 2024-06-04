## New package version

This is a package update to add a function and move messaging and progress bars to the **cli** package. 

## Test environments

  - Local, Ubuntu 22.04.4 LTS, R 4.4.0
  
  - `rhub::rhub_check`, ubuntu-latest, macos-13, macos-latest, windows-latest, Fedora Linux 38 (R-devel), Ubuntu 22.04.4 LTS (R-4.4.0)

## R CMD check results

```
0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

Depending on the checking settings, I can get 1 NOTE where three examples take longer than five seconds to run. All three examples have been wrapped in `donttest` so will not be run during routine testing. 

## Downstream dependencies

This package has has no downstream dependencies.
