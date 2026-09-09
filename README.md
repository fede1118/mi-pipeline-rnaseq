# RNA-seq Automated Pipeline
This repository compiles the steps necessary to download (from the SRA), process, annotate, and analyze RNA-seq and sRNA-seq libraries from different samples. It is designed for use with samples from species with well-annotated genomes (Arabidopsis, and common crops).

## ⚠️ Considerations and Prerequisites

### 1. Supported Experimental Design
Currently, this automated pipeline is strictly configured to process **paired-end** RNA-seq libraries. Executing it on single-end datasets will generate formatting errors during the download and alignment steps.

### 2. Genomic References Preparation
This workflow is species-agnostic. Before configuring metadata or executing the scripts, the user must download and structure the genomic reference files for the organism of interest (e.g., from repositories like TAIR, MaizeGDB, or EnsemblPlants). 

A `references/` directory must be created in the project root containing, at a minimum, the following inputs:

*   **Ribosomal RNA (rRNA):** A `.fasta` format file containing the sequences corresponding to the ribosomal subunits (e.g., unified SSU and LSU). The sequences must be in DNA format (uracils must be replaced by thymines).
*   **Reference Genome:** The complete genome assembly in `.fasta` format.
*   **Gene Annotation:** The gene models file in `.gff3` or `.gtf` format, which must strictly match the version of the downloaded genome.

## 🚀 Quick Start Guide

### 1. Clone the repository
Clone this repository to your local machine and navigate into the directory:
```bash
git clone [https://github.com/YOUR_USERNAME/my-pipeline-rnaseq.git](https://github.com/YOUR_USERNAME/my-pipeline-rnaseq.git)
cd my-pipeline-rnaseq
```

### 2. Set up the Conda environment
Create and activate the required bioinformatics environment:
```bash
conda env create -f environment.yml
conda activate rnaseq_env
```

### 3. Provide Genomic References
Place your reference files into the pre-configured directories:
- Place the rRNA sequences (`.fasta` format) inside `references/rRNA/`.
- Place the Reference Genome (`.fasta`) and the Gene Annotation (`.gff3` or `.gtf`) inside `references/genome/`.

*Note: Run the utility script to index the reference genome with HISAT2 before proceeding:*
```bash
bash scripts/utils/prepare_genome.sh references/genome/TAIR10_chr_all.fas references/genome/genome_idx
```

*Note: If your rRNA sequences are separated by subunits and/or contain Uracils (U), run the utility script to format and index them before proceeding:*
```bash
bash scripts/utils/prepare_rrna.sh references/rRNA/SSU.fasta references/rRNA/LSU.fasta references/rRNA/unified_rRNA
```

## 4. Configure Metadata
Duplicate the template file and fill in your experimental design:

Edit `samples_rnaseq.tsv` with your sample IDs, SRA accession numbers, conditions, and replicates.

## 5. Run the Pipeline
Execute the master script to run all steps sequentially:
```bash
bash run_rnaseq_pipeline.sh
```