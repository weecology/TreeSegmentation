#' Run detection training for a tile in a site
#'
#' \code{run_detection} is a wrapper for detection_training for checking a file exists and optionally overwriting
#' @param site Four letter NEON abbreviation
#' @param lidar_file Character. path to lidar file
#' @param rgb_dir Character. Directory of rgb files to check
#' @return NULL; CSV files written to file
#' @export

#Define testing function
run_detection<-function(lidar_file, site, rgb_dir){

  #check if tile can be processed
  rgb_files<-list.files(rgb_dir,pattern=".tif")
  rgb_path<-convert_names(from="lidar",to="rgb",lidar=lidar_file,site=site)

  flag<-rgb_path %in% rgb_files

  if(!flag){
    print(paste(lidar_file,"Failed Tile Check, can't be read"))
    return("Failed Tile Check - does not exist")
  }
  #check file are almost all edge black.
  try(r<-raster::raster(paste(rgb_dir,rgb_path,sep="/")))

  if(!exists("r")){
    print(paste(lidar_file,"Failed Tile Check, can't be read"))
    return("Failed RGB Tile Check, can't be read")
  }

  #check if its black
  if(sum(raster::getValues(r)==0)/length(r) > 0.4){
    print(paste(lidar_file,"Failed Tile Check, mostly a blank black edge"))
    return("Failed Tile Check, mostly a blank black edge")
  }

  #Check if in output already
  sanitized_fn<-paste(stringr::str_match(string=lidar_file,pattern="(\\w+).laz")[,2],".csv",sep="")

  #check if exists
  filepath<-paste("Results/detection_boxes/",site,"/",year,"/",sep="")
  already_completed<-list.files(filepath)

  if(sanitized_fn %in% already_completed){
    return(paste(sanitized_fn, "already exists"))
  }

  #Passed checks
  print(paste(lidar_file,"Running"))
  time_ran<-system.time(detection_training(path=lidar_file,site=site,year,max_cr_factor=site_params$max_cr_factor,exclusion=site_params$exclusion))
  return(paste(lidar_file,"completed in",time_ran["elapsed"]/60,"minutes"))
}
