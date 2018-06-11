#' Function to prepare a data frame for modelling with \strong{rmweather}. 
#' 
#' \code{rmw_prepare_data} will test and prepare a data frame for further use 
#' with \strong{rmweather}.
#' 
#' \code{rmw_prepare_data} will check if a \code{date} variable is present and 
#' is of the correct data type, impute missing numeric and categorical values, 
#' randomly split the input into training and testing sets, and rename the 
#' dependent variable to \code{"value"}. The \code{date} variable will also be 
#' used to calculate new variables such as \code{date_unix}, \code{day_julian}, 
#' \code{weekday}, and \code{hour} which can be used as independent variables. 
#' These attributes are needed for other \strong{rmweather} functions to operate. 
#' 
#' Use \code{set.seed} in an R session to keep results reproducible.  
#' 
#' @param df Input data frame. Generally a time series of air quality data with
#' pollutant concentrations and meteorological variables. 
#' 
#' @param value Name of the dependent variable. Usually a pollutant, for example,
#' \code{"no2"} or \code{"pm10"}. 
#' 
#' @param na.rm Should missing values (\code{NA}) be removed from \code{value}? 
#' 
#' @param fraction Fraction of the observations to make up the training set. 
#' Default is 0.8, 80 \%.
#'
#' @return Data frame, the input data transformed ready for modelling with 
#' \strong{rmweather}. 
#' 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{set.seed}}, \code{\link{rmw_train_model}}, 
#' \code{\link{rmw_normalise}}
#' 
#' @examples 
#' 
#' # Keep things reproducible
#' set.seed(123)
#'
#' # Prepare example data for modelling 
#' data_london_prepared <- rmw_prepare_data(data_london, value = "no2")
#' 
#' @export
rmw_prepare_data <- function(df, value = "value", na.rm = FALSE, fraction = 0.8) {
  
  # Check
  if (!value %in% names(df))
    stop("`value` is not within input data frame...", call. = FALSE)
  
  df <- df %>% 
    rmw_check_data(prepared = FALSE) %>% 
    impute_values(na.rm = na.rm) %>% 
    add_date_variables() %>% 
    split_into_sets(fraction = fraction) %>% 
    rename(value = !!value)
  
  # Drop the tibble formatting, useful when groups are left over
  if ("tbl" %in% class(df)) class(df) <- "data.frame"
  
  return(df)
  
}


add_date_variables <- function(df) {
  
  # Check variables
  names <- names(df)
  
  # Add variables if they do not exist
  # Add date variables
  if (!"date_unix" %in% names) df$date_unix <- as.numeric(df$date)
  
  if (!"day_julian" %in% names) df$day_julian <- lubridate::yday(df$date)
  
  # if (!"month" %in% names) df$month <- lubridate::month(df$date)
  # if (!"week" %in% names) df$week <- lubridate::week(df$date)

  # Own function  
  if (!"weekday" %in% names) df$weekday <- wday_monday(df$date, as.factor = TRUE)

  if (!"hour" %in% names) df$hour <- lubridate::hour(df$date)

  return(df)
  
}


impute_values <- function(df, na.rm) {
  
  # Remove missing values
  if (na.rm) df <- filter(df, !is.na(value))
  
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


split_into_sets <- function(df, fraction) {
  
  # Add row number
  df <- tibble::rowid_to_column(df) 
  
  # Sample to get training set
  df_training <- df %>% 
    dplyr::sample_frac(fraction) %>% 
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


rmw_check_data <- function(df, prepared) {
  
  # Get data names
  names <- names(df)
  
  if (!"date" %in% names) 
    stop("Input must contain a `date` variable...", call. = FALSE)
  
  if (!"POSIXct" %in% class(df$date)[1]) 
    stop("`date` variable needs to be a parsed date (POSIXct)...", call. = FALSE)
  
  if (anyNA(df$date)) stop("`date` must not contain missing (NA) values...", call. = FALSE)
  
  # More checks for prepared data
  if (prepared) {
    
    if (!"set" %in% names) 
      stop("Input must contain a `set` variable...", call. = FALSE)
    
    if (!all(unique(df$set) %in% c("training", "testing")))
      stop("`set` can only take the values `training` and `testing`...", call. = FALSE)
    
    if (!"value" %in% names) 
      stop("Input must contain a `value` variable...", call. = FALSE)
    
    if (!"date_unix" %in% names) 
      stop("Input must contain a `date_unix` variable...", call. = FALSE)
    
  }

  return(df)
  
}
