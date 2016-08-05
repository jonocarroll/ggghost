[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Linux/Mac Travis Build Status](https://img.shields.io/travis/jonocarroll/ggghost/master.svg?label=Mac%20OSX%20%26%20Linux)](https://travis-ci.org/jonocarroll/ggghost) [![AppVeyor Build Status](https://img.shields.io/appveyor/ci/jonocarroll/ggghost/master.svg?label=Windows)](https://ci.appveyor.com/project/jonocarroll/ggghost) [![codecov](https://codecov.io/gh/jonocarroll/ggghost/branch/master/graph/badge.svg)](https://codecov.io/gh/jonocarroll/ggghost) [![GitHub forks](https://img.shields.io/github/forks/jonocarroll/ggghost.svg)](https://github.com/jonocarroll/ggghost/network) [![GitHub stars](https://img.shields.io/github/stars/jonocarroll/ggghost.svg)](https://github.com/jonocarroll/ggghost/stargazers) [![Twitter](https://img.shields.io/twitter/url/https/github.com/jonocarroll/ggghost.svg?style=social)](https://twitter.com/intent/tweet?text=Wow:&url=%5Bobject%20Object%5D) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/ggghost)](https://cran.r-project.org/package=ggghost) [![packageversion](https://img.shields.io/badge/Package%20version-0.0.0.9000-orange.svg?style=flat-square)](commits/master) [![Last-changedate](https://img.shields.io/badge/last%20change-2016--08--06-yellowgreen.svg)](/commits/master)

<!-- README.md is generated from README.Rmd. Please edit that file -->
Oh, no! I think I saw a ... *g-g-ghost*
=======================================

Capture the spirit of your `ggplot` calls.

![](https://github.com/jonocarroll/ggghost/raw/master/inst/img/scooby.gif)

Motivation
----------

`ggplot` stores the information needed to build the graph as a `grob`, but that's what the **computer** needs to know about in order to build the graph. As humans, we're more interested in what commands were issued in order to build the graph. For good reproducibility, the calls need to be applied to the relevant data. While this is somewhat available by deconstructing the `grob`, it's not the simplest approach.

Here is one option that solves that problem.

`ggghost` stores the data used in a `ggplot()` call, and collects `ggplot` commands (usually separated by `+`) as they are applied, in effect lazily collecting the calls. Once the object is requested, the `print` method combines the individual calls back into the total plotting command and executes it. This is where the call would usually be discarded. Instead, a "ghost" of the commands lingers in the object for further investigation, subsetting, adding to, or subtracting from.

Installation
------------

You can install `ggghost` from github with:

``` r
# install.packages("devtools")
devtools::install_github("jonocarroll/ggghost")
```

Usage
-----

use `%g<%` to initiate storage of the `ggplot` calls then add to the call with each logical call on a new line (@hrbrmstr style)

``` r
tmpdata <- data.frame(x = 1:100, y = rnorm(100))
head(tmpdata)
#>   x           y
#> 1 1 -0.01830042
#> 2 2  1.32715969
#> 3 3 -0.00528025
#> 4 4 -1.57672576
#> 5 5  1.54318048
#> 6 6  0.02371901
```

``` r
library(ggplot2)
library(ggghost)
z %g<% ggplot(tmpdata, aes(x,y))
z <- z + geom_point(col = "steelblue")
z <- z + theme_bw()
z <- z + labs(title = "My cool ggplot")
z <- z + labs(x = "x axis", y = "y axis")
z <- z + geom_smooth()
```

This invisibly stores the `ggplot` calls in a list which can be reviewed either with the list of calls

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

![](inst/img/README-unnamed-chunk-7-1.png)

which re-evaluates the list of calls and applies them to the saved data, meaning that the plot remains reproducible even if the data source is changed/destroyed.

The call list can be subset, removing parts of the call

``` r
(z2 <- subset(z, c(1,2,6)))
```

![](inst/img/README-unnamed-chunk-8-1.png)

Plot features can be removed by name, a task that would otherwise have involved re-generating the entire plot

``` r
z3 <- z + geom_line(col = "coral")
z3 <- z3 - geom_point()
z3
```

![](inst/img/README-unnamed-chunk-9-1.png)

Calls are removed based on matching to the regex `\\(.*$` (from the first bracket to the end of the call), so arguments are irrelevant.

The object still generates all the grob info, it's just stored as calls rather than a completed image.

``` r
str(print(z))
#> List of 9
#>  $ data       :'data.frame': 100 obs. of  2 variables:
#>   ..$ x: int [1:100] 1 2 3 4 5 6 7 8 9 10 ...
#>   ..$ y: num [1:100] -0.0183 1.32716 -0.00528 -1.57673 1.54318 ...
#>  $ layers     :List of 2
#> [... truncated ...]
```

`ggplot` still works as normal if you want to avoid storing the calls.

``` r
ggplot(tmpdata) + geom_point(aes(x,y), col = "red")
```

![](inst/img/README-unnamed-chunk-11-1.png)

Since the object is a list, we can stepwise show the process of building up the plot as a (re-)animation

``` r
lazarus(z, "mycoolplot.gif")
```

![](inst/img/mycoolplot.gif)

For full reproducibility, the entire structure can be saved to an object for re-loading at a later point. This may not have made much sense for a `ggplot2` object, but now both the original data and the calls to generate the plot are saved. Should the environment that generated the plot be destroyed, all is not lost.

``` r
saveRDS(z, file = "inst/extdata/mycoolplot.rds")
rm(z)
rm(tmpdata)
exists("z")
#> [1] FALSE
exists("tmpdata")
#> [1] FALSE
```

Reading the `ggghost` object back to the session, both the relevant data and plot-generating calls can be re-executed.

``` r
z <- readRDS("inst/extdata/mycoolplot.rds")
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
#>   .. ..$ y: num [1:100] -0.0183 1.32716 -0.00528 -1.57673 1.54318 ...

recover_data(z)
head(tmpdata)
#>   x           y
#> 1 1 -0.01830042
#> 2 2  1.32715969
#> 3 3 -0.00528025
#> 4 4 -1.57672576
#> 5 5  1.54318048
#> 6 6  0.02371901
z
```

![](inst/img/README-unnamed-chunk-14-1.png)

We now have a proper reproducible graphic.

Caveats
-------

-   The data *must* be used as an argument in the `ggplot` call, not piped in to it. Pipelines such as `z %g<% tmpdata %>% ggplot()` won't work... yet.
-   Only one original data set will be stored; the one in the original `ggplot(data = x)` call. If you require supplementary data for some `geom` then you need manage storage/consistency of that.
