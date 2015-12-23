# Include relevant libraries
library(ggplot2)
library(gridExtra)
library(plyr)
library(dplyr, warn.conflicts = FALSE)
library(alr3)
library(reshape2)
library(tidyr)
library(GGally)

# Read in all files
setwd("D:\\Foundations of Data Science\\Projects\\Foundations of Data Science - Data Wrangling Project\\UCI HAR Dataset")
activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")

# Read in training files
setwd("D:\\Foundations of Data Science\\Projects\\Foundations of Data Science - Data Wrangling Project\\UCI HAR Dataset\\train")
subject_train <- read.table("subject_train.txt")
X_train <- read.table("x_train.txt")
y_train <- read.table("y_train.txt")
setwd("D:\\Foundations of Data Science\\Projects\\Foundations of Data Science - Data Wrangling Project\\UCI HAR Dataset\\train\\Inertial Signals")
body_acc_x_train <- read.table("body_acc_x_train.txt")
body_acc_y_train <- read.table("body_acc_y_train.txt")
body_acc_z_train <- read.table("body_acc_z_train.txt")
body_gyro_x_train <- read.table("body_gyro_x_train.txt")
body_gyro_y_train <- read.table("body_gyro_y_train.txt")
body_gyro_z_train <- read.table("body_gyro_z_train.txt")
total_acc_x_train <- read.table("total_acc_x_train.txt")
total_acc_y_train <- read.table("total_acc_y_train.txt")
total_acc_z_train <- read.table("total_acc_z_train.txt")

# Read in test files
setwd("D:\\Foundations of Data Science\\Projects\\Foundations of Data Science - Data Wrangling Project\\UCI HAR Dataset\\test")
subject_test <- read.table("subject_test.txt")
X_test <- read.table("x_test.txt")
y_test <- read.table("y_test.txt")
setwd("D:\\Foundations of Data Science\\Projects\\Foundations of Data Science - Data Wrangling Project\\UCI HAR Dataset\\test\\Inertial Signals")
body_acc_x_test <- read.table("body_acc_x_test.txt")
body_acc_y_test <- read.table("body_acc_y_test.txt")
body_acc_z_test <- read.table("body_acc_z_test.txt")
body_gyro_x_test <- read.table("body_gyro_x_test.txt")
body_gyro_y_test <- read.table("body_gyro_y_test.txt")
body_gyro_z_test <- read.table("body_gyro_z_test.txt")
total_acc_x_test <- read.table("total_acc_x_test.txt")
total_acc_y_test <- read.table("total_acc_y_test.txt")
total_acc_z_test <- read.table("total_acc_z_test.txt")

# Create single data frame - test
# Merge activity names and labels
# Preserve order by adding row number variable to y_test
y_test$id <- 1:nrow(y_test)
activityname_labels_test <- merge(y_test, activity_labels, by = "V1", all = TRUE)
activityname_labels_test <- activityname_labels_test[order(activityname_labels_test$id),]
# Reorder & rename columns
y_test <- y_test[,c(2, 1)]
activityname_labels_test <- activityname_labels_test[,c(2, 1, 3)]
colnames(activityname_labels_test)[2] <- "activitylabel"
colnames(activityname_labels_test)[3] <- "activityname"
# Bind labels and sets
labels_sets_test <- cbind(activityname_labels_test, X_test)
# Bind subjects
subjects_labels_sets_test <- cbind(subject_test, labels_sets_test)
# Rename and reorder columns
colnames(subjects_labels_sets_test)[1] <- "subject"
subjects_labels_sets_test <- subjects_labels_sets_test[,c(2, 1, 3:565)]

# Merge features to set
# Turn subjects_labels_sets_test into long
subjects_labels_sets_test.long <- gather(subjects_labels_sets_test, featureid, value, -id, -subject, -activitylabel, -activityname)
# Map featurename to featureid
# Remove v from featureid
subjects_labels_sets_test.long$featureid <- gsub( "V", "", paste(subjects_labels_sets_test.long$featureid))
# Map featurename to new featureid
subjects_labels_sets_test.long <- merge(subjects_labels_sets_test.long, features, by.x = c("featureid"), by.y=c("V1"), all = TRUE)
# Drop unneccessary columns, reorder, rename
subjects_labels_sets_test.long$featureid <- NULL
subjects_labels_sets_test.long <- subjects_labels_sets_test.long[,c(1, 2, 3, 4, 6, 5)]
colnames(subjects_labels_sets_test.long)[5] <- "featurename"
# Redo unique id for now-expanded data set
subjects_labels_sets_test.long$id <- 1:nrow(subjects_labels_sets_test.long)
# Wide the dataset
subjects_labels_sets_test.wide <- spread(subjects_labels_sets_test.long, featurename, value)


# Testing
X_test.long <- gather(X_test)
X_test.long$id <- 1:nrow(X_test.long)
View(X_test.long)
X_test.long.subset <- head(X_test.long, n = 10000)
View(X_test.long.subset)
X_test.long.subset.grouped <- group_by(X_test.long.subset, key, value)
X_test.wide <- spread(X_test.long.subset.grouped, key, value)
View(X_test.wide)