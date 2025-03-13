#!/bin/bash

#SBATCH --job-name=BWAIndexFG
#SBATCH --output=BWAIndexFG.%A.txt

#SBATCH --mail-user=giles.goetz@noaa.gov
#SBATCH --mail-type=ALL

#SBATCH -c 20
#SBATCH -t 0

BASE=/share/nwfsc/ggoetz/202310-eulachon-radseq
IN=${BASE}/ref
REF=${IN}/GCA_023658055.1_Tpac_2.0_genomic.fna

module load aligners/bwa/0.7.17

bwa index ${REF} &> ${IN}/bwa.index.full_genome.log
