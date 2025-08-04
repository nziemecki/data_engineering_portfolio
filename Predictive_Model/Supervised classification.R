wd=("/Users/tup93308/Desktop/ML_term_proj")
setwd(wd)

library(terra)
library(sf)
library(ggplot2)
library(DataExplorer)
library(randomForest)
library(xgboost)
library(rpart)
library(rattle)
library(pdp)
library(iml)
library(raster)

# Loading data
pointdata <- read.csv("pointdata.csv")  # Adjust the file path if needed
colnames(pointdata)[ncol(pointdata)] <- "response"

datastack <- rast("datastack_b.tif")

#Check pointdata
head(pointdata)

#Check for missing data
if (sum(is.na(pointdata)) > 0) {
  pointdata = subset(pointdata, complete.cases(pointdata))
}

#Identify duplicates
dups = duplicated(pointdata)
pointdata[dups, ]  # Check duplicates

#Converting the "canopycover" column to numeric
datastack$Canopy.Cover <- as.numeric(datastack$Canopy.Cover)
colnames(pointdata)[colnames(pointdata) == "Canopy Cover"] <- "Canopy.Cover"

pointdata$Canopy.Cover<- as.numeric(pointdata$Canopy.Cover)
  
#Make response variable a factor (presence/absence)
pointdata$response <- as.factor(pointdata$response)

#LandCover2021 as factor
pointdata$LandCover2021 <- as.factor(pointdata$LandCover2021)

#-------------------------------------------------------------------------------

#RANDOM FOREST

#Split data (CHANGE TO K-1)
set.seed(42)
train_index <- sample(1:nrow(pointdata), 0.7 * nrow(pointdata))
train_data <- pointdata[train_index, ]
test_data <- pointdata[-train_index, ]

#defining columns to use(include response) (TRY INCLUDING X, Y)
feature_columns <- names(pointdata)[c(3:9, 14)]  # Adjust indices as needed

#Subset train and test data
train_data_subset <- train_data[, c("response", feature_columns)]
test_data_subset <- test_data[, c("response", feature_columns)]

#na omit
train_data_subset <- na.omit(train_data_subset)

# Train the Random Forest model using only the selected feature columns
rf_model <- randomForest(
  response ~ .,               
  data = train_data_subset,
  ntree = 860,         # Match trees
  mtry = 7,            # Match mtry
  nodesize = 6,        # Match min_n (via nodesize)
  importance = TRUE
)

#Model summary
print(rf_model)
varImpPlot(rf_model)

#Predict presence probability

#make it numeric
#LandCover2021 as factor
valid_categories <- levels(pointdata$LandCover2021)
# Create a reclassification matrix
reclassify_matrix <- matrix(c(
  0, 0, 11  # Map 0 to 11
), ncol = 3, byrow = TRUE)

# Apply reclassification
datastack$LandCover2021 <- classify(datastack$LandCover2021, reclassify_matrix, others = "include")

datastack$LandCover2021 <- as.factor(datastack$LandCover2021)

datastack <- subset(datastack, feature_columns)

predicted=terra::predict(datastack, rf_model, type="prob")

plot(predicted)

#Save raster
writeRaster(predicted, filename="rf_predict.tif", filetype="GTiff", overwrite=TRUE)


# Predict probabilities
test_predictions <- predict(rf_model, test_data_subset, type = "prob")

# Predict the class
test_predicted_classes <- predict(rf_model, test_data_subset, type = "response")
accuracy <- sum(test_predicted_classes == test_data_subset$response) / nrow(test_data_subset)
print(paste("Accuracy:", round(accuracy * 100, 2), "%"))
#-------------------------------------------------------------------------------





plot_columns <- names(pointdata)[c(6:9, 14)]
plot_ds_sub <- subset(datastack, plot_columns)


library(pdp)
# Partial dependence plot for a single feature
pdp_result <- partial(rf_model, pred.var = "feature_name", train = train_data_subset)
plot(pdp_result)

#XGBOOST
# Load necessary libraries
library(xgboost)
library(Matrix)
library(caret)
library(terra)

# Set seed for reproducibility
set.seed(42)

# Specify the predictor variables (replace with your actual column names)
predictor_columns <-  names(pointdata)[c(3:9, 14)] # Replace with actual predictor names
response_column <- "response"  # Replace with the actual response column name

# Split the dataset into training and testing sets
train_index <- sample(1:nrow(pointdata), 0.7 * nrow(pointdata))
train_data <- pointdata[train_index, c(predictor_columns, response_column)]
test_data <- pointdata[-train_index, c(predictor_columns, response_column)]

# Ensure response is numeric (0 and 1)
train_data[[response_column]] <- as.numeric(as.character(train_data[[response_column]]))  # Convert factor to numeric
test_data[[response_column]] <- as.numeric(as.character(test_data[[response_column]]))    # Convert factor to numeric

# Prepare training and testing data as sparse matrices
train_matrix <- sparse.model.matrix(as.formula(paste(response_column, "~ . - 1")), 
                                    data = train_data[, c(response_column, predictor_columns), drop = FALSE])
test_matrix <- sparse.model.matrix(as.formula(paste(response_column, "~ . - 1")), 
                                   data = test_data[, c(response_column, predictor_columns), drop = FALSE])

# Create DMatrix for XGBoost
dtrain <- xgb.DMatrix(data = train_matrix, label = train_data[[response_column]])
dtest <- xgb.DMatrix(data = test_matrix, label = test_data[[response_column]])

# Set XGBoost parameters
params <- list(
  objective = "binary:logistic", # Binary classification
  eta = 1.94,                   # Learning rate
  max_depth = 9,                # Tree depth
  colsample_bytree = 0.782,     # Feature subset for trees
  gamma = 1.65,                 # Minimum loss reduction
  subsample = 0.782             # Sample size for rows
)

# Train the XGBoost model
bst <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 344,                # Number of boosting rounds
  watchlist = list(train = dtrain, test = dtest),  # Monitor performance on train and test sets
  eval.metric = "error",        # Track classification error
  eval.metric = "logloss"       # Track log loss
)

# Predict probabilities on the test set
pred_prob <- predict(bst, test_matrix)

# Convert probabilities to binary predictions
pred_class <- as.numeric(pred_prob > 0.5)

# Calculate accuracy
accuracy <- mean(pred_class == test_data[[response_column]])
print(paste("Accuracy:", round(accuracy * 100, 2), "%"))

# Feature importance
importance_matrix <- xgb.importance(model = bst)
print(importance_matrix)

# Plot feature importance
xgb.plot.importance(importance_matrix)

# Save the trained model
xgb.save(bst, "xgboost_model.bin")

ds_columns <-  names(pointdata)[c(3:9, 14)]
datastack_subset <- datastack[[ds_columns]]

datastack_matrix <- as.matrix(datastack_subset)
datastack_matrix <- na.omit(datastack_matrix)

xgbpred <- predict(bst, datastack_matrix)

xgRast <- sum(datastack_subset)

stopifnot(length(which(!is.na(values(xgRast)))) == length(xgbpred))

values(xgRast)[!is.na(values(xgRast))] <- xgbpred
plot(xgRast, main = "XGBoost Prediction")

writeRaster(xgRast, "xgbpred.tif", overwrite = TRUE)
