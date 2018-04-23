#' Find individual tree crowns using normalized las and a canopy height model
#'
#' \code{segment_trees} assigns each point in a lidR cloud to a treeID.
#' @param las A lidar cloud read in by lidR package
#' @param algorithm a segmentation method, see \code{\link[lidR]{lastrees}}
#' @param chm a canopy height model see \code{\link{canopy_model}}
#' @return A las object with treeID field updated based on individual tree segmentation.
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0"
#' chm=canopy_model(tile)
#' treelas=segment_trees(tile,algorithm="watershed",chm=chm)
segment_trees<-function(las,algorithm="watershed",chm=chm){

  if(algorithm=="watershed"){
    # tree segmentation
    crowns = lidR::lastrees(las, algorithm = algorithm, chm, th = 4, extra = TRUE)

    # display
    tree = lidR::lasfilter(las, !is.na(treeID))
    plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1)

    # More stuff
    contour = rasterToPolygons(crowns, dissolve = TRUE)

    plot(chm, col = height.colors(50))
    plot(contour, add = T)
    return(las)
  }
  if (algorithm=="dalponte2016"){

    # Dalponte 2016
    ttops = tree_detection(chm, 5, 2)
    crowns <- lastrees_dalponte(las, chm, ttops,extra=T)
    plot(crowns, color = "treeID", colorPalette = col)

    contour = rasterToPolygons(crowns, dissolve = TRUE)

    plot(chm, col = height.colors(50))
    plot(contour, add = T)
    return(las)
  }

  if(algorithm=="li2012"){
    # tree segmentation
    lastrees(las, "li2012", R = 5)

    # display
    tree = lasfilter(las, !is.na(treeID))
    plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1)

    return(las)
  }

  if(algorithm=="silva2016"){

    ttops = tree_detection(chm, 5, 2)
    crowns<-lastrees_silva(las, chm, ttops, max_cr_factor = 0.6, exclusion = 0.3,
                           extra = T)

    # display
    tree = lasfilter(las, !is.na(treeID))
    plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1,backend="rgl")

    # More stuff
    contour = rasterToPolygons(crowns, dissolve = TRUE)

    plot(chm, col = height.colors(50))
    plot(contour, add = T)
    return(las)
  }

}
