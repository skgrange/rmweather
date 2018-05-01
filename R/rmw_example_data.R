#' Function to load example data for the \strong{rmweather} package.
#' 
#' @details These example data are daily means of NO2 and NOx observations at 
#' London Marylebone Road. The accompanying surface meteorological data are from
#' London Heathrow, a major airport located 23 km west of Central London.
#' 
#' @author Stuart K. Grange
#' 
#' @return Data frame. 
#' 
#' @examples 
#' 
#' # Load rmweather's example data
#' data_london <- rmw_example_data()
#' 
#' 
#' @export
rmw_example_data <- function() {
  
  # Find file
  file_name <- file.path(
    system.file("extdata", package = "rmweather", mustWork = TRUE), 
    "london_marylebone_nox_data.rds"
  )
  
  # Load file
  df <- readRDS(file_name)
  
  return(df)
  
}
