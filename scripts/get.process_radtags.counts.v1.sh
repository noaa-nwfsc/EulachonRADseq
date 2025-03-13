#!/bin/bash

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

    stacks-dist-extract \
        ${OUT_SAMPLE}/process_radtags.${ID}.v${VER}.full.log \
        per_barcode_raw_read_counts \
        &> ${OUT_SAMPLE}/process_radtags.${ID}.v${VER}.counts.tsv

done
