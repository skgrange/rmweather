#' Function to plot partial dependencies after calculation by 
#' \code{\link{rmw_partial_dependencies}}. 
#' 
#' @param df Tibble created by \code{\link{rmw_partial_dependencies}}. 
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


#' Function to plot random forest variable importances after training by 
#' \code{\link{rmw_train_model}}.
#' 
#' @param df Data frame created by \code{\link{rmw_model_importance}}. 
#' 
#' @param colour Colour of point and segment geometries.
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot with point and segment geometries.
#' 
#' @seealso \code{\link{rmw_train_model}}, \code{\link{rmw_model_importance}}
#' 
#' @export
rmw_plot_importance <- function(df, colour = "black") {
  
  # Check input
  if (!all(c("rank", "variable", "importance") %in% names(df))) {
    
    stop(
      "Data frame must contain `rank`, `variable`, and `importance` variables...", 
      call. = FALSE
    )
    
  }
  
  # Plot
  plot <- ggplot2::ggplot(
    df, 
    ggplot2::aes(importance, reorder(variable, importance))
  ) + 
    ggplot2::geom_point(size = 5, colour = colour) + 
    ggplot2::geom_segment(
      ggplot2::aes(
        x = 0, y = reorder(variable, importance), 
        xend = importance, 
        yend = reorder(variable, importance)
      ),
      colour = colour
    ) +
    ggplot2::theme_minimal() + 
    ggplot2::ylab("Variable") + 
    ggplot2::xlab("Variable importance (permutation difference)")
  
  return(plot)
  
}


#' Function to plot the test set and predicted set after
#' \code{\link{rmw_predict_the_test_set}}. 
#' 
#' @param df Tibble created by \code{\link{rmw_predict_the_test_set}}. 
#' 
#' @param bins Numeric vector giving number of bins in both vertical and 
#' horizontal directions. 
#' 
#' @param coord_equal Should axes be forced to be equal? 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot with a hex geometry.
#' 
#' @export
rmw_plot_test_prediction <- function(df, bins = 30, coord_equal = TRUE) {
  
  # Plot
  plot <- ggplot2::ggplot(df, ggplot2::aes(value, value_predict)) + 
    ggplot2::geom_hex(bins = bins) +
    ggplot2::geom_abline(slope = 1, intercept = 0) + 
    ggplot2::theme_minimal() +
    viridis::scale_fill_viridis(
      option = "inferno",
      begin = 0.3,
      end = 0.8
    ) + 
    ggplot2::xlab("Observed") + 
    ggplot2::ylab("Predicted")
  
  # Fix axes
  if (coord_equal) {
    
    # Get axes limits
    min_values <- min(c(df$value, df$value_predict), na.rm = TRUE)
    max_values <- max(c(df$value, df$value_predict), na.rm = TRUE)
    
    plot <- plot +
      ggplot2::ylim(min_values, max_values) + 
      ggplot2::xlim(min_values, max_values) +
      ggplot2::coord_equal()
    
  }
  
  return(plot)
  
}


#' Function to plot the meteorologically normalised time series after
#' \code{\link{rmw_normalise}}. 
#' 
#' If the input data contains a standard error variable named \code{"se"}, 
#' this will be plotted as a ribbon (+ and -) around the mean. 
#' 
#' @param df Tibble created by \code{\link{rmw_normalise}}. 
#' 
#' @param colour Colour for line geometry. 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot with a line and ribbon geometries. 
#' 
#' @examples 
#' 
#' # Plot normalised example data
#' rmw_plot_normalised(data_london_normalised)
#' 
#' @export
rmw_plot_normalised <- function(df, colour = "#6B186EFF") {
  
  # Create plot
  plot <- ggplot2::ggplot(data = df)
  
  # Add se if present in data frame too
  if ("se" %in% names(df)) {
    
    # Plot the ribbon geom first
    plot <- plot + 
      ggplot2::geom_ribbon(
        ggplot2::aes(x = date, ymin = value_predict - se, ymax = value_predict + se), 
        alpha = 0.3,
        fill = "grey"
      )
    
  }
  
  # Overlay line  
  plot <- plot + 
    ggplot2::geom_line(
      ggplot2::aes(date, value_predict), colour = colour
    ) + 
    ggplot2::theme_minimal() +
    ggplot2::ylab("Meteorologically normalised value") + 
    ggplot2::xlab("Date")
  
  return(plot)
  
}
