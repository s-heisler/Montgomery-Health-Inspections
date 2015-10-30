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

#Create a unique inspection id
foodInspect$Inspection_ID <- id(foodInspect[c("Name", "Inspection_Date", "Inspection_Results")], drop = FALSE)

#Create a unique restaurant id
foodInspect$id <- id(foodInspect[c("Name", "addr")], drop = FALSE)

#Fill in and standardize missing coordinates when available
foodInspect <- data.table(foodInspect)
setkey(foodInspect, id)
foodInspect$Latitude[is.na(foodInspect$Latitude)] <- 0
foodInspect$Longitude[is.na(foodInspect$Longitude)] <- 0
coords_agg <- foodInspect[,list(stdLat=max(Latitude), stdLon=min(Longitude)),by=id]
foodInspect <- join(foodInspect, coords_agg, by='id')

################################
#Geocode missing coords
#Replace zeroes back with NAs
foodInspect$stdLat[foodInspect$stdLat==0] <- NA
foodInspect$stdLon[foodInspect$stdLon==0] <- NA

#Count missing geocodes
print(cat('Fraction of rows missing coords:', sum(is.na(foodInspect$stdLat))/nrow(foodInspect)))

#Read in and merge stuff that's been geocoded already
fillin_coords<- readRDS("Data/Extra geocodes.RDS")
for(id in 1:nrow(geocoded)){
  foodInspect$stdLat[foodInspect$adds %in% fillin_coords$address_original[id]] <- fillin_coords$Latitude[id]
  foodInspect$stdLon[foodInspect$addr %in% fillin_coords$address_original[id]] <- fillin_coords$Longitude[id]
}


#Create list of unique addresses still missing coords
foodInspect$fulladdr <- paste(foodInspect$addr, foodInspect$city, "MD", foodInspect$Zip)
select <- foodInspect[is.na(foodInspect$stdLat)][, list(fulladdr)]
setkey(select, fulladdr)
select <- unique(select)

#Geocode missing addresses
geocoded <- get_geocodes(input_table=select[
											i=TRUE,
											j=list(address_field=fulladdr)],
                    tempfilename="Temp/_geocodes_foodid.RDS")

#add the missing coordinates back into the raw data
for(id in 1:nrow(geocoded)){
  foodInspect$stdLat[foodInspect$fulladdr %in% geocoded$address_original[id]] <- geocoded$lat[id]
  foodInspect$stdLon[foodInspect$fulladdr %in% geocoded$address_original[id]] <- geocoded$lon[id]
}

#Count missing geocodes again
print(cat('Fraction of rows missing coords:', sum(is.na(foodInspect$stdLat))/nrow(foodInspect)))

#Re-save the full geocode compilation
fillin_coords_combined <- rbind.fill(fillin_coords, geocoded)
saveRDS(fillin_coords_combined, "Data/Extra geocodes.RDS")

##################################

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
foodInspectShort <- foodInspect[, list(Inspection_ID, id, Name, addr, City, Zip, Category, Type, stdLat, stdLon, Inspection_Date, fail_flag, past_fail, days_since_insp)]

#Standardize variable names
setnames(foodInspectShort, "stdLat", "Latitude")
setnames(foodInspectShort, "stdLon", "Longitude")

#Save
saveRDS(foodInspectShort , "Data/food_inspections.Rds")


