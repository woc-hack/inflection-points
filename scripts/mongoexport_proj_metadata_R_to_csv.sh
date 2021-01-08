#!/bin/bash

# Export a MongoDB query to a csv file. The desired fields are in ~/inflection-points/mongo-R_fieldsarg.txt
mongoexport --host "da1.eecs.utk.edu" --db WoC --collection 'proj_metadata.R' --query '{NumAuthors: {$gt:50}, NumCommits: {$gt:5000}}' --type=csv --fieldFile ~/inflection-points/mongo-R_fieldsarg.txt --out out.csv
