#!/bin/bash
set -euo pipefail

CONFIG_FILE="../../config/samples_rnaseq.tsv"
IN_DIR="../../stringtie_out"
OUT_DIR="../../deseq2_run"
SAMPLE_LST="${OUT_DIR}/sample_lst.txt"
PHENO_DATA="${OUT_DIR}/pheno_data.txt"
PREPDE_SCRIPT="../../scripts/utils/prepDE.py3"

mkdir -p "$OUT_DIR"

echo "Generating configuration files for DESeq2..."
# Create header for phenotypic data
echo -e "sample\tgenotype" > "$PHENO_DATA"
# Clear previous sample list content
> "$SAMPLE_LST"

tail -n +2 "$CONFIG_FILE" | while IFS=$'\t' read -r sample_id srr_id condition replicate; do
    
    # Append absolute or relative paths for prepDE.py3
    # Use realpath to resolve full path to avoid prepDE path resolution issues
    GTF_PATH=$(realpath "${IN_DIR}/${sample_id}.gtf")
    echo -e "${sample_id}\t${GTF_PATH}" >> "$SAMPLE_LST"
    
    # Append phenotypic data
    echo -e "${sample_id}\t${condition}" >> "$PHENO_DATA"

done

echo "Retrieving prepDE.py3 utility script..."
if [[ ! -f "$PREPDE_SCRIPT" ]]; then
    wget -q -O "$PREPDE_SCRIPT" https://ccb.jhu.edu/software/stringtie/dl/prepDE.py3
    chmod +x "$PREPDE_SCRIPT"
fi

echo "Extracting read count matrix..."
# Execute prepDE.py3 with a specified read length (-l 150)
python3 "$PREPDE_SCRIPT" -i "$SAMPLE_LST" -g "${OUT_DIR}/gene_count_matrix.csv" -l 150

echo "Count matrix generation completed."