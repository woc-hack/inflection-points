## Data Cleaning Process (R)

1. Converted unix timestamp to date in the LibreOffice Calc spreadsheet software with  `=(A1/86400)+DATE(1970,1,1)`, where `A1` is the cell with the unix timestamp.
2. Calculated interval (i.e. age in months) of two dates (_EarlistCommitDate_ and _LatestCommitDate_) in the spreadsheet using   `=DATEDIF(E1,G1,"m")`, where `E1` and `G1` are the cells with date values and `"m"` indicates the difference in months.
3. Then selected projects with: `Interval >= 48`. Output: **8438** projects
4. Some projects had _EarlistCommitDate_ set to 0, which is an invalid timestamp, so we removed such projects.

**Final set: 8311 projects**

This was later combined into an `awk` one liner, removing projects with a lifespan < 4 yrs and/or _EarlistCommitDate_ == 0 in one step. The script is [filter_projects-R.sh](../scripts/filter_projects-R.sh).

Note: _**Earlist**CommitDate_ is not a typo. It is the actual name of the field in Mongo.

