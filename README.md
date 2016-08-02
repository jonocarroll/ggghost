# Oh, no! I think I saw a ... *ggghost*

Capture the spirit of your `ggplot` calls.

![](https://github.com/jonocarroll/ggghost/raw/master/inst/img/scooby.gif)

## Installation

You can install `ggghost` from github with:

```{r}
# install.packages("devtools")
devtools::install_github("ggghost/jonocarroll")
```

## Examples

```{r}
tmp <- data.frame(x = 1:100, y = rnorm(100))

## use %g<% to initiate storage of the ggplot calls
## then add to the call with each logical call on 
## a new line (@hrbrmstr style)
library(ggplot2)
z %g<% ggplot(tmp, aes(x,y))
z <- z + geom_point()
z <- z + theme_bw()
z <- z + labs(title = "My cool ggplot")
```

This invisibly stores the `ggplot` calls in a list.

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
![](https://github.com/jonocarroll/ggghost/raw/master/inst/img/example1.gif)

```{r}
## the object still contains all the grob info
str(print(z))
```

```{r}
## ggplot still works as normal
ggplot(tmp) + geom_point(aes(x,y), col="red")
```
