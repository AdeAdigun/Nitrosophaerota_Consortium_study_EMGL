#!/bin/bash
echo "Trycycler_pre_assembly"

threads=71
mkdir assemblies

conda activate trycycler

trycycler subsample --reads cat.fastq.gz --out_dir read_subsets --threads 71

echo "assembly"

flye --nano-hq read_subsets/sample_01.fastq --meta --threads "$threads" --out-dir assembly_01 && cp assembly_01/assembly.fasta assemblies/assembly_01.fasta && cp assembly_01/assembly_graph.gfa assemblies/assembly_01.gfa && rm -r assembly_01

canu -p canu -d canu_temp -fast genomeSize=5m useGrid=false maxThreads="$threads" -nanopore read_subsets/sample_02.fastq
    python /home/sophy/mambaforge/envs/trycycler/scripts/canu_trim.py canu_temp/canu.contigs.fasta > assemblies/assembly_02.fasta
    rm -rf canu_temp

raven --threads "$threads" --disable-checkpoints --graphical-fragment-assembly assemblies/assembly_03.gfa read_subsets/sample_03.fastq > assemblies/assembly_03.fasta

flye --nano-hq read_subsets/sample_04.fastq --meta --threads "$threads" --out-dir assembly_04 && cp assembly_04/assembly.fasta assemblies/assembly_04.fasta && cp assembly_04/assembly_graph.gfa assemblies/assembly_04.gfa && rm -r assembly_04

canu -p canu -d canu_temp -fast genomeSize=5m useGrid=false maxThreads="$threads" -nanopore read_subsets/sample_05.fastq
    python /home/sophy/mambaforge/envs/trycycler/scripts/canu_trim.py canu_temp/canu.contigs.fasta > assemblies/assembly_05.fasta
    rm -rf canu_temp

raven --threads "$threads" --disable-checkpoints --graphical-fragment-assembly assemblies/assembly_06.gfa read_subsets/sample_06.fastq > assemblies/assembly_06.fasta

flye --nano-hq read_subsets/sample_07.fastq --meta --threads "$threads" --out-dir assembly_07 && cp assembly_07/assembly.fasta assemblies/assembly_07.fasta && cp assembly_07/assembly_graph.gfa assemblies/assembly_07.gfa && rm -r assembly_07

canu -p canu -d canu_temp -fast genomeSize=5m useGrid=false maxThreads="$threads" -nanopore read_subsets/sample_08.fastq
    python /home/sophy/mambaforge/envs/trycycler/scripts/canu_trim.py canu_temp/canu.contigs.fasta > assemblies/assembly_08.fasta
    rm -rf canu_temp

raven --threads "$threads" --disable-checkpoints --graphical-fragment-assembly assemblies/assembly_09.gfa read_subsets/sample_09.fastq > assemblies/assembly_09.fasta

flye --nano-hq read_subsets/sample_10.fastq --meta --threads "$threads" --out-dir assembly_10 && cp assembly_10/assembly.fasta assemblies/assembly_10.fasta && cp assembly_10/assembly_graph.gfa assemblies/assembly_10.gfa && rm -r assembly_10

canu -p canu -d canu_temp -fast genomeSize=5m useGrid=false maxThreads="$threads" -nanopore read_subsets/sample_11.fastq
    python /home/sophy/mambaforge/envs/trycycler/scripts/canu_trim.py canu_temp/canu.contigs.fasta > assemblies/assembly_11.fasta
    rm -rf canu_temp

raven --threads "$threads" --disable-checkpoints --graphical-fragment-assembly assemblies/assembly_12.gfa read_subsets/sample_12.fastq > assemblies/assembly_12.fasta
