cat("* Inside R \n")

start <- Sys.time()

## Collect arguments
args <- commandArgs(TRUE)
 
# Cheching required genome assembly
if ("-as" %in% (args)){
	argtouse <- match("-as", args)
	assembly <- args[argtouse + 1]
} else {
	assembly <- "hg19"
}

# Checking requestd assembly validity
if (assembly != "hg18" & assembly != "hg19" & assembly != "hg38") {
	cat("Please enter a valid genome assembly (hg18, hg19 or hg38).\n")
	quit(save="no")
}

if ("-f" %in% (args) | "-c" %in% (args)) {
	
	cat("circRNA classification in progress\n")
	# Defining absolute path of circRNA file
	circ <- "../circRNA"
	
	# Checks if a biomart export was supplied with -sg
	if("-sg" %in% (args)){

		# Defining the absolute path of exon file
		genome <- "../genome"

	} else {		

		genome <- "../genome"
		cat("Downloading exon data\n")
		source("get_exon_data.R")

	}
	
	source("circRNA_classification.R")
	
	cat("-- Classification completed --\n")
}	

#=================================================
# NEW CODE FOR main isoform
#=================================================
if ("-ci" %in% (args)) {

	cat("Main isoform circRNA classification in progress\n")
	
	circ <- "../circRNA" # DEBUG

	if("-id" %in% (args)){
		
		# Defining the absolute path of isoform information file
		isoform <- "../isoformdata"
		
	} else {
	
		isoform <- "../isoformdata"
		cat("Downloading isoform data\n")
		source("isoform_info.R")	

	}
	
	source("isoform.R")

}

if ("-f" %in% (args) | "-s" %in% (args)) {

	# Defining absolute path of circRNA file
	circ <- "../circRNA"
	
	cat("Defining backsplicing junction sequences coordinates\n")
	source("backsplicing_junction_sequences.R")

	cat("-- Sequences obtained --\n")

}

if ("-r" %in% (args)) { # f was excluded on purpose

	cat("Inside r mode\n")

	junctionseqs <- "../bksj"
	rnaseq <- "../rnaseq"

	if("-hc" %in% (args)){
		argtouse <- match("-hc", args)
		hcargs <- args[argtouse + 1:6]
	}
	
	source("r_hashcirc.R") # Main hashcirc script

}


if (args[1] == "q") {

	# Defining absolute path of FASTA file
	FASTA <- "../circRNA"

	cat("Converting FASTA to FASTQ\n")
	source("t_FASTAtoFASTQ.R")

	cat("-- Conversion completed")
	
}


print(Sys.time()-start)
quit(save="no")
