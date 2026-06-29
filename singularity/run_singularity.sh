#!/bin/bash
set -e

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_DIR="${SCRIPT_DIR}/containers"
CONTAINER_NAME="${CONTAINER_DIR}/pipeline.sif"
RECIPE_FILE="${SCRIPT_DIR}/Singularity.def"

# --- Real Windows/WSL Paths Setup ---
# Hum pure /mnt/f ko bind karenge taake container in paths ko access kar sake
REF_GENOME="/mnt/f/New Volume (F:)/ref_genome.fasta"
INPUT_BAM="/mnt/f/New Volume (F:)/aligned_reads.bam"
OUTPUT_DIR="/mnt/f/New Volume (F:)/nextflow_variant_output"

# Clair3 internal parameters (Conda environment ke mutabiq)
MODEL_PATH="/opt/conda/share/clair3/models/ont" # Standard Conda Clair3 model path
PLATFORM="ont"
THREADS=4

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

# 3. Create Output Directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# 4. Launch Clair3 Variant Calling inside Singularity Container
echo "=========================================================="
echo "Starting Clair3 Variant Calling Process..."
echo "=========================================================="

# -B /mnt/f:/mnt/f ka matlab hai Windows ki F drive container ko visible ho jaye
singularity exec -B "/mnt/f:/mnt/f" "$CONTAINER_NAME" \
    run_clair3.sh \
    --bam_fn="$INPUT_BAM" \
    --ref_fn="$REF_GENOME" \
    --output="$OUTPUT_DIR" \
    --platform="$PLATFORM" \
    --model_path="$MODEL_PATH" \
    --threads="$THREADS"

echo "=========================================================="
echo "Singularity Clair3 Pipeline finished successfully!"
echo "=========================================================="
