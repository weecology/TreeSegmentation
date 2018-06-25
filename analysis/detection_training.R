## Detection network training
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(dplyr)

testing=F

if(testing){
  #path<-"../data/2017/Lidar/OSBS_006.laz"
  path<-"../data/training/NEON_D03_OSBS_DP1_407000_3291000_classified_point_cloud.laz"
  detection_training(path)
 } else{

  #lidar data dir
  lidar_dir<-"/orange/ewhite/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/"
  rgb_dir<-"/orange/ewhite/b.weinstein/NEON/D03/OSBS/DP1.30010.001/2017/FullSite/D03/2017_OSBS_3/L3/Camera/Mosaic/V01/"
  itcs_path<-"/orange/ewhite/b.weinstein/ITC"
  lidar_files<-list.files(lidar_dir,full.names = T,pattern=".laz")

  cl<-makeCluster(10)
  registerDoSNOW(cl)

  results<-foreach::foreach(x=1:length(lidar_files),.packages=c("TreeSegmentation")) %dopar%{

    #check if tile can be processed
    flag<-check_tile(itcs_path=itcs_path,lidar_path = lidar_files[x],rgb_dir=rgb_dir)

    if(flag){
      detection_training(path=lidar_files[x])
    } else{
      return("Failed check_tile")
    }
  }
 }
