#' Function to make predictions from a random forest models using a nested 
#' tibble.
#' 
#' @param df_nest Nested tibble created by \code{\link{rmw_model_nested_sets}}.
#' 
#' @param se Should the standard error of the predictions be calculated? 
#' 
#' @param n_cores Number of CPU cores to use for the model calculations. 
#' 
#' @param keep_vectors Should the prediction vectors be kept in the return? This
#' is usually not needed because these vectors have been added to the 
#' \code{observations} variable.
#' 
#' @param verbose Should the function give messages? 
#' 
#' @seealso \code{\link{rmw_nest_for_modelling}}, 
#' \code{\link{rmw_model_nested_sets}}, \code{\link{rmw_predict}}
#' 
#' @author Stuart K. Grange
#' 
#' @return Nested tibble.
#' 
#' @export
rmw_predict_nested_sets <- function(df_nest, se = FALSE, n_cores = NULL, 
                                    keep_vectors = FALSE, verbose = FALSE) {
  
  # Check input
  if (!all(c("observations", "model") %in% names(df_nest))) {
    stop("Input requires `observations` and `model` variables.", call. = FALSE)
  }
  
  # Make the predictions, the return will be a vector
  df_nest <- df_nest %>% 
    mutate(
      predictions = list(
        rmw_predict(
          model, observations, se = se, n_cores = n_cores, verbose = verbose
        )
      )
    )
  
  # Add prediction vector(s) to observations
  if (!se) {
    
    # No standard error
    df_nest <- df_nest %>% 
      mutate(
        observations = list(
          mutate(
            observations, 
            value_predict = predictions,
            value_delta = value - value_predict
          )
        )
      )
    
  } else {
    
    # With standard error
    df_nest <- df_nest %>% 
      mutate(
        observations = list(
          mutate(
            observations, 
            value_predict = predictions$predictions,
            value_se = predictions$se,
            value_delta = value - value_predict
          )
        )
      )
    
  }
  
  # Drop prediction vectors, not usually needed after being put into observations
  if (!keep_vectors) {
    df_nest <- select(df_nest, -predictions)
  }
  
  return(df_nest)
  
}
