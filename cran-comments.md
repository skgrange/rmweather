## New package version

This is a package update to fix a few minor issues and to move messaging and progress bars to the **cli** package. 

## Test environments

  - Local, Ubuntu 22.04 LTS, R 4.3.2
  
  - `check_rhub`, Windows Server 2022, R-devel, 64 bit, Ubuntu Linux 20.04.1 LTS, R-release, Fedora Linux, R-devel
  
  - [win-builder](https://win-builder.r-project.org/), Windows Server 2022, (R-release and R-devel)

## R CMD check results

```
0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

Depending on checking settings, I can get 1 NOTE where three examples take longer than five seconds to run. All three examples have been wrapped in `donttest` so will not be run during routine testing. 

### False positive results

#### Spell check

On some Windows systems, some false positive spelling mistakes are being detected, such as: 

```
Possibly misspelled words in DESCRIPTION:
  BAU (17:77)
```

or: 

```
Possibly misspelled words in DESCRIPTION:
  BAU (17:77)
  Counterfactual (3:58)
  counterfactual (11:38, 17:40)
```

These are not mistakes.

#### Other notes

Again, on a Windows system, this note can be raised: 

```
Found the following (possibly) invalid URLs:
  URL: https://www.sciencedirect.com/science/article/pii/S004896971834244X
    From: inst/CITATION
    Status: 403
    Message: Forbidden
```

This URL has been checked and is not forbidden for non-automated browsers but seems to be forbidden (at least at times) with tools such as `wget`.

Yet again, on a Windows system, these notes can be raised: 

```
* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

These are a specific issues related to the rhub service (see [here](https://github.com/r-hub/rhub/issues/503)) and are not related to the package itself and cannot be replicated elsewhere. 

## Downstream dependencies

This package has has no downstream dependencies.

