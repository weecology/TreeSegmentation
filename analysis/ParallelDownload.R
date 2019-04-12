### Download AOP data tiles in parallel

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)

library(neonUtilities)

#TO DO, make %dopar% available without load
library(foreach)

site="BART"

fold<-paste("/orange/ewhite/NeonData/",site=site,sep="")
#RGB
ParallelFileAOP(dpID = "DP3.30010.001",site = site,year="2018",check.size=F, savepath=fold,cores=10)

#LIDAR
ParallelFileAOP(dpID = "DP1.30003.001",site = site,year="2018",check.size=F, savepath=fold,cores=10)
