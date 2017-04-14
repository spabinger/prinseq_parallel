#!/bin/bash


TMP_CUR_DIR=`readlink -f test.sh`
BASE_DIR=`dirname $TMP_CUR_DIR`
FILE1="$BASE_DIR/demo/r1.fastq"
FILE2="$BASE_DIR/demo/r2.fastq"

mkdir -p demo_output

## Standard version
perl ./prinseq-lite.pl -no_qual_header -min_qual_mean 20 -trim_left 5 -trim_right 5 -log demo_output/file.log -fastq $FILE1 -fastq2 $FILE2 -out_good demo_output/standard

## Parallel version
./prinseq_parallel.sh -no_qual_header -min_qual_mean 20 -trim_left 5 -trim_right 5 -log $BASE_DIR/demo_output/prallel.log $FILE1 $FILE2 $BASE_DIR/demo_output/parallel_output PE 6

##Check MD5 sums
md5sum $BASE_DIR/demo_output/parallel_output_1.fastq
md5sum $BASE_DIR/demo_output/standard_1.fastq

md5sum $BASE_DIR/demo_output/parallel_output_2.fastq
md5sum $BASE_DIR/demo_output/standard_2.fastq

