## 0. Download data from source

#Create a new working directory
if(!dir.exists("data")){
    dir.create("./data")
}

#Download data
dataSource <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataSource,destfile="./data/rawData.zip",method="curl")

#unzip the data
unzip(zipfile="./data/rawData.zip",exdir="./data")

#move into the new working directory
setwd("./data")

#determine the files present
files<-list.files("UCI HAR Dataset", recursive=TRUE)

## 1. Merging training and test datasets
#refer to the structure of the data (there is a useful diagram)


#Read the Activity files

ActivityTest  <- read.table(file.path("UCI HAR Dataset", "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path("UCI HAR Dataset", "train", "Y_train.txt"),header = FALSE)


#Read the Subject files

SubjectTrain <- read.table(file.path("UCI HAR Dataset", "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path("UCI HAR Dataset", "test" , "subject_test.txt"),header = FALSE)


#Read Fearures files

FeaturesTest  <- read.table(file.path("UCI HAR Dataset", "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path("UCI HAR Dataset", "train", "X_train.txt"),header = FALSE)


#combine train and test data for subjects

Subject <- rbind(SubjectTrain, SubjectTest)
Activity<- rbind(ActivityTrain, ActivityTest)
Features<- rbind(FeaturesTrain, FeaturesTest)

names(Subject)<-c("subject")
names(Activity)<- c("activity")
FeaturesNames <- read.table(file.path("UCI HAR Dataset", "features.txt"),head=FALSE)
names(Features)<- FeaturesNames$V2

Combine <- cbind(Subject, Activity)
Data <- cbind(Features, Combine)

## 2. Extracting mean and standard deviation from each measurement

#get the names of the variables with mean() or std() in them

MeanStdNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]

selectedNames<-c(as.character(MeanStdNames), "subject", "activity" )

dataSubset<-subset(Data,select=selectedNames)


## 3. Descriptive renaming of variables 

#read descriptive names from activity_labels.txt
activityLabels <- read.table(file.path("UCI HAR Dataset", "activity_labels.txt"),header = FALSE)



## 4. Relabeling dataset using descriptive variable names
#create factor levels (i.e convert numeric values to factor levels)
Data$activity<-factor(Data$activity)
#redefine levels in terms of descriptive names
levels(Data$activity)<-activityLabels[,2]

#Furthermore, undo the abbreviations in the variable names like so:

#prefix t --> time
#Acc --> Accelerometer
#Gyro --> Gyroscope
#prefix f --> frequency
#Mag --> Magnitude
#BodyBody --> Body

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))


## 5. Creating an independent tidy data set with the averges of each variable for each activity and each subject 

library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
