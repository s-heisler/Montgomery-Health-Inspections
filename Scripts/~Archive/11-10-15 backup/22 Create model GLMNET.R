##Create a GLMNET (elastic net regression) model
#Note that this gives worse results overall than regular stepwise logistic

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


#Try with glmnet
xdat <- train
xdat$fail_flag <-NULL
xdat <- as.matrix(xdat)
ydat <- as.factor(ifelse(train$fail_flag==0, "Pass", "Fail"))

#Create corresponding vars for test data
xdat_test <- test
xdat_test$fail_flag <-NULL
xdat_test <- as.matrix(xdat_test)
ydat_test <- as.factor(ifelse(test$fail_flag==0, "Pass", "Fail"))

#Set optimization parameters
tcontrol=trainControl(
		method = "repeatedCV",
		number=10,
		repeats=5,
		returnResamp = "all",
		classProbs = TRUE,
		summaryFunction=twoClassSummary
		)


model <- train(x = xdat,
            y = ydat,
            method='glmnet',
			metric = "ROC",
			tuneGrid = expand.grid(.alpha=seq(0,1,by=0.1), .lambda=seq(0,0.05,by=0.01)),
			trControl=tcontrol)
model

plot(model, metric='ROC')

#Get confusion matrix on training data
plsClasses <- predict(model, newdata = xdat)
confusionMatrix(data = plsClasses, ydat)

#View variable importances
importance <- varImp(model, scale=FALSE)
plot(importance)

#Get confusion matrix on testing data
plsClassesTest <- predict(model, newdata = xdat_test)
confusionMatrix(data = plsClassesTest, ydat_test)