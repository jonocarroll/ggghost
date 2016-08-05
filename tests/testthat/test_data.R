library(ggghost)
library(ggplot2)
context("Data recovery")

dat <- df_saved <- data.frame(x = 1:100, y = rnorm(100))
ggghostx %g<% ggplot(dat, aes(x,y))
ggghostx <- ggghostx + geom_point(col = "red")
rm(dat)
recover_data(ggghostx)

test_that("data can be successfully recovered", {
    expect_identical(df_saved, dat)
})