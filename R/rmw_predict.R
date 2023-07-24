#' Function to predict using a \strong{ranger} random forest.
#' 
#' @param model A \strong{ranger} model object from \code{rmw_train_model}. 
#' 
#' @param df Input data to be used for predictions. 
#' 
#' @param se If \code{df} is supplied, should the standard error of the 
#' prediction be calculated too? The standard error method is the "infinitesimal
#' jackknife for bagging" and will slow down the predictions significantly. 
#' 
#' @param n_cores Number of CPU cores to use for the model predictions.
#' 
#' @param verbose Should the function give messages? 
#' 
#' @author Stuart K. Grange
#' 
#' @return Numeric vector or a named list containing two numeric vectors.
#' 
#' @examples 
#' 
#' # Load package
#' library(dplyr)
#' 
#' # Prepare example data
#' data_london_prepared <- data_london %>% 
#'   filter(variable == "no2") %>% 
#'   rmw_prepare_data()
#' 
#' # Make a prediction with the examples
#' vector_prediction <- rmw_predict(
#'   model_london, 
#'   df = data_london_prepared
#' )
#' 
#' 
#' # Make a prediction with standard errors too
#' list_prediction <- rmw_predict(
#'   model_london, 
#'   df = data_london_prepared,
#'   se = TRUE
#' )
#'  
#' @export
rmw_predict <- function(model, df = NA, se = FALSE, n_cores = NULL, 
                        verbose = FALSE) {
  
  # Message to user
  if (verbose) {
    cli::cli_alert_info(
      "{str_date_formatted()}: Predicting using `{model$num.independent.variables}` variables..."
    )
  }
  
  if ("data.frame" %in% class(df) && identical(df[1], NA)) {
    x <- model$predictions
  } else {
    
    if (se) {
      
      x <- predict(
        model, 
        df,
        type = "se", 
        se.method = "infjack",
        num.threads = n_cores, 
        seed = NULL,
        verbose = verbose
      )
      
      # Extract the two vectors
      x <- x[c("predictions", "se")]
      
    } else {
      
      # Use generic, no se which is much quicker
      x <- predict(
        model, 
        df, 
        num.threads = n_cores, 
        seed = NULL,
        verbose = verbose
      )$predictions
      
    }
    
  }
  
  return(x)
  
}
