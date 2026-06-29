#!/bin/bash
set -e

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_DIR="${SCRIPT_DIR}/containers"
CONTAINER_NAME="${CONTAINER_DIR}/pipeline.sif"
RECIPE_FILE="${SCRIPT_DIR}/Singularity.def"

# Real Windows/WSL paths setup
FASTQ_INPUT="/mnt/f/New Volume (F:)/raw_reads.fastq.gz"
REF_GENOME="/mnt/f/New Volume (F:)/ref_genome.fasta"
OUTPUT_DIR="/mnt/f/New Volume (F:)/nextflow_variant_output"

# Ensure containers directory exists
mkdir -p "$CONTAINER_DIR"

# 1. Build the container if it doesn't exist
if [ ! -f "$CONTAINER_NAME" ]; then
    echo "=========================================================="
    echo "Building Singularity container from recipe..."
    echo "=========================================================="
    sudo singularity build "$CONTAINER_NAME" "$RECIPE_FILE"
else
    echo "Container already exists at: $CONTAINER_NAME"
fi

# 2. Test the container integrity
echo "Testing tools inside container..."
singularity run "$CONTAINER_NAME"

# 3. Launch the Nextflow Pipeline with Singularity Profile
echo "=========================================================="
echo "Starting End-to-End Nextflow Genomic Pipeline"
echo "=========================================================="

nextflow run main.nf \
    -profile singularity \
    --fastq "$FASTQ_INPUT" \
    --ref_genome "$REF_GENOME" \
    --outdir "$OUTPUT_DIR" \
    --threads 4

echo "=========================================================="
echo "Pipeline finished successfully!"
echo "=========================================================="
