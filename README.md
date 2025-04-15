
<!-- badges: start -->
[![packageversion](https://img.shields.io/badge/Package%20version-0.2.1-orange.svg?style=flat-square)](commits/master)
[![Last-changedate](https://img.shields.io/badge/last%20change-2025--04--15-yellowgreen.svg)](/commits/master)
[![R-CMD-check](https://github.com/jonocarroll/ggghost/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jonocarroll/ggghost/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

[![Downloads](http://cranlogs.r-pkg.org/badges/ggghost)](http://www.r-pkg.org/pkg/ggghost)
[![GitHub
forks](https://img.shields.io/github/forks/jonocarroll/ggghost.svg)](https://github.com/jonocarroll/ggghost/network)
[![GitHub
stars](https://img.shields.io/github/stars/jonocarroll/ggghost.svg)](https://github.com/jonocarroll/ggghost/stargazers)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# :ghost: *Oh, no! I think I saw a … g-g-ghost*

![](https://github.com/jonocarroll/ggghost/raw/master/README_supp/scooby.gif)

Capture the spirit of your `ggplot2` calls.

## Motivation

`ggplot2::ggplot()` stores the information needed to build the graph as
a `grob`, but that’s what the **computer** needs to know about in order
to build the graph. As humans, we’re more interested in what commands
were issued in order to build the graph. For good reproducibility, the
calls need to be applied to the relevant data. While this is somewhat
available by deconstructing the `grob`, it’s not the simplest approach.

Here is one option that solves that problem.

`ggghost` stores the data used in a `ggplot()` call, and collects
`ggplot2` commands (usually separated by `+`) as they are applied, in
effect lazily collecting the calls. Once the object is requested, the
`print` method combines the individual calls back into the total
plotting command and executes it. This is where the call would usually
be discarded. Instead, a “ghost” of the commands lingers in the object
for further investigation, subsetting, adding to, or subtracting from.

## Installation

You can install `ggghost` from CRAN with:

``` r
install.packages("ggghost")
```

or the development version from github with:

``` r
# install.packages("devtools")
devtools::install_github("jonocarroll/ggghost")
```

## Usage

use `%g<%` to initiate storage of the `ggplot2` calls then add to the
call with each logical call on a new line (@hrbrmstr style)

``` r
tmpdata <- data.frame(x = 1:100, y = rnorm(100))
head(tmpdata)
#>   x          y
#> 1 1  1.8318017
#> 2 2 -0.8719125
#> 3 3  0.4451759
#> 4 4 -0.6943876
#> 5 5 -0.2814022
#> 6 6 -0.6976087
```

``` r
library(ggplot2)
library(ggghost)
z %g<% ggplot(tmpdata, aes(x, y))
z <- z + geom_point(col = "steelblue")
z <- z + theme_bw()
z <- z + labs(title = "My cool ggplot")
z <- z + labs(x = "x axis", y = "y axis")
z <- z + geom_smooth()
```

This invisibly stores the `ggplot2` calls in a list which can be
reviewed either with the list of calls

``` r
summary(z)
#> [[1]]
#> ggplot(tmpdata, aes(x, y))
#> 
#> [[2]]
#> geom_point(col = "steelblue")
#> 
#> [[3]]
#> theme_bw()
#> 
#> [[4]]
#> labs(title = "My cool ggplot")
#> 
#> [[5]]
#> labs(x = "x axis", y = "y axis")
#> 
#> [[6]]
#> geom_smooth()
```

or the concatenated call

``` r
summary(z, combine = TRUE)
#> [1] "ggplot(tmpdata, aes(x, y)) + geom_point(col = \"steelblue\") + theme_bw() + labs(title = \"My cool ggplot\") + labs(x = \"x axis\", y = \"y axis\") + geom_smooth()"
```

The plot can be generated using a `print` method

``` r
z
```

![](README_supp/README-unnamed-chunk-8-1.png)<!-- -->

which re-evaluates the list of calls and applies them to the saved data,
meaning that the plot remains reproducible even if the data source is
changed/destroyed.

The call list can be subset, removing parts of the call

``` r
subset(z, c(1,2,6))
```

![](README_supp/README-unnamed-chunk-9-1.png)<!-- -->

Plot features can be removed by name, a task that would otherwise have
involved re-generating the entire plot

``` r
z2 <- z + geom_line(col = "coral")
z2 - geom_point()
```

![](README_supp/README-unnamed-chunk-10-1.png)<!-- -->

Calls are removed based on matching to the regex `\\(.*$` (from the
first bracket to the end of the call), so arguments are irrelevant.

The object still generates all the `grob` info, it’s just stored as
calls rather than a completed image.

``` r
str(print(z))
#> List of 11
#>  $ data       :'data.frame': 100 obs. of  2 variables:
#>   ..$ x: int [1:100] 1 2 3 4 5 6 7 8 9 10 ...
#>   ..$ y: num [1:100] 1.832 -0.872 0.445 -0.694 -0.281 ...
#>  $ layers     :List of 2
#> [... truncated ...]
#>  - attr(*, "class")= chr [1:2] "gg" "ggplot"
```

Since the `grob` info is still produced, normal `ggplot2` operators can
be applied *after* the `print` statement, such as replacing the data

``` r
xvals <- seq(0,2*pi,0.1)
tmpdata_new <- data.frame(x = xvals, y = sin(xvals))
print(z - geom_smooth()) %+% tmpdata_new
```

![](README_supp/README-unnamed-chunk-12-1.png)<!-- -->![](README_supp/README-unnamed-chunk-12-2.png)<!-- -->

`ggplot2` calls still work as normal if you want to avoid storing the
calls.

``` r
ggplot(tmpdata) + geom_point(aes(x,y), col = "red")
```

![](README_supp/README-unnamed-chunk-13-1.png)<!-- -->

Since the object is a list, we can stepwise show the process of building
up the plot as a (re-)animation

``` r
lazarus(z, "mycoolplot.gif")
```

![](README_supp/mycoolplot.gif)<!-- -->

A supplementary data object (e.g. for use in a `geom_*` or `scale_*`
call) can be added to the `ggghost` object

``` r
myColors <- c("alpha" = "red", "beta" = "blue", "gamma" = "green")
supp_data(z) <- myColors
```

These will be recovered along with the primary data.

For full reproducibility, the entire structure can be saved to an object
for re-loading at a later point. This may not have made much sense for a
`ggplot2` object, but now both the original data and the calls to
generate the plot are saved. Should the environment that generated the
plot be destroyed, all is not lost.

``` r
saveRDS(z, file = "README_supp/mycoolplot.rds")
rm(z)
rm(tmpdata)
rm(myColors)
exists("z")
#> [1] FALSE
exists("tmpdata")
#> [1] FALSE
exists("myColors")
#> [1] FALSE
```

Reading the `ggghost` object back to the session, both the relevant data
and plot-generating calls can be re-executed.

``` r
z <- readRDS("README_supp/mycoolplot.rds")
str(z)
#> List of 6
#>  $ : language ggplot(tmpdata, aes(x, y))
#>  $ : language geom_point(col = "steelblue")
#>  $ : language theme_bw()
#>  $ : language labs(title = "My cool ggplot")
#>  $ : language labs(x = "x axis", y = "y axis")
#>  $ : language geom_smooth()
#>  - attr(*, "class")= chr [1:2] "ggghost" "gg"
#>  - attr(*, "data")=List of 2
#>   ..$ data_name: chr "tmpdata"
#>   ..$ data     :'data.frame':    100 obs. of  2 variables:
#>   .. ..$ x: int [1:100] 1 2 3 4 5 6 7 8 9 10 ...
#>   .. ..$ y: num [1:100] 1.832 -0.872 0.445 -0.694 -0.281 ...
#>  - attr(*, "suppdata")=List of 2
#>   ..$ supp_data_name: chr "myColors"
#>   ..$ supp_data     : Named chr [1:3] "red" "blue" "green"
#>   .. ..- attr(*, "names")= chr [1:3] "alpha" "beta" "gamma"

recover_data(z, supp = TRUE)
head(tmpdata)
#>   x          y
#> 1 1  1.8318017
#> 2 2 -0.8719125
#> 3 3  0.4451759
#> 4 4 -0.6943876
#> 5 5 -0.2814022
#> 6 6 -0.6976087

myColors
#>   alpha    beta   gamma 
#>   "red"  "blue" "green"

z
```

![](README_supp/README-unnamed-chunk-18-1.png)<!-- -->

We now have a proper reproducible graphic.

## Caveats

- The data *must* be used as an argument in the `ggplot2` call, not
  piped in to it. Pipelines such as `z %g<% tmpdata %>% ggplot()` won’t
  work… yet.
- ~~Only one original data set will be stored; the one in the original
  `ggplot(data = x)` call. If you require supplementary data for some
  `geom` then you need manage storage/consistency of that.~~ (fixed)
- For removing `labs` calls, an argument *must* be present. It doesn’t
  need to be the actual one (all will be removed) but it must evaluate
  in scope. `TRUE` will do fine.
