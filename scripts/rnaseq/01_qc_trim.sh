#!/bin/bash
# Activar el modo estricto para que el script se detenga si hay un error
set -euo pipefail

# 1. Definir rutas de los directorios y archivos
CONFIG_FILE="../../config/samples_rnaseq.tsv"
RAW_DIR="../../fastq"
TRIM_DIR="../../trimmed_reads"
REPORT_DIR="../../fastqc_reports"

# 2. Crear los directorios de salida si no existen
mkdir -p "$TRIM_DIR" "$REPORT_DIR"

# 3. Bucle para procesar cada muestra descrita en el archivo de configuración
# tail -n +2 omite la cabecera del archivo TSV
tail -n +2 "$CONFIG_FILE" | while IFS=$'\t' read -r sample_id srr_id condition replicate; do
    
    echo "Iniciando control de calidad y filtrado para la muestra: ${sample_id}"

    # 4. Ejecución de fastp
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
          
    echo "Procesamiento finalizado para: ${sample_id}"
    echo "---------------------------------------------------"

done