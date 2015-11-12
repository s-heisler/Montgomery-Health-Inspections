geneorama::loadinstall_libraries("data.table")
require("plyr")
require("data.table")

## Import shift function
shift <- geneorama::shift

#load in the data
foodInspect <- read.csv("Raw data/Food inspections/Food_Inspection 10/15-11/5.csv")

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

#Create a unique inspection id
foodInspect$Inspection_ID <- id(foodInspect[c("id", "Inspection_Date", "Inspection_Results")], drop = FALSE)

#Drop duplicate inspection records
foodInspect <- data.table(foodInspect)
setkey(foodInspect, Inspection_ID)
foodInspect <- unique(foodInspect)

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
                    tempfilename="Temp/_geocodes_foodid-test.RDS")

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


## Calcualte time since last inspection.
## If the time is NA, this means it's the first inspection; add an inicator 
## variable to indicate that it's the first inspection.
foodInspect[i = TRUE , 
          j = timeSinceLast := as.numeric(
              Inspection_Date - shift(Inspection_Date, -1, NA)), 
          by = id]
foodInspect[ , firstRecord := 0]
foodInspect[is.na(timeSinceLast), firstRecord := 1]
foodInspect[is.na(timeSinceLast), timeSinceLast := 730]
foodInspect[ , timeSinceLast := pmin(timeSinceLast, 730)]


#Create dummy vars for biggest categories
foodInspect[ , category_restaurant := ifelse(Category=="Restaurant",1, 0)]
foodInspect[ , category_school := ifelse(Category %like% "School",1, 0)]
foodInspect[ , category_market := ifelse(Category %like% "Market",1, 0)]
foodInspect[ , category_takeout := ifelse(Category =="Carry Out",1, 0)]

#Create dummy vars for month - not very elegant, but effective
foodInspect[ , Jan := ifelse(format(Inspection_Date, "%m") == "01", 1, 0)]
foodInspect[ , Feb := ifelse(format(Inspection_Date, "%m") == "02", 1, 0)]
foodInspect[ , Mar := ifelse(format(Inspection_Date, "%m") == "03", 1, 0)]
foodInspect[ , Apr := ifelse(format(Inspection_Date, "%m") == "04", 1, 0)]
foodInspect[ , May := ifelse(format(Inspection_Date, "%m") == "05", 1, 0)]
foodInspect[ , Jun := ifelse(format(Inspection_Date, "%m") == "06", 1, 0)]
foodInspect[ , Jul := ifelse(format(Inspection_Date, "%m") == "07", 1, 0)]
foodInspect[ , Aug := ifelse(format(Inspection_Date, "%m") == "08", 1, 0)]
foodInspect[ , Sep := ifelse(format(Inspection_Date, "%m") == "09", 1, 0)]
foodInspect[ , Oct := ifelse(format(Inspection_Date, "%m") == "10", 1, 0)]
foodInspect[ , Nov := ifelse(format(Inspection_Date, "%m") == "11", 1, 0)]

#Create dummy vars for the biggest towns
foodInspect[ , CitySilverSpring := ifelse(City == "SILVER SPRING", 1, 0)]
foodInspect[ , CityRockville := ifelse(City == "ROCKVILLE", 1, 0)]
foodInspect[ , CityGaithesburg := ifelse(City == "GAITHESBURG", 1, 0)]
foodInspect[ , CityBethesda := ifelse(City == "BETHESDA", 1, 0)]
foodInspect[ , CityGermantown := ifelse(City == "GERMANTOWN", 1, 0)]
foodInspect[ , CityOlney := ifelse(City == "OLNEY", 1, 0)]
foodInspect[ , CityWheaton := ifelse(City == "WHEATON", 1, 0)]


#Keep only the important variables
foodInspectShort <- foodInspect[, list(Inspection_ID, id, Name, addr, City, Zip, Category, Type, stdLat, stdLon, Inspection_Date, fail_flag, past_fail, timeSinceLast, category_restaurant, category_takeout, category_market, category_school, firstRecord, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, CitySilverSpring, CityRockville, CityGaithesburg, CityBethesda, CityGermantown, CityOlney, CityWheaton)]

#Standardize variable names
setnames(foodInspectShort, "stdLat", "Latitude")
setnames(foodInspectShort, "stdLon", "Longitude")

#Save
saveRDS(foodInspectShort , "Data/food_inspections 10-15 to 11-05.Rds")


