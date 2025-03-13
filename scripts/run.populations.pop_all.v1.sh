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
IN=${BASE}/gstacks/v${VER}
OUT=${BASE}/populations/v${VER}
POPMAP=${BASE}/data/popmap.all.txt

if [ ! -d ${OUT} ]; then
    mkdir -p ${OUT}
fi

cd ${BASE}

populations \
    -P ${IN} \
    --vcf \
    --genepop \
    -t 20 \
    -O ${OUT} \
    -M ${POPMAP} \
    --min-mac 3 \
    > ${OUT}/populations.log \
    2> ${OUT}/populations.err


