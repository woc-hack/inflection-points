"""Produce files changed per commit data

Must be located in the oscar.py repo and run on da4.

usage: python2.7 files_ch-single_project.py project_name
Example: python2.7 files_ch-single_project.py nuri1126_SWE

Output:
    files_changed
    ...
"""


from oscar import Project, Commit
import sys

for com in Project(sys.argv[1]).commit_shas:
    print(len(Commit(com).changed_file_names))
