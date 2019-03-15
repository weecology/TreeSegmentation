#' Wrapper for plotting a set of polygons on to a 3d lidar plot
#'
#' \code{plot_3d_polygons} creates 3d polygons from a SpatialPolygonsDataFrame
#' @param spdf A SpatialPolygonDataFrame or polygons with length 1
#' @param z The height to plot polygons.
#' @return NULL - plot invoked by side effect.
#' @export
#'
plot_3d_polygons<-function(spdf,z=0){
  for(i in 1:nrow(spdf)){
    x<-spdf@polygons[[i]]@Polygons[[1]]@coords[,1]
    y<-spdf@polygons[[i]]@Polygons[[1]]@coords[,2]
    polygon3d(x,y,rep(z,length(x)),col =rgb(255, 0, 0, 30, maxColorValue=255))
  }
}
