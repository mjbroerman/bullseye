test_that("summation works", {
  expect_equal(sum_numbers('1', '2'), 3)
  expect_equal(sum_numbers(1, 2), 3)
  expect_equal(sum_numbers(1, "A"), "not numeric")
})
