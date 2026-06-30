#!/bin/bash

# to stop error
set -e

echo "=========================================================="
echo "Starting Pure Bash Genomic Pipeline 
echo "=========================================================="

# --- 1. Paths and Parameters Setup ---
# Apne experimental files paths setting
FASTQ_INPUT="/mnt/f/New Volume (F:)/raw_reads.fastq.gz"
REF_GENOME="/mnt/f/New Volume (F:)/ref_genome.fasta"
OUTPUT_DIR="/mnt/f/New Volume (F:)/nextflow_variant_output"

# Clair3 specific parameters (local conda/system path)
MODEL_PATH="/opt/conda/bin/clair3_models/ont"
PLATFORM="ont"
THREADS=4

# making temporary and output folders for Interim files 
ALIGN_DIR="${OUTPUT_DIR}/alignment"
VARIANT_DIR="${OUTPUT_DIR}/variants"

mkdir -p "$ALIGN_DIR"
mkdir -p "$VARIANT_DIR"

# --- 2. Step 1: Alignment using minimap2 ---
echo -e "\n[STEP 1] Aligning Raw FASTQ reads to Reference Genome..."

minimap2 -ax map-ont -t "$THREADS" "$REF_GENOME" "$FASTQ_INPUT" > "${ALIGN_DIR}/aligned.sam"

# --- 3. Step 2: Convert SAM to BAM, Sort, and Index using samtools ---
echo -e "\n[STEP 2] Sorting and Indexing BAM file..."

# SAM to BAM  convert and sorting
samtools sort -@ "$THREADS" -o "${ALIGN_DIR}/sorted.bam" "${ALIGN_DIR}/aligned.sam"

# Sorted BAM index (.bai) file 
samtools index -@ "$THREADS" "${ALIGN_DIR}/sorted.bam"

# Temporary heavy SAM file delete to save space 
rm "${ALIGN_DIR}/aligned.sam"

# --- 4. Step 3: Variant Calling using Clair3 ---
echo -e "\n[STEP 3] Running Clair3 Variant Calling..."

run_clair3.sh \
    --bam_fn="${ALIGN_DIR}/sorted.bam" \
    --ref_fn="$REF_GENOME" \
    --output="$VARIANT_DIR" \
    --platform="$PLATFORM" \
    --model_path="$MODEL_PATH" \
    --threads="$THREADS"

echo "=========================================================="
echo "Pipeline Completed Successfully!"
echo "Final Variants VCF located at: ${VARIANT_DIR}/merge_output.vcf.gz"
echo "=========================================================="
