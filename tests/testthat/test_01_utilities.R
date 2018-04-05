context("Utility functions")

test_that("Example data", {
  
  # Load example data
  df <- rmw_example_data()
  
  # Test data frame
  expect_identical(class(df), "data.frame")
  expect_identical(ncol(df), 14L)
  expect_identical(class(df$date)[1], "POSIXct")

})


test_that("CPU count", {
  
  x <- system_cpu_core_count()
  expect_identical(class(x), "integer")
  expect_identical(length(x), 1L)
  
})
