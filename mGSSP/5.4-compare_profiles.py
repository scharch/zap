#!/usr/bin/env python3

'''
5.4-compare_profiles.py

This script reads in GSSPs constructed by 5.2-make_profiles.py and calculates
      the matrix of Jensen-Shannon divergences between all GSSPs, the rarity
      of each substitution observed in each GSSP, and the Shannon entropy of
      the subsitutions observed at each position of each gene.
   
NOTE: GSSP files are assumed to have names of the form "sourceData-info_profile.txt".
      This program therefore uses everything up to the first underscore as the name
      of the profile in the output. Thus:
      `5.3-compare_profiles.py trial Condition_1_profile.txt Condition_2_profile.txt`
      will produce output that compares "Condition" to "Condition", obfuscating which
      one came from which original source.

Usage: 5.4-compare_profiles.py <outHead> GSSP...

Options:
    <outHead>   Stem of file name for output. Three files will be generated: 
                     <outHead>_jsdMatrix.txt, for all v. all JSD;
                     <outHead>_rarity.txt, with average and stddev of rarities; and
                     <outHead>_entropy.txt,weighted average shannon entropy for each gene/dataset
    GSSP        One or more text files containing GSSPs generated by 5.2-make_profiles.py

Added to SONAR as part of mGSSP on 2017-02-24.
Edited to use Py3 and DocOpt by CAS 2018-08-29.
Renamed as 5.4 by CAS 2018-09-05.

Copyright (c) 2011-2018 Columbia University and Vaccine Research Center, National
                         Institutes of Health, USA. All rights reserved.

'''

import sys, csv
from docopt import docopt
import pandas

try:
	from SONAR.mGSSP import *
except ImportError:
	find_SONAR = sys.argv[0].split("SONAR/mGSSP")
	sys.path.append(find_SONAR[0])
	from SONAR.mGGSP import *


def main():

	#open outputs
	rHandle = open( "%s_rarity.txt"%arguments['<outHead>'], "w" )
	rWriter = csv.writer(rHandle, delimiter = "\t")
	rWriter.writerow( ['dataset', 'Vgene', 'position', 'germline', 'mutation', 'rarity', 'stdv_r'] )

	eHandle = open( "%s_entropy.txt"%arguments['<outHead>'], "w" )
	eWriter = csv.writer(eHandle, delimiter = "\t")
	eWriter.writerow( ['dataset', 'Vgene', 'entropy'] )

	#load all the data (hopefully this shouldn't kill memory)
	data = []
	for dataset in arguments['GSSP']:
		data.append( GSSP( dataset, name=dataset.split("/")[-1].split("_")[0] ) )

	print( "Data loaded!" )

	#iterate through the list and run calculations
	bigMatrix = [ [] for dummy in range(len(data)) ]
	for x, spectrum1 in enumerate(data):

		print( "Running calculations on %s..." % spectrum1.name )

		#single dataset calculations
		spectrum1.computeRarity()
		for row in spectrum1.rarity:
			rWriter.writerow( row )
		spectrum1.profileEntropy(use_all=False)
		for row in spectrum1.entropy:
			eWriter.writerow( row )

		#now do the big distance matrix
		bigMatrix[x].append( spectrum1.betweenV() )

		for y, spectrum2 in enumerate(data[x+1:]):
			offDiagonal = spectrum1.compare(spectrum2)
			bigMatrix[x].append( offDiagonal )
			bigMatrix[x+y+1].append( offDiagonal.transpose() )

	#now tell pandas to make it all into one big matrix and write it
	combinedRows = []
	for row in bigMatrix:
		combinedRows.append(pandas.concat(row))
	full = pandas.concat(combinedRows, axis=1)
	full.to_csv("%s_jsdMatrix.txt"%sys.argv[1], sep="\t", float_format="%.3f", na_rep="NA")#, index=False)
	
	#clean up
	rHandle.close()
	eHandle.close()
	

if __name__ == "__main__":

	arguments = docopt(__doc__)
	
	#log command line
	logCmdLine(sys.argv)	

	main()
