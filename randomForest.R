library(randomForest)


# RF Model on Train
rf.train = randomForest(Days.PM2.5~., train, importance=TRUE)
rf.train

# Predict train set and calculate RMSE
rf.trainPred <- predict(rf.train, train)
sqrt(mean((rf.trainPred - train$Days.PM2.5)^2))

# Predict test set and calculate RMSE
rf.testPred <- predict(rf.train, test)
sqrt(mean((rf.testPred - test$Days.PM2.5)^2))


#Tuning
features <- setdiff(names(train), "Days.PM2.5")

# tuning the random forest with parameters:
tuneRF <- tuneRF(
  x          = train[features],
  y          = train$Days.PM2.5,
  ntreeTry   = 500,   # No. of trees
  mtryStart  = 1,     # Starting value of mtry
  stepFactor = 3,   # mTry step factor
  improve    = 0.05,   # Improvement to continue
  trace      = TRUE,  # Shows progress
  doBest     = TRUE,  # Returns tree with optimal mTry
)
tuneRF

# Predict train set and calculate RMSE
rfTuned.trainPred <- predict(tuneRF, train)
sqrt(mean((rfTuned.trainPred - train$Days.PM2.5)^2))

# Predict test set and calculate RMSE
rfTuned.testPred <- predict(tuneRF, test)
sqrt(mean((rfTuned.testPred - test$Days.PM2.5)^2))


# Plotting
plot(rf.train)
plot(tuneRF)