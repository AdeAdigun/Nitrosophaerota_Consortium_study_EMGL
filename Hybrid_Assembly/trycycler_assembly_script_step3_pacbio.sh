#!/bin/bash
echo "This is step three of assembly with trycycler"
echo "This step comes after trycycler reconcile!"
echo "Please make sure to have deleted bad clusters!"

echo "Multiple sequence alignment"

trycycler msa --cluster_dir trycycler/cluster_001 --threads 71

echo "Partitioning reads"

trycycler partition --reads pacbio.fastq --cluster_dirs trycycler/cluster_* --threads 71

#echo "Making a consensus assembly"

trycycler consensus --cluster_dir trycycler/cluster_001 --threads 71  --verbose

echo "Post-assembly consensus"

cat trycycler/cluster_*/8_medaka.fasta > trycycler/consensus.fasta

echo "done"
