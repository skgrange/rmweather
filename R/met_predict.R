#' Function to predict. 
#' 
#' @param model A ranger model object from \code{met_train_model}. 
#' 
#' @param df Input data to be used for predictions. 
#' 
#' @param n_cores Number of CPU cores to use for the model predictions.
#' 
#' @param verbose Should the function give messages? 
#' 
#' @author Stuart K. Grange
#' 
#' @return Numeric vector. 
#' 
#' @export
met_predict <- function(model, df = NA, n_cores = NULL, 
                        verbose = FALSE) {
  
  if (class(df) != "data.frame" && is.na(df[1])) {
    
    x <- model$predictions
    
  } else {
    
    x <- predict(
      model, 
      df, 
      num.threads = n_cores, 
      verbose = verbose
    )$predictions
    
  }
  
  return(x)
  
}
