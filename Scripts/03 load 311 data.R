require("geneorama")
geneorama::detach_nonstandard_packages()
require("data.table")

#Read in data
d311 <- read.csv("Raw data/DEP Code Enforcement Sample Data.csv")
d311<-setNames(d311, gsub("\\.","_",colnames(d311)))
d311<-setNames(d311, gsub("___","_",colnames(d311)))

#Convert date
d311$date <- as.Date(d311$Created, "%m/%d/%y")
d311 <-data.table(d311)

#Count and keep non-missing coordinates only
print(cat('Fraction of rows missing coords:', sum(is.na(d311$GIS_LAT))/NROW(d311)))
d311 <- d311[!is.na(d311$GIS_LAT)]

#Rename coordinate columns
setnames(d311,"GIS_LAT","Latitude")
setnames(d311,"GIS_LONG","Longitude")

#Create flags
d311[ , d311_noise_flag := ifelse(Sub_Area=="Noise",1, 0)]
d311[ , d311_dumping_flag := ifelse(Sub_Area=="Illegal Dumping",1, 0)]
d311[ , d311_water_flag := ifelse(Sub_Area=="Water Quality",1, 0)]
d311[ , d311_pollution_flag := ifelse(Sub_Area %like% "Air -",1, 0)]

d311[ , d311_any_flag := ifelse(d311_noise_flag==1 | d311_dumping_flag==1 | d311_water_flag==1 | d311_pollution_flag==1,1, 0)]

#Trim data down
write.table(crime, "Temp/311 full processed data.csv", quote = FALSE, sep = "|", row.names = FALSE)

d311 <- d311[d311$d311_any_flag==1]
d311_short <- d311[, list(date, Latitude, Longitude, d311_noise_flag, d311_dumping_flag, d311_water_flag, d311_pollution_flag, d311_any_flag)]

#Write data out
saveRDS(d311_short, "Data/d311.Rds")