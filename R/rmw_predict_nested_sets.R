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
#' @param model_errors Should model error statistics between the observed and 
#' predicted values be calculated and returned? 
#' 
#' @param as_long For when \code{model_errors} is \code{TRUE}, should the model 
#' error unit be returned in "long format"? 
#' 
#' @param partial Should the model's partial dependencies also be calculated? 
#' This will increase the execution time of the function. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @seealso \code{\link{rmw_nest_for_modelling}}, 
#' \code{\link{rmw_model_nested_sets}}, \code{\link{rmw_predict}}, 
#' \code{\link{rmw_calculate_model_errors}}, \code{\link{rmw_partial_dependencies}}
#' 
#' @author Stuart K. Grange
#' 
#' @return Nested tibble.
#' 
#' @export
rmw_predict_nested_sets <- function(df_nest, se = FALSE, n_cores = NULL, 
                                    keep_vectors = FALSE, model_errors = FALSE, 
                                    as_long = TRUE, partial = FALSE, 
                                    verbose = FALSE) {
  
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
  
  # Calculate the errors between the observed and predicted values in the desired
  # format
  if (model_errors) {
    df_nest <- df_nest %>% 
      mutate(
        model_errors = list(
          rmw_calculate_model_errors(observations, as_long = as_long)
        )
      )
  }
  
  # Calculate partial dependencies if desired
  if (partial) {
    df_nest <- df_nest %>% 
      mutate(
        partial = list(
          rmw_partial_dependencies(
            model, 
            observations, 
            variable = NA,
            training_only = TRUE,
            n_cores = if_else(is.null(n_cores), NA, n_cores),
            verbose = verbose
          )
        )
      )
  }
  
  return(df_nest)
  
}
