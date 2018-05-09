#' Generate training data from lidar tiles
#'
#' \code{generate_training} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree. It then writes the resulting files in h5 format for machine learning input
#' @inheritParams extract_trees
#' @return A nested list of lidR tiles equal to the length of path_to_tiles. Each list will have a list of segmented .las for each tree.
#' @export
#'
generate_training<-function(las=NULL,algorithm="silva",cores=NULL){

  ind_trees<-extract_trees(cores = cores,algorithm = algorithm,las=las)

}
