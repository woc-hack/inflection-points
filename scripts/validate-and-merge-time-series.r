#!/usr/bin/Rscript
#
# Read single project CSV files and merge into a single CSV file
#
#-------------------------------------------------------------------------- 
suppressPackageStartupMessages( library(fs) )
suppressPackageStartupMessages( library(lubridate) )
suppressPackageStartupMessages( library(tidyverse) )

#-------------------------------------------------------------------------- 
# Paths
#-------------------------------------------------------------------------- 
in_path <- '../data/commits/S/authors-and-commits'
out_path <- '../data/commits/S/authors-and-commits-time-series.csv'
err_path <- '../data/commits/S/invalid-authors-and-commits-files.csv'

#-------------------------------------------------------------------------- 
# Read a single author and commit time series CSV file into a tibble
#-------------------------------------------------------------------------- 
read_commit_ts <- function(path) {
    proj_colnames <- c('year_month','ncommits','nauthors','timestamp')
    commits_ts <- read_csv(file=path, col_names=proj_colnames, col_types='ciid', skip=1)
    if (nrow(commits_ts) > 0) {
        commits_ts <- commits_ts %>%
            mutate(date=as_date(str_c(year_month, '-01')), timestamp=NULL) %>%
            complete(date=seq.Date(min(date), max(date), by="month"), fill=list(ncommits=0, nauthors=0)) %>%
            mutate(year_month=str_c(year(date),str_pad(month(date),2,"left","0"),sep='-'))
    }
    commits_ts
}

#-------------------------------------------------------------------------- 
# Merge valid per-project time series data into a single data frame. 
#
# Valid data requirements are:
#   1. Time series must span at least 48 months.
#   2. No months before January 1970
#   3. No months after December 2020
#
# Projects whose data fails to meet all 3 requirements are not included in
# the merged data frame.
#-------------------------------------------------------------------------- 
earliest_checkdate <- ymd('1969-12-01')
latest_checkdate <- ymd('2021-01-01')

merge_projects <- function(in_paths) {
    i <- 0
    projects <- NULL
    for (path in in_paths) {
        i <- i + 1
        if ((i %% 200) == 0) {
            cat(i, "..", sep="")
        }

        proj_name <- path_ext_remove(path_file(path))
        sample_df <- read_commit_ts(path) %>% add_column(project = proj_name)

        if (nrow(sample_df) >= 48) {
            sdate <- sample_df$date
            if (all(sdate > earliest_checkdate & sdate < latest_checkdate)) {
                projects <- bind_rows(projects, sample_df)
            } else { # record files with pre-1970 or post-2020 dates
                probfilename = str_c(proj_name, '.csv')
                if (!(all(sdate > earliest_checkdate))) {
                    problem_files <<- problem_files %>%
                        add_row( filename=probfilename, problem='pre-1970 dates' )
                }
                if (!(all(sdate < latest_checkdate))) {
                    problem_files <<- problem_files %>%
                        add_row( filename=probfilename, problem='post-2020 dates' )
                } 
            }
        } else { # record too short files for investigation
            probfilename = str_c(proj_name, '.csv')
            if (nrow(sample_df) == 0) {
                problem_files <<- problem_files %>%
                    add_row( filename=probfilename, problem='zero rows' )
            } else {
                problem_files <<- problem_files %>%
                    add_row( filename=probfilename, problem='less than 48 rows' )
            }

        }
    }
    projects
}

#-------------------------------------------------------------------------- 
# Main program
#-------------------------------------------------------------------------- 
per_project_files <- dir_ls(in_path, glob='*.csv')

# Identify zero size CSV files
problem_files <- tibble(filename = character(), problem = character())
zero_size_files <- per_project_files[file_info(per_project_files)$size == 0]
for (zeropath in zero_size_files) {
    zerofilename <- path_file(zeropath)
    problem_files <- problem_files %>%
        add_row( filename=zerofilename, problem='zero size' )
}

# Process non-zero size time series CSV files
nonzero_size_files <- per_project_files[file_info(per_project_files)$size != 0]
cat("Processing file number ")
all_projects <- merge_projects(nonzero_size_files)
write_csv(all_projects, out_path)
cat("done.\n")

# Save problem file filenames with problem types
write_csv(problem_files, err_path)
