#!/bin/bash

#SBATCH --job-name=EulaRAD

#SBATCH --mail-user=giles.goetz@noaa.gov
#SBATCH --mail-type=ALL

#SBATCH -c 20
#SBATCH -t 0

BASE=/share/nwfsc/ggoetz/202310-eulachon-radseq

cd ${BASE}

VER=1

IN=${BASE}/raw
OUT=${BASE}/processed_radtags/v${VER}
SETUP_FILE=${BASE}/data/process_radtags_setup.txt

module load bio/stacks/2.65

if [ ! -d ${OUT} ]; then
    mkdir -p ${OUT}
fi

# Get the settings from the setup file
SAMPLES=$(cat ${SETUP_FILE})

# Loop through the samples and process them
for SAMPLE in ${SAMPLES}
do

    # Parse settings
    read -r ID LOC R1_FILE R2_FILE BARCODE_FILE <<< \
        "$(echo ${SAMPLE} | sed -e 's/|/ /g')"

    IN_SAMPLE=${IN}/${LOC}
    OUT_SAMPLE=${OUT}/${LOC}

    if [ ! -d ${OUT_SAMPLE} ]; then
        mkdir -p ${OUT_SAMPLE}
    fi

    # bestRAD 
    # -r rescue barcodes and RAD-Tag cut sites.
    # -c clean data, remove any read with an uncalled base ('N').
    # -q discard reads with low quality (phred) scores.
    # -D capture discarded reads to a file.
    process_radtags \
        -1 ${IN_SAMPLE}/${R1_FILE} \
        -2 ${IN_SAMPLE}/${R2_FILE} \
        -e sbfI \
        -b ${BASE}/barcodes/${BARCODE_FILE} \
        -o ${OUT_SAMPLE} \
        -r \
        -c \
        -q \
        -D \
        --adapter_1 AGATCGGAAGAGC \
        --adapter_2 AGATCGGAAGAGC \
        --adapter_mm 1 \
        --bestrad \
        &> ${OUT_SAMPLE}/process_radtags.${ID}.v${VER}.log

    # Rename the log file to keep process_radtags from overwriting it.
    mv ${OUT_SAMPLE}/process_radtags.${LOC}.log \
        ${OUT_SAMPLE}/process_radtags.${ID}.v${VER}.full.log
done
