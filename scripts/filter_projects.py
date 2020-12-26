"""Filter out projects with a lifespan less than 4 years or earliest commit 
at timestamp 0 from a mongoexport file. 

Use with proj_metadata.S export format: 
numStars,NumAuthors,NumBlobs,LatestCommitDate,projectID,EarlistCommitDate,rootFork,communitySize,NumCommits,NumFiles

Usage: python filter_projects.py < /da1_data/play/noah22/mongo-exports/mongo_proj_metadata_S_out.csv

Output:
	-- same format, but filtered --
"""

import sys

firstline = sys.stdin.readline()
print(firstline[:-1])

for line in sys.stdin.readlines():
	fields = line.split(',')

	# all projects pass these two tests
	#if fields[6] == "" and fields[4] == "":
	#	print(f'No project name: {line[:-1]}', file=sys.stderr)
	#
	#if int(fields[5]) == 0:
	#	print(f'Starting time at 0: {line[:-1]}', file=sys.stderr)
	
	if int(fields[3]) - int(fields[5]) > 126144000:
		#print(f'Lifespan <4yrs: {line[:-1]}', file=sys.stderr)
		print(line[:-1])


	

