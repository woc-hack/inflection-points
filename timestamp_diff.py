"""Print time difference between two UNIX timestamps.

Usage: python timestamp_diff timestamp1 timestamp2

Output: <Difference in days>
"""

import datetime
import sys

if len(sys.argv) < 3:
    print(__doc__)
    sys.exit()

day1 = datetime.datetime.fromtimestamp(int(sys.argv[1]))
day2 = datetime.datetime.fromtimestamp(int(sys.argv[2]))
delta = day2-day1
print('Difference in days: ' + str(delta.days))
