#!/bin/bash

for n_threads in 1 2 3 4 5 6 7 8 9 10
do
    for n_lines in $(seq 4 4 80)
    do
	./script.sh $n_lines $n_threads
    done
done


