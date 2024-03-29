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
#' @param replace When adding the date variables to the set, should they replace
#' the versions already contained in the data frame if they exist? 
#' 
#' @param fraction Fraction of the observations to make up the training set. 
#' Default is 0.8, 80 \%.
#'
#' @return Tibble, the input data transformed ready for modelling with 
#' \strong{rmweather}. 
#' 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{set.seed}}, \code{\link{rmw_train_model}}, 
#' \code{\link{rmw_normalise}}
#' 
#' @examples 
#' 
#' # Load package
#' library(dplyr)
#' 
#' # Keep things reproducible
#' set.seed(123)
#'
#' # Prepare example data for modelling, only use no2 data here
#' data_london_prepared <- data_london %>% 
#'   filter(variable == "no2") %>% 
#'   rmw_prepare_data()
#' 
#' @export
rmw_prepare_data <- function(df, value = "value", na.rm = FALSE, replace = FALSE,
                             fraction = 0.8) {
  
  # Check
  if (!value %in% names(df)) {
    cli::cli_abort("`value` is not within input data frame.")
  }
  
  df <- df %>% 
    rename(value = !!value) %>% 
    rmw_check_data(prepared = FALSE) %>% 
    impute_values(na.rm = na.rm) %>% 
    add_date_variables(replace = replace) %>% 
    split_into_sets(fraction = fraction) %>% 
    ungroup()
  
  return(df)
  
}


add_date_variables <- function(df, replace) {
  
  # Check variables
  names <- names(df)
  
  if (replace) {
    
    # Will replace if variables exist
    df$date_unix <- as.numeric(df$date)
    df$day_julian <- lubridate::yday(df$date)
    df$weekday <- wday_monday(df$date, as.factor = TRUE)
    df$hour <- lubridate::hour(df$date)
    
  } else {
    
    # Add variables if they do not exist
    # Add date variables
    if (!"date_unix" %in% names) df$date_unix <- as.numeric(df$date)
    if (!"day_julian" %in% names) df$day_julian <- lubridate::yday(df$date)
    # An internal package's function  
    if (!"weekday" %in% names) {
      df$weekday <- wday_monday(df$date, as.factor = TRUE)
    }
    if (!"hour" %in% names) df$hour <- lubridate::hour(df$date)
    
  }

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
    dplyr::slice_sample(prop = fraction) %>% 
    mutate(set = "training")
  
  # Remove training set from input to get testing set
  df_testing <- df %>% 
    filter(!rowid %in% df_training$rowid) %>% 
    mutate(set = "testing")
  
  # Bind again
  df_split <- df_training %>% 
    bind_rows(df_testing) %>% 
    relocate(set) %>% 
    select(-rowid) %>% 
    arrange(date)
  
  return(df_split)
  
}


rmw_check_data <- function(df, prepared) {
  
  # Get data names
  names <- names(df)
  
  if (!"date" %in% names) {
    cli::cli_abort("Input must contain a `date` variable.")
  }
  
  if (!"POSIXct" %in% class(df$date)[1]) {
    cli::cli_abort("`date` variable needs to be a parsed date (POSIXct).")
  }
  
  if (anyNA(df$date)) {
    cli::cli_abort("`date` must not contain missing (NA) values.")
  }
  
  # More checks for prepared data
  if (prepared) {
    
    if (!"set" %in% names) {
      cli::cli_abort("Input must contain a `set` variable.")
    }
    
    if (!all(unique(df$set) %in% c("training", "testing"))) {
      cli::cli_abort("`set` can only take the values `training` and `testing`.")
    }
    
    if (!"value" %in% names) {
      cli::cli_abort("Input must contain a `value` variable.")
    }
    
    if (!"date_unix" %in% names) {
      cli::cli_abort("Input must contain a `date_unix` variable.")
    }
    
  }

  return(df)
  
}
