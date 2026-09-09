#!/bin/bash
set -euo pipefail

# Check input arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <SSU_fasta> <LSU_fasta> <output_prefix>"
    exit 1
fi

FILE_SSU=$1
FILE_LSU=$2
PREFIX_OUT=$3

echo "Combining sequences and replacing Uracil (U) with Thymine (T)..."
# Concatenate both files and apply global character substitution
cat "$FILE_SSU" "$FILE_LSU" | sed 's/U/T/g' > "${PREFIX_OUT}.fasta"

echo "Building Bowtie 1 index..."
# Generate the .ebwt index files
bowtie-build "${PREFIX_OUT}.fasta" "$PREFIX_OUT"

echo "rRNA indexing completed successfully."