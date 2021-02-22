#FINAL PROJECT
#Curtis Stone

##################################################################
#Time Series analysis on the overall US unemployment data series
#install.packages("corrplot")
#install.packages("Hmisc")
#Load in required packages
library(ggplot2)
library(GGally)
library(klaR)
library(MASS)
library(fpp2)
library(ISLR)
library(lattice)
library(caret)
library(DAAG)
library("rpart")
library(leaps)
library("readxl")
library(corrplot)
library("Hmisc")

#Create the dataset
setwd("C:/Users/spost/Desktop/Baypath/Capstone/Final Files")

#Complete Dataset
#usunemploy <- read.csv("US_Unemployment_Rate.csv")
usunemploy <- read_excel("US_Unemployment_Rate2000-2019.xlsx")

#usunemploy2020 <-read.csv("US_Unemployment_Rate.csv")
usunemploy2020 <- read_excel("US_Unemployment_Rate2000-2019.xlsx")

#Create time series data from complete data. This includes everything
ts.usue2020 <- ts(data=usunemploy2020$Unemployment.Percent, frequency = 12,
                  start=c(2000,1), end=c(2019,12))
#Create a test window
used2020 <- window(ts.usue2020, c(2019,5))


#Create test time series data
ts.usue <- ts(data=usunemploy$Unemployment.Percent, frequency = 12,
              start=c(2000,1), end=c(2019,5))


#Data Exploration
autoplot(ts.usue)+
  ggtitle("US Unemployment Rates")
ggtsdisplay(ts.usue)
checkresiduals(ts.usue)

#Seasonal exploration
ggseasonplot(ts.usue)
ggseasonplot(ts.usue, polar=T)


#Subseries plots
ggsubseriesplot(ts.usue)

#Lag plot
gglagplot(ts.usue)

#Decomposition
ts.usue %>% decompose(type="multiplicative") %>%
  autoplot()

########################################################
#Begin forecasting methods for comparison. 
#########################################################
#Most basic first
#This is using only the basic forecast function built in to R
ts.fc1 <- forecast(ts.usue, h=24)
autoplot(ts.fc1)+
  coord_cartesian(xlim = c(2000,2022))
checkresiduals(ts.fc1)
accuracy(ts.fc1, used2020)

autoplot(ts.fc1)+
  autolayer(ts.usue2020) +
  coord_cartesian(xlim = c(2018,2021))


################################################################
#Apply drift, mean, and naive methods. And zoom.
autoplot(ts.usue) +
  autolayer(meanf(ts.usue, h=24),
            series="Mean", PI=FALSE) +
  autolayer(rwf(ts.usue, h=24),
            series="Naïve", PI=FALSE) +
  autolayer(rwf(ts.usue, drift=TRUE, h=24),
            series="Drift", PI=FALSE)+
  ggtitle("Drift, Mean, and Naive Methods") +
  coord_cartesian(xlim = c(2010,2022))

checkresiduals(meanf(ts.usue, h=24))
checkresiduals(rwf(ts.usue, h=24))
checkresiduals(rwf(ts.usue, drift=TRUE, h=24))


accuracy(meanf(ts.usue, h=24), used2020)
accuracy(rwf(ts.usue, h=24), used2020)
accuracy(rwf(ts.usue, drift=TRUE, h=24), used2020)
################################################################

################################################################
#Forecasts using bias-adjusted methods
fc <- rwf(ts.usue, drift=TRUE, lambda=0, h=24)
fc2 <- rwf(ts.usue, drift=TRUE, lambda=0, h=24, biasadj=TRUE)
autoplot(ts.usue) +
  autolayer(fc, series="Simple back transformation") +
  autolayer(fc2, series="Bias adjusted", PI=FALSE) +
  guides(colour=guide_legend(title="Forecast"))+
  coord_cartesian(xlim = c(2000,2022))+
  ggtitle("Bias Adjusted")

