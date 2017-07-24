#!/usr/bin/env python

import os,sys

"""
UNIVOCAL CLASSIFIER
This script outputs a univocal circRNA classification
"""

classification_dic = {}			#circRNA classification dictionary
sorted_classification_dic = {}	#circRNA classification dictionary SORTED
data_dic = {}					#circRNA data retrival dictionary
univocal_dic = {}				#Final classification dictionary

# Opening input file containing CircHunter's circRNA classification
circ_file = open(sys.argv[1]).readlines()

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
	"multiexon":		"01_multiexon",
	"monoexon":			"01_monoexon",
	"putativeexon":		"01_putativeexon",
	"intronic":			"05_intronic",
	"intergenic":		"06_intergenic",
	"intertranscript":	"07_intertranscript",
	}
	
	conversion = converter.get(x)
	return (conversion)


"""
Function: data_parser
Organize data and pass it to dic_filler function
"""
def data_parser (x):
	
	y = x[2].split("_") # Splitting circRNA name
	z = x[0].split("-") # Splitting gene name
	iso_index = x[1]
	ENST = y[3]
	
	# Variables for dic_circ (univocal circRNA dic)
	#circ_name = "%s_%s_%s" % (y[0], y[1], y[2]) # Defining circRNA name
	circ_name = "%s_%s_%s_%s" % (y[0], y[1], y[2], z[0]) # Defining circRNA name
	class_index = class_converter(x[3])
	circ_values = (iso_index, class_index, ENST)

	# Variables for circRNA raw data inside dic_data
	line_name = "%s_%s" % (x[2], x[3])
	line_data = x
	return (circ_name, circ_values, line_name, line_data)

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
Function: circRNA_classifier
Allows to obtain a univocal classification for a circRNA
"""
def classifier (dic, key, udic):
	
	if key not in udic:
		udic[key] = []
	
	# First pass for higher importance classifications
	for element in dic[key]:
		class_index = element[1].strip().split("_")
		
		# Appending to univocal dictionary only if it is empty
		if str(class_index[0]) == "01" and len(udic[key]) == 0:
			udic[key] = element
	
	# Second pass for lower importance classifications
	for element in dic[key]:
		
		# Appending to univocal dictionary onlu if no higher importance classification was found
		if len(udic[key]) == 0 and str(class_index[0]) != "07":
			udic[key] = element
	
	# Second pass for intertranscript classifications
	for element in dic[key]:
		
		# Appending to univocal dictionary onlu if no higher importance classification was found
		if len(udic[key]) == 0:
			udic[key] = element

"""
Function: circRNA_data_retrival
Returns detailed information about the selected circRNA isoform
"""
def circRNA_data_retrival (dic, key):
	
	# Reconstructing key for info dictionary	
	cn = key.strip().split("_")							# Splitting for circ name
	circ_name = ("%s_%s_%s" % (cn[0], cn[1], cn[2]))	# Obtaining chr_start_end	
	ENST = dic[key][2]									# Obtaining ENST
	classification = dic[key][1].strip().split("_")[1]	# Obtaining classification
	
	circ_key = ("%s_%s_%s" % (circ_name, ENST, classification))	

	return (circ_key)

"""
Function: output parser

"""
def output_parser (dic, key):
	
	circRNA_name = ["_".join(circ_key.strip().split("_")[0:3])]	# circRNA name (chr_start_end)
	classification = [circ_data[3]]								# Classification
	isoform_info = circ_data[0:2]								# Transcript name
	other_data = circ_data[4:]
	
	output_data = circRNA_name + classification + isoform_info + other_data
	return (output_data)

# MAIN PROGRAM
for circ in circ_file:
	
	data = circ.strip().split("\t")
	dparsed = data_parser(data) # Extract data from line
	fill_dic(classification_dic, dparsed[0], dparsed[1], "y") #Fill classification dictionary
	fill_dic(data_dic, dparsed[2], dparsed[3], "n") # Fill data dictionary with circRNA full line data

dic_sorter(classification_dic, sorted_classification_dic) # Sorting classification dic
#classification_dic = {} # Cleaning up memory


# Univocal classification
for circRNA in sorted_classification_dic:
	classifier(sorted_classification_dic, circRNA, univocal_dic)
#sorted_classification_dic = {} # Cleaning up memory

# Data retrival
for circRNA in univocal_dic:
	circ_key = circRNA_data_retrival(univocal_dic, circRNA)	# Retriving circRNA key
	circ_data = data_dic[circ_key]							# Retriving circRNA data
	final_data = output_parser (circ_data, circ_key)		# Formatting output
	print("\t".join(final_data))


# Debug
#print("\nDEBUG")
#print("\nClassification dic")
#dic_debugger(classification_dic)
#print("\nSORTED Classification dic")
#dic_debugger(sorted_classification_dic)
#print("\nData dic")
#dic_debugger(data_dic)
#print("\nUnivocal dic")
#dic_debugger(univocal_dic)
