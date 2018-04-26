#' Find tree crown polygons using the Li (2012) algorithm
#'
#' \code{li2012} assigns each point in a lidR cloud to a treeID.
#' @param path A filename of a .las or .laz file to be read in by the lidR package
#' @param extra Output both the tile and the convex polygons
#' @param tile Optionally a lidR object in memory
#' @return A \code{\link[sp]{SpatialPolygonsDataFrame}} object with tree crown polygons
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- li2012(path=LASfile)
#' @export

li2012<-function(path=NULL,tile=NULL,extra=F){

  if(is.null(tile)){
    tile = lidR::readLAS(path, select = "xyz", filter = "-drop_z_below 0")
    tile@crs<-CRS("+init=epsg:32617")
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
  tile@crs<-CRS("+init=epsg:32617")

  #Compute unsupervised classification method
  print("Clustering Trees")
  print(system.time(li2012<-segment_trees(las=tile,algorithm = "li2012",chm=chm)))

  #create polygons
  print("Creating tree polygons")
  convex<-get_convex_hulls(li2012,li2012@data$treeID)

  if(extra){
    return(list(convex=convex,tile=li2012))
  } else{
    return(convex)
  }
}

