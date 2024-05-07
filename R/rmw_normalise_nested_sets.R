#' Function to
#' 
#' @author Stuart K. Grange
#' 
#' 
#' @export
rmw_normalise_nested_sets <- function(df_nest, variables = NA, n_samples = 10,
                                      replace = TRUE, se = FALSE, 
                                      aggregate = TRUE, keep_samples = FALSE,
                                      n_cores = NA, verbose = FALSE, 
                                      progress = FALSE) {
  
  # Check input
  if (!all(c("observations", "model") %in% names(df_nest))) {
    cli::cli_abort("Input requires `observations` and `model` variables.")
  }
  
  # Make the predictions
  if (verbose) {
    cli::cli_alert_info(
      "{str_date_formatted()}: Normalising `{nrow(df_nest)}` time series..."
    )
  }
  
  # Use the vectors directly and put into a tibble
  df_normalised <- purrr::map2(
    df_nest$model,
    df_nest$observations,
    ~rmw_normalise(
      model = .x,
      df = .y,
      variables = variables,
      n_samples = n_samples,
      replace = replace,
      aggregate = aggregate,
      keep_samples = keep_samples,
      n_cores = n_cores,
      verbose = FALSE
    ),
    .progress = progress
  ) %>% 
    purrr::map(~rename(., value_normalised = value_predict)) %>%
    tibble(normalised = .)
  
  # Add normalised time series to nested tibble
  df_nest <- df_nest %>% 
    dplyr::bind_cols(df_normalised) %>% 
    mutate(
      observations = list(left_join(observations, normalised, by = join_by(date)))
    ) %>% 
    select(-normalised)
  
  return(df_nest)
  
}