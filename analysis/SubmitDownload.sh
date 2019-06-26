#!/bin/bash
#SBATCH --job-name=download   # Job name
#SBATCH --mail-type=END               # Mail events (NONE, BEGIN, END, FAIL, AL$
#SBATCH --mail-user=ben.weinstein@weecology.org   # Where to send mail
#SBATCH --account=ewhite
#SBATCH --qos=ewhite-b
#SBATCH --ntasks=1                 # Number of MPI ranks
#SBATCH --cpus-per-task=1            # Number of cores per MPI rank
#SBATCH --mem-per-cpu=5GB
#SBATCH --time=72:00:00       #Time limit hrs:min:sec
#SBATCH --output=/home/b.weinstein/logs/download_plots.out   # Standard output and error log
#SBATCH --error=/home/b.weinstein/logs/download_plots.err

#This is a generic R submission script
module load R gcc gdal
Rscript Process_NEON_Plots.R

#Ugly dependency on gdal versions, best to be invoked seperately.
module unload module unload python3-core/3.6.5
Rscript Process_Hyperspectral_Plots.R
