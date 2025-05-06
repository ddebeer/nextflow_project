#!/usr/bin/env nextflow

// set default input parameters (these can be altered by calling their flag
//    on the command line, e.g., nextflow run main.nf --<param> '<parameter value>')
params.inputfile = "${launchDir}/input/input.csv"
params.datadir = "${launchDir}/data"
params.Rdir = "${launchDir}/R"
params.outdir = "${launchDir}/output"


// include processes and subworkflows to make them available for use in this script
include { preprocess } from "./modules/preprocess"
include { combine_type as combine_esm; combine_type as combine_pp } from "./modules/combine"


workflow {
    // Set a header made using https://patorjk.com/software/taag (but be sure to escape characters such as dollar signs and backslashes, e.g., '$'=> '\$' and '\' =>'\\')
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
    input = preprocess.out.view()
                   //.collect()
                   .view()
    //combine_esm("esm", params.datadir)
    //combine_pp("pp", params.datadir)




    workflow.onComplete = {
        println "Pipeline completed at: ${workflow.complete}"
        println "Time to complete workflow execution: ${workflow.duration}"
        println "Execution status: ${workflow.success ? 'Succesful' : 'Failed' }"
    }

    workflow.onError = {
        println "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
    }

}
