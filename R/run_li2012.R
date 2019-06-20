#' Find tree crown polygons using the Li (2012) algorithm
#'
#' \code{run_li2012} assigns each point in a lidR cloud to a treeID.
#' @param path Character. A filename of a .las or .laz file to be read in by the lidR package, see \code{\link[lidR]{readLAS}}
#' @param tile Character. Optionally a lidR object in memory
#' @param output Character. 'Tile', "convex_hull","all"
#' @return
#' \preformatted{
#' 'tile' : .las tile with segmented trees in the treeID column
#' 'convex_hull': a \code{\link[sp]{SpatialPolygonsDataFrame}} object with tree crown polygons
#' 'all': Both a tile and convex hull output in a named list.
#' }
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- run_li2012(path=LASfile)
#' @export

run_li2012<-function(path=NULL,tile=NULL,output="all",epsg_numeric){

  if(is.null(tile)){
    tile = lidR::readLAS(path)
    lidR::epsg(tile)<-epsg_numeric
  }

  #Read in tile
  print("Computing Ground Model")

  #Compute ground model
  tile=ground_model(tile,ground=F)

  #3. canopy model
  print("Computing Canopy Model")
  chm=canopy_model(tile)

  #Compute unsupervised classification method
  print("Clustering Trees")
  print(system.time(result<-segment_trees(las=tile,algorithm = "li2012",chm=chm)))

  if(output=="tile"){
    return(result)
  }

  #create polygons
  print("Creating tree polygons")
  convex<-get_convex_hulls(result,result@data$treeID)

  #set outputs
  if(output=="all"){
    return(list(convex=convex,tile=result))
  }
  if(output=="convex_hull"){
    return(convex)
  }
}

