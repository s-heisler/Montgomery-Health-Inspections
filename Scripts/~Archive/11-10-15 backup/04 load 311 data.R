require("geneorama")
geneorama::detach_nonstandard_packages()
require("data.table")
require("plyr")


#Read in data
pollution <- read.csv("Raw data/311 data/DEP Environmental Code SRs from 2013 Onward1.csv")
mice <- read.csv("Raw data/311 data/DHCA Rodents Bedbugs Mice SRs from 2013 Onward2.csv")
mice2 <- read.csv("Raw data/311 data/Rodent Complaints.csv")
trash <- read.csv("Raw data/311 data/DHCA Trash Complaint SRs from 2013 Onward3.csv")

mice$Sub.Area <- "Mice"
mice2$Sub.Area <- "Mice"
trash$Sub.Area <- "Trash"

d311 <- rbind.fill(pollution, mice, mice2, trash)

d311<-setNames(d311, gsub("\\.","_",colnames(d311)))
d311<-setNames(d311, gsub("___","_",colnames(d311)))

#Convert date
d311$Date <- as.Date(d311$Created, "%m/%d/%y")
d311 <-data.table(d311)

#Rename coordinate columns
setnames(d311,"GIS_LAT","Latitude")
setnames(d311,"GIS_LONG","Longitude")

print(cat('Fraction of rows missing coords:', sum(is.na(d311$Latitude))/nrow(d311)))

#Standardize coords that got lost in un-merging cells
#Create list of unique addresses not missing coords
unique_addr <- d311[i=!is.na(Latitude), j=list(Request, Latitude, Longitude), keyby=Request]
unique_addr <- unique(unique_addr)

#add the missing coordinates back into the raw data
for(id in 1:nrow(unique_addr)){
  d311$Latitude[d311$Request %in% unique_addr$Request[id]] <- unique_addr$Latitude[id]
  d311$Longitude[d311$Request %in% unique_addr$Request[id]] <- unique_addr$Longitude[id]
}

print(cat('Fraction of rows missing coords after fill-in:', sum(is.na(d311$Latitude))/nrow(d311)))

#Create flags
d311[ , d311_noise_flag := ifelse(Sub_Area=="Noise",1, 0)]
d311[ , d311_dumping_flag := ifelse(Sub_Area=="Illegal Dumping",1, 0)]
d311[ , d311_water_flag := ifelse(Sub_Area=="Water Quality",1, 0)]
d311[ , d311_pollution_flag := ifelse(Sub_Area %like% "Air -",1, 0)]
d311[ , d311_rodent_flag := ifelse(Sub_Area=="Mice",1, 0)]
d311[ , d311_trash_flag := ifelse(Sub_Area=="Trash",1, 0)]

d311[ , d311_any_flag := ifelse(d311_noise_flag==1 | d311_dumping_flag==1 | d311_water_flag==1 | d311_pollution_flag==1 | d311_rodent_flag==1 | d311_trash_flag==1,1, 0)]

#Filter out non-complaints
d311 <- subset(d311, SolutionName != "Live Near a Stream and Want to Protect/Help the Stream")
d311 <- subset(d311, SolutionName != "Asbestos")

#Trim data down
write.table(d311, "Temp/311 full processed data.csv", quote = FALSE, sep = "|", row.names = FALSE)

d311 <- d311[d311$d311_any_flag==1]
d311_short <- d311[, list(Date, Latitude, Longitude, d311_noise_flag, d311_dumping_flag, d311_water_flag, d311_pollution_flag, d311_rodent_flag, d311_trash_flag, d311_any_flag)]

#Write data out
saveRDS(d311_short, "Data/d311.Rds")