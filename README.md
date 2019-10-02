SONAR - Software for Ontogenic aNalysis of Antibody Repertoires [![Build Status](https://travis-ci.com/scharch/SONAR.svg?branch=master)](https://travis-ci.com/scharch/SONAR)
=====

Introduction
-----

SONAR is the Antibodyomics2 pipeline developed collaboratively by the Structural Bioinformatics Section of the Vaccine Research Center, NIAID, NIH and the Shapiro lab at Columbia University. It is designed to process longitudinal NGS samples by extracting sequences related to a known antibody or antibodies of interest and reconstructing the ontogeny of the lineage. For more details, please see [below](#Using-SONAR). For examples of papers using SONAR, please see [here](#Papers).

If you use SONAR, please cite:

Schramm et al "SONAR: A High-Throughput Pipeline for Inferring Antibody Ontogenies from Longitudinal Sequencing of B Cell Transcripts." **Frontiers Immunol**, 2016. [PMCID: PMC5030719](https://www.frontiersin.org/articles/10.3389/fimmu.2016.00372/full)

For GSSPs, please cite:

Sheng et al "Gene-Specific Substitution Profiles Describe the Types and Frequencies of Amino Acid Changes during Antibody Somatic Hypermutation." **Frontiers Immunol**, 2017. [PMCID: PMC5424261](https://www.frontiersin.org/articles/10.3389/fimmu.2017.00537/full).

Installation
-----

**SONAR requires Python >=3.6**

### Docker
SONAR is available as an automatically updated Docker image. To use Docker:
```
$> docker pull scharch/sonar
$> docker run -it -e DISPLAY=$DISPLAY -v ~:/host/home scharch/sonar
$root@1abcde234> cd /host/home
$root@1abcde234> /SONAR/sample_data/runVignette.sh
<< *OR* >>
$root@1abcde234> cd /host/home/*path*/*to*/*data*/
$root@1abcde234> sonar 1.1
.
.
.
```

### Installing locally

#### General Prerequisites:
* Python3 with Biopython, airr, and docopt
* Perl5 with BioPerl, Statistics::Basic, List::Util, and Algorithm::Combinatorics
* R with docopt, ggplot2, MASS, grid, and ptinpoly

#### Optional Prerequisites:
* For using the master script: fuzzywuzzy python package
* For inferring ancestor sequences with IgPhyML: PDL::LinearAlgebra::Trans perl package
* For displaying trees: ete3, PyQT4, and PyQt4.QtOpenGL python packages
* For comparing GSSPs: pandas python package

For details on how to install the prerequisites, follow the recipe used in the [Dockerfile](Dockerfile).

Then clone the github repo and run the setup utility:
```
$> git clone https://github.com/scharch/SONAR.git
$> cd SONAR
$> ./setup.py
$> cp sonar ~/bin
```

If you wish, you may verify/test the installation by running
```
$> python3 tests/run_tests.py
```

Using SONAR
-----
To see a summary of all SONAR scripts and what they do, simply run `sonar -h`. Alternatively, take advantange of the fuzzy matching to find the scripts in a particular module, eg `sonar annotate`. All sonar scripts will print detailed options and usage when passed the `-h` flag. For a detailed summary, please see [the vignette](vignette.pdf).

Support
-----
I am more than happy to assist with basic SONAR usage. Please file all bugs reports and requests for help as GitHub [issues](https://github.com/scharch/SONAR/issues). I will typically respond within a day or two, though it may take me up to a month to push out bug fixes, depending on the criticallity and complexity of the bug, as well as other obligations.

Change Log
-----
### New in version 4.1
* Added `tests/run_tests.py` to verify installation and function. Implemented Travis CI.
* Added a full featured vignette in `sample_data`.
* Improvements in the `mGSSP` module, including a new script `5.5-score_sequences.py` to identify rare mutations.
* Added GSSPs from Sheng et al 2017 to `sample_data`.
* Improved how `1.0-preprocess.py` and `1.3-finalize_assignments.py` run on HPCs.

### New in version 4.0
* SONAR now does UMI detection and consensus generation, with `1.0-preprocess.py` replacing `1.0-MiSeq_assembly.pl`. It is specifically designed to be compatible with 2x300 sequencing of cDNA generated using the 10x Chromium platform, but should work with almost any experimental design. See help message for details. All QC functionality in the old script has been ported to the new one.
* SONAR is now single-cell aware. `1.1-blast_V.py` will look for a `cell_id` tag in the input sequences and maintain that information. A new script, `1.5-single_cell_statistics.py`, can be used to collate the output information in the rearragnements.tsv file generated by `1.3-finalize_assignments.py` and create a cell-level summary.
* To accomodate these new workflows, I have changed the mechanism for daisy-chaining Module 1 scripts together. Each script will now directly accept all options that can be passed to downstream scripts, as well as `--runX` flags. Please see help messages for more details.
* In `1.4-cluster_sequences.py`, the `-f` parameter for specifying a nonstandard input file has changed to `--file`. In addition, a new `--maxgaps` parameter is available.
* `1.3-finalize_assignments.py` has been split, with a new `parse_blast.py` doing most of the work that was originally in the main script. This allow parallel processing/cluster submission of large datasets in the same way as done for `1.1-blast_V.py` and `1.2-blast_J.py`.
* `unique` has been deprecated as a read `status` to avoid creating problems when testing multiple clustering conditions. Instead, look for `centroid`==`sequence_id` and/or a none-null `cluster_count` field.
* `1.3-finalize_assignments.py` now does fall-back isotype detection using the first 3 bases of CH1. This is useful for protocols using primers in the 5' region of CH1 such that isotype cannot be found by BLAST. It can be disabled with the `--noFallBack` flag.
* MacOS-compatible binaries have been added for all third-party programs. Please re-run setup.py to have SONAR autodetect which binary to use.
* I've finally fixed the SONAR/sonar bug, resolving the issue in favor of retaining the all-caps name. If you're like me and you've lazily cloned the repo into lower-case directory, you will need to rename it for things to continue to work.
* Fixed bugs in setup.py and the Dockerfile.

### New in version 3.0:
* SONAR now uses Python3. Python2 is not supported.
* All Python scripts now use DocOpt to manage argument parsing. This means that most single dash options are now double dash options.
* Output is now in [AIRR format](https://www.frontiersin.org/articles/10.3389/fimmu.2018.02206/full). A 'rearrangements.tsv' file has replaced the old 'all_seq_stats.txt' file and several field names have changed. I've tried to maintain backward compatibility in most cases, but there is also a new `convertToAIRR.py` utility to help pull data over, if necessary.
* I've finally removed the double SONAR folder, which was never meant to be there in the first place. If you've added the SONAR module directories to your PATH, you'll need to update those references.
* `1.1-blast_V.py` now includes an optional dereplication step, and will preserve replicate counts through the pipeline.
* `1.3-finalize_assignments.py` now distinguishes between `nonproductive` junctions and reads with other `indel`s.
* USearch has been replaced by VSearch, as the license of the latter allows me to include it in the SONAR distribution. In general, I've included most other programs that SONAR uses in the new `third_party/` folder, so that install is smoother and the user doesn't have to input paths to all sorts of things.
* In general, I've really tried to smooth out the install/setup process. Feedback welcome.
* I replaced the old master script `SONAR_master.pl` with a new one `sonar` that will is more flexible+portable and therefore hopefully more useful. It is generated by `setup.sh` so as to include a hardcoded path to the SONAR home directory, allowing it be copied/moved to a convenient location and keep the PATH much cleaner. It also allows partial and fuzzy matching for target script names.
* IgPhyML replaces DNAML as the phylogenetic engine of choice. It is included in the `third_party/` folder.
* `1.4_dereplicate sequences.pl` has been replaced by `1.4-cluster_sequences.py` and `2.1-calculate_id-div.pl` has been replaced by `2.1-calculate_id-div.py`.
* The mGSSP pipeline has been reworked a little bit to allow for multithreading. It also now accomodates masking primer positions and building GSSPs from nonproductive repertoires. See [the mGSSP readme](mGSSP/mGSSP_readme.md) for more details.
* I added another FASTA extraction utility, `getReadsByAnnotation.py` to get more flexible subsets of reads. For instance, all reads assigned to IGHV1-2*02.

### New in version 2.0:
* Added a new mGSSP module. See [our paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5424261/) and [the mGSSP readme](mGSSP/mGSSP_readme.md) for more details.

Papers
-----
* Doria-Rose et al "Developmental pathway for potent V1V2-directed HIV-neutralizing antibodies." **Nature**, 2014. [PMCID: PMC4395007](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4395007/)
* Wu et al "Maturation and Diversity of the VRC01-Antibody Lineage over 15 Years of Chronic HIV-1 Infection." **Cell** 2015. [PMCID: PMC4706178](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4706178/)
* Bhiman et al "Viral variants that initiate and drive maturation of V1V2-directed HIV-1 broadly neutralizing antibodies." **Nat Med**, 2015. [PMCID: PMC4637988](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4637988/)
* Doria-Rose et al "New Member of the V1V2-Directed CAP256-VRC26 Lineage That Shows Increased Breadth and Exceptional Potency." **J Virol**, 2016. [PMCID: PMC4702551](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4702551/)
* Sheng et al "Effects of Darwinian Selection and Mutability on Rate of Broadly Neutralizing Antibody Evolution during HIV-1 Infection." **PLoS Comput Biol**, 2016. [PMCID: PMC4871536](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4871536/)
* Huang et al "Identification of a CD4-Binding-Site Antibody to HIV that Evolved Near-Pan Neutralization Breadth." **Immunity**, 2016. [PMCID: PMC5770152](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5770152/) 
* Sheng et al "Gene-Specific Substitution Profiles Describe the Types and Frequencies of Amino Acid Changes during Antibody Somatic Hypermutation." **Frontiers Immunol**, 2017. [PMCID: PMC5424261](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5424261/)
* Krebs et al "Longitudinal Analysis Reveals Early Development of Three MPER-Directed Neutralizing Antibody Lineages from an HIV-1-Infected Individual." **Immunity**, 2019. [PMCID: PMC6555550](https://www.ncbi.nlm.nih.gov/pubmed/30876875)
