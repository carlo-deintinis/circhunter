# Welcome to CircHunter

### Filtering exon data in order to obtain only exons from canonical chromosomes
filtering <- paste("awk -v OFS='\t' '{if($4 == \"chr1\" || $4 == \"chr2\" || $4 == \"chr3\" || $4 == \"chr4\" || $4 == \"chr5\" || $4 == \"chr6\" || $4 == \"chr7\" || $4 == \"chr8\" || $4 == \"chr9\" || $4 == \"chr10\" || $4 == \"chr11\" || $4 == \"chr12\" || $4 == \"chr13\" || $4 == \"chr14\" || $4 == \"chr15\" || $4 == \"chr16\" || $4 == \"chr17\" || $4 == \"chr18\" || $4 == \"chr19\" || $4 == \"chr20\" || $4 == \"chr21\" || $4 == \"chr22\" || $4 == \"chrX\" || $4 == \"chrY\") {print $0}}' ", genome, " > ../data/exon_data")
system(filtering, wait=TRUE)


### Obtaining intron data from the available exon data
# Sorting exons
sorting <- "sort -k 4,4 -k 1,1 -k 2,2 -k8,8 -V ../data/exon_data > ../data/exon_sorted"
system(sorting, wait=TRUE)

# Obtaining intron information
introns <- "python intron_exporter.py ../data/exon_sorted > ../data/full_genome"
system(introns, wait=TRUE)


### Creating BED files from circRNA and exon data files

# Genome
extract_columns <- "awk -v OFS='\t' '{print $4,$5,$6,$2\"_\"$3,\".\",$7}' ../data/full_genome > ../data/genome_tofix.bed"
system(extract_columns, wait=TRUE)

fix_strand <- "cat ../data/genome_tofix.bed | awk -v OFS='\t' '{if ($6 == 1) {$6 = \"+\"} else if ($6 == -1) {$6 = \"-\"}; print }' > ../data/genome.bed"
system(fix_strand, wait=TRUE)

cleanup <- "rm ../data/genome_tofix.bed"
system(cleanup, wait=TRUE)

# circRNAs
extract_circRNA_cols <- paste("awk -v OFS='\t' '{print $1,$2,$3,$4,\".\",$5}'", circ, "> ../data/circRNA_tofix.bed")
system(extract_circRNA_cols, wait=TRUE)

fix_circRNA_strand <- "cat ../data/circRNA_tofix.bed | awk -v OFS='\t' '{if ($6 == 1) {$6 = \"+\"} else if ($6 == -1) {$6 = \"-\"}; print }' > ../data/circRNA.bed"
system(fix_circRNA_strand, wait=TRUE)

cleanup <- "rm ../data/circRNA_tofix.bed"
system(cleanup, wait=TRUE)

### Overlapping between circRNAs and genomic features using bedtools
overlap <- "bedtools intersect -a ../data/genome.bed -b ../data/circRNA.bed -wa -wb -s > ../data/overlap_tofix"
system(overlap, wait=TRUE)

#Removing score columns
fix <- "cat ../data/overlap_tofix | awk -v OFS='\t' '{print $1,$2,$3,$4,$6,$7,$8,$9,$10,$12}' > ../data/overlap"
system(fix, wait=TRUE)

cleanup <- "rm ../data/overlap_tofix"
system(cleanup, wait=TRUE)

### CircRNA classification using circ_classifier.py
classification <- "python circ_classifier.py ../data/full_genome ../data/overlap > ../data/circRNA_classification"
system(classification, wait=TRUE)

# Procedure to add circRNAs missed by bedtools alignment

# circRNAs from classification
addmissing <- "cat ../data/circRNA_classification | awk 'BEGIN {FS=\"_|\t\"} {print $1\"_\"$2\"_\"$3}' | sort -u > ../data/names"
system(addmissing, wait=TRUE)

# all circRNAs
addmissing <- paste("cut -f 4", circ, "| sort -u > ../data/fullnames")
system(addmissing, wait=TRUE)

# Identification of circRNAs missed by bedtools
addmissing <- "comm -3 ../data/fullnames ../data/names | awk 'BEGIN {FS=\"\t\"} {print $0\"_NA\tintergenic\"}' > ../data/missed"
system(addmissing, wait=TRUE)

# Adding circRNAs to classification
addmissing <- "cat ../data/circRNA_classification ../data/missed > ../data/total"
system(addmissing, wait=TRUE)

# Cleaning files
addmissing <- "rm ../data/fullnames ../data/names ../data/circRNA_classification" #../data/missed
system(addmissing, wait=TRUE)

# Renaming output file
addmissing <- "mv ../data/total ../data/circRNA_classification"
system(addmissing, wait=TRUE)

# Final cleanup
finalcleanup <- "rm ../data/exon_data ../data/exon_sorted ../data/full_genome ../data/missed ../data/overlap ../data/circRNA.bed ../data/genome.bed"
system(finalcleanup, wait=TRUE)
