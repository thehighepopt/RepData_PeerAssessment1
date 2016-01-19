PA1 <- function(directory) {
setwd(directory)
      unzip <- unzip("activity.zip")
      activity <- read.csv("activity.csv")
      activnona <- subset(activity,!is.na(activity[,1]))
}


##What is mean steps taken per day?
need<-c("dplyr") #needed packages for a job
ins<-installed.packages()[,1] #find out which packages are installed
(Get<-need[which(is.na(match(need,ins)))]) # check if the needed packages are installed
if(length(Get)>0){install.packages(Get)} #install the needed packages if they are not-installed
eval(parse(text=paste("library(",need,")")))#load the needed packages

sumstep <- summarise(group_by(activnona,date),sum(steps))

hist(as.matrix(sumstep[,2]), breaks = 8, xlab = "Counts of Steps",main = "Histogram: Total Steps")


meanmed <- cbind(summarise(group_by(activnona,date),round(mean(steps),digits = 2)),
                 summarise(group_by(activnona,date),median(steps)))

names(meanmed) <- c("Date","Mean Steps","Median Steps")

meanmed

##What is the average daily activity pattern?
meanint <- summarise(group_by(activnona,interval),round(mean(steps),2))

plot(meanint, type = "l", col = "blue", lwd = 2, xlab = "Interval", ylab = "Mean(Steps)", main = "Average Steps per Interval")

paste("Max average steps occurs in interval", meanint[which(meanint[,2] == max(meanint[,2])),1])

##Imputing missing values
sum(is.na(activity)) ##rows of NA

activ_na <- merge(activity[is.na(activity),],meanint, by = "interval")[,c(4,3,1)]
names(activ_na) <- names(activity)
activ_na_replaced <- arrange(rbind(activnona,activ_na),date,interval)

sumstep_rep <- summarise(group_by(activ_na_replaced,date),sum(steps))

hist(as.matrix(sumstep_rep[,2]), breaks = 8, xlab = "Counts of Steps",main = "Histogram: Total Steps")


meanmed_rep <- cbind(summarise(group_by(activ_na_replaced,date),round(mean(steps),digits = 2)),
                 summarise(group_by(activ_na_replaced,date),median(steps))[,2])

names(meanmed_rep) <- c("Date","Mean Steps","Median Steps")

meanmed_rep



