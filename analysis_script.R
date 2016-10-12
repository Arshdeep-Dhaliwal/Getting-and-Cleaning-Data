## Download the zip file
setwd("F:\\R Coursera\\data")
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="F:\\R Coursera\\data\\rProject.zip")

## Unzip DataSet in directory
unzip(zipfile="F:\\R Coursera\\data\\rProject.zip", exdir="F:\\R Coursera\\data")

###Load required packages
library(dplyr)
library(data.table)
library(tidyr)

dataLocation <- "F:\\R Coursera\\data\\UCI HAR Dataset"

# Read subject files
dataSubTrain <- tbl_df(read.table(file.path(dataLocation, "train", "subject_train.txt")))
dataSubTest  <- tbl_df(read.table(file.path(dataLocation, "test" , "subject_test.txt" )))

# Read activity files
dataActivityTrain <- tbl_df(read.table(file.path(dataLocation, "train", "Y_train.txt")))
dataActivityTest  <- tbl_df(read.table(file.path(dataLocation, "test" , "Y_test.txt" )))

#Read data files.
dataTrain <- tbl_df(read.table(file.path(dataLocation, "train", "X_train.txt" )))
dataTest  <- tbl_df(read.table(file.path(dataLocation, "test" , "X_test.txt" )))

## Merge the training and the test subject data tables by row binding 
dataSub <- rbind(dataSubTrain, dataSubTest)
## Rename variable as "subject"
setnames(dataSub, "V1", "subject")

## Merge the training and the test activity data tables by row binding 
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
## Rename variable as "activity"
setnames(dataActivity, "V1", "activity")

## Merge the training and test data table
dataTable <- rbind(dataTrain, dataTest)

# Read features file
dataFeatures <- tbl_df(read.table(file.path(dataLocation, "features.txt")))
## Name variables according to features
setnames(dataFeatures, names(dataFeatures), c("feature", "featureName"))
colnames(dataTable) <- dataFeatures$featureName

## Column names for activity labels
activityLabels<- tbl_df(read.table(file.path(dataLocation, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activity","activityName"))

# Merge columns
dataSubjAct<- cbind(dataSub, dataActivity)
dataTable <- cbind(dataSubjAct, dataTable)

## Read "features.txt" and extract the mean and standard deviation
FeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",dataFeatures$featureName,value=TRUE)

# TakE only measurements for the mean and standard deviation and add "subject","activity"
FeaturesMeanStd <- union(c("subject","activity"), FeaturesMeanStd)
dataTable<- subset(dataTable,select= FeaturesMeanStd)

## Enter name of activity into dataTable
dataTable <- merge(activityLabels, dataTable , by="activity", all.x=TRUE)
dataTable$activityName <- as.character(dataTable$activityName)

## Create dataTable with variable means sorted by subject and Activity
dataTable$activityName <- as.character(dataTable$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = dataTable, mean) 
dataTable<- tbl_df(arrange(dataAggr,subject,activityName))