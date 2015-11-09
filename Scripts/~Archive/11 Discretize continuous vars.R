restaurants <- readRDS("Data/food_inspections.Rds")


#Drop duplicate inspection records
restaurants <- data.table(restaurants)
setkey(restaurants, id)
restaurants <- unique(restaurants)
rest <- restaurants[ , list( Latitude, Longitude)]
rest <- subset(rest, Latitude>38 & Latitude<40)


fit <- kmeans(rest, 15)
mydata <- data.frame(rest, fit$cluster) 
attach(mydata)
plot(Latitude, Longitude, col=fit.cluster)

library(mclust)
fit <- Mclust(rest)
plot(fit) # plot results
summary(fit) # display the best model 