#' Find tree crown polygons using the Dalponte 2016 algorithm
#'
#' \code{dalponte2016} assigns each point in a lidR cloud to a treeID.
#' @inheritParams li2012
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- dalponte2016(path=LASfile)
#' @export

dalponte2016<-function(path=NULL,tile=NULL,output="all"){

  if(is.null(tile)){
    tile = lidR::readLAS(path, select = "xyz", filter = "-drop_z_below 0")
    tile@crs<-sp::CRS("+init=epsg:32617")
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
  print(system.time(dalponte2016<-segment_trees(las=tile,algorithm = "dalponte2016",chm=chm)))

  if(output=="tile"){
    return(dalponte2016)
  }

  #create polygons
  print("Creating tree polygons")
  dalponte_convex<-get_convex_hulls(dalponte2016,dalponte2016@data$treeID)

  #set outputs
  if(output=="all"){
    return(list(convex=dalponte_convex,tile=dalponte2016))
  }

  if(output=="convex_hull"){
    return(dalponte_convex)
  }
}

