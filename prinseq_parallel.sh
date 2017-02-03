#!/bin/bash

echo -e "\nStarting Prinseq parallel: github.com/spabinger"
echo "Prinseq commands: ${@}"

## Get directory of script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## General variables
SPLIT_CMD="${SCRIPT_DIR}/split"
PRINSEQ_CMD="perl ${SCRIPT_DIR}/prinseq-lite.pl"


## TODO Parse arguments instead of assuming that they are at the end


NUM_THREADS="${@: -1}"
TYPE_OF_DATA="${@:(-2):1}"  ## SE or PE
OUTPUT_FILE="${@:(-3):1}"
INPUT_FILE_1="${@:(-4):1}"
if [ $TYPE_OF_DATA == "PE" ]
then
    INPUT_FILE_1="${@:(-5):1}"
    INPUT_FILE_2="${@:(-4):1}"
fi


echo "NUM_THREADS: ${NUM_THREADS}"
echo "TYPE_OF_DATA: ${TYPE_OF_DATA}"
echo "OUTPUT_FILE: ${OUTPUT_FILE}"
echo "INPUT_FILE_1: ${INPUT_FILE_1}"
echo "INPUT_FILE_2: ${INPUT_FILE_2}"
echo ""


## Get OUTPUT_DIR
OUTPUT_DIR=`dirname ${OUTPUT_FILE}`


## Get Basenames
BASENAME_INPUT_FILE_1=`basename ${INPUT_FILE_1}`
echo "BASENAME_INPUT_FILE_1: ${BASENAME_INPUT_FILE_1}"

if [ $TYPE_OF_DATA == "PE" ]
then
    BASENAME_INPUT_FILE_2=`basename ${INPUT_FILE_2}`
    echo "BASENAME_INPUT_FILE_2: ${BASENAME_INPUT_FILE_2}"
fi
echo ""


## Create split output dir - split subfolder with input name
SPLIT_OUTPUT_DIR_INPUT_1="${OUTPUT_DIR}/split_${BASENAME_INPUT_FILE_1%.fastq}/"
rm -r ${SPLIT_OUTPUT_DIR_INPUT_1}
mkdir -p ${SPLIT_OUTPUT_DIR_INPUT_1}

if [ $TYPE_OF_DATA == "PE" ]
then
    SPLIT_OUTPUT_DIR_INPUT_2="${OUTPUT_DIR}/split_${BASENAME_INPUT_FILE_2%.fastq}/"
    rm -r ${SPLIT_OUTPUT_DIR_INPUT_2}
    mkdir -p ${SPLIT_OUTPUT_DIR_INPUT_2}
fi
echo ""


## Calculate the number of threads (if PE both files need to have equal number of lines)
INPUT_LINES=`wc -l ${INPUT_FILE_1} | cut -f1 -d' '`
echo "Number of lines of the input file: ${INPUT_LINES}"


## First split the input file -> according to number of threads
## Take ceiling http://stackoverflow.com/questions/2394988/get-ceiling-integer-from-number-in-linux-bash
NUMBER_LINES_SPLIT_TMP=$(((INPUT_LINES + 3) / (4 * NUM_THREADS )))
NUMBER_LINES_SPLIT=$((NUMBER_LINES_SPLIT_TMP * 4))
echo "Will be split into files with # lines: ${NUMBER_LINES_SPLIT}"


## PREFIX for split output files
PREFIX_INPUT_1="${SPLIT_OUTPUT_DIR_INPUT_1}/${BASENAME_INPUT_FILE_1%.fastq}_prinseq_"
echo "Prefix INPUT1 split output: ${PREFIX_INPUT_1}"

if [ $TYPE_OF_DATA == "PE" ]
then
    PREFIX_INPUT_2="${SPLIT_OUTPUT_DIR_INPUT_2}/${BASENAME_INPUT_FILE_2%.fastq}_prinseq_"
    echo "Prefix INPUT2 split output: ${PREFIX_INPUT_2}"
fi
echo ""


##
## Run the split command - first input 1 (SE & PE)
##

## cd into the correct directory
echo "cd into dir: ${SPLIT_OUTPUT_DIR_INPUT_1}"
cd ${SPLIT_OUTPUT_DIR_INPUT_1}

