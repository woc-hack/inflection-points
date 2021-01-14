"""Generate time series data for files changed per commit per month.

Must be located in the oscar.py repo and run on da4.

usage: python2.7 filesch.py project_name
Example: python2.7 filesch.py oliviaguest_gini

Output:
    YYYY-MM,nFilesChngd
    ...
"""

from oscar import Project, Commit
from collections import Counter
import sys

if len(sys.argv) < 2:
    print(__doc__)
    sys.exit()

comTimes = Counter()
for com in Project(sys.argv[1]).commit_shas:
    try:
        comTimes[str(Commit(com).committed_at)[:7]] += len(Commit(com).changed_file_names)
    except ValueError:
        pass

for key, val in sorted(comTimes.items()):
        print(key + ',' + str(val))
