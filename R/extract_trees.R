#' Extract individual las files for segmented trees
#'
#' \code{extra_trees} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree.
#' @param path_to_tiles Character or Vector. Location of lidar tiles on system. May be a single tile or vector of tiles.
#' @param algorithm  Character. A vector of lidar unsupervised classification algorithm(s). Currently "silva","dalponte","li" and "watershed" are implemented. See \code{\link[lidR]{lastrees}}
#' @param compute_consensus Logical. Generate a consensus from selected methods, see \code{\link{consensus}}.
#' @return a list of lidR tiles.
#' @export
#'
extract_trees<-function(path_to_tiles=NULL,algorithm="silva",compute_consensus=F,cores=NULL){

  #Sanity check, consensus can't be T if only 1 algorithm selection
  if(length(algorithm==1) & compute_consensus==T){
    stop("Select more than 1 algorithm to generate consensus")
  }

  #If running in parallel
  `%dopar%` <- foreach::`%dopar%`
  if(!is.null(cores)){
    cl<-parallel::makeCluster(cores)
    doSNOW::registerDoSNOW(cl)
  }

  #set file name
  #for each tile in path_to_tiles
  results<-foreach::foreach(g=1:length(path_to_tiles),.packages=c("TreeSegmentation")) %dopar% {

    #Select tile
    inpath<-path_to_tiles[g]

    #Run segmentation methods
    tiles<-list()
    if("silva" %in% algorithm){
      print("silva")
      tiles$silva<-silva2016(path=inpath,output="tile")
    }

    if("dalponte" %in% algorithm){
      print("Dalpone")
      tiles$dalponte<-dalponte2016(path=inpath,output="tile")
    }

    if("li" %in% algorithm){
      print("li")
      tiles$li<-li2012(path=inpath,output="tile")
    }

    if("watershed" %in% algorithm){
      print("watershed")
      tiles$watershed<-watershed(path=inpath,output="tile")
    }

    if(compute_consensus){
      print("consensus")
      tiles$consensus<-consensus(ptlist=tiles)
    }

    #For each method compute result statistics
    tree_las<-list()
    for(i in 1:length(tiles)){
      ind_trees= split(tiles[[i]]@data, tiles[[i]]@data$treeID)
      tree_las[[i]] = lapply(ind_trees, LAS, header = tile@header)
    }
    tree_las<-do.call(c, tree_las)
    result[[g]]<-tree_las
  }
  #give result list the input file names
  names(results)<-path_to_tiles
  return(results)
}
