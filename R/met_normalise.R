#' @export
met_normalise <- function(model, df, n_samples = 300, replace = TRUE, 
                          verbose = FALSE) {
  
  # Sample the time series
  if (verbose) message(str_date_formatted(), ": Sampling and predicting...")
  
  df <- purrr::rerun(n_samples) %>% 
    purrr::map_dfr(~met_normalise_worker(
      model = model,
      df = df,
      replace = replace
    )
  )
  
  # Aggregate predictions
  if (verbose) message(str_date_formatted(), ": Aggregating predictions...")
  
  df <- df %>% 
    group_by(date) %>% 
    summarise(value_predict = mean(value_predict, na.rm = TRUE)) %>% 
    ungroup() %>% 
    mutate(n_samples = n_samples)
  
  return(df)
  
}


met_normalise_worker <- function(model, df, variables, replace) {
  
  message(str_date_formatted(), ": Sampling...")
  
  # Randomly sample observations
  n_rows <- nrow(df)
  index_rows <- sample(1:n_rows, replace = replace)
  
  # Transform data frame to include sampled variables
  df[variables] <- lapply(df[variables], function(x) x[index_rows])
  
  # Use model to predict
  message(str_date_formatted(), ": Predicting...")
  value_predict <- met_predict(model, df)
  
  # Build data frame of predictions
  df <- data.frame(
    date = df$date,
    value_predict = value_predict
  )
  
  return(df)
  
}
