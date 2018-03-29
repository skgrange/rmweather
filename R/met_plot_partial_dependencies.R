#' Function to plot partial dependencies after calculation by 
#' \code{\link{met_partial_dependencies}}. 
#' 
#' @param df Data frame created by \code{\link{met_partial_dependencies}}. 
#' 
#' @author Stuart K. Grange
#' 
#' @return ggplot2 plot. 
#' 
#' @export
met_plot_partial_dependencies <- function(df) {
  
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
