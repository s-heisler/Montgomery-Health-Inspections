require("geneorama")
geneorama::detach_nonstandard_packages()
require("geneorama")
require("data.table")
require("ROCR")
require("caret")

dat <- readRDS("Data/Model data.RDS")

#Remove ID vars from data
dat$id <- NULL
dat$Inspection_Date <- NULL
dat$Inspection_ID <- NULL

##########################################
#EDA
##########################################
#Calculate a correlation matrix
cors <- cor(dat)
write.table(cors, "Temp/Correlation matrix.csv", quote = FALSE, sep = ",", row.names = TRUE)

##########################################
#Create test and train data
##########################################
dat$fail_flag <- as.factor(dat$fail_flag)

#Calculate train data size
smp_size <- floor(0.75 * nrow(dat))

## set the seed to make partition reproductible
set.seed(123)

##Partition data
train_ind <- sample(seq_len(nrow(dat)), size = smp_size)

train <- dat[train_ind, ]
test <- dat[-train_ind, ]


##########################################
#Implement stepwise selection
##########################################

#Create list of vars to include in model
allvars <- list("otherviol_heat", "past_fail", "timeSinceLast", "category_restaurant", "category_takeout", "category_market", "category_school", "firstRecord", "burglary_heat", "larceny_heat", "vandalism_heat", "drug_heat", "noise_heat", "airpol_heat", "rodent_heat", "trash_heat", "d311_heat", "construct_heat", "demolish_heat", "dumping_heat30", "waterpol_heat30", "temp", "humid", "precip", "temp3day_avg", "humid3day_avg", "precip3day_sum", "liquor_license", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "CitySilverSpring", "CityRockville", "CityGaithesburg", "CityBethesda", "CityGermantown", "CityOlney", "CityWheaton")

#Define the full model formula
fullmod_formula <- paste("fail_flag ~ ", paste(allvars, collapse= "+"))

#Define the null hypothesis formula
nothing_formula <- "fail_flag ~ 1"

#Fit both models
fullmod <- glm(fullmod_formula,family=binomial(link='logit'),data=train)
nothing <- glm(nothing_formula,family=binomial(link='logit'),data=train)

#Perform stepwise logistic regression
bothways = step(nothing, list(lower=formula(nothing),upper=formula(fullmod)), direction="both")
summary(bothways)

#Plot ROC curve 
pred_values <- predict(bothways, type="response", new=test)
pred <- prediction(pred_values, test$fail_flag)
rocperf = performance(pred, measure = "tpr", x.measure = "fpr")
plot(rocperf)
abline(a=0, b= 1)

#Find the AUC
slot(performance(pred, "auc"), "y.values")[[1]]

#Generate a lift chart
liftperf <- performance(pred, measure="lift", x.measure="rpp")
plot(liftperf)
abline(a=1, b=0)
abline(a=1.2, b=0)
abline(a=1.4, b=0)

#Show confusion matrix
predict_bothways_train <- as.factor(ifelse(predict(bothways, type="response", new=test)>=0.5,1, 0))
confusionMatrix(predict_bothways_train, test$fail_flag, positive="1")

#Show confusion matrix - different threshold
predict_bothways_train <- as.factor(ifelse(predict(bothways, type="response", new=test)>=0.3,1, 0))
confusionMatrix(predict_bothways_train, test$fail_flag, positive="1")

#############=========================================================================
#Merge results onto a copy of the training data
train_comp <- train
train_comp

