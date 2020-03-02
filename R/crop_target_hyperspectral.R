#' Clip Hyperspectral Data Based on extent of RGB file
#'
#' @param siteID NEON site abbreviation (e.g. "HARV")
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @export
#'
crop_target_hyperspectral<-function(siteID="TEAK",rgb_filename,geo_index,false_color=FALSE, year="2019",h5_base_dir="/orange/ewhite/NeonData",save_base_dir="/orange/ewhite/b.weinstein/NEON"){

  #Hyperspectral dir
  h5_dir<-paste(h5_base_dir,siteID,"DP3.30006.001",year,sep="/")
  h5_files<-list.files(h5_dir,recursive = TRUE,full.names = T, pattern="*.h5")

  #Find corresponding h5 tile
  h5_path<-h5_files[stringr::str_detect(h5_files,geo_index)]

  save_dir<-paste(save_base_dir,siteID,year,"NEONPlots/Hyperspectral/L3/",sep="/")
  if(!dir.exists(save_dir)){
    dir.create(save_dir,recursive=T)
  }

  #Clip in python!
  reticulate::use_condaenv("NEON",required=TRUE)
  reticulate::source_python("generate_h5_raster.py")
  status <-run(rgb_filename=rgb_filename,
               h5_path=h5_path,
               save_dir=save_dir,
               false_color=false_color)

  return(status)
}

