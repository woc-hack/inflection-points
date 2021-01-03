#!/bin/bash

# Usage: ./get_rootfork.sh project_name
# Print rootfork field of a project or the project name if it is root

if [ -z "$1" ]
then
	echo "usage: get_rootfork.sh project_name"
	exit
fi

# Get WoC root project and protect against ssh errors (try until success)
c=""
while [ -z "$c" ]
do
	#echo "Trying p2P for $1"
	c=$(echo $1 | ~/lookup/getValues -f p2P 2>/dev/null 2>/dev/null | cut -d';' -f2)
done

# Search mongo for rootfork
out=$(mongoexport --quiet --host "da1.eecs.utk.edu" --db WoC --collection \
'proj_metadata.S' --query "{projectID: "\""$c"\""}" -f 'rootFork' --type=csv \
--noHeaderLine)

# Print rootfork or provided project name if mongo returned nothing (means it's root)
printf "$1;"
if [[ -z $out ]]; then echo $1; else echo $out; fi
