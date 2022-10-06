### Download AOP data tiles in parallel

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)
## Detection network training
library(TreeSegmentation)
library(stringr)
library(neonUtilities)

pdownload<-function(site,year="2018"){
  print(site)
  fold<-paste("/orange/ewhite/NeonData/",site=site,sep="")

  #try catch all
  #RGB
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2014",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2015",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2022",check.size=F, savepath=fold),error=function(e){print(e)})
  #neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2022",check.size=F, savepath=fold)

#tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2017",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2013",check.size=F, savepath=fold),error=function(e){})

  #LIDAR
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP1.30003.001",site = site,year="2017",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP1.30003.001",site = site,year="2022",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30015.001",site = site,year="2021",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30015.001",site = site,year="2022",check.size=F, savepath=fold),error=function(e){})

  #Hyperspec
  #Check directory first
  if(!dir.exists(paste(fold,"DP3.30006.001","2018",sep="/"))){
    tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2018",check.size=F, savepath=fold),error=function(e){})
  }

  if(!dir.exists(paste(fold,"DP3.30006.001","2019",sep="/"))){
    tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2019",check.size=F, savepath=fold),error=function(e){})
  }

  if(!dir.exists(paste(fold,"DP3.30006.001","2021",sep="/"))){
    tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2021",check.size=F, savepath=fold),error=function(e){})
  }

  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2019",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2021",check.size=F, savepath=fold),error=function(e){})
}


sites<-c("ABBY","ARIK","BARR","BART","BLAN","BONA","CLBJ","CPER","CUPE","DEJU","DELA","DSNY","GRSM","GUAN",
"GUIL","HARV","HEAL","HOPB","JERC","JORN","KONZ","LAJA","LENO","LIRO","MCDI","MLBS","MOAB","NIWO","NOGP","OAES","OSBS","PRIN","PUUM","REDB","RMNP","SCBI","SERC","SJER","SOAP","SRER","STEI","STER","TALL","TEAK","TOOL","UKFS","UNDE","WLOU","WOOD","WREF","YELL")

#sites <- c("SCBI","HARV")

for (x in sites){
	pdownload(site=x)
}
