#' Functions to extract model statistics from a model calculated with
#' \code{met_calculate_model}. 
#' 
#' @param model A ranger model object from \code{met_calculate_model}. 
#' 
#' @return Data frame. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples
#' 
#' \dontrun{
#'
#' # Extract statistics from a model object
#' met_model_statistics(model)
#' 
#' # Extract importances from a model object
#' met_model_importance(model)
#'  
#' }
#' 
#' @export
met_model_statistics <- function(model) {
  
  stopifnot(class(model) == "ranger")
  
  data.frame(
    mtry = model$mtry,
    min_node_size = model$min.node.size,
    importance_mode = model$importance.mode,
    count_independent_variables = model$num.independent.variables,
    independent_variables = stringr::str_c(
      model$forest$independent.variable.names, 
      collapse = "; "
    ), 
    count_samples = model$num.samples,
    prediction_error = model$prediction.error,
    r_squared = model$r.squared,
    stringsAsFactors = FALSE
  )
  
}


#' @rdname met_model_statistics
#' 
#' @export
met_model_importance <- function(model) {
  
  stopifnot(class(model) == "ranger")
  
  vector_importance <- ranger::importance(model)
  df <- data.frame(matrix(nrow = length(vector_importance), ncol = 2))
  df <- setNames(df, c("variable", "importance"))
  df[, 1] <- names(vector_importance)
  df[, 2] <- vector_importance
  df <- arrange(df, -importance)
  
  # Add ranking
  df <- tibble::rowid_to_column(df, "rank")
  
  return(df)
  
}


#' @rdname met_model_statistics
#' 
#' @export
met_plot_importance <- function(model) {
  
  # Get importances
  df <- met_model_importance(model)
  
  # Plot
  ggplot2::ggplot(df, ggplot2::aes(importance, reorder(variable, importance))) + 
    ggplot2::geom_point(size = 5) + 
    ggplot2::geom_segment(
      ggplot2::aes(
        x = 0, y = reorder(variable, importance), 
        xend = importance, 
        yend = reorder(variable, importance))
    ) +
    ggplot2::theme_minimal() + 
    ggplot2::ylab("Variable") + 
    ggplot2::xlab("Variable importance (unit?)")
  
}
