#' Function to transform a parsed \code{date} variable into other date/time 
#' variables in preparation for modelling with the \strong{normalweatherr} 
#' package. 
#' 
#' \code{prepare_input_data} will check variable names, transform the parsed 
#' \code{date} variable into other variables, impute missing data, and make 
#' correct data types. 
#' 
#' @param df Data frame containing air quality data. 
#' 
#' @param impute Should missing values be imputed? Numeric variables will be 
#' imputed with their median while categorical variables the mode will be used.
#' 
#' @return Data frame. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples 
#' \dontrun{
#'
#' # 
#' 
#' 
#' }
#' 
#' @export
add_date_variables <- function(df) {
  
  # Check data frame input, df_tbl will not simplify when [, ] are used
  if (any(grepl("tbl", class(df)))) df <- data.frame(df)
  
  # Check variables
  names <- names(df)
  
  if (!any(grepl("date", names))) 
    stop("Data must contain a `date` variable.", call. = FALSE)
  
  if (!any(grepl("POSIXct", class(df$date))))
    stop("`date` variable needs to be a parsed date (POSIXct).", call. = FALSE)
  
  # if (impute) 
  
  # Add variables if they do not exist
  # Add date variables
  if (!any(grepl("date_unix", names))) 
    df[, "date_unix"] <- as.numeric(df[, "date"])
  
  if (!any(grepl("week", names)))
    df[, "week"] <- lubridate::week(df[, "date"])
  
  if (!any(grepl("weekday", names)))
    df[, "weekday"] <- wday_monday(df[, "date"], as.factor = TRUE)
  
  if (!any(grepl("hour", names)))
    df[, "hour"] <- lubridate::hour(df[, "date"])
  
  if (!any(grepl("month", names)))
    df[, "month"] <- lubridate::month(df[, "date"])
  
  if (!any(grepl("day_julian", names)))
    df[, "day_julian"] <- lubridate::yday(df[, "date"])
  
  return(df)
  
}


#' Function to
#' 
#' @author Stuart K. Grange
#' 
#' @return Data frame. 
#' 
#' @export
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


#' @export
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
