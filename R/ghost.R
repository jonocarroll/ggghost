#' @export
`%g<%` <- function(lhs, rhs) {
    match     <- match.call()
    match_lhs <- match[[2]]
    match_rhs <- match[[3]]
    
    new_obj <- structure(list(as.call(match_rhs)), class = c("ggghost", "gg"))

    parent <- parent.frame()
    assign(as.character(match_lhs), new_obj, envir = parent)
    
    return(invisible(NULL))
}

#' @export
is.ggghost <- function(x) inherits(x, "ggghost")

#' @export
"+.gg" <- function(e1, e2) {
    # Get the name of what was passed in as e2, and pass along so that it
    # can be displayed in error messages
    e2name <- deparse(substitute(e2))
    
    if      (is.theme(e1))  ggplot2:::add_theme(e1, e2, e2name)
    else if (is.ggplot(e1)) ggplot2:::add_ggplot(e1, e2, e2name)
    else if (is.ggghost(e1)) structure(append(e1, match.call()[[3]]), class = c("ggghost", "gg"))
}

#' @export
"-.ggghost" <- function(e1, e2) {
    if      (is.theme(e1))  stop("not implemented for ggplot2 themes")
    else if (is.ggplot(e1)) stop("not implemented for ggplot2 plots")
    else if (is.ggghost(e1)) { 
        call_to_remove <- match.call()[[3]]
        if (!grepl(sub("\\(.*$", "", call_to_remove), as.character(summary(e1, combine = TRUE)))) {
            warning("can't find that call in the call list")
            return(e1)
        }
        structure(unclass(e1)[-grep(sub("\\(.*$", "", call_to_remove), unclass(e1))], class = c("ggghost", "gg"))
    }
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
    structure(unclass(x)[i], class = c("ggghost", "gg"))
}
