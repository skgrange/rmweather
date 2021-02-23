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
#' @param n_cores Number of CPU cores to use for the model calculation. Default 
#' is system's total minus one.
#' 
#' @param verbose Should the function give messages?
#' 
#' @seealso \code{\link{rmw_nest_for_modelling}}, \code{\link{rmw_train_model}}
#' 
#' @return Nested tibble. 
#' 
#' @author Stuart K. Grange
#' 
#' @export
rmw_model_nested_sets <- function(df_nest, variables, n_trees = 10, mtry = NULL, 
                                  min_node_size = 5, n_cores = NA, verbose = FALSE) {
  
  # Check input
  if (!"observations" %in% names(df_nest)) {
    stop("Nested input must contain an `observations` variable.", call. = FALSE)
  }
  
  # Do
  df_nest %>% 
    mutate(
      model = list(
        rmw_train_model(
          observations,
          variables = variables,
          n_trees = n_trees,
          mtry = mtry,
          min_node_size = min_node_size,
          n_cores = n_cores,
          verbose = verbose
        )
      ),
      model_statistics = list(rmw_model_statistics(model)),
      model_importances = list(rmw_model_importance(model))
    )
  
}
