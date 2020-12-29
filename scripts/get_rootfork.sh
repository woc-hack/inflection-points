#!/bin/bash

# Usage: ./get_rootfork.sh project_name
# Print rootfork field of a project or the project name if it is root

out=$(mongoexport --quiet --host "da1.eecs.utk.edu" --db WoC --collection 'proj_metadata.S' --query "{projectID: "\""$1"\""}" -f 'rootFork' --type=csv --noHeaderLine)

# Use to test if project is rootfork or not (test existence of output in pipe series)
#echo "$out"

# Use to either print rootfork or original project name
if [[ -z $out ]]; then echo $1; else echo $out; fi
