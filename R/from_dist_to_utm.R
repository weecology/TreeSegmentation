#' Convert coordinates to utms
#' \code{from_dist_to_utm} converts azimuth distance to utm coodinates
#' @param dista Distance from point
#' @param angle Angle from point
#' @param xcord X distance
#' @param ycord Y distance
#' @return A stacked file in /data/ with desired product across sites
#' @export
#'
from_dist_to_utm <- function(dista, angle, xcord, ycord){

  #Angle is expected in degrees.

  #Return NA if no angle.
  if(is.na(angle)){
    return(c(NA,NA))
  }

  if(angle <= 90){
    adj.ang <- (angle*pi)/180
    y.shift <- dista * cos(adj.ang)
    x.shift <- dista * sin(adj.ang)
    point.coords <- c(xcord + x.shift, ycord + y.shift)
  }else{
    if(angle > 90 & angle <= 180){
      adj.ang <-  ((angle - 90)*pi)/180
      x.shift <- dista * cos(adj.ang)
      y.shift <- dista * sin(adj.ang)
      point.coords <- c(xcord + x.shift, ycord - y.shift)
    }else{
      if(angle > 180 & angle <= 270){
        adj.ang <- ((angle - 180)*pi)/180
        x.shift <- dista * sin(adj.ang)
        y.shift <- dista * cos(adj.ang)
        point.coords <- c(xcord - x.shift, ycord - y.shift)
      }else{
        adj.ang <- ((angle -270)*pi)/180
        x.shift <- dista * cos(adj.ang)
        y.shift <- dista * sin(adj.ang)
        point.coords <- c(xcord - x.shift, ycord + y.shift)
      }
    }
  }
  return(point.coords)
}
