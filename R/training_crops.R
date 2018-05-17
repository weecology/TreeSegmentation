#' Generate bounding boxes from lidar tiles
#'
#' \code{training_crops} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree. It then writes the resulting files in h5 format for machine learning input
#' @param path_rgb Character. file path of rgb image
#' @param create_negatives Should negative samples be generated. see details
#' @param write Logical. Should results be written to file
#' @details Negative training samples are produced by randomly placing boxes along the tiles. The size of each box, and the number of total tiles, match the number of trees found in the tile.
#' @export
#'
training_crops<-function(path_las=NULL,algorithm="silva",cores=NULL,create_negatives=T){

  #holder for crops
  results<-list()

  #segmented trees
  results$lidar<-extract_trees(cores = NULL,algorithm = algorithm,las=path_las,output = "df")

  #create bounding boxes dataframe
  boxes<-get_bounding_boxes(df=results$lidar)

  #give the results a filename and label the lidar tile
  sanitized_fn<-stringr::str_extract(string=path_las,pattern="(NEON.*)")
  sanitized_fn<-stringr::str_replace_all(sanitized_fn,"\\.","_")

  #get the corresponding orthophoto naming
  boxes$lidar_path<-stringr::str_match(path_las,"\\/(\\w+.laz)")[,2]
  boxes$rgb_path<-convert_names(from="lidar",to="rgb",lidar=path_las)

  #label
  boxes$label<-"Tree"

  #quick sanity check, if box is NA, give it the rowID index
  if(sum(!is.na(boxes$box))==0){
    boxes$box<-as.character(1:nrow(boxes))
  }

  if(create_negatives){
    print("Generating random negative samples")

    #append negative samples
    new_boxes<-negative_samples(boxes,path_las)
    boxes<-dplyr::bind_rows(list(boxes,new_boxes))
  }

  write.csv(boxes,paste("Results/bounding_boxes_",sanitized_fn,".csv",sep=""))

}

