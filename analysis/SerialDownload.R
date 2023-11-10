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
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2017",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2018",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2019",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2020",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2021",check.size=F, savepath=fold),error=function(e){print(e)})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2022",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2023",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2017",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30010.001",site = site,year="2013",check.size=F, savepath=fold),error=function(e){})

  #LIDAR
  tryCatch(neonUtilities::byFileAOP(dpID = "DP1.30003.001",site = site,year="2017",check.size=F, savepath=fold),error=function(e){})
  tryCatch(neonUtilities::byFileAOP(dpID = "DP1.30003.001",site = site,year="2018",check.size=F, savepath=fold),error=function(e){})
  tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30003.001",site = site,year="2019",check.size=F, savepath=fold),error=function(e){})
  tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30003.001",site = site,year="2020",check.size=F, savepath=fold),error=function(e){})
  tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30003.001",site = site,year="2020",check.size=F, savepath=fold),error=function(e){})
  tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30003.001",site = site,year="2021",check.size=F, savepath=fold),error=function(e){})
  tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30003.001",site = site,year="2022",check.size=F, savepath=fold),error=function(e){})
  tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30003.001",site = site,year="2023",check.size=F, savepath=fold),error=function(e){})
  #Hyperspec
  #Check directory first
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2018",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2019",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2020",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2021",check.size=F, savepath=fold),error=function(e){})
  #tryCatch(neonUtilities::byFileAOP(dpID = "DP3.30006.001",site = site,year="2023",check.size=F, savepath=fold),error=function(e){})
}


sites<-c("SERC","BART","BLAN","BONA","CLBJ","DEJU","DELA","GRSM",
"HARV","JERC","LENO","MLBS","NIWO","OSBS","RMNP","SCBI","SERC","SJER","SOAP","STEI","TALL","TEAK","UKFS","UNDE","WREF","YELL","GUAN")
#sites<-c("TALL")

for (x in sites){
	pdownload(site=x)
}
