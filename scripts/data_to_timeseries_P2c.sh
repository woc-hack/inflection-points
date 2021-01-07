#!/bin/bash
# 
# Commits sourced: commits of all projects in the given project's cluster (P2c)
# Retrieve number of commits time series for each CLUSTER a project belongs to 
# in the sample of projects obtained from MongoDB.
#
#-------------------------------------------------------------------------- 

# Run in batches of N
#N=30
N=20

(
# Projects that were p, not P 
cat /home/noah22/inflection-points/data/missing_P2c_data_names | while read a

do
	((i=i%N)); ((i++==0)) && wait
    b=$(echo "$a" | sed 's/\//_/g')
	echo $a | ~/lookup/getValues -f P2c | cut -d';' -f2 | ~/lookup/getValues c2ta 2>/dev/null | cut -d';' -f2-3 | \
	python3.9 /home/noah22/inflection-points/scripts/auth-comm_proj_report.py > /da0_data/play/inflection_points/P2c_auth-and-comm_data_S/$b.csv &
done
)

wait
