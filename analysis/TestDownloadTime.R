#Test Download time for the NEON AOP API
library(gdata)
library(downloader)
library(jsonlite)
library(httr)

dpID = "DP1.30003.001"
site = "SJER"
filepath="Test"

productUrl <- paste0("http://data.neonscience.org/api/v0/products/", dpID)
req <- httr::GET(productUrl)
avail <- jsonlite::fromJSON(httr::content(req, as="text"), simplifyDataFrame=TRUE, flatten=TRUE)

# get the urls for months with data available, and subset to site
month.urls <- unlist(avail$data$siteCodes$availableDataUrls)
month.urls <- month.urls[grep(paste(site, year, sep="/"), month.urls)]

#Define functions
getFileUrls <- function(m.urls){
  url.messages <- character()
  file.urls <- c(NA, NA, NA)
  for(i in 1:length(m.urls)) {
    tmp <- httr::GET(m.urls[i])
    tmp.files <- jsonlite::fromJSON(httr::content(tmp, as="text"),
                                    simplifyDataFrame=T, flatten=T)
    
    # check for no files
    if(length(tmp.files$data$files)==0) {
      url.messages <- c(url.messages, paste("No files found for site", tmp.files$data$siteCode,
                                            "and year", tmp.files$data$month, sep=" "))
      next
    }
    
    file.urls <- rbind(file.urls, cbind(tmp.files$data$files$name,
                                        tmp.files$data$files$url,
                                        tmp.files$data$files$size))
    
    # get size info
    file.urls <- data.frame(file.urls, row.names=NULL)
    colnames(file.urls) <- c("name", "URL", "size")
    file.urls$URL <- as.character(file.urls$URL)
    file.urls$name <- as.character(file.urls$name)
    
    if(length(url.messages) > 0){writeLines(url.messages)}
    file.urls <- file.urls[-1, ]
    return(file.urls)
  }
}

download_file<-function(file.urls.current,filepath,month.urls){
  # copy zip files into folder
  j <- 1
  messages <- list()
  while(j <= nrow(file.urls.current)) {
    path1 <- strsplit(file.urls.current$URL[j], "\\?")[[1]][1]
    pathparts <- strsplit(path1, "\\/")
    path2 <- paste(pathparts[[1]][4:(length(pathparts[[1]])-1)], collapse="/")
    newpath <- paste0(filepath, "/", path2)
    
    if(dir.exists(newpath) == F) dir.create(newpath, recursive = T)
    dtime<-system.time(t <- try(downloader::download(file.urls.current$URL[j],
                                  paste(newpath, file.urls.current$name[j], sep="/"),
                                  mode="wb"), silent = T))
    
    downld.size <- sum(as.numeric(as.character(file.urls.current$size)), na.rm=T)
    bytes_per_second<-downld.size / dtime[3]
    speed<- humanReadable(bytes_per_second, units = "auto", standard = "SI")
    
    print(paste("Estimated download speed of",speed,"per second"))
    
    if(class(t) == "try-error"){
      writeLines("File could not be downloaded. URLs may have expired. Getting new URLs.")
      file.urls.new <- getFileUrls(month.urls)
      file.urls.current <- file.urls.new
      writeLines("Continuing downloads.")}
    if(class(t) != "try-error"){
      messages[j] <- paste(file.urls.current$name[j], "downloaded to", newpath, sep=" ")
      j = j + 1
    }
  }
  writeLines(paste("Successfully downloaded ", length(messages), " files."))
  writeLines(paste0(messages, collapse = "\n"))
}

file.urls.current <- getFileUrls(month.urls)

#Just grab the first file
file.urls.current<-file.urls.current[1,]

print("Download file")
download_file(file.urls.current,filepath =filepath,month.urls = month.urls)



