library(doSNOW)
library(foreach)

#Testing flag
testing<-FALSE

if(testing){
  generate_training(lidar = "../data/training/NEON_D03_OSBS_DP1_398000_3280000_classified_point_cloud.laz" ,algorithm = c("silva"),expand=2)
  #generate_training(lidar = "../data/2017/Lidar/OSBS_006.laz" ,algorithm = c("silva"),expand=2)
} else{

  #lidar data dir
  lidar_dir<-"/orange/ewhite/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/"
  rgb_dir<-"/orange/ewhite/b.weinstein/NEON/D03/OSBS/DP1.30010.001/2017/FullSite/D03/2017_OSBS_3/L3/Camera/Mosaic/V01/"
  itcs_path<-"/orange/ewhite/b.weinstein/ITC"
  lidar_files<-list.files(lidar_dir,full.names = T,pattern=".laz")

  cl<-makeCluster(15)
  registerDoSNOW(cl)

  results<-foreach::foreach(x=1:length(lidar_files),.packages=c("TreeSegmentation")) %dopar%{

    #check if tile can be processed
    flag<-check_tile(itcs_path=itcs_path,lidar_path = lidar_files[[x]],rgb_dir=rgb_dir)

    if(flag){
      generate_training(lidar = lidar_files[[x]] ,algorithm = c("silva"),expand=2)
        } else{
          return("Failed check_tile")
        }
  }
}
