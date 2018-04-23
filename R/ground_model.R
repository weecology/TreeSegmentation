#' Generate a ground model from raw las
#'
#' \code{ground_model} computes a ground model and normalizes the input point cloud such that ground points are at zero elevation
#' @param las A lidar cloud read in by lidR package
#' @return NA. By default operation is done in place to reduce memory.
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0"
#' ground_model(tile)
#' @export
ground_model<-function(las){
  ws = seq(3,21, 3)
  th = seq(0.1, 6, length.out = length(ws))

  lidR::lasground(las, "pmf", ws, th)

  # normalization
  lidR::lasnormalize(las, method = "kriging", k = 10L, model = gstat::vgm(0.59, "Sph", 874))
}
