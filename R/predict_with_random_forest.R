#' @export
predict_with_random_forest <- function(model, df = NA) {
  
  if (class(df) != "data.frame" && is.na(df[1])) {
    
    x <- model$predictions
    
  } else {
    
    x <- predict(model, df)$predictions
    
  }
  
  return(x)
  
}


#' @export
predict_the_test_set <- function(model, df) {
  
  df %>% 
    filter(set == "testing") %>% 
    mutate(value_predict = predict_with_random_forest(model, .)) 
  
}
