# rmweather 0.2.4

  - Make `rmw_calculate_model_errors` calculate `n` and `n_all`

  - Add name tags to the `NULL` functions

  - Add nested tibble functions to help with running multiple models
  
  - Allow the use of 0 samples in `rmw_do_all`
  
  - Enhance `rmw_calculate_model_errors` to return further error statistics
  
  - Add `max_cores` argument to `system_cpu_core_count`
  
  - Add `rmw_predict_nested_sets_by_year`
  
  - Add `as_long` argument to `rmw_calculate_model_errors`
  
    - **tidyr** has been added as an import for this functionality

# rmweather 0.1.51

  - Correct a failing unit test for some Linux distributions. 

# rmweather 0.1.5

  - Minor changes to improve compatibility with dplyr 1.0.0.
  
  - Update package's data and alter format where pollutants are in a "long" format.

# rmweather 0.1.4

  - Replace deprecated `data_frame` with `tibble`
  
  - Replace deprecated `funs` with `~`
  
  - Allow `rmw_plot_test_prediction` to not fix axes, useful for facetting after the plot has been generated
  
  - Minor logic change to `rmw_predict` to handle tibble's non-dropping behaviour

# rmweather 0.1.3

  - Example data are now tibbles, not data frames

  - Add citation file with two publications
  
  - Enhance description file to contain new publication

# rmweather 0.1.2

  - Add tolerance to an R^2 unit test for some flavours of Linux used on the CRAN networks

  - The enhancement of a number of functions to allow for the estimation of uncertainty/errors of predictions
  
  - Convenient plotting functions now have colour arguments
  
  - Normalised predictions can now be returned without being aggregated
  
  - Add `na.rm` argument to data preparing function to avoid imputing of the dependent variable
  
  - Add `replace` argument to data preparing function so generated variables replace existing variables of the same name if they exist
  
  - Add `variables_sample` argument to `rmw_do_all` to allow for a user to choose which variables to be sampled for the normalisation step

# rmweather 0.1.1

  - Resubmission after failure to pass CRAN's manual checks 
  
    - Expanded the package's description and added a reference which uses the method to conduct an example analysis (https://doi.org/10.5194/acp-18-6223-2018)
    
    - Added two new data objects
  
    - Replaced \dontrun{} with \donttest{} for examples 

# rmweather 0.1.0

  - First CRAN submission
