# Data Overview

## Version S

- [project_names_S.txt](project_names_S.txt): Valid projects from S
  - Source:  `cat /da1_data/play/noah22/mongo-exports/mongo_proj_metadata_S_out.csv  | python3.9 scripts/filter_projects.py | python3.9 scripts/get_project_names.py`
  - Excludes projects with a lifespan < 4 yrs
- [P_names](P_names): Central repository for each project
  - Source: `cat project_names_S.txt | ~/lookup/getValues -f p2P`
  - Useful for `P2*` lookups in WoC, such as `P2c` **and** getting rootforks from MongoDB
- [rootforks.csv](rootforks.csv): GitHub "forked from ..." project names
  - Source: `cat data/P_names | cut -d';' -f2 | while read a; do ./scripts/get_rootfork_P.sh $a; done`
- [projects_S_with_50authors_5000commits.csv](projects_S_with_50authors_5000commits.csv): `mongoexport` output of projects with >50 authors and >5000 commits
  - Source: `./scripts/mongoexport_proj_metadata_S_to_csv.sh `
  - Lifespan > 4 yrs filtered by [scripts/filter_projects.py](../scripts/filter_projects.py) 

## Version R

With the absence of the *rootfork* field in version R, project names and lifespan can all be modified/extracted directly in [projects_R_with_50authors_5000commits.csv](projects_R_with_50authors_5000commits.csv). Only valid projects are left in this file. The file [projects_R_with_50authors_5000commits.csv](projects_R_with_50authors_5000commits.csv), however, contains the entire mongoexport.

