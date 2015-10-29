require("data.table")

#load, in the data
crime <- read.csv("Raw data/Moco crime data.csv")

##fix variable names
crime<-setNames(crime, gsub("\\.","_",colnames(crime)))
crime<-setNames(crime, gsub("___","_",colnames(crime)))

#Adjust date formats
crime$Date <- as.Date(crime$Start_Date_Time, "%m/%d/%Y %I:%M:%S %p")
sum(is.na(crime$Date))

#Convert into data.table
crime <- data.table(crime)

#Limit to relevant data range
crime <- crime[Date >= as.IDate("2013-01-01")]

#Create flags for different crime types
crime[ , crime_burglary_flag := ifelse(Class_Description %like% 'BURG ',1, 0)]
crime[ , crime_larceny_flag := ifelse((Class_Description %like% 'LARCENY') | (Class_Description %like% 'ROB '),1, 0)]
crime[ , crime_vandalism_flag := ifelse(Class_Description %like% 'VANDALISM ',1, 0)]
crime[ , crime_drug_flag := ifelse(Class_Description %like% 'CDS ',1, 0)]
crime[ , crime_any_flag := ifelse((crime_burglary_flag==1) | (crime_larceny_flag==1) | (crime_vandalism_flag==1) | (crime_drug_flag==1) ,1, 0)]

#Keep only relevant crime types
crime <- crime[crime$crime_any_flag==1]

#Drop everything with missing lat/lon
print(cat('Fraction of rows missing coords:', sum(is.na(crime$Latitude))/NROW(crime)))
crime <- crime[!is.na(crime$Latitude)]

#Save data
write.table(crime, "Temp/Crime full processed data.csv", quote = FALSE, sep = "|", row.names = FALSE)
crime_short <- crime[ , list(Date, crime_burglary_flag, crime_larceny_flag, crime_vandalism_flag, crime_drug_flag, crime_any_flag, Latitude, Longitude)]

saveRDS(crime_short, 'Data/Crime.Rds')
