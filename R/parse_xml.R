#' Site wrapper for calculating recall and precision from IoU overlap for a NEON site.
#' @param site Character. NEON Site code
#' @return a data.frame object with the spatial polygons of the ground truth annotations
#' @export
#'

parse_xml<-function(site){
  file_list<-list.files(paste("../data/NeonTreeEvaluation/",site,"/annotations/",sep=""),pattern=paste(site,"_0",sep=""),full.names = T)
  dat<-bind_rows(lapply(file_list,parser))
  return(dat)
  }

  parser<-function(fil){
    pg <- xml2::read_xml(fil)

    # get all the <record>s
    recs <- xml2::xml_find_all(pg, "//name")
    names <- trimws(xml2::xml_text(recs))

    recs <- xml2::xml_find_all(pg, "//xmin")

    # extract and clean all the columns
    xmin <- trimws(xml2::xml_text(recs))

    # get all the <record>s
    recs <- xml2::xml_find_all(pg, "//ymin")

    # extract and clean all the columns
    ymin <- trimws(xml2::xml_text(recs))

    # get all the <record>s
    recs <- xml2::xml_find_all(pg, "//ymax")

    # extract and clean all the columns
    ymax <- trimws(xml2::xml_text(recs))

    # get all the <record>s
    recs <- xml2::xml_find_all(pg, "//xmax")

    # extract and clean all the columns
    xmax <- trimws(xml2::xml_text(recs))

    recs <- xml2::xml_find_all(pg, "//filename")
    filename <- trimws(xml2::xml_text(recs))

    #Multiple by cell size
    df<-data.frame(filename,xmin=as.numeric(xmin)*0.1,xmax=as.numeric(xmax)*0.1,ymin=as.numeric(ymin)*0.1,ymax=as.numeric(ymax)*0.1,name=names)
    return(df)
  }
