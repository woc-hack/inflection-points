#!/usr/bin/env Rscript
#
# Read monthly time series of commits from CSV file, identify change-
# points using non-parametric PELT algorithm, and write changepoints
# to CSV file. If file contained data but there were no changepoints, 
# the output file should have a header line but no other content. If
# the input file contained no data, an empty output fill will be created.
#
#-------------------------------------------------------------------------- 
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(fs))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(changepoint.np))

#-------------------------------------------------------------------------- 
# Read monthly commit count time series from CSV, adding date column and any
# missing rows, where no commits had been made.
#-------------------------------------------------------------------------- 
read_commit_ts <- function(path) {
    commits_ts <- read_csv(file=path, col_names=proj_colnames, col_types='ciii', skip=1)
    commits_ts <- commits_ts %>%
        mutate(date=as_date(str_c(year_month, '-01')), timestamp=NULL) %>%
        complete(date=seq.Date(min(date), max(date), by="month"), fill=list(ncommits=0, nauthors=0)) %>%
        mutate(year_month=str_c(year(date),str_pad(month(date),2,"left","0"),sep='-'))
    commits_ts
}

#-------------------------------------------------------------------------- 
# Find changepoints in ts via nonparameteric PELT with >=2 months/segment
#   Assumes time series is in data frame column named "ncommits"
#   Compute change in mean before and after each changepoint, storing
#   in a tibble with one row per changepoint, identifying changepoints
#   by row number and year-month in date format.
#-------------------------------------------------------------------------- 
find_changepoints <- function(commits_ts) {
    changes <- tibble(
                    row = integer(), 
                    date = Date(), 
                    pre_mean = double(),
                    post_mean = double(),
                    diff_means = double()
                    )

    if (nrow(commits_ts) > 1) {
        cnp <- cpt.np(commits_ts$ncommits, minseglen=2)
        changepoints <- cpts(cnp)
        nchangepoints <- length(changepoints)
    } else { # can't find change points with only one time period
        nchangepoints <- 0
    }

    if (nchangepoints > 0) {
        for (i in 1:nchangepoints) { 
            if (i == 1) {
                begin_row <- 1
            } else {
                begin_row <- changepoints[i-1]
            }
            if (i == nchangepoints) {
                end_row <- nrow(commits_ts)
            } else {
                end_row <- changepoints[i+1]
            }
            pre_change_mean <- commits_ts %>% 
                slice(begin_row:changepoints[i]) %>%
                summarize(mean(ncommits)) %>%
                pull()
            post_change_mean <- commits_ts %>% 
                slice(changepoints[i]:end_row) %>%
                summarize(mean(ncommits)) %>%
                pull()
            changes <- changes %>% add_row(row=changepoints[i],
            date=commits_ts %>% slice(changepoints[i]) %>% select(date) %>% pull(),
            pre_mean=pre_change_mean,
            post_mean=post_change_mean,
            diff_means=post_change_mean - pre_change_mean)
        }
    }
    changes
}

#-------------------------------------------------------------------------- 
# Parse command line args and get paths of input CSV time series files
#-------------------------------------------------------------------------- 
args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 1) {
    print("Usage: find-changepoints.r input_dir output_dir")
    quit("no")
}
indir <- args[1]
outdir <- args[2]
inpaths <- dir_ls(indir, glob='*.csv')

#-------------------------------------------------------------------------- 
# Find changepoints for each input and write to changepoints CSV file
#-------------------------------------------------------------------------- 
for (inpath in inpaths) {
    print(paste("Processing", inpath))
    outfn <- str_c(path_ext_remove(path_file(inpath)), '-changepoints.csv')
    outpath <- path(outdir, outfn)

    if (is_file_empty(inpath)) {
        print(paste("\t", inpath, "is an empty file."))
        file.create(outpath)
    } else {
        oss_ts <- read_commit_ts(inpath)
        oss_cps <- find_changepoints(oss_ts)
        write_csv(oss_cps, outpath)
    }
}
