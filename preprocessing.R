library(kohonen)
library(dummies)
library(ggplot2)
library(sp)
library(maptools)
library(reshape2)
library(rgeos)
library(dplyr)
#install.packages("hutilscpp")
library(hutilscpp)
library(rsample)


# Colour palette definition
pretty_palette <- c("#1f77b4", '#ff7f0e', '#2ca02c', '#d62728',
                    '#9467bd', '#8c564b', '#e377c2')

# ==== Pre-processing ====
data <- read.csv('annual_aqi_by_county_2020.csv')

# Summary of the dataset
str(data)

'
# Summary
clean.data %>%
  select(Days.with.AQI) %>%
  summary()
'

# Get percentage of good / bad days
clean.data <- data
clean.data$percent_good <- (clean.data$Good.Days + clean.data$Moderate.Days) / clean.data$Days.with.AQI
clean.data$percent_bad <- (clean.data$Unhealthy.for.Sensitive.Groups.Days + clean.data$Unhealthy.Days + 
                             clean.data$Very.Unhealthy.Days + clean.data$Hazardous.Days) / 
                            clean.data$Days.with.AQI

# States with more bad days than good
bad_percent_data = clean.data%>% filter(clean.data$percent_good < clean.data$percent_bad)
bad_percent_data_short = (clean.data%>% filter(clean.data$percent_good < clean.data$percent_bad))[c(1,19,20)]
boxplot(bad_percent_data$Median.AQI, horizontal = TRUE, xlab = 'median.AQI')
boxplot(bad_percent_data$Max.AQI, horizontal = TRUE, xlab = 'max.AQI')

# Remove Country and Year after identifying baseline for "bad" AQI 
clean.data = data[-c(2,3)]


# Label Encoding for State
clean.data$State <- as.integer(factor(clean.data$State))


# Replacing outliers with 5% and 95% of interquartile range
hist(clean.data$Median.AQI, main = "Histogram")
median.AQI.quantile <- quantile(clean.data$Median.AQI,c(.05,0.95))
clean.data$Median.AQI <- squish(clean.data$Median.AQI, as.integer(median.AQI.quantile[1]), as.integer(median.AQI.quantile[2]))
hist(clean.data$Median.AQI, main = "Histogram")

hist(clean.data$X90th.Percentile.AQI, main = "Histogram")
X90th.Percentile.AQI.quantile <- quantile(clean.data$X90th.Percentile.AQI,c(.05,0.95))
clean.data$X90th.Percentile.AQI <- squish(clean.data$X90th.Percentile.AQI,as.integer(X90th.Percentile.AQI.quantile[1]), 
                                          as.integer(X90th.Percentile.AQI.quantile[2]))
hist(clean.data$X90th.Percentile.AQI, main = "Histogram")

hist(clean.data$Max.AQI, main = "Histogram")
Max.AQI.quantile <- quantile(clean.data$Max.AQI,c(.05,0.95))
clean.data$Max.AQI <- squish(clean.data$Max.AQI,as.integer(Max.AQI.quantile[1]), as.integer(Max.AQI.quantile[2]))
hist(clean.data$Max.AQI, main = "Histogram")


# Correlation in descending order
corrTable <- abs(cor(clean.data, y=clean.data$Days.PM2.5))
corrTable <- corrTable[order(corrTable, decreasing=TRUE),, drop=FALSE]


# Split into 80:20 for training and testing
# Set seed for reproducibility
set.seed(123)

# Generate a vector of indices corresponding to the rows of your dataset
indices <- sample(1:nrow(clean.data), size = nrow(clean.data), replace = FALSE)

# Calculate the number of rows for the training set (80%)
train_size <- round(0.8 * nrow(clean.data))

# Select the indices corresponding to the training set
train_indices <- indices[1:train_size]

# Select the indices corresponding to the testing set
test_indices <- indices[(train_size + 1):nrow(clean.data)]

# Create the training and testing datasets
train <- clean.data[train_indices, ]
test <- clean.data[test_indices, ]

