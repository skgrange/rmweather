#' Functions to use a model to predict the observations within a test set after
#' \code{rmw_calculate_model}. 
#' 
#' \code{rmw_predict_the_test_set} uses data withheld from the training of the 
#' model and therefore can be used for investigating overfitting. 
#' 
#' @param model A ranger model object from \code{rmw_calculate_model}. 
#' 
#' @param df Input data used to calculate \code{model}. 
#' 
#' @return Tibble. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples
#' 
#' # Use the test set for prediction
#' rmw_predict_the_test_set(
#'   model_london, 
#'   df = rmw_prepare_data(data_london, value = "no2")
#' )
#' 
#' # Predict, then produce a hex plot of the predictions
#' rmw_predict_the_test_set(
#'   model_london, 
#'   df = rmw_prepare_data(data_london, value = "no2")
#' ) %>% 
#'   rmw_plot_test_prediction()
#' 
#' @export
rmw_predict_the_test_set <- function(model, df) {
  
  df %>% 
    filter(set == "testing") %>% 
    mutate(value_predict = rmw_predict(model, .)) 
  
}
