library(ggghost)
context("Construction")

ggghostx %g<% ggplot2::ggplot(df, aes(x,y))

test_that("%g<% constructs a ggghost object", {
  expect_s3_class(ggghostx, "ggghost")
  expect_s3_class(ggghostx, "gg")
  expect_type(ggghostx[[1]], "language")
  expect_true(grepl("ggplot",as.character(ggghostx)))
})