########################### Overview ##############################
# 1. Unzip the data files, and setwd() to the extracted folder, 
#    Place run_analysis.R script in that folder for execution.
# 2. Script load's the files into R memory. Merges test and training data
# 3. extract mean() and std() values from merged data with descriptive name
# 4. computes mean of mean() and std() columns based on subject and activity
# 5. writes output to a txt file and provides grader with code to read it in R
###################################################################


###### Install packages ######
# installing sqldf and dplyr packages
##############################

#install.packages("dplyr") # uncomment this if you see missing dplyr package error on ur machine
#install.packages("sqldf") # uncomment this if you see missing sqldf package error on ur machine
library(sqldf)
library(dplyr)

######## Loding files into R #######
# load training and test data into R
####################################

# loading training data set
# subject_id_training: holds training subject id's for all measurements
# features_training: holds feature measurements for all the training dataset
# activity_id_training: holds traning activity id's for all the measurements
subject_id_training<-read.table(file = "train/subject_train.txt")
features_training<-read.table(file = "train/X_train.txt")
activity_id_training<-read.table(file = "train/y_train.txt")


# loading test data set
# subject_id_test: holds test subject id's for all measurements
# features_test: holds feature measurements for all the test dataset
# activity_id_test: holds test activity id's for all the measurements
subject_id_test<-read.table(file = "test/subject_test.txt")
features_test<-read.table(file = "test/X_test.txt")
activity_id_test<-read.table(file = "test/y_test.txt")

# import activty name file. Used later to produce activty full description from id fields
activity_name<-read.table(file = "activity_labels.txt", stringsAsFactors = FALSE)

# import feature names file. Used later to extract mean and std header names and finall set them in tidy data file
feature_list<-read.table(file = "features.txt", stringsAsFactors = FALSE)


######## Checking the loaded data #######
# using str function to see how data looks inside R
# checking For NA
# using SQLDF to check for duplicate data
#########################################
## checking the imported data fields to study the data-types. 
## if any errors re-issuing the import statements above with correct settings.
## commented all out after the initial testing

#str(subject_id_training)
#str(features_training)
#str(activity_id_training)

#str(subject_id_test)
#str(features_test)
#str(activity_id_test)

#str(activity_name)
#str(activity_merged)
#str(merged_training)

#str(feature_list)


# checking if any NA, so to write a remove NA logic if needed

#any(is.na(subject_id_training$subject_id)) 

## checking counts to get an idea about the data. check for duplicates etc.

#sqldf('select subject_id_training.subject_id, 
#      count(*) from subject_id_training 
#      group by subject_id_training.subject_id')

#sqldf('select activity_id_training.activity_id, 
#      count(*) from activity_id_training 
#      group by activity_id_training.activity_id')

#same as count(*) and group by function above. Just checking with another function

#table(activity_id_training$activity_id) 



######## Name fields in DF for SQLDF joins #######
# To have a meaningful names in SQLDF joins, named columns
#########################################
## naming fields to be descriptive for SQL join and codebook later on

names(subject_id_training)<-c("subject_id")
names(subject_id_test)<-c("subject_id")

names(activity_id_training)<-("activity_id")
names(activity_id_test)<-("activity_id")

names(activity_name)<-c("activity_id","activity_name")

names(feature_list)<-c("feature_id","feature_name")

######## Merging the data ###############
# We can use MERGE or DPLYR, but I have used SQLDF as I am comfortable with SQL
# using CBIND and RBIND to get the final merged test and training data
# Since SQLDF is used we dont have to SORT the data before merging Activities and ID's
#########################################

# merge activities so for a given ID we give a descriptive name

