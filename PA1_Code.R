setwd()
unzip <- unzip("activity.zip")
activity <- read.csv("activity.csv")
activ_no_na <- subset(activity,!is.na(activity[,1]))


##What is mean steps taken per day?
need<-c("dplyr","ggplot2") #needed packages for a job
ins<-installed.packages()[,1] #find out which packages are installed
(Get<-need[which(is.na(match(need,ins)))]) # check if the needed packages are installed
if(length(Get)>0){install.packages(Get)} #install the needed packages if they are not-installed
eval(parse(text=paste("library(",need,")")))#load the needed packages
rm(need,Get)

library(dplyr)
sumstep <- summarise(group_by(activ_no_na,date),sum(steps))

hist(as.matrix(sumstep[,2]), breaks = 8, xlab = "Counts of Steps",main = "Histogram: Total Steps")


meanmed <- merge(summarise(group_by(activ_no_na,date),round(mean(steps),digits = 2)),
                 summarise(group_by(activ_no_na,date),median(steps)))
names(meanmed) <- c("Date","Mean Steps","Median Steps")
meanmed

##What is the average daily activity pattern?
meanint <- summarise(group_by(activ_no_na,interval),round(mean(steps),2))

plot(meanint, type = "l", col = "blue", lwd = 2, xlab = "Interval", ylab = "Mean(Steps)", main = "Average Steps per Interval")

paste("Max average steps occurs in interval", meanint[which(meanint[,2] == max(meanint[,2])),1])

##Imputing missing values
sum(is.na(activity)) ##rows of NA

##Capture interval avgs from meanint and replace the NA values, then combine with No NA sheet
activ_na <- merge(activity[is.na(activity),],meanint, by = "interval")[,c(4,3,1)]
names(activ_na) <- names(activity) ##update names to facilitate rbind
activ_na_replaced <- arrange(rbind(activ_no_na,activ_na),date,interval)

sumstep_rep <- summarise(group_by(activ_na_replaced,date),sum(steps))

##Histogram and table for new activity with replaced values
hist(as.matrix(sumstep_rep[,2]), breaks = 8, xlab = "Counts of Steps",main = "Histogram: Total Steps")


meanmed_rep <- cbind(summarise(group_by(activ_na_replaced,date),round(mean(steps),digits = 2)),
                 summarise(group_by(activ_na_replaced,date),median(steps))[,2])

names(meanmed_rep) <- c("Date","Mean Steps Rep","Median Steps Rep")

meanmed_compared <- merge(meanmed,meanmed_rep,by = "Date", all.y = TRUE)

##Are there differences in activity patterns between weekdays and weekends?
activ_na_replaced$Day_type <-  weekdays(as.Date(activ_na_replaced[,2]))

activ_na_replaced[,4] <- sapply(activ_na_replaced[,4], switch, 
                  Saturday = 'Weekend', 
                  Sunday = 'Weekend', 
                  Monday = 'Weekday', 
                  Tuesday = 'Weekday',
                  Wednesday = 'Weekday',
                  Thursday = 'Weekday',
                  Friday = 'Weekday')

g <- as.data.frame(tapply(activ_na_replaced$steps,activ_na_replaced[,3:4] ,mean))
g$interval <- rownames(g)

qplot(interval, steps, data = activ_na_replaced, facets = Day_type ~ ., geom =
        c("line"), xlab = "Interval", ylab = "Number of Steps", main = "Avg Steps by Interval: Weekend v Weekday")


