#' @export
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
#' @export
`+` <- function (e1, e2) UseMethod("+")

#' @export
`+.default` <- function (e1, e2) .Primitive("+") (e1, e2)

#' @export
`+.ggghost` <- function(e1, e2) {
  new_list <- append(e1, match.call()[[3]])
  class(new_list) <- "ggghost"
  return(new_list)
}

#' @export
print.ggghost <- function(call_list) {
  
  print(eval(parse(text = paste(call_list, collapse = " + "))))
  
}


#' @export
summary.ggghost <- function(call_list, combine = FALSE) {
  
  if (combine) 
    paste(call_list, collapse = " + ") 
  else 
    print(head(call_list, n = length(call_list)))
  
}

#' @export
subset.ggghost <- function(x, i) {

  new_list <- unclass(x)[i]
  class(new_list) <- "ggghost"
  return(new_list)

}
