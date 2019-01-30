setwd("/circhunter/functions")

source("backsplicing_junction_sequences.R")
source("circRNA_classification.R")
source("get_exon_data.R")
source("isoform.R")
source("isoform_info.R")
source("r_hashcirc.R")

main_scratch <- "/scratch"

#create a scratch folder for the current execution
tmp.id <- gsub(":","-",gsub(" ","-",date()))
my_scratch <- file.path(main_scratch, tmp.id)
writeLines(paste("Current scratch folder ID: ", tmp.id))
dir.create(file.path(my_scratch))

## Useful paths
path_exondata <- "/circhunter/genome"
path_isoformdata <- "/circhunter/isoformdata"
path_circrna <- "/circhunter/circRNA"
path_bksjunctions <- "/circhunter/bksj"
path_rnaseq <- "/circhunter/rnaseq"
path_output_folder <- "/output"

## Now main() begin
writeLines("* Inside R")
start <- Sys.time()
args <- commandArgs(TRUE)


# Checking required genome assembly and assessing validity
assembly <- "hg19"
if ("-as" %in% (args) | "--assembly" %in% (args)){
	argtouse <- match("-as", args)
	assembly <- args[argtouse + 1]
}
if (assembly %in% c("hg18", "hg19", "hg38") == FALSE) {
    writeLines("Please enter a valid genome assembly (hg18, hg19 or hg38).")
	quit(save="no")
}

## Download isoform and exon data
if ("-f" %in% (args) | "--full" %in% (args) |
    "-p" %in% (args) | "--preparedata" %in% (args)) {
    writeLines("Preparing isoform and exon data.")

    writeLines("Downloading exon data...")
    get_exon_data(my_scratch, assembly)

    writeLines("Downloading isoform data...")
    get_isoform_data(my_scratch, assembly)
    writeLines("Downloads completed.")
}


## CircRNA classification
if ("-f" %in% (args) | "--full" %in% (args) |
    "-c" %in% (args) | "--classification" %in% (args)) {

    writeLines("circRNA classification in progress...")

    # Checks if a biomart export was supplied with -sg
    if (("-sg" %in% (args) | "--suppliedgenome" %in% (args)) == FALSE) {
        writeLines("Downloading exon data...")
        get_exon_data(my_scratch, assembly)
    }
    circRNA_classification(my_scratch, path_exondata, path_circrna)
	writeLines("-- Classification completed --")

    #=================================================
    # CODE FOR MAIN ISOFORM
    #=================================================

    writeLines("Main isoform circRNA classification in progress")
    if(("-id" %in% (args) | "--isoformdata" %in% (args)) == FALSE) {
        writeLines("Downloading isoform data\n")
        get_isoform_data(my_scratch, assembly)
    }
    isoform(my_scratch, path_isoformdata)
    writeLines("-- Main isoform classification obtained --")
}

# Obtains CircRNA backsplicing junctions
if ("-f" %in% (args) | "--full" %in%(args) |
    "-s" %in% (args) | "--sequences" %in% (args)) {

	writeLines("Searching backsplicing junction sequences coordinates")

    backsplicing_junction_sequences(my_scratch, path_circrna)
	writeLines("-- Sequences obtained --")
}

if ("-r" %in% (args) | "--readcount" %in% (args)) { # -f was excluded on purpose
	if("-hc" %in% (args) | "--hashcirc" %in% (args)){
		argtouse <- match("-hc", args)
		hcargs <- args[argtouse + 1:6]
	} else {
        #TODO: provide default values
    }

	writeLines("Running HashCirc analysis")

    r_hashcirc(my_scratch, path_rnaseq, path_bksjunctions, hcargs)
	writeLines("-- HashCirc analysis completed --")
}

if (args[1] == "-q") {
    writeLines("Converting FASTA to FASTQ")

    fasta_file <- paste(my_scratch, "my_fasta.fastq", sep="/")
    conversion <- paste("python fasta_to_fastq.py", path_circrna, ">", fasta_file)
    system(conversion, wait=TRUE)

    writeLines("-- Conversion completed --")
}


# Output folder step
if ("-of" %in% (args) | "--outputfolder" %in% (args)) {

	writeLines("Placing output files in provided folder")
    data_in_scratch <- file.path(my_scratch, "*")
    move_output <- paste("rsync -avhP", data_in_scratch, path_output_folder)
    system(move_output, wait=TRUE)
    writeLines("-- Output moved --")
	system(paste("rm -f", data_in_scratch))

    writeLines(paste("Removing temporary directory", my_scratch))
    system(paste("rmdir", my_scratch))  #remove directory if it is empty
}

writeLines("Exiting CircHunter successfully.")
writeLines(paste("Execution time:", Sys.time()-start))
quit(save="no")
