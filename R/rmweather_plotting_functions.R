#' Function to plot partial dependencies after calculation by 
#' \code{\link{rmw_partial_dependencies}}. 
#' 
#' @param df Data frame created by \code{\link{rmw_partial_dependencies}}. 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot. 
#' 
#' @export
rmw_plot_partial_dependencies <- function(df) {
  
  # Check for variable names
  if (!all(c("variable", "value", "partial_dependency") %in% names(df)))
    stop("Input must have 'variable', 'value', and 'partial_dependency' variables...")
  
  plot <- df %>% 
    ggplot2::ggplot(ggplot2::aes(value, partial_dependency)) + 
    ggplot2::geom_point() +
    ggplot2::facet_wrap("variable", scales = "free") +
    ggplot2::theme_minimal()
  
  return(plot)
  
}


#' Function to plot random forest imporantances after training by 
#' \code{\link{rmw_train_model}}.
#' 
#' @param df Data frame created by \code{\link{rmw_model_importance}}. 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot. 
#' 
#' @export
rmw_plot_importance <- function(df) {
  
  # To-do: check variable names
  
  # Plot
  plot <- ggplot2::ggplot(
    df, 
    ggplot2::aes(importance, reorder(variable, importance))
  ) + 
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
  
  return(plot)
  
}


#' Function to plot the test set and predicted set after
#' \code{\link{rmw_predict_the_test_set}}. 
#' 
#' @param df Data frame created by \code{\link{rmw_predict_the_test_set}}. 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot. 
#' 
#' @export
rmw_plot_test_prediction <- function(df) {
  
  min_values <- min(c(df$value, df$value_predict), na.rm = TRUE)
  max_values <- max(c(df$value, df$value_predict), na.rm = TRUE)
  
  plot <- ggplot2::ggplot(df, ggplot2::aes(value, value_predict)) + 
    ggplot2::geom_hex() +
    ggplot2::geom_abline(slope = 1, intercept = 0) + 
    ggplot2::coord_equal() + 
    ggplot2::theme_minimal() +
    ggplot2::ylim(min_values, max_values) + 
    ggplot2::xlim(min_values, max_values) +
    viridis::scale_fill_viridis(
      option = "inferno",
      begin = 0.3,
      end = 0.8
    )
  
  return(plot)
  
}
