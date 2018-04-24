#!/bin/bash
#SBATCH --job-name=submitR   # Job name
#SBATCH --mail-type=END               # Mail events (NONE, BEGIN, END, FAIL, AL$
#SBATCH --mail-user=ben.weinstein@weecology.org   # Where to send mail
#SBATCH --account=ewhite
#SBATCH --qos=ewhite-b
#SBATCH --nodes=1                 # Number of MPI ranks
#SBATCH --ntasks=1                 # Number of MPI ranks
#SBATCH --cpus-per-task=12            # Number of cores per MPI rank
#SBATCH --mem=4000
#SBATCH --time=00:59:00       #Time limit hrs:min:sec
#SBATCH --output=R.out   # Standard output and error log
#SBATCH --error=R.err

#This is a generic R submission script
module load R

Rscript --default-packages=methods CropLIDAR.R
