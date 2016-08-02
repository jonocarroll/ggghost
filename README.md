# Oh, no! I think I saw a ... *ggghost*

Capture the spirit of your `ggplot` calls.

![](https://github.com/jonocarroll/ggghost/raw/master/inst/img/scooby.gif)

## Installation

You can install `ggghost` from github with:

```{r}
# install.packages("devtools")
devtools::install_github("jonocarroll/ggghost")
```

## Examples

use `%g<%` to initiate storage of the `ggplot` calls then add to the call with each logical call on a new line (@hrbrmstr style)

```{r}
tmp <- data.frame(x = 1:100, y = rnorm(100))

library(ggplot2)
z %g<% ggplot(tmp, aes(x,y))
z <- z + geom_point()
z <- z + theme_bw()
z <- z + labs(title = "My cool ggplot")
```

This invisibly stores the `ggplot` calls in a list which can be reviewed

```{r}
summary(z)
#> [[1]]
#> ggplot(tmp, aes(x, y))
#> 
#> [[2]]
#> geom_point()
#> 
#> [[3]]
#> theme_bw()
#> 
#> [[4]]
#> labs(title = "plot")

summary(z, combine = TRUE)
#> [1] "ggplot(tmp, aes(x, y)) + geom_point() + theme_bw() + labs(title = \"plot\")"

z
```
![](https://github.com/jonocarroll/ggghost/raw/master/inst/img/example1.png)

Better yet, the list can be subset, removing parts of the call
```{r}
z2 <- subset(z, c(1,2,4))
#> [[1]]
#> ggplot(tmp, aes(x, y))
#> 
#> [[2]]
#> geom_point()
#> 
#> [[3]]
#> labs(title = "My cool ggplot")
```
![](https://github.com/jonocarroll/ggghost/raw/master/inst/img/example2.png)

```{r}
## the object still contains all the grob info
str(print(z))
#> List of 3
#> $ data :List of 1
#>  ..$ :'data.frame':	100 obs. of  10 variables:
#>  .. ..$ x     : num [1:100] 1 2 3 4 5 6 7 8 9 10 ...
#>  .. ..$ y     : num [1:100] 0.624 -0.569 0.127 -1.358 -1.896 ...
#>  .. ..$ PANEL : int [1:100] 1 1 1 1 1 1 1 1 1 1 ...
#>  .. ..$ group : int [1:100] -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
#>  .. ..$ shape : num [1:100] 19 19 19 19 19 19 19 19 19 19 ...
#>  .. ..$ colour: chr [1:100] "black" "black" "black" "black" ...
#>  .. ..$ size  : num [1:100] 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 ...
#>  .. ..$ fill  : logi [1:100] NA NA NA NA NA NA ...
#>  .. ..$ alpha : logi [1:100] NA NA NA NA NA NA ...
#>  .. ..$ stroke: num [1:100] 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 ...
#> $ panel:List of 5
#>  ..$ layout  :'data.frame':	1 obs. of  5 variables:
#>  .. ..$ PANEL  : int 1
#>  .. ..$ ROW    : int 1
#>  .. ..$ COL    : int 1
#>  .. ..$ SCALE_X: int 1
#>  .. ..$ SCALE_Y: int 1
#>  ..$ shrink  : logi TRUE
#>  ..$ x_scales:List of 1
#> [... truncated ...]
```

```{r}
## ggplot still works as normal
ggplot(tmp) + geom_point(aes(x,y), col="red")
```
