# Read a .h5 tile and convert a band to a raster object
#'
#' \code{band2Raster} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree. It then writes the resulting files in h5 format for machine learning input
#' @param file: the hdf file
#' @param band: the band you want to process
#' @return returns: a matrix containing the reflectance data for the specific band
#' @export
#'
band2Raster <- function(file, band, noDataValue, xMin, yMin, res, crs){
  #first read in the raster
  out<- h5read(file,"Reflectance",index=list(1:nCols,1:nRows,band))
  #Convert from array to matrix
  out <- (out[,,1])
  #transpose data to fix flipped row and column order
  #depending upon how your data are formated you might not have to perform this
  #step.
  out <-t(out)
  #assign data ignore values to NA
  #note, you might chose to assign values of 15000 to NA
  out[out == myNoDataValue] <- NA

  #turn the out object into a raster
  outr <- raster(out,crs=myCrs)

  # define the extents for the raster
  #note that you need to multiple the size of the raster by the resolution
  #(the size of each pixel) in order for this to work properly
  xMax <- xMin + (outr@ncols * res)
  yMin <- yMax - (outr@nrows * res)

  #create extents class
  rasExt  <- extent(xMin,xMax,yMin,yMax)

  #assign the extents to the raster
  extent(outr) <- rasExt

  #return the raster object
  return(outr)
}
