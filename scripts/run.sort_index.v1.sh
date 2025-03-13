#!/bin/bash
#SBATCH --job-name=sort_index
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
#SBATCH --partition=standard
#SBATCH -t 5-0:0:0
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err

VER=1
BASE=/home/mnahom/Eulachon_radseq
IN=${BASE}/populations/v${VER}
OUT=${BASE}/process_vcf/v${VER}

if [ ! -d ${OUT} ]; then
    mkdir -p ${OUT}
fi

cd ${BASE}

module load bio/htslib/1.19
bcftools=/home/mnahom/software/bcftools-1.21/bcftools

# sort vcf file 
$bcftools sort --max-mem 30G -O z $IN/populations.snps.vcf >$OUT/populations.snps.vcf.gz

# index the vcf file 
tabix -p vcf $OUT/populations.snps.vcf.gz
