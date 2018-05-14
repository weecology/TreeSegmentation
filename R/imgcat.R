#' Plot result in iTerm
#'
#' \code{imgcat} assigns each point in a lidR cloud to a treeID.
#' @param plot_command a plot function to be viewed in the terminal
#' @export
imgcat <- function(plot_command){

  fn <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")

  png(fn)

  eval(quote(plot_command))
  dev.off()
  system2("imgcat", fn)
}
