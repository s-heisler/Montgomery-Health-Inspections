#Create a unique list of establishment IDs
foodId <- readRDS("Data/food_inspections.Rds")

foodId <- foodId[, list(Name, addr, City, Zip, id)]
foodId <- unique(foodId)

saveRDS(foodId , "Data/Restaurant IDs in food inspections.Rds")

