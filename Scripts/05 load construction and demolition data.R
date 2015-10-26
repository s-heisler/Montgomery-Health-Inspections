require("geneorama")
geneorama::detach_nonstandard_packages()
require("data.table")
require("plyr")

#Read in data
combuild <- read.csv("Raw data/Commercial building permits.csv")
resbuild <- read.csv("Raw data/Residential building permits.csv")
demol <- read.csv("Raw data/Demolition Permits.csv")

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

# #Write out all missing coordinate addresses
# select <- permits[is.na(permits$Latitude)]
# select <- select[, list(Location)]
# setkey(select, Location)
# select <- unique(select)
# write.table(select, "Temp/Construction addresses missing coords.csv", quote = TRUE, sep = "|", row.names = FALSE)

#PLACEHOLDER: Probably figure out how to fill in coordinates here

#Drop missing coordinates
print(cat('Fraction of rows missing coords:', sum(is.na(permits$Latitude))/NROW(permits)))
permits <- permits[!is.na(permits$Latitude)]

#save data
permits_short <- permits[, list(permit_issue_date, permit_final_date, Work_Type, Latitude, Longitude)]

#Write data out
saveRDS(permits_short, "Data/permits.Rds")

