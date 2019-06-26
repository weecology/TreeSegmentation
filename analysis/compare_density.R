library(lidR)
library(reshape2)
library(dplyr)
library(ggplot2)

samps<-list.files("/Users/ben/Documents/DeepLidar/data/SJER/plots/",pattern=".laz",full.names=T)

dens_plots<-c()
for(x in samps){
  r<-readLAS(x)
  dens_plots[x]<-nrow(r@data)/area(r)
}

mean(dens_plots)

samps<-list.files("/Users/ben/Desktop/new",pattern=".laz",full.names=T)

dens_samp<-c()
for(x in samps){
  r<-readLAS(x)
  dens_samp[x]<-nrow(r@data)/area(r)
}
mean(dens_samp)
