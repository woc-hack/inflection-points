#!/bin/bash

# Get a list of fields from a mongo collection to be used with mongoexport to a csv file (requires fields to be listed)
mongo --host da1 WoC --quiet --eval 'db.proj_metadata.R.findOne()' | sed 's/^[[:space:]]\"\([^\"]*\)\".*$/\1/;t;d' | sed '1d' 
