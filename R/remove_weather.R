#' @export
remove_weather <- function(model, df, n_samples = 300, replace = TRUE) {
  
  # Sample the time series
  df <- purrr::rerun(n_samples) %>% 
    purrr::map_dfr(~remove_weather_worker(
      model = model,
      df = df,
      replace = replace
    )
  )
  
  # Aggregate
  df <- df %>% 
    group_by(date) %>% 
    summarise(value_predict = mean(value_predict, na.rm = TRUE)) %>% 
    ungroup() %>% 
    mutate(n_samples = n_samples)
  
  return(df)
  
}


remove_weather_worker <- function(model, df, variables, replace) {
  
  # Randomly sample observations
  n_rows <- nrow(df)
  index_rows <- sample(1:n_rows, replace = replace)
  
  # Transform data frame to include sampled variables
  df[variables] <- lapply(df[variables], function(x) x[index_rows])
  
  # Use models to predict
  value_predict <- predict_with_random_forest(model, df)
  
  # Build data frame of predictions
  df <- data.frame(
    date = df$date,
    value_predict = value_predict
  )
  
  return(df)
  
}
