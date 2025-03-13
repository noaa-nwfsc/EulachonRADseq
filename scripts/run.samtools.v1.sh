#!/bin/bash

#SBATCH --job-name=EulaSAM

#SBATCH -c 20
#SBATCH -t 0

#SBATCH --mail-user=giles.goetz@noaa.gov
#SBATCH --mail-type=ALL

module load bio/samtools/1.19

VER=1
BASE=/share/nwfsc/ggoetz/202310-eulachon-radseq
IN=${BASE}/bwa/v${VER}
OUT=${BASE}/samtools/v${VER}
REF=${BASE}/ref/GCA_023658055.1_Tpac_2.0_genomic.fna

if [ ! -d ${OUT} ]; then
    mkdir -p ${OUT}
fi

FOLDERS=$(ls -1 ${IN})
for FOLDER in ${FOLDERS}
do
    FILES=$(ls -1 ${IN}/${FOLDER}/*.sam)
    for FILE in ${FILES}
    do
        SAMPLE=$(echo ${FILE} | awk -F "/" '{print $NF}' | sed -e 's/.sam//')
        echo ${FOLDER} ${SAMPLE}

        samtools flagstat \
            --threads 20 \
            ${IN}/${FOLDER}/${SAMPLE}.sam \
            > ${OUT}/${SAMPLE}.flagstat.txt

        samtools flagstat \
            --threads 20 \
            -O tsv \
            ${IN}/${FOLDER}/${SAMPLE}.sam \
            > ${OUT}/${SAMPLE}.flagstat.tsv

        samtools view \
            --threads 20 \
            -b \
            -T ${REF} \
            ${IN}/${FOLDER}/${SAMPLE}.sam \
            > ${OUT}/${SAMPLE}.bam

        samtools sort \
            --threads 20 \
            ${OUT}/${SAMPLE}.bam \
            > ${OUT}/${SAMPLE}.sorted.bam

        samtools index \
            --threads 20 \
            ${OUT}/${SAMPLE}.sorted.bam

    done 
done
