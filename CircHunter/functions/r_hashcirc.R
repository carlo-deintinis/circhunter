# =======================================
# PRELIMINARY OPERATIONS
# =======================================

cat("Inside r_hashcirc.R\n")

# Make variable with both filenames
filecheck <- c(rnaseq, junctionseqs)

# Purges temporary files
purgetemp <- "rm -f ../data/CHTEMP* ../data/outputhashcirc* ../data/readcount*"
system (purgetemp, wait=TRUE)


# =======================================
# FUNCTIONS SECTION
# =======================================


# FUNCTION: converter
## Converts FASTA files into FASTQ files
## Renames the FASTQ files and places them in the CircHunter data directory
converter <- function(element){
	
	# Check first character of file
	check <- file(element, "r")
	first_line <- readLines(check, n=1)
	
	# Variables for file renaming
	pathname <- substr(element, start=1, stop=3)
	filename <- substr(element, start=4, stop=nchar(element))
	newname <- paste(pathname, "data/CHTEMP", filename, sep="")

	# Check if conversion is needed
	if (substr(first_line,0,1) == ">"){
	
		# Mounted FASTA files are converted into FASTQ files and renamed
		cat ("FASTA file ", element, " will be converted to FASTQ\n", sep="")
		conversion <- paste("python fasta_to_fastq.py ", element, " > ", newname,".fastq", sep="")
		system(conversion, wait=TRUE)

	} else if ((substr(first_line,0,1) == "@")) {
		
		# Mounted FASTQ files are renamed
		cat ("FASTQ file ", element, " will be only renamed\n", sep="")
		renaming <- paste("cp ", element, " ", newname, ".fastq", sep="")
		system(renaming, wait=TRUE)

	}
	else {

		cat ("ERROR: Please provide a valid FASTA or FASTQ file\n")

	}
	

}


# FUNCTION: splitter
## Uses fastqsplitter to split FASTQ files
## Renames the resulting FASTQ files for hashcirc

splitter <- function(index){
	
	cat("FASTQ files will be split into", index, "parts.\n", sep=" ")
	splitcommand <- paste("perl fastq-splitter.pl -n", index, "../data/CHTEMP*", sep=" ")
	system(splitcommand, wait=TRUE)

}

# FUNCTION: renamer
## Renames FASTQ files in a suitable way for HashCirc execution

renamer <- function(oldname){
	
	name <- substr(oldname, start=9, stop=nchar(oldname))	# Obtains file name
	nameparts <- strsplit(name, "\\.")[[1]]			# Splits file name into components

	index <- as.integer(strsplit(nameparts[2], "-")[[1]][2]) - 1

	renamingcommand <- paste("mv ../data/", name, " ../data/", nameparts[1], index, ".", nameparts[3], sep="")
	system(renamingcommand, wait=TRUE)

}


# =======================================
# MAIN PROGRAM
# =======================================


# Conversion step
for (providedfile in filecheck){

	converter(providedfile)

}

# Backup of unsplitted backsplicing junction sequences file
bkp <- "cp ../data/CHTEMPbksj.fastq ../data/ALLbksj.fastq"
system(bkp, wait=TRUE)


# Acquiring data for split and renaming step
convertedfiles <- system("ls ../data/CHTEMP*", intern=TRUE)	# Get list of FASTQ files
threadnumber <- as.integer(hcargs[2])				# Get thread number

if (threadnumber < 1){

	# Thread number check
	cat("ERROR: the argument \"thread number\" must be greater than 1\n")
	cat("Quitting program")
	quit(save="no")

}

# Split step
splitter(threadnumber)

# Removing conversion step temporary files
cleanconv <- paste("rm", paste(convertedfiles, collapse = " "), sep=" ")
system(cleanconv, wait=TRUE)


# Renaming step
torename <- system("ls ../data/CHTEMP*", intern=TRUE)	# Get list of FASTQ files to rename

for (tr in torename) {

	renamer(tr)

}

# HashCirc execution step 1
hashcircexecution <- paste(
	"/hashcirc/HashCheckerFilter",		# HashCirc program (first step)
	"/circhunter/data/CHTEMPbksj fastq",	# Backsplicing junction sequences files
	threadnumber,				# File parts (supplied thread nmumber)
	"/circhunter/data/CHTEMPrnaseq fastq",	# RNA-Seq files
	threadnumber,				# File parts (supplied thread number)
	"/circhunter/data/outputhashcirc",	# HashCirc output file
	paste(hcargs[1:5], collapse=" "),	# HashCirc arguments
	sep=" ")
print(hashcircexecution)
system(hashcircexecution, wait=TRUE)

# HashCirc execution step 2
i = 0 # Counter for step 2

while (i < threadnumber) {
	
	hashcircexecution_second <- paste(
		"/hashcirc/AlignmentCirRNA",				# HashCirc program (second step)
		"/circhunter/data/ALLbksj.fastq",			# Backsplicing junction sequences file
		paste("/circhunter/data/outputhashcircSim", i, sep=""),	# Output file of step 1
		hcargs[6],						# Matches argument
		paste("/circhunter/data/readcount", i, sep=""),		# Output file
		sep=" ")

	cat("HashCirc second step will run with the following command \n", hashcircexecution_second, "\n")
	system(hashcircexecution_second, wait=TRUE)
	i = i + 1 # Increasing step 2 counter

}

# Merge ouput files
merging <- "cd /circhunter/data/ ; for i in readcount* ; do cut -f 2 $i > $i.num ; done ; paste *num | awk '{c=0;for(i=1;i<=NF;++i){c+=$i}; pri
nt c}' > count
cut -f 1 readcount1 > id ; paste id count  > Read_count_temp ; echo -e \"ID\tCounts\" | cat - Read_count_temp > Read_count ; rm *num *temp read
count* id count ; chmod 777 *"

system(merging, wait=TRUE)
# Cleanup of temporary files
final_cleanup <- "rm -f ../data/CHTEMP* ../data/outputhashcirc* ../data/ALL*"
system(final_cleanup, wait=TRUE)
