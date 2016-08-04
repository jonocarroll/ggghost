
<!-- README.md is generated from README.Rmd. Please edit that file -->
Oh, no! I think I saw a ... *g-g-ghost*
=======================================

Capture the spirit of your `ggplot` calls.

![](https://github.com/jonocarroll/ggghost/raw/master/inst/img/scooby.gif)

Motivation
----------

`ggplot` stores the information needed to build the graph as a `grob`, but that's what the **computer** needs to know about in order to build the graph. As humans, we're more interested in what commands were issued in order to build the graph. Here is one option that solves that problem.

`ggghost` stores the `ggplot` commands (usually separated by `+`) as they are generated, in effect lazily collecting the calls. Once the object is requested, the `print` method combines the individual calls back into the total plotting command and executes it. This is where the call would usually be discarded. Instead, a "ghost" of the commands lingers in the object for further investigation, subsetting, or adding to.

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
tmp <- data.frame(x = 1:100, y = rnorm(100))

library(ggplot2)
library(ggghost)
z %g<% ggplot(tmp, aes(x,y))
z <- z + geom_point(col = "steelblue")
z <- z + theme_bw()
z <- z + labs(title = "My cool ggplot")
```

This invisibly stores the `ggplot` calls in a list which can be reviewed either with the list of calls

``` r
summary(z)
#> [[1]]
#> ggplot(tmp, aes(x, y))
#> 
#> [[2]]
#> geom_point(col = "steelblue")
#> 
#> [[3]]
#> theme_bw()
#> 
#> [[4]]
#> labs(title = "My cool ggplot")
```

or the concatenated call

``` r
summary(z, combine = TRUE)
#> [1] "ggplot(tmp, aes(x, y)) + geom_point(col = \"steelblue\") + theme_bw() + labs(title = \"My cool ggplot\")"
```

The plot can be generated using a `print` method

``` r
z
```

![](inst/img/README-unnamed-chunk-6-1.png)

The call list can be subset, removing parts of the call

``` r
(z2 <- subset(z, c(1,2,4)))
```

![](inst/img/README-unnamed-chunk-7-1.png)

Plot features can be removed by name, a task that would otherwise have involved re-generating the entire plot

``` r
z <- z + geom_line(col = "coral")
z <- z - geom_point()
z
```

![](inst/img/README-unnamed-chunk-8-1.png)

Calls are removed based on matching to the regex `(.*$` (from the first bracket to the end of the call), so arguments are irrelevant.

The object still contains all the grob info, it's just stored as calls rather than a completed image.

``` r
str(print(z))
#> List of 3
#>  $ data :List of 1
#>   ..$ :'data.frame': 100 obs. of  8 variables:
#>   .. ..$ x       : num [1:100] 1 2 3 4 5 6 7 8 9 10 ...
#>   .. ..$ y       : num [1:100] 0.977 1.109 -0.923 1.16 -0.534 ...
#>   .. ..$ PANEL   : int [1:100] 1 1 1 1 1 1 1 1 1 1 ...
#>   .. ..$ group   : int [1:100] -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
#>   .. ..$ colour  : chr [1:100] "coral" "coral" "coral" "coral" ...
#>   .. ..$ size    : num [1:100] 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 ...
#>   .. ..$ linetype: num [1:100] 1 1 1 1 1 1 1 1 1 1 ...
#>   .. ..$ alpha   : logi [1:100] NA NA NA NA NA NA ...
#>  $ panel:List of 5
#>   ..$ layout  :'data.frame': 1 obs. of  5 variables:
#>   .. ..$ PANEL  : int 1
#>   .. ..$ ROW    : int 1
#>   .. ..$ COL    : int 1
#>   .. ..$ SCALE_X: int 1
#>   .. ..$ SCALE_Y: int 1
#>   ..$ shrink  : logi TRUE
#>   ..$ x_scales:List of 1
#> [... truncated ...]
```

`ggplot` still works as normal if you want to avoid storing the calls.

``` r
ggplot(tmp) + geom_point(aes(x,y), col = "red")
```

![](inst/img/README-unnamed-chunk-10-1.png)

Show the process of building up the plot as a (re-)animation

![](https://github.com/jonocarroll/ggghost/raw/master/inst/img/ggghost.gif)
