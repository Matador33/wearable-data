run_analysis <- function() {
  library(dplyr)
  show_progress <- FALSE
  
## Step 1 = merge the training and test data sets to create one data set
##          (Note that the subject code and activity key are provided in 
##           additional files, these are included as they will be needed
##           to perform the tasks in step4 and step 5)
  if (show_progress) "Step 1"
  colname_activity_key <- "activity_key"   ## avoid activity table using column v1
  colname_activity <- "activity"           ## Ensure always refer to columns correctly
  colname_subject_key <- "subject_key"     ## avoid subject table using column v1
  
  train <- read.table("~/UCI HAR Dataset/train/X_train.txt")
  train_activity <- read.table("~/UCI HAR Dataset/train/y_train.txt")
  names(train_activity) = c(colname_activity_key)
  train_subject <- read.table("~/UCI HAR Dataset/train/subject_train.txt")
  names(train_subject) = c(colname_subject_key)
  test <- read.table("~/UCI HAR Dataset/test/X_test.txt")
  test_subject <- read.table("~/UCI HAR Dataset/test/subject_test.txt")
  test_activity <- read.table("~/UCI HAR Dataset/test/y_test.txt")
  names(test_activity) = c(colname_activity_key)
  names(test_subject) = c(colname_subject_key)
  x<-rbind(cbind(train,train_subject,train_activity),cbind(test,test_subject,test_activity))

## Step 2 Extracts only the measurements on the mean and standard deviation for each measurement
##        (Note that the subject key and activity key were placed in the last columns )
##         during the creation of the data set x, so that the numbers in the column
##         selection here can match the numbers in the code book named features.txt)

  if (show_progress) "Step 2"
  x2<-select(x,562,563,1:6,41:46,81:86,121:126,161:166,201:202,214:215,227:228,240:241,253:254)

## Step 4 Appropriately label the data set with descriptive variable names
##        (Note this comes before Step 3 because the merge needed for Step 3
##        depends on having the column names already in place)
## This code is only an initial bit of the work for Step 4, the rest needs 
## repeating after Step 5 because in Step 5 the dataset is collapsed to an 
## average for each measurement 
  if (show_progress) "Step 4"
  x2names <- cbind(colname_subject_key,colname_activity_key,                                                                                           ## 561,562
                   "tBodyAcc-meanX","tBodyAcc-meanY","tBodyAcc-meanZ","tBodyAcc-stdX","tBodyAcc-stdY","tBodyAcc-stdZ",                    ## 1-6
                   "tGravityAcc-meanX","tGravityAcc-meanY","tGravityAcc-meanZ","tGravityAcc-stdX","tGravityAcc-stdY","tGravityAcc-stdZ",  ## 41-46                    
                   "tBodyAccJerk-meanX","tBodyAccJerk-meanY","tBodyAccJerk-meanZ","tBodyAccJerk-stdX","tBodyAccJerk-stdY","tBodyAccJerk-stdZ",  ## 81-86
                   "tBodyGyro-meanX","tBodyGyo-meanY","tBodyGyro-meanZ","tBodyGyro-stdX","tBodyGyro-stdY","tBodyGyro-stdZ",              ## 121-126
                   "tBodyGyroJerk-meanX","tBodyGyroJerk-meanY","tBodyGyroJerk-meanZ","tBodyGyroJerk-stdX","tBodyGyroJerk-stdY","tBodyGyroJerk-stdZ",## 161-166
                   "tBodyAccMag-mean", "tBodyAccMag-std",                                                                                 ## 201-202
                   "tGravityAccMag-mean", "tGravityAccMag-std",                                                                           ## 214-215
                   "tBodyAccJerkMag-mean", "tBodyAccJerkMag-std",                                                                         ## 227-228
                   "tBodyGyroMag-mean", "tBodyGyroMag-std",                                                                               ## 240-241
                   "tBodyGyroJerkMag-mean", "tBodyGyroJerkMag-std"                                                                        ## 253-254
                   )
  names(x2) <- x2names 

##  Step 3 - use descriptive activity names to name the activities in the data set
##           This is done by merging with the human-readable list of activity names

  if (show_progress) "Step 3"
  activity_labels <- read.table("~/UCI HAR Dataset/activity_labels.txt") 
  names(activity_labels) <- cbind(colname_activity_key,colname_activity)
  x3 <- merge(x2,activity_labels)

## Step 5 - create a second, tidy data set with the average of each variable for each activity type and subject
  if (show_progress) "Step 5"
  library(reshape2)
  xmelt <- melt(x3,id=c("activity","subject_key"),measure.vars=3:42)
  xmelt2 <- mutate(xmelt,ref = paste(colname_activity,colname_subject_key))
  xcast <- dcast(xmelt2,ref ~ variable,mean)
  xq <- str_split_fixed(xcast$ref," ",2)
  activity <- xq[,1] 
  subject <- xq[,2]
  xfinal <- cbind(activity,subject,select(xcast,2:41))
  xfinalnames = paste("avg",x2names)
  xfinalnames[1] <- "activity-name"
  xfinalnames[2] <- "subject-key"
  names(xfinal) <- xfinalnames

## Step 6 - write results to a table for uploading to Coursera
  if (show_progress) "Step 6"
  write.table(xfinal,file="average_measurements.txt",row.names=FALSE)
}
