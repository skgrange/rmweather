## New package version

This is a package update to fix a few minor issues and to move all messaging to the **cli** package. 

## Test environments

  - Local, Ubuntu 22.04 LTS, R 4.3.2
  
  - `check_rhub`, Windows Server 2022, R-devel, 64 bit, Ubuntu Linux 20.04.1 LTS, R-release, Fedora Linux, R-devel
  
  - [win-builder](https://win-builder.r-project.org/), Windows Server 2008, (R-release and R-devel)

## R CMD check results

```
0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

Depending on checking settings, I can get 1 NOTE where three examples take longer than five seconds to run. All three examples have been wrapped in `donttest` so will not be run during routine testing. 

### An intermittent issue

On one `rhub` system, the note below was raised: 

```
Found the following (possibly) invalid URLs:
  URL: https://www.sciencedirect.com/science/article/pii/S004896971834244X
    From: inst/CITATION
    Status: 403
    Message: Forbidden
```

This URL has been checked and is not forbidden for non-automated browsers but seems to be forbidden with tools such as `wget`.

## Downstream dependencies

This package has has no downstream dependencies.
