#' Function to train random forest models using a nested tibble. 
#' 
#' @param df_nest Nested tibble created by \code{\link{rmw_nest_for_modelling}}. 
#' 
#' @param variables Independent/explanatory variables used to predict \code{"value"}.
#' 
#' @param n_trees Number of trees to grow to make up the forest.
#' 
#' @param mtry Number of variables to possibly split at in each node. Default is
#' the (rounded down) square root of the number variables.
#' 
#' @param min_node_size Minimal node size.
#' 
#' @param n_cores Number of CPU cores to use for the model calculations.
#' 
#' @param verbose Should the function give messages?
#' 
#' @param progress Should a progress bar be displayed?
#' 
#' @seealso \code{\link{rmw_nest_for_modelling}}, 
#' \code{\link{rmw_predict_nested_sets}}, \code{\link{rmw_train_model}}
#' 
#' @return Nested tibble. 
#' 
#' @author Stuart K. Grange
#' 
#' @export
rmw_model_nested_sets <- function(df_nest, variables, n_trees = 10, mtry = NULL, 
                                  min_node_size = 5, n_cores = NA,
                                  verbose = FALSE, progress = FALSE) {
  
  # Check input
  if (!"observations" %in% names(df_nest)) {
    cli::cli_abort("Nested input must contain an `observations` variable.")
  }
  
  # Pull out observations and train each model and put the results in a tibble
  # for easy later binding
  if (verbose) {
    cli::cli_alert_info(
      "{str_date_formatted()}: Growing `{nrow(df_nest)}` forest{?s}..."
    )
  }
  
  df_models <- df_nest %>% 
    pull(observations) %>% 
    purrr::map(
      ~rmw_train_model(
        df = .,
        variables = variables,
        n_trees = n_trees,
        mtry = mtry,
        min_node_size = min_node_size,
        n_cores = n_cores,
        verbose = FALSE
      ),
      .progress = progress
    ) %>% 
    tibble(model = .)
  
  # Bind the models with the observations and extract a few things from the model
  # objects
  if (verbose) {
    cli::cli_alert_info("{str_date_formatted()}: Extracting model statistics...")
  }
  
  df_nest <- df_nest %>% 
    dplyr::bind_cols(df_models) %>% 
    mutate(model_statistics = list(rmw_model_statistics(model)),
           model_importances = list(rmw_model_importance(model)))
  
  return(df_nest)
  
}
