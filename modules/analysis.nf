#!/usr/bin/env nextflow

process analysis {
  // DIRECTIVES: set the docker container, the directory to output
  container 'ddebeer/r4.5.0_analysis:v02'
  publishDir "${params.outdir}/bin/${threshold}_${name}", mode: 'copy', overwrite: true

  input:
    tuple (path(data_path), val(name), val(formula), val(threshold))

  output:
    path('*.RDS'), emit: path

  script:
    """
    analysis.R ${data_path} ${name} ${formula} ${threshold}

    """
}


process check {
  // DIRECTIVES: set the docker container, the directory to output
  container 'ddebeer/r4.5.0_analysis:v02'
  publishDir "${params.outdir}/bin/${threshold}_${name}", mode: 'copy', overwrite: true

  input:
    path(fit)


  output:
    path('*.pdf')

  script:
    """
    check.R ${fit}
    """
}


// create a subworkflow
workflow analysis_check {
    take:
        input

    main:
        analysis(input)
        check(analysis.out)

}