fc7 <- rwf(ts.usue, drift=TRUE, lambda=0, h=7)
fc27 <- rwf(ts.usue, drift=TRUE, lambda=0, h=7, biasadj=TRUE)

checkresiduals(fc7)
checkresiduals(fc27)
accuracy(fc7, used2020)
accuracy(fc27, used2020)


#See if a Box-Cox would be any use here
lambda.final <- BoxCox.lambda(ts.usue)
usue_Box <- BoxCox(ts.usue, lambda = lambda.final)
autoplot(usue_Box)+
  ggtitle("Box-Cox Transformation")
#This transformation is not useful because any variation is not consistently getting larger or smaller.

#Other spline
h <- 24
spline.usue <- splinef(ts.usue, lambda=0, h=h)
ts.usue %>% splinef(lambda = 0) %>% autoplot()
autoplot(spline.usue)+ ggtitle("Auto Splines")
autoplot(spline.usue)+ ggtitle("Auto Splines Zoomed") + coord_cartesian(xlim = c(2015,2022), ylim = c(0,.25))
checkresiduals(spline.usue)
accuracy(spline.usue, used2020)

autoplot(spline.usue) +
  autolayer(used2020)+
  ggtitle("Splines with Real") + coord_cartesian(ylim = c(0,.25))

###############################################################
#Moving average analysis
autoplot(ts.usue, series="Data") +
  autolayer(ma(ts.usue, 12), series="12-MA") +
  xlab("Year") + ylab("US Unemployment %") +
  ggtitle("US Unemployment") +
  scale_colour_manual(values=c("Data"="grey","12-MA"="red"),
                      breaks=c("Data","12-MA"))




ts.usue %>% decompose(type="multiplicative") %>%
  autoplot() + xlab("Year") +
  ggtitle("US Unemployment")


##################################################################
#Holt Analysis
fc.holt <- holt(ts.usue, h=150)
fc2.holt <- holt(ts.usue, damped=TRUE, phi = 0.9, h=150)
autoplot(ts.usue) +
  autolayer(fc.holt, series="Holt's method", PI=FALSE) +
  autolayer(fc2.holt, series="Damped Holt's method", PI=FALSE) +
  ggtitle("Forecasts from Holt's method") + xlab("Year") +
  guides(colour=guide_legend(title="Forecast"))




fc.ets <- forecast(ets(ts.usue), h=24)

autoplot(ets(ts.usue))
autoplot(fc.ets) +
  autolayer(used2020)

autoplot(fc.ets)

#############################################################
#Starting the ARIMA modeling
#Check for necessary transformations
ndiffs(ts.usue)
nsdiffs(ts.usue)

#The data needs to be differenced twice, but does not show signs of seasonality
usuedif <- diff(ts.usue)

#Plot the new data
autoplot(usuedif) + ggtitle("Differenced Data")

#The histogram here looks pretty good actually
checkresiduals(usuedif)

#ACF and PACF both show strong correlations up to 4
ggtsdisplay(usuedif)

autoarima2 <- auto.arima(ts.usue)
best.arima <- auto.arima(ts.usue, stepwise = F, approximation = F)

autoarima2
checkresiduals(autoarima2)
best.arima
checkresiduals(best.arima)

forecast(best.arima)

accuracy(forecast(best.arima),used2020)

autoplot(forecast(best.arima, h=24)) +
  autolayer(ts.usue2020)+ coord_cartesian(xlim = c(2000,2022))

autoplot(forecast(best.arima, h=48)) +
  autolayer(ts.usue2020)+ coord_cartesian(xlim = c(2000,2022), ylim=c(0.005,.13))


#######################################################
#Industry Analysis
#######################################################
#Create the dataset
setwd("C:/Users/spost/Desktop/Baypath/Capstone/2000-2019/Final Data")

#All these are the individual time series
indus <- read_excel("Industry2000-2019.xlsx")

