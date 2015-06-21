GettingAndCleaningData Course Project
=====================================

Objective
-----------------------------------
- Using the data from the Samsung Accelerometer perform mean of Mean() and std() columns.
- Provide descriptive column names for the final tidy data.
- Generate codebook.md describing each column name in the tidy data.
- Upload R script and tidy data.

Initial setup
------------------------------------
- Unzip the data files, and setwd() to the extracted folder inside R 
- Place run_analysis.R script in that folder for execution.
- Script needs latest version of SQLDF and DPLYR packages to be installed. Script provides command needed for installation

Overview of files
------------------------------------
- README.md: provides overview of the project and various components and files.
- codebook.md: Description of columns in the final tidy data.
- run_analysis.R: R script used to generate the tidy data.
- Merged_Samsung_Output.txt: tidy data.

R script outline
------------------------------------
- Script load's the files into R memory. Merges test and training data.
- extract mean() and std() values from merged data with column descriptive names.
- computes mean of mean() and std() columns based on  grouping subject and activity.
- writes output to a .txt file and provides grader with code to read it in R.

*Step-by-Step details on functioning of the script are described inside the R script.*