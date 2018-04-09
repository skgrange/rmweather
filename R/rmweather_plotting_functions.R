#' Function to plot partial dependencies after calculation by 
#' \code{\link{rmw_partial_dependencies}}. 
#' 
#' @param df Data frame created by \code{\link{rmw_partial_dependencies}}. 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot with a point geometry. 
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
#' @return ggplot2 plot with point and segment geometries.
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
#' @param bins Numeric vector giving number of bins in both vertical and 
#' horizontal directions. 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot with a hex geometry.
#' 
#' @export
rmw_plot_test_prediction <- function(df, bins = 30) {
  
  min_values <- min(c(df$value, df$value_predict), na.rm = TRUE)
  max_values <- max(c(df$value, df$value_predict), na.rm = TRUE)
  
  plot <- ggplot2::ggplot(df, ggplot2::aes(value, value_predict)) + 
    ggplot2::geom_hex(bins = bins) +
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


#' Function to plot the meteorologically normalised time series after
#' \code{\link{rmw_normalise}}. 
#' 
#' @param df Data frame created by \code{\link{rmw_normalise}}. 
#' 
#' @param colour Colour for line geometry. 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot with a line geometry. 
#' 
#' @export
rmw_plot_normalised <- function(df, colour = "#6B186EFF") {
  
  plot <- ggplot2::ggplot() + 
    ggplot2::geom_line(data = df, ggplot2::aes(date, value_predict), colour = colour) + 
    ggplot2::theme_minimal() +
    ggplot2::ylab("Meteorologically normalised value") + 
    ggplot2::xlab("Date")
  
  return(plot)
  
}
