#!/bin/bash

set -x

clear
cat << EOF
**********************************************************************************************
*                                                                                            *
* Welcome to SONAR!                                                                          *
*                                                                                            *
* This script will run the vignette using the CAP256 data from Doria-Rose et al Nature 2014. *
* It assumes that you have already verified that all dependencies are properly installed and *
* have run setup.py. If running in the Docker container, please make sure to start Docker    *
* '-e DISPLAY=\$DISPLAY' so that it can open X11 windows. Otherwise, the script will skip     *
* 2.2-get_island_interactive.R and instead load the preselected islands from the sample_data *
* folder.                                                                                    *
* This script will use 4 threads and should take approximately 15-20 hours to complete on an *
* average machine. Please note that it will wait for user input (to select the island(s)     *
* that correspond to lineage-related reads in 2.2) for each of the three time points; this   *
* should be approximately 1/4, 1/2, and 3/4 of the way through the full run.                 *
* An image of the tree generated by this vignette is also in the sample_data/ folder; minor  *
* differences in the tree are possible depending on how the islands in 2.2 are drawn.        *
*                                                                                            *
**********************************************************************************************
EOF

echo "Downloading week 34 data"
mkdir cap256-week34H
cd cap256-week34H/
fastq-dump SRR2126754

echo "Running Module 1"
sonar blast_V --fasta SRR2126754.fastq --locus H --derep --threads 4
sonar blast_J --threads 4
sonar finalize
sonar cluster_Sequences --id .97 --min2 2

echo "Running Module 2"
sonar id-div -a /SONAR/sample_data/CAP256-VRC26.01-12H.fa -t 4

if [[ -n "$DISPLAY" ]]; then
	sonar get_island output/tables/cap256-week34H_goodVJ_unique_id-div.tab --mab CAP256-VRC26.01 --mab CAP256-VRC26.08
	sonar getfastafromlist -l output/tables/islandSeqs.txt  -f output/sequences/nucleotide/cap256-week34H_goodVJ_unique.fa -o output/sequences/nucleotide/cap256-week34H_islandSeqs.fa
else
	cp /SONAR/sample_data/cap256-week34H_islandSeqs.fa output/sequences/nucleotide
fi
sonar intradonor --n /SONAR/sample_data/CAP256-VRC26.01-12H.fa --v IGHV3-30*18 --threads 4 -f
sonar groups -v 'IGHV3-30*18' -j 'IGHJ3*01' -t 4

echo "Processing week 48 data"
cd ..
mkdir cap256-week48H
cd cap256-week48H/
fastq-dump SRR1057705
sonar blast_V --fasta SRR1057705.fastq --locus H --derep --threads 4
sonar blast_J --threads 4
sonar finalize
sonar cluster_Sequences --id .97 --min2 2
sonar id-div -a /SONAR/sample_data/CAP256-VRC26.01-12H.fa -t 4
if [[ -n "$DISPLAY" ]]; then
	sonar get_island output/tables/cap256-week48H_goodVJ_unique_id-div.tab --mab CAP256-VRC26.01 --mab CAP256-VRC26.08
	sonar getfastafromlist -l output/tables/islandSeqs.txt  -f output/sequences/nucleotide/cap256-week48H_goodVJ_unique.fa -o output/sequences/nucleotide/cap256-week48H_islandSeqs.fa
else
	cp /SONAR/sample_data/cap256-week48H_islandSeqs.fa output/sequences/nucleotide
fi

echo "Processing week 59 data"
cd ..
mkdir cap256-week59H
cd cap256-week59H/
fastq-dump SRR1057707
sonar blast_V --fasta SRR1057707.fastq --locus H --derep --threads 4
sonar blast_J --threads 4
sonar finalize
sonar cluster_Sequences --id .97 --min2 2
sonar id-div -a /SONAR/sample_data/CAP256-VRC26.01-12H.fa -t 4
if [[ -n "$DISPLAY" ]]; then
	sonar get_island output/tables/cap256-week59H_goodVJ_unique_id-div.tab --mab CAP256-VRC26.01 --mab CAP256-VRC26.08
	sonar getfastafromlist -l output/tables/islandSeqs.txt  -f output/sequences/nucleotide/cap256-week59H_goodVJ_unique.fa -o output/sequences/nucleotide/cap256-week59H_islandSeqs.fa
else
	cp /SONAR/sample_data/cap256-week59H_islandSeqs.fa output/sequences/nucleotide
fi

echo "Starting longitudinal analysis"
cd ..
mkdir cap256-longitudinal
cd cap256-longitudinal
sonar merge_time --seqs ../cap256-week34H/output/sequences/nucleotide/cap256-week34H_islandSeqs.fa --labels w34 --seqs ../cap256-week48H/output/sequences/nucleotide/cap256-week48H_islandSeqs.fa --labels w48 --seqs ../cap256-week59H/output/sequences/nucleotide/cap256-week59H_islandSeqs.fa --labels w59
sonar igphyml -v 'IGHV3-30*18' --quick -f
sonar fliptree output/cap256-longitudinal_igphyml.tree output/cap256-longitudinal_igphyml.flipped.tree
xvfb-run sonar display_tree -t output/cap256-longitudinal_igphyml.flipped.tree -n /SONAR/sample_data/natives.csv -o output/plot/CAP256_SONAR-vignette_tree.png --sp 2 --sc 1500 -f 2
