### Download plots and clip to tile extent

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)

library(foreach)
library(doSNOW)

###Download RGB and LIDAR, HyperSpec tiles
sites<-c("ARIK","BARR","BART","BONA","CLBJ","CPER","CUPE","DEJU","DELA","DSNY","GRSM","GUAN",
"GUIL","HARV","HEAL","HOPB","HOPB","JERC","JORN","KONZ","LAJA","LENO","LIRO","MCDI","MLBS","MOAB","NIWO","NOGP","OAES","OSBS","PRIN","REDB","RMNP","SCBI","SERC","SJER","SOAP","SRER","STEI","STER","TALL","TEAK","TOOL","UKFS","UNDE","WLOU","WOOD","WREF")

cl<-makeCluster(5,outfile="")
registerDoSNOW(cl)

foreach(x=1:length(sites),.packages=c("neonUtilities","TreeSegmentation","dplyr"),.errorhandling = "pass") %dopar% {
  fold<-paste("/orange/ewhite/NeonData/",sites[x],sep="")
  byPointsAOP(dpID="DP3.30010.001",site=sites[x],year="2017",check.size=F, savepath=fold)
  byPointsAOP(dpID="DP3.30010.001",site=sites[x],year="2018",check.size=F, savepath=fold)
  #byPointsAOP(dpID="DP1.30003.001",site=sites[x],year="2018",check.size=F, savepath=fold)
  #byPointsAOP(dpID="DP1.30006.001",site=sites[x],year="2017",check.size=F, savepath=fold)
  ##Cut Tiles
  #crop_rgb_plots(sites[x])
  #crop_lidar_plots(sites[x])
}
