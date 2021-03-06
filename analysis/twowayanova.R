
#------------------------------------------------------------------------------------------------------------------
# TWO WAY ANOVA with Unequal Sample Sizes

#File name: twowayanova.R
#Description: This script takes the stations data coming from the weather underground API, makes some preprocessing 
#and cleanning to finally map the data with the telecom Italia Milano GRID.
#Author:Carolina Arias Munoz. Modified from: https://www.r-bloggers.com/r-tutorial-series-two-way-anova-with-unequal-sample-sizes/
#Date Created: 30/07/2016
#Date Last Modified: 30/07/2016
#R version: 3.3.0 (2016-05-03)
#------------------------------------------------------------------------------------------------------------------

library(car)


#---------------------------#
#Initial data exploration
#---------------------------#
#reading data
anovadata <- read.csv(your_path + 'anovadata.csv')

#seeing 10 first rows
head(anovadata, n=10)

#calls_out : outgoing calls
#callsout_out : outgoing calls without oitliers

#boxplot
boxplot(anovadata$calls_out ~ anovadata$d_type)
boxplot(anovadata$calls_out ~ anovadata$t_levels)

#side-by-side boxplots
par(mfrow = c(1,2))
plot(calls_out ~ t_levels + d_type, data = anovadata)
#Interaction plot
interaction(anovadata$t_evels, anovadata$d_type,anovadata$calls_out)

# Derive the weighted means for each treatment group: day type: workdays, weekends; temperature levels: high, medium, low
#subset (data) to filter data by each treatment group
workdays<- subset(anovadata, anovadata$d_type == 'workdays')#5'059.871
weekends<- subset(anovadata, anovadata$d_type == 'weekend')#12'271.469
high<- subset(anovadata, anovadata$t_levels == 'high')#127.845
medium<- subset(anovadata, anovadata$t_levels == 'medium')#6'951.311
low<- subset(anovadata, anovadata$t_levels == 'low')#125.636

#use mean(data) to calculate the weighted means for each treatment group
mean(workdays$calls_out)#1.521016 . more calls during the workdays
mean(weekends$calls_out)#1.101976 :less calls during the weekends
mean(high$calls_out)#1.34138
mean(medium$calls_out)#1.393334 
mean(low$calls_out)#1.388347

#---------------------------#
#ANOVA assumptions
#---------------------------#

library(stats)
library(fitdistrplus)
#1. Each group sample is drawn from a normally distributed population
plotdist(anovadata$calls_out, histo = TRUE, demp = TRUE)
qqnorm(anovadata$calls_out)

#2.All populations have a common variance
#variances
var(workdays$calls_out)#5.001374 . more calls during the workdays
var(weekends$calls_out)#4.273476 :less calls during the weekends
var(high$calls_out)#4.808997
var(medium$calls_out)#4.834485
var(low$calls_out)#4.805754

#3. Other:
#All samples are drawn independently of each other
#Within each sample, the observations are sampled randomly and independently of each other
#Factor effects are additive



#------------------------------------------------------------------------------------------------------------------------#
#ANOVA using Type I Sums of Squares and Weighted Means
#------------------------------------------------------------------------------------------------------------------------#
#use anova(object) to execute the Type I SS ANOVAs


#day type ANOVA
anova(lm(callsout_out ~ d_type * t_levels, anovadata))
#----------------------------------------------------------------
#Analysis of Variance Table

# Response: calls_out
#                         Df   Sum Sq Mean Sq   F value    Pr(>F)    
#   d_type                1   215324  215324 45004.966 < 2.2e-16 ***
#   t_levels              3      784     261    54.589 < 2.2e-16 ***
#   d_type:t_levels       3     3255    1085   226.763 < 2.2e-16 ***
#   Residuals       7331332 35076413       5                        
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#----------------------------------------------------------------

#temperature ANOVA
anova(lm(calls_out ~ t_levels * d_type , anovadata))
#----------------------------------------------------------------
#Analysis of Variance Table

# Response: calls_out
# Df   Sum Sq Mean Sq   F value    Pr(>F)    
# d_type                1   215324  215324 45004.966 < 2.2e-16 ***
#   t_levels              3      784     261    54.589 < 2.2e-16 ***
#   d_type:t_levels       3     3255    1085   226.763 < 2.2e-16 ***
#   Residuals       7331332 35076413       5                        
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#----------------------------------------------------------------

#If the null hypothesis is true, you expect F to have a value close to 1.0 most of the time.

#------------------------------------------------------------------------------------------------------------------------#
# ANOVA using Type III Sums of Squares and Unweighted Means
#------------------------------------------------------------------------------------------------------------------------#

#use mean(data) and subset(data, condition) to calculate the unweighted means for each treatment group

#workdays unweighted mean = (high.workdays mean + medium.workdays mean + low.workdays mean  )/ 3 :1.507178
(mean(subset(workdays$calls_out, workdays$t_levels == 'high')) + mean(subset(workdays$calls_out, workdays$t_levels == 'medium')) + mean(subset(workdays$calls_out, workdays$t_levels == 'low'))) / 3
#weekends unweighted mean = (high.weekends mean + medium.weekends mean + low.weekends mean  )/ 3 : 1.075166
(mean(subset(weekends$calls_out, weekends$t_levels == 'high')) + mean(subset(weekends$calls_out, weekends$t_levels == 'medium')) + mean(subset(weekends$calls_out, weekends$t_levels == 'low'))) / 3
#high unweighted mean = (workdays.high mean + weekends.high mean) / 2 :1.261896
(mean(subset(high$calls_out, high$d_type == 'workdays')) + mean(subset(high$calls_out, high$d_type == 'weekend'))) / 2
#medium unweighted mean = (workdays.medium mean + weekends.medium mean) / 2 :1.313243
(mean(subset(medium$calls_out, medium$d_type == 'workdays')) + mean(subset(medium$calls_out, medium$d_type == 'weekend'))) / 2
#low unweighted mean = (workdays.low mean + weekends.low mean) / 2 :1.298377
(mean(subset(low$calls_out, low$d_type == 'workdays')) + mean(subset(low$calls_out, low$d_type == 'weekend'))) / 2


#load the car package (install first, if necessary
library(car)
#use the Anova(mod, type) function to conduct the Type III SS ANOVA

Anova(lm(calls_out ~ t_levels * d_type , anovadata), type = "3", singular.ok = T)

#----------------------------------------------------------------
#Anova Table (Type III tests)

# Response: calls_out
#                     Sum Sq      Df  F value    Pr(>F)    
#   (Intercept)        73031       1 15264.32 < 2.2e-16 ***
#   t_levels            1574       3   109.63 < 2.2e-16 ***
#   d_type             13926       1  2910.67 < 2.2e-16 ***
#   t_levels:d_type     3255       3   226.76 < 2.2e-16 ***
#   Residuals       35076413 7331332                       
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#----------------------------------------------------------------
