#!/bin/bash
#
# Retrieve number of commits time series for each project in the sample
# of projects obtained from MongoDB.
#
#-------------------------------------------------------------------------- 

# Run in batches of N
N=30

(
# projects missed in the first run
#cat missing_projects_timestamp-csvs | while read a

# all projects from R
#sort -n -t',' -k2 /data/play/inflection_points/data_R_8311.csv | sed '1,4d' | cut -d',' -f1 | while read a

# project names from S
cat /home/noah22/inflection-points/project_names_S.txt | while read a

# small set of projects for testing
#sort -nr -t',' -k2 /data/play/inflection_points/data_R_8311.csv | tail -8 | head -2 | cut -d',' -f1 | while read a

# re-compute empty files
#wc -l /data/play/inflection_points/auth-and-comm_data/* | awk '$1 == 0' | cut -d '/' -f6 | sed 's/\.csv$//' | while read a

do
	((i=i%N)); ((i++==0)) && wait
	b=$(echo "$a" | sed 's/\//_/g')
	echo $a | ~/lookup/getValues -f p2c | cut -d';' -f2 | ~/lookup/getValues c2ta 2>/dev/null | cut -d';' -f2-3 | \
	python3.9 /home/noah22/inflection-points/auth-comm_proj_report.py > /da0_data/play/inflection_points/auth-and-comm_data_S/$b.csv &
done
)

wait
