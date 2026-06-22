nextflow.enable.dsl=2

params.bam          = "/mnt/f/New Volume (F:)/aligned_reads.bam"
params.ref_genome   = "/mnt/f/New Volume (F:)/ref_genome.fasta"
params.model_path   = "/opt/conda/bin/clair3_models/ont"
params.platform     = "ont"
params.outdir       = "/mnt/f/New Volume (F:)/nextflow_variant_output"

process CLAIR3_VARIANT_CALLING {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path bam
    path ref

    output:
    path "merge_output.vcf.gz"
    path "merge_output.vcf.gz.tbi"

    script:
    """
    run_clair3.sh --bam_fn=${bam} --ref_fn=${ref} --output=. --platform="${params.platform}" --model_path="${params.model_path}" --threads=2
    """
}

workflow {
    bam_ch = Channel.fromPath(params.bam, checkIfExists: true)
    ref_ch = Channel.fromPath(params.ref_genome, checkIfExists: true)
    CLAIR3_VARIANT_CALLING(bam_ch, ref_ch)
}