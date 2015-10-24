geneorama::loadinstall_libraries("data.table")
require("plyr")
require("data.table")

## Import shift function
shift <- geneorama::shift

#load in the data
foodInspect <- read.csv("Raw data/Food_Inspection.csv")

##fix variable names
foodInspect<-setNames(foodInspect, gsub("\\.","_",colnames(foodInspect)))
foodInspect<-setNames(foodInspect, gsub("_+$","",colnames(foodInspect)))

#Convert dates to date
foodInspect$Inspection_Date <- as.Date(foodInspect$Inspection_Date, "%m/%d/%Y")

#Check that there are no missing dates
sum(is.na(foodInspect$Inspection_Date))

#Remove periods (most common cause of inconsistency) from address
foodInspect$addr <- gsub('[.]', '', foodInspect$Address_1)

#Remove other messy characters from names
foodInspect$Name <- gsub('-', ' ', foodInspect$Name)
foodInspect$Name <- gsub('\'', '', foodInspect$Name)
foodInspect$Name <- gsub('&', 'AND', foodInspect$Name)

#Create a unique restaurant id
foodInspect$id <- id(foodInspect[c("Name", "addr")], drop = FALSE)

#Fill in and standardize missing coordinates when available
foodInspect <- data.table(foodInspect)
setkey(foodInspect, id)
foodInspect$Latitude[is.na(foodInspect$Latitude)] <- 0
foodInspect$Longitude[is.na(foodInspect$Longitude)] <- 0
coords_agg <- foodInspect[,list(stdLat=max(Latitude), stdLon=min(Longitude)),by=id]
foodInspect <- join(foodInspect, coords_agg, by='id')

#Drop rows with missing coordinates
foodInspect <- foodInspect[foodInspect$stdLat!=0]

#Calculate whether the restaurant failed the inspection
foodInspect[ , fail_flag := ifelse(Inspection_Results %in% c("Critical Violations Corrected", "Facility Closed"),1, 0)]

#Sort table by id and date of inspection
foodInspect <- foodInspect[order(id, Inspection_Date)]

#Calculate failure on previous inspection
foodInspect[ , past_fail := shift(fail_flag, -1, 0), by = id]

#Calculate time since last inspection
foodInspect[, last_insp := c(0, Inspection_Date[-.N]) ,by=id]
foodInspect$days_since_insp = foodInspect$Inspection_Date-as.Date(foodInspect$last_insp, '1970-01-01')
foodInspect$days_since_insp[foodInspect$last_insp==0] <- NA


#Export table to csv for review
write.table(foodInspect, "Temp/Food inspect full processed data.csv", quote = FALSE, sep = "|", row.names = FALSE)

#Keep only the important variables
foodInspectShort <- foodInspect[, list(id, Name, addr, City, Zip, Category, Type, stdLat, stdLon, Inspection_Date, fail_flag, past_fail, days_since_insp)]

#Save
saveRDS(foodInspect , "Data/food_inspections.Rds")


