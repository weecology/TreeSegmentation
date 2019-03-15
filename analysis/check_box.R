library(raster)
library(dplyr)

path="/Users/ben/Documents/DeepForest/data/detection_OSBS_006.csv"
data<-read.csv(path)
a<-data %>% mutate(Cluster=Cluster-1) %>% filter(Cluster==2) %>% slice(1)
e<-extent(a$cluster_xmin,a$cluster_xmax,a$cluster_ymin,a$cluster_ymax)
r<-stack("/Users/ben/Documents/DeepForest/data/OSBS_006_ortho.tif")

plot(e,add=T,col='red')
rc<-crop(r,e)
plotRGB(rc)

#plot boxes
boxes<-data %>% mutate(Cluster=Cluster-1) %>% filter(Cluster==2)
for(i in 1:nrow(boxes)){
  e<-extent(boxes[i,]$xmin,boxes[i,]$xmax,boxes[i,]$ymin,boxes[i,]$ymax)
  plot(e,add=T,col='red')
}
