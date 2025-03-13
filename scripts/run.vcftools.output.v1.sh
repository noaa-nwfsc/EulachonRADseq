#!/bin/bash
#SBATCH --job-name=vcfoutput
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
#SBATCH --partition=standard
#SBATCH -t 5-0:0:0
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err

VER=1
BASE=/home/mnahom/Eulachon_radseq
DIR=${BASE}/process_vcf/v${VER}

cd ${DIR}

module load bio/vcftools/0.1.16

#OUTPUT stats on vcf file
vcftools --gzvcf populations.snps.vcf.gz --freq 
vcftools --gzvcf populations.snps.vcf.gz --counts 
vcftools --gzvcf populations.snps.vcf.gz --depth 
vcftools --gzvcf populations.snps.vcf.gz --site-mean-depth 
vcftools --gzvcf populations.snps.vcf.gz --site-depth 
vcftools --gzvcf populations.snps.vcf.gz --missing-indv 
vcftools --gzvcf populations.snps.vcf.gz --missing-site 
vcftools --gzvcf populations.snps.vcf.gz --site-quality 

