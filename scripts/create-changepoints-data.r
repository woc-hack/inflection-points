#!/usr/bin/Rscript
#
# Create data file with all changepoint locations and sizes
#
#-------------------------------------------------------------------------- 
suppressPackageStartupMessages( library(changepoint.np) )
suppressPackageStartupMessages( library(lubridate) )
suppressPackageStartupMessages( library(tidyverse) )

#-------------------------------------------------------------------------- 
# Paths
#-------------------------------------------------------------------------- 
in_path <- '../data/commits/S/authors-and-commits-time-series.csv'
out_path <- '../data/changepoints/S/authors-and-commits-changepoints.csv'

#-------------------------------------------------------------------------- 
# Parameters
#-------------------------------------------------------------------------- 
minsegment <- 3                 # At least 3 months between changepoints

#-------------------------------------------------------------------------- 
# Read author and commit time series CSV file into a tibble
#-------------------------------------------------------------------------- 
compute_changesizes <- function(project_df, column_name) {
    changesizes <- tibble(
        project = character(), 
        date = Date(), 
        type = character(),
        pre_mean = double(),
        post_mean = double(),
        diff_means = double()
    )

    data <- select(project_df, all_of(column_name)) %>% pull()
    np_data <- cpt.np(data, method="PELT", minseglen=minsegment)
    np_changepoints <- cpts(np_data)
    nnp_changepoints <- ncpts(np_data)

    if (nnp_changepoints > 0) {
        for (i in 1:nnp_changepoints) {
            if (i == 1) {
                begin_row <- 1
            } else {
                begin_row <- np_changepoints[i-1]
            }
            if (i == nnp_changepoints) {
                end_row <- nrow(project_df)
            } else {
                end_row <- np_changepoints[i+1]
            }
            pre_change_mean <- project_df %>% 
                slice(begin_row:np_changepoints[i]) %>%
                select(all_of(column_name)) %>%
                pull() %>%
                mean()
            post_change_mean <- project_df %>% 
                slice(np_changepoints[i]:end_row) %>%
                select(all_of(column_name)) %>%
                pull() %>%
                mean()
            changesizes <- changesizes %>% add_row(
                project=project_names[i],
                date=project_df %>% slice(np_changepoints[i]) %>% select(date) %>% pull(),
                type=column_name,
                pre_mean=pre_change_mean,
                post_mean=post_change_mean,
                diff_means=post_change_mean - pre_change_mean
            )
        }
    }

    changesizes
}

#-------------------------------------------------------------------------- 
# Main program
#-------------------------------------------------------------------------- 
proj_colnames <- c('date','year_month','ncommits','nauthors','project')
projects <- read_csv(file=in_path, col_names=proj_colnames, col_types='Dciic', skip=1)
project_names <- projects %>% select(project) %>% unique() %>% pull()
project_list <- projects %>% group_by(project) %>% group_split()

changepoints_data <- tibble(
    project = character(), 
    date = Date(), 
    type = character(),
    pre_mean = double(),
    post_mean = double(),
    diff_means = double()
)

for(i in seq_along(project_list)) {
    project_df <- project_list[[i]]
    author_cpts <- compute_changesizes(project_df, 'nauthors')
    commit_cpts <- compute_changesizes(project_df, 'ncommits')
    changepoints_data <- bind_rows(changepoints_data, author_cpts, commit_cpts)
}
write_csv(changepoints_data, out_path)
