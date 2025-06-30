library(ggghost)
library(ggplot2)
context("Methods")

dat <- data.frame(x = 1:100, y = rnorm(100))
ggghostx %g<% ggplot(dat, aes(x, y))
ggghostx <- ggghostx + geom_point(col = "red")
ggghostx <- ggghostx + geom_line(col = "steelblue")
summary1 <- summary(ggghostx)
summary2 <- summary(ggghostx, combine = TRUE)
ggsubset <- subset(ggghostx, c(1, 3))
summary3 <- summary(ggsubset)
summary4 <- summary(ggsubset, combine = TRUE)

test_that("ggghost methods behave correctly", {
  expect_s3_class(print(ggghostx), "gg")
  expect_s3_class(print(ggghostx), "ggplot")

  expect_type(summary1, "list")
  expect_identical(length(summary1), 3L)
  expect_type(summary2, "character")
  expect_true(grepl("ggplot", summary2))
  expect_true(grepl("geom_point", summary2))

  expect_s3_class(ggsubset, "gg")
  expect_s3_class(ggsubset, "ggghost")

  expect_type(summary3, "list")
  expect_identical(length(summary3), 2L)
  expect_type(summary4, "character")
  expect_true(grepl("ggplot", summary4))
  expect_true(grepl("geom_line", summary4))
  expect_false(grepl("geom_point", summary4))
})
