wd=("/Users/tup93308/Desktop/ML_term_proj")
setwd(wd)

library(tidymodels)
library(tune)
library(dials)
library(workflows)
library(parsnip)
library(rsample)
library(recipes)
library(yardstick)
library(ranger)
library(terra)

pointdata <- read.csv("pointdata.csv")  # Adjust the file path if needed
colnames(pointdata)[ncol(pointdata)] <- "response"

datastack <- rast("datastack_b.tif")


pointdata$LandCover2021 <- as.factor(pointdata$LandCover2021)
pointdata$Canopy.Cover <- as.numeric(pointdata$Canopy.Cover)
pointdata$response <- as.factor(pointdata$response) 

#Make a pointdataset with desired predictors
desired_predictors <- c("Aspect", "Roughness", "Slope", "Elevation", "Precipitation", "TDMean", "TMean", "Canopy.Cover")

# Subset data to include only desired predictors and response
pointdata <- pointdata[, c(desired_predictors, "response")]


#training and testing split:

set.seed(42)
data_split <- initial_split(pointdata, prop = 0.7)
train_data <- training(data_split)
test_data <- testing(data_split)

#define recipe for pre-processing
recipe_bird <- recipe(response ~ ., data = train_data) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_naomit(all_predictors())

# 4.1 Random Forest
rf_spec <- rand_forest(
  mtry = tune(),        
  min_n = tune(),       
  trees = tune()
) %>%
  set_mode("classification") %>%
  set_engine("randomForest")

# 4.2 Extreme Gradient Boosting
xgb_spec <- boost_tree(
  trees = tune(),
  tree_depth = tune(),
  learn_rate = tune(),
  loss_reduction = tune(),
  sample_size = tune(),
  mtry = tune()
) %>%
  set_mode("classification") %>%
  set_engine("xgboost")

# 4.3 neural-network
nn_spec <- mlp(
  hidden_units = tune(),
  penalty = tune(),
  epochs = tune()
) %>%
  set_mode("classification") %>%
  set_engine("nnet")

# 5. Create Workflows
rf_workflow <- workflow() %>%
  add_model(rf_spec) %>%
  add_recipe(recipe_bird)

xgb_workflow <- workflow() %>%
  add_model(xgb_spec) %>%
  add_recipe(recipe_bird)

nn_workflow <- workflow() %>%
  add_model(nn_spec) %>%
  add_recipe(recipe_bird)

# 6. Set Up K-Fold Cross-Validation
set.seed(42)
cv_folds <- vfold_cv(train_data, v = 5)

# 7. Define Tuning Grids
rf_grid <- grid_random(
  mtry(range = c(1, length(desired_predictors))),
  min_n(range = c(5, 15)),
  trees(range = c(100, 1000)),
  size = 20
)

xgb_grid <- grid_random(
  mtry(range = c(1, length(desired_predictors))),
  trees(range = c(50, 500)),
  tree_depth(range = c(1, 10)),
  learn_rate(range = c(0.01, 0.3)),
  loss_reduction(range = c(0.01, 10)),
  sample_prop(range = c(0.5, 1)),
  size = 20
)

nn_grid <- grid_random(
  hidden_units(range = c(5, 50)),
  penalty(range = c(0, 0.1)),
  epochs(range = c(10, 200)),
  size = 20
)

# 8. Tune Models Using Cross-Validation
set.seed(42)
rf_tuned <- tune_grid(
  rf_workflow,
  resamples = cv_folds,
  grid = rf_grid,
  metrics = metric_set(yardstick::roc_auc, yardstick::accuracy)
)

xgb_tuned <- tune_grid(
  xgb_workflow,
  resamples = cv_folds,
  grid = xgb_grid,
  metrics = metric_set(yardstick::roc_auc, yardstick::accuracy)
)

nn_tuned <- tune_grid(
  nn_workflow,
  resamples = cv_folds,
  grid = nn_grid,
  metrics = metric_set(roc_auc, accuracy)
)

# 9. Select Best Hyperparameters
rf_best <- select_best(rf_tuned, metric = "accuracy")
xgb_best <- select_best(xgb_tuned, metric = "accuracy")
nn_best <- select_best(nn_tuned, metric = "accuracy")

# 10. Finalize Workflows with Optimal Hyperparameters
rf_workflow <- finalize_workflow(rf_workflow, rf_best)
xgb_workflow <- finalize_workflow(xgb_workflow, xgb_best)
nn_workflow <- finalize_workflow(nn_workflow, nn_best)

# 11. Fit Final Models and Evaluate
rf_final <- rf_workflow %>%
  last_fit(data_split)
rf_metrics <- collect_metrics(rf_final)

xgb_final <- xgb_workflow %>%
  last_fit(data_split)
xgb_metrics <- collect_metrics(xgb_final)

nn_final <- nn_workflow %>%
  last_fit(data_split)
nn_metrics <- collect_metrics(nn_final)

# 12. Compare Metrics
print(rf_metrics)
print(xgb_metrics)
print(nn_metrics)

# Save Random Forest Predictions
rf_predictions <- rf_final %>% collect_predictions()
write.csv(rf_predictions, "rf_predictions.csv")


rf_workflow_model <- extract_workflow(rf_final)

rf_model_object <- extract_fit_parsnip(rf_workflow_model)$fit

# Extract the workflow and model from `last_fit`
rf_workflow_model <- extract_workflow(rf_final)
rf_model_object <- extract_fit_parsnip(rf_workflow_model)$fit

# Ensure raster stack is ready
datastack <- datastack[[c(1:7, 12)]]
names(datastack) <- c("Aspect", "Roughness", "Slope", "Elevation", "Precipitation", "TDMean", "TMean", "Canopy.Cover")
datastack <- app(datastack, fun = function(x) {
  ifelse(is.na(x), mean(x, na.rm = TRUE), x)
})

# Predict probabilities using the Random Forest model
predicted=terra::predict(datastack, rf_final, type="prob")


# Plot and save the raster
plot(predicted)
writeRaster(predicted, filename = "rf_predict.tif", filetype = "GTiff", overwrite = TRUE)