echo "SPLIT CMD: ${SPLIT_CMD} -l ${NUMBER_LINES_SPLIT} --additional-suffix=\".fastq\" -d ${INPUT_FILE_1} ${PREFIX_INPUT_1}"
${SPLIT_CMD} -l ${NUMBER_LINES_SPLIT} --additional-suffix=".fastq" -d ${INPUT_FILE_1} ${PREFIX_INPUT_1}


if [ $TYPE_OF_DATA == "PE" ]
then
    ## cd into the correct directory
    echo "cd into dir: ${SPLIT_OUTPUT_DIR_INPUT_2}"
    cd ${SPLIT_OUTPUT_DIR_INPUT_2}


    echo "SPLIT CMD: ${SPLIT_CMD} -l ${NUMBER_LINES_SPLIT} --additional-suffix=\".fastq\" -d ${INPUT_FILE_2} ${PREFIX_INPUT_2}"
    ${SPLIT_CMD} -l ${NUMBER_LINES_SPLIT} --additional-suffix=".fastq" -d ${INPUT_FILE_2} ${PREFIX_INPUT_2}
fi
echo ""


## Remove last four or five (if PE) input arguments (threads, type, output file, input file 1, [input file 2]) from original command
if [ $TYPE_OF_DATA == "PE" ]
then
    CMD_PARAMETERS_TRIMMED="${@:1:$(($#-5))}"
else
    CMD_PARAMETERS_TRIMMED="${@:1:$(($#-4))}"
fi

echo "CMD_PARAMETERS_TRIMMED: ${CMD_PARAMETERS_TRIMMED}"



## CD again into INPUT_1 directory
echo "cd into input 1 directory: ${SPLIT_OUTPUT_DIR_INPUT_1}"
cd ${SPLIT_OUTPUT_DIR_INPUT_1}
echo -e "\n"

## Call prinseq on all split files
for f in *prinseq_*;
do
    echo -e "\n\nNew command"
    MY_CMD="${PRINSEQ_CMD} ${CMD_PARAMETERS_TRIMMED} -fastq ${SPLIT_OUTPUT_DIR_INPUT_1}/${f} -out_good ${SPLIT_OUTPUT_DIR_INPUT_1}/${f%.fastq}_output_xxxx_output"


    ## Get the second file and add to command
    if [ $TYPE_OF_DATA == "PE" ]
    then
	## Get suffix
	prefix1=$(echo $f | rev | cut -f1 -d_ | rev)
	## Find file in INPUT_2 split dir
	PRINSEQ_INPUT_FILE_2=$(ls $SPLIT_OUTPUT_DIR_INPUT_2*$prefix1)
	echo -e "PRINSEQ_INPUT_FILE_2: $PRINSEQ_INPUT_FILE_2\n"

	MY_CMD="${MY_CMD} -fastq2 ${PRINSEQ_INPUT_FILE_2}"
    fi

    echo "Starting prinseq"
    echo "CMD: ${MY_CMD}"
    ${MY_CMD} &
done

## Wait for all parallel processes to finish
wait


##
## Combine the trimmed files
##

## Remove old output files
rm -f ${OUTPUT_FILE}_1.fastq
if [ $TYPE_OF_DATA == "PE" ]
then
    rm -f ${OUTPUT_FILE}_2.fastq
fi


echo "Combining the trimmed files"
echo ""

if [ $TYPE_OF_DATA == "PE" ]
then
    for of_1 in *output_xxxx_output_1.fastq;
    do
	## Add to Fastq1
	cat "$of_1" >> ${OUTPUT_FILE}_1.fastq

	## Add to Fastq2
	##Get the second file
	echo "of_1: $of_1"
	prefix1=$(echo $of_1 | sed 's/_1.fastq//g')
	of_2=$(ls ${SPLIT_OUTPUT_DIR_INPUT_1}${prefix1}_2.fastq)
	echo "of_2: $of_2"
	
	cat "$of_2" >> ${OUTPUT_FILE}_2.fastq

    done
else
    for of in *output_xxxx_output.fastq; 
    do
	cat "$of" >> ${OUTPUT_FILE}.fastq
    done
fi



## TODO

## Remove the temp files
#rm -r ${SPLIT_OUTPUT_DIR}















