.onAttach <- function(...) {
#   note <- "
# The message about masking + that follows occurs because I need to 
# avoid conflicts with ggplot2's + operator.
# Rest assured that I have not altered the default behaviour of +.
# You can check the code to confirm this."
#   packageStartupMessage(paste(strwrap(note), collapse = "\n"))
}