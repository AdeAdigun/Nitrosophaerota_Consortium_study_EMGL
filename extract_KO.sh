#!/bin/bash

OUTPUT_DIR="./results"
TARGET_GENES="target_genes.csv"
KO_LIST="KO_list.tsv"

# Extract KO_IDs and remove 'ko:' prefix
echo -e "Genome\tKO_ID" > "$KO_LIST"

for annotation in $OUTPUT_DIR/*.annotations; do
    genome_name=$(basename "$annotation" .emapper.annotations)

    # Extract KEGG Ortholog (KO) IDs (Column 12), remove 'ko:' prefix
    awk -F"\t" 'NR > 4 && $12 ~ /K[0-9]+/ {sub(/^ko:/, "", $12); print "'$genome_name'\t"$12}' "$annotation" >> "$KO_LIST"
done

echo "KO extraction completed."
