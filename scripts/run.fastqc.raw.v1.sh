#!/bin/bash

#SBATCH --job-name=FASTQC
#SBATCH -c 20
#SBATCH -t 0
#SBATCH --mail-user=giles.goetz@noaa.gov
#SBATCH --mail-type=ALL

module load bio/fastqc/0.11.9

BASE=/share/nwfsc/ggoetz/202310-eulachon-radseq
IN=${BASE}/raw
OUT=${BASE}/fastqc/raw

if [ ! -d ${OUT} ]; then
    mkdir -p ${OUT}
fi

cd ${BASE}

IN2=${IN}/original
OUT2=${OUT}/original
if [ ! -d ${OUT2} ]; then
    mkdir -p ${OUT2}
fi

# Original 4 Plates
fastqc \
    -t 20 \
    -o ${OUT2} \
    ${IN2}/*.gz \
    &> ${OUT2}/fastqc.log

# cowlitz
IN2=${IN}/cowlitz
OUT2=${OUT}/cowlitz
if [ ! -d ${OUT2} ]; then
    mkdir -p ${OUT2}
fi

fastqc \
    -t 20 \
    -o ${OUT2} \
    ${IN2}/*.gz \
    &> ${OUT2}/fastqc.log

# Elwha/Lyre samples
IN2=${IN}/elwha_lyre
OUT2=${OUT}/elwha_lyre
if [ ! -d ${OUT2} ]; then
    mkdir -p ${OUT2}
fi

fastqc \
    -t 20 \
    -o ${OUT2} \
    ${IN2}/*.gz \
    &> ${OUT2}/fastqc.log
