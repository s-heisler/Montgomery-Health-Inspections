require("geneorama")
geneorama::detach_nonstandard_packages()
require("geneorama")
geneorama::sourceDir("Scripts/functions/")
require("data.table")
require("plyr")

#Read in data
combuild <- read.csv("Raw data/Demolition and construction/Commercial building permits.csv")
resbuild <- read.csv("Raw data/Demolition and construction/Residential building permits.csv")
demol <- read.csv("Raw data/Demolition and construction/Demolition Permits.csv")

#Clean up datasets
combuild <- subset(combuild, Work.Type=="CONSTRUCT" | Work.Type=="BUILD FOUNDATION")
resbuild <- subset(resbuild, Work.Type=="CONSTRUCT" | Work.Type=="BUILD FOUNDATION")
setnames(demol,"Zip.code","ZIP.code")

#Append datasets
permits <- rbind.fill(combuild, resbuild, demol)

#Clean up column names
permits<-setNames(permits, gsub("\\.","_",colnames(permits)))

#Convert data types
permits$permit_issue_date <- as.Date(permits$Issue_Date, "%m/%d/%Y")
permits$permit_final_date <- as.Date(permits$Final_Date, "%m/%d/%Y")


#Convert to data table
permits <- data.table(permits)

#Trim down dates
permits <- permits[permit_issue_date >= as.IDate("2013-01-01")]

#Extract latitude and longitude
permits[, c("Loc1", "Loc2"):=tstrsplit(Location, "(", fixed=TRUE)]
permits[, c("Latitude", "Longitude"):=tstrsplit(Loc2, ", ", fixed=TRUE)]
permits[, Longitude:=substring(Longitude, 0, nchar(Longitude)-1)]
permits$Latitude <- as.numeric(permits$Latitude)
permits$Longitude <- as.numeric(permits$Longitude)

#Clean up the address field
drop_ns <- function (x) gsub("\n", " ", x)
permits$Location <- drop_ns(permits$Location)

####Geocode the missing addresses ####
#Count missing geocodes
print(cat('Fraction of rows missing coords:', sum(is.na(permits$Latitude))/nrow(permits)))

#Read in and merge stuff that's been geocoded already
fillin_coords<- readRDS("Data/Extra geocodes.RDS")
for(id in 1:nrow(geocoded)){
  permits$Latitude[permits$Location %in% fillin_coords$address_original[id]] <- fillin_coords$Latitude[id]
  permits$Longitude[permits$Location %in% fillin_coords$address_original[id]] <- fillin_coords$Longitude[id]
}

#Create list of unique addresses still missing coords
setkey(permits, Location)
select <- permits[is.na(permits$Latitude)][, list(Location)]
select <- unique(select)

#Geocode missing addresses
geocoded <- get_geocodes(input_table=select[
											i=TRUE,
											j=list(address_field=Location)],
                    tempfilename="Temp/_geocodes_construction.RDS")

#add the missing coordinates back into the raw data
for(id in 1:nrow(geocoded)){
  permits$Latitude[permits$Location %in% geocoded$address_original[id]] <- geocoded$lat[id]
  permits$Longitude[permits$Location %in% geocoded$address_original[id]] <- geocoded$lon[id]
}

#Re-save the full geocode compilation
fillin_coords_combined <- rbind.fill(fillin_coords, geocoded)
saveRDS(fillin_coords_combined, "Data/Extra geocodes.RDS")

#Drop still missing coordinates
print(cat('Fraction of rows missing coords:', sum(is.na(permits$Latitude))/NROW(permits)))
permits <- permits[!is.na(permits$Latitude)]

#save data
permits_short <- permits[, list(permit_issue_date, permit_final_date, Work_Type, Latitude, Longitude)]

#Write data out
saveRDS(permits_short, "Data/permits.Rds")

