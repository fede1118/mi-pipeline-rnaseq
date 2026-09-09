#!/bin/bash
set -euo pipefail

# Arguments received by the user (e.g., SSU.fasta and LSU.fasta)
FILE_SSU=$1
FILE_LSU=$2
PREFIX_OUT=$3

echo "Unifying sequences and converting uracils (U) to thymines (T)..."
# Both files are concatenated, and a global character substitution is applied.
cat "$FILE_SSU" "$FILE_LSU" | sed 's/U/T/g' > "${PREFIX_OUT}.fasta"

echo "Building Bowtie 1 indices..."
bowtie-build "${PREFIX_OUT}.fasta" "$PREFIX_OUT"