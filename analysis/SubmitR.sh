#!/bin/bash
#SBATCH --job-name=crop_rgb   # Job name
#SBATCH --mail-type=END               # Mail events (NONE, BEGIN, END, FAIL, AL$
#SBATCH --mail-user=ben.weinstein@weecology.org   # Where to send mail
#SBATCH --account=ewhite
#SBATCH --qos=ewhite-b
#SBATCH --nodes=1                 # Number of MPI ranks
#SBATCH --ntasks=1                 # Number of MPI ranks
#SBATCH --cpus-per-task=15            # Number of cores per MPI rank
#SBATCH --mem=20GB
#SBATCH --time=5:00:00       #Time limit hrs:min:sec
#SBATCH --output=/home/b.weinstein/logs/training.out   # Standard output and error log
#SBATCH --error=/home/b.weinstein/logs/training.err

#This is a generic R submission script
module load R
Rscript training.R
