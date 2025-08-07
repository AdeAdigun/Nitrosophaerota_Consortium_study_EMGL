# Load necessary libraries
library(ggplot2)
library(maps)
library(dplyr)
library(purrr)

# Read the data
data <- read.table("biosample_metadata.tsv", header=TRUE, sep="\t", stringsAsFactors=FALSE, fill=TRUE, quote="")

# Function to handle directionality for Latitude and Longitude
adjust_coordinates <- function(lat, lon) {
  # If either lat or lon is missing or empty, return NA
  if (is.na(lat) | is.na(lon) | lat == "" | lon == "") {
    return(c(NA, NA))  # Return NA for both if missing or empty
  }
  
  # Extract numeric value and direction from Latitude and Longitude
  lat_value <- suppressWarnings(as.numeric(sub("([0-9.]+).*", "\\1", lat)))
  lat_direction <- sub(".*([NS]).*", "\\1", lat)
  lon_value <- suppressWarnings(as.numeric(sub("([0-9.]+).*", "\\1", lon)))
  lon_direction <- sub(".*([EW]).*", "\\1", lon)
  
  # If any values are invalid (not a number or no direction), return NA
  if (is.na(lat_value) | is.na(lon_value) | is.na(lat_direction) | is.na(lon_direction)) {
    return(c(NA, NA))  # Return NA if any part is invalid
  }
  
  # Adjust for direction (South or West)
  if (lat_direction == "S") lat_value <- -lat_value
  if (lon_direction == "W") lon_value <- -lon_value
  
  return(c(lat_value, lon_value))
}


# Apply the function and clean data
data_clean <- data %>%
  mutate(
    LatLon = purrr::pmap(list(Latitude, Longitude), adjust_coordinates),
    Latitude = sapply(LatLon, `[`, 1),
    Longitude = sapply(LatLon, `[`, 2)
  ) %>%
  select(-LatLon) %>%
  filter(!is.na(Latitude) & !is.na(Longitude))  # Keep only rows with valid coordinates

# Safely convert Latitude and Longitude to numeric without warnings
problematic_rows <- data %>% filter(
  is.na(suppressWarnings(as.numeric(Latitude))) | is.na(suppressWarnings(as.numeric(Longitude)))
)

# Check problematic rows
print(problematic_rows)


# Get world map data
world_map <- map_data("world")

# Check the number of unique Isolation.Source values
num_sources <- length(unique(data_clean$Isolation.Source))

# Choose a color palette based on the number of unique sources
if (num_sources <= 12) {
  # Use Set3 palette for up to 12 unique values
  colors <- c("hot springs metagenome" = "#FF0000", 
              setNames(brewer.pal(num_sources - 1, "Set3"), 
                       setdiff(unique(data_clean$Isolation.Source), "hot springs metagenome")))
} else {
  # Use a viridis palette for more than 12 values
  colors <- c("hot springs metagenome" = "#FF0000", 
              setNames(viridis::viridis(num_sources - 1), 
                       setdiff(unique(data_clean$Isolation.Source), "hot springs metagenome")))
}

# Plotting the map with sample locations
ggplot(data = world_map) +
  geom_polygon(aes(x = long, y = lat, group = group), fill = "lightgray", color = "black") +
  geom_point(data = data_clean, aes(x = Longitude, y = Latitude, color = Isolation.Source), size = 2, alpha = 0.7) +
  theme(
    axis.ticks = element_blank(),  # Remove axis ticks
    panel.grid = element_blank(),  # Remove gridlines
    axis.text = element_blank(),  # Remove axis labels
    panel.background = element_blank(),  # Make background transparent
    plot.background = element_blank()  # Make entire plot background transparent
  ) +
  labs(title = NULL, x = NULL, y = NULL) +
  scale_color_manual(values = colors) +  # You can choose a color scale
  coord_cartesian(xlim = c(-180, 180), ylim = c(-90, 90))  # Adjust limits for zooming in
