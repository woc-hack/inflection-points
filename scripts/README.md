# Scripts
All scripts used from data collection to producing a timeseries can be found here.

## Workflow
1. [mongoexport_to_csv.sh](mongoexport_to_csv.sh): Export projects from MongoDB with `NumAuthors > 50 && NumCommits > 5,000 `to _out.csv_. Relies on a file _mongo-R\_fieldsarg.txt_ that lists desired fields to export.
2. [data_to_timeseries.sh](data_to_timeseries.sh): Use _[timestamps_to_series.py](timestamps_to_series.py)_ to produce a timeseries file of commits per month in CSV format. Writes to _/data/play/inflection-points/new_timeseries_data/**Project-ID**.csv_ and must be run on da0.
3. [find-changepoints.r](find-changepoints.r): Use data output from _[data_to_timeseries.sh](data_to_timeseries.sh)_ to find changepoints. Input and Output directories are determined by command line arguments.

## Utility Scripts
- [get_mongo_fields.sh](get_mongo_fields.sh): Get fields of each document in __db.proj\_metadata.R__. This output can then be modified and directed to _mongo-R\_fieldsarg.txt_ for use with [mongoexport_to_csv.sh](mongoexport_to_csv.sh). Example: `./scripts/get_mongo_fields.sh | sed 1d > mongo-R_fieldsarg.txt`
- [GetDataFromMongo.py](GetDataFromMongo.py): Export projects from MongoDB with `NumAuthors > 50 && NumCommits > 5,000 `to _data\_R.csv_. This achieves the same output as [mongoexport_to_csv.sh](mongoexport_to_csv.sh).
- [timestamp_diff.py](timestamp_diff.py): Print days between 2 timestamps.
- [project_times.py](project_times.py): Get timestamps for each file was modified in a project. This script is kept as a reference for use of __[oscar.py](https://github.com/ssc-oscar/oscar.py)__'s Clickhouse utilities.
