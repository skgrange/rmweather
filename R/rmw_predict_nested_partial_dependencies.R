#' Function to calculate partial dependencies from a random forest models using 
#' a nested tibble.
#' 
#' @param df_nest Nested tibble created by \code{\link{rmw_model_nested_sets}}.
#' 
#' @param variables Vector of variables to calculate partial dependencies for. 
#' 
#' @param n_cores Number of CPU cores to use for the model calculations. 
#' 
#' @param training_only Should only the training set be used for prediction?
#' 
#' @param rename Within the \code{partial_dependencies} nested tibble, should 
#' the generic \code{"variable"} name be renamed to \code{"variable_model"}. 
#' This is useful when \code{"variable"} has been used as a pollutant identifier.
#' 
#' @param verbose Should the function give messages? 
#' 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{rmw_nest_for_modelling}}, 
#' \code{\link{rmw_model_nested_sets}}, \code{\link{rmw_partial_dependencies}}
#' 
#' @return Nested tibble. 
#' 
#' @export
rmw_predict_nested_partial_dependencies <- function(df_nest, 
                                                    variables = NA, 
                                                    n_cores = NA,
                                                    training_only = TRUE,
                                                    rename = FALSE,
                                                    verbose = FALSE) {
  
  # Check input
  if (!all(c("observations", "model") %in% names(df_nest))) {
    stop("Input requires `observations` and `model` variables.", call. = FALSE)
  }
  
  # Predict the partial dependencies
  df_nest <- df_nest %>% 
    mutate(
      partial_dependencies = list(
        rmw_partial_dependencies(
          model, 
          observations, 
          variable = variables,
          training_only = training_only,
          n_cores = n_cores,
          verbose = verbose
        ) 
      )
    )
  
  # Rename the variable within partial dependencies unit
  if (rename) {
    df_nest <- df_nest %>% 
      mutate(
        partial_dependencies = list(
          rename(partial_dependencies, variable_model = variable)
        )
      )
  }
  
  return(df_nest)
  
}
