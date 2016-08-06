library(ggghost)
context("Ops (+, -)")

dat <- data.frame(x = 1:100, y = rnorm(100))
gg1 <- ggplot2::ggplot(dat, aes(x,y)) 
gg2 <- ggplot2::geom_point()
ggx <- gg1 + gg2

test_that("+ behaves as normal for ordinary objects", {
  expect_equal(2L + 3L, 5L)
  expect_equal(2. + 3., 5.)
  expect_equal(c(2L, 3.) + c(1L, 1.), c(3., 4.))
  expect_error("a" + "b")
  expect_s3_class(ggx, "gg")
})

test_that("- behaves as normal for ordinary objects", {
  expect_equal(3L - 2L, 1L)
  expect_equal(3. - 2., 1.)
  expect_equal(c(2L, 3.) - c(1L, 1.), c(1., 2.))
  expect_error("a" - "b")
})

ggghostx %g<% ggplot2::ggplot(dat, aes(x,y))
ggghostx <- ggghostx + ggplot2::geom_point(col = "red")
ggghostx2 <- ggghostx - geom_point()

test_that("+ produces new behaviour", {
  expect_s3_class(ggghostx, "ggghost")
  expect_s3_class(eval(ggghostx), "gg")
  expect_equal(length(ggghostx), 2)
  expect_true(grepl("geom_point", summary(ggghostx, combine = TRUE)))
})

test_that("- produces new behaviour", {
  expect_s3_class(ggghostx2, "ggghost")
  expect_s3_class(eval(ggghostx2), "gg")
  expect_equal(length(ggghostx2), 1)
  expect_false(grepl("geom_point", summary(ggghostx2, combine = TRUE)))
})

test_that("- fails if trying to remove ggplot() or missing call",{
    expect_warning(ggghostx - ggplot(), "ggghostbuster")
    expect_warning(ggghostx - geom_bar(), "ggghostbuster")
})