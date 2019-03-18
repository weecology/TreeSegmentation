## Detection network training
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(dplyr)
library(stringr)
library(raster)

testing=T
site="TEAK"
year="2018"

if(testing){
  path<-"../data/NeonTreeEvaluation/TEAK/training/NEON_D17_TEAK_DP1_315000_4091000_classified_point_cloud_colorized.laz"
  system.time(results<-detection_training(path,site,year))
 } else{

  #Lidar dir
  lidar_dir<-paste("/ufrc/ewhite/b.weinstein/NeonData/",site,"/DP1.30003.001/2018/FullSite/D17/2018_",site,"_3/L1/DiscreteLidar/ClassifiedPointCloud",sep="")
  lidar_files<-list.files(lidar_dir,full.names = T,pattern=".laz")
  #lidar_files<-lidar_files[!str_detect(lidar_files,"colorized")]

  rgb_dir<-paste("/ufrc/ewhite/b.weinstein/NeonData/",site,"/DP3.30010.001/2018/FullSite/D17/2018_",site,"_3/L3/Camera/Mosaic/V01/",sep="")
  rgb_files<-list.files(rgb_dir,pattern=".tif")

  cl<-makeCluster(10,outfile="")
  registerDoSNOW(cl)

  results<-foreach::foreach(x=1:length(lidar_files),.packages=c("TreeSegmentation","raster"),.errorhandling="pass") %dopar%{

    #check if tile can be processed
    rgb_path<-convert_names(from="lidar",to="rgb",lidar=lidar_files[x],site=site)

    flag<-rgb_path %in% rgb_files

    if(!flag){
      print(paste(lidar_files[x],"Failed Tile Check, can't be read"))
      return("Failed Tile Check - does not exist")
    }
    #check file are almost all edge black.
    try(r<-raster(paste(rgb_dir,rgb_path,sep="/")))

    if(!exists("r")){
      print(paste(lidar_files[x],"Failed Tile Check, can't be read"))
      return("Failed Tile Check, can't be read")
    }

    #check if its black
    if(sum(getValues(r)==0)/length(r) > 0.4){
      print(paste(lidar_files[x],"Failed Tile Check, mostly a blank black edge"))
      return("Failed Tile Check, mostly a blank black edge")
    }

    #Check if in output already
    sanitized_fn<-stringr::str_match(string=lidar_files[x],pattern="(\\w+).laz")[,2]

    #check if exists
    filepath<-paste("Results/detection_boxes/",site,"/",year,"/",sep="")
    already_completed<-list.files(filepath)

    if(sanitized_fn %in% already_completed){
      return(paste(sanitized_fn, "already exists"))
    }

    #Passed checks
    print(paste(lidar_files[x],"Running"))
    detection_training(path=lidar_files[x],site=site,year)
  }
 }

print(results)
