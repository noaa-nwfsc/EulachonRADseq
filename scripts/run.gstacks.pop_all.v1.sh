#!/bin/bash

#SBATCH --job-name=Eula_GS
#SBATCH --output=Eula_GS.%A.txt
#SBATCH -c 20
#SBATCH -t 0
#SBATCH --mail-user=giles.goetz@noaa.gov
#SBATCH --mail-type=ALL

module load bio/stacks/2.65

VER=1
BASE=/share/nwfsc/ggoetz/202310-eulachon-radseq
IN=${BASE}/samtools/v${VER}
OUT=${BASE}/gstacks/v${VER}
POPMAP=${BASE}/data/popmap.all.txt

if [ ! -d ${OUT} ]; then
    mkdir -p ${OUT}
fi

cd ${BASE}

gstacks \
    -I ${IN} \
    -M ${POPMAP} \
    -S .sorted.bam \
    -O ${OUT} \
    -t 20 \
    &> ${OUT}/gstacks.log
