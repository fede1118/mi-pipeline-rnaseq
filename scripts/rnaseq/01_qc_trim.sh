#!/bin/bash
# Enable strict mode so that the script stops if an error occurs.
set -euo pipefail

# 1. Define path variables (assuming the script is executed from the project root)
CONFIG_FILE="../../config/samples_rnaseq.tsv"
RAW_DIR="../../fastq"
TRIM_DIR="../../trimmed_reads"
REPORT_DIR="../../fastqc_reports"

# 2. Create the output directories if they do not exist.
mkdir -p "$TRIM_DIR" "$REPORT_DIR"

# 3. Loop to process each sample described in the configuration file.
# tail -n +2 skips the TSV file header.
tail -n +2 "$CONFIG_FILE" | while IFS=$'\t' read -r sample_id srr_id condition replicate; do
    
    echo "Starting quality control and filtering for the sample: ${sample_id}"

    # 4. Execution of fastp
    fastp -i "${RAW_DIR}/${sample_id}_1.fastq.gz" \
          -I "${RAW_DIR}/${sample_id}_2.fastq.gz" \
          -o "${TRIM_DIR}/${sample_id}_1_clean.fastq.gz" \
          -O "${TRIM_DIR}/${sample_id}_2_clean.fastq.gz" \
          -h "${REPORT_DIR}/${sample_id}_fastp.html" \
          -j "${REPORT_DIR}/${sample_id}_fastp.json" \
          --trim_front1 9 \
          --trim_front2 9 \
          --detect_adapter_for_pe \
          --thread 4
          
    echo "Quality control and filtering completed for: ${sample_id}"
    echo "---------------------------------------------------"

done