library(ggghost)
library(ggplot2)
context("Data recovery")

dat <- df_saved <- data.frame(x = 1:100, y = rnorm(100))
sdat <- sdat_saved <- data.frame(a = 21:30, y = rnorm(10))
ggghostx %g<% ggplot(dat, aes(x,y))
ggghostx <- ggghostx + geom_point(col = "red")
rm(dat)
recover_data(ggghostx)

test_that("data can be successfully recovered", {
    expect_identical(df_saved, dat)
})

dat <- data.frame(x = 1:100, y = rnorm(100))

test_that("overwriting changed data produces a warning",{
    expect_warning(recover_data(ggghostx, supp = FALSE))
})

test_that("supplementary data is rejected from a non-ggghost object",{
    expect_error(supp_data(sdat) <- c(1, 2))
})

test_that("non-existant supplementary data cannot be extracted from a ggghost object",{
    expect_warning(recover_data(ggghostx, supp = TRUE))
})

test_that("supplementary data can be added to a ggghost object",{
    expect_silent(supp_data(ggghostx) <- sdat)
})

supp_data(ggghostx) <- sdat

test_that("adding additional supplementary data produces a warning",{
    expect_warning(supp_data(ggghostx) <- sdat)
})


test_that("supplementary data be inspected",{
    expect_type(supp_data(ggghostx), "list")
    expect_s3_class(supp_data(ggghostx)[[2]], "data.frame")
    expect_identical(supp_data(ggghostx)[[2]], sdat)
})

sdat <- c(1, 2)

test_that("overwriting changed supplementary data produces a warning",{
    expect_warning(recover_data(ggghostx, supp = TRUE))
})

recover_data(ggghostx, supp = TRUE)

test_that("supplementary data be successfully recovered",{
    expect_identical(sdat_saved, sdat)
})

ggghostx <- ggghostx + geom_line()

test_that("supplementary data remains after adding a call", {
    expect_identical(supp_data(ggghostx)[[2]], sdat)
})
