#!/usr/bin/env python
#
# Retrieve projects that meet our criteria for having sufficient data
# (number of authors, number of commits) to analyze inflection points
# from World of Code Mongo database. We use the version R dataset.
#
#-------------------------------------------------------------------------- 

import pymongo
import bson
import csv

# connect to server and use collection proj_metadata.R from WoC database
client = pymongo.MongoClient("mongodb://da1.eecs.utk.edu/")
db = client ['WoC']
coll = db['proj_metadata.R']
print("Extracting..")

#select projects using the criteria: Authors >= 50, Numcommits >= 5000
data = coll.find( {"NumAuthors": {"$gte":50} ,"NumCommits": {"$gte":5000}})

documents = list(data)

print("number of projects",len(documents))
fields = ["projectID","numStars","NumCommits","NumAuthors","EarlistCommitDate","LatestCommitDate","numStars","FileInfo","_id"]
filename = "data_R.csv"

with open(filename,'w') as outfile:
	writer = csv.DictWriter(outfile, fieldnames = fields)
	writer.writeheader()
	writer.writerows(documents) 


print("closing")
data.close()
