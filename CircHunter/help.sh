#!/bin/bash

echo -e "\t\t\e[7m\e[1mCircHunter Help\e[0m"
echo
echo -e "\e[1mNAME\e[0m"
echo -e "\tCircHunter"
echo
echo -e "\e[1mSYNOPSIS\e[0m"
echo -e "\tbash circhunter.sh [execution mode] [arguments]"
echo
echo -e "Examples\tbash circhunter.sh -c -cr circRNA_file -as hg38"
echo -e "\t\tbash circhunter.sh -f -cr circRNA_file -sg hg19_file -as hg19"
echo -e "\t\tbash circhunter.sh -r -rs rnaseqfile -bj backsplicing_seq_file"
echo -e "\t\tbash circhunter.sh -q FASTA_file"
echo
echo -e "\e[1mDESCRIPTION\e[0m"
echo -e "\t\e[1m-h\e[0m,\e[1m --help\e[0m"
echo -e "\t\tPrints this screen"
echo
echo -e "\t\e[1mEXECUTION MODES\e[0m"
echo -e "\t\e[1m-f, --full\e[0m\t\t full (executes all modes below)"
echo -e "\t\e[1m-c, --classification\e[0m\t circRNA classification"
echo -e "\t\e[1m-s, --sequences\e[0m\t\t backsplicing junction sequences"
echo -e "\t\e[1m-r, --readcount\e[0m\t\t RNA-Seq read count of backsplicing junction sequences"
echo
echo -e "\t\e[1mARGUMENTS\e[0m"
echo -e "\t\e[1m-cr\e[0m,\e[1m --circrna\e[0m\t\t supplied circRNA list file"
echo -e "\t\e[1m-sg\e[0m,\e[1m --suppliedgenome\e[0m\t supplied exon export file"
echo -e "\t\e[1m-id\e[0m,\e[1m --isoformdata\e[0m\t supplied gene isoform data file"
echo -e "\t\e[1m-rs\e[0m,\e[1m --rnaseq\e[0m\t\t supplied RNA-Seq file"
echo -e "\t\e[1m-bj\e[0m,\e[1m --bksjunctions\e[0m\t supplied circRNA backsplicing junction sequences"
echo -e "\t\e[1m-of\e[0m,\e[1m --outputfolder\e[0m\t supplied output folder (defaults to ~/data)"
echo -e "\t\e[1m-as\e[0m,\e[1m --assembly\e[0m\t\t genome assembly to use for backsplicing sequences"
echo -e "\t\t\t\t\e[1m Choices:\e[0m hg18, hg19 (default), hg38"
echo -e "\t\e[1m-hc\e[0m,\e[1m --hashcirc\e[0m\t non-default arguments to pass to HashCirc (all arguments below)"
echo -e "\t\t\t\t 1) k-mer size 2) thread number 3) hash size"
echo -e "\t\t\t\t 4) collision list size 5) k-mer number 6) matches"
echo
echo -e "\t\e[1mTOOLS\e[0m"
echo -e "\t\e[1m-cd\e[0m\t Cleans docker images left on the system"
echo -e "\t\e[1m-q\e[0m\t FASTA to FASTQ converter (will output in the same folder of FASTA)"
echo
echo -e "\e[1mNOTES\e[0m"
echo -e "\tIf the exon file is not available, CircHunter will download GRCh37 (hg19)."
echo
echo -e "\e[1mREFERENCES\e[0m"
echo -e "\tCarlo De Intinis\t carlo.deintinis@gmail.com"
