#' Check if tile can be used for training
#'
#' \code{check_tile} ensures that training tiles 1) Do not overlap with ground truth, and 2) have both lidar and rgb data
#' @param itcs_path path to itcs
#' @param lidar_path Character. path to lidar data directory
#' @param rgb_dir Character. path to camera tile
#' @param cores Numeric. Available cores to process data
#' @return Writes training crops to file
#' @export

check_tile<-function(itcs_path,lidar_path,rgb_dir){

  # Load in ground-truth
  shps<-list.files(itcs_path,pattern=".shp",full.names = T)
  itcs<-lapply(shps,rgdal::readOGR,verbose=F)

    names(itcs)<-sapply(itcs,function(x){
      id<-unique(x$Plot_ID)
      return(id)
    })

  #load lidar tile
  tile<-lidR::readLAS(lidar_path)

  #Get corresponding rgb tile
  full_path<-convert_names(from="lidar",to="rgb",lidar=tile)

  #check if rgb tile exists
  if(!file.exists(full_path)){
    print("no corresponding rgb tile")
    return(FALSE)
  }

  #check for intersection with ground truth
  intersect_sum<-c()
  for(x in 1:length(itcs)){
    does_intersect<-raster::intersect(itcs[[x]],raster(extent(tile)))
    intersect_sum[x]<-is.null(does_intersect)
  }

  #if no intersections with ground truth return true
  if(sum(!intersect_sum)==0){
    return(TRUE)
  } else {
    return(FALSE)
  }
}
