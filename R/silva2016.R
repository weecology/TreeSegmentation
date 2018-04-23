#' Find tree crown polygons using the Silva 2016 algorithm
#'
#' \code{silva2016} assigns each point in a lidR cloud to a treeID.
#' @param path A filename of a .las or .laz file to be read in by the lidR package
#' @return A \code{\link[sp]{SpatialPolygonsDataFrame}} object with tree crown polygons
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0")
#' convex_hulls <- silva2016(tile)
#' @export

silva2016<-function(path){

  #Read in tile
  tile = lidR::readLAS(path, select = "xyz", filter = "-drop_z_below 0")

  #Compute ground model
  ground_model(tile)

  #3. canopy model
  chm=canopy_model(tile)

  #remove ground points, Classification == 2.
  tile<-tile %>% lidR::lasfilter(!Classification==2)

  #Compute unsupervised classification method
  system.time(silva2016<-segment_trees(tile,algorithm = "silva2016",chm=chm))

  #create polygons
  silva_convex<-get_convex_hulls(silva2016,silva2016@data$treeID)
}

