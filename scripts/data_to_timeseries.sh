#!/bin/bash

# Run in batches of N
N=30

(
cat missing_projects_timestamp-csvs | while read a
#sort -n -t',' -k2 /data/play/inflection_points/data_R_8311.csv | sed '1,4d' | cut -d',' -f1 | while read a
#sort -nr -t',' -k2 /data/play/inflection_points/data_R_8311.csv | tail -8 | head -2 | cut -d',' -f1 | while read a
do
	((i=i%N)); ((i++==0)) && wait
	echo $a | ~/lookup/getValues -f p2c | cut -d';' -f2 | ~/lookup/getValues -f c2ta | cut -d';' -f2 | awk 'NR % 2' | /home/noah22/python3.9/Python-3.9.0/python timestamps_to_series.py > /data/play/inflection_points/new_timeseries_data/$a.csv &
done
)

wait

#head -2 /data/play/inflection_points/data_R_8311.csv | sed 1d | cut -d',' -f1 | while read a
