#!/bin/bash

# Get a list of fields from a mongo collection to be used with mongoexport to a csv file (requires fields to be listed)
mongo --host da1 WoC --quiet --eval 'db.proj_metadata.S.findOne()' | sed 's/^[[:space:]]\"\([^\"]*\)\".*$/\1/;t;d' | sed '1d' 

>&2 echo 'Note: FileInfo contains JSON formatted data and does not work well with CSV formats.'
