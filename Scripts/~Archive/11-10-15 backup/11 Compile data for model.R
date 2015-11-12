require("geneorama")
geneorama::detach_nonstandard_packages()
require("geneorama")
require("data.table")

## Load custom functions
geneorama::sourceDir("CODE/functions/")


################
#Load the data
################
foodInspect <- readRDS("Data/food_inspections.Rds")
weather <- readRDS("Data/Weather data.Rds")
liquor <- readRDS("Data/liquor_license.Rds")

#Crime
burglary_heat <- readRDS("Data/burglary_heat.RDS") 
larceny_heat <- readRDS("Data/larceny_heat.RDS") 
vandalism_heat <- readRDS("Data/vandalism_heat.RDS") 
drug_heat <- readRDS("Data/drug_heat.RDS") 
crime_heat <- readRDS("Data/crime_heat.RDS") 

burglary_heat30 <- readRDS("Data/burglary_heat30.RDS") 
larceny_heat30 <- readRDS("Data/larceny_heat30.RDS") 
vandalism_heat30 <- readRDS("Data/vandalism_heat30.RDS") 
drug_heat30 <- readRDS("Data/drug_heat30.RDS") 
crime_heat30 <- readRDS("Data/crime_heat30.RDS") 

#311
noise_heat <- readRDS("Data/noise_heat.RDS")
dumping_heat <- readRDS("Data/dumping_heat.RDS")
waterpol_heat <- readRDS("Data/waterpol_heat.RDS")
airpol_heat <- readRDS("Data/airpol_heat.RDS")
rodent_heat <- readRDS("Data/rodent_heat.RDS")
trash_heat <- readRDS("Data/trash_heat.RDS")
d311_heat <- readRDS("Data/d311_heat.RDS")

noise_heat30 <- readRDS("Data/noise_heat30.RDS")
dumping_heat30 <- readRDS("Data/dumping_heat30.RDS")
waterpol_heat30 <- readRDS("Data/waterpol_heat30.RDS")
airpol_heat30 <- readRDS("Data/airpol_heat30.RDS")
rodent_heat30 <- readRDS("Data/rodent_heat30.RDS")
trash_heat30 <- readRDS("Data/trash_heat30.RDS")
d311_heat30 <- readRDS("Data/d311_heat30.RDS")

#Construction
construct_heat <- readRDS("Data/construct_heat.RDS")
demolish_heat <- readRDS("Data/demolish_heat.RDS")
disturbance_heat <- readRDS("Data/disturbance_heat.RDS")

construct_heat30 <- readRDS("Data/construct_heat30.RDS")
demolish_heat30 <- readRDS("Data/demolish_heat30.RDS")
disturbance_heat30 <- readRDS("Data/disturbance_heat30.RDS")

#Other violations
otherviol_heat <- readRDS("Data/otherviol_heat.RDS")


################
#Set appropriate keys for heat values
################
setkey(noise_heat, Inspection_ID)
setkey(dumping_heat, Inspection_ID)
setkey(waterpol_heat, Inspection_ID)
setkey(airpol_heat, Inspection_ID)
setkey(rodent_heat, Inspection_ID)
setkey(trash_heat, Inspection_ID)
setkey(d311_heat, Inspection_ID)
setkey(construct_heat, Inspection_ID)
setkey(demolish_heat, Inspection_ID)
setkey(disturbance_heat, Inspection_ID)
setkey(burglary_heat, Inspection_ID) 
setkey(larceny_heat, Inspection_ID) 
setkey(vandalism_heat, Inspection_ID) 
setkey(drug_heat, Inspection_ID) 
setkey(crime_heat, Inspection_ID) 
setkey(otherviol_heat, Inspection_ID) 

################
#Compile the data
################
#Merge on heat values
dat_model <- foodInspect[i=TRUE, j=list(Inspection_ID, id, Inspection_Date, fail_flag, past_fail, timeSinceLast, category_restaurant, category_takeout, category_market, category_school, firstRecord, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, CitySilverSpring, CityRockville, CityGaithesburg, CityBethesda, CityGermantown, CityOlney, CityWheaton)]

heats <- list(burglary_heat, larceny_heat, vandalism_heat, drug_heat, crime_heat, noise_heat, dumping_heat, waterpol_heat, airpol_heat, rodent_heat, trash_heat, d311_heat, construct_heat, demolish_heat, disturbance_heat, burglary_heat30, larceny_heat30, vandalism_heat30, drug_heat30, crime_heat30, noise_heat30, dumping_heat30, waterpol_heat30, airpol_heat30, rodent_heat30, trash_heat30, d311_heat30, construct_heat30, demolish_heat30, disturbance_heat30, otherviol_heat)
for (h in heats) {
	#merge data on
	dat_model <- merge(x=dat_model, 
					y=h,
					by="Inspection_ID",
					all.x = TRUE)
}

#Clean up missing values
dat_model[is.na(burglary_heat), burglary_heat := 0]
dat_model[is.na(larceny_heat), larceny_heat := 0]
dat_model[is.na(vandalism_heat), vandalism_heat := 0]
dat_model[is.na(drug_heat), drug_heat := 0]
dat_model[is.na(crime_heat), crime_heat := 0]

dat_model[is.na(noise_heat), noise_heat := 0]
dat_model[is.na(dumping_heat), dumping_heat := 0]
dat_model[is.na(waterpol_heat), waterpol_heat := 0]
dat_model[is.na(airpol_heat), airpol_heat := 0]
dat_model[is.na(rodent_heat), rodent_heat := 0]
dat_model[is.na(trash_heat), trash_heat := 0]
dat_model[is.na(d311_heat), d311_heat := 0]

dat_model[is.na(construct_heat), construct_heat := 0]
dat_model[is.na(demolish_heat), demolish_heat := 0]
dat_model[is.na(disturbance_heat), disturbance_heat := 0]

dat_model[is.na(burglary_heat30), burglary_heat30 := 0]
dat_model[is.na(larceny_heat30), larceny_heat30 := 0]
dat_model[is.na(vandalism_heat30), vandalism_heat30 := 0]
dat_model[is.na(drug_heat30), drug_heat30 := 0]
dat_model[is.na(crime_heat30), crime_heat30 := 0]

dat_model[is.na(noise_heat30), noise_heat30 := 0]
dat_model[is.na(dumping_heat30), dumping_heat30 := 0]
dat_model[is.na(waterpol_heat30), waterpol_heat30 := 0]
dat_model[is.na(airpol_heat30), airpol_heat30 := 0]
dat_model[is.na(rodent_heat30), rodent_heat30 := 0]
dat_model[is.na(trash_heat30), trash_heat30 := 0]
dat_model[is.na(d311_heat30), d311_heat30 := 0]

dat_model[is.na(construct_heat30), construct_heat30 := 0]
dat_model[is.na(demolish_heat30), demolish_heat30 := 0]
dat_model[is.na(disturbance_heat30), disturbance_heat30 := 0]

dat_model[is.na(otherviol_heat), otherviol_heat := 0]


#Merge on the weather
setnames(weather, "date", "Inspection_Date")
dat_model <- merge(x=dat_model, 
					y=weather,
					by="Inspection_Date",
					all.x = TRUE)

#Merge on the liquor licenses
dat_model <- merge(x=dat_model, 
					y=liquor,
					by="id",
					all.x = TRUE)

dat_model[is.na(liquor_license), liquor_license := 0]

#save compiled data
saveRDS(dat_model, "Data/Model data.RDS")


