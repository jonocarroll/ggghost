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

#' @importFrom ggplot2 is.theme is.ggplot
#' @export
"+.gg" <- function(e1, e2) {
    # Get the name of what was passed in as e2, and pass along so that it
    # can be displayed in error messages
    e2name <- deparse(substitute(e2))
    
    if      (ggplot2::is.theme(e1))  ggplot2:::add_theme(e1, e2, e2name)
    else if (ggplot2::is.ggplot(e1)) ggplot2:::add_ggplot(e1, e2, e2name)
    else if (is.ggghost(e1)) structure(append(e1, match.call()[[3]]), class = c("ggghost", "gg"))
}

# #' @importFrom ggplot2 add_theme, add_ggplot

#' @importFrom ggplot2 is.theme is.ggplot
#' @export
"-.ggghost" <- function(e1, e2) {
    if      (ggplot2::is.theme(e1))  stop("not implemented for ggplot2 themes")
    else if (ggplot2::is.ggplot(e1)) stop("not implemented for ggplot2 plots")
    else if (is.ggghost(e1)) { 
        call_to_remove <- match.call()[[3]]
        if (!grepl(sub("\\(.*$", "", call_to_remove), as.character(summary(e1, combine = TRUE)))) {
            warning("ggghostbuster: can't find that call in the call list")
            return(e1)
        } else if (sub("\\(.*$", "", call_to_remove) == "ggplot") {
            warning("ggghostbuster: can't remove the ggplot call itself")
            return(e1)
        }
        structure(unclass(e1)[-grep(sub("\\(.*$", "", call_to_remove), unclass(e1))], class = c("ggghost", "gg"))
    }
}

#' @export
print.ggghost <- function(x, ...) {
    print(eval(parse(text = paste(x, collapse = " + "))))
}


#' @export
summary.ggghost <- function(object, ...) {
    # dots <- list(...)
    dots <- eval(substitute(alist(...)))
    combine = "combine" %in% names(dots)
    if (combine) 
        paste(object, collapse = " + ") 
    else 
        print(utils::head(object, n = length(object)))
}

#' @export
subset.ggghost <- function(x, ...) {
    structure(unclass(x)[...], class = c("ggghost", "gg"))
}

#' @importFrom animation ani.options saveGIF
#' @export
reanimate <- function(call_list, gifname = "ggghost.gif", interval = 1, ani.width = 600, ani.height = 600) {
    stopifnot(length(call_list) > 1)
    animation::ani.options(interval = interval, ani.width = ani.width, ani.height = ani.height)
    animation::saveGIF({
        ggtmp <- call_list[[1]]
        print(eval(ggtmp))
        for (i in 2:length(call_list)) {
            ggtmp <- eval(ggtmp) + eval(call_list[[i]])
            print(ggtmp)
        }
    }, movie.name = gifname)
}

#' @export
lazarus <- reanimate
