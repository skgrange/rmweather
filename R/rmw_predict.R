#' Function to predict using a \strong{ranger} random forest.
#' 
#' @param model A \strong{ranger} model object from \code{rmw_train_model}. 
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
#' @examples 
#' \dontrun{
#' 
#' # Make a prediction with a ranger random forest model
#' vector_predict <- rmw_prefict(model, df = data_observations)
#' 
#' }
#' 
#' @export
rmw_predict <- function(model, df = NA, n_cores = NULL, 
                        verbose = FALSE) {
  
  if (class(df) != "data.frame" && is.na(df[1])) {
    
    x <- model$predictions
    
  } else {
    
    x <- predict(
      model, 
      df, 
      num.threads = n_cores, 
      seed = NULL,
      verbose = verbose
    )$predictions
    
  }
  
  return(x)
  
}
