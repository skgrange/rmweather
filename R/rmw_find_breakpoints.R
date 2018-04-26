#' Function to detect breakpoints in a data frame using a linear regression 
#' based approach.
#' 
#' \code{rmw_find_breakpoints} will generally be applied to a data frame after
#' \code{\link{rmw_normalise}}. 
#' 
#' @author Stuart K. Grange
#' 
#' @param df Data frame from \code{\link{rmw_normalise}} to detect breakpoints 
#' in. 
#' 
#' @param h Minimal segment size either given as fraction relative to the sample 
#' size or as an integer giving the minimal number of observations in each 
#' segment.
#' 
#' @param n Number of breaks to detect. Default is maximum number allowed by
#' \code{h}. 
#' 
#' @return Data frame with a \code{date} variable indicating where the 
#' breakpoints are. 
#' 
#' @export
rmw_find_breakpoints <- function(df, h = 0.15, n = NULL) {
  
  # Check input
  df <- rmw_check_data(df, prepared = FALSE)
  
  # Switch to a common variable name
  names(df) <- ifelse(names(df) == "value_predict", "value", names(df))
  
  # Another check
  stopifnot("value" %in% names(df))
  
  # Do
  x <- strucchange::breakpoints(
    value ~ date, 
    data = df, 
    h = h, 
    breaks = n
  )
  
  # Get dates from index and make data frame
  df <- data.frame(date = df$date[x$breakpoints])
  
  return(df)
  
}
