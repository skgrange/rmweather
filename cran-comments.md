## New package version

This is a package update to update the email address for the author and maintainer of the package. Please note that the old email address (`stuart.grange@york.ac.uk`) is no longer active and cannot be reached. 

This is resubmission after CRAN feedback where the URLs in the citation file have been switched to those using DOIs to avoid a build note. 

## Test environments

  - Local, Ubuntu 22.04.4 LTS, R 4.4.2
  
  - `rhub::rhub_check`, ubuntu-latest, macos-13, macos-latest, macos-arm64, windows-latest, Fedora Linux 38 (R-devel), Ubuntu 22.04.5 LTS (R-4.4.2), Ubuntu 22.04.5 LTS (R-4.4.3 beta (2025-02-18 r87748))

## R CMD check results

```
0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

Depending on the checking settings, I can get 1 NOTE where three examples take longer than five seconds to run. All three examples have been wrapped in `donttest` so will not be run during routine testing. 

## Downstream dependencies

This package has has no downstream dependencies.
