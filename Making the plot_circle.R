# Load necessary libraries
library(ggplot2)
library(dplyr)
library(ggforce)
library(reshape2)

# Read the matrix data
matrix_data <- read.csv("matrix_output.csv")

# Reshape the matrix into long format
long_data <- melt(matrix_data, id.vars = c("Gene_Name", "KO_ID", "Metabolic_traits"), variable.name = "Sample", value.name = "Copy_Number")

# Inspect the reshaped data
head(long_data)

# Filter out rows where Copy_Number is 0
long_data <- long_data %>% filter(Copy_Number > 0)

# Define the desired order for the x-axis (samples)
desired_sample_order <- c("Aigarchaeota_GMQ_bin_10", "Aigarchaeota_JZ_bin_15", "Candidatus_Caldarchaeum_subterraneum", "Aigarchaeota_JZ_bin_40", "Aigarchaeota_JZ_bin_19","Conexivisphaera_calida_NAS.02","Thaumarchaeota_archaeon_UBA164","Thaumarchaeota_archaeon_DS1","Thaumarchaeota_archaeon_UBA160","archaeon_YF1.bin89","archaeon_YP1.bin10","NA0","Thaumarchaeota_archaeon_BS4","Thaumarchaeota_archaeon_BS1","Nitrososphaerota_archaeon_AcS1_13","Nitrososphaerota_archaeon_AcS1_6","Nitrososphaerota_archaeon_AcS1_27","Nitrososphaerota_archaeon_SubAcS15_15","Nitrososphaerota_archaeon_SubAcS9_116","FN1","Nitrososphaerota_archaeon_SubAcS15_57","Nitrososphaerota_archaeon_SubAcS11.97","Nitrososphaerota_archaeon_AAIW","Nitrososphaerota_archaeon_ATL","Nitrososphaerota_archaeon_PAC","Nitrososphaerota_archaeon_AABW","Candidatus_Nitrososphaera_gargensis_Ga92","Candidatus_Nitrosocosmicus_oleophilus_MY3","Candidatus_Nitrosocosmicus_arcticus_Kfb","Nitrosotalea_sinensis_NSIN","Candidatus_Nitrosotenuis_chungbukensis_MY2","Nitrosopumilus_maritimus_SCM1","Candidatus_Nitrosopelagicus_brevis")

# Define the desired order for the y-axis (samples)
desired_gene_order <- unique(c("coxA","coxAC","coxB","coxD","cydA","cydB","coxL","amoA","amoB","amoC","glnA","narG","soxB","soxC","dsrA","HdrA","HdrB","HdrD","sqr","AA3","CE1","GT57","S53","M24B","M32","M19","S24","S8","M3","M48B","THERMOPSIN","C15","M32","ribA","bioB","cobA","mvaD","fadD","acd","echA","fadB","fadA","atoB","rbcL","prk","abfD","apc","A/V-type_ATPase","other_ATPases","trx","SOD2","arcA","kdpA","kdpB","kdpC","F420-dep_G6PD"))
                          
# Apply the order to the Sample variable
long_data$Sample <- factor(long_data$Sample, levels = desired_sample_order)

# Apply the order to the Sample variable
long_data$Gene_Name <- factor(long_data$Gene_Name, levels = desired_gene_order)

# Create a column for circle size (based on copy number)
long_data$circle_size <- long_data$Copy_Number * 1  # Scale the size if necessary

# Create a color mapping for metabolic traits
trait_colors <- c("Aerobic respiration" = "darkblue", 
                  "Nitrogen metabolism" = "#DC143C", 
                  "Sulfur metabolism" = "red",
                  "CAZymes" = "darkorange",
                  "Peptidases" = "#FFAC1C",
                  "Cofactor Biosynthesis" = "green",
                  "Fatty acid degradation" = "#CC7722",
                  "Carbon assimilation" = "#6E260E",
                  "Stress response" = "darkgreen",
                  "N/A" = "gray")

# Plot the circle-based heatmap with flipped axes and filled circles
ggplot(long_data, aes(x = Sample, y = Gene_Name)) +
  geom_point(aes(size = circle_size, fill = Metabolic_traits), shape = 21) +
  scale_size_continuous(range = c(2, 5), name = "Copy Number") +  # Adjust the size range
  scale_fill_manual(values = trait_colors, name = "Metabolic traits") +  # Use the custom color scheme
  labs(title = NULL,
       x = "Samples", 
       y = "Genes") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1.05,  vjust = 0.5, family = "Arial", face = "bold"),
        axis.title.x = element_blank(), 
        axis.title.y = element_blank(),  # Remove Y-axis title
        axis.text.y = element_blank(),  # Remove Y-axis labels
        axis.ticks.y = element_blank(),
        legend.key.size = unit(0.5, "cm")) +  # Adjust legend size
  theme(legend.title = element_text(size = 12)) +
  guides(fill = guide_legend(override.aes = list(size = 5)),  # Increase legend circle size
         size = guide_legend(order = 1)) +  # Make size legend more compact
  coord_flip()  # Flip the axes
