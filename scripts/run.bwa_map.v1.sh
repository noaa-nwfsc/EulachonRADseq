#!/bin/bash

#SBATCH --job-name=BWA
#SBATCH --output=BWA.%A.%a.txt

#SBATCH --mail-user=giles.goetz@noaa.gov
#SBATCH --mail-type=ALL

#SBATCH -c 20
#SBATCH -t 0

#SBATCH --array=1-539%10

module load aligners/bwa/0.7.17

VER=1

BASE=/share/nwfsc/ggoetz/202310-eulachon-radseq
IN=${BASE}/processed_radtags/v${VER}
OUT=${BASE}/bwa/v${VER}
REF=${BASE}/ref/GCA_023658055.1_Tpac_2.0_genomic.fna

if [ ! -d ${OUT} ]; then
    mkdir -p ${OUT}
fi

FILES=$(find ${IN} -name "*.1.fq.gz" | grep -v ".rem.1.fq.gz")
FILES_ARRAY=(${FILES})
FILES_ARRAY_SIZE=${#FILES_ARRAY[@]}

FILE=${FILES_ARRAY[${SLURM_ARRAY_TASK_ID}-1]}
SAMPLE=$(echo ${FILE} | awk -F "/" '{print $NF}' | sed -e 's/.1.fq.gz//')
FOLDER=$(echo ${FILE} | awk -F "/" '{print $(NF-1)}')

if [ ! -d ${OUT}/${FOLDER} ]; then
    mkdir -p ${OUT}/${FOLDER}
fi

bwa mem \
    -t 20 \
    ${REF} \
    ${IN}/${FOLDER}/${SAMPLE}.1.fq.gz \
    ${IN}/${FOLDER}/${SAMPLE}.2.fq.gz \
    > ${OUT}/${FOLDER}/${SAMPLE}.sam \
    2> ${OUT}/${FOLDER}/${SAMPLE}.log
