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


#' @export
met_predict_the_test_set <- function(model, df) {
  
  df %>% 
    filter(set == "testing") %>% 
    mutate(value_predict = met_predict(model, .)) 
  
}


#' @export
met_plot_test_prediction <- function(df) {
  
  min_values <- min(c(df$value, df$value_predict), na.rm = TRUE)
  max_values <- max(c(df$value, df$value_predict), na.rm = TRUE)
  
  ggplot2::ggplot(df, ggplot2::aes(value, value_predict)) + 
    ggplot2::geom_hex() +
    ggplot2::geom_abline(slope = 1, intercept = 0) + 
    ggplot2::coord_equal() + 
    ggplot2::theme_minimal() +
    ggplot2::ylim(min_values, max_values) + 
    ggplot2::xlim(min_values, max_values) 
  
}
