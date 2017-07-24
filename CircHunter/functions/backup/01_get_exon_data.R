# Welcome to CircHunter
# This script extracts the required exon data from ensembl

library(biomaRt)

# Choosing the right dataset
my_genome <- useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl", GRCh = 37)

# Extracting data
# WARNING: limited to one transcript for test purposes
exons <- getBM(attributes=c("ensembl_gene_id", "ensembl_transcript_id", "ensembl_exon_id", "chromosome_name", "exon_chrom_start", "exon_chrom_end", "strand", "rank", "start_position", "end_position", "transcript_start", "transcript_end"),
      filters=c("chromosome_name"),
      values=list(chromosome_name=c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "X", "Y")),
      mart = my_genome)

# Correcting chromosome names
exons$chromosome_name <- paste("chr", exons$chromosome_name, sep="")

# Saving results to exons file
write.table(exons, file="exons", sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)


# SINGLE TRANSCRIPT FILTER VALUE
## ensembl_transcript_id="ENST00000367770"

# EXTRA
## Getting attributes list
### att <- listAttributes(my_genome)
### write.csv(att, file="attributes.csv")
