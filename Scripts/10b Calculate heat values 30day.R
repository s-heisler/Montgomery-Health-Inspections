require("geneorama")
geneorama::detach_nonstandard_packages()
require("geneorama")
require("data.table")

## Load custom functions
geneorama::sourceDir("Scripts/functions/")


################
#Load the data
################

foodInspect <- readRDS("Data/food_inspections.Rds")
crime <- readRDS("Data/Crime.Rds")
d311 <- readRDS("Data/d311.Rds")
construction <- readRDS("Data/permits.Rds")



################
#Calculate heat values: crime
################
burglary_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_burglary_flag==1, j=list(Date, crime_burglary_flag, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)

larceny_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_larceny_flag==1, j=list(Date, crime_larceny_flag, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)

vandalism_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_vandalism_flag==1, j=list(Date, crime_vandalism_flag, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)


drug_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_drug_flag==1, j=list(Date, crime_drug_flag, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)


crime_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_any_flag==1, j=list(Date, crime_any_flag, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)


################
#Calculate heat values: 311
################
noise_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_noise_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)

dumping_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_dumping_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)


waterpol_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_water_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)    

airpol_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_pollution_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)    


rodent_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_rodent_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)    


trash_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_trash_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)


d311_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_any_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)


################
#Calculate heat values: 311
################
construct_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = construction[i=(Work_Type=="CONSTRUCT"|Work_Type=="BUILD FOUNDATION"), j=list(Date=permit_issue_date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)

demolish_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = construction[i=Work_Type=="DEMOLISH", j=list(Date=permit_issue_date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)

disturbance_heat30 <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = construction[i=TRUE, j=list(Date=permit_issue_date, Latitude, Longitude)],
                          window = 30, 
                          page_limit = 500)





burglary_heat30 <- setnames(burglary_heat30, "heat_values", "burglary_heat30") 
larceny_heat30 <- setnames(larceny_heat30, "heat_values", "larceny_heat30") 
vandalism_heat30 <- setnames(vandalism_heat30, "heat_values", "vandalism_heat30") 
drug_heat30 <- setnames(drug_heat30, "heat_values", "drug_heat30") 
crime_heat30 <- setnames(crime_heat30, "heat_values", "crime_heat30") 
noise_heat30 <- setnames(noise_heat30, "heat_values", "noise_heat30")
dumping_heat30 <- setnames(dumping_heat30, "heat_values", "dumping_heat30")
waterpol_heat30 <- setnames(waterpol_heat30, "heat_values", "waterpol_heat30")
airpol_heat30 <- setnames(airpol_heat30, "heat_values", "airpol_heat30")
rodent_heat30 <- setnames(rodent_heat30, "heat_values", "rodent_heat30")
trash_heat30 <- setnames(trash_heat30, "heat_values", "trash_heat30")
d311_heat30 <- setnames(d311_heat30, "heat_values", "d311_heat30")
construct_heat30 <- setnames(construct_heat30, "heat_values", "construct_heat30")
demolish_heat30 <- setnames(demolish_heat30, "heat_values", "demolish_heat30")
disturbance_heat30 <- setnames(disturbance_heat30, "heat_values", "disturbance_heat30")   

saveRDS(burglary_heat30, "Data/burglary_heat30.RDS") 
saveRDS(larceny_heat30, "Data/larceny_heat30.RDS") 
saveRDS(vandalism_heat30, "Data/vandalism_heat30.RDS") 
saveRDS(drug_heat30, "Data/drug_heat30.RDS") 
saveRDS(crime_heat30, "Data/crime_heat30.RDS") 
saveRDS(noise_heat30, "Data/noise_heat30.RDS")
saveRDS(dumping_heat30, "Data/dumping_heat30.RDS")
saveRDS(waterpol_heat30, "Data/waterpol_heat30.RDS")
saveRDS(airpol_heat30, "Data/airpol_heat30.RDS")
saveRDS(rodent_heat30, "Data/rodent_heat30.RDS")
saveRDS(trash_heat30, "Data/trash_heat30.RDS")
saveRDS(d311_heat30, "Data/d311_heat30.RDS")
saveRDS(construct_heat30, "Data/construct_heat30.RDS")
saveRDS(demolish_heat30, "Data/demolish_heat30.RDS")
saveRDS(disturbance_heat30, "Data/disturbance_heat30.RDS")

