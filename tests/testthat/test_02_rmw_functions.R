context("`rmw_*` functions")

test_that("Test data preparation function", {
  
  # Load example data
  df <- data_london
  
  # Change name
  df <- rmw_prepare_data(filter(df, variable == "no2"))
  
  # Test data frame
  expect_identical(class(df), c("tbl_df", "tbl", "data.frame"))
  expect_identical(ncol(df), 16L)
  expect_identical(class(df$date)[1], "POSIXct")
  
  # Check set variable
  expect_identical(names(df)[1], "set")
  expect_equal(sort(unique(df$set)), c("testing", "training"))
  
  # Date variables
  expect_true(all(c("date_unix", "day_julian", "weekday", "hour") %in% names(df)))

})


test_that("Test data preparation function with custom arguments", {
  
  df <- data_london %>% 
    filter(variable == "no2") %>% 
    rmw_prepare_data(na.rm = TRUE) 
  
  expect_identical(class(df), c("tbl_df", "tbl", "data.frame"))
  
  df <- data_london %>% 
    filter(variable == "no2") %>% 
    rmw_prepare_data(replace = TRUE) 
  
  expect_identical(class(df), c("tbl_df", "tbl", "data.frame"))
  
  df <- data_london %>% 
    filter(variable == "no2") %>% 
    rmw_prepare_data(fraction = 0.5) 
  
  expect_identical(class(df), c("tbl_df", "tbl", "data.frame"))

})


test_that("Test training function", {
  
  # Keep it reproducible
  set.seed(123)
  
  # Get data
  df <- data_london %>% 
    filter(variable == "no2") %>% 
    rmw_prepare_data()
  
  # Use standard variables but minimal defaults, testing execution, not performance...
  model <- rmw_train_model(
    df,
    variables = c(
      "air_temp", "atmospheric_pressure", "rh", "wd", "ws", "date_unix", 
      "day_julian", "weekday"
      ),
    n_trees = 1,
    n_cores = 1
  )
  
  # Test model return
  expect_identical(class(model), "ranger")
  expect_equal(model$r.squared, 0.1620433, tolerance = 0.5)
  
  # Extract things from model
  df_importance <- rmw_model_importance(model)
  df_performance <- rmw_model_statistics(model)
  
  # Test
  expect_identical(class(df_importance), c("tbl_df", "tbl", "data.frame"))
  expect_identical(class(df_performance), c("tbl_df", "tbl", "data.frame"))
  
  # Importance plot
  expect_true(ggplot2::is_ggplot(rmw_plot_importance(df_importance)))
  
  # Test predictions
  df_predict <- rmw_predict_the_test_set(model = model, df = df)
  plot_test <- rmw_plot_test_prediction(df_predict)
  
  # The tests
  expect_identical(class(df_predict), c("tbl_df", "tbl", "data.frame"))
  expect_true(ggplot2::is_ggplot(plot_test))
  
  # Is this needed? 
  rm(.Random.seed, envir = globalenv())
  
})


test_that("Test normalising function", {
  
  # Keep it reproducible
  set.seed(123)
  
  # Get data
  df <- data_london %>% 
    filter(variable == "no2") %>% 
    rmw_prepare_data()
  
  # Use standard variables but minimal defaults, testing execution, not performance...
  model <- rmw_train_model(
    df,
    variables = c(
      "air_temp", "atmospheric_pressure", "rh", "wd", "ws", "date_unix", 
      "day_julian", "weekday"
    ),
    n_trees = 1,
    n_cores = 1
  )
  
  # Test prediction function
  expect_identical(class(rmw_predict(model, df, n_cores = 1)), "numeric")
  
  # Now normalise
  df_normalise <- rmw_normalise(
    model = model, 
    df = df,
    n_samples = 2,
    n_cores = 1
  )
  
  # Pass zero samples, an edge case
  df_normalise_zero <- rmw_normalise(
    model = model, 
    df = df,
    n_samples = 0,
    n_cores = 1
  )
  
  # Check 
  expect_identical(class(df_normalise), c("tbl_df", "tbl", "data.frame"))
  expect_identical(names(df_normalise), c("date", "value_predict"))
  expect_identical(class(df$date)[1], "POSIXct")
  expect_identical(nrow(df_normalise_zero), 0L)
  
})


