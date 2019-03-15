#!/bin/bash

#SBATCH --job-name=getCrData    # Job name
#SBATCH --mail-type=END               # Mail events (NONE, BEGIN, END, FAIL, AL$
#SBATCH --mail-user=ben.weinstein@weecology.org   # Where to send mail
#SBATCH --account=ewhite
#SBATCH --qos=ewhite

#SBATCH --ntasks=1                 # Number of MPI ranks
#SBATCH --cpus-per-task=1            # Number of cores per MPI rank
#SBATCH --mem=200
#SBATCH --time=700:00:00       #Time limit hrs:min:sec
#SBATCH --output=itc.out   # Standard output and error log
#SBATCH --error=itc.err

pwd; hostname; date
module load R
echo "get data"
echo

Rscript ./getNEON_AOP.R $1 $2 $3
echo "done"

date
