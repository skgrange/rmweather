#' Functions to use a model to predict the observations within a test set after
#' \code{met_calculate_model}. 
#' 
#' \code{met_predict_the_test_set} uses data withheld from the training of the 
#' model and therefore can be used for investigating overfitting. 
#' 
#' @param model A ranger model object from \code{met_calculate_model}. 
#' 
#' @param df Input data used to calculate \code{model}. 
#' 
#' @return Data frame. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples
#' 
#' \dontrun{
#'
#' # Use the test set for prediction
#' met_predict_the_test_set(model, data_for_modelling)
#' 
#' # Produce a hex plot of the predictions
#' met_predict_the_test_set(model, data_for_modelling) %>% 
#'   met_plot_test_prediction()
#'  
#' }
#' 
#' @export
met_predict_the_test_set <- function(model, df) {
  
  df %>% 
    filter(set == "testing") %>% 
    mutate(value_predict = met_predict(model, .)) 
  
}


#' @rdname met_predict_the_test_set
#' 
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
    ggplot2::xlim(min_values, max_values) +
    viridis::scale_fill_viridis(
      option = "inferno",
      begin = 0.3,
      end = 0.8
    )
  
}