activity_merged_training<-sqldf('select activity_id_training.activity_id, activity_name.activity_name
      from activity_id_training,activity_name
      where activity_id_training.activity_id = activity_name.activity_id')


activity_merged_test<-sqldf('select activity_id_test.activity_id, activity_name.activity_name
      from activity_id_test,activity_name
      where activity_id_test.activity_id = activity_name.activity_id')

## column bind to merge subject, activity and feature information

merged_training<-cbind(subject_id_training,activity_merged_training,features_training)
merged_test<-cbind(subject_id_test,activity_merged_test,features_test)

## row bind to join both the training and test datset

merged_data<-rbind(merged_training,merged_test)

# checking merged data to see if all columns exist

tail(merged_data)

######## Extracting column labels ###############
# using GREPL to find mean() and std() column positions, and using them to extract 
    # correct columns data from merged_data
# using GREPL to find matching column names in feature list file and assign them to the DF
################################################


## displays line number where mean() and std() exists
## '.*' will match anything till you find mean(), and [^Freq] means ignore Freq following mean()
which(grepl(".*mean()[^Freq].*",feature_list$feature_name))
which(grepl(".*std().*",feature_list$feature_name))

## merged everything into one array and since we have one subject and two activity columns
## in the beginning adding +3 to extract the correct columns from merged_data

## using '|' or OR to join extract column's when either of the regex conditions are true
column_position<-which(grepl("(.*std().*)|(.*mean()[^Freq].*)",feature_list$feature_name))+3
length(column_position)

## extracr subject_id, activity_id, activity_name and mean() and std() columns from merged_data
merged_data_MeanStd<-merged_data[,c(1:3,column_position)]

# checking output to see if everything still looks good. 
#Checking for columnnames as well
str(merged_data_MeanStd)

# extract the column names from the feature file
column_names<-feature_list[which(feature_list$feature_id %in% (which(grepl("(.*std().*)|(.*mean()[^Freq].*)",feature_list$feature_name)))),"feature_name"]
# clean '-' and '()' from the filename. Using '|' OR to put two patterns in the same
column_names<-gsub(pattern ="(-)|(\\(\\))" ,replacement = "",x = column_names)

# name the all the columns in the mean, std DF
names(merged_data_MeanStd)<-c("subject_id","activity_id","activity_name",column_names)

## unitesting code for checking avg of mean() and std() column
#sqldf('select avg(merged_data_MeanStd.tBodyAccmeanX) avg_tBodyAccmeanX 
#      from merged_data_MeanStd 
#      where merged_data_MeanStd.subject_id = 1 and
#      merged_data_MeanStd.activity_id = 1')


######## Find AvG of mean and std column ###############
# Before Applying group by function sort the data is mandatory
# Applying DPLY grammer to group data first and then do mean function
########################################################



# before applying group functions we sort the data based on the grouping column so we get a correct output.
merged_data_MeanStd_sorted<-arrange(merged_data_MeanStd,subject_id,activity_id)

# checking if the data is correctly sorted
str(merged_data_MeanStd_sorted)
tail(merged_data_MeanStd_sorted)


# Since the tidy data is avg of each value, adding descriptive names. 
# [1:60] as we have to rename the duplicate body in last 6 columns
avg_column_names<-paste("avg_",column_names[1:60],sep = "")

names(merged_data_MeanStd_sorted)<-c("subject_id",
                                     "activity_id",
                                     "activity_name",
                                     avg_column_names,
                                     "avg_fBodyAccJerkMagmean",
                                    "avg_fBodyAccJerkMagstd",
                                    "avg_fBodyGyroMagmean",
                                    "avg_fBodyGyroMagstd",
                                    "avg_fBodyGyroJerkMagmean",
                                    "avg_fBodyGyroJerkMagstd")


# DPLYR package is used to get mean of all rows. First group-by then apply mean
merged_data_MeanStd_sorted_group<-group_by(merged_data_MeanStd_sorted,subject_id,activity_id,activity_name)
merged_data_MeanStd_Summary<-summarise_each(merged_data_MeanStd_sorted_group, funs = funs(... = mean))

# checking the summary dataframe
# reason for (1,3:69) is I dont want to show activity_id in the output's. But I still
# want to have it in R as its faster to do sorting on numeric values than strings
str(merged_data_MeanStd_Summary)
View(merged_data_MeanStd_Summary[,c(1,3:69)])


######## Generating the data/.txt output ###############
# Write.table to write the summary to Merged_Samsung_Output.txt file
################################################
write.table(x = merged_data_MeanStd_Summary[,c(1,3:69)],file = "./Merged_Samsung_Output.txt",row.names = FALSE)

######## Generating the codebook.md ###############
# Generating codebook for variables used in data
################################################
write.table(avg_column_names,file="./codebook.md",row.names = FALSE)

######## Dear Grader, Please run below to see my data ###############
# Download Merged_Samsung_Output.txt file to your current directory and run the following
####################################################################

check_data<-read.table(file = "./Merged_Samsung_Output.txt",header = TRUE)
View(check_data)

