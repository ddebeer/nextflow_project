#!/usr/bin/env nextflow

process preprocess {
  // DIRECTIVES: set the docker container, the directory to output to, and a tag to follow along which sample is currently being processed
  container 'blekhmanlab/dada2:1.26.0'
  publishDir "${params.datadir}/${dataset}", mode: 'copy', overwrite: true
  tag "${dataset}"

  input:
    tuple val(dataset), path(input)

  output:
    path('*.RDS')

  script:
    """
    echo ${dataset}
    preprocess.R ${dataset} ${input}

    """
}
