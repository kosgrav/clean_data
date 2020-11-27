# download data from web

datadescrip <- "http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones"
dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file (dataURL, destfile = "data.zip")

# extract zip archive

unzip ("data.zip")

# 1. Create one data set by merging training and test sets
# read activity and feature labels

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")

# read test data

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

# read training data

subject_training <- read.table("./UCI HAR Dataset/train/subject_train.txt")
X_training <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_training <- read.table("./UCI HAR Dataset/train/y_train.txt")

# combine subjects, activity labels, and features into test and training sets

test  <- cbind(subject_test, y_test, X_test)
training <- cbind(subject_training, y_training, X_training)

# combine test and training sets into full data set

DataSet <- rbind(test, training)

# 2. Extract only the mean and standard deviation for each measurement
# subset the data, keeping the mean, standard deviation, subject, and activity columns

allNames <- c("subject", "activity", as.character(features$V2))
meanStdColumns <- grep("subject|activity|[Mm]ean|std", allNames, value = FALSE)
reducedSet <- DataSet[ ,meanStdColumns]

# 3. Use descriptive activity names to name the activities in the data set
# apply activity names to corresponding activity number using indexing

names(activity_labels) <- c("activityNumber", "activityName")
reducedSet$V1.1 <- activity_labels$activityName[reducedSet$V1.1]

# 4. Label data set with descriptive varible names
# rename variables using a series of substitutions

reducedNames <- allNames[meanStdColumns]  
reducedNames <- gsub("mean", "Mean", reducedNames)
reducedNames <- gsub("std", "Std", reducedNames)
reducedNames <- gsub("gravity", "Gravity", reducedNames)
reducedNames <- gsub("[[:punct:]]", "", reducedNames)
reducedNames <- gsub("^t", "time", reducedNames)
reducedNames <- gsub("^f", "frequency", reducedNames)
reducedNames <- gsub("^anglet", "angleTime", reducedNames)
names(reducedSet) <- reducedNames

# 5. Create a second, independent tidy data set containing the average of each variable for each activity and each subject
# create tidy data set

tidyDataset <- reducedSet %>% 
  group_by(activity, subject) %>%
  summarize_all(funs(mean))

# write tidy data to output file

write.table(tidyDataset, file = "tidyDataset.txt", row.names = FALSE)