#' Negative sampling of a tile based on observed trees
#'
#' \code{negative_samples} Negative training samples are produced by randomly placing boxes along the tiles. The size of each box, and the number of total tiles, match the number of trees found in the tile.
#' @param boxes. A dataframe output from \code{training_crops}
#' @param path_las A tile to define the bounds of sampling
#' @export

negative_samples<-function(boxes,path_las){

  #load tile
  tile<-lidR::readLAS(path_las)

  #get extent
  e<-extent(tile)

  negatives<-boxes %>% group_by(id=1:n()) %>% do(jitter_box(.,e=e)) %>% ungroup() %>% select(-id)

  return(negatives)
}

#jitter box function
jitter_box<-function(box,e){
  #find box size
  width=box$xmax-box$xmin
  height=box$ymax-box$ymin

  #border the tile
  border_xmin=e@xmin+width
  border_xmax=e@xmax-width
  border_ymin=e@ymin+height
  border_ymax=e@ymax-height

  #Choose a positive or negative direction for both axis
  x_direction<-sample(c(1,-1),1)
  y_direction<-sample(c(1,-1),1)

  #Jitter X position
  if(x_direction==1){
    x_to_select<-seq(0,box$xmax-border_xmax,length.out = 100)
  } else {
    x_to_select<-seq(0,border_xmin-box$xmin,length.out = 100)
  }

  #jitter y direction
  if(y_direction==1){
    y_to_select<-seq(0,box$ymax-border_ymax,length.out = 100)

  } else {
    y_to_select<-seq(0,border_ymin-box$ymin,length.out = 100)
  }

  #randomly draw a x and y coordinate
  x_jitter<-sample(x_to_select,1)
  y_jitter<-sample(y_to_select,1)

  #reform box
  box$xmin<- box$xmin + x_jitter
  box$xmax<- box$xmax + x_jitter
  box$ymin<- box$ymin + y_jitter
  box$ymax<- box$ymax + y_jitter
  box$label<-"Background"
  box$box<-paste(box$box,"_background",sep="")
  return(box)
}

