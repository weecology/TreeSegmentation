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
    ws = seq(3,12, 3)
    th = seq(0.1, 1.5, length.out = length(ws))
    las<-lidR::lasground(las, pmf( ws, th))
    # normalization
    las<-lidR::lasnormalize(las, knnidw(k = 10 , p = 2))
  } else{
    dtm <- lidR::grid_terrain(las,res=1, algorithm = knnidw(k = 10 , p = 2))
    las <- lidR::lasnormalize(las, dtm)
  }

  return(las)
}
