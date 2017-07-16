#!/usr/bin/env python

import os,sys

"""
POST UNIVOCAL
This script will take the output of the univolcal circRNA classification file.
The output is a file where only multiexon, monoexon and putative exon are repeated, while intronic, intergenic and intertranscript circRNAs are reported only one time.
"""

# Opening input file with univocal classification
circ_file = open(sys.argv[1]).readlines()

data_dic = {} # Dictionary with full file data
circ_dic = {} # Dictionary with circRNA classification information
sorted_circ_dic = {} # Sorted circ_dic

"""
Function: dic_debugger
"""
def dic_debugger (dic):	
    for entry in dic:
        print("%s\t%s" % (entry, dic[entry]))

"""
Function: class_converter
Converts circRNA classification in a sortable string

Every classification beginning with 01 will have priority over
the main isoform if the main isoform itself does not contain it.
"""

def class_converter (x):
	
	converter = {
	"multiexon":        "01_multiexon",
	"monoexon":         "01_monoexon",
	"putativeexon":     "01_putativeexon",
	"intronic":         "05_intronic",
	"intergenic":       "06_intergenic",
	"intertranscript":  "07_intertranscript",
	}
	
	conversion = converter.get(x)
	return (conversion)


"""
Function: data_parser
Organize data and pass it to dic_filler function
"""
def data_parser (x):

        circ_name = x[0] # name as chromosome_start_end
        class_index = class_converter(x[1]) # classific. conversion

        g = x[2].split("-") # Splitting gene name
        g_info = len(g) # Gene name sections        
       
        # Getting the correct gene name excluding only its intex 
        g_index = 0 # Index used to explore gene name sections
        g_parts = [] # Used to store gene name parts
        while g_index < (g_info-1): # exclude the last position
            g_parts.append(g[g_index]) # add gene name part
            g_index += 1 # increase position
        gene_name = '-'.join(g_parts) # gene name
        gene_iso = g[g_info-1] # gene isoform
        
        line_data = x # whole line data
        line_name = "%s_%s" % (circ_name, x[2]) # whole line name
        circ_values = (class_index, gene_iso, gene_name)
        return(circ_name, circ_values, line_name, line_data)
"""
Function: fill_dic
Fills a dictionary with provided key and values
Modes:	y = check if the key is already in the dictionary
		n = doesn't check dictionary (use only when data append is not needed)
"""
def fill_dic(dic, k, v, mode):
        
        # Key existence check
        # Data is appended to the key
        if mode == "y":
            if k not in dic:
                dic[k] = []
            dic[k].append(v)
	
	# No check for key existence
	# Data overwrite if duplicate keys are present	
	else:
            dic[k] = v

"""
Function: dic_sorter
Sorts the tuples of the various keys in a dictionary
"""
def dic_sorter (dic, dic_sorted):
    
    for key in dic:
        dic_sorted[key] = sorted(dic[key])

"""
Function: univocal_circ
Obtains a univocal classification for circRNAs
"""
def univocal_circ (c_dic, d_dic):

    for circ in c_dic:

        stop_circ = False
        stop_iso = False

        for iso in c_dic[circ]:
            iso_index = iso[0].split("_")[0]
            # Block for exonic classifications
            if (iso_index == "01" and stop_circ == False):
                search_key = "%s_%s-%s" % (circ, iso[2], iso[1])
                print ("\t").join(d_dic[search_key])
                stop_iso = True
            # Block for intronic, intertranscript, intergenic
            elif (stop_circ == False and stop_iso == False):
                search_key = "%s_%s-%s" % (circ, iso[2], iso[1])
                
                if search_key in d_dic:
                    print ("\t").join(d_dic[search_key])
                else:
                    iso_class = iso[0].split("_")[1]
                    circdata = "%s\t%s" % (circ, iso_class)
                    print(circdata)
                stop_circ = True

# MAIN PROGRAM
for circ in circ_file:
    data = circ.strip().split("\t")
    dparsed = data_parser(data) # Extract data from line
    
    fill_dic(data_dic, dparsed[2], dparsed[3], "n") # filling dic
    fill_dic(circ_dic, dparsed[0], dparsed[1], "y") # filling dic

    dic_sorter(circ_dic, sorted_circ_dic) # sorting dic

univocal_circ(sorted_circ_dic, data_dic)

# Debug
#print("\nData dic")
#dic_debugger(data_dic)
#print("\nCirc dic")
#dic_debugger(circ_dic)
#print("\nSorted circ dic")
#dic_debugger(sorted_circ_dic)
