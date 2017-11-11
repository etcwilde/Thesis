#!/usr/bin/Rscript
# Jul 22, 2017
# Evan Wilde

library(RPostgreSQL)
library(ggplot2)

colorScheme <- c("#3366CC", "#DC3912", "#FF9900", "#109618", "#990099", "#3B3EAC")
colorSchemeTrans <- c("#3366CC99", "#DC391299", "#FF990099", "#10961899", "#99009999", "#3B3EAC99")
con <- dbConnect(drv=dbDriver('PostgreSQL'), dbname='postgres', user='postgres', host='localhost', port=32768)

# Create 1 plot
# - Number of commits per year

# === [ Commits Per year ] ===

query <- "
SELECT extract(year FROM comdate) AS year, count(*) FROM commits GROUP BY year ORDER BY year;
"

data <- dbGetQuery(con, query)
pdf("per_year.pdf", width=16, height=8)
data <- data[2:(nrow(data)- 1),]
data.freq = as.vector(rep(data$year, data$count))
barplot(table(data.freq),
        xlab="",
        ylab="Number of Commits",
        main="Number of Commits Merged Per Year",
        col=colorSchemeTrans[1],
        border=colorScheme[1]
        )

# === [ Commits Per Release] ===

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

CREATE TEMP TABLE root_merges AS
(SELECT ptm.cid,
        ptm.count,
        c.autdate
FROM (SELECT ptm.mcidlinus cid,
             count(ptm.cid)
      FROM pathtomerge ptm
      GROUP BY ptm.mcidlinus) ptm
LEFT JOIN commits c
ON c.cid=ptm.cid);

SELECT chunks.ver,
       count(*) merge_count,
       sum(chunks.count) commit_count,
       start_date,
       end_date
FROM (SELECT rm.cid,
       vr.ver,
       vr.start_date,
       vr.end_date,
       rm.count,
       rm.autdate
FROM root_merges rm,
     version_ranges vr
WHERE
     rm.autdate >= vr.start_date AND rm.autdate < vr.end_date) chunks
GROUP BY chunks.ver,
         chunks.start_date,
         chunks.end_date
ORDER BY start_date;
"

pdf("per_release.pdf", width=16, height=8)
data <- dbGetQuery(con, query)
barplot(data$commit_count,
        names.arg=data$ver,
        xlab="Version",
        ylab="Commits",
        main="Commits per Linux Release",
        col=colorSchemeTrans[1],
        border=colorScheme[1],
        cex.main=1.8,
        cex.lab=1.5)
barplot(data$merge_count,
        names.arg=data$ver,
        xlab="Version",
        ylab="Merges",
        main="Merges into the Master Branch of Linux",
        col=colorSchemeTrans[2],
        border=colorScheme[2],
        cex.main=1.8,
        cex.lab=1.5)
barplot(data$commit_count / data$merge_count,
        names.arg=data$ver,
        xlab="Version",
        ylab="Commits per Merge",
        main="Commits per Merge over each Linux Release",
        col=colorSchemeTrans[3],
        border=colorScheme[3],
        cex.main=1.8,
        cex.lab=1.5)

# === [ Commits Per Merge Per Release] ===

query <- "
SELECT rm.cid,
       vr.ver,
       vr.start_date,
       vr.end_date,
       rm.count,
       rm.autdate
FROM root_merges rm,
     version_ranges vr
WHERE rm.autdate >= vr.start_date AND rm.autdate < vr.end_date;
"

data <- dbGetQuery(con, query)
pdf("merge_distribution.pdf", width=12, height=8)

print(colorScheme[1])

p0 = ggplot(data, aes(reorder(ver, start_date), count)) + geom_boxplot(outlier.shape=NA, fill=colorSchemeTrans[1], color=colorScheme[1])

ylim1 = boxplot.stats(data$count)$stats[c(1,5)]
plot(p0 + coord_cartesian(ylim=ylim1*1.5) +
     xlab("Version") +
     ylab("Commits") +
     ggtitle("Distribution of Commits in each Merge") +
     theme(plot.title=element_text(size=22, hjust=0.5),
           axis.title=element_text(size=18),
           axis.text.x=element_text(angle=30,hjust=1),
           axis.text=element_text(size=15),
           panel.background=element_blank(),
           axis.line.y=element_line(colour="#000000")))

dbDisconnect(con)