indus.ni <- ts(data=indus$`Nonagriculture Industries`, frequency = 12,
               start=c(2000,1), end=c(2019,12))

indus.mine <- ts(data=indus$`Mining, quarrying, and oil and gas extraction`, frequency = 12,
                 start=c(2000,1), end=c(2019,12))

indus.cons <- ts(data=indus$Construction, frequency = 12,
                 start=c(2000,1), end=c(2019,12))

indus.man <- ts(data=indus$Manufacturing, frequency = 12,
                start=c(2000,1), end=c(2019,12))

indus.dur <- ts(data=indus$`Durable Goods Manufacturing`, frequency = 12,
                start=c(2000,1), end=c(2019,12))

indus.ndur <- ts(data=indus$`Nondurable Goods Manufacturing`, frequency = 12,
                 start=c(2000,1), end=c(2019,12))

indus.retail <- ts(data=indus$`Wholesale and retail trade`, frequency = 12,
                   start=c(2000,1), end=c(2019,12))

indus.trans <- ts(data=indus$`Transportation and Utilities`, frequency = 12,
                  start=c(2000,1), end=c(2019,12))

indus.info <- ts(data=indus$Information, frequency = 12,
                 start=c(2000,1), end=c(2019,12))

indus.fin <- ts(data=indus$`Financial Activities`, frequency = 12,
                start=c(2000,1), end=c(2019,12))

indus.busi <- ts(data=indus$`Professional and Business Services`, frequency = 12,
                 start=c(2000,1), end=c(2019,12))

indus.edu <- ts(data=indus$`Education and Health Services`, frequency = 12,
                start=c(2000,1), end=c(2019,12))

indus.leis <- ts(data=indus$`Leisure and Hospitality`, frequency = 12,
                 start=c(2000,1), end=c(2019,12))

indus.other <- ts(data=indus$`Other Services`, frequency = 12,
                  start=c(2000,1), end=c(2019,12))

indus.agr <- ts(data=indus$`Agriculture, forestry, fishing, and hunting`, frequency = 12,
                start=c(2000,1), end=c(2019,12))

indus.gov <- ts(data=indus$`Government Wage and Salary Workers`, frequency = 12,
                start=c(2000,1), end=c(2019,12))

indus.self <- ts(data=indus$`Self-employed unincorporated, and unpaid family workers`, frequency = 12,
                 start=c(2000,1), end=c(2019,12))
#End of the time series data creation

#Here we see each dataset broken out

indus.ni %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Nonagriculture Industries")

ggseasonplot(indus.ni)

ndiffs(indus.ni)
nsdiffs(indus.ni)
###################

indus.mine %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Mining, quarrying, and oil and gas extraction")

ggseasonplot(indus.mine)

ndiffs(indus.mine)
nsdiffs(indus.mine)
###################


indus.cons %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Construction")
ggseasonplot(indus.cons)

ndiffs(indus.cons)
nsdiffs(indus.cons)
###################

indus.man %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Manufacturing")
ggseasonplot(indus.man)

ndiffs(indus.man)
nsdiffs(indus.man)
###################


indus.dur %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Durable Goods Manufacturing")
ggseasonplot(indus.dur)

ndiffs(indus.dur)
nsdiffs(indus.dur)
###################


indus.ndur %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Nondurable Goods Manufacturing")
ggseasonplot(indus.ndur)

ndiffs(indus.ndur)
nsdiffs(indus.ndur)
###################


indus.retail %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Wholesale and retail trade")
ggseasonplot(indus.retail)

ndiffs(indus.retail)
nsdiffs(indus.retail)
###################


indus.trans %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Transportation and Utilities")
ggseasonplot(indus.trans)

ndiffs(indus.trans)
nsdiffs(indus.trans)
###################


indus.info %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Information")
ggseasonplot(indus.info)

ndiffs(indus.info)
nsdiffs(indus.info)
###################


indus.fin %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Financial Activities")
ggseasonplot(indus.fin)

