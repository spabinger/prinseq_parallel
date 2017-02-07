Prinseq Parallel
================

This script handles parallel execution of [Prinseq](http://prinseq.sourceforge.net).<br/>
It currently supports Prinseq commands for FASTQ files.

Basic functionality
-------------------
* Split input FASTQ into multiple files based on a specified number of threads
* Process each split FASTQ individually
* Merge processed files


Usage
-----
./prinseq_parallel.sh <PRINSEQ COMMANDS> FASTQ_FILE (FASTQ_FILE R2) OUT_BASE_PATH TYPE NUM_THREADS
TYPE = [SE, PE]

Example:
./prinseq_parallel.sh -no_qual_header -min_qual_mean 20 -trim_left 5 -trim_right 5 -log /output/file.log /input/r1.fastq /input/r2.fastq /output/output/ PE 6

Todo
----
* Merge out_bad files
