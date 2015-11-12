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
crime <- readRDS("Data/Crime.Rds")
d311 <- readRDS("Data/d311.Rds")
construction <- readRDS("Data/permits.Rds")



################
#Calculate heat values: crime
################
burglary_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_burglary_flag==1, j=list(Date, crime_burglary_flag, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)

larceny_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_larceny_flag==1, j=list(Date, crime_larceny_flag, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)

vandalism_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_vandalism_flag==1, j=list(Date, crime_vandalism_flag, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)


drug_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_drug_flag==1, j=list(Date, crime_drug_flag, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)


crime_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime[i=crime_any_flag==1, j=list(Date, crime_any_flag, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)


################
#Calculate heat values: 311
################
noise_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_noise_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)

dumping_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_dumping_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)


waterpol_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_water_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)    

airpol_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_pollution_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)    


rodent_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_rodent_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)    


trash_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_trash_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)


d311_heat   <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = d311[i=d311_any_flag==1, j=list(Date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)


################
#Calculate heat values: 311
################
construct_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = construction[i=(Work_Type=="CONSTRUCT"|Work_Type=="BUILD FOUNDATION"), j=list(Date=permit_issue_date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)

demolish_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = construction[i=Work_Type=="DEMOLISH", j=list(Date=permit_issue_date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)

disturbance_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = construction[i=TRUE, j=list(Date=permit_issue_date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500)


################
#Calculate heat values: previous violations in the area
################
otherviol_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = foodInspect[i=(fail_flag==1), j=list(Date=Inspection_Date, Latitude, Longitude)],
                          window = 90, 
                          page_limit = 500,
                          offset = 3)



burglary_heat <- setnames(burglary_heat, "heat_values", "burglary_heat") 
larceny_heat <- setnames(larceny_heat, "heat_values", "larceny_heat") 
vandalism_heat <- setnames(vandalism_heat, "heat_values", "vandalism_heat") 
drug_heat <- setnames(drug_heat, "heat_values", "drug_heat") 
crime_heat <- setnames(crime_heat, "heat_values", "crime_heat") 
noise_heat <- setnames(noise_heat, "heat_values", "noise_heat")
dumping_heat <- setnames(dumping_heat, "heat_values", "dumping_heat")
waterpol_heat <- setnames(waterpol_heat, "heat_values", "waterpol_heat")
airpol_heat <- setnames(airpol_heat, "heat_values", "airpol_heat")
rodent_heat <- setnames(rodent_heat, "heat_values", "rodent_heat")
trash_heat <- setnames(trash_heat, "heat_values", "trash_heat")
d311_heat <- setnames(d311_heat, "heat_values", "d311_heat")
construct_heat <- setnames(construct_heat, "heat_values", "construct_heat")
demolish_heat <- setnames(demolish_heat, "heat_values", "demolish_heat")
disturbance_heat <- setnames(disturbance_heat, "heat_values", "disturbance_heat")   
otherviol_heat <- setnames(otherviol_heat, "heat_values", "otherviol_heat")   


saveRDS(burglary_heat, "Data/burglary_heat.RDS") 
saveRDS(larceny_heat, "Data/larceny_heat.RDS") 
saveRDS(vandalism_heat, "Data/vandalism_heat.RDS") 
saveRDS(drug_heat, "Data/drug_heat.RDS") 
saveRDS(crime_heat, "Data/crime_heat.RDS") 
saveRDS(noise_heat, "Data/noise_heat.RDS")
saveRDS(dumping_heat, "Data/dumping_heat.RDS")
saveRDS(waterpol_heat, "Data/waterpol_heat.RDS")
saveRDS(airpol_heat, "Data/airpol_heat.RDS")
saveRDS(rodent_heat, "Data/rodent_heat.RDS")
saveRDS(trash_heat, "Data/trash_heat.RDS")
saveRDS(d311_heat, "Data/d311_heat.RDS")
saveRDS(construct_heat, "Data/construct_heat.RDS")
saveRDS(demolish_heat, "Data/demolish_heat.RDS")
saveRDS(disturbance_heat, "Data/disturbance_heat.RDS")
saveRDS(otherviol_heat, "Data/otherviol_heat.RDS")

