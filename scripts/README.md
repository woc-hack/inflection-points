# Scripts

Scripts for collecting and analyzing time series data from World of Code.

General naming scheme: 

- data_to_* produces data for changepoint analysis
- get_* produces intermediate data (data collection and cleaning)

## Workflow

We first take a sample of projects from the version R WoC dataset, then obtain a time series for each project before running an R script to identify change points in the time series.

  1. [mongoexport_to_csv.sh](mongoexport_to_csv.sh): Export projects from
     MongoDB with `NumAuthors > 50 && NumCommits > 5,000` to _out.csv_. Relies
     on a file _mongo-R\_fieldsarg.txt_ that lists desired fields to export.
    2. [data_to_timeseries.sh](data_to_timeseries.sh): Use _[timestamps_to_series.py](timestamps_to_series.py)_ to generate a time series of commits per month in CSV format for each project. Writes to _/data/play/inflection_points/new_timeseries_data/**Project-ID**.csv_ and should be run on __da0__.
     - This script was later improved to also include the number of unique authors per month using *[auth-comm_proj_report.py](auth-comm_proj_report.py)*
    3. [find-changepoints.r](find-changepoints.r): Use data output from _[data_to_timeseries.sh](data_to_timeseries.sh)_ to find changepoints.
     Input and Output directories are determined by command line arguments.

## Utility Scripts

  - [get_mongo_fields.sh](get_mongo_fields.sh): Get fields of each document in
    __db.proj\_metadata.R__. This output can then be modified and directed to _mongo-R\_fieldsarg.txt_ for use with [mongoexport_to_csv.sh](mongoexport_to_csv.sh).
    
    Example: `./scripts/get_mongo_fields.sh | sed 1d > mongo-R_fieldsarg.txt`
    
- [filter_projects-R.sh](filter_projects-R.sh): Remove projects with *EarlistCommitDate* == 0 and lifespan < 4 yrs from `mongoexport` data. This script expects fields in the order of **R**'s export but can easily by modified to work with S.

  - [GetDataFromMongo.py](GetDataFromMongo.py): Export projects from MongoDB
    with `{"NumAuthors": {"$gte": 50}, "NumCommits": {"$gte": 5000}}` to _data\_R.csv_. This
    achieves the same output as [mongoexport_to_csv.sh](mongoexport_to_csv.sh)
    
  - [timestamp_diff.py](timestamp_diff.py): Print days between 2 timestamps.

  - [project_times.py](project_times.py): Get timestamps for each file was modified in a project. This script is kept as a reference for use of __[oscar.py](https://github.com/ssc-oscar/oscar.py)__'s Clickhouse utilities.

While developing these scripts, WoC transitioned from version R to S. For this reason, many scripts are suffixed with 'R' or 'S' to indicate which version of data it is compatible with. Most scripts are backwards compatible, but two versions exist for the sake of clarity. Some extra scripts were required to adapt to the new fields provided in version S. Additionally, some scripts were only ran on version S if they were developed after the introduction of S.

## New in Version S

- [auth-comm_proj_report.py](auth-comm_proj_report.py): Print commits and authors per month for a project. An improved version of  [project_times.py](project_times.py) with the number of unique authors (nAuthors) data by month.
- [data_to_timeseries_P2c.sh](data_to_timeseries_P2c.sh): Same as [data_to_timeseries.sh](data_to_timeseries.sh) but calculated on `P2c` commits instead of `p2c` commits. From WoC Tutorial: "P2c returns ALL commits associated with this repo, including commits made to forks of this particular repo."

- [filter_projects-S.py](filter_projects-S.py): Filter out projects with a lifespan less than 4 years from `mongoexport` data. This script expects fields in the order of **S**'s export but can easily be modified to work with R.
- [get_project_names.py](get_project_names.py): Get project name from mongoexport file. Root projects have an empty *rootfork* field, so we must use the 'projectID' field.
- [data_to_filesch-da4.sh](data_to_filesch-da4.sh): Produce files changed per commit data using *[files_ch-single_project.py](files_ch-single_project.py)* which must be located in the [**oscar.py**](https://github.com/ssc-oscar/oscar.py) repo directory. This script assumes that path is *~/oscar.py/files_ch-single_project.py* and therefore can be run from any directory. Also, because *oscar.py* is only availble on da4, this script must only be run on **da4**.
- [data_to_filesch-da0.sh](data_to_filesch-da0.sh): Produces the same output as [data_to_filesch-da4.sh](data_to_filesch-da4.sh) by using `getValue` lookups instead of *oscar.py*. For best results, run only on **da0**.

Additional information can be found on each Python script in its docstring.