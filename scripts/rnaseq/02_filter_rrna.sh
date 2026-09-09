#!/bin/bash
set -euo pipefail

# 1. Define path variables (assuming the script is executed from the project root)
CONFIG_FILE="../../config/samples_example.tsv"
TRIM_DIR="../../trimmed_reads"
OUT_DIR="../../filtered_reads"
REPORT_DIR="${OUT_DIR}/reports"
REF_DIR="../../references/At_rRNA"
INDEX_PREFIX="${REF_DIR}/At_rRNA"

# 2. Create the necessary directories
mkdir -p "$OUT_DIR" "$REPORT_DIR" "$REF_DIR"

# 3. Verification and construction of the rRNA index
echo "Verifying rRNA indices..."
if [[ ! -f "${INDEX_PREFIX}.1.ebwt" ]]; then
    echo "  - The Bowtie indices do not exist in ${REF_DIR}."
    
    if [[ ! -f "${REF_DIR}/At_rRNA.fasta" ]]; then
        echo "Critical error: The file ${REF_DIR}/At_rRNA.fasta was not found."
        echo "You must provide the unified sequences in this file to build the index."
        exit 1
    fi
    
    echo "  - Building Bowtie 1 indices for rRNA..."
    bowtie-build "${REF_DIR}/At_rRNA.fasta" "$INDEX_PREFIX"
fi

echo "Indices validated. Preparing filtering..."
echo "---------------------------------------------------"