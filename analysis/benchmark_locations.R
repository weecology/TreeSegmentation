library(NeonTreeEvaluation)
library(dplyr)
library(stringr)

dat<-plots %>% as.data.frame() %>% dplyr::select(plotID,easting,northing) %>%
  mutate(easting=as.integer(easting/1000)*1000,northing=as.integer(northing/1000)*1000) %>%
  mutate(geo_index=paste(easting,northing,sep="_"))
head(dat)

a<-read.table("/Users/Ben/Documents/NeonTreeEvaluation/evaluation/RGB/out.csv")
a<-tidyr::gather(a)$value
a<-data.frame(plotID=a,str_match(a,"\\d+_(\\d+)_(\\d+)_image")[,2:3])
colnames(a)<-c("plotID","easting","northing")
a$easting<-as.character(a$easting)
a$northing<-as.character(a$northing)
a$geo_index<-paste(a$easting,a$northing,sep="_")

dat$easting<-as.character(dat$easting)
dat$northing<-as.character(dat$northing)

dat<-bind_rows(list(dat,a))
write.csv(dat,"/Users/Ben/Documents/NeonTreeEvaluation/evaluation/RGB/benchmark_locations.csv",row.names = F)

data.frame()
