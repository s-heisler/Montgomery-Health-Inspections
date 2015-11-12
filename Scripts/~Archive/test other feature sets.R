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
allvars <- list("past_fail", 
				"category_restaurant", 
				"CitySilverSpring", 
				"burglary_heat", 
				"liquor_license", 
				"larceny_heat", 
				"CityRockville", 
				"temp", 
				"timeSinceLast", 
				"firstRecord", 
				"category_takeout", 
				"otherviol_heat", 
				"Aug", 
				"construct_heat", 
				"humid", 
				"May", 
				"category_school", 
				"CityBethesda")

#Define the full model formula
fullmod_formula <- paste("fail_flag ~ ", paste(allvars, collapse= "+"))

#Fit both models
fullmod <- glm(fullmod_formula,family=binomial(link='logit'),data=train)

#Plot ROC curve 
pred_values <- predict(fullmod, type="response", new=test)
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
predict_bothways_train <- as.factor(ifelse(predict(fullmod, type="response", new=test)>=0.5,1, 0))
confusionMatrix(predict_bothways_train, test$fail_flag, positive="1")

#Show confusion matrix - different threshold
predict_bothways_train <- as.factor(ifelse(predict(fullmod, type="response", new=test)>=0.3,1, 0))
confusionMatrix(predict_bothways_train, test$fail_flag, positive="1")

#############=========================================================================
#Merge results onto a copy of the training data
train_comp <- train
train_comp

