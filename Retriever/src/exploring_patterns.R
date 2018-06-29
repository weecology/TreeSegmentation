trash <- function(){
  colnames(final_traits_data)
  library(dplyr)
  library(corrplot)
  dat <- final_traits_data %>%
    select(c("taxonID","nlcdClass", "elevation", "decimalLatitude","decimalLongitude", "LMA_freshWeight" ,"leafArea","leafMassPerArea",
             "ligninPercent", "cellulosePercent", "d15N","d13C", "foliarPhosphorusConc", "foliarPotassiumConc","foliarCalciumConc","foliarMagnesiumConc","foliarSulfurConc",
             "foliarManganeseConc","foliarIronConc","foliarCopperConc","foliarBoronConc","foliarZincConc", "extractChlAConc","extractChlBConc","extractCarotConc", "nitrogenPercent","carbonPercent","CNratio"    ))
  
  dat$taxonID <- factor(dat$taxonID)
  dat$nlcdClass <- factor(dat$nlcdClass)
  
  pairs(dat)
  corrplot(dat, method="number")
  coorrmatrix <- as.data.frame(cor(dat[-c(1:2)], use = "complete.obs"))
  plot(coorrmatrix$elevation[-c(1:3)])
  plot(coorrmatrix$decimalLatitude[-c(1:3)])
  plot(coorrmatrix$decimalLongitude[-c(1:3)])
  
  library(tidyverse)
  token = 6
  trait <-colnames(dat[token])
  ggplot(dat, aes_string("elevation", trait)) + geom_point(aes(color = nlcdClass )) + facet_wrap(~ taxonID)
  token = token +1
  
  dat$foliarIronConc[which(dat$foliarIronConc > 250)] <- NA
  dat$foliarCopperConc[which(dat$foliarCopperConc > 250)] <- NA
  
  data_long <- gather(dat, tr_name,tr_value, leafArea:CNratio, factor_key=TRUE)
  ggplot(data_long, aes(decimalLatitude, tr_value)) + geom_point(aes(color = taxonID)) + facet_wrap(~ tr_name, scales = "free")
  ggplot(data_long, aes(decimalLatitude, tr_value)) + geom_point(aes(color = nlcdClass)) + facet_wrap(~ tr_name, scales = "free")
  
  elev_site <- final_traits_data %>%
    select(siteID.x, elevation)
  unique(elev_site)
}