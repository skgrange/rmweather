#' @export
met_model_statistics <- function(model) {
  
  data.frame(
    mtry = model$mtry,
    min_node_size = model$min.node.size,
    importance_mode = model$importance.mode,
    count_independent_variables = model$num.independent.variables,
    count_samples = model$num.samples,
    prediction_error = model$prediction.error,
    r_squared = model$r.squared,
    stringsAsFactors = FALSE
  )
  
}


#' @export
met_model_importance <- function(model) {
  
  vector_importance <- ranger::importance(model)
  df <- data.frame(matrix(nrow = length(vector_importance), ncol = 2))
  df <- setNames(df, c("variable", "importance"))
  df[, 1] <- names(vector_importance)
  df[, 2] <- vector_importance
  df <- arrange(df, -importance)
  return(df)
  
}
