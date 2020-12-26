"""Print commits and authors per month for a project.

To be used in pipe series: 
	echo <project> | ~/lookup/getValues -f p2c | cut -d';' -f2 | \
	~/lookup/getValues c2ta 2>/dev/null | cut -d\; -f2-3 | \
	python prod_proj_series.py

Output (months from oldest to newest):
	YYYY-MM,nCommits,nAuthors,timestamp-of-beginning-of-month
	...
"""

import sys
from collections import defaultdict, Counter
import datetime

nauthors = defaultdict(set)  # key: month, val: author
ncommits = Counter()


for line in sys.stdin.readlines():
    time, auth = line.split(';')
    d = datetime.datetime.fromtimestamp(int(time)).strftime('%Y-%m')
    nauthors[d].add(auth)
    ncommits[d] += 1

print('YYYY-MM,nCommits,nAuthors,timestamp')
for key, val in sorted(nauthors.items()):
    print(f'{key},{ncommits[key]},{len(val)},{int(datetime.datetime.timestamp(datetime.datetime(int(key[:4]), int(key[5:]), 1, tzinfo=datetime.timezone.utc)))}')

# print('\nCommits:')
# for key, val in sorted(ncommits.items()):
#	print(f'{key},{val}')
