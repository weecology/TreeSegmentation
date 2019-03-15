#' Generate a SpatialPolygonsDataFrame of convex hulls for all segmented trees
#'
#' \code{get_convex_hulls} Iterates through a lidR .las point cloud and returns convex hulls for all identified trees.
#' @param tile A lidR point cloud which has been processed by \code{\link[lidR]{lastrees}}, see \code{\link{segment_trees}}
#' @param ID The name of the ID field that deliniates individual trees.
#' @return A \code{\link[sp]{SpatialPolygonsDataFrame}} object containing a convex hull for each defined tree.
#' @export
#' @examples
#' Read in tile
#' tile=readLAS("../tests/data/NEON_D03_OSBS_DP1_404000_3284000_classified_point_cloud.laz")
#' #Generate ground model
#' ground_model(tile)
#' #Generate canopy model
#' chm=canopy_model(tile)
#'
#' #remove ground points? Classification == 2?
#' tile<-tile %>% lasfilter(!Classification==2)
#'
#' #Compute unsupervised classification method
#' system.time(silva2016<-segment_ITC(tile,algorithm = "silva2016",chm=chm))
#' #create polygons
#' silva_convex<-get_convex_hull(silva2016,silva2016@data$treeID)
#'
get_convex_hulls<-function(tile,ID){

  split_trees= split(tile@data, ID)
  tree_polygons<-lapply(split_trees,convex_hull)

  names(tree_polygons)<-NULL

  #assign treeID as slot ID for each polygon
  for(x in 1:length(tree_polygons)){
    tree_polygons[[x]]@polygons[[1]]@ID<-names(split_trees)[x]
  }

  if(length(tree_polygons)>1){
    #bind into large SpatialPolygonsDataframe if more than one
    convex_polygons<-do.call(raster::bind,unlist(tree_polygons))
  } else{
    convex_polygons<-tree_polygons[[1]]
  }

  #make into sp dataframe
  IDs <- sapply(slot(convex_polygons, "polygons"), function(x) slot(x, "ID"))
  df <- data.frame(ID=1:length(IDs), row.names=IDs)
  result<-sp::SpatialPolygonsDataFrame(convex_polygons,df)
  sp::proj4string(result)<-projection(tile)

  return(result)
}
