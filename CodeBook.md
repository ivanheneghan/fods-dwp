# Markdown Code Book for Foundations of Data Science - Data Wrangling Project

## Data Sets:

* activity_labels - The labels for the 6 activities, taken from activity_labels.txt.
* features - The list of 261 features, taken from features.txt.
* subject_train - The training set of subject identifies, taken from subject_train.txt.
* * X_train - The training set of features data, taken from X_train.txt, and which matches to the 261 features outlined in features.txt.
* y_train - The training set of activies (1 - 6, matching to the activity labels above), taken from y_train.txt.
* subject_test - The test set of subject identifies, taken from subject_test.txt.
* X_test - The test set of features data, taken from X_test.txt, and which matches to the 261 features outlined in features.txt.
* y_test - The test set of activies (1 - 6, matching to the activity labels above), taken from y_test.txt.

## Step-by-Step Transformations:

### I read in all files to local data frames: 

activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")
subject_train <- read.table("subject_train.txt")
X_train <- read.table("x_train.txt")
y_train <- read.table("y_train.txt")
subject_test <- read.table("subject_test.txt")
X_test <- read.table("x_test.txt")
y_test <- read.table("y_test.txt")

### I merged the training and test sets into one set, using rbind():

subject_merged <- rbind(subject_train, subject_test)
X_merged <- rbind(X_train, X_test)
y_merged <- rbind(y_train, y_test)

### I named the columns in the X_merged data with the header names taken from the features file, as these are the column headers/variable names:

colnames(X_merged) <- t(features[2])

### I expanded the activities data set to include both label identified (numerical) and name (text). I merged activity names and labels. I preserved the order by adding a row number variable (id) to the merged y data (y_merged) (from 1 to the number of rows), with an eye towards removing this again later (otherwise order would be lost when merging the acitivy labels with the activity names). I then merged the activity labels and the activity names, giving me the complete list of activities, in order:

y_merged$id <- 1:nrow(y_merged)
activitylabels_names <- merge(y_merged, activity_labels, by = "V1", all = TRUE)
activitylabels_names <- activitylabels_names[order(activitylabels_names$id),]

###  I reordered & renamed columns to make this cleaner:

y_test <- y_test[,c(2, 1)]
activitylabels_names <- activitylabels_names[,c(2, 1, 3)]
colnames(activitylabels_names)[2] <- "activitylabel"
colnames(activitylabels_names)[3] <- "activityname"

### I merged X, y and subject data sets to form a complete data set:

complete <- cbind(subject_merged, activitylabels_names, X_merged)

### I renamed relevant columns (1), and removed the id column I used to sort:

colnames(complete)[1] <- "subject"
complete$id <- NULL

### I extracted the mean/standard deviation columns (columns with mean() and std() in the names). I used grep for this. I then merged each set of data (mean and standard deviation) with the subject and activity data sets, renamed columns, and removed the id column:

mean_subset <- complete[,grep("mean()", colnames(complete), ignore.case = TRUE)]
std_subset <- complete[,grep("std()", colnames(complete), ignore.case = TRUE)]
mean_std <- cbind(subject_merged, activitylabels_names, mean_subset, std_subset)
colnames(mean_std)[1] <- "subject"

### I created the data set with average of each variable for activity & subject. I used aggregate() for this, with the dot notation due to the huge number of variables, aggregating across subject and activity name, and taking the mean:

tidy <- aggregate(. ~ subject + activityname, mean_std, mean)