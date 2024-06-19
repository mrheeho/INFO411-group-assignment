library(car)
library(Metrics)
library(MASS)
Sys.setenv(LANG = "en")

# training
# 1st model, using all the attributes beside NO2, as it would provide a perfect fit
lr.train1 <- lm(Days.PM2.5 ~.-Days.NO2, data = train)
summary(lr.train1)
lr.predict1 = predict(lr.train1, newdata = test)
# Calculate RMSE
#RMSE(lr.predict1, test$Days.PM2.5)
rmse <- sqrt(mean((lr.predict1 - test$Days.PM2.5)^2))
# Print RMSE
rmse


# Tuning
# 2nd model, using only attribute with a significant p-value
lr.train2 <-stepAIC(lr.train1,direction="both")
summary(lr.train2)

lr.predict2 = predict(lr.train2, newdata = test)
# Calculate RMSE
#RMSE(lr.predict2, test$Days.PM2.5)
rmse <- sqrt(mean((lr.predict2 - test$Days.PM2.5)^2))
# Print RMSE
rmse

# 3rd model
lr.train3 =update(lr.train2, ~. -StateNew.York-StateLouisiana, data = train)
summary(lr.train3)

lr.predict3 = predict(lr.train3, newdata = test)
# Calculate RMSE
#RMSE(lr.predict3, test$Days.PM2.5)
rmse <- sqrt(mean((lr.predict3 - test$Days.PM2.5)^2))
# Print RMSE
rmse


#par(mfrow=c(2,2))
#plot(lr.train3)
# Adjust plot margins
# Adjust plot margins and increase plotting device size

# Adjust the margin sizes as needed
par(mfrow=c(2,2), mar=c(2, 2, 2, 1) + 0.1) 
# Increase plotting device size
options(repr.plot.width=10, repr.plot.height=10)  

# Create the plot
plot(lr.train3)

added_variable_plots <- avPlots(lr.train3)

for (i in seq_along(added_variable_plots)) {
  plot <- ggplot(data = added_variable_plots[[i]], aes(x = x, y = y)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) +
    labs(title = names(added_variable_plots)[i]) +
    theme_minimal()
  print(plot)
}


