# Welcome to CircHunter
# This script extracts the required exon data from ensembl

library(biomaRt)

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





# Extracting data
exons <- getBM(attributes=c("ensembl_gene_id", "ensembl_transcript_id", "ensembl_exon_id", "chromosome_name", "exon_chrom_start", "exon_chrom_end", "strand", "rank", "start_position", "end_position", "transcript_start", "transcript_end"),
      mart = my_genome)

# Correcting chromosome names
exons$chromosome_name <- paste("chr", exons$chromosome_name, sep="")

# Saving results to exons file
write.table(exons, file="../genome", sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)

rm(exons)

# SINGLE TRANSCRIPT FILTER VALUE
## ensembl_transcript_id="ENST00000367770"

# EXTRA
## Getting attributes list
### att <- listAttributes(my_genome)
### write.csv(att, file="attributes.csv")

# WORKING
#exons <- getBM(attributes=c("ensembl_gene_id", "ensembl_transcript_id", "ensembl_exon_id", "chromosome_name", "exon_chrom_start", "exon_chrom_end", "strand", "rank", "start_position", "end_position", "transcript_start", "transcript_end"),
#      filters=c("chromosome_name"),
#      values=list(chromosome_name=c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "X", "Y")),
#      mart = my_genome)



#awk -v OFS='\t' '{if($4 == "chr1" || $4 == "chr2" || $4 == "chr3" || $4 == "chr4" || $4 == "chr5" || $4 == "chr6" || $4 == "chr7" || $4 == "chr8" || $4 == "chr9" || $4 == "chr10" || $4 == "chr11" || $4 == "chr12" || $4 == "chr13" || $4 == "chr14" || $4 == "chr15" || $4 == "chr16" || $4 == "chr17" || $4 == "chr18" || $4 == "chr19" || $4 == "chr20" || $4 == "chr21" || $4 == "chr22" || $4 == "chrX" || $4 == "chrY") {print $0}}' exons > RES
