# Clinical Genomics Pipeline

A modular Nextflow and Shell-based clinical genomics pipeline designed for long-read sequencing data. This repository provides automated workflows for robust variant calling using **Clair3** to detect high-confidence SNPs and INDELs. 

It supports direct execution via native environments or containerized reproducibility through Singularity/Apptainer.
---
## Repository Structure

The project follows a clean, single-purpose structure separating workflow logic, container setup, and execution scripts:

```
clinical_genomics/
├── nextflow/
│   ├── main.nf
│   └── nextflow.config
├── shell/
│   └── run_pipeline.sh
├── singularity/
│   └── pipeline.def
└── README.md
```
---
Requirements:
Before running the pipelines, ensure the following core tools are installed on your system:

Nextflow (DSL2 enabled)

Apptainer / Singularity

Linux or WSL (Windows Subsystem for Linux) (Required for executing scripts and workflows)
---
Input Data
Large biological data files are strictly excluded from version control via .gitignore. Users must supply their own dataset located on their local storage system or mounted drives.

The pipelines are pre-configured to look for:

Reference Genome: ref_genome.fasta

Input Alignment: aligned_reads.bam (and its index file .bai)
---
Container Setup
The Singularity container image (.sif) contains the complete software environment (including Clair3 and required dependencies) to guarantee absolute reproducibility.

Because .sif files are large binaries, they are ignored by Git. You must build your container locally using the provided definition recipe before launching your runs:
---
```
Bash
# Build the container image from the definition file
sudo singularity build singularity/pipeline.sif singularity/pipeline.def
```
---
Running the Pipelines
This repository offers two ways to execute the clinical genomic analysis depending on your workflow preference:

Option 1: Native Execution via Master Shell Script
To trigger the automated execution sequence directly inside your shell terminal:
```
Bash
bash shell/run_pipeline.sh
```
Option 2: Scalable Execution via Nextflow Workflow
To leverage Nextflow's pipeline orchestration, caching, and container management:
```
Bash
nextflow run nextflow/main.nf
```
Note: Nextflow parameters and execution profiles are systematically managed inside nextflow/nextflow.config.
---
Output
Upon successful execution, the pipeline produces high-accuracy variant calls:

Clair3 Results: Compressed variant call files (merge_output.vcf.gz and its index .tbi) containing detected SNPs and INDELs.

All intermediate operational directories (such as work/), local run logs (.nextflow.log*), and temporary scratch binaries remain completely untracked to keep the repository clean.

Maintained by: Eiesha Asif
