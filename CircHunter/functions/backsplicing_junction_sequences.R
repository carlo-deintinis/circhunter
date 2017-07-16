# Welcome to CircHunter
# This script allows to obtain backsplicing junction sequences from a circRNA list

con <- file(circ, "r")
first_line <- read.table(con, nrows=1, sep='\t')
close(con)

# Cheching if strand conversion is required and copying file
if (first_line$V5 == '1' | first_line$V5 == '-1'){

	conversion <- paste("cat", circ, "| awk -v OFS='\t' '{if ($5 == 1) {$5 = \"+\"} else if ($5 == -1) {$5 = \"-\"}; print }' | cut -f 4,5 > ../data/circtoseq")
	system(conversion, wait=TRUE)

} else {
	
	copy_cf <- paste("cut -f 4,5", circ, " > ../data/circtoseq")
	system(copy_cf, wait=TRUE)
}

# Obtaining backsplicing junction sequences

backsplicing <- "python 70bp_junction_coordinates.py ../data/circtoseq > ../data/backsplicing_coord"
system(backsplicing, wait=TRUE)

cleanup <- "rm ../data/circtoseq"
system (cleanup, wait=TRUE)

# Header
create_header <- paste("circRNA_NAME", "chromosome", "strand", "ex5_start", "ex5_end", "ex3_start", "ex3_end", sep='\t')
out_file <- file("../data/header_backsplicing")
writeLines(create_header, out_file)
close(out_file)

# Creating csv file containing backsplicing junction sequences
backsplicing_coordinates <- "cat ../data/header_backsplicing ../data/backsplicing_coord | cut -f 1,2,3,4,5,6,7 > ../data/backsplicing_coord.csv"
system(backsplicing_coordinates, wait=TRUE)

cleanup <- "rm ../data/header_backsplicing ../data/backsplicing_coord"
system(cleanup, wait=TRUE)

# Obtaining backsplicing junction sequences
source("backsplicing_seq.R")

cleanup <- "rm ../data/backsplicing_coord.csv"
system(cleanup, wait=TRUE)
