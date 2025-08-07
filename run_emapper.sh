#!/bin/bash


# Set the output directory for results
OUTPUT_DIR="./results"

# Set the number of CPUs you want to use (adjust as needed)
CPU_COUNT=71

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Loop over each .faa file in the /genomes/ directory
for genome in /path/to/genomes/*.faa; do
    # Get the base name of the genome file (e.g., genome1)
    genome_name=$(basename "$genome" .faa)
    
    echo "Running EggNOG-mapper for $genome_name"

    # Run EggNOG-mapper
    emapper.py -i "$genome" -o "$genome_name" --output_dir "$OUTPUT_DIR" --cpu $CPU_COUNT
    echo "$genome_name completed."
done