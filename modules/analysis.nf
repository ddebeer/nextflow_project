#!/usr/bin/env nextflow

process analysis {
  // DIRECTIVES: set the docker container, the directory to output
  container 'ddebeer/r4.5.0_analysis:v02'
  publishDir "${params.outdir}/bin/${threshold}_${name}", mode: 'copy', overwrite: true

  input:
    tuple (val(data_path), val(name), val(formula), val(threshold))

  output:
    path('*.RDS'), emit: path
    tuple (val(name), val(threshold), path('*.RDS')), emit: fit

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
    tuple (val(name), val(threshold), path(fit))


  output:
    path('*.pdf')

  script:
    """
    check.R ${fit} ${name} ${threshold}

    """
}


// create a subworkflow
workflow analysis_check {
    take:
        input

    main:
        analysis(input)
        check(analysis.out.fit)

}

