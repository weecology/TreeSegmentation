#' Generate bounding boxes for all segmented trees
#'
#' \code{get_bounding_boxes} Iterates through a list of dataframes and returns bounding boxes based on the extent of XY points.
#' @param df a list of objects exported by \code{\link{extract_trees}}
#' @return A list of \code{\link[sp]{SpatialPolygonsDataFrame}} objects containing a bounding box for each defined tree.
#' @export

get_bounding_boxes<-function(df){

  #Bind together all lists
  allrows<-reshape2::melt(df,id.vars=colnames(df[[1]][[1]][[1]]))
  allrows<- dplyr::rename(allrows,Tile=L1,Algorithm=L2,Tree=L3)

  #Split by tile, algorithm and Tree
  as_list_allrows<-split(allrows,list(allrows$Tile,allrows$Algorithm,allrows$Tree),drop=T)

  #Get bounding boxes
  boxes<-lapply(as_list_allrows,get_box)
  boxes<-reshape2::melt(boxes,id.vars=colnames(boxes[[1]])) %>% rename(box=L1)

  #sanitize the box names
  sanitized<-stringr::str_extract(string=boxes$box,pattern="(NEON.*)")
  boxes$box<-stringr::str_replace_all(sanitized,"\\.","_")
  return(boxes)
}

get_box<-function(x){
  s<-sp::SpatialPoints(cbind(x$X,x$Y))
  e<-raster::extent(s)
  edf<-data.frame(xmin=e@xmin,xmax=e@xmax,ymin=e@ymin,ymax=e@ymax)
  return(edf)
}

