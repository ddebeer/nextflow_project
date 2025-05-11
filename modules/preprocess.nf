#!/usr/bin/env nextflow

process preprocess {
  // DIRECTIVES: set the docker container, the directory to output to, and a tag to follow along which sample is currently being processed
  container 'ddebeer/r4.5.0_process:v01'
  publishDir "${params.datadir}/${dataset}", mode: 'copy', overwrite: true
  tag "${dataset}"

  input:
    tuple val(dataset), path(input), path(sourcefile)

  output:
    path('*.RDS')

  script:
    """
    preprocess.R ${dataset} ${input} ${sourcefile}

    """
}
