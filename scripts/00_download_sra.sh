#!/bin/bash
# Enable Bash strict mode
set -euo pipefail

# 1. Define path variables (assuming the script is executed from the project root)
CONFIG_FILE="config/samples_example.tsv"
OUT_DIR="fastq"

# 2. Validation of prerequisites
# Check if the metadata file exists (-f)
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Critical error: The metadata file '$CONFIG_FILE' does not exist."
    echo "Make sure you are running the script from the project root (mi-pipeline-rnaseq/)."
    exit 1
fi

echo "Validation passed: The file $CONFIG_FILE was found."

# 3. Create the output directory if it does not exist
mkdir -p "$OUT_DIR"

# 4. Read the metadata file line by line
echo "Starting to read metadata..."
echo "---------------------------------"

# tail -n +2 skips the first line (the header)
tail -n +2 "$CONFIG_FILE" | while IFS=$'\t' read -r sample_id srr_id condition replicate; do
    
    echo "Processing sample: $sample_id (SRA: $srr_id)"

    # 5. Avoid duplicate downloads
    if [[ -f "${OUT_DIR}/${sample_id}_1.fastq.gz" && -f "${OUT_DIR}/${sample_id}_2.fastq.gz" ]]; then
        echo "  - The compressed files already exist. Skipping download."
        echo "---------------------------------"
        continue
    fi

    # 6. Download with fasterq-dump
    echo "  - Downloading reads from NCBI..."
    fasterq-dump --split-files "$srr_id" -O "$OUT_DIR" -e 4
    
    # 7. Rename and compress
    echo "  - Renaming and compressing with pigz..."
    mv "${OUT_DIR}/${srr_id}_1.fastq" "${OUT_DIR}/${sample_id}_1.fastq"
    mv "${OUT_DIR}/${srr_id}_2.fastq" "${OUT_DIR}/${sample_id}_2.fastq"
    
    pigz -p 4 "${OUT_DIR}/${sample_id}_1.fastq"
    pigz -p 4 "${OUT_DIR}/${sample_id}_2.fastq"

    echo "  - Download and compression completed for $sample_id"
    echo "---------------------------------"
done

