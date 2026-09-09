#!/bin/bash
set -euo pipefail

CONFIG_FILE="../../config/samples_rnaseq.tsv"
IN_DIR="../../hisat_out"
OUT_DIR="../../stringtie_out"
ABUNDANCE_DIR="${OUT_DIR}/gene_abundance"
ANNOTATION="../../references/genome/annotation.gff3"

mkdir -p "$OUT_DIR" "$ABUNDANCE_DIR"

# Validate annotation file existence
if [[ ! -f "$ANNOTATION" ]]; then
    echo "Error: Gene annotation file not found at $ANNOTATION"
    echo "Ensure your GFF3/GTF file is correctly placed and named 'annotation.gff3'."
    exit 1
fi

tail -n +2 "$CONFIG_FILE" | while IFS=$'\t' read -r sample_id srr_id condition replicate; do
    
    echo "Quantifying transcripts for sample: ${sample_id}"

    # Execute stringtie with --rf for stranded fr-firststrand libraries
    stringtie "${IN_DIR}/${sample_id}.bam" \
        --rf -e \
        -G "$ANNOTATION" \
        -o "${OUT_DIR}/${sample_id}.gtf" \
        -A "${ABUNDANCE_DIR}/${sample_id}.tab"

    echo "Quantification completed for: ${sample_id}"
    echo "---------------------------------------------------"
done