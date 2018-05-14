#' Generate training crop data from lidar tiles
#'
#' \code{training_crops} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree. It then writes the resulting files in h5 format for machine learning input
#' @param path_rgb Character. file path of rgb image
#' @param path_lidar Character. path of lidar tile
#' @param path_hyperspec Character. path of hyperspectral tile
#' @param write Logical. Should results be written to file
#' @param outdir Character. Path to output directory on disk.
#' @return If write=T, returns NULL, else returns a list of cropped objects
#' @export
#'
training_crops<-function(path_las=NULL,algorithm="silva",cores=NULL,path_rgb=NULL,path_hyperspec=NULL,outdir){

  #holder for crops
  results<-list()

  #segmented trees
  results$lidar<-extract_trees(cores = NULL,algorithm = algorithm,las=path_las,output = "df")

  #create bounding boxes
  boxes<-get_bounding_boxes(df=ind_trees)

  #crop rgb
  if(is.null(path_rgb)){
    rgb<-raster::stack(path_rgb)
    results$rgb<-lapply(boxes,function(x){
      raster::crop(x,rgb)
    })
  }

  #crop hyperspectral
  if(!is.null(path_hyperspec)){
    #TODO load and process hyperspectral?
    hyperspec<-raster::stack(path_hyperspec)
    results$hyperspectral<-lapply(boxes,function(x){
      raster::crop(x,hyperspec)
    })
  }

  #write
  if(write){
    train_dir<-paste(outdir,"training",sep="/")

    #If training dir doesn't exist, create
    if(!dir.exists(train_dir)){
      dir.create(train_dir)
    }

    #write each object

  } else{
    return(results)

  }

}

