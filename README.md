# **rmweather** <a href='https://github.com/skgrange/rmweather'><img src='man/figures/logo.png' align="right" height="131.5" /></a>

[![Build Status](https://travis-ci.org/skgrange/rmweather.svg?branch=master)](https://travis-ci.org/skgrange/rmweather)
[![CRAN status](https://www.r-pkg.org/badges/version/rmweather)](https://cran.r-project.org/package=rmweather)
[![CRAN log](https://cranlogs.r-pkg.org/badges/last-week/rmweather?color=brightgreen)](https://cran.r-project.org/package=rmweather)

## Introduction

**rmweather** is an R package to conduct meteorological/weather normalisation on air quality so trends and interventions can be investigated in a robust way. For those who are aware of my previous research, **rmweather** is the "Mk.II" package of [**normalweatherr**](https://github.com/skgrange/normalweatherr). **rmweather** does less than **normalweatherr**, but it is much faster and easier to use. 

## Installation

**rmweather** is aviable from CRAN and can be installed in the normal way: 

```
# Install rmweather from CRAN
install.packages("rmweather")
```

## Development version

To install the development version of **rmweather**, the [**devtools**](https://github.com/hadley/devtools) package will need to be installed first. Then:

```
# Load helper package
library(devtools)

# Install rmweather
install_github("skgrange/rmweather")
```

## Example usage

**rmweather** contains example data from London which can be used to show the meteorological normalisation procedure. The example data are daily means of NO<sub>2</sub> and NO<sub>x</sub> observations at London Marylebone Road. The accompanying surface meteorological data are from London Heathrow, a major airport located 23 km west of Central London. 

Most of **rmweather**'s functions begin with `rmw_` so are easy to track and find help for. In this example, we have used **dplyr** and the pipe (`%>%` and pronounced as "then") for clarity. The example takes about a couple of minutes on my (laptop) system and the model has an *R<sup>2</sup>* value of 77 %. 

```
# Load packages
library(dplyr)
library(rmweather)
library(ranger)

# Have a look at rmweather's example data, from london
head(data_london)

# Prepare data for modelling
# Only use data with valid wind speeds, no2 will become the dependent variable
data_london_prepared <- data_london %>% 
  filter(!is.na(ws)) %>% 
  rename(value = no2) %>% 
  rmw_prepare_data(na.rm = TRUE)

# Grow/train a random forest model and then create a meteorological normalised trend 
list_normalised <- rmw_do_all(
  data_london_prepared,
  variables = c(
    "date_unix", "day_julian", "weekday", "air_temp", "rh", "wd", "ws",
    "atmospheric_pressure"
  ),
  n_trees = 300,
  n_samples = 300,
  verbose = TRUE
)

# What units are in the list? 
names(list_normalised)

# Check model object's performance
rmw_model_statistics(list_normalised$model)

# Plot variable importances
list_normalised$model %>% 
  rmw_model_importance() %>% 
  rmw_plot_importance()

# Check if model has suffered from overfitting
rmw_predict_the_test_set(
  model = list_normalised$model,
  df = list_normalised$observations
) %>% 
  rmw_plot_test_prediction()

# How long did the process take? 
list_normalised$elapsed_times

# Plot normalised trend
rmw_plot_normalised(list_normalised$normalised)

# Investigate partial dependencies, if variable is NA, predict all
data_pd <- rmw_partial_dependencies(
  model = list_normalised$model, 
  df = list_normalised$observations,
  variable = NA
)

# Plot partial dependencies
data_pd %>% 
  filter(variable != "date_unix") %>% 
  rmw_plot_partial_dependencies()
```

The meteorologically normalised trend produced is below.

![](man/figures/normalised_no2_example.png)

## Examples and citations

For usage examples see: 

Grange, S. K., Carslaw, D. C., Lewis, A. C., Boleti, E., and Hueglin, C. (2018). [Random forest meteorological normalisation models for Swiss PM<sub>10</sub> trend analysis](https://www.atmos-chem-phys.net/18/6223/2018/). *Atmospheric Chemistry and Physics* 18.9, pp. 6223--6239.
  
Grange, S. K. and Carslaw, D. C. (2019). [Using meteorological normalisation to detect interventions in air quality time series](http://www.sciencedirect.com/science/article/pii/S004896971834244X). *Science of The Total Environment* 653, pp. 578--588.

## See also

  - [**ranger**](https://github.com/imbs-hl/ranger)
  
  - [**normalweatherr**](https://github.com/skgrange/normalweatherr)
  
  - [**deweather**](https://github.com/davidcarslaw/deweather)
