# Data Overview

Data output from scripts and details on da server data.

## Data for Changepoint Analysis

WoC timeseries data is kept on the da servers due to its size. They can be found with `ls /da?_data/play/inflection[-_]points` (spread across several da servers). Regardless of server location, data is grouped by directory name as defined below:

-  **auth-and-comm_data_[RS]**: Timeseries data for number of commits per month (nCommits) and number of unique authors per month (nAuthors)
  - Source: [data_to_timeseries.sh](../scripts/data_to_timeseries.sh) 
- **P2c_auth-and-comm_data_S**: Same as *auth-and-comm_data_[RS]*, but commits are retrieved using `P2c` rather than `p2c`. This single character change yields a drastically different output. Instead of retrieving the commits associated with a single project (`p2c`), `P2c` retrieves ALL commits associated with the project's cluster (clusters determined by WoC algorithms). 
  - Source: [data_to_timeseries_P2c.sh](../scripts/data_to_timeseries_P2c.sh)
- **filesch_data_S**: Files changed per commit data. Each numerical value in these files represents the number of files changed by each commit, listed in chronological order.
  - Source: data_to_filesch* – Both `getValues` and **oscar.py** were utilized in this data collection process. See the [scripts README](../scripts/README.md) for details on each script.
- **mongo-exports**: Untouched output of `mongoexport` queries (Includes projects with lifespan < 4 yrs).

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
  - This data was then filtered to exclude projects with a lifespan < 4 yrs with [scripts/filter_projects.py](../scripts/filter_projects.py) 

## Version R

With the absence of the *rootfork* field in version R, project names can be extracted directly from [projects\_**R**\_with_50authors_5000commits.csv](projects_R_with_50authors_5000commits.csv). The file [projects\_**S**\_with_50authors_5000commits.csv](projects_S_with_50authors_5000commits.csv), however, contains empty _rootfork_ fields for root projects. This required extra scripts to extract the true project name. In summary:

- [projects\_**R**\_with_50authors_5000commits.csv](projects_R_with_50authors_5000commits.csv): `mongoexport` output **excluding** invalid projects
  - Source: `./scripts/filter_projects-R.sh /da1_data/play/inflection-points/mongo-exports/mongo_proj_metadata_R_out.csv`
  - See [projects_R_data_cleaning.txt](projects_R_data_cleaning.txt) for more info