cat("Obtaining circRNA main isoform\n")

# Initial clean up
cleanup <- "rm -f ../data/CHMAINISO*"
system (cleanup, wait=TRUE)

# ===============================
# COMMANDS SECTION
# ===============================

# Filtering for canonical chromosomes

filter <- paste("awk -v OFS='\\t' '{if(",
	" $3 == \"chr1\" || $3 == \"chr2\" || $3 == \"chr3\" ||",
	" $3 == \"chr4\" || $3 == \"chr5\" || $3 == \"chr6\" ||",
	" $3 == \"chr7\" || $3 == \"chr8\" || $3 == \"chr9\" ||",
	" $3 == \"chr10\" || $3 == \"chr11\" || $3 == \"chr12\" ||",
	" $3 == \"chr13\" || $3 == \"chr14\" || $3 == \"chr15\" ||",
	" $3 == \"chr16\" || $3 == \"chr17\" || $3 == \"chr18\" ||",
	" $3 == \"chr19\" || $3 == \"chr20\" || $3 == \"chr21\" ||",
	" $3 == \"chr22\" || $3 == \"chrX\" || $3 == \"chrY\")",
	"{print $0}}' ",
	"../isoformdata > ",                                                     # input file
	"../data/CHMAINISO_genes_isoform_canonical",                             # output file
	sep="")

# Obtaining isoform value

getIsoformValue <- paste("cut -f 4 ../data/CHMAINISO_genes_isoform_canonical",  # input file
	"| rev | cut -c1-3 | rev",                                              # obtaining isoform value
	"> ../data/CHMAINISO_isoform_value",                                     # output file with isoform values
	sep=" ")

assignGeneIsoform <- paste("paste",                          # command
	"../data/CHMAINISO_genes_isoform_canonical",         # gene isoform file
	"../data/CHMAINISO_isoform_value",                   # isoform value file
	"> ../data/CHMAINISO_genes_isoforms_value_unsorted", # output file
	sep=" ")

sortGenes <- paste("sort -k 4,4 -k 5,5",                   # sorting command
	"../data/CHMAINISO_genes_isoforms_value_unsorted", # input file
	"> ../data/CHMAINISO_01_genes_isoforms_value",     # output file
	sep=" ")

# Obtaining transcripts from classification

getTranscripts <- paste("cut -f 1 ../data/circRNA_classification", # input data from file
	"| awk 'BEGIN {FS=\"_\"} {print $4}'",                     # command
	"> ../data/CHMAINISO_ENST",                                # output file
	sep=" ")

# Obtaining isoform data from ENST

getIsoformData <- paste("python data_extractor.py",  # used program
	"../data/CHMAINISO_01_genes_isoforms_value", # input data file
	"../data/CHMAINISO_ENST",                    # input query file
	"1 0",                                       # column parameters
	"| cut -f 4,5",                              # extracted data
	"> ../data/CHMAINISO_ENST_ISO",              # output file
	sep=" ")

# Pasting results

pasteIsoCircData <- paste("paste",        # paste command
	"../data/CHMAINISO_ENST_ISO",     # input enst-iso file
	"../data/circRNA_classification", # input classification file
	"> ../data/CHMAINISO_circ_iso",   # output file
	sep=" ")

# Obtaining unique classification

uniqueClassification <- paste("python univocal_classifier.py",  # command
	"../data/CHMAINISO_circ_iso",                               # input file
	"> ../data/CHMAINISO_circRNA_univocal_classification",     # univocal classification output
	sep=" ")

postClassification <- paste("python post_univocal.py",                  # command
    "../data/CHMAINISO_circRNA_univocal_classification",               # input file
    "> ../data/CHMAINISO_unsorted_circRNA_univocal_classification",    # post-univocal output
    sep =" ")

resultSort <- paste("sort",                                         # command
    "../data/CHMAINISO_unsorted_circRNA_univocal_classification",  # input file
    "> ../data/circRNA_univocal_classification",                    # FINAL output file
    sep=" ")

# ===============================
# PIPELINE SECTION
# ===============================

# Building pipeline
command_list <- c(filter,   # Filtering for canonical chromosomes
    getIsoformValue,        # Obtaining isoform value
    assignGeneIsoform,      # Obtaining isoform value
    sortGenes,              # Obtaining isoform value
    getTranscripts,         # Obtaining transcripts from classification
    getIsoformData,         # Obtaining isoform data from ENST
    pasteIsoCircData,       # Pasting results
    uniqueClassification,   # Obtaining unique classification
    postClassification,     # Post-classification final step
    resultSort,             # Result sorting
    cleanup)                # Final CHRMAINISO temp file cleanup

# ===============================
# EXECUTION SECTION
# ===============================

for (command in command_list){

	system(command, wait=TRUE)

}

