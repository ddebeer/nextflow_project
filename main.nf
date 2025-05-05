#!/usr/bin/env nextflow

// set default input parameters (these can be altered by calling their flag on the command line, e.g., nextflow run main.nf --reads 'data2/*_R{1,2}.fastq')
params.indir = "${launchDir}/input"
params.inputfile = "input.csv"
params.datadir = "${launchDir}/data"
params.outdir = "${launchDir}/output"


// include processes and subworkflows to make them available for use in this script



workflow {
    // Set a header made using https://patorjk.com/software/taag (but be sure to escape characters such as dollar signs and backslashes, e.g., '$'=> '\$' and '\' =>'\\')
    log.info """

    INPUT PARAMETERS:
        - input directory : ${params.indir}
        - input file: ${params.inputfile}
        - data directory : ${params.datadir}
        - output directory : ${params.outdir}

    """.stripIndent()

    // read input csv-file
    def input = Channel.fromPath('${params.indir}/${params.inputfile}', checkIfExists:true)
                       .splitCsv(header:true)
                       .view()



    workflow.onComplete = {
        println "Pipeline completed at: ${workflow.complete}"
        println "Time to complete workflow execution: ${workflow.duration}"
        println "Execution status: ${workflow.success ? 'Succesful' : 'Failed' }"
    }

    workflow.onError = {
        println "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
    }

}