test_that("Test normalising function with standard error calculation", {
  
  # Keep it reproducible
  set.seed(123)
  
  # Get data
  df <- data_london %>% 
    filter(variable == "no2") %>% 
    rmw_prepare_data()
  
  # Use standard variables but minimal defaults, testing execution, not performance...
  model <- rmw_train_model(
    df,
    variables = c(
      "air_temp", "atmospheric_pressure", "rh", "wd", "ws", "date_unix", 
      "day_julian", "weekday"
    ),
    n_trees = 5,
    n_cores = 1
  )
  
  # Test prediction function
  expect_identical(class(rmw_predict(model, df, se = TRUE, n_cores = 1)), "list")
  
  # Now normalise
  df_normalise <- rmw_normalise(
    model = model, 
    df = df,
    se = TRUE,
    n_samples = 2,
    n_cores = 1
  )
  
  # Check 
  expect_identical(class(df_normalise), c("tbl_df", "tbl", "data.frame"))
  expect_identical(names(df_normalise), c("date", "se", "value_predict"))
  expect_identical(class(df$date)[1], "POSIXct")
  
})


test_that("Test `rmw_do_all` function", {
  
  # Keep it reproducible
  set.seed(123)
  
  # Get data
  df <- data_london %>% 
    filter(variable == "no2") %>% 
    rmw_prepare_data()
  
  # Do
  list_normalised <- rmw_do_all(
    df = df,
    variables = c(
      "air_temp", "atmospheric_pressure", "rh", "wd", "ws", "date_unix", 
      "day_julian", "weekday"
    ),
    n_trees = 1,
    n_samples = 2,
    n_cores = 1
  )
  
  # Check types
  expect_identical(class(list_normalised), "list")
  
  # Check types
  list_types <- purrr::map(list_normalised, class) %>% 
    purrr::map_chr(`[[`, 1) %>% 
    unname()
  
  expect_identical(
    list_types,
    c("tbl_df", "ranger", "integer", "tbl_df", "tbl_df")
  )
  
})


test_that("Test `rmw_do_all` function and use variables_sample argument", {
  
  # Keep it reproducible
  set.seed(123)
  
  # Get data, use nox to be different
  df <- data_london %>% 
    filter(variable == "nox") %>% 
    rmw_prepare_data()
  
  variables <- c(
    "air_temp", "atmospheric_pressure", "rh", "wd", "ws", "date_unix", 
    "day_julian", "weekday"
  )
  
  # Drop
  variables_sample <- setdiff(variables, c("date_unix", "wd"))
  
  # Do
  list_normalised <- rmw_do_all(
    df = df,
    variables = variables,
    variables_sample = variables_sample,
    n_trees = 1,
    n_samples = 2,
    n_cores = 1
  )
  
  # Check types
  expect_identical(class(list_normalised), "list")
  
  # Check types
  list_types <- purrr::map(list_normalised, class) %>% 
    purrr::map_chr(`[[`, 1) %>% 
    unname()
  
  expect_identical(
    list_types,
    c("tbl_df", "ranger", "integer", "tbl_df", "tbl_df")
  )
  
})


test_that("Test `rmw_clip` function", {
  
  # Keep it reproducible
  set.seed(123)
  
  # Get data
  df <- data_london %>% 
    filter(variable == "no2") %>% 
    rmw_prepare_data()
  
  # Do
  list_normalised <- rmw_do_all(
    df = df,
    variables = c(
      "air_temp", "atmospheric_pressure", "rh", "wd", "ws", "date_unix", 
      "day_julian", "weekday"
    ),
    n_trees = 1,
    n_samples = 2,
    n_cores = 1
  )
  
  # Do
  df <- rmw_clip(list_normalised$normalised)
  
  # Check
  expect_identical(class(df), c("tbl_df", "tbl", "data.frame"))
  
})
