#' Canopy model generation from normalized las
#'
#' \code{canopy_model} returns a canopy height raster from a lidR point cloud
#'
#'
#' @param las A lidar cloud read in by lidR package
#' @return A raster with the canopy height estimated for each grid cell.
#' @examples
#' library(lidR)
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0")
#' chm=canopy_model(tile)
#' @export
canopy_model<-function(las,res=0.5){
  # compute a canopy image
  chm= lidR::grid_canopy(las, res=res, subcircle = 0.2, na.fill = "knnidw", k = 4,p=2)
  chm = raster::as.raster(chm)
  kernel = matrix(1,3,3)
  chm = raster::focal(chm, w = kernel, fun = mean)
  chm = raster::focal(chm, w = kernel, fun = mean)
  return(chm)
}
