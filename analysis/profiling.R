#Profiling
library(lineprof)

## Detection network training
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(dplyr)
#path<-"../data/training/NEON_D03_OSBS_DP1_407000_3291000_classified_point_cloud.laz"
path<-"../data/2017/Lidar/OSBS_006.laz"

l <- lineprof(detection_training(path,expand=2,res=1,threshold = 15))

shine(l)
