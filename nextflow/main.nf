nextflow.enable.dsl=2

// --- Parameters Defaults ---
params.fastq      = "/mnt/f/New Volume (F:)/raw_reads.fastq.gz"
params.ref_genome = "/mnt/f/New Volume (F:)/ref_genome.fasta"
params.model_path = "/opt/conda/bin/clair3_models/ont"
params.platform   = "ont"
params.outdir     = "/mnt/f/New Volume (F:)/nextflow_variant_output"
params.threads    = 4

// --- Process 1: Alignment using minimap2 ---
process ALIGN_READS {
    tag "Aligning reads with minimap2"
    
    input:
    path fastq
    path ref

    output:
    path "aligned.bam"

    script:
    """
  
    minimap2 -ax map-ont -t ${params.threads} ${ref} ${fastq} | samtools view -bS - > aligned.bam
    """
}

// --- Process 2: Sort and Index BAM ---
process SORT_INDEX_BAM {
    tag "Sorting and Indexing BAM"
    publishDir "${params.outdir}/alignment", mode: 'copy'

    input:
    path bam

    output:
    path "sorted.bam", emit: sorted_bam
    path "sorted.bam.bai", emit: bai

    script:
    """
    samtools sort -@ ${params.threads} -o sorted.bam ${bam}
    samtools index -@ ${params.threads} sorted.bam
    """
}

// --- Process 3: Clair3 Variant Calling ---
process CLAIR3_VARIANT_CALLING {
    tag "Calling variants with Clair3"
    publishDir "${params.outdir}/variants", mode: 'copy'

    input:
    path bam
    path bai
    path ref

    output:
    path "merge_output.vcf.gz", emit: vcf
    path "merge_output.vcf.gz.tbi", emit: tbi

    script:
    """
    run_clair3.sh \
        --bam_fn=${bam} \
        --ref_fn=${ref} \
        --output=. \
        --platform="${params.platform}" \
        --model_path="${params.model_path}" \
        --threads=${params.threads}
    """
}

// --- Workflow Definition ---
workflow {
    // 1. Input Channels Setup
    fastq_ch = Channel.fromPath(params.fastq, checkIfExists: true)
    ref_ch   = Channel.fromPath(params.ref_genome, checkIfExists: true)

    // 2. Alignment Step
    ALIGN_READS(fastq_ch, ref_ch)

    // 3. Sorting and Indexing Step
    SORT_INDEX_BAM(ALIGN_READS.out)

    // 4. Variant Calling Step (Takes sorted BAM, its Index, and Reference)
    CLAIR3_VARIANT_CALLING(
        SORT_INDEX_BAM.out.sorted_bam, 
        SORT_INDEX_BAM.out.bai, 
        ref_ch
    )
}
