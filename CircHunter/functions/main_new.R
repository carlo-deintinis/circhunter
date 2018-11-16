cat("* Inside R \n")

start <- Sys.time()

## Collect arguments
args <- commandArgs(TRUE)
 
# Cheching required genome assembly
if ("-as" %in% (args) | "--assembly" %in% (args)){
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


if ("-f" %in% (args) |
    "-p" %in% (args) | 
    "--full" %in% (args) |
    "--preparedata" %in% (args)) {
  cat("Preparing isoform and exon data.\n")
  
#  genome <- "../genome"
  cat("Downloading exon data\n")
  source("get_exon_data.R")
  
#  isoform <- "../isoformdata"
  cat("Downloading isoform data\n")
  source("isoform_info.R")	
}


if ("-f" %in% (args) |
    "-c" %in% (args) |
    "--full" %in% (args) |
    "--classification" %in% (args)) {
	
	cat("circRNA classification in progress\n")
	# Defining absolute path of circRNA file
	circ <- "../circRNA"
	
	# Checks if a biomart export was supplied with -sg
	if("-sg" %in% (args) | "--suppliedgenome" %in% (args)){

		# Defining the absolute path of exon file
		genome <- "../genome"

	} else {		

		genome <- "../genome"
		cat("Downloading exon data\n")
		source("get_exon_data.R")

	}
	
	source("circRNA_classification.R")
	
	cat("-- Classification completed --\n")
	

#=================================================
# CODE FOR MAIN ISOFORM
#=================================================

	cat("Main isoform circRNA classification in progress\n")
	
	circ <- "../circRNA"

	if("-id" %in% (args) | "--isoformdata" %in% (args)){
		
		# Defining the absolute path of isoform information file
		isoform <- "../isoformdata"
		
	} else {
	
		isoform <- "../isoformdata"
		cat("Downloading isoform data\n")
		source("isoform_info.R")	

	}
	
	source("isoform.R")

    cat("-- Main isoform classification obtained --\n")

}

if ("-f" %in% (args) |
    "-s" %in% (args) |
    "--full" %in%(args) |
    "--sequences" %in% (args)) {

	# Defining absolute path of circRNA file
	circ <- "../circRNA"
	
	cat("Defining backsplicing junction sequences coordinates\n")
	source("backsplicing_junction_sequences.R")

	cat("-- Sequences obtained --\n")

}

if ("-r" %in% (args) | "--readcount" %in% (args)) { # f was excluded on purpose

	junctionseqs <- "../bksj"
	rnaseq <- "../rnaseq"

	if("-hc" %in% (args) | "--hashcirc" %in% (args)){
		argtouse <- match("-hc", args)
		hcargs <- args[argtouse + 1:6]
	}

	cat("Running HashCirc analysis\n")	
	source("r_hashcirc.R") # Main hashcirc script
	cat("-- HashCirc analysis completed --\n")

}


if (args[1] == "-q") {

	# Defining absolute path of FASTA file
	FASTA <- "../circRNA"

	cat("Converting FASTA to FASTQ\n")
	source("t_FASTAtoFASTQ.R")

	cat("-- Conversion completed --\n")
	
}

# Output folder step
if ("-of" %in% (args) | "--outputfolder" %in% (args)) {
	
	cat("Placing output files in provided folder\n")
	move_output <- "rsync -avhP /circhunter/data/* /output/"
	system(move_output, wait=TRUE)
	cat("-- Output moved --\n")

}

print(Sys.time()-start)
quit(save="no")
