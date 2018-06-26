#!/bin/bash
#SBATCH --job-name=detection   # Job name
#SBATCH --mail-type=END               # Mail events (NONE, BEGIN, END, FAIL, AL$
#SBATCH --mail-user=ben.weinstein@weecology.org   # Where to send mail
#SBATCH --account=ewhite
#SBATCH --qos=ewhite-b
#SBATCH --ntasks=1                 # Number of MPI ranks
#SBATCH --cpus-per-task=10            # Number of cores per MPI rank
#SBATCH --mem-per-cpu=20GB
#SBATCH --time=12:00:00       #Time limit hrs:min:sec
#SBATCH --output=/home/b.weinstein/logs/detection.out   # Standard output and error log
#SBATCH --error=/home/b.weinstein/logs/detection.err

#This is a generic R submission script
module load gcc/6.3.0 R/3.4.3 gdal/2.2.1
Rscript detection_training.R
