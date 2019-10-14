library(TreeSegmentation)
library(dplyr)
#Questions for field data
dat<-read.csv("../data/Terrestrial/field_data.csv")

#only higher quality data
dat<-dat %>% filter(!dat$crdSource=="GIS")

#nothing from before 2016.
dat<-dat[!stringr::str_detect(dat$eventID,c("2015|2014")),]

#search for bole duplicates, ending in a letter
field_data<-dat %>% filter(siteID == site)
field_data<-field_data %>% filter(!is.na(as.numeric(stringr::str_sub(individualID,-1))))

#Individual trees
trees<-field_data  %>% filter(!is.na(UTM_E))
a<-dat %>% group_by(individualID,eventID) %>% summarize(n=n(),site=unique(siteID)) %>% filter(n>1)
table(a$site)

#2014 data don't seem as trustworthy? Just abandon?


#enormous tree in clbj_051? OSBS_028,
#missing event id year in vst_UNDE_
# duplicate ids in NEON.PLA.D05.STEI.01071A, NEON.PLA.D14.SRER.01112

#The goal showing individual examples is not to obsess over a detail, but rather try to understand if there are larger systemic issues in the way we handling the data
#see JERC_063

#This function works
plot_lidar_data("SJER_015")
plot_lidar_data("TALL_042")

plot_lidar_data("BONA_005")

# #multibole
# ```NEON.PLA.D07.MLBS.01063```
#
# is from 2015
# ```NEON.PLA.D07.MLBS.01063A```
# is from 2017
# there is no
# ```NEON.PLA.D07.MLBS.01063```
# in the 2017 data


#what controls whether a point gets a height
# BONA_005, missing tree example()
# NEON.PLA.D19.BONA.03528 does not
#
# but NEON.PLA.D19.BONA.03062, they are the same year, 1m from each other.
plot_lidar_data("CLBJ_040")

#NEON.PLA.D11.CLBJ.01505 is misplaced.

plot_lidar_data("MLBS_074")

