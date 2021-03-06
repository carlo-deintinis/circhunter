# R script used to obtain isoform information

library(biomaRt)

get_isoform <- function(assembly) {
	cat("\nDownloading isoform data")

	# Choosing the right dataset
	if (assembly == "hg18"){

		my_genome <- useMart("ENSEMBL_MART_ENSEMBL",
		dataset="hsapiens_gene_ensembl",
		host="may2009.archive.ensembl.org",
		path="/biomart/martservice",
		archive=FALSE)

	} else if (assembly == "hg19") {

		my_genome <- useEnsembl(biomart="ensembl",
		dataset="hsapiens_gene_ensembl",
		GRCh = 37)

	} else if (assembly == "hg38"){

		my_genome <- useEnsembl(biomart="ensembl",
		dataset="hsapiens_gene_ensembl")

	}

	return(my_genome)
}


get_isoform_data <- function(data.folder, assembly) {
	my_genome <- get_isoform(assembly)

	# Extracting data
	isoform <- getBM(attributes=c("ensembl_gene_id", "ensembl_transcript_id", "chromosome_name" , "external_transcript_name"),
	      mart = my_genome)

	# Correcting chromosome names
	isoform$chromosome_name <- paste("chr", isoform$chromosome_name, sep="")

	# Saving results to isoform file
	isoform.file <- file.path(data.folder, "isoformdata")

	write.table(isoform, file=isoform.file, sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)

	rm(isoform)
}


#get_isoform_data("..", assembly)
