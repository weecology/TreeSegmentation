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
  pdf<-reshape2::melt(ptlist,id.vars=colnames(ptlist[[1]]))
  points_to_remove<-pdf %>% group_by(PointID) %>% summarize(n=n()) %>% arrange(n) %>% filter(n < 3) %>% .$PointID

  pdf<-pdf %>% filter(!PointID %in% points_to_remove)

  res<-reshape2::dcast(pdf,PointID~L1,value.var = "treeID")

  idframe<-res %>% add_rownames() %>% select(rowname,PointID)
  head(res<-res %>% select(-PointID))

  system.time(consensus<-diceR::majority_voting(res, is.relabelled = FALSE))

  #reassign to pointID
  consensus_frame<-data.frame(rowname=rownames(res),consensus=consensus) %>% inner_join(idframe) %>% select(PointID,consensus)

  #merge with the original tile
  tile@data<-merge(tile@data,consensus_frame,all=T)
  return(tile)
  }
