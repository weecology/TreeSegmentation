#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = FALSE)


library(devtools)
library(neonUtilities)

print(args)

#neon product id
prd = args[6]
#neon site to download the product for
ste = args[7]
#year to download
yr = args[8]
byFileAOP(prd, site = ste, year = yr, check.size=F, savepath = paste("/orange/ewhite/NeonData/",  ste, sep=""))
