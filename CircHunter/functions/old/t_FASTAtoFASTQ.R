# Welcome to CircHunter
# This script converts a FASTA file to a FASTQ file

conversion <- paste("python fasta_to_fastq.py ", FASTA, " > ", FASTA, ".fastq", sep="")
system(conversion, wait=TRUE)
