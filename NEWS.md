# rmweather 0.1.x

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

  - Resubmisison after failure to pass CRAN's manual checks 
  
    - Expanded the package's description and added a reference which uses the method to conduct an example analysis (https://doi.org/10.5194/acp-18-6223-2018)
    
    - Added two new data objects
  
    - Replaced \dontrun{} with \donttest{} for examples 

# rmweather 0.1.0

  - First CRAN submission
