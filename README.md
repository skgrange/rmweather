# **rmweather** <a href='https://github.com/skgrange/rmweather'><img src='man/figures/logo.png' align="right" height="131.5" /></a>

[![Build Status](https://travis-ci.org/skgrange/rmweather.svg?branch=master)](https://travis-ci.org/skgrange/rmweather)
[![Lifecycle Status](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/)
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

To install the development version of **rmweather**, the [**remotes**](https://github.com/hadley/remotes) package will need to be installed first. Then:

```
# Load helper package
library(remotes)

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
  filter(variable == "no2",
         !is.na(ws)) %>% 
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

## The use of **rmweather** for prediction or counterfactual/business as usual scenarios

A second usage of **rmweather** became established in 2020 to help researchers quantify the effects of the COVID-19 related restrictions on air quality. Briefly, the approach involves the training of random forest models to explain pollutant concentrations based on meteorological and time variables for a training period, say, between 2018 and 2019. After the training period, the model is used in predictive-mode using the experienced meteorological conditions. The predicted time series can be thought of as a counterfactual or business-as-usual (BAU) scenario which the observed time series can be compared with. Critically, an approach like this accounts for the meteorological conditions observed in 2020, which in many locations was unusual and complicates simple analyses. The meteorological sampling and normalisation step is not required for this analysis, but this has been confused in the literature. 

### Examples of counterfactural modelling

Grange, S. K., Lee, J. D., Drysdale, W. S., Lewis, A. C., Hueglin, C., Emmenegger, L., and Carslaw, D. C. (2021). [COVID-19 lockdowns highlight a risk of increasing ozone pollution in European urban areas](https://acp.copernicus.org/articles/21/4169/2021/). *Atmospheric Chemistry and Physics* 21.5, pp. 4169--4185.

Wang, Y., Wen, Y., Wang, Y., Zhang, S., Zhang, K. M., Zheng, H., Xing, J., Wu, Y., and Hao, J. (2020). [Four-Month Changes in Air Quality during and after the COVID-19 Lockdown in Six Megacities in China](https://doi.org/10.1021/acs.estlett.0c00605). *Environmental Science and Technology Letters* 7.11, pp. 802--808.

Fenech, S., Aquilina, N. J., Ryan, V. (2021) [COVID-19-Related Changes in NO<sub>2</sub> and O<sub>3</sub> Concentrations and Associated Health Effects in Malta](https://www.frontiersin.org/articles/10.3389/frsc.2021.631280/full). *Frontiers in Sustainable Cities* 3.631280, pp. 1--12. 

Shi, Z., Song, C., Liu, B., Lu, G., Xu, J., Van Vu, T., Elliott, R. J. R., Li, W., Bloss, W. J., and Harrison, R. M. (2021).
[Abrupt but smaller than expected changes in surface air quality attributable to COVID-19 lockdowns](http://advances.sciencemag.org/content/7/3/eabd6696.abstract). *Science Advances* 7.3, eabd6696.

## See also

  - [**ranger**](https://github.com/imbs-hl/ranger)
  
  - [**normalweatherr**](https://github.com/skgrange/normalweatherr)
  
  - [**deweather**](https://github.com/davidcarslaw/deweather)
