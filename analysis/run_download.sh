#!/bin/bash
#SBATCH --job-name=download_data    # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ben.weinstein@weecology.org     # Where to send mail	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --account=ewhite
#SBATCH --mem=5gb                     # Job memory request
#SBATCH --time=48:00:00               # Time limit hrs:min:sec
#SBATCH --error=/home/b.weinstein/logs/download.err
#SBATCH --output=/home/b.weinstein/logs/download.out   # Standard output and error log
pwd; hostname; date

ml R

Rscript DownloadData.R
