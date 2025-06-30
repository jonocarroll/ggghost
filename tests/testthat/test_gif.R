library(ggghost)
library(ggplot2)
context("(Re-)animation")

dat <- data.frame(x = 1:100, y = rnorm(100))
z %g<% ggplot(dat, aes(x, y))
z <- z + geom_point(col = "steelblue")
z <- z + theme_bw()
z <- z + labs(title = "My cool ggplot")
z <- z + labs(x = "x axis", y = "y axis")
z <- z + geom_smooth()
giftest <- lazarus(z, "testgif.gif")

test_that("gif can be created without errors/warnings", {
  expect_identical(giftest, TRUE)
})

if (file.exists("testgif.gif")) file.remove("testgif.gif")
