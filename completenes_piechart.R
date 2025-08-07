install.packages("svglite")

# Load necessary libraries
library(ggplot2)
library(tidyr)

# Assuming the data is already loaded into a data frame called 'data'
data <- read.csv("extra_plots.csv")

# Clean the data if necessary
data$Completeness <- as.numeric(data$Completeness)

# Create a column for the percentage completeness
data$Completeness_pct <- data$Completeness / 100

# Create a 'Completeness' column to represent the rest of the pie chart (100 - Completeness)
data$Remaining_pct <- 1 - data$Completeness_pct

# Reshape data to long format for pie chart creation
data_long <- data %>%
  gather(key = "completeness_type", value = "value", Completeness_pct, Remaining_pct)

# Order the 'Taxon' factor based on the order in the CSV
data_long$Taxon <- factor(data_long$Taxon, levels = unique(data_long$Taxon))

# Define custom colors for the completeness and remaining portions
pie_colors <- c("Completeness_pct" = "red", "Remaining_pct" = "lightgrey")

# Plot: Pie charts for Completeness of each taxon arranged horizontally
completeness_pie <- ggplot(data_long, aes(x = "", y = value, fill = completeness_type)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  facet_wrap(~ Taxon, scales = "free_y", ncol = 1) +  # Arrange all in one column
  theme_void() +
  labs(title = NULL) +
  theme(legend.position = "none",  # Hide legend
        strip.text = element_blank()) +  # Remove facet labels (Taxon names)
  scale_fill_manual(values = pie_colors)  # Apply custom colors

# Save the plot with a larger width (adjust the height as needed)
ggsave("completeness_pie_chart_column_colored.png", completeness_pie, width = 7, height = 25)
ggsave("completeness_pie_chart_column_colored.svg", completeness_pie, width = 7, height = 25, device = "svg")

       