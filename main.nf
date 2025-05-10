#!/usr/bin/env nextflow

// set default input parameters (these can be altered by calling their flag
//    on the command line, e.g., nextflow run main.nf --<param> '<parameter value>')
params.inputfile = "${launchDir}/input/input.csv"
params.modelsfile = "${launchDir}/input/models.csv"
params.datadir = "${launchDir}/data"
params.Rdir = "${launchDir}/R"
params.outdir = "${launchDir}/output"


// include processes and subworkflows to make them available for use in this script
include { preprocess } from "./modules/preprocess"
include { combine_type as combine_esm; combine_type as combine_pp } from "./modules/combine"
include { analysis_check } from "./modules/analysis"

workflow {
    log.info """

    INPUT PARAMETERS:
        - input file: ${params.inputfile}
        - data directory : ${params.datadir}
        - output directory : ${params.outdir}

    """.stripIndent()

    // read input csv-file
    def datasets = Channel.fromPath(params.inputfile, checkIfExists:true)
                          .splitCsv(header:true)
                          .map { row -> row.dataset }
                          .map { set -> tuple(set, file(params.datadir + '/data_raw/data_' + set + '.csv'), file(params.Rdir + '/process/preproces_' + set + '.R')) }

    // preprocess datasets
    preprocess(datasets)


    // combine datasets
    def input_esm = preprocess.out
                              .map{ files -> file(files[0])}
                              .collect()

    def input_pp = preprocess.out
                             .map{ files -> file(files[1])}
                             .collect()

    combine_esm("esm", input_esm)
    combine_pp("pp", input_pp)

    // do analyses
    def models = Channel.fromPath(params.modelsfile, checkIfExists:true)
                        .splitCsv(header:true)

    def input_analyses = combine_pp.out
                                   .combine(models)
                                   .combine(channel.of(25, 50, 75))
                                   .map { entry -> tuple(file(entry[0]), value(entry[1]), value(entry[2]), value(entry[3])) }
                                   .view()

    // analysis_check(input_analyses)




    workflow.onComplete = {
        println "Pipeline completed at: ${workflow.complete}"
        println "Time to complete workflow execution: ${workflow.duration}"
        println "Execution status: ${workflow.success ? 'Succesful' : 'Failed' }"
    }

    workflow.onError = {
        println "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
    }

}
