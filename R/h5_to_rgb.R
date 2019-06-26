# Create a three band RGB raster object from h5 data
#' \code{h5_to_rgb} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree. It then writes the resulting files in h5 format for machine learning input
#' @inheritParams band2Raster
#' @param file_path Character. path to h5 file.
#' @param bands List Bands to combine into stack
#' @param outpath Character. fullpath to write RGB path.
#' @return returns: a RGB raster stack
#' @export
#'
h5_to_rgb<-function(file_path,write=F,outpath=NULL,bands=list(58,34,19)){

  #r get spatial info and map info using the  h5readAttributes function

  #define coordinate reference system
  #myCrs <- spInfo$projdef
  #define the resolution
  #res <- spInfo$xscale
  f <- hdf5r::H5File$new(file_path, mode = "r")
  site<-names(f)
  mapInfo<-f[[site]][["Reflectance"]][["Metadata"]][["Coordinate_System"]][["Map_Info"]]$read()

  #the map info string contains the lower left hand coordinates of our raster
  #let's grab those next
  # split out the individual components of the mapinfo string
  mapInfo<-unlist(strsplit(mapInfo, ","))

  #grab the utm coordinates of the lower left corner
  xMin<-as.numeric(mapInfo[4])
  yMax<-as.numeric(mapInfo[5])

  #r get attributes for the Reflectance dataset
  reflInfo <- h5readAttributes(file_path,"Reflectance")

  #create objects represents the dimensions of the Reflectance dataset
  #note that there are several ways to access the size of the raster contained
  #within the H5 file
  nRows <- reflInfo$row_col_band[1]
  nCols <- reflInfo$row_col_band[2]
  nBands <- reflInfo$row_col_band[3]

  #grab the no data value
  myNoDataValue <- reflInfo$`data ignore value`

  rgb <- bands
  rgb_rast <- lapply(rgb,band2Raster, file = file_path,
                     noDataValue=myNoDataValue,
                     xMin=xMin, yMin=yMin, res=1,
                     crs=myCrs)
  hsiStack <- raster::stack(rgb_rast)
  bandNames <- paste("Band_",unlist(rgb),sep="")

  names(hsiStack) <- bandNames

  if(write){
    raster::writeRaster(hsiStack, file=outpath, format="GTiff", overwrite=TRUE)
  }

}
