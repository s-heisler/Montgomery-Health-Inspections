#############=========================================================================
#Try caret recursive feature selection
#This takes a really, really long time. Couldn't get it to finish running. Besides, it keeps trying to eliminate all my vars.

require("geneorama")
geneorama::detach_nonstandard_packages()
require("geneorama")
require("data.table")
require("caret")
require("glmnet")
require("ROCR")

require("ipred")
require("e1071")
require("doMC")

dat <- readRDS("Data/Model data.RDS")

#Remove ID vars from data
dat$id <- NULL
dat$Inspection_Date <- NULL
dat$Inspection_ID <- NULL

##########################################
#Create test and train data
##########################################
#Calculate train data size
smp_size <- floor(0.75 * nrow(dat))

## set the seed to make partition reproductible
set.seed(123)

##Partition data
train_ind <- sample(seq_len(nrow(dat)), size = smp_size)

train <- dat[train_ind, ]
test <- dat[-train_ind, ]


#Set data
xdat <- train
xdat$fail_flag <-NULL
xdat <- as.matrix(xdat)
ydat <- as.factor(ifelse(train$fail_flag==0, "Pass", "Fail"))

#Custom Functions
glmnetFuncs <- caretFuncs #Default caret functions

glmnetFuncs$summary <-  twoClassSummary

#Rank coefficients by size for feature selection
glmnetFuncs$rank <- function (object, x, y) {
	vimp <- sort(object$finalModel$beta[, 1])
	vimp <- as.data.frame(vimp)
	vimp$var <- row.names(vimp)
	vimp$'Overall' <- seq(nrow(vimp),1)
	vimp
}

MyRFEcontrol <- rfeControl(
		functions=glmnetFuncs,
		method = "boot",
		number = 15,
		rerank = FALSE,
		returnResamp = "final",
		saveDetails = FALSE,
		verbose = TRUE)


MyTrainControl <- trainControl(
		method = "boot",
		number=10,
		returnResamp = "all",
		classProbs = TRUE,
		summaryFunction=twoClassSummary
		)

RFE <- rfe(xdat,ydat,
		preProcess(method = c("center", "scale")),
		metric = "ROC",
		maximize=TRUE,
		rfeControl = MyRFEcontrol,
		sizes=c(6:60),
		method='glmnet',
		tuneGrid = expand.grid(.alpha=seq(0,1, by=0.2),.lambda=seq(0,0.03,by=0.01)),
		trControl = MyTrainControl,
		parallel = TRUE)


NewVars <- RFE$optVariables
RFE
plot(RFE)

FL <- as.formula(paste("ydat ~ ", paste(NewVars, collapse= "+")))


model_RFE <- train(FL,
			data=xdat,
            method='glmnet',
			metric = "ROC",
			tuneGrid = expand.grid(.alpha=seq(0,1,by=0.1),.lambda=seq(0,0.05,by=0.01)),
			trControl=tcontrol)

model_RFE
plot(RFE, type=c("g", "o"))