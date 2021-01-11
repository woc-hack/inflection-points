#!/bin/bash
# usage: filter_projects.sh mongoexport_file
# example: filter_projects-R.sh /da1_data/play/inflection-points/mongo-exports/mongo_proj_metadata_R_out.csv 

awk -F',' '($4 > 0 && $6 - $4 > 126144000) || NR==1' $1
