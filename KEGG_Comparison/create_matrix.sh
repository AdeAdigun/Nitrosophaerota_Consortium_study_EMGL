#!/bin/bash

OUTPUT_DIR="./results"
TARGET_GENES="target_genes.csv"
KO_LIST="KO_list.tsv"
MATRIX_FILE="KO_matrix.tsv"

# Ensure target genes file exists
if [[ ! -f "$TARGET_GENES" ]]; then
    echo "Error: Target genes file not found!" >&2
    exit 1
fi

# Read target KO IDs into an array (remove header if present)
mapfile -t target_KOs < <(awk 'NR>1 {split($1, a, ","); print a[2]}' "$TARGET_GENES")

# Extract unique genome names
genomes=($(cut -f1 "$KO_LIST" | tail -n +2 | sort -u))

# Initialize matrix with header
{
    echo -ne "Genome"
    for ko in "${target_KOs[@]}"; do
        echo -ne "\t$ko"
    done
    echo
} > "$MATRIX_FILE"

# Populate matrix with KO presence/absence and copy numbers
for genome in "${genomes[@]}"; do
    echo -ne "$genome"
    for ko in "${target_KOs[@]}"; do
        count=$(awk -v g="$genome" -v k="$ko" '$1 == g && $2 == k' "$KO_LIST" | wc -l)
        echo -ne "\t$count"
    done
    echo
done >> "$MATRIX_FILE"

echo "KO matrix generation completed: $MATRIX_FILE"
