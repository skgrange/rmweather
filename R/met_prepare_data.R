#' Function to prepare a data frame for modelling with \strong{metnormr}. 
#' 
#' \code{met_prepare_data} will check if a \code{date} variable is present and 
#' is of the correct data type, impute missing numeric and categorical values, 
#' randomly split the input into training and testing sets, and rename the 
#' dependant variable to \code{"value"}. 
#' 
#' @param df Input data frame. 
#' 
#' @param value Name of the dependent variable. Usually a pollutant, for example,
#' \code{"no2"} or \code{"pm10"}. 
#'
#' @return Data frame, the input data transformed to a data frame ready for 
#' modelling with \strong{metnormr}. 
#' 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{met_calculate_model}}
#' 
#' @examples 
#' \dontrun{
#'
#' # Prepare data for modelling 
#' data_for_modelling <- met_prepare_data(data_london, value = "no2")
#' 
#' }
#' 
#' @export
met_prepare_data <- function(df, value = "value") {
  
  df %>% 
    met_check_data(prepared = FALSE) %>% 
    add_date_variables() %>% 
    impute_values() %>% 
    split_into_sets() %>% 
    rename(value = !!value)
  
}


add_date_variables <- function(df) {
  
  # Check variables
  names <- names(df)
  
  # Add variables if they do not exist
  # Add date variables
  if (!any(grepl("date_unix", names))) 
    df[, "date_unix"] <- as.numeric(df[, "date"])
  
  if (!any(grepl("day_julian", names)))
    df[, "day_julian"] <- lubridate::yday(df[, "date"])
  
  if (!any(grepl("month", names)))
    df[, "month"] <- lubridate::month(df[, "date"])
  
  if (!any(grepl("week", names)))
    df[, "week"] <- lubridate::week(df[, "date"])
  
  if (!any(grepl("weekday", names)))
    df[, "weekday"] <- wday_monday(df[, "date"], as.factor = TRUE)
  
  if (!any(grepl("hour", names)))
    df[, "hour"] <- lubridate::hour(df[, "date"])

  return(df)
  
}


impute_values <- function(df) {
  
  # Numeric variables
  index_numeric <- sapply(df, function(x) is.numeric(x) | is.integer(x))
  
  df[index_numeric] <- lapply(df[index_numeric], function(x) 
    ifelse(is.na(x), median(x, na.rm = TRUE), x))
  
  # Character and categorical variables 
  index_categorical <- sapply(df, function(x) is.factor(x) | is.character(x))
  
  df[index_categorical] <- lapply(df[index_categorical], function(x) 
    ifelse(is.na(x), mode_average(x, na.rm = TRUE), x))
  
  return(df)
  
}


split_into_sets <- function(df, fraction = 0.8) {
  
  # Add row number
  df <- tibble::rowid_to_column(df) 
  
  # Sample to get training set
  df_training <- df %>% 
    sample_frac(fraction) %>% 
    mutate(set = "training")
  
  # Remove training set from input to get testing set
  df_testing <- df %>% 
    filter(!rowid %in% df_training$rowid) %>% 
    mutate(set = "testing")
  
  # Bind again
  df_split <- df_training %>% 
    bind_rows(df_testing) %>% 
    select(set,
           everything()) %>% 
    select(-rowid) %>% 
    arrange(date)
  
  return(df_split)
  
}


met_check_data <- function(df, prepared) {
  
  # Get data names
  names <- names(df)
  
  if (!any(grepl("date", names))) 
    stop("Input must contain a `date` variable...", call. = FALSE)
  
  if (!grepl("POSIXct", class(df$date)[1]))
    stop("`date` variable needs to be a parsed date (POSIXct)...", call. = FALSE)
  
  if (prepared) {
    
    if (!any(grepl("set", names))) 
      stop("Input must contain a `set` variable...", call. = FALSE)
    
    # unique(df$set) %in% c("training", "testing")
    
    if (!any(grepl("value", names))) 
      stop("Input must contain a `value` variable...", call. = FALSE)
    
  }

  return(df)
  
}
