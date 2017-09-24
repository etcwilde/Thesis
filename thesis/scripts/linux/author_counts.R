#!/usr/bin/Rscript
library(RPostgreSQL)

colorScheme <- c("#3366CC", "#DC3912", "#FF9900", "#109618", "#990099", "#3B3EAC")
colorSchemeTrans <- c("#3366CC99", "#DC391299", "#FF990099", "#10961899", "#99009999", "#3B3EAC99")
con <- dbConnect(drv=dbDriver('PostgreSQL'), dbname='postgres', user='postgres', host='localhost', port=32768)
query <- "
CREATE TEMP TABLE version_ranges AS
(SELECT r.ver,
        r.prevrealver,
        c_start.autdate start_date,
        c_end.autdate end_date
FROM releases r
JOIN commits c_end
ON r.vercid = c_end.cid
JOIN commits c_start
ON r.prevrealvercid = c_start.cid
WHERE r.candidate IS FALSE
ORDER BY end_date);

CREATE TEMP TABLE version_authors AS
(SELECT DISTINCT aim.author,
        vr.start_date,
        vr.ver
FROM version_ranges vr,
(SELECT ca.author,
        ca.mcidlinus,
        c.autdate
FROM
(SELECT c.author,
        p.mcidlinus
FROM pathtomerge p
LEFT JOIN commits c
ON p.cid = c.cid) ca
JOIN commits c
on ca.mcidlinus = c.cid) aim
WHERE aim.autdate >= vr.start_date AND aim.autdate < vr.end_date);

SELECT ver,
             start_date,
             count(author)
FROM version_authors
GROUP BY ver, start_date
ORDER BY start_date;
"

pdf("authors_per_release.pdf", width=12, height=8)
data <- dbGetQuery(con, query)
print("## Authors")
print(data)
barplot(data$count,
        names.arg=data$ver,
        xlab="Version",
        ylab="Authors",
        main="Number of authors per Linux release",
        col=colorSchemeTrans[4],
        border=colorScheme[4])

dbDisconnect(con)
