#!/bin/bash
set -euo pipefail

# Check input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <genome_fasta> <index_prefix>"
    exit 1
fi

GENOME_FASTA=$1
INDEX_PREFIX=$2

echo "Building HISAT2 index for ${GENOME_FASTA}..."
# Generate the .ht2 index files
hisat2-build "${GENOME_FASTA}" "${INDEX_PREFIX}"

echo "Genome indexing completed successfully."