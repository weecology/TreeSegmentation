#' Negative sampling of a tile based on observed trees
#'
#' \code{negative_samples} Negative training samples are produced by randomly placing boxes along the tiles. The size of each box, and the number of total tiles, match the number of trees found in the tile.
#' @param boxes. A dataframe output from \code{training_crops}
#' @param path_las A tile to define the bounds of sampling
#' @export

negative_samples<-function(boxes,path_las){

  #load tile
  tile<-lidR::readLAS(path_las)

  #create raster from extent
  r<-raster::raster(extent(tile))
  raster::res(r)<-1
  r[]<-1

  #cut out existing boxes
  extent_boxes<-lapply(split(boxes,boxes$box),box_from_row)
  spatial_boxes<-lapply(extent_boxes,function(x){as(x,"SpatialPolygons")})

  spatial_boxes<-list(spatial_boxes, makeUniqueIDs = T) %>%
    purrr::flatten() %>%
    do.call(rbind, .)

  system.time(r<-raster::mask(r,spatial_boxes,inverse=T))

  #Kill boxes of 0 area.
  boxes<-boxes %>% filter(!xmin==xmax)
  negatives<-boxes %>% group_by(id=1:n()) %>% do(sample_box(.,r)) %>% ungroup() %>% select(-id)

  return(negatives)
}

#check box proposal - negative boxes shouldn't overlap
sample_box<-function(row,sampling_tile){

  while(TRUE){
    #define box size
    width=row$xmax-row$xmin
    height=row$ymax-row$ymin

    #Sample a random location on the tile
    p<-raster::sampleRandom(sampling_tile,size=1,xy=TRUE)[,1:2]

    #create box from point
    xmin<-p[["x"]]
    ymax<-p[["y"]]
    xmax<-xmin + width
    ymin<-ymax-height

    #create an extent box
    new_box<-raster::extent(xmin,xmax,ymin,ymax)

    #check if box overlaps with border.
    if(!is.null(raster::intersect(new_box,sampling_tile))){
      row$label<-"Background"
      row$box<-paste(row$box,"_background",sep="")
      row$xmin<-xmin
      row$xmax<-xmax
      row$ymin<-ymin
      row$ymax<-ymax
      return(row)
    }

  }
}

box_from_row<-function(row){
  raster::extent(row$xmin,row$xmax,row$ymin,row$ymax)
}
