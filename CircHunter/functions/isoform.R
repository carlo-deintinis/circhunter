isoform <- function(data.folder, isoformdata_file) {
	cat("Obtaining circRNA main isoform\n")

	#fixed paths (mounted files)
#	isoformdata_file <- "/circhunter/isoformdata"
	#circRNA classification file (created by circRNA_classification.R script)
	circRNA_classification <- file.path(data.folder, "circRNA_classification")
	#prefix temporary files
	temp_prefix <- file.path(data.folder, "CHMAINISO")

	cleanup <- paste("rm -f ", temp_prefix, "*", sep="")
	system(cleanup, wait=TRUE)

	# ===============================
	# COMMANDS SECTION
	# ===============================

	# Filtering for canonical chromosomes
	canonical_isoforms <- paste(temp_prefix, "_genes_isoform_canonical", sep="")

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
		isoformdata_file, ">", 								#input file
		canonical_isoforms
	)									#output file
#		"../isoformdata > ",                                                     # input file
#		"../data/CHMAINISO_genes_isoform_canonical",                             # output file
#		sep="")

	# Obtaining isoform value
	isoform_value <- paste(temp_prefix, "_isoform_value", sep="")
	getIsoformValue <- paste(
		"cut -f 4", canonical_isoforms, 	#input file
		"| rev | cut -c1-3 | rev", 			#obtaining isoform value
		">", isoform_value					#output file with isoform values
	)

	# getIsoformValue <- paste("cut -f 4 ../data/CHMAINISO_genes_isoform_canonical",  # input file
	# 	"| rev | cut -c1-3 | rev",                                              # obtaining isoform value
	# 	"> ../data/CHMAINISO_isoform_value"                                     # output file with isoform values
	# )

	# Merge gene isoform and isoform values files
	unsorted_isoform_values <- paste(temp_prefix, "_genes_isoforms_value_unsorted", sep="")
	assignGeneIsoform <- paste("paste", canonical_isoforms, isoform_value, ">", unsorted_isoform_values)

# assignGeneIsoform <- paste("paste",                          # command
# 	"../data/CHMAINISO_genes_isoform_canonical",         # gene isoform file
# 	"../data/CHMAINISO_isoform_value",                   # isoform value file
# 	"> ../data/CHMAINISO_genes_isoforms_value_unsorted", # output file
# 	sep=" ")
	sorted_genes <- paste(temp_prefix, "_01_genes_isoforms_value", sep="")
	sortGenes <- paste("sort -k 4,4 -k 5,5", unsorted_isoform_values, ">", sorted_genes)

#sortGenes <- paste("sort -k 4,4 -k 5,5",                   # sorting command
#	"../data/CHMAINISO_genes_isoforms_value_unsorted", # input file
#	"> ../data/CHMAINISO_01_genes_isoforms_value",     # output file
#	sep=" ")

	# Obtaining transcripts from classification
	transcripts_temp <- paste(temp_prefix, "_ENST", sep="")

	getTranscripts <- paste(
		"cut -f 1", circRNA_classification, 		#input data
		"| awk 'BEGIN {FS=\"_\"} {print $4}'",	# command
		">", transcripts_temp					#output file
	)
# getTranscripts <- paste("cut -f 1 ../data/circRNA_classification", # input data from file
# 	"| awk 'BEGIN {FS=\"_\"} {print $4}'",                     # command
# 	"> ../data/CHMAINISO_ENST",                                # output file
# 	sep=" ")

	# Obtaining isoform data from ENST
	transcripts_def <- paste(temp_prefix, "_ENST_ISO", sep="")

	getIsoformData <- paste(
		"python data_extractor.py",  # used program
		sorted_genes, 				#input data file
		transcripts_temp, 			#input query file
		"1 0", 						#column parameters
		"| cut -f 4,5",				#extracted data
		">", transcripts_def		#output file
	)

# getIsoformData <- paste("python data_extractor.py",  # used program
# 	"../data/CHMAINISO_01_genes_isoforms_value", # input data file
# 	"../data/CHMAINISO_ENST",                    # input query file
# 	"1 0",                                       # column parameters
# 	"| cut -f 4,5",                              # extracted data
# 	"> ../data/CHMAINISO_ENST_ISO",              # output file
# 	sep=" ")

	# Pasting results
	circ_isoforms <- paste(temp_prefix, "_circ_iso", sep="")
	pasteIsoCircData <- paste("paste",
		transcripts_def, 			# input enst-iso file
		circRNA_classification, 	# input classification file
		">", circ_isoforms			#output file
	)

# pasteIsoCircData <- paste("paste",        # paste command
# 	"../data/CHMAINISO_ENST_ISO",     # input enst-iso file
# 	"../data/circRNA_classification", # input classification file
# 	"> ../data/CHMAINISO_circ_iso",   # output file
# 	sep=" ")

# Obtaining unique classification
	univocal_temp <- paste(temp_prefix, "_circRNA_univocal_classification", sep="")
	uniqueClassification <- paste("python univocal_classifier.py", circ_isoforms, ">", univocal_temp)


#uniqueClassification <- paste("python univocal_classifier.py",  # command
#	"../data/CHMAINISO_circ_iso",                               # input file
#	"> ../data/CHMAINISO_circRNA_univocal_classification",     # univocal classification output
#	sep=" ")

	univocal_unsorted <- paste(temp_prefix, "_unsorted_circRNA_univocal_classification", sep="")
	postClassification <- paste("python post_univocal.py", univocal_temp, ">", univocal_unsorted)

# postClassification <- paste("python post_univocal.py",                  # command
# 	"../data/CHMAINISO_circRNA_univocal_classification",               # input file
# 	"> ../data/CHMAINISO_unsorted_circRNA_univocal_classification",    # post-univocal output
# 	sep =" ")

	univocal_def <- file.path(data.folder, "circRNA_univocal_classification")
	resultSort <- paste("sort", univocal_unsorted, ">", univocal_def)

# resultSort <- paste("sort",                                         # command
# 	"../data/CHMAINISO_unsorted_circRNA_univocal_classification",  # input file
# 	"> ../data/circRNA_univocal_classification",                    # FINAL output file
# 	sep=" ")

# ===============================
# PIPELINE SECTION
# ===============================

	# Building pipeline
	command_list <- c(
		filter,   				# Filtering for canonical chromosomes
		getIsoformValue,        # Obtaining isoform value
		assignGeneIsoform,      # Obtaining isoform value
		sortGenes,              # Obtaining isoform value
		getTranscripts,         # Obtaining transcripts from classification
		getIsoformData,         # Obtaining isoform data from ENST
		pasteIsoCircData,       # Pasting results
		uniqueClassification,   # Obtaining unique classification
		postClassification,     # Post-classification final step
		resultSort,             # Result sorting
		cleanup                # Final CHRMAINISO temp file cleanup
	)
	# ===============================
	# EXECUTION SECTION
	# ===============================

	for (command in command_list) {
		system(command, wait=TRUE)
	}
}
