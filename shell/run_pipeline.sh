#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================="
echo " Starting Clinical Genomics Shell Pipeline"
echo "========================================="

# 1. Paths configuration (Windows F: drive paths accessed via WSL)
REF_GENOME="/mnt/f/New Volume (F:)/ref_genome.fasta"
INPUT_BAM="/mnt/f/New Volume (F:)/aligned_reads.bam"
OUTPUT_DIR="/mnt/f/New Volume (F:)/shell_variant_output"
MODEL_PATH="/opt/conda/bin/clair3_models/ont"
PLATFORM="ont"

# 2. Input validation checks
if [ ! -f "$REF_GENOME" ]; then
    echo "ERROR: Reference genome missing at: $REF_GENOME"
    exit 1
fi

if [ ! -f "$INPUT_BAM" ]; then
    echo "ERROR: Input BAM file missing at: $INPUT_BAM"
    exit 1
fi

echo "All input files validated successfully."
echo "Running Clair3 Variant Calling via Shell..."

# 3. Execution of Clair3 command directly in Bash environment
run_clair3.sh \
    --bam_fn="$INPUT_BAM" \
    --ref_fn="$REF_GENOME" \
    --output="$OUTPUT_DIR" \
    --platform="$PLATFORM" \
    --model_path="$MODEL_PATH" \
    --threads=2

echo "========================================="
echo " Shell Pipeline Completed Successfully!"
echo " Results saved in: $OUTPUT_DIR"
echo "========================================="
