import sys
import datetime
from collections import Counter

# i = 1;
alldates = []
for line in sys.stdin.readlines():
    #print(f'line{i:02}: {line[:-1]}')
    #i = i + 1
    d = datetime.datetime.fromtimestamp(float(line))
    alldates.append(f'{d.year}-{d.month:02}')

for key, val in sorted(Counter(alldates).items()):
    print(
        f'{key:7},{val},{int(datetime.datetime.timestamp(datetime.datetime(int(key[:4]), int(key[5:]), 1, tzinfo=datetime.timezone.utc)))}')
