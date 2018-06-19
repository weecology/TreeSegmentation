#' Find clusters of elevation on the canopy height model
#'
#' \code{treeClusters} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree. It then writes the resulting files in h5 format for machine learning input
#' @param path Character. file path to lidar image
#' @param threshold Minimum height of the tree clusters.
#' @param res Numeric. Resolution of the canopy height model
#' @param expand Numeric. Meters to expand the bounding box to pad the edges.
#' @return A data.frame of bounding boxes for each tree object.
#' @export
#'
treeClusters<-function(path,threshold=15,res=3,expand=0){

  ## Load lidR
  tile<-lidR::readLAS(path)

  #normalize
  ground_model(tile,ground=F)

  ## Compute CHM
  chm<-canopy_model(tile,res=res)

  ## Threshold CHM
  islands<-chm > threshold

  ## Find Blobs
  connected<-clump(islands)

  ## Get bounding boxes for each blob
  connected_sp<-raster::rasterToPoints(connected,spatial = T)

  indices<-unique(connected_sp$clumps)
  result<-list()
  for(x in 1:length(indices)){
    result[[x]]<-point_box(connected_sp,indices[x],expand=expand)
  }

  result<-dplyr::bind_rows(result)

  #bind path name
  result<-result
  return(result)
}

#Define box funtion
point_box<-function(connected_sp,index,expand){

  #select cluster, get bounding box and pad.
  b<-bbox(connected_sp[connected_sp$clumps==index,])

  bounding_box<-as.numeric(expand_box(b,expand))

  #ensure the padding didn't fall off the edge of the tile.
  bounding_box<-data.frame(Index=index,xmin=bounding_box[1],ymin=bounding_box[2],xmax=bounding_box[3],ymax=bounding_box[4])
}

expand_box<-function(b,expand){
  b[,1]<-b[,1]-expand
  b[,2]<-b[,2]+expand
  return(b)
}
