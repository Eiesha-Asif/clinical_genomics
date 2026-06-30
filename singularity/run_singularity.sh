#!/bin/bash
set -e

# --- Configuration & Paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#the singularity folder is located in the main project directory."
CONTAINER_NAME="${SCRIPT_DIR}/../singularity/pipeline.sif"
RECIPE_FILE="${SCRIPT_DIR}/../singularity/pipeline.def"

# --- Real Windows/WSL Paths Setup ---
DATA_DIR="/mnt/f/New Volume (F:)"
REF_GENOME="${DATA_DIR}/ref_genome.fasta"
INPUT_FASTQ="${DATA_DIR}/sample_reads.fastq"  # Raw Input Data

# Intermediate files (for workflow process)
OUTPUT_BAM="${DATA_DIR}/aligned_reads.bam"
SORTED_BAM="${DATA_DIR}/sorted_reads.bam"
OUTPUT_DIR="${DATA_DIR}/shell_variant_output"

# Clair3 internal parameters
MODEL_PATH="/opt/conda/share/clair3/models/ont"
PLATFORM="ont"
THREADS=4

# 1. Check if Singularity Container exists, if not build it
if [ ! -f "$CONTAINER_NAME" ]; then
    echo "=========================================================="
    echo "Building Singularity container from recipe..."
    echo "=========================================================="
    sudo singularity build "$CONTAINER_NAME" "$RECIPE_FILE"
else
    echo "Container found at: $CONTAINER_NAME"
fi

# 2. Output and Data validation
mkdir -p "$OUTPUT_DIR"

if [ ! -f "$REF_GENOME" ]; then
    echo "ERROR: Reference genome missing at $REF_GENOME"
    exit 1
fi

# --- PIPELINE EXECUTION (Inside Singularity) ---

echo "=========================================================="
echo " STEP 1: Read Alignment using Minimap2"
echo "=========================================================="
singularity exec -B "/mnt/f:/mnt/f" "$CONTAINER_NAME" \
    minimap2 -ax map-ont -t "$THREADS" "$REF_GENOME" "$INPUT_FASTQ" > "$OUTPUT_BAM"

echo "=========================================================="
echo " STEP 2: BAM Sorting & Indexing using Samtools"
echo "=========================================================="
# Sort the alignment file
singularity exec -B "/mnt/f:/mnt/f" "$CONTAINER_NAME" \
    samtools sort -@ "$THREADS" -o "$SORTED_BAM" "$OUTPUT_BAM"

# Index the sorted BAM
singularity exec -B "/mnt/f:/mnt/f" "$CONTAINER_NAME" \
    samtools index -@ "$THREADS" "$SORTED_BAM"

echo "=========================================================="
echo " STEP 3: Clair3 Variant Calling Process"
echo "=========================================================="
singularity exec -B "/mnt/f:/mnt/f" "$CONTAINER_NAME" \
    run_clair3.sh \
    --bam_fn="$SORTED_BAM" \
    --ref_fn="$REF_GENOME" \
    --output="$OUTPUT_DIR" \
    --platform="$PLATFORM" \
    --model_path="$MODEL_PATH" \
    --threads="$THREADS"

echo "=========================================================="
echo " Pipeline Finished Successfully! All outputs saved on F: drive."
echo "=========================================================="
