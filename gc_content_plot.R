# Load necessary libraries
library(ggplot2)
library(readr)
library(gridExtra)

# Load the dataset
data <- read_csv("extra_plots.csv", col_types = cols(.default = "c"))

# Select only relevant columns
data <- data[, 1:5]  # Adjust if your actual columns differ

# Remove % sign and convert GC_Content to numeric
data$GC_Content <- as.numeric(gsub("%", "", data$GC_Content)) * 100  # Convert to percentage

# Ensure the Taxon order matches the CSV file
data$Taxon <- factor(data$Taxon, levels = unique(data$Taxon))  # Maintain CSV order

# Get the minimum and maximum GC_Content values for setting color scale limits
min_gc <- min(data$GC_Content, na.rm = TRUE)
max_gc <- max(data$GC_Content, na.rm = TRUE)

# Create the GC Content heatmap (single horizontal bar)
gc_content_heatmap <- ggplot(data, aes(x = 0, y = Taxon, fill = GC_Content)) +  
  geom_tile(width = 0.5, height = 1) +  # Adjust tile shape
  scale_fill_gradient(low = "white", high = "black") +
  theme_minimal() +
  labs(title = "GC Content", x = "", y = "") +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "none",  # Hide legend in the plot
    plot.title = element_blank()  # Ensure no title
) +
  coord_flip()  # Force vertical arrangement

# Save the plot as PNG and SVG
ggsave("gc_content_heatmap.png", gc_content_heatmap, width = 15, height = 2, dpi = 300)
ggsave("gc_content_heatmap.svg", gc_content_heatmap, width = 15, height = 2, device = "svg")

# Extract the legend using the guides() function
gc_content_legend <- gc_content_heatmap + 
  theme(legend.position = "bottom") +
  guides(fill = guide_colorbar(title = NULL))  # Remove the legend title

# Save the legend separately
ggsave("gc_content_legend.png", gc_content_legend, width = 5, height = 1, dpi = 300)
