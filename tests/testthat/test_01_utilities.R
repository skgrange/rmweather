context("Utility functions")

test_that("Example observational data", {
  
  # Load example data
  df <- data_london
  
  # Test data frame
  expect_identical(class(df), c("tbl_df", "tbl", "data.frame"))
  expect_identical(ncol(df), 11L)
  expect_identical(class(df$date)[1], "POSIXct")

})


test_that("Example normalised data", {
  
  # Load example data
  df <- data_london_normalised
  
  # Test data frame
  expect_identical(class(df), c("tbl_df", "tbl", "data.frame"))
  expect_identical(ncol(df), 5L)
  
  expect_true(names(df)[1] == "date")
  expect_identical(class(df$date)[1], "POSIXct")
  
  expect_true(names(df)[5] == "value_predict")
  
})


test_that("Example ranger object", {
  
  # Load example
  model <- model_london
  
  # Test data frame
  expect_identical(class(model), "ranger")
  expect_identical(length(model), 16L)
  
})


test_that("CPU count", {
  
  x <- system_cpu_core_count()
  expect_identical(class(x), "integer")
  expect_identical(length(x), 1L)
  
})
