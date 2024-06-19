library(party)
library(tree)
library(rpart)
#install.packages("Metrics")
library(Metrics)

#Creating the Decision Tree Model
tree = rpart(Days.PM2.5 ~ ., data=train, method ="anova")
tree

tree.pred = predict(tree, train, method = "anova")
#RMSE of the train prediction
sqrt(mean((tree.pred - train$Days.PM2.5)^2))

tree.pred = predict(tree, test, method = "anova")
#RMSE of the test prediction
sqrt(mean((tree.pred - test$Days.PM2.5)^2))

#Tuning the Decision Tree Model 
control <- rpart.control(minsplit = 4, 
                         minbucket = round(5 / 3),
                         maxdepth = 16,
                         cp = 0)

#Fitting of tuned model
tune_fit <- rpart(Days.PM2.5~., data = train, method = 'anova', control = control)

#Predicting the model after tuning
#train
tune.pred = predict(tune_fit, train, method = "anova")
sqrt(mean((tune.pred - train$Days.PM2.5)^2))

#test
tune.pred = predict(tune_fit, test, method = "anova")
sqrt(mean((tune.pred - test$Days.PM2.5)^2))

