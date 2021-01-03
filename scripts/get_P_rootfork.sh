#!/bin/bash

# Usage: ./get_rootfork.sh P_project_name
# Print rootfork field of a project or the project name if it is root
# Provided project name must be WoC's P from p2P

if [ -z "$1" ]
then
	echo "usage: get_rootfork.sh P_project_name"
	exit
fi

# Search mongo for rootfork
out=$(mongoexport --quiet --host "da1.eecs.utk.edu" --db WoC --collection \
'proj_metadata.S' --query "{projectID: "\""$c"\""}" -f 'rootFork' --type=csv \
--noHeaderLine)

# Print rootfork or provided project name if mongo returned nothing (means it's root)
printf "$1;"
if [[ -z $out ]]; then echo $1; else echo $out; fi
