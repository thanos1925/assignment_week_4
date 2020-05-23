### Before you begin, make sure you have the package dplyr. If not, run: install.packages('dplyr')

### Download the zip file in your working directory and unzips it
#delete this comment and run the following command to find your working directory: getwd()
dest_zip = './Assignment.zip' #set the path and name of the zip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = dest_zip) #download zipfile
unzip(dest_zip) #unzips zipfile in your working directory

### '1. Merges the training and the test sets to create one data set.'
### Read and combine the train and test data

## Read the features labels table
dest_features_labels <- './UCI HAR Dataset/features.txt'
features_labels <- read.table(dest_features_labels)
colnames(features_labels) <- c('code', 'feature_label')


## Read and combine the train data
dest_train_X <- './UCI HAR Dataset/train/X_train.txt'
train_X_data <- read.table(dest_train_X)
colnames(train_X_data) <- features_labels$feature_label # Identify the features based on the features file
dest_train_Y <- './UCI HAR Dataset/train/y_train.txt'
train_Y_data <- read.table(dest_train_Y)
colnames(train_Y_data) <- 'activity_code'
dest_subject_train <- './UCI HAR Dataset/train/subject_train.txt'
train_subject_data <- read.table(dest_subject_train)
colnames(train_subject_data) <- 'subject'
train_df <- cbind(train_subject_data, train_Y_data, train_X_data)

## Read and combine the test data
dest_test_X <- './UCI HAR Dataset/test/X_test.txt'
test_X_data <- read.table(dest_test_X)
colnames(test_X_data) <- features_labels$feature_label # Identify the features based on the features file
dest_test_Y <- './UCI HAR Dataset/test/y_test.txt'
test_Y_data <- read.table(dest_test_Y)
colnames(test_Y_data) <- 'activity_code'
dest_subject_test <- './UCI HAR Dataset/test/subject_test.txt'
test_subject_data <- read.table(dest_subject_test)
colnames(test_subject_data) <- 'subject'
test_df <- cbind(test_subject_data, test_Y_data, test_X_data)

## Merge the train and test data
merged_df <- rbind(train_df, test_df)

### '2. Extracts only the measurements on the mean and standard deviation for each measurement'
needed_columns <- grep("mean\\(\\)|std\\(\\)",colnames(merged_df)) #Identify the column numbers you need, as the ones including mean and std in the title
extract_df <- merged_df[,c(1,2,needed_columns)]                    #Extract the required columns plus the first two referring to the test subject and the activity

### 3. Uses descriptive activity names to name the activities in the data set
## Read the activity labels table
dest_activity_labels <- './UCI HAR Dataset/activity_labels.txt'
activity_labels <- read.table(dest_activity_labels)
colnames(activity_labels) <- c('code', 'activity_label')

## Join extraxt_df with activity_labels
extract_labeled_df <- merge(activity_labels, extract_df, by.y = 'activity_code', by.x = 'code', all = TRUE)
extract_labeled_df <- extract_labeled_df[,-1]


### '4. Appropriately labels the data set with descriptive variable names.'
## Clarifying the variable names further by substituting half-words
names(extract_labeled_df)<-gsub("Acc", "Accelerometer", names(extract_labeled_df))
names(extract_labeled_df)<-gsub("Gyro", "Gyroscope", names(extract_labeled_df))
names(extract_labeled_df)<-gsub("BodyBody", "Body", names(extract_labeled_df))
names(extract_labeled_df)<-gsub("Mag", "Magnitude", names(extract_labeled_df))
names(extract_labeled_df)<-gsub("^t", "Time", names(extract_labeled_df))
names(extract_labeled_df)<-gsub("^f", "Frequency", names(extract_labeled_df))
names(extract_labeled_df)<-gsub("tBody", "TimeBody", names(extract_labeled_df))
names(extract_labeled_df)<-gsub("-mean()", "Mean", names(extract_labeled_df), ignore.case = TRUE)
names(extract_labeled_df)<-gsub("-std()", "STD", names(extract_labeled_df), ignore.case = TRUE)
names(extract_labeled_df)<-gsub("-freq()", "Frequency", names(extract_labeled_df), ignore.case = TRUE)
names(extract_labeled_df)<-gsub("angle", "Angle", names(extract_labeled_df))
names(extract_labeled_df)<-gsub("gravity", "Gravity", names(extract_labeled_df))
        
### '5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.'
##Usin dplyr functions group_by and summarise, get the required averages
library(dplyr)
grouped_data <- group_by(extract_labeled_df, activity_label, subject)
tidy_data <- summarise_all(grouped_data, list(mean = mean))
write.table(tidy_data, file = "./UCI HAR Dataset/tidydata.txt", row.names = FALSE)


