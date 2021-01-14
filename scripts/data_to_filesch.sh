#!/bin/bash
#
# Retrieve number of files changed time series for each project in the
# sample of projects obtained from MongoDB
#
#-------------------------------------------------------------------------- 

# Run in batches of N
N=30

(
# project names from S
cat /home/noah22/inflection-points/data/project_names_S.txt | while read a

do
    ((i=i%N)); ((i++==0)) && wait
    b=$(echo "$a" | sed 's/\//_/g')
    echo "Running $a. b = $b"
    python ~/oscar.py/filesch.py "$a" > /da4_data/play/inflection-points/filesch_data_S/"$b".txt &
done
)

wait
