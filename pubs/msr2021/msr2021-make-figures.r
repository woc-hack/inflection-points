#!/usr/bin/Rscript
#
# Make figures for MSR 2021 WoC hackathon paper
#
#-------------------------------------------------------------------------- 
library(changepoint.np)
library(fs)
library(lubridate)
library(tidyverse)

#-------------------------------------------------------------------------- 
# Paths
#-------------------------------------------------------------------------- 
indir <- '../../data/commits/S/authors-and-commits'
in_paths <- dir_ls(indir, glob='*.csv')
figure_path <- 'figures'
dir.create(figure_path, showWarnings = FALSE, recursive = TRUE, mode = "0755")

#-------------------------------------------------------------------------- 
# Read a single author and commit time series CSV file into a tibble
#-------------------------------------------------------------------------- 
read_commit_ts <- function(path) {
    proj_colnames <- c('year_month','ncommits','nauthors','timestamp')
    commits_ts <- read_csv(file=path, col_names=proj_colnames, col_types='ciid', skip=1)
    commits_ts <- commits_ts %>%
        mutate(date=as_date(str_c(year_month, '-01')), timestamp=NULL) %>%
        complete(date=seq.Date(min(date), max(date), by="month"), fill=list(ncommits=0, nauthors=0)) %>%
        mutate(year_month=str_c(year(date),str_pad(month(date),2,"left","0"),sep='-'))
    commits_ts
}

#-------------------------------------------------------------------------- 
# Load project data into projects tibble containing data for all projects
# and project_list list of single project tibbles
#-------------------------------------------------------------------------- 
projects <- NULL
for (path in in_paths) {
    proj_name <- path_ext_remove(path_file(path))
    sample_df <- read_commit_ts(path) %>% add_column(project = proj_name)

    if(nrow(sample_df) >= 48) {
        sdate <- sample_df$date
        if(all(sdate > as.Date('1969-12-01') & sdate < as.Date('2021-01-01'))) {
            projects <- bind_rows(projects, sample_df)
        }
    }
}

project_names <- projects %>% select(project) %>% unique() %>% pull()
project_list <- projects %>% group_by(project) %>% group_split()

#-------------------------------------------------------------------------- 
# Number of changepoints per project for authors and commits time series
#-------------------------------------------------------------------------- 
minsegment <- 3
changepoints <- tibble(name=character(), 
                       lifespan=integer(), 
                       ncommits=integer(), 
                       author_cpts=integer(),
                       commit_cpts=integer()
)

for(i in seq_along(project_list)) {
    project_name <- project_names[i]
    project_df <- project_list[[i]]
    authors <- select(project_df, 'nauthors') %>% pull()
    commits <- select(project_df, 'ncommits') %>% pull()
    np_authors <- cpt.np(authors, method="PELT", minseglen=minsegment)
    np_commits <- cpt.np(commits, method="PELT", minseglen=minsegment)
    changepoints <- changepoints %>% 
        add_row(name=project_name, 
                lifespan=length(commits),
                ncommits=as.integer(sum(commits)),
                author_cpts=ncpts(np_authors),
                commit_cpts=ncpts(np_commits)
        )
}

# Plot number of authors changepoint counts
apts <- changepoints %>% select(author_cpts) %>% count(author_cpts)
apts$author_cpts <- as.factor(apts$author_cpts)
aplot <- ggplot(apts, aes(x=n, y=author_cpts)) + geom_point(size=2) +
  scale_x_continuous(breaks=seq(0,2700,200)) +
  xlab("Number of Projects") + ylab("Number of Changepoints")
ggsave(filename="author-changepoints.pdf", path=figure_path, width=10, height=6)

# Plot number of commits changepoint counts
commit_cpts <- changepoints %>% select(commit_cpts) %>% count(commit_cpts)
commit_cpts$commit_cpts <- as.factor(commit_cpts$commit_cpts)
commit_cpts
cplot <- ggplot(commit_cpts, aes(x=n, y=commit_cpts)) + geom_point(size=2) +
  scale_x_continuous(breaks=seq(0,2600,200)) +
  xlab("Number of Projects") + ylab("Number of Changepoints")
ggsave(filename="commit-changepoints.pdf", path=figure_path, width=10, height=6)

#-------------------------------------------------------------------------- 
# Analyze sign and magnitude of changepoints
#-------------------------------------------------------------------------- 
compute_changesizes <- function(column_name) {
    minsegment <- 3
    changesizes <- tibble(
                    project = character(), 
                    date = Date(), 
                    pre_mean = double(),
                    post_mean = double(),
                    diff_means = double()
                    )

    for(i in seq_along(project_list)) {
    #for(i in seq_along(plist)) {
        project_df <- project_list[[i]]
        data <- select(project_df, all_of(column_name)) %>% pull()
        np_data <- cpt.np(data, method="PELT", minseglen=minsegment)
        np_changepoints <- cpts(np_data)
        nnp_changepoints <- ncpts(np_data)
        if(nnp_changepoints > 0) {
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
                    pre_mean=pre_change_mean,
                    post_mean=post_change_mean,
                    diff_means=post_change_mean - pre_change_mean
                )
            }
        }
    }

    changesizes
}

commit_changesizes <- compute_changesizes('ncommits')
ggplot(commit_changesizes, aes(x=diff_means)) + geom_density() + 
  xlab("Change in means at changepoint") + ylab("Density")
ggsave(filename="commit-changesizes.pdf", path=figure_path, width=10, height=6)

author_changesizes <- compute_changesizes('nauthors')
ggplot(author_changesizes, aes(x=diff_means)) + geom_density() + 
  xlab("Change in means at changepoint") + ylab("Density")
ggsave(filename="author-changesizes.pdf", path=figure_path, width=10, height=6)
