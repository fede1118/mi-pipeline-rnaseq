#!/bin/bash
set -euo pipefail

CONFIG_FILE="../../config/samples_rnaseq.tsv"
TRIM_DIR="../../trimmed_reads"
OUT_DIR="../../filtered_reads"
REPORT_DIR="${OUT_DIR}/reports"
INDEX_PREFIX="../../references/rRNA/unified_rRNA"

mkdir -p "$OUT_DIR" "$REPORT_DIR"

# Validate index existence
if [[ ! -f "${INDEX_PREFIX}.1.ebwt" ]]; then
    echo "Error: Bowtie index not found at ${INDEX_PREFIX}.1.ebwt"
    echo "Please run scripts/utils/prepare_rrna.sh first."
    exit 1
fi

tail -n +2 "$CONFIG_FILE" | while IFS=$'\t' read -r sample_id srr_id condition replicate; do
    
    echo "Filtering rRNA for sample: ${sample_id}"

    # Execute Bowtie 1
    # Process substitution <(pigz -dc ...) is used because Bowtie 1 does not natively read .gz files
    bowtie -v 3 -x "$INDEX_PREFIX" \
        -1 <(pigz -dc "${TRIM_DIR}/${sample_id}_1_clean.fastq.gz") \
        -2 <(pigz -dc "${TRIM_DIR}/${sample_id}_2_clean.fastq.gz") \
        --un "${OUT_DIR}/${sample_id}_non_rRNA.fastq" \
        2> "${REPORT_DIR}/${sample_id}_bowtie_rRNA.log"

    # Compress unaligned reads (mRNA) to save storage
    echo "Compressing filtered reads for ${sample_id}..."
    pigz -p 4 "${OUT_DIR}/${sample_id}_non_rRNA_1.fastq"
    pigz -p 4 "${OUT_DIR}/${sample_id}_non_rRNA_2.fastq"

    # Optional: Remove intermediate uncompressed FASTQ if required for disk space
    # rm "${TRIM_DIR}/${sample_id}_1_clean.fastq.gz" "${TRIM_DIR}/${sample_id}_2_clean.fastq.gz"

    echo "Filtering completed for: ${sample_id}"
    echo "---------------------------------------------------"
done