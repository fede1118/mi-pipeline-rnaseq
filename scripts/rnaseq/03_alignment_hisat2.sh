#!/bin/bash
set -euo pipefail

CONFIG_FILE="../../config/samples_rnaseq.tsv"
IN_DIR="../../filtered_reads"
OUT_DIR="../../hisat_out"
REPORT_DIR="${OUT_DIR}/reports"
INDEX_PREFIX="../../references/genome/genome_idx"

mkdir -p "$OUT_DIR" "$REPORT_DIR"

# Validate index existence
if [[ ! -f "${INDEX_PREFIX}.1.ht2" ]]; then
    echo "Error: HISAT2 index not found at ${INDEX_PREFIX}.1.ht2"
    echo "Please run scripts/utils/prepare_genome.sh first."
    exit 1
fi

tail -n +2 "$CONFIG_FILE" | while IFS=$'\t' read -r sample_id srr_id condition replicate; do
    
    echo "Aligning sample: ${sample_id}"

    # Execute HISAT2 and pipe directly to samtools for BAM conversion and sorting
    # --rna-strandness RF specifies the stranded library type used in this experiment
    hisat2 --rna-strandness RF -p 4 -x "$INDEX_PREFIX" \
        -1 "${IN_DIR}/${sample_id}_non_rRNA_1.fastq.gz" \
        -2 "${IN_DIR}/${sample_id}_non_rRNA_2.fastq.gz" \
        2> "${REPORT_DIR}/${sample_id}_hisat2.log" | \
    samtools view -bS -@ 4 - | \
    samtools sort -@ 4 -o "${OUT_DIR}/${sample_id}.bam" -

    echo "Indexing BAM file for IGV visualization..."
    samtools index -@ 4 "${OUT_DIR}/${sample_id}.bam"

    echo "Alignment completed for: ${sample_id}"
    echo "---------------------------------------------------"
done