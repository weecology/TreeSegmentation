#!/bin/bash
#SBATCH --job-name=downloadparallel   # Job name
#SBATCH --mail-type=END               # Mail events (NONE, BEGIN, END, FAIL, AL$
#SBATCH --mail-user=ben.weinstein@weecology.org   # Where to send mail
#SBATCH --account=ewhite
#SBATCH --qos=ewhite-b
#SBATCH --ntasks=1                 # Number of MPI ranks
#SBATCH --cpus-per-task=5            # Number of cores per MPI rank
#SBATCH --mem-per-cpu=5GB
#SBATCH --time=72:00:00       #Time limit hrs:min:sec
#SBATCH --output=/home/b.weinstein/logs/paralleldownload.out   # Standard output and error log
#SBATCH --error=/home/b.weinstein/logs/paralleldownload.err

#This is a generic R submission script
module load R gcc gdal
Rscript ParallelDownload.R
