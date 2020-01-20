  #Create depth images
  library(lidR)
  library(TreeSegmentation)
  library(NeonTreeEvaluation)
  library(RStoolbox)
  library(raster)
  library(sf)
  library(dplyr)

  plotID = "MLBS_063"
  save_path = "/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/"
  data_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/"

  decorrelation_stretch(pathr = paste( "/Users/Ben/Documents/NeonTreeEvaluation/evaluation/RGB/",plotID,".tif",sep=""),outdir = save_path)

  r<-readLAS(paste(data_path,"LiDAR/",plotID,".laz",sep=""))
  r<-ground_model(r,ground = FALSE)
  r<-lasfilter(r,Z<60)
  chm<-canopy_model(r)
  writeRaster(chm,paste(save_path,plotID,"_chm.tif",sep=""),datatype='INT1U',overwrite=T)

  #Hyperspec three band
  g<-stack(paste(data_path,"Hyperspectral/",plotID,"_hyperspectral.tif",sep=""))
  g<-g[[c(40,55,113)]]

  #trim quantile
  stretched<-stretch(g,maxq=0.95)
  plotRGB(stretched)
  writeRaster(stretched,paste(save_path,plotID,"_hyperspec.tif",sep=""),overwrite=T)

  a<-load_ground_truth(plotID)
  b<-st_as_sf(a)
  write_sf(b,paste("/Users/Ben/Dropbox/Weecology/Benchmark/ForStephanie/",plotID,"_Ben.shp",sep=""))

  dat<-st_read("/Users/Ben/Documents/NeonTreeEvaluation/field_data.csv", options=c("X_POSSIBLE_NAMES=easting","Y_POSSIBLE_NAMES=northing"))
  ID=plotID
  remove(plotID)
  dat<-dat %>% filter(plotID == ID)
  st_crs(dat)<-crs(r)
  plot(chm)
  plot(dat,add=T)
