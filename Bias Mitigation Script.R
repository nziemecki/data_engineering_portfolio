wd=("/Users/tup93308/Desktop/ML_term_proj")
setwd(wd)

# Load necessary libraries
library(terra)
library(sf)
library(tidycensus)
library(dplyr)
library(ggplot2)

# Load your existing spatial and raster data
datastack = rast("datastack_b.tif")
SpatData = vect(paste0(wd, "/DataPoints/DataPoints.shp"))
plot(datastack[[11]])
plot(SpatData, add = TRUE)

# Ensure CRS matches
SpatData = project(SpatData, datastack)

# Assign response variable
SpatData$response = ifelse(SpatData$individual > 0, 1, 0)

#-------------------------------------------------------------------------------
#TEST SPATIAL BIAS

#Extract SpatData with population density values
SpatData$population_density <- extract(datastack[[11]], SpatData)[, 2]  

#Moran's I for SpatData
library(spdep)

# Create spatial weights (e.g., based on neighbors or distance)
coords <- st_coordinates(st_as_sf(SpatData))
nb <- dnearneigh(coords, d1 = 0, d2 = 10000)  # Adjust distance threshold (e.g., 10 km)
lw <- nb2listw(nb, style = "W")

# Moran's I for population density
moran.test(SpatData$population_density, lw)

#*****there is no spatial clustering

# Kolmogorov-Smirnov (KS) test for SpatData

population_density_values <- values(datastack[[11]]) 


population_density_values <- population_density_values[!is.na(population_density_values)]


ks.test(SpatData$population_density, population_density_values, alternative = "two.sided")

#****the KS test shows that the sampled points are influenced by population density

#Visualize Distribution
# Empirical cumulative distribution function (ECDF) for study area
study_area_cdf <- ecdf(population_density_values)

# ECDF for sample points
sample_cdf <- ecdf(SpatData$population_density)

# Plot CDFs
plot(study_area_cdf, main = "Cumulative Distribution of Population Density",
     xlab = "Population Density", ylab = "Cumulative Probability", col = "black")
lines(sample_cdf, col = "red")

legend("bottomright", legend = c("Study Area", "Sample Points"), col = c("black", "red"), lwd = 2)


#-------------------------------------------------------------------------------

# PRODUCE PSEUDO ABSENCES

#make study area variable:
# Define study area
studyArea = st_union(st_as_sf(censusdata))
plot(studyArea)

# Filter presence data
SpatData = SpatData[SpatData$response == 1, ]
samp = st_sample(studyArea, size = nrow(SpatData))
samp = vect(samp)

# Create an empty dataframe for the sampled pseudo-absences
values(samp) = data.frame(matrix(data = 0, nrow = nrow(samp), ncol = ncol(SpatData)))
names(samp) = names(SpatData)

# Combine presence and pseudo-absence data
SpatData = rbind(SpatData, samp)

# Extract data directly from the raster for each pixel
pointdata = extract(datastack, SpatData, xy = TRUE)

# 7. Combine the response variable with the extracted data
pointdata = cbind(pointdata, SpatData$response)

# 8. Save the combined data to CSV
write.csv(pointdata, file = "pointdata.csv")

