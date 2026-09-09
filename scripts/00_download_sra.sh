#!/bin/bash
# Activar el modo estricto de Bash
set -euo pipefail

# 1. Definir variables de rutas (asumiendo que el script se ejecuta desde la raíz del proyecto)
CONFIG_FILE="config/samples_example.tsv"
OUT_DIR="fastq"

# 2. Validación de pre-requisitos
# Comprobar si el archivo de metadatos existe (-f)
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error crítico: El archivo de metadatos '$CONFIG_FILE' no existe."
    echo "Asegúrate de estar ejecutando el script desde la raíz del proyecto (mi-pipeline-rnaseq/)."
    exit 1
fi

echo "Validación superada: El archivo $CONFIG_FILE fue encontrado."

# 3. Crear el directorio de salida si no existe
mkdir -p "$OUT_DIR"

# 4. Leer el archivo de metadatos línea por línea
echo "Iniciando lectura de metadatos..."
echo "---------------------------------"

# tail -n +2 omite la primera línea (la cabecera)
tail -n +2 "$CONFIG_FILE" | while IFS=$'\t' read -r sample_id srr_id condition replicate; do
    
    echo "Procesando muestra: $sample_id (SRA: $srr_id)"

    # 5. Evitar descargas duplicadas
    if [[ -f "${OUT_DIR}/${sample_id}_1.fastq.gz" && -f "${OUT_DIR}/${sample_id}_2.fastq.gz" ]]; then
        echo "  - Los archivos comprimidos ya existen. Omitiendo descarga."
        echo "---------------------------------"
        continue
    fi

    # 6. Descarga con fasterq-dump
    echo "  - Descargando lecturas desde NCBI..."
    fasterq-dump --split-files "$srr_id" -O "$OUT_DIR" -e 4
    
    # 7. Renombrar y comprimir
    echo "  - Renombrando y comprimiendo con pigz..."
    mv "${OUT_DIR}/${srr_id}_1.fastq" "${OUT_DIR}/${sample_id}_1.fastq"
    mv "${OUT_DIR}/${srr_id}_2.fastq" "${OUT_DIR}/${sample_id}_2.fastq"
    
    pigz -p 4 "${OUT_DIR}/${sample_id}_1.fastq"
    pigz -p 4 "${OUT_DIR}/${sample_id}_2.fastq"

    echo "  - Descarga y compresión completada para $sample_id"
    echo "---------------------------------"
done

