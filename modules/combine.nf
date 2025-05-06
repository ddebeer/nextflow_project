#!/usr/bin/env nextflow

process combine {
  // DIRECTIVES: set the docker container, the directory to output
  container 'ddebeer/r4.5.0_process:v01'
  publishDir "${params.datadir}/", mode: 'copy', overwrite: true

  input:
    val(type)
    tuple(input)

  output:
    path('*.RDS')

  script:
    """
    combine.R ${type} ${input}

    """
}

// create a subworkflow
workflow combine_type {
    take:
        type
        input

    main:
        combine(type, input)
}

