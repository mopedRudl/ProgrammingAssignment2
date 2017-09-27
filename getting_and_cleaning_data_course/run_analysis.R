library(reshape2)


#check if file exists and download it in case it doesn't
if (!file.exists("getdata_dataset.zip")){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, "getdata_dataset.zip", method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

#load activity_labels and features
act_lab = read.table("activity_labels.txt")
feat = read.table("features.txt")

#select mean and sd
feat_select = grep("(.*mean|std.*)",feat[,2])
feat_names = feat[feat_select,2]

#edit feature names
feat_names = gsub('-std','Std',feat_names)
feat_names = gsub('-mean','Mean',feat_names)
feat_names = gsub('\\(\\)-', '', feat_names)

#get test data and join it
test = read.table("test/X_test.txt")[feat_select]
test_act = read.table("test/y_test.txt")
test_sub = read.table("test/subject_test.txt")
test = cbind(test_act,test_sub,test)

#get train data and join it
train = read.table("train/X_train.txt")[feat_select]
train_act = read.table("train/y_train.txt")
train_sub = read.table("train/subject_train.txt")
train = cbind(train_act,train_sub,train)

#combine train and test data
dt = rbind(train,test)

#replace colnames
colnames(dt) <- c("activity","subject",feat_names)

#replace activity numbers with labels
dt$activity <- factor(dt$activity, levels = act_lab[,1], labels = act_lab[,2])
dt$subject <- as.factor(dt$subject)

#melt the data frame and calculate the mean and sd per group
dt_melted <- melt(dt, id = c("subject", "activity"))
dt_mean <- dcast(dt_melted, subject + activity ~ variable, mean)

#save table
write.table(dt_mean, "tidy_df.txt", row.names = FALSE, quote = FALSE)

#read table for testing reasons
test = read.table("tidy_df.txt", sep = " ", header = T)
