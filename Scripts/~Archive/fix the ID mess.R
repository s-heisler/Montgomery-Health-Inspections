
####Get old data
foodInspectOld <- readRDS("Data/food_inspections.Rds")
foodInspectOld <- data.table(foodInspectOld)
foodInspectOld <- foodInspectOld[, list(id, Name, addr, Zip)]
foodInspectOld <- unique(foodInspectOld)


###Get new data
foodInspectNew <- read.socrata("https://data.montgomerycountymd.gov/Health-and-Human-Services/Food-Inspection/5pue-gfbe")
foodInspectNew<-setNames(foodInspectNew, gsub("\\.","_",colnames(foodInspectNew)))
foodInspectNew<-setNames(foodInspectNew, gsub("_+$","",colnames(foodInspectNew)))
foodInspectNew$addr <- gsub('[.]', '', foodInspectNew$Address_1)
foodInspectNew$Name <- gsub('-', ' ', foodInspectNew$Name)
foodInspectNew$Name <- gsub('\'', '', foodInspectNew$Name)
foodInspectNew$Name <- gsub('&', 'AND', foodInspectNew$Name)

foodInspectNew <- data.table(foodInspectNew)
foodInspectNew <- foodInspectNew[, list(Establishment_ID, Name, addr, Zip)]
foodInspectNew <- unique(foodInspectNew)


###Merge old and new
foodInspectIds <- merge(x=foodInspectNew, 
					y=foodInspectOld,
					by=list("Name", "addr", "Zip"),
					all.x = TRUE)

sum(is.na(foodInspectIds$id))
#Yay! old-to-new translation acquired!

#Merge new Id onto license translation

foodInspectIds <- foodInspectIds[, list(id, Establishment_ID)]
trans <- read.csv("Raw Data/Liquor licenses/License to inspection dictionary cleaned.csv")
trans2 <- merge(x=trans, 
					y=foodInspectIds,
					by="id",
					all.x = TRUE)
sum(is.na(trans2$Establishment_ID))

trans2$id <- NULL


setnames(trans2, "Establishment_ID", "id")

write.table(trans2, "Raw Data/Liquor licenses/License to inspection dictionary cleaned.csv", quote = FALSE, row.names = FALSE, sep="|")

