require("data.table")

#Read in data
weather <- read.table("Raw data/Weather Gaithesburg.txt", header=TRUE, sep="\t")


#Convert data types
weather$temp <- as.numeric(as.character(weather$tmpf))
weather$humidity <- as.numeric(as.character(weather$relh))
weather$precip <- as.numeric(as.character(weather$p01i))

weather$date <- as.Date(weather$valid, "%Y-%m-%d %H:%M")

weather <- data.table(weather)

#Aggregate by day
weather_daily <- weather[,list(temp=mean(na.omit(temp)), humid=mean(na.omit(humidity)), precip=sum(na.omit(precip))),by=date]

#Calculate running 3-day aggregations
weather_daily[, temp3day_avg:=shift(rollapply(temp, 3, mean, na.rm=TRUE), -3)]
weather_daily[, humid3day_avg:=shift(rollapply(humid, 3, mean, na.rm=TRUE), -3)]
weather_daily[, precip3day_sum:=shift(rollapply(precip, 3, sum, na.rm=TRUE), -3)]

#Output
write.table(weather_daily, "Temp/Weather data.csv", quote = FALSE, sep = "|", row.names = FALSE)

saveRDS(weather_daily, "Data/Wather data.Rds")

