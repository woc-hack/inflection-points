#!/bin/bash
# usage: filter_projects.sh mongoexport_file
#
# Use with proj_metadata.R export format:
# numStars,NumAuthors,projectID,EarlistCommitDate,NumCommits,LatestCommitDate
#
# example: filter_projects-R.sh /da1_data/play/inflection-points/mongo-exports/mongo_proj_metadata_R_out.csv 

if [ -z "$1" ]
then
	echo "usage: filter_projects.sh mongoexport_file"
	exit
fi

awk -F',' '($4 > 0 && $6 - $4 > 126144000) || NR==1' "$1"
