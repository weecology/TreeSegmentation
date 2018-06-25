#' Find tree crown polygons using the Silva 2016 algorithm
#'
#' \code{silva2016} assigns each point in a lidR cloud to a treeID.
#' @inheritParams li2012
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- silva2016(path=LASfile)
#' @export

silva2016<-function(path=NULL,tile=NULL,output=c("all"),ground=T){

  if(is.null(tile)){
    tile = lidR::readLAS(path, filter = "-drop_z_below 0")
    tile@crs<-sp::CRS("+init=epsg:32617")
  }

  #Read in tile
  #Compute ground model
  if(ground){
    ground_model(tile,ground=F)
  }

  #3. canopy model
  chm=canopy_model(tile)

  #remove ground points, Classification == 2.
  #tile<-tile %>% lidR::lasfilter(!Classification==2)
  #tile@crs<-sp::CRS("+init=epsg:32617")

  #Compute unsupervised classification method
  silva2016<-segment_trees(las=tile,algorithm = "silva2016",chm=chm)

  if(output=="tile"){
    return(silva2016)
  }
  print("hi")
  #create polygons
  silva_convex<-get_convex_hulls(tile = silva2016,ID = silva2016@data$treeID)

  #set outputs
  if(output=="all"){
    return(list(convex=silva_convex,tile=silva2016))
  }
  if(output=="convex_hull"){
    return(silva_convex)
  }

}

