#' Clip CHM Data Based on extent of RGB file
#'
#' @param rgb_filename path to a projected file to extract coordinates
#' @param year year to match in CHM files
#' @param tif_base_dir where to search for CHM files
#' @param save_dir base path to save cropped files
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @export
#'
crop_target_CHM<-function(siteID="TEAK",rgb_filename,year="2019",tif_base_dir="/orange/ewhite/NeonData",save_base_dir="/orange/ewhite/b.weinstein/NEON"){

  #Hyperspectral dir
  tif_dir<-paste(tif_base_dir,siteID,"DP3.30015.001",year,sep="/")
  chm_files<-list.files(tif_dir,recursive = TRUE,full.names = T, pattern="*CHM.tif")

  #find extent and geoindex
  ext <- raster::extent(raster::raster(rgb_filename))
  easting <- as.integer(ext@xmin/1000)*1000
  northing <- as.integer(ext@ymin/1000)*1000
  geo_index <- paste(easting,northing,sep="_")

  #Find corresponding h5 tile
  tif_path<-chm_files[stringr::str_detect(chm_files,geo_index)]

  save_dir<-paste(save_base_dir,siteID,year,"NEONPlots/CHM/target/",sep="/")
  if(!dir.exists(save_dir)){
    dir.create(save_dir,recursive=T)
  }

  #Clip
  CHM<-raster::raster(tif_path)
  cropped_CHM<-raster::crop(CHM,ext)

  #filename
  basename <- stringr::str_match(rgb_filename,"/(\\w+).tif")[,2]
  fname <- paste(basename,"_CHM.tif",sep="")
  full_fname<-paste(save_dir,fname,sep="/")
  raster::writeRaster(cropped_CHM,full_fname,datatype='INT1U',overwrite=T)

  return(full_fname)
}

