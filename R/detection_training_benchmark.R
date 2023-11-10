#' Generate detection network training files
#'
#' \code{detection training} is the pipeline for generating training data for a detection based nueral net (RCNN).
#' @param path Character Location of the lidar tile to process.
#' @param save_dir Where to save the boxes, a folder for the year will be added to relative to this base dir.
#' @param silva_exclusion see lidR::lastrees
#' @param silva_cr_factor see lidR::lastrees
#' @return A .csv file is written to disk containing detections
#' @export
#'
#'
detection_training_benchmark<-function(path,silva_cr_factor=0.7,silva_exclusion=0.5,rgb_tiles,save_dir="Results/detection_boxes/"){

  #Find the corresponding orthophoto naming
  lidar_basename<-stringr::str_match(path,"\\/(\\w+.laz)")[,2]

  #Search the rgb_tiles for matching paths
  lidar_geo_index<-stringr::str_match(lidar_basename,"DP1_(\\d+_\\d+)_")[,2]
  lidar_year<-stringr::str_match(path,"DP1.30003.001/neon-aop-products/(\\d+)/FullSite/")[,2]
  selected_rgb<-rgb_tiles %>% filter(geo_index == lidar_geo_index,year == lidar_year) %>% droplevels()

  #ignore v01 data if multiple tiles remaining
  if(nrow(selected_rgb)>1){
    selected_rgb<-selected_rgb %>% filter(!str_detect(RGB,"V01"))
  }
  if(nrow(selected_rgb)==0){
    stop(paste("Cannot match rgb tiles to lidar file:",path))
  }

  #Read tile
  tile<-lidR::readLAS(path)

  #normalize
  tile<-ground_model(tile,ground=F)

  #Compute silva segmentation
  las<-run_silva2016(tile=tile,output = "tile",max_cr_factor = silva_cr_factor, exclusion=silva_exclusion)

  #2m height filter
  las@data$treeID[las@data$Z<2]<-NA

  #format bounding boxes
  tree_polygons<- lidR::tree_hulls(las,type="bbox")
  bboxes<-lapply(tree_polygons@polygons,sp::bbox)

  #min areas
  min_area<-sapply(tree_polygons@polygons,function(x) x@area>1)
  bboxes<-bboxes[min_area]

  #Format according the keras-retinet requirements "CSV datasets" https://github.com/fizyr/keras-retinanet
  #as a single row
  result<-lapply(bboxes, function(x){
    df<-data.frame(xmin=x["x","min"],ymin=x["y","min"],xmax=x["x","max"],ymax=x["y","max"])
    return(df)
  })

  result<-dplyr::bind_rows(result)
  result$label<-"Tree"


  result$plot_name<-unique(selected_rgb$RGB)
  result<-result %>% dplyr::select(plot_name,xmin,ymin,xmax,ymax,label)

  #give the results a filename and label the lidar tile
  sanitized_fn<-stringr::str_match(string=path,pattern="(\\w+).laz")[,2]

  #Set origin to top left corner of image, following numpy convention, flipped from raster origin (bottom left)
  #in cell units, not meters, round to nearest.
  e<-raster::extent(tile)
  origin_result<-result
  origin_result$xmin<-(result$xmin - e@xmin)
  origin_result$xmax<-(result$xmax - e@xmin)
  origin_result$ymin<-(e@ymax - result$ymax)
  origin_result$ymax<-(origin_result$ymin + (result$ymax-result$ymin))

  #resoution of 0.1m per cell
  origin_result$xmin =  round(origin_result$xmin * 10)
  origin_result$ymin =  round(origin_result$ymin * 10)
  origin_result$xmax =  round(origin_result$xmax * 10)
  origin_result$ymax =  round(origin_result$ymax * 10)

  #Write to dir
  fname<-paste(save_dir,"/",sanitized_fn,".csv",sep="")
  write.csv(origin_result,fname,row.names = F)
}
