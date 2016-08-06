#' Begin constructing a cache
#'
#' @param lhs LHS of call
#' @param rhs RHS of call
#'
#' @return NULL
#' 
#' @export
`%g<%` <- function(lhs, rhs) {
    match     <- match.call()
    match_lhs <- match[[2]]
    match_rhs <- match[[3]]
    
    parent <- parent.frame()
    
    new_obj <- structure(list(as.call(match_rhs)), class = c("ggghost", "gg"))
    data_name <- eval(parse(text = sub("ggplot[^(]*", "identify_data", deparse(summary(new_obj)[[1]]))))
    attr(new_obj, "data") <- list(data_name = data_name,
                                  data      = get(data_name, envir = parent))

    assign(as.character(match_lhs), new_obj, envir = parent)
    
    return(invisible(NULL))
}


#' @export
identify_data <- function(data, mapping = ggplot2::aes(), ..., environment = parent.frame()) {
    match <- match.call()
    data_name <- match[["data"]]
    if (is.null(data_name)) stop("could not identify data from call.")
    return(as.character(data_name))
}


#' @export
is.ggghost <- function(x) inherits(x, "ggghost")

#' @importFrom ggplot2 is.theme is.ggplot
#' @export
"+.gg" <- function(e1, e2) {
    # Get the name of what was passed in as e2, and pass along so that it
    # can be displayed in error messages
    e2name <- deparse(substitute(e2))
    
    if      (ggplot2::is.theme(e1))  return(ggplot2:::add_theme(e1, e2, e2name))
    else if (ggplot2::is.ggplot(e1)) return(ggplot2:::add_ggplot(e1, e2, e2name))
    else if (is.ggghost(e1)) {
        new_obj <- structure(append(e1, match.call()[[3]]), class = c("ggghost", "gg"))
        attr(new_obj, "data") <- attr(e1, "data")
        return(new_obj)
    }
}

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
        new_obj <- structure(unclass(e1)[-grep(sub("\\(.*$", "", call_to_remove), unclass(e1))], class = c("ggghost", "gg"))
        attr(new_obj, "data") <- attr(e1, "data")
        return(new_obj)
    }
}


#' @export
print.ggghost <- function(x, ...) {
    recover_data(x)
    plotdata <- eval(parse(text = paste(x, collapse = " + ")))
    print(plotdata)
    return(invisible(plotdata))
}


# @export
# grob <- function(object) {
#     stopifnot(inherits(object, "ggghost"))
#     recover_data(x)
#     return(print(eval(parse(text = paste(x, collapse = " + ")))))
# }

#' @export
summary.ggghost <- function(object, ...) {
    dots <- eval(substitute(alist(...)))
    combine = "combine" %in% names(dots)
    if (combine) 
        return(paste(object, collapse = " + "))
    else 
        return(utils::head(object, n = length(object)))
}


#' @export
subset.ggghost <- function(x, ...) {
    new_obj <- structure(unclass(x)[...], class = c("ggghost", "gg"))
    attr(new_obj, "data") <- attr(x, "data")
    return(new_obj)
}


#' @importFrom animation ani.options saveGIF
#' @export
reanimate <- function(call_list, gifname = "ggghost.gif", interval = 1, ani.width = 600, ani.height = 600) {
    stopifnot(length(call_list) > 1)
    animation::ani.options(interval = interval, ani.width = ani.width, ani.height = ani.height)
    animation::saveGIF({
        recover_data(call_list)
        ggtmp <- call_list[[1]]
        print(eval(ggtmp))
        for (i in 2:length(call_list)) {
            ggtmp <- eval(ggtmp) + eval(call_list[[i]])
            print(ggtmp)
        }
    }, movie.name = gifname)
    return(invisible(TRUE))
}


#' @export
lazarus <- reanimate


#' @export
recover_data <- function(x) {
    parent <- parent.frame()
    assign(attr(x, "data")$data_name, attr(x, "data")$data, envir = parent)
    return(invisible(NULL))
}