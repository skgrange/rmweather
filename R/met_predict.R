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
