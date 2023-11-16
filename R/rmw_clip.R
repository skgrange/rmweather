#' Function to "clip" the edges of a normalised time series after being 
#' produced with \code{\link{rmw_normalise}}. 
#' 
#' \code{rmw_clip} helps if the random forest model behaves strangely at the 
#' beginning and end of the time series during prediction. 
#' 
#' @author Stuart K. Grange
#' 
#' @param df Data frame from \code{\link{rmw_normalise}}. 
#' 
#' @param seconds Number of seconds to clip from start and end of time-series. 
#' The default is half a year. 
#' 
#' @return Data frame. 
#' 
#' @seealso \code{\link{rmw_normalise}}, \code{\link{rmw_plot_normalised}}
#' 
#' @examples 
#' 
#' # Clip the edges of a normalised time series, default is half a year
#' data_normalised_clipped <- rmw_clip(data_london_normalised)
#'
#' @export
rmw_clip <- function(df, seconds = 31536000 / 2) {
  
  # A date check
  df <- rmw_check_data(df, prepared = FALSE)
  
  # Value check
  if (!"value_predict" %in% names(df)) {
    cli::cli_abort("`value_predict` is not present in input.")
  }
  
  # Get min and max
  date_start <- min(df$date)
  date_end <- max(df$date)
  
  # Push min and max
  date_start_plus <- date_start + seconds
  date_end_minus <- date_end - seconds
  
  # Invalidate value_predict
  df <- df %>% 
    mutate(
      value_predict = ifelse(
        date <= date_start_plus | date >= date_end_minus, NA, value_predict
      )
    )
  
  return(df)
  
}
