#' Example meteorologically normalised data for the \strong{rmweather} package.
#' 
#' These example data are derived from the observational data included in 
#' \strong{rmweather} and represent meteorologically normalised NO2 
#' concentrations at London Marylebone Road, aggregated to monthly resolution. 
# 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{data_london}}
#' 
#' @format Tibble with 246 observations and 5 variables. The variables are:
#' \code{date}, \code{date_end}, \code{site}, \code{site_name}, and 
#' \code{value_predict}. The dates are in \code{POSIXct} format, the site 
#' variables are characters and \code{value_predict} is numeric. 
#' 
#' @examples 
#' 
#' # Load rmweather's meteorologically normalised example data and check
#' head(data_london_normalised)
#' 
"data_london_normalised"
