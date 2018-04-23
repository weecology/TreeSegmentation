#' Canopy model generation from normalized las
#'
#' \code{canopy_model} returns a canopy height raster from a lidR point cloud
#'
#'
#' @param las A lidar cloud read in by lidR package
#' @return A raster with the canopy height estimated for each grid cell.
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0"
#' chm=canopy_model(tile)
#'
canopy_model<-function(las){
  # compute a canopy image
  chm= grid_canopy (las, res=1, subcircle = 0.1, na.fill = "knnidw", k = 3, p = 2)
  chm = as.raster(chm)
  kernel = matrix(1,3,3)
  chm = raster::focal(chm, w = kernel, fun = mean)
  chm = raster::focal(chm, w = kernel, fun = mean)
  return(chm)
}
