library(ggghost)
library(ggplot2)
context("Construction")

dat <- data.frame(x = 1:100, y = rnorm(100))
ggghostx %g<% ggplot(dat, aes(x,y))

test_that("%g<% constructs a ggghost object", {
  expect_s3_class(ggghostx, "ggghost")
  expect_s3_class(ggghostx, "gg")
  expect_type(ggghostx[[1]], "language")
  expect_true(grepl("ggplot",as.character(ggghostx)))
})