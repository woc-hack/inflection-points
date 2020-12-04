"""Print timestamps for all commits of a project provided on cmdline.

Usage: python project_times.py project_name

Output:
	"year-month, count" where count is the number of commits to the project
		in that month

Example:
	To get info on https://github.com/ssc-oscar/oscar.py
	$ python project_times.py ssc-oscar_oscar.py
"""

from oscar import Time_project_info
import datetime
import collections
import sys

if len(sys.argv) < 2:
	print(__doc__)
	sys.exit()

p = Time_project_info()
rows = p.project_timeline(['time'], sys.argv[1])

alldates = []
for row in rows:
	# print(row[0])
	d = datetime.datetime.fromtimestamp(float(row[0]))
	alldates.append('{0}-{1}'.format(d.year, d.month))

for key, val in sorted(collections.Counter(alldates).items()):
	# print(key, value)
	print('{:8} {}'.format(key + ',', val))
