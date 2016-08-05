.onAttach <- function(...) {
  AttachNote <- "
Please be aware: this development package has the potential to mess with your ggplot2 calls.
If you find a bug, please let me know: https://github.com/jonocarroll/ggghost/issues
"
  packageStartupMessage(paste(strwrap(AttachNote), collapse = "\n"))
}