ndiffs(indus.fin)
nsdiffs(indus.fin)
###################


indus.busi %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Professional and Business Services")
ggseasonplot(indus.busi)

ndiffs(indus.busi)
nsdiffs(indus.busi)
###################


indus.edu %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Education and Health Services")
ggseasonplot(indus.edu)

ndiffs(indus.edu)
nsdiffs(indus.edu)
###################


indus.leis %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Leisure and Hospitality")
ggseasonplot(indus.leis)

ndiffs(indus.leis)
nsdiffs(indus.leis)
###################


indus.other %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Other Services")
ggseasonplot(indus.other)

ndiffs(indus.other)
nsdiffs(indus.other)
###################


indus.agr %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Agriculture, forestry, fishing, and hunting")
ggseasonplot(indus.agr)

ndiffs(indus.agr)
nsdiffs(indus.agr)
###################

indus.gov %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Government Wage and Salary Workers")
ggseasonplot(indus.gov)

ndiffs(indus.gov)
nsdiffs(indus.gov)
###################


indus.self %>% decompose(type="multiplicative") %>%
  autoplot()+ggtitle("Self-employed unincorporated, and unpaid family workers")
ggseasonplot(indus.self)

ndiffs(indus.self)
nsdiffs(indus.self)
###################


#####################################################################
#Industry Cluster
#####################################################################

setwd("C:/Users/spost/Desktop/Baypath/Capstone/Final Files")

indus <- read.csv("Industry2000-2019R.csv", row.names=1, head=TRUE)

d <- dist(as.matrix(indus))
hc <- hclust(d, method = "ave")

par(mfrow = c(1,1))


plot(hc, hang = -1)

# Ward Hierarchical Clustering
d <- dist(indus, method = "euclidean") # distance matrix
fit <- hclust(d, method="ward.D")
plot(fit) # display dendogram
groups <- cutree(fit, k=4) # cut tree into 4 clusters
# draw dendogram with red borders around the 4 clusters
rect.hclust(fit, k=4, border="red")



#####################################################################
#State Cluster
#####################################################################
setwd("C:/Users/spost/Desktop/Baypath/Capstone/Final Files")

mom <- read.csv("States MoM for R.csv", row.names=1, head=TRUE)

d <- dist(as.matrix(mom))
hc <- hclust(d, method = "ave")

par(mfrow = c(1,1))


plot(hc, hang = -1)

# Ward Hierarchical Clustering
d <- dist(mom, method = "euclidean") # distance matrix
fit <- hclust(d, method="ward.D")
plot(fit) # display dendogram
groups <- cutree(fit, k=5) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters
rect.hclust(fit, k=5, border="red")

#####################################################################
#Correlation Coefficients Across All Data
#####################################################################
#This finds the correlation coefficient only and creates an output.
setwd("C:/Users/spost/Desktop/Baypath/Capstone/Final Files")

master <- read.csv("MasterMonthOverMonthData2000-2019.csv")
master <- data.frame(master)
res2 <- rcorr(as.matrix(master[2:72]))

options(max.print = 3333)

# Extract the correlation coefficients
res2$r

write.csv(res2$r,"C:/Users/spost/Desktop/Baypath/Capstone/Final Files/MasterCorrelation.csv", row.names = TRUE)


#####################################################################
#Correlation Plots Across All Data and subsets of data
#####################################################################
M1 <- cor(master[2:72])
M1_test <- M1
diag(M1_test) <-0

corrplot(M1_test, method = "circle")

#States and industry
corrplot(M1_test[1:54,55:71])

#States
corrplot(M1_test[1:54,1:54])

#Industry
M2 <- cbind(indus,US,sp)
M2 <- cor(M2)
diag(M2) <-0
corrplot(M2)
#####################################################################
#PCA Analysis Across All Data
#####################################################################
#For all month over month data
setwd("C:/Users/spost/Desktop/Baypath/Capstone/Final Files")

