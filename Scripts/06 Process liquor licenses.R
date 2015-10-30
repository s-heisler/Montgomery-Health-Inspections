require("geneorama")
geneorama::detach_nonstandard_packages()
require("data.table")

#Read in data
license <- read.csv("Raw Data/Licensee_Information_Open_Data_PROD_10072015.csv")

#Pull in food inspections data
foodInspect <- readRDS("Data/food_inspections.Rds")

foodInspect <- data.table(foodInspect)
license <- data.table(license)

#Rename merge key fields to match
setnames(license, "CUSTOMER_NAME", "Name")
setnames(license, "BUSINESS_ZIP", "Zip")
setnames(license, "BUSINESS_STREET", "addr")

foodId <- foodInspect[, list(Name, addr, City, Zip, id)]
foodId <- unique(foodId)

license <- license[, list(Name, addr, BUSINESS_CITY, Zip, LICENSE_NUMBER, ACCOUNT_NUMBER)]

#Try to clean up addresses

#Uppercase everything
license$addr <- toupper(license$addr)
foodId$addr <- toupper(foodId$addr)

#Get rid of units
rm_unit_foodinsp <- function (x) gsub("([0-9])(\\s?-[A-Z]+)(.*)", "\\1\\3", x)
rm_unit_foodinsp2 <- function (x) gsub("#.*", "", x)
foodId$addr <- rm_unit_foodinsp(foodId$addr)
foodId$addr <- rm_unit_foodinsp2(foodId$addr)

rm_unit_lic <- function (x) gsub("(UNIT|SUITE|#|PO).*$", "", x)
license$addr <- rm_unit_lic(license$addr)


#Clean up strings
trans <- list("AVENUE" = ""
	," AVE" = ""
	," PARKWAY" = ""
	," PKWY" = ""	
	," ROAD" = ""
	," RD" = ""
	," BOULEVARD" = ""
	," BLVD" = ""
	," DRIVE" = ""
	," DR" = ""
	," PIKE" = ""
	," PK" = ""
	," STREET" = ""
	," ST" = ""
	," HIGHWAY" = ""
	," HWY" = ""
	," PLACE"  = ""
	," PLAZA" = ""
	," PL" = ""
	," LANE" = ""
	," LN" = ""
	,"EAST" = ""
	,"WEST"=""
	,"NORTH"=""
	,"SOUTH"=""
	," E " = " "
	," W "=" "
	," N "=" "
	," S "=" "	
	, "&"="AND"
	, "\\."=""
	, "-"=" "
	,","=""
	,"  " = " "
	,"^\\s+|\\s+$" = "")


for (name in names(trans)) {
	license$addr <- gsub(name, trans[name], license$addr)
	foodId$addr <- gsub(name, trans[name], foodId$addr)
}

merged <- merge(foodId, license, by=c("addr", "Zip"), all.y=TRUE)


write.table(merged, "Temp/matched licenses.csv", quote = TRUE, sep = "|", row.names = FALSE)

print("Done!")
