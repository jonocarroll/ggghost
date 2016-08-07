library(ggghost)
library(ggplot2)
context("Construction")

dat <- data.frame(x = 1:100, y = rnorm(100))
ggghostx %g<% ggplot(dat, aes(x,y))
ggghostx2 %g<% ggplot(aes(x,y), data = dat)

test_that("%g<% constructs a ggghost object", {
  expect_s3_class(ggghostx, "ggghost")
  expect_s3_class(ggghostx, "gg")
  expect_type(ggghostx[[1]], "language")
  expect_true(grepl("ggplot",as.character(ggghostx)))
})

test_that("%g<% captures data regardless of where it is in the argument list", {
    expect_type(attr(ggghostx2, "data"), "list")
    expect_s3_class(attr(ggghostx2, "data")$data, "data.frame")
}) 