library(igraph)
library(ggplot2)
library(dplyr)
library(reshape2)

#'  Graph based consensus algorithm for majority voting.
#' \code{consensus_network} assigns each point in a lidR cloud to a treeID based on multiple segmentation algorithms
#' @param ptlist A list of lidar clouds read in by lidR package, processed using \code{\link[lidR]{lastrees}}
#' @param threshold numeric. The proportion [0-1] of methods which need to predicted a pair of points to be included in the same cluster. Default is 0.5, which is a majority rule. A cluster voting scheme. Currently implemented "majority" or "kmodes" see \code{\link[diceR]{majority_voting}}  processed using \code{\link[lidR]{lastrees}}
#' @return A las object with treeID field updated based on ensemble individual tree segmentation. A new column "consensus" is the consensus treeID.
#' @import dplyr
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0"
#' chm=canopy_model(tile)
#' ptlist<-list()
#' ptlist[["watershed"]] <- segment_trees(tile,algorithm="watershed",chm=chm)
#' ptlist[["silva2016"]]<- segment_trees(tile,algorithm="silva2016",chm=chm)
#' consensus_network(ptlist)
#' @export
#'
consensus_network<-function(ptlist,threshold=0.5){

  #Find pairwise incidence
  system.time(df_all<-count_list(ptlist,threshold=threshold))

  #create lidar graph
  g<-create_graph(as.matrix(df_all))

  #Get connection components
  r<-get_connected(g)

  r<-reshape2::melt(r)
  colnames(r)<-c("PointID","treeID")
  r$PointID<-as.character(r$PointID)
  r$treeID<-as.character(r$treeID)

  #create a dataframe of PointID
  #bind to .las object, use the first instance.
  original<-ptlist[[1]]

  #it will have a treeID to replace, give it a pointID
  original@data<-original@data %>% select(-treeID)
  original@data$PointID<-as.character(1:nrow(original@data))

  #merge
  original@data<-merge(original@data,r,all=T)
  return(original)
}

get_edges<-function(x){
  as.data.frame(t(combn(x,2)))
}

pairwise_count<-function(.las){

  #Get a pointID
  .las@data$PointID<-1:nrow(.las@data)

  #Split into treeIDs
  ind_trees= split(.las@data, .las@data$treeID)

  #For each group, get all pairwise combination of members
  m<-lapply(ind_trees,function(x){get_edges(x$PointID)})

  #Bind groups into a dataframe and give it a count column
  df<-bind_rows(m)
  colnames(df)<-c("Point1","Point2")
  return(df)
}

count_list<-function(ptlist,threshold=0.5){

  #find pairwise lists
  point_list<-lapply(ptlist,pairwise_count)

  #bind
  alldf<-bind_rows(point_list)

  #count
  df_all<-alldf %>% group_by(Point1,Point2) %>% summarize(n=n()/length(ptlist))

  #filter out data less than threshold, return point names
  df_all<-df_all %>% ungroup() %>% filter(n>threshold) %>% select(Point1,Point2) %>% mutate(Point1=as.character(Point1),Point2=as.character(Point2))
}

create_graph<-function(edge_list){
  g<-igraph::graph_from_edgelist(edge_list,directed=F)
}

get_connected<-function(g){
  cl <- igraph::clusters(g)
  lapply(seq_along(cl$csize)[cl$csize > 1], function(x)
    igraph::V(g)$name[cl$membership %in% x])
}



