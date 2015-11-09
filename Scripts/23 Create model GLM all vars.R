require("geneorama")
geneorama::detach_nonstandard_packages()
require("geneorama")
require("data.table")
require("caret")
require("glmnet")
require("ROCR")

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
#Fit a model with all variables
model_logit <- glm(fail_flag ~.,family=binomial(link='logit'),data=train)
summary(model_logit)

# #Confusion matrix
# plsClasses_logit <- predict(model_logit, newdata = train)
# confusionMatrix(data = plsClasses_logit, train$fail_flag)

#Get the R-squared
library(pscl)
pR2(model)

#Get the AIC
AIC(model)

#Identify threshold based on unequal costs
cost.perf = performance(pred, "cost", cost.fp = 1, cost.fn = 3)
cost_thresh <- pred@cutoffs[[1]][which.min(cost.perf@y.values[[1]])]
print(cost_thresh)

#Identify cutoff that maximizes accuracy
pred_values <- predict(model, type="response", new=train)
pred <- prediction(pred_values, train$fail_flag)

acc.perf = performance(pred, measure = "acc")
ind = which.max( slot(acc.perf, "y.values")[[1]] )
acc = slot(acc.perf, "y.values")[[1]][ind]
cutoff = slot(acc.perf, "x.values")[[1]][ind]
print(c(accuracy= acc, cutoff = cutoff))

#Calculate accuracy, precision, recall
pred_values <- ifelse(predict(model, type="response", new=train)>=cost_thresh,1, 0)
pred <- prediction(pred_values, train$fail_flag)

#Accuracy
slot(performance(pred, "acc"), "y.values")[[1]][2]

#Recall (true positive rate)
slot(performance(pred, "tpr"), "y.values")[[1]][2]

#Specificity (true negative rate)
slot(performance(pred, "tnr"), "y.values")[[1]][2]

#Positive predictive value (TP/(TP+FP))
slot(performance(pred, "ppv"), "y.values")[[1]][2]
