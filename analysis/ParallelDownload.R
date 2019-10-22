### Download AOP data tiles in parallel

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)

library(neonUtilities)

#TO DO, make %dopar% available without load
library(foreach)

sites=c("SJER","TEAK","NIWO","MLBS","BART","BLAN","BONA","CLBJ","DELA","DSNY","HARV","JERC","LENO","ONAQ","OSBS","SCBI","SOAP","TALL","UNDE","WREF")

for(site in sites){
  print(site)
  fold<-paste("/orange/ewhite/NeonData/",site=site,sep="")

  #RGB
  ParallelFileAOP(dpID = "DP3.30010.001",site = site,year="2019",check.size=F, savepath=fold,cores=20)

  #LIDAR
  #ParallelFileAOP(dpID = "DP1.30003.001",site = site,year="2018",check.size=F, savepath=fold,cores=5)

  #Hyperspec
  #ParallelFileAOP(dpID = "DP3.30006.001",site = site,year="2018",check.size=F, savepath=fold,cores=5)

}
