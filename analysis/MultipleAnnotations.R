#Comparison script for multiple annotations
library(NeonTreeEvaluation)
library(raster)
library(lidR)
library(sf)
library(dplyr)

shapefile_to_annotation<-function(path, image_path){
  #Read shapefile
  shp<-sf::read_sf(path)

  #Extract bounds
  boxes<-lapply(shp$geometry,function(x) sf::st_bbox(x))
  boxes<-do.call(rbind,boxes)
  boxes<-as.data.frame(boxes)

  #grab label if present
  if ("label" %in% colnames(shp)){
    boxes$label<-shp$label
  } else {
    boxes$label<-"Tree"
  }

  boxes$plot_name<-stringr::str_match(image_path,"(\\w+)\\.")[,2]

  return(boxes)
}

matching_results<-function(submission,path_to_rgb,image_path,results, project_boxes=F, threshold=0.5){
  rgb<-stack(image_path)

  #Convert to spatial objects
  predictions<-boxes_to_spatial_polygons(submission,rgb,project_boxes=project_boxes)
  results<-results[results$IoU>threshold,]
  #
  ground_truth<-load_ground_truth(unique(submission$plot_name))

  #filter
  predictions<-predictions[predictions$crown_id %in% results$prediction_id,]
  ground_truth<-ground_truth[ground_truth$crown_id %in% results$crown_id,]

  #labels

    #plot
  plotRGB(rgb)
  plot(predictions,add=T,border="red")
  labels(results)
  plot(ground_truth,add=T)
}

matching_results(submission=aditya_annotation,
                 image_path ="/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_043.tif",results=aditya_results,threshold = 0.4)

#TALL_043
aditya_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/TALL_043_Crowns.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_043.tif")
aditya_results<-evaluate_benchmark(aditya_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(aditya_results)


a<-read_sf("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/TALL_043_Stephanie.shp",crs=4326)
a<-sf::st_transform(a, 32616)
write_sf(a,"/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/TALL_043_Stephanie_projected.shp")
stephanie_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/TALL_043_Stephanie_projected.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_043.tif")
stephanie_results<-evaluate_benchmark(stephanie_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(stephanie_results)

sergio_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/TALL_043_sergio.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_043.tif")
sergio_results<-evaluate_benchmark(sergio_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(sergio_results)

#TALL 017
aditya_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/TALL_017_Crowns.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_017.tif")
aditya_results<-evaluate_benchmark(aditya_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(aditya_results,threshold=0.4)

matching_results(submission=aditya_annotation,
                 image_path ="/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_017.tif",
                 results=aditya_results,threshold = 0.4)

a<-read_sf("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/TALL_017.shp",crs=4326)
a<-sf::st_transform(a, 32616)
write_sf(a,"/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/TALL_017_Stephanie_projected.shp")
stephanie_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/TALL_017_Stephanie_projected.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_017.tif")
stephanie_results<-evaluate_benchmark(stephanie_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(stephanie_results,threshold=0.4)

sergio_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/TALL_017_sergio.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_017.tif")
sergio_results<-evaluate_benchmark(sergio_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(sergio_results,threshold = 0.4)

#HARV 40
aditya_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/HARV_040_Crowns.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/HARV_040.tif")
aditya_results<-evaluate_benchmark(aditya_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(aditya_results,threshold = 0.6)

a<-read_sf("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/HARV_040.shp",crs=4326)
a<-sf::st_transform(a, 32616)
write_sf(a,"/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/HARV_040_projected.shp")
stephanie_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/HARV_040_projected.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/HARV_040.tif")
stephanie_results<-evaluate_benchmark(stephanie_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(stephanie_results)

sergio_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/HARV_040_sergio.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/HARV_040.tif")
sergio_results<-evaluate_benchmark(sergio_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(sergio_results)

aditya_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/HARV_040_Crowns.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/HARV_040.tif")
aditya_results<-evaluate_benchmark(aditya_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(aditya_results,threshold = 0.4)
matching_results(aditya_annotation,results=aditya_results,image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/HARV_040.tif",
                 threshold=0.4)

stephanie_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/HARV_040.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/HARV_040.tif")
stephanie_results<-evaluate_benchmark(stephanie_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(stephanie_results)

sergio_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/HARV_040_sergio.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/HARV_040.tif")
sergio_results<-evaluate_benchmark(sergio_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(sergio_results)

#OSBS_011
aditya_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/OSBS_011_Crowns.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/OSBS_011.tif")
aditya_results<-evaluate_benchmark(aditya_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(aditya_results,threshold=0.5)

stephanie_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/OSBS_011.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/OSBS_011.tif")
stephanie_results<-evaluate_benchmark(stephanie_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(stephanie_results)

sergio_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/OSBS_011_sergio.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/OSBS_011.tif")
sergio_results<-evaluate_benchmark(sergio_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(sergio_results)

#OSBS 32
aditya_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/OSBS_032_Crowns.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/OSBS_032.tif")
aditya_results<-evaluate_benchmark(aditya_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(aditya_results)

stephanie_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/OSBS_032.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/OSBS_032.tif")
stephanie_results<-evaluate_benchmark(stephanie_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(stephanie_results)

sergio_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/OSBS_032_sergio.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/OSBS_032.tif")
sergio_results<-evaluate_benchmark(sergio_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(sergio_results)

#MLBS 71
aditya_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/MLBS_071_Crowns.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/MLBS_071.tif")
aditya_results<-evaluate_benchmark(aditya_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(aditya_results)

stephanie_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/MLBS_071.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/MLBS_071.tif")
stephanie_results<-evaluate_benchmark(stephanie_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(stephanie_results)

sergio_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/MLBS_071_sergio.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/MLBS_071.tif")
sergio_results<-evaluate_benchmark(sergio_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(sergio_results)

#SERC_062
aditya_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/SERC_062_Crowns.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/SERC_062.tif")
aditya_results<-evaluate_benchmark(aditya_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(aditya_results)

stephanie_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/SERC_062.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/SERC_062.tif")
stephanie_results<-evaluate_benchmark(stephanie_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(stephanie_results)

sergio_annotation<-shapefile_to_annotation("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/SERC_062_sergio.shp",image_path = "/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/SERC_062.tif")
sergio_results<-evaluate_benchmark(sergio_annotation,project_boxes = F,show=T,compute_PR = FALSE)
summary_statistics(sergio_results)

#Aditya's crowns
ben<-read_sf("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/TALL_043_Ben.shp")
aditya<-read_sf("/Users/ben/Dropbox/Weecology/Benchmark/AdityaCrownDelineation/TALL_043_Crowns.shp")
stephanie<-read_sf("/Users/ben/Dropbox/Weecology/Benchmark/stephCrowns28jan20/TALL_043_Stephanie.shp")
sergio<-read_sf("/Users/ben/Dropbox/Weecology/Benchmark/ForStephanie/annotation_sergio/annotation_compare/TALL_043_sergio.shp")

rgb<-stack("/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/TALL_043.tif")

plotRGB(rgb)
plot(st_combine(st_intersection(ben,sergio)),add=TRUE)
