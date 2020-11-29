library(tidyverse)
library(fs)
library(lubridate)
library(changepoint.np)

#-------------------------------------------------------------------------- 
# Paths
#-------------------------------------------------------------------------- 
inpath <- 'gitlab.com_bisralewitz_namd.csv'
outpath <- str_c(path_ext_remove(inpath), '-changepoints.csv')

#-------------------------------------------------------------------------- 
# Read monthly commit count time series from CSV, adding date column and any
# missing rows, where no commits had been made.
#-------------------------------------------------------------------------- 
colnames <- c('year_month','ncommits','timestamp')
commits_ts <- read_csv(file=inpath, skip=1, col_names=colnames, col_types='cii')
commits_ts <- commits_ts %>%
    mutate(date=as_date(str_c(year_month, '-01')), timestamp=NULL) %>%
    complete(date=seq.Date(min(date), max(date), by="month"), fill=list(ncommits=0)) %>%
    mutate(year_month=str_c(year(date),str_pad(month(date),2,"left","0"),sep='-'))

#-------------------------------------------------------------------------- 
# Find changepoints using nonparameteric PELT with at least 2 months/segment
#-------------------------------------------------------------------------- 
cnp <- cpt.np(commits_ts$ncommits, minseglen=2)
changepoints <- cpts(cnp)
nchangepoints <- length(changepoints)

#-------------------------------------------------------------------------- 
# Compute change in mean before and after each changepoint, storing
# in a tibble with one row per changepoint, identifying changepoints
# by row number and year-month in date format.
#-------------------------------------------------------------------------- 
changes <- tibble(
                  row = integer(), 
                  date = Date(), 
                  pre_mean = double(),
                  post_mean = double(),
                  diff_means = double()
                  )
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

#-------------------------------------------------------------------------- 
# Write the changes to disk. If there were no changepoints, the output
# file should have a header line but no other content.
#-------------------------------------------------------------------------- 
write_csv(changes, outpath)