master <- read.csv("MasterMonthOverMonthData2000-2019.csv")

master <- master[2:72]

master <- data.matrix(master)
master <- master
master<- scale(master)

dim(master)

#PCA Analysis
pc_ex1 <- princomp(master)
plot(pc_ex1)

names(pc_ex1)
pc_ex1$loadings[,1:3]
biplot(pc_ex1)

summary(pc_ex1)

#####################################################################
#PCA For States
#####################################################################

#For all month over month data
setwd("C:/Users/spost/Desktop/Baypath/Capstone/Final Files")

s.master <- read.csv("MasterMonthOverMonthData2000-2019.csv")

s.master <- s.master[4:55]

s.master <- data.matrix(s.master)

s.master<- scale(s.master)

dim(s.master)

#PCA Analysis
pc_state <- princomp(s.master)
plot(pc_state)

names(pc_state)
pc_state$loadings[,1:3]
biplot(pc_state)

summary(pc_state)

#####################################################################
#PCA For Industry
#####################################################################

i.master <- read.csv("MasterMonthOverMonthData2000-2019.csv")

i.master <- i.master[56:72]

i.master <- data.matrix(i.master)

i.master<- scale(i.master)

dim(i.master)

#PCA Analysis
pc_indus <- princomp(i.master)
plot(pc_indus)

names(pc_indus)
pc_indus$loadings[,1:3]
biplot(pc_indus)

summary(pc_indus)

#####################################################################
#PCA For Region
#####################################################################
reg.master <- read.csv("MasterMonthOverMonthData2000-2019.csv")

reg.master <- reg.master[73:77]

reg.master <- data.matrix(reg.master)

reg.master<- scale(reg.master)

dim(reg.master)

#PCA Analysis
pc_reg <- princomp(reg.master)
plot(pc_reg)

names(pc_reg)
pc_reg$loadings[,1:3]
biplot(pc_reg)

summary(pc_reg)

#####################################################################
#Correlation Coefficients Region and Industry
#####################################################################
#This finds the correlation coefficient only and creates an output.
setwd("C:/Users/spost/Desktop/Baypath/Capstone/Final Files")
ri.master <- read.csv("MasterMonthOverMonthData2000-2019.csv")

ri.master <- data.frame(ri.master)
res2 <- rcorr(as.matrix(ri.master[56:77]))

options(max.print = 3333)

# Extract the correlation coefficients
res2$r

write.csv(res2$r,"C:/Users/spost/Desktop/Baypath/Capstone/Final Files/MasterCorrelationRI.csv", row.names = TRUE)



M2 <- cor(ri.master[56:77])

corrplot(M2, method = "circle")


#####################################################################
#PCA revisited for Region and Industry combined
#####################################################################
regi.master <- read.csv("MasterMonthOverMonthData2000-2019.csv")

regi.master <- regi.master[56:77]

regi.master <- data.matrix(regi.master)

regi.master<- scale(regi.master)

dim(regi.master)

#PCA Analysis
pc_regi <- princomp(regi.master)
plot(pc_regi)

names(pc_regi)
pc_regi$loadings[,1:3]
biplot(pc_regi)

summary(pc_regi)


#####################################################################
#Heat Maps
#####################################################################
master <- read.csv("MasterMonthOverMonthData2000-2019.csv")
master <- data.frame(master)
indus <- master[56:72]
state <- master[4:55]
US <- master[2]
sp <- master[3]
region <- master[73:77]


#State Heat map
heatState <- cor(master[2:55])
heatmap.2(heatState)

#Industry heat map
i.sp.us <- cbind(indus,US,sp)
heatIndus <- cor(i.sp.us)
heatmap.2(heatIndus)

#Massive heat map
all <- cor(master[2:77])
heatmap.2(all)

#Indus and Region Heatmap
i.r.us.sp <- cbind(indus,region, US, sp)
heatIRUSSP <- cor(i.r.us.sp)
heatmap.2(heatIRUSSP)







