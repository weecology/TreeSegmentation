library(doSNOW)
library(foreach)

#Local flags
#generate_training(lidar = "../data/2017/Lidar/OSBS_006.laz" ,algorithm = c("silva"))
generate_training(lidar = "../data/training/NEON_D03_OSBS_DP1_398000_3280000_classified_point_cloud.laz" ,algorithm = c("silva"))

#lidar data dir
lidar_dir<-"/orange/ewhite/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/"

cl<-makeCluster(15)
registerDoSNOW(cl)

results<-foreach::foreach(x=1:length(lidar_dir),.packages=c("TreeSegmentation")) %dopar%{
  flag<-check_tile(lidar_dir)

  if(flag){
    generate_training(lidar = "../data/training/NEON_D03_OSBS_DP1_398000_3280000_classified_point_cloud.laz" ,algorithm = c("silva"))
      } else{
        return("Failed check_tile")
      }
}
