#' Begin constructing a ggghost cache
#' 
#' The data and initial \code{ggpot()} call are stored as a list (call) with 
#' attribute (data).
#' 
#' @details The data must be passed into the \code{ggplot} call directly. 
#'   Passing this in via a magrittr pipe remains as a future improvement. The
#'   newly created \code{ggghost} object is a list of length 1 containing the 
#'   \code{ggplot} call, with attribute \code{data}; another list, containing
#'   the \code{data_name} and \code{data} itself.
#'   
#' @param lhs LHS of call
#' @param rhs RHS of call
#'   
#' @return Assigns the \code{ggghost} structure to the \code{lhs} symbol.
#'   
#' @export
#' @examples
#' ## create a ggghost object
#' tmpdata <- data.frame(x = 1:100, y = rnorm(100))
#' 
#' z %g<% ggplot(tmpdata, aes(x,y))
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


#' Identify the data passed to ggplot
#' 
#' Duplicate arguments to ggplot2::ggplot with the intent that the \code{data}
#' argument can be captured and identified.
#' 
#' @inheritParams ggplot2::ggplot
#'   
#' @return Name of the \code{data.frame} passed to \code{ggplot}
#' 
#' @keywords internal
identify_data <- function(data, mapping = ggplot2::aes(), ..., environment = parent.frame()) {
    match <- match.call()
    data_name <- match[["data"]]
    if (is.null(data_name)) stop("could not identify data from call.")
    return(as.character(data_name))
}


#' Reports whether x is a ggghost object
#'
#' @param x An object to test
#'
#' @return logical; \code{TRUE} if \code{x} inherits class \code{ggghost}
#' @export
is.ggghost <- function(x) inherits(x, "ggghost")

# @TODO check compatibility with dev ggplot2
# @BODY urgent, since ggplot2 uodate will be released soon.
#' Add a New ggplot Component to a ggghost Object
#'
#' This operator allows you to add objects to a ggghost object in the style of @hrbrmstr.
#'
#' @param e1 An object of class \code{ggghost}
#' @param e2 A component to add to \code{e1}
#'
#' @return Appends the \code{e2} call to the \code{ggghost} structure
#' @rdname plus-ggghost
#' 
#' @importFrom ggplot2 is.theme is.ggplot %+%
#' @export
#' 
#' @examples
#' #' ## create a ggghost object
#' tmpdata <- data.frame(x = 1:100, y = rnorm(100))
#' 
#' z %g<% ggplot(tmpdata, aes(x,y))
#' z <- z + geom_point(col = "steelblue")
#' z <- z + theme_bw()
#' z <- z + labs(title = "My cool ggplot")
#' z <- z + labs(x = "x axis", y = "y axis")
#' z <- z + geom_smooth()
"+.gg" <- function(e1, e2) {
    if (is.ggghost(e1)) {
        new_obj <- structure(append(e1, match.call()[[3]]), class = c("ggghost", "gg"))
        attr(new_obj, "data") <- attr(e1, "data")
        if (!is.null(attr(e1, "suppdata"))) {
            attr(new_obj, "suppdata") <- attr(e1, "suppdata")
        }
        return(new_obj) 
    } else {
        return(e1 %+% e2)
    }
}


#' Remove a call from a ggghost object
#' 
#' Calls can be removed from the \code{ggghost} object via regex matching of the
#' function name. All matching calls will be removed based on the match to the 
#' string up to the first bracket, so any arguments are irrelevant.
#' 
#' For example, subtracting \code{geom_line()} will remove all calls matching 
#' \code{geom_line} regardless of their arguments.
#' 
#' `labs()` has been identified as a special case, as it requires an argument in
#' order to be recognised as a valid function. Thus, trying to remove it with an
#' empty argument will fail. That said, the argument doesn't need to match, so 
#' it can be populated with a dummy string or anything that evaluates in scope.
#' See examples.
#' 
#' @param e1 An object of class \code{ggghost}
#' @param e2 A component to remove from \code{e1}
#'   
#' @return A \code{ggghost} structure with calls matching \code{e2} removed, 
#'   otherwise the same as \code{e1}
#' 
#' @rdname minus-ggghost
#' @export
#' 
#' @examples
#' ## create a ggghost object
#' tmpdata <- data.frame(x = 1:100, y = rnorm(100))
#' 
#' z %g<% ggplot(tmpdata, aes(x,y))
#' z <- z + geom_point(col = "steelblue")
#' z <- z + theme_bw()
#' z <- z + labs(title = "My cool ggplot")
#' z <- z + labs(x = "x axis", y = "y axis")
#' z <- z + geom_smooth()
#' 
#' ## remove the geom_smooth
#' z - geom_smooth()
#' 
#' ## remove the labels
#' ## NOTE: argument must be present and able to be 
#' ## evaluated in scope
#' z - labs(TRUE) # works
#' z - labs(title) # works because of title(), but removes all labs()
"-.gg" <- function(e1, e2) {
    if      (ggplot2::is.theme(e1))  stop("not implemented for ggplot2 themes")
    else if (ggplot2::is.ggplot(e1)) stop("not implemented for ggplot2 plots")
    else if (is.ggghost(e1)) { 
        call_to_remove <- match.call()[[3]]
        if (!any(grepl(sub("\\(.*$", "", call_to_remove)[1], as.character(summary(e1, combine = TRUE))))) {
            warning("ggghostbuster: can't find that call in the call list", call. = FALSE)
            return(e1)
        } else if (sub("\\(.*$", "", call_to_remove)[1] == "ggplot") {
            warning("ggghostbuster: can't remove the ggplot call itself", call. = FALSE)
            return(e1)
        }
        new_obj <- structure(unclass(e1)[-grep(sub("\\(.*$", "", call_to_remove)[1], unclass(e1))], class = c("ggghost", "gg"))
        attr(new_obj, "data") <- attr(e1, "data")
        if (!is.null(attr(e1, "suppdata"))) {
            attr(new_obj, "suppdata") <- attr(e1, "suppdata")
        }
        return(new_obj)
    }
}


