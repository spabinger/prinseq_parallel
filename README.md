Prinseq Parallel
================

This script handles parallel execution of Prinseq.
It supports all prinseq commands for FASTQ files.

Basic functionality
-------------------
* Split input FASTQ in multiple files based on specified number of threads
* Process each split FASTQ individually
* Merge processed files


Usage
-----
./prinseq_parallel.sh <PRINSEQ COMMANDS> FASTQ_FILE (FASTQ_FILE R2) OUT_BASE_PATH TYPE NUM_THREADS

TYPE = [SE, PE]


