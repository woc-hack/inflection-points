# Inflection Points

Studying inflection points in open source software evolution.

Note: Name changed for MSR21 paper and any future works to __Changepoints__ to better reflect the goal of our research.

## Team Members

  * Noah Burgin (noah22)
  * Kuljit Chahal (kkc-al)
  * James Walden (jwalden)

## Research Questions
  * What are the types of inflection points in software evolution?
      * X% increase in commits/month
      * X% decrease in commits/month
      * X% increase in unique authors/month
      * X% decrease in unique authors/month
      * X% increase in users
      * X% decrease in users
      * X% increase in truck factor
      * X% decrease in truck factor
      * X% increase in popularity
      * X% decrease in popularity
      * X% increase in activity (in terms of pull requests/forks) 
      * X% decrease in activity (in terms of pull requests/forks)
     
  * What are the causes of inflection points in software evolution?
      * Migration to GitHub: check commit messages
      * New releases: check for release tags near inflection point
      * Security events: check news or CVE database for important dates
      * Bot adoption: check commit messages
      * Users adopt fork or competing project: check forks, compare to other projects 
      * core team reorganization (e.g. a project lead leaving the project/ newcomers bringing in fresh ideas)
      * change in team culture e.g. from hostile to more inclusive (may be through sentiment analysis) or vice-versa

## Data
  * Sample of projects from WoC R and S dataset that have
      * 50 authors
      * 5000 commits
      * Age 48 months or more
      * EarleistCommitDate(in unix timestamp) > 0
  * Time series on da0 in /data/play/inflection_points/timeseries-data/

## Tasks

  * [X] (James) Test changepoint detection libraries.
  * [X] (Kuljit) Obtain sample of projects.
  * [X] (Noah) Write script to get time series commit data.
  * [X] (Noah) Obtain commit time series data.
  * [X] (James) Write changepoint detection script for commits.
  * [X] (James) Compute changepoint data for commit time series.
  * [X] (James) Check-in changepoint script.
  * [X] (Noah) Check-in time series scripts and instructions to use.
  * [X] (Kuljit) Check-in project sample script and/or instructions.
  * [X] (Noah) Investigate why we could not obtain time series for all projects.
  * [X] (Noah) Obtain number of unique authors/month time series for sample.
  * [ ] (Kuljit, Noah) Obtain files changed/month time series for sample.
  * [ ] (James) Visualize changepoints for sample of projects.
  * [ ] (James) Tune changepoint detection.
  * [ ] (James) Run tuned changepoint detection on commits time series.
  * [ ] (James) Check-in changepoint data and visualizations.
  * [ ] (James) Compute changepoint data for unique authors time series.
  * [ ] (James) Compute changepoint data for changed files time series.
  * [X] (All) Prepare for hackathon final presentation on Dec 5.
  * [ ] (All) Write hackathon 2-page paper by Jan 19.

## MSR 2021 World of Code Hackathon Schedule

Checkpoints are scheduled at 10-11:30am EST.

  * *Checkpoint 1 (Sun, Nov 15):* Present tasks and research questions. Complete WoC tutorial before or after checkpoint.
  * *Checkpoint 2 (Weds, Nov 18):* Refine RQs. Have sample of projects. Determine how to create time series. Plan for next checkpoint.
  * *Checkpoint 3 (Fri, Nov 20):* Obtained project sample based on commits and authors using MongoDB. Investigating clickhouse for time series data. Research segmented regression for modeling time series.
  * *Checkpoint 4 (Wed, Nov 25):* Having problems getting time series data from clickhouse. Audris suggests we need to get commits and authors time series from maps using a shell script instead of using clickhouse, which only has data for files changed per month time series.
  * *Checkpoint 5 (Wed, Dec 2):* Obtained commits/month time series and analyzed with changepoint detection script.
  * *Final presentations (Sat, Dec 5):* 10am-1pm EST
  * *Hackathon track paper (Tue, Jan 19):* 2-page + bibliography paper due.
