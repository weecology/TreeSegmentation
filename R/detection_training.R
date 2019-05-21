#' Generate detection network training files
#'
#' \code{detection training} is the pipeline for generating training data for a detection based nueral net (RCNN).
#' @param path Character Location of the lidar tile to process.
#' @return A .csv file is written to disk containing detections
#' @export
#'
#'
detection_training<-function(path,site,year,silva_cr_factor,silva_exclusion){
  tile<-lidR::readLAS(path)

  #normalize
  tile<-ground_model(tile,ground=F)

  print("Normalized")

  #Compute silva segmentation
  result<-run_silva2016(tile=tile,output = "tile",max_cr_factor = silva_cr_factor, exclusion=silva_exclusion)

  print("Tree Segmentation Complete")

  #get list of tree points
  trees<-split(result@data, result@data$treeID)
  trees<-dplyr::bind_rows(trees) %>% dplyr::select(X,Y,Z,treeID)

  #Get bounding box around each tree id, label the algorithm
  trees<-trees %>% dplyr::group_by(treeID) %>% dplyr::do(get_box(.,expand=1)) %>% mutate(Algorithm="Silva")

  print("Bounding boxes complete")

  #get the corresponding orthophoto naming
  trees$lidar_path<-stringr::str_match(path,"\\/(\\w+.laz)")[,2]
  trees$rgb_path<-convert_names(from="lidar",to="rgb",lidar=path,site=site)

  #label
  trees$label<-"Tree"

  #give the results a filename and label the lidar tile
  sanitized_fn<-stringr::str_match(string=path,pattern="(\\w+).laz")[,2]

  #Format according the keras-retinet requirements "CSV datasets" https://github.com/fizyr/keras-retinanet
  #Create a unique index

  #Add tile extent for spatial reference
  e<-raster::extent(tile)

  boxes<-trees %>% mutate(numeric_label=as.numeric(as.factor(label))) %>% mutate(tile_xmin=e@xmin,tile_xmax=e@xmax,tile_ymin=e@ymin,tile_ymax=e@ymax)
  fname<-paste("Results/detection_boxes/",site,"/",year,"/",sanitized_fn,".csv",sep="")

  #check if exists
  filepath<-paste("Results/detection_boxes/",site,"/",year,"/",sep="")
  if(dir.exists(filepath) == F) dir.create(filepath, showWarnings=F,recursive = T)

  write.csv(boxes,fname,row.names = T)
}
