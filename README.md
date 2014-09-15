wearable-data
=============

DS3 Getting and Cleaning Data - Project assignment

The raw data set is the zipfile downloaded for the assignment, and the tidy data set is generated from the run_analysis.R script

This repo contains


###The R script
  run_analysis.R

###The tidy data set
  average_measurements.txt

###The code book
  average_measurements-info.txt

###Key assumption 1
  That the subjects called 1,2,3 during training are the same people in the same order as the subhjects called 1,2,3 etc during testing (i.e. this is an assumption that it makes sense to aggregate data by the numeric value of the subject key, across the two separate populations)

###Key assumption 2
  That the instructions are for us to produce a single set of averages by Activity Name (human readable) AND Subject (key number)

###Key assumption 3
  That all measurements labelled as "-std" or "-mean" in the code book (features.txt) are meant to be included



##How the script works
### Step 1 : merge the training and test data sets to create one data set
The script reads the full train data and the full test data into separate datasets using read.table(), also the subject code and the activity key
which are contained in corresponding extra files.
The subject code and activity are added using cbind() to make them additional columns at the end.
Then rbind() is used to merge the test and training data into one longer dataset. 
The subject code and activity key will be needed to perform the tasks in step 4 and step 5.

### Step 2 : Extracts only the measurements on the mean and standard deviation for each measurement
The features.txt file identifies 40 measurements as being either "mean" or "std"
The script uses select() from library dplyr to reduce down to the 42 columns needed (bringing subject key and activity key to the first two columns).
NB. The reason for placing the subject key and activity key in the last columns 
during the creation of the data set x was so that the numbers in the column
selection here can match the numbers in the code book named features.txt)

###  Step 3 : use descriptive activity names to name the activities in the data set
This step actually takes place AFTER Step 4 in the sequence of processing. The reason is because the method used for Step 3 is 
the function merge() from library dplyr, and this works by using the column names.
The merge() function allows the human-readable text for the five different activities to be placed into the data table as an additional column.

### Step 4 : Appropriately label the data set with descriptive variable names
This step is in fact done twice. It has to be done initially to make Step 3 straightforward and understandable.
However, after Step 5 there is a new dataset with averages, so at the end of Step 5, the labelling with descriptive variable names is done again (using altered names that start with "avg").

Step 4 uses cbind to create the list of column names from the information in features.txt (plus names for other columns introduced during this script's operation).
This list is then applied to the data table using the names() function.

### Step 5 : create a second, tidy data set with the average of each variable for each activity type and subject
Step 5 is the hardest part. It uses various functions from the library reshape2.
During Step 5, it becomes necessary to refer to some of the new columns using literals, which is a shame because this way 
of writing code is more error-prone than announcing the new column names at the start of the script and keeping them in named variables.

I was not able to use chaining successfully in Step 5, so a number of intermediate tables are created. Ideally these would not be created at all, or would be released for memory-reallocation by R as soon as they were no longer needed.

The actions in Step 5 start with the data set with named columns (x3 from the end of the previous step).
First melt() is used to make the data set long and skinny, with the 40 measurements converted from separate columns to named measurement values on separate rows.
The summarisation stage is going to need a single key to summarise on, but the project instructions are to provide averages "by activity and subject".
So the next task is to create a reference field (ref) by using paste() to concatenate the human-readable activity name with the subject key.
This now allows dcast() to generate a summarised data table from the melted data table.
In order to finish properly, I have to undo the "ref" column back into its two constituents. This is done using str_split() to produce a 2 x n vector of activity names and subject keys.
select() and merge() are used to replace the ref column with these two as new separate columns.
And in the last task during this step, the data table names are re-applied, this time with "avg" pasted at the start of each measurement used.


### Step 6 : create a text table of the results for uploading on the Assignment submission page
This is created using write.table() as per the instructions.




