#'  Majority voting for individual tree crown segmentation based on multiple algorithms
#'
#' \code{consensus} assigns each point in a lidR cloud to a treeID based on multiple segmentation algorithms
#' @param ptlist A list of lidar clouds read in by lidR package, processed using \code{\link[lidR]{lastrees}}
#' @return A las object with treeID field updated based on ensemble individual tree segmentation. A new column "consensus" is the consensus treeID.
#' @import dplyr
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0"
#' chm=canopy_model(tile)
#' ptlist<-list()
#' ptlist[["watershed"]] <- segment_trees(tile,algorithm="watershed",chm=chm)
#' ptlist[["silva2016"]]<- segment_trees(tile,algorithm="silva2016",chm=chm)
#' consensus(ptlist)
#' @export
#'
consensus<-function(ptlist){

  #Grab the data structure from the lidR file.
  ptlist_data<-lapply(ptlist,function(x){x@data})

  #add point column id
  ptlist_data<-lapply(ptlist_data,function(x){
    x$PointID<-1:nrow(x)
    return(x)
  })

  pdf<-reshape2::melt(ptlist_data,id.vars=colnames(ptlist_data[[1]])) %>% filter(!is.na(treeID))

  #TODO complete cases?
  #points_to_remove<-pdf %>% group_by(PointID) %>% summarize(n=n()) %>% arrange(n) %>% filter(!n==length(ptlist)) %>% .$PointID
  #pdf<-pdf %>% filter(!PointID %in% points_to_remove)

  res<-reshape2::dcast(pdf,PointID~L1,value.var = "treeID")

  idframe<-res %>% tibble::rownames_to_column() %>% select(rowname,PointID)
  head(res<-res %>% select(-PointID))

  #complete cases
  res<-res[complete.cases(res),]

  system.time(result<-diceR::majority_voting(res, is.relabelled = FALSE))

  #reassign to pointID
  consensus_frame<-data.frame(rowname=rownames(res),treeID=result) %>% inner_join(idframe) %>% select(PointID,treeID)

  #merge with the original tile
  original<-ptlist[[1]]
  original@data<-original@data %>% select(-treeID)
  original@data$PointID<-1:nrow(original@data)
  original@data<-merge(original@data,consensus_frame,all=T)
  return(original)
  }