#' Collect ggghost calls and produce the ggplot output
#'
#' @param x A ggghost object to be made into a ggplot grob
#' @param ... Not used, provided for \code{print.default} generic consistency.
#'
#' @return The ggplot plot data (invisibly). Used for the side-effect of producing a ggplot plot.
#' @export
print.ggghost <- function(x, ...) {
    recover_data(x, supp = TRUE)
    plotdata <- eval(parse(text = paste(x, collapse = " + ")))
    print(plotdata)
    return(invisible(plotdata))
}


#' List the calls contained in a ggghost object
#' 
#' Summarises a ggghost object by presenting the contained calls in the order 
#' they were added. Optionally concatenates these into a single ggplot call.
#' 
#' @details The data is also included in ggghost objects. If this is also
#'   desired in the output, use \code{str}. See example.
#'   
#' @param object A ggghost object to present
#' @param ... Mainly provided for \code{summary.default} generic consistency. 
#'   When \code{combine} is passed as an argument (arbitrary value) the list of 
#'   calls is concatenated into a single string as one might write the ggplot 
#'   call.
#'   
#' @return Either a list of ggplot calls or a string of such concatenated with " + "
#' @export
#' 
#' @examples
#' ## present the ggghost object as a list
#' tmpdata <- data.frame(x = 1:100, y = rnorm(100))
#' 
#' z %g<% ggplot(tmpdata, aes(x,y))
#' z <- z + geom_point(col = "steelblue")
#' summary(z)
#' 
#' ## present the ggghost object as a string
#' summary(z, combine = TRUE) # Note, value of 'combine' is arbitrary
#' 
#' ## to inspect the data structure also captured, use str()
#' str(z)
summary.ggghost <- function(object, ...) {
    dots <- eval(substitute(alist(...)))
    combine = "combine" %in% names(dots)
    if (combine) 
        return(paste(object, collapse = " + "))
    else 
        return(utils::head(object, n = length(object)))
}


#' Extract a subset of a ggghost object
#' 
#' Alternative to subtracting calls using `-.gg`, this method allows one to 
#' select the desired components of the available calls and have those
#' evaluated.
#' 
#' @param x A ggghost object to subset
#' @param ... A logical expression indicating which elements to select.
#'   Typically a vector of list numbers, but potentially a vector of logicals or
#'   logical expressions.
#'   
#' @return Another ggghost object containing only the calls selected.
#' @export
#' 
#' @examples
#' ## create a ggghost object
#' tmpdata <- data.frame(x = 1:100, y = rnorm(100))
#' 
#' z %g<% ggplot(tmpdata, aes(x,y))
#' z <- z + geom_point(col = "steelblue")
#' z <- z + theme_bw()
#' z <- z + labs(title = "My cool ggplot")
#' z <- z + labs(x = "x axis", y = "y axis")
#' z <- z + geom_smooth()
#' 
#' ## remove the labels and theme
#' subset(z, c(1,2,6))
#' ## or
#' subset(z, c(TRUE,TRUE,FALSE,FALSE,FALSE,TRUE))
subset.ggghost <- function(x, ...) {
    new_obj <- structure(unclass(x)[...], class = c("ggghost", "gg"))
    attr(new_obj, "data") <- attr(x, "data")
    if (!is.null(attr(x, "suppdata"))) {
        attr(new_obj, "suppdata") <- attr(x, "suppdata")
    }
    return(new_obj)
}


