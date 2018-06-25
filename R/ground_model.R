#' Generate a ground model from raw las
#'
#' \code{ground_model} computes a ground model and normalizes the input point cloud such that ground points are at zero elevation
#' @param las A lidar cloud read in by lidR package
#' @param ground Logical. Should a ground model be computed? Some tiles come pre-processed.
#' @return NA. By default operation is done in place to reduce memory.
#' @export
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0"
#' ground_model(tile)

ground_model<-function(las,ground=T){

  if(ground){
    ws = seq(3,21, 3)
    th = seq(0.1, 6, length.out = length(ws))
    lidR::lasground(las, "pmf", ws, th)
  }

  # normalization
  lidR::lasnormalize(las, method = "knnidw", k = 10L)
}
