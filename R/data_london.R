#' Example observational data for the \strong{rmweather} package.
#' 
#' These example data are daily means of NO2 and NOx observations at London 
#' Marylebone Road. The accompanying surface meteorological data are from
#' London Heathrow, a major airport located 23 km west of Central London.
#' 
#' The NO2 and NOx observations are sourced from the European Commission Air 
#' Quality e-Reporting \href{http://cdr.eionet.europa.eu/gb/eu/aqd/e1a/}{repository}
#' which can be freely shared with acknowledgement of the source. The 
#' meteorological data are sourced from the Integrated Surface Data (ISD) 
#' database which cannot be redistributed for commercial purposes and are bound 
#' to the \href{http://www.wmo.int/pages/prog/hwrp/documents/wmo_827_enCG-XII-Res40.pdf}{WMO Resolution 40 Policy}. 
# 
#' @author Stuart K. Grange
#' 
#' @format Tibble with 15676 observations and 11 variables. The variables are:
#' \code{date}, \code{date_end}, \code{site}, \code{site_name}, \code{value}, 
#' \code{air_temp}, \code{atmospheric_pressure}, \code{rh}, \code{wd}, and 
#' \code{ws}. The dates are in \code{POSIXct} format, the site variables are 
#' characters and all other variables are numeric. 
#' 
#' @examples 
#' 
#' # Load rmweather's example data and check
#' head(data_london)
#' 
"data_london"
