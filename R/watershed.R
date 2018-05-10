#' Find tree crown polygons using a simple watershed algorithm
#'
#' \code{watershed} assigns each point in a lidR cloud to a treeID.
#' @inheritParams li2012
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- watershed(path=LASfile)
#' @export

watershed<-function(path=NULL,tile=NULL,output="all"){

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
  #tile<-tile %>% lidR::lasfilter(!Classification==2)
  #tile@crs<-CRS("+init=epsg:32617")

  #Compute unsupervised classification method
  print("Clustering Trees")
  print(system.time(watershed_result<-segment_trees(las=tile,algorithm = "watershed",chm=chm)))

  if(output=="tile"){
    return(watershed_result)
  }

  #create polygons
  print("Creating tree polygons")
  convex<-get_convex_hulls(watershed_result,watershed_result@data$treeID)

  #set outputs
  if(output=="all"){
    return(list(convex=convex,tile=watershed_result))
  }

  if(output=="convex_hull"){
    return(convex)
  }
}

