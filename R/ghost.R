`%g<%` <- function(lhs, rhs) {

  match     <- match.call()
  match_lhs <- match[[2]]
  match_rhs <- match[[3]]

  new_obj <- list(as.call(match_rhs))
  class(new_obj) <- "ggghost"
  
  parent <- parent.frame()
  assign(as.character(match_lhs), new_obj, envir = parent)
  
  return(invisible(NULL))
  
}

## OVERLOAD + (dangerous)
`+` <- function (e1, e2) UseMethod("+")
`+.default` <- function (e1, e2) .Primitive("+") (e1, e2)
`+.ggghost` <- function(e1, e2) {
  new_list <- append(e1, match.call()[[3]])
  class(new_list) <- "ggghost"
  return(new_list)
}


print.ggghost <- function(call_list) {
  
  print(eval(parse(text = paste(call_list, collapse = " + "))))
  
}

summary.ggghost <- function(call_list, combine = FALSE) {
  
  if(combine) 
    paste(call_list, collapse = " + ") 
  else 
    print(head(call_list, n = length(z)))
  
}

tmp <- data.frame(x = 1:100, y = rnorm(100))
z %g<% ggplot(tmp, aes(x,y))
summary(z)
str(z)
z <- z + geom_point()
z
summary(z, combine = TRUE)
str(z)
z <- z + theme_bw()
z <- z + labs(title = "plot")
z
summary(z)
str(z)


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
#> produces plot
str(print(z))
#> still contains all the grob info

## ggplot still works as normal
ggplot(tmp) + geom_point(aes(x,y), col="red")
