#' Functions to extract model statistics from a model calculated with
#' \code{rmw_calculate_model}. 
#' 
#' @param model A ranger model object from \code{rmw_calculate_model}. 
#' 
#' @param date_unix Should the \code{date_unix} variable be included in the 
#' return? 
#' 
#' @return Tibble. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples
#'
#' # Extract statistics from the example random forest model
#' rmw_model_statistics(model_london)
#' 
#' # Extract importances from a model object
#' rmw_model_importance(model_london)
#' 
#' @export
rmw_model_statistics <- function(model) {
  
  # Check class of object
  stopifnot(inherits(model, "ranger"))
  
  # Build tibble form some things in the model
  tibble(
    n_trees = model$num.trees,
    mtry = model$mtry,
    min_node_size = model$min.node.size,
    importance_mode = model$importance.mode,
    count_independent_variables = model$num.independent.variables,
    independent_variables = stringr::str_c(
      model$forest$independent.variable.names, 
      collapse = "; "
    ), 
    count_samples = model$num.samples,
    prediction_error_mse = model$prediction.error,
    r_squared = model$r.squared
  )
  
}


#' @rdname rmw_model_statistics
#' 
#' @details The variable importances are defined as "the permutation importance 
#' differences of predictions errors". This measure is unit-less and the values 
#' are not useful when comparing among data sets.
#' 
#' @export
rmw_model_importance <- function(model, date_unix = TRUE) {
  
  # Check class of object
  stopifnot(inherits(model, "ranger"))
  
  # Get vector and clean
  vector_importance <- ranger::importance(model)
  df <- data.frame(matrix(nrow = length(vector_importance), ncol = 2))
  df <- setNames(df, c("variable", "importance"))
  df[, 1] <- names(vector_importance)
  df[, 2] <- vector_importance
  df <- arrange(df, -importance)
  
  # Drop date_unix before ranking
  if (!date_unix) {
    df <- filter(df, variable != "date_unix")
  }
  
  # Add ranking
  df <- tibble::rowid_to_column(df, "rank")
  
  # To tibble
  df <- as_tibble(df)
  
  return(df)
  
}
