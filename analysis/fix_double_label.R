library(lidR)
library(data.table)
laz_files<-list.files("/Users/Ben/Documents/NeonTreeEvaluation/evaluation/LiDAR/",pattern=".laz",full.names = T)
for(laz in laz_files){
  r<-readLAS(laz)
  if("label" %in% colnames(r@data)){
    print(laz)
    r@data[,"label":=NULL]
    r@header@VLR<-list()
    writeLAS(r,laz)
  }
}

path<-"/Users/Ben/Documents/NeonTreeEvaluation/evaluation/LiDAR/TEAK_062.laz"
r<-readLAS(path)
r<-lasfilter(r,Z > 1)
plot(r,color="label")
