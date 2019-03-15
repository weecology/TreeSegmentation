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
  chm <- grid_canopy(las, res = res, pitfree(c(0,2,5,10,15), c(0, 1.5)))
  return(chm)
}
