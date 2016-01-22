# Include relevant libraries
library(ggplot2)
library(gridExtra)
library(plyr)
library(dplyr, warn.conflicts = FALSE)
library(alr3)
library(reshape2)
library(tidyr)
library(GGally)
library(data.table)

# Read in all files
setwd("D:\\Foundations of Data Science\\Projects\\Foundations of Data Science - Data Wrangling Project\\UCI HAR Dataset")
activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")

# Read in training files
setwd("D:\\Foundations of Data Science\\Projects\\Foundations of Data Science - Data Wrangling Project\\UCI HAR Dataset\\train")
subject_train <- read.table("subject_train.txt")
X_train <- read.table("X_train.txt")
y_train <- read.table("y_train.txt")

# Read in test files
setwd("D:\\Foundations of Data Science\\Projects\\Foundations of Data Science - Data Wrangling Project\\UCI HAR Dataset\\test")
subject_test <- read.table("subject_test.txt")
X_test <- read.table("X_test.txt")
y_test <- read.table("y_test.txt")

# Merge the training and test sets into one set
subject_merged <- rbind(subject_train, subject_test)
X_merged <- rbind(X_train, X_test)
y_merged <- rbind(y_train, y_test)

# Name the columns in the merged X data with the header names taken from the features file
colnames(X_merged) <- t(features[2])

# Expand the activities data set to include label and name
# Merge activity names and labels
# Preserve order by adding row number variable to y_test
y_merged$id <- 1:nrow(y_merged)
activitylabels_names <- merge(y_merged, activity_labels, by = "V1", all = TRUE)
activitylabels_names <- activitylabels_names[order(activitylabels_names$id),]

# Reorder & rename columns
y_test <- y_test[,c(2, 1)]
activitylabels_names <- activitylabels_names[,c(2, 1, 3)]
colnames(activitylabels_names)[2] <- "activitylabel"
colnames(activitylabels_names)[3] <- "activityname"

# Merge X, y and subject data sets
complete <- cbind(subject_merged, activitylabels_names, X_merged)

# Rename relevant columns (1)
colnames(complete)[1] <- "subject"

# Remove sort column
complete$id <- NULL

# Extract mean/standard deviation columns (columns with mean() and std() in the names)
mean_subset <- complete[,grep("mean()", colnames(complete), ignore.case = TRUE)]
std_subset <- complete[,grep("std()", colnames(complete), ignore.case = TRUE)]
mean_std <- cbind(subject_merged, activitylabels_names, mean_subset, std_subset)
colnames(mean_std)[1] <- "subject"
mean_std$id <- NULL

# Create data set with average of each variable for activity & subject
tidy <- aggregate(. ~ subject + activityname, mean_std, mean)