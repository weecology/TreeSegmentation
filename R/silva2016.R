#' Find tree crown polygons using the Silva 2016 algorithm
#'
#' \code{silva2016} assigns each point in a lidR cloud to a treeID.
#' @param path A filename of a .las or .laz file to be read in by the lidR package
#' @param extra Output both the tile and the convex polygons
#' @param tile Optionally a lidR object in memory
#' @return A \code{\link[sp]{SpatialPolygonsDataFrame}} object with tree crown polygons
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- silva2016(path=LASfile)
#' @export

silva2016<-function(path=NULL,tile=NULL,extra=F){

  if(is.null(tile)){
    tile = lidR::readLAS(path, select = "xyz", filter = "-drop_z_below 0")
  }
  #Read in tile

  print("Computing Ground Model")
  #Compute ground model
  ground_model(tile)

  #3. canopy model
  print("Computing Canopy Model")
  chm=canopy_model(tile)

  #remove ground points, Classification == 2.
  tile<-tile %>% lidR::lasfilter(!Classification==2)

  #Compute unsupervised classification method
  print("Clustering Trees")
  print(system.time(silva2016<-segment_trees(tile,algorithm = "silva2016",chm=chm)))

  #create polygons
  print("Creating tree polygons")
  silva_convex<-get_convex_hulls(silva2016,silva2016@data$treeID)

  if(extra){
    return(list(silva_convex=silva_convex,silva_tile=tile))
  }
}

