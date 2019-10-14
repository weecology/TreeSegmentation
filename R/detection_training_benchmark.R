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
detection_training_benchmark<-function(site,path,silva_cr_factor,silva_exclusion,save_dir="Results/detection_boxes/"){
  #Read tile
  tile<-lidR::readLAS(path)

  #normalize
  tile<-ground_model(tile,ground=F)

  #Compute silva segmentation
  las<-run_silva2016(tile=tile,output = "tile",max_cr_factor = silva_cr_factor, exclusion=silva_exclusion)

  #format bounding boxes
  tree_polygons<- lidR::tree_hulls(las,type="bbox")
  bboxes<-lapply(tree_polygons@polygons,sp::bbox)

  #Format according the keras-retinet requirements "CSV datasets" https://github.com/fizyr/keras-retinanet
  #as a single row
  result<-lapply(bboxes, function(x){
    df<-data.frame(xmin=x["x","min"],ymin=x["y","min"],xmax=x["x","max"],ymax=x["y","max"])
    return(df)
  })

  result<-dplyr::bind_rows(result)
  result$label<-"Tree"

  #get the corresponding orthophoto naming
  lidar_path<-stringr::str_match(path,"\\/(\\w+.laz)")[,2]
  result$plot_name<-convert_names(from="lidar",to="rgb",lidar=path,site=site)
  result<-result %>% dplyr::select(plot_name,xmin,ymin,xmax,ymax,label)

  #give the results a filename and label the lidar tile
  sanitized_fn<-stringr::str_match(string=path,pattern="(\\w+).laz")[,2]

  #Set origin to top left corner of image, following numpy convention, flipped from raster origin (bottom left)
  e<-raster::extent(tile)
  origin_result<-result
  origin_result$xmin<-result$xmin - e@xmin
  origin_result$xmax<-result$xmax - e@xmin
  origin_result$ymin<-e@ymax - result$ymax
  origin_result$ymax<-origin_result$ymin + (result$ymax-result$ymin)

  #Write to dir
  fname<-paste(save_dir,"/",sanitized_fn,".csv",sep="")
  write.csv(origin_result,fname,row.names = F)
}
