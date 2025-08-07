library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

# Load the data
data <- read.csv("conexivisphaerales_imngs.csv", stringsAsFactors = FALSE)

# Convert wide format to long format
data_long <- data %>%
  pivot_longer(cols = c(NA0, BS1, BS4), names_to = "Sequence", values_to = "Hits") %>%
  group_by(Description, Sequence) %>%
  summarise(Percentage = (sum(Hits) / sum(Size)) * 100, .groups = "drop")  # Ensure percentages are correctly calculated

# Create a grouped bar plot
ggplot(data_long, aes(x = reorder(Description, -Percentage), y = Percentage, fill = Sequence)) +
  geom_bar(stat = "identity", position = "dodge") +  # Dodge to separate bars
  theme_minimal() +
  xlab("Sample Description") +
  ylab("Relative abundance(%)") +
  coord_flip() +  # Rotate for readability
  scale_fill_manual(values = c("NA0" = "#800020", "BS1" = "darkorange", "BS4" = "#00008B")) + 
  scale_y_continuous(breaks = seq(0, 1, by = 0.01), expand = c(0, 0)) +  # Fix percentage display and axis alignment
  scale_x_discrete(expand = c(0.05, 0)) +  # Ensure bars touch the y-axis
  theme_minimal() +
  theme(
    panel.grid = element_blank(),  # Remove gridlines
    panel.border = element_rect(color = "black", fill = NA, size = 1),  # Add axis lines on all sides
    axis.line = element_blank(),  # Avoid double axis lines
    legend.position = c(0.95, 0.95),  # Position legend inside the plot area (upper right)
    legend.justification = c(1, 1),  # Adjust legend box placement
    legend.box = "vertical",  # Stack the legend items vertically
    legend.background = element_rect(fill = "white", color = "black", size = 0.5)  # Add background to legend
  ) +
  labs(fill = "Strain")