#' Bring a ggplot to life (re-animate)
#' 
#' Creates an animation showing the stepwise process of building up a ggplot.
#' Successively adds calls from a ggghost object and then combines these into an
#' animated GIF.
#' 
#' @param object A ggghost object to animate
#' @param gifname Output filename to save the .gif to (not including any path,
#'   will be saved to current directory)
#' @param interval A positive number to set the time interval of the animation
#'   (unit in seconds); see \code{animation::ani.options}
#' @param ani.width width of image frames (unit in px); see
#'   \code{animation::ani.options}
#' @param ani.height height of image frames (unit in px); see
#'   \code{animation::ani.options}
#'   
#' @return \code{TRUE} if it gets that far
#'   
#' @importFrom animation ani.options saveGIF
#' @export
#' @rdname reanimate
#'   
#' @examples
#' \dontrun{
#' ## create an animation showing the process of building up a plot
#' reanimate(z, "mycoolplot.gif")
#' }
reanimate <- function(object, gifname = "ggghost.gif", interval = 1, ani.width = 600, ani.height = 600) {
    stopifnot(length(object) > 1)
    animation::ani.options(interval = interval, ani.width = ani.width, ani.height = ani.height)
    animation::saveGIF({
        recover_data(object, supp = TRUE)
        ggtmp <- object[[1]]
        print(eval(ggtmp))
        for (i in 2:length(object)) {
            ggtmp <- eval(ggtmp) + eval(object[[i]])
            print(ggtmp)
        }
    }, movie.name = gifname)
    return(invisible(TRUE))
}


#' @export
#' @rdname reanimate
lazarus <- reanimate


#' Recover data Stored in a ggghost object
#' 
#' The data used to generate a plot is an essential requirement for a 
#' reproducible graphic. This is somewhat available from a ggplot \code{grob} 
#' (in raw form) but it it not easily accessible, and isn't named the same way 
#' as the original call.
#' 
#' This function retrieves the data from the ggghost object as it was when it 
#' was originally called.
#' 
#' If supplementary data has also been attached using \code{\link{supp_data}} 
#' then this will also be recovered (if requested).
#' 
#' When used iteractively, a warning will be produced if the data to be
#' extracted exists in the workspace but not identical to the captured version.
#' 
#' @param x A ggghost object from which to extract the data.
#' @param supp (logical) Should the supplementary data be extracted also?
#'   
#' @return A \code{data.frame} of the original data, named as it was when used 
#'   in \code{ggplot(data)}
#' @export
recover_data <- function(x, supp = TRUE) {
    
    ## create a local copy of the data
    y <- yname <- attr(x, "data")$data_name
    assign(y, attr(x, "data")$data, envir = environment())
    
    ## if the data exists in the calling frame, but has changed since
    ## being saved to the ggghost object, produce a warning (but do it anyway)
    parent <- parent.frame()
    optout_data <- ""
    if (exists(y, where = parent)) {
        if (!identical(get(y, envir = environment()), get(y, envir = parent))) {
            warning(paste0("Potentially overwriting object ", yname, " in working space, but object has changed"), call. = FALSE, immediate. = TRUE)
            ## this should really be ggghost::in_the_shell as per @hrbrmstr's suggestion
            if (interactive()) {
                optout_data <- readline("Press 'n' to opt out of overwriting ")
            }
        } 
    }
    
    if (optout_data != "n") assign(yname, attr(x, "data")$data, envir = parent)
    
    if (supp) {
        
        optout_supp_data <- ""
        supp_list <- supp_data(x)
        if (length(supp_list) > 0) {
            if (exists(supp_list[[1]], where = parent)) {
                if (!identical(supp_list[[2]], get(supp_list[[1]], envir = parent))) {
                    warning(paste0("Potentially overwriting object ", supp_list[[1]], " in working space, but object has changed"), call. = FALSE, immediate. = TRUE)
                    if (interactive()) {
                        optout_supp_data <- readline("Press 'n' to opt out of overwriting ")
                    }   
                }
            }
        if (optout_supp_data != "n") assign(supp_list[[1]], supp_list[[2]], envir = parent)
        }
    }
    
    return(invisible(NULL))
}


#' Inspect the supplementary data attached to a ggghost object
#' 
#' @param x A ggghost object
#'   
#' @return A list with two elements: the name of the supplementary data, and the
#'   supplementary data itself
#'   
#' @export
supp_data <- function(x) {
    
    value <- attr(x, "suppdata")
    # if (length(value) == 0 & interactive()) warning("ggghostbuster: no supplementary data found", call. = FALSE)
    
    return(value)
    
}

#' Attach supplementary data to a ggghost object
#' 
#' @param x A ggghost object to which the supplementary data should be
#'   attached
#' @param value Supplementary data to attach to the ggghost object, probably
#'   used as an additional data input to a \code{scale_*}  or \code{geom_*} call
#'   
#' @return The original object with \code{suppdata} attribute
#' 
#' @export
"supp_data<-" <- function(x, value) {
    
    if (is.ggghost(x)) {
        
        if (length(attr(x, "suppdata")) > 0) {
            warning("ggghostbuster: can't assign more than one supplementary data set to a ggghost object.", call. = FALSE)
            return(x)
        }
        
        attr(x, "suppdata") <- list(supp_data_name = as.character(substitute(value)), 
                                    supp_data      = value)
        
    } else {
        stop("attempt to attach supplementary data to a non-ggghost object")
    }
    
    return(x)
}
