#' Find tree crown polygons using the Li (2012) algorithm
#'
#' \code{li2012} assigns each point in a lidR cloud to a treeID.
#' @param path Character. A filename of a .las or .laz file to be read in by the lidR package, see \code{\link[lidR]{readLAS}}
#' @param tile Character. Optionally a lidR object in memory
#' @return
#' \preformatted{
#' 'tile' : .las tile with segmented trees in the treeID column
#' 'convex_hull': a \code{\link[sp]{SpatialPolygonsDataFrame}} object with tree crown polygons
#' 'all': Both a tile and convex hull output in a named list.
#' }
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- li2012(path=LASfile)
#' @export

li2012<-function(path=NULL,tile=NULL,output="all"){

  if(is.null(tile)){
    tile = lidR::readLAS(path, filter = "-drop_z_below 0")
    tile@crs<-CRS("+init=epsg:32617")
  }

  #Read in tile
  print("Computing Ground Model")

  #Compute ground model
  ground_model(tile,ground=F)

  #3. canopy model
  print("Computing Canopy Model")
  chm=canopy_model(tile)

  #remove ground points, Classification == 2.
  tile<-tile %>% lidR::lasfilter(!Classification==2)
  tile@crs<-CRS("+init=epsg:32617")

  #Compute unsupervised classification method
  print("Clustering Trees")
  print(system.time(li2012<-segment_trees(las=tile,algorithm = "li2012",chm=chm)))

  if(output=="tile"){
    return(li2012)
  }

  #create polygons
  print("Creating tree polygons")
  convex<-get_convex_hulls(li2012,li2012@data$treeID)

  #set outputs
  if(output=="all"){
    return(list(convex=convex,tile=li2012))
  }
  if(output=="convex_hull"){
    return(convex)
  }
}

