# This script uses genomic coordinates of circRNAs to extract sequences in FASTA format
# Filename for exon data: circRNA_hash_junction_coord.csv

#Uncomment to install dependencies
#source("https://bioconductor.org/biocLite.R")
#biocLite("GenomicRanges")
#source("https://bioconductor.org/biocLite.R")
#biocLite("BSgenome")
#source("http://bioconductor.org/biocLite.R")
#biocLite("BSgenome.Hsapiens.UCSC.hg19")


# Function used to load correct genome
installer <- function(x){

	if (x %in% rownames(installed.packages()) == TRUE) {

	cat(paste("Loading genome", x,"\n"))
	library(x, character.only = TRUE)

	} else {

	source("https://bioconductor.org/biocLite.R")
	biocLite(selectedgenome)
	cat(paste("Loading genome", x,"\n"))
	library(x, character.only = TRUE)

	}
}



# Loading dependencies
library(GenomicRanges)
library(BSgenome)


# Checking required genome assembly

if (assembly == "hg19") {

	selectedgenome <- "BSgenome.Hsapiens.UCSC.hg19"

} else if (assembly == "hg18") {

	selectedgenome <- "BSgenome.Hsapiens.UCSC.hg18"

} else if (assembly == "hg38") {

	selectedgenome <- "BSgenome.Hsapiens.UCSC.hg38"

} else {

	cat("WARNING: Invalid genome assembly\n")
	quit(save="no")
}


installer(selectedgenome)




circ <- read.csv("../data/backsplicing_coord.csv", header = TRUE, sep="\t")

# Creating objects needed for GRanges object
circ_seqnames <- circ$chromosome
circ_strand <- circ$strand

# 5' exon
circ_start1 <- circ$ex5_start
circ_end1 <- circ$ex5_end

# 3' exon
circ_start2 <- circ$ex3_start
circ_end2 <- circ$ex3_end

# Shared
circ_name <- as.character(circ$circRNA_NAME)
circ_metadata <- DataFrame(as.character(circ_name))
names(circ_metadata) <- c("circRNA name")

# Creating GRanges objects
circ_5exon <- GRanges(seqnames = circ_seqnames, ranges = IRanges(start = circ_start1, end = circ_end1), strand = circ_strand, mcols = circ_metadata)
circ_3exon <- GRanges(seqnames = circ_seqnames, ranges = IRanges(start = circ_start2, end = circ_end2), strand = circ_strand, mcols = circ_metadata)

cat("Obtaining sequences\n")
# Sequence extraction plus strand
circ_5exon_p <- subset(circ_5exon, strand(circ_5exon) == "+")
circ_3exon_p <- subset(circ_3exon, strand(circ_3exon) == "+")
circ_seq5_p <- getSeq(Hsapiens, circ_5exon_p)
circ_seq3_p <- getSeq(Hsapiens, circ_3exon_p)

# Sequence extraction negative strand
circ_5exon_n <- subset(circ_5exon, strand(circ_5exon) == "-")
circ_3exon_n <- subset(circ_3exon, strand(circ_3exon) == "-")
circ_seq5_n <- reverseComplement(getSeq(Hsapiens, circ_5exon_n))
circ_seq3_n <- reverseComplement(getSeq(Hsapiens, circ_3exon_n))

circ_seq5_n <- getSeq(Hsapiens, circ_5exon_n)
circ_seq3_n <- getSeq(Hsapiens, circ_3exon_n)

circ_junction_p <- xscat(circ_seq3_p, circ_seq5_p)
circ_junction_n <- reverseComplement(xscat(circ_seq3_n, circ_seq5_n))

#Name addition
name_p <- subset(circ, circ$strand == "+")$circRNA_NAME
name_n <- subset(circ, circ$strand == "-")$circRNA_NAME
  
names(circ_junction_p) <- name_p
names(circ_junction_n) <- name_n
circ_junction <- c(circ_junction_p, circ_junction_n)

writeXStringSet(circ_junction, "../data/circRNA_backsplicing_sequences.fasta")
