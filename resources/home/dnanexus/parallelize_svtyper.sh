#!/bin/bash

input=$1
directory=$2
output=$3
input_bam=$4

input_lines=$(grep -v \# $input | wc -l)
threads=$(nproc)
threads=$((threads * 8))
if [[ $input_lines -ge $threads ]]; then
    lines=$(expr $input_lines / $threads)
    split -d -a 5 -l $lines $input $directory
fi

i=0
for item in $directory*; do
    i=$(expr $i + 1)
    grep \# $input > $directory/$i
    grep -v \# $item >> $directory/$i
    echo "svtyper -B $input_bam -i $directory/$i >> $directory/$i" >> $output.cmds
done

threads=$(nproc)
threads=$((threads / 2))
parallel --verbose -j $threads -a $output.cmds eval 2> /dev/null

grep \# $input > $output
for item in $directory/*; do
    grep -v \# $item >> $output
done