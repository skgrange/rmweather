#' Function to load example data for the \strong{rmweather} package.
#' 
#' @author Stuart K. Grange
#' 
#' @return Data frame. 
#' 
#' @export
rmw_example_data <- function() {
  
  # Find file
  file_name <- file.path(
    system.file("extdata", package = "rmweather"), "london_marylebone_nox_data.rds"
  )
  
  # Load file
  df <- readRDS(file_name)
  
  return(df)
  
}
