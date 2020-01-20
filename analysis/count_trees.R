library(NeonTreeEvaluation)
library(dplyr)
library(stringr)
a<-list.files("/Users/Ben/Documents/NeonTreeEvaluation/evaluation/RGB",full.names = T)
plot_names<-str_match(a,"/(\\w+).tif")[,2]
plot_names<-plot_names[!is.na(plot_names)]
plot_names<-unique(plot_names)
b<-bind_rows(lapply( plot_names, function(x) {
  path<-get_data(plot_name=x,"annotations")
  try(xml_parse(path),return(NULL))
  }))

results<-b %>% mutate(Site=str_match(filename,"(\\w+)_")[,2])

#Two awkward sites do to naming structure.
results[stringr::str_detect(results$filename,"2018_SJER"),"Site"]<-"SJER"
results[stringr::str_detect(results$filename,"2018_TEAK"),"Site"]<-"TEAK"

table(results$Site)

