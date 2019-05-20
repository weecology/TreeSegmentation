## Detection network training
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(dplyr)
library(stringr)
library(raster)
library(batchtools)

#metadata
testing=F
site="TEAK"
year="2018"
basedir = "/orange/ewhite/NeonData/"

#Batchtools tmp registry
reg = makeRegistry(file.dir = NA, seed = 1)
print(reg)
print("registry created")

#Define optimal parameters
silva_params<-data.frame(Site=c("SJER","TEAK","NIWO"),max_cr_factor=c(0.9,0.2,0.2),exclusion=c(0.3,0.5,0.5))
site_params<-silva_params[silva_params$Site == site,]

#Define testing function
run_detection<-function(lidar_file, site){

  #check if tile can be processed
  rgb_path<-convert_names(from="lidar",to="rgb",lidar=lidar_file,site=site)

  flag<-rgb_path %in% rgb_files

  if(!flag){
    print(paste(lidar_file,"Failed Tile Check, can't be read"))
    return("Failed Tile Check - does not exist")
  }
  #check file are almost all edge black.
  try(r<-raster(paste(rgb_dir,rgb_path,sep="/")))

  if(!exists("r")){
    print(paste(lidar_file,"Failed Tile Check, can't be read"))
    return("Failed RGB Tile Check, can't be read")
  }

  #check if its black
  if(sum(getValues(r)==0)/length(r) > 0.4){
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

#Quick debug option
if(testing){
  path<-"../data/NeonTreeEvaluation/TEAK/plots/TEAK_044.laz"
  system.time(results<-detection_training(path,site,year,site_params$max_cr_factor,site_params$exclusion))
 } else {

  #Lidar dir
  lidar_dir<-paste(basedir,site,"/DP1.30003.001/2018/FullSite/D17/2018_",site,"_3/L1/DiscreteLidar/ClassifiedPointCloud",sep="")
  lidar_files<-list.files(lidar_dir,full.names = T,pattern=".laz")
  #lidar_files<-lidar_files[!str_detect(lidar_files,"colorized")]

  rgb_dir<-paste(basedir,site,"/DP3.30010.001/2018/FullSite/D17/2018_",site,"_3/L3/Camera/Mosaic/V01/",sep="")
  rgb_files<-list.files(rgb_dir,pattern=".tif")

  #batchtools submission
  reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 1, fs.latency = 65)

  #map each file to a new job
  batchMap(fun = run_detection,lidar_file=lidar_files,site=rep(site,length(lidar_files)))
  submitJobs(resources = list(walltime = 432000, memory = 10240))
  print(getJobTable())
 }
