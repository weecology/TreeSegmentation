#For each annotation make sure there are corresponding data
library(NeonTreeEvaluation)
library(stringr)
library(raster)
library(lidR)
f<-list.files("/Users/Ben/Documents/NeonTreeEvaluation/annotations/",full.names = T)
for(annotation_file in f){
  plot_name<-str_match(annotation_file,"(\\w+).xml")[,2]
  rgb<-get_data(plot_name,"rgb")
  tryCatch(
    {s<-raster::stack(rgb)},
    error = function(err){
    print(paste(plot_name,"missing RGB"))}
    )
  lidar<-get_data(plot_name,"lidar")
  
  tryCatch(
    {s<-readLAS(lidar)},
    error = function(err){
      print(paste(plot_name,"missing lidar"))}
  )
  hyperspectral<-get_data(plot_name,"hyperspectral")
  
  tryCatch(
    {s<-raster::stack(hyperspectral)},
    error = function(err){
      print(paste(plot_name,"missing hyperspectral"))}
  )
}
  