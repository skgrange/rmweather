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
#' @param progress Should a progress bar be displayed?
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
                                                    verbose = FALSE,
                                                    progress = FALSE) {
  
  # Check input
  if (!all(c("observations", "model") %in% names(df_nest))) {
    cli::cli_abort("Input requires `observations` and `model` variables.")
  }
  
  # Calculate the partial dependencies
  if (verbose) {
    cli::cli_alert_info(
      "{str_date_formatted()}: Calculating partial dependencies for `{nrow(df_nest)}` model{?s}..."
    )
  }
  
  # Use the vectors directly and put into a tibble
  df_partial_dependencies <- purrr::map2(
    df_nest$model,
    df_nest$observations,
    ~rmw_partial_dependencies(
      model = .x,
      df = .y,
      variable = variables,
      training_only = training_only,
      n_cores = n_cores,
      verbose = FALSE
    ),
    .progress = progress
  ) %>% 
    tibble(partial_dependencies = .)
  
  # Bind the partial dependencies to the nested tibble
  df_nest <- dplyr::bind_cols(df_nest, df_partial_dependencies)
  
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
