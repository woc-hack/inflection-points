"""Get project name from mongoexport file.

Root projects have an empty 'rootFork' field, so we must use the 'projectID' field.

Use with proj_metadata.S export format: 
numStars,NumAuthors,NumBlobs,LatestCommitDate,projectID,EarlistCommitDate,rootFork,communitySize,NumCommits,NumFiles

Usage: python get_project_names.py < valid_projects_from_S.csv

Output:
	-- same format, but filtered --
"""

import sys

firstline = sys.stdin.readline()
print(firstline[:-1])

for line in sys.stdin.readlines():
    fields = line.split(',')

    if fields[6] != "":
        print(fields[6])

    else:
        print(fields[4])
