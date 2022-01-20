#' Function to get weekday number from a date where \code{1} is Monday and 
#' \code{7} is Sunday. 
#' 
#' @author Stuart K. Grange
#' 
#' @param x Date vector.
#' 
#' @param as.factor Should the return be a factor? 
#' 
#' @return Numeric vector.
#' 
wday_monday <- function(x, as.factor = FALSE) {
  
  x <- lubridate::wday(x)
  x <- x - 1
  x <- ifelse(x == 0, 7, x)
  if (as.factor) x <- factor(x, levels = 1:7, ordered = TRUE)
  return(x)
  
}


mode_average <- function(x, na.rm = FALSE) {
  if (na.rm) x <- na.omit(x)
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}


str_date_formatted <- function(date = NA, time_zone = TRUE, 
                               fractional_seconds = TRUE) {
  
  # Get date if not supplied
  if (is.na(date)[1]) date <- lubridate::now(tz = Sys.timezone())
  
  # Format string
  format_date <- ifelse(
    fractional_seconds, 
    "%Y-%m-%d %H:%M:%OS3", 
    "%Y-%m-%d %H:%M:%S"
  )
  
  # Format
  x <- format(date, format = format_date, usetz = time_zone)
  
  return(x)
  
}


#' Function to return the system's number of CPU cores. 
#' 
#' @author Stuart K. Grange
#' 
#' @param logical_cores Should logical cores be included in the core count? 
#' 
#' @param max_cores Should the return have a maximum value? This can be useful 
#' when there are very many cores and logic is being built. 
#' 
#' @export
system_cpu_core_count <- function(logical_cores = TRUE, max_cores = NA) {
  x <- as.integer(parallel::detectCores(logical = logical_cores))
  if (!is.na(max_cores)) {
    max_cores <- as.integer(max_cores)
    x <- if_else(x >= max_cores, max_cores, x) 
  }
  return(x)
}


n_cores_default <- function() {
  
  # Get core count
  x <- system_cpu_core_count()
  
  # Different logic for well resourced systems
  if (x < 16) {
    x <- x - 1L
  } else {
    x <- 16L
  }
  
  return(x)
  
}
