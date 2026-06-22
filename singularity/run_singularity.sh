#!/bin/bash
set -e

CONTAINER_NAME="clinical_pipeline.sif"
RECIPE_FILE="pipeline.def"

# Real paths setup
REF_GENOME="/mnt/f/New Volume (F:)/ref_genome.fasta"
INPUT_BAM="/mnt/f/New Volume (F:)/aligned_reads.bam"
OUTPUT_DIR="/mnt/f/New Volume (F:)/variant_output"

# 1. Build the container if it doesn't exist
if [ ! -f "$CONTAINER_NAME" ]; then
    echo "Building Singularity container with Clair3..."
    sudo singularity build "$CONTAINER_NAME" "$RECIPE_FILE"
fi

echo "Testing Clair3 inside container..."
singularity run "$CONTAINER_NAME"

echo "Starting Clair3 Variant Calling Example..."
# singularity exec -B /mnt:/mnt "$CONTAINER_NAME" \
#   run_clair3.sh \
#   --bam_fn="$INPUT_BAM" \
#   --ref_fn="$REF_GENOME" \
#   --output="$OUTPUT_DIR" \
#   --platform="ont" \
#   --model_path="/opt/conda/bin/clair3_models/ont"

echo "Workflow configuration script ready for Clair3."