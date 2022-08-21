# Load necessary package
library(reshape2)

file <- "getdata_dataset.zip"

## Downloads + unzip the dataset given to us:
if (!file.exists(file)){
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileurl, file, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file) 
}

# Loading the features and labels of data
actlabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actlabels[,2] <- as.character(actlabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Getting data on mean + standard deviation
featureswanted <- grep(".*mean.*|.*std.*", features[,2])
featureswanted.names <- features[featureswanted,2]
featureswanted.names = gsub('-mean', 'Mean', featureswanted.names)
featureswanted.names = gsub('-std', 'Std', featureswanted.names)
featureswanted.names <- gsub('[-()]', '', featureswanted.names)


# Loading the datasets
tr <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
tractivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
tr <- cbind(trsubjects, tractivities, tr)

tst <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
tstactivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
tstsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
tst <- cbind(tstsubjects, tstactivities, tst)

# Add labels to new merged data
everything <- rbind(tr, tst)
colnames(everything) <- c("subject", "activity", featureswanted.names)

# turn activities & subjects into factors
everything$activity <- factor(everything$activity, levels = actlabels[,1], labels = actlabels[,2])
everything$subject <- as.factor(everything$subject)

everything.melted <- melt(everything, id = c("subject", "activity"))
everything.mean <- dcast(everything.melted, subject + activity ~ variable, mean)

write.table(everything.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
