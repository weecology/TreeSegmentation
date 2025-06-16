#' Clip CHM Data Based on Neon Plots
#'
#' \code{crop_CHM_plots} overlays the polygons of the NEON plots with the derived CHM image
#' @param site_name NEON site abbreviation (e.g. "HARV")
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @export
#'
crop_CHM_plots <- function(site_name = "TEAK", year = "2018") {
  # Check if site_name is valid
  if (is.na(site_name) || site_name == "") {
    stop("Invalid site_name provided")
  }

  # Read plots with error handling
  tryCatch({
    plots <- sf::st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V7/All_NEON_TOS_Plot_Polygons_V7.shp")
  }, error = function(e) {
    stop(paste("Error reading plot shapefile:", e$message))
  })

  # Only baseplots
  site_plots <- plots %>% 
    filter(siteID == site_name, subtype == "basePlot")

  # Check if any plots exist
  if (nrow(site_plots) == 0) {
    warning(paste("No site plots found for site:", site_name))
    return(NULL)
  }

  # Generic path
  generic_path <- file.path("/orange/ewhite/NeonData", site_name, "DP3.30015.001")
    
  # Check if directory exists
  if (!dir.exists(generic_path)) {
    warning(paste("Directory not found:", generic_path))
    return(NULL)
  }

  chm_files <- list.files(generic_path, full.names = TRUE, pattern = "CHM.tif", recursive = TRUE)

  # filter by year
  chm_files <- chm_files[stringr::str_detect(chm_files, year)]

  if (length(chm_files) == 0) {
    warning(paste(site_name, "No CHM files available"))
    return(NULL)
  }

  # Read first raster for projection
  tryCatch({
    r <- raster::stack(chm_files[1])
  }, error = function(e) {
    stop(paste("Error reading CHM file:", e$message))
  })

  # Project plots
  site_plots <- sf::st_transform(site_plots, crs = raster::projection(r))

  # Create directory if needed
  fold <- file.path("/orange/ewhite/b.weinstein/NEON", site_name, year, "NEONPlots/CHM")
  if (!dir.exists(fold)) {
    dir.create(fold, recursive = TRUE)
  }

  for (x in 1:nrow(site_plots)) {
    tryCatch({
      plotid <- site_plots[x,]$plotID
      if (is.na(plotid)) {
        warning(paste("Skipping plot with NA plotID at index", x))
        next
      }

      ext <- raster::extent(site_plots[x,])
      if (any(is.na(c(ext@xmin, ext@xmax, ext@ymin, ext@ymax)))) {
        warning(paste("Skipping plot with invalid extent at index", x))
        next
      }

      # Construct filename
      cname <- file.path(fold, paste0(plotid, "CHM_", year, ".tif"))

      # Check if already complete
      if (file.exists(cname)) {
        print(paste(cname, "exists"))
        next
      }

      # Find CHM file
      easting <- as.integer(ext@xmin/1000)*1000
      northing <- as.integer(ext@ymin/1000)*1000
      geo_index <- paste(easting, northing, sep = "_")

      # Find corresponding h5 tile
      tif_path <- chm_files[stringr::str_detect(chm_files, geo_index)]

      # If exists
      if (length(tif_path) == 0) {
        warning(paste("No matching CHM file found for plot", plotid))
        next
      }

      CHM <- raster::raster(tif_path)
      cropped_CHM <- raster::crop(CHM, ext)

      raster::writeRaster(cropped_CHM, cname, overwrite = TRUE)
    }, error = function(e) {
      warning(paste("Error processing plot", x, ":", e$message))
    })
  }
}
