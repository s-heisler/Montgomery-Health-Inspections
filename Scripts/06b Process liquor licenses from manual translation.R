require("geneorama")
geneorama::detach_nonstandard_packages()
require("data.table")

#Load in the processed translation table
trans <- read.csv("Raw Data/Liquor licenses/License to inspection dictionary cleaned.csv")

#Keep only the inspection ID and a flag
trans$liquor_license <- 1

#Clean up the table
trans<- data.table(trans)
trans <- trans[i=(Wrong.match!= "x") & (id != "NA"), j=list(id, liquor_license)]

#Get rid of duplicates on id
liquor  <- data.table(liquor)
setkey(liquor, id)
liquor <- unique(liquor)

#Save the data
saveRDS(trans, "Data/liquor_license.Rds")
