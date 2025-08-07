##2024-05-17 JH.G mnter89@gmail.com

PWD=$(pwd)
help()
{
echo "we are working on $PWD"
echo "basic_annot_w_prokka"
echo "##usage"
echo "source basic_annot_w_prokka.bash #1 #2"
echo "##Do not use absolute file path"
echo "#1 - target.fa"
echo "#2 - Archaea OR Bacteria"
echo "if you want keep ncbi gbff ORF prediction then save the ""target"".gbff"
exit 1
}
[ -z "$1" ] && help

N="${1%.*}"

if [ ! -f ""${1%.fna}".gbff" ]; then
prokka --kingdom "$2" --outdir prokka_"$N" --cpus 71 --force --prefix "$N" --addgenes --addmrna --locustag "$N" --evalue 1e-05 --coverage 40 --proteins "${1%.fna}".gbff $1
else  
prokka --kingdom "$2" --outdir prokka_"$N" --cpus 71 --force --prefix "$N" --addgenes --addmrna --locustag "$N" --evalue 1e-05 --coverage 40 $1
fi

cd prokka_"$N"

sed -n -e '/CDS/p' "$N".gff > "$N"_temp0.txt
cat "$N"_temp0.txt | cut -d$'\t' -f1,3,4,5,6,7,8 > "$N"_temp1.txt
cat "$N"_temp0.txt | grep -o -P '(?<=ID=).*?(?=;)' > "$N"_temp2.txt
cat "$N"_temp0.txt | awk '{sub(/.*'Name='/,""); sub(/;.*/,""); sub(/.*'ID'.*/,""); print;}' > "$N"_temp3.txt
cat "$N"_temp0.txt | awk '{sub(/.*'eC_number='/,""); sub(/;.*/,""); sub(/.*'ID'.*/,""); print;}' > "$N"_temp4.txt
cat "$N"_temp0.txt | awk '{sub(/.*'db_xref=COG:'/,""); sub(/;.*/,""); sub(/.*'ID'.*/,""); print;}' > "$N"_temp5.txt
cat "$N"_temp0.txt | awk '{sub(/.*'product='/,""); sub(/;.*/,""); sub(/.*'ID'.*/,""); print;}' > "$N"_temp6.txt
paste "$N"_temp1.txt "$N"_temp2.txt "$N"_temp3.txt "$N"_temp4.txt "$N"_temp5.txt "$N"_temp6.txt > "$N".tsv
rm -rf "$N"_temp*.txt

diamond blastp --db /mnt/sdd1/diamond_db/nr --query "$N".faa --threads 71 -o "$N".nr.blast6 --log -f 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle staxids sscinames skingdoms sphylums
cat "$N".nr.blast6 | sort -k 3 -g -r -t$'\t' | awk 'BEGIN{ FS=OFS="\t"};!x[$1]++ {print $0}' | sort -k 1 > dmnd_bh_"$N".tab
cat "$N".faa | awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$1);N++;next;} {printf("%s",$0);} END {printf("\n");}' | awk 'BEGIN{FS=OFS="\t"} { sub(">","",$0); print }' > 1line_"$N".faa
cat "$N".ffn | awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$1);N++;next;} {printf("%s",$0);} END {printf("\n");}' | awk 'BEGIN{FS=OFS="\t"} { sub(">","",$0); print }' > 1line_"$N".ffn

join -t $'\t' -a 1 -1 8 -2 1 "$N".tsv 1line_"$N".faa > temp_faa; join -t $'\t' -a 1 -1 1 -2 1 temp_faa 1line_"$N".ffn > temp_ffn; join -e $'.' -t $'\t' -a 1 -1 1 -2 1 -o '0,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,2.10,2.11,2.12,2.13,2.14,2.15,2.16,2.17' temp_ffn dmnd_bh_"$N".tab > temp_annot.tsv

pfam_scan.pl -cpu 71 -fasta "$N".faa -dir /mnt/sdd1/pfam > pfam_temp.tsv
sed 's/  */\t/g' pfam_temp.tsv > pfam_"$N".tsv
rm -rf pfam_temp.tsv
awk '{print $8}' "$N".tsv > gene_id_"$N".tsv
while read line; do grep -i $line pfam_"$N".tsv | awk '{print $6}' | xargs | sed 's/ /;/g' | sed "s/^/$line\t/g" ; done < gene_id_"$N".tsv > pfam_id_"$N".tsv
while read line; do grep -i $line pfam_"$N".tsv | awk '{print $7}' | xargs | sed 's/ /;/g' | sed "s/^/$line\t/g" ; done < gene_id_"$N".tsv > pfam_des_"$N".tsv
join -t $'\t' -a 1 -1 1 -2 1 pfam_id_"$N".tsv pfam_des_"$N".tsv > pfam_xargs_"$N".tsv
rm -rf pfam_id_"$N".tsv
rm -rf pfam_des_"$N".tsv

join -e $'.' -t $'\t' -a 1 -1 1 -2 1 -o '0,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,1.15,1.16,1.17,1.18,1.19,1.20,1.21,1.22,1.23,1.24,1.25,1.26,1.27,1.28,1.29,1.30,2.2,2.3' temp_annot.tsv pfam_xargs_"$N".tsv > temp_annot_pfam.tsv

emapper.py -i "$N".faa -o eggnog --cpu 71

join -e $'.' -t $'\t' -a 1 -1 1 -2 1 -o '0,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,1.15,1.16,1.17,1.18,1.19,1.20,1.21,1.22,1.23,1.24,1.25,1.26,1.27,1.28,1.29,1.30,1.31,1.32,2.5,2.6,2.7,2.8,2.9,2.10,2.11,2.12,2.13,2.14,2.15,2.16,2.17,2.18,2.19,2.20,2.21' temp_annot_pfam.tsv <(sort -k 1 eggnog.emapper.annotations) > temp_annot_pfam_egg.tsv

signalp6 --fastafile "$N".faa --organism other --output_dir signalp6 --format txt --mode fast --write_procs 71
sed 's/ /\t/' signalp6/prediction_results.txt > sp6_temp.tsv
awk -F'\t' '$4 < 0.9' sp6_temp.tsv > sp6_temp_0.9.tsv

echo -e "locus\tscaffold_name\tfeature\tstart\tend\tscore\tstrand\tframe\tname\tEC\tCOG\tdescription\tfaa\tffn\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tsalltitles\tstaxids\tscientific_name\tscomnames\tsskingdoms\thmm_name\thmm_description\teggNOG_OGs\tmax_annot_lvl\tCOG_category\tDescription\tPreferred_name\tGOs\tEC\tKEGG_ko\tKEGG_Pathway\tKEGG_Module\tKEGG_Reaction\tKEGG_rclass\tBRITE\tKEGG_TC\tCAZy\tBiGG_Reaction\tPFAMs\tsp6_desc\tPrediction\tOTHER\tSP(Sec/SPI)\tLIPO(Sec/SPII)\tTAT(Tat/SPI)\tTATLIPO(Sec/SPII)\tPILIN(Sec/SPIII)\tCS Position" > "$N"_annot.tab

join -e $'.' -t $'\t' -a 1 -1 1 -2 1 -o '0,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,1.15,1.16,1.17,1.18,1.19,1.20,1.21,1.22,1.23,1.24,1.25,1.26,1.27,1.28,1.29,1.30,1.31,1.32,1.33,1.34,1.35,1.36,1.37,1.38,1.39,1.40,1.41,1.42,1.43,1.44,1.45,1.46,1.47,1.48,1.49,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,2.10' temp_annot_pfam_egg.tsv <(sort -k 1 sp6_temp_0.9.tsv) >> "$N"_annot.tab

#biolib run --local DTU/DeepTMHMM --fasta "$N".faa

#grep -e "Number of predicted TMRs:" ./biolib_results/TMRs.gff3 | sed 's/ Number of predicted TMRs: /\t/g' | sed 's/# //g'> tmrs_out.txt

#cp "$N"_annot.tab "$N"_annot_bak.tab

#join -e $'.' -t $'\t' -a 1 -1 1 -2 1 -o '0,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,1.15,1.16,1.17,1.18,1.19,1.20,1.21,1.22,1.23,1.24,1.25,1.26,1.27,1.28,1.29,1.30,1.31,1.32,1.33,1.34,1.35,1.36,1.37,1.38,1.39,1.40,1.41,1.42,1.43,1.44,1.45,1.46,1.47,1.48,1.49,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,2.10' temp_annot_pfam_egg.tsv <(sort -k 1 sp6_temp_0.9.tsv) > tmp_tmr

#echo -e "locus\tscaffold_name\tfeature\tstart\tend\tscore\tstrand\tframe\tname\tEC\tCOG\tdescription\tfaa\tffn\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tsalltitles\tstaxids\tscientific_name\tscomnames\tsskingdoms\thmm_name\thmm_description\teggNOG_OGs\tmax_annot_lvl\tCOG_category\tDescription\tPreferred_name\tGOs\tEC\tKEGG_ko\tKEGG_Pathway\tKEGG_Module\tKEGG_Reaction\tKEGG_rclass\tBRITE\tKEGG_TC\tCAZy\tBiGG_Reaction\tPFAMs\tsp6_desc\tPrediction\tOTHER\tSP(Sec/SPI)\tLIPO(Sec/SPII)\tTAT(Tat/SPI)\tTATLIPO(Sec/SPII)\tPILIN(Sec/SPIII)\tCS Position\t#TMRs" > "$N"_annot_tmr.tab

#join -e $'.' -t $'\t' -a 1 -1 1 -2 1 -o '0,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,1.15,1.16,1.17,1.18,1.19,1.20,1.21,1.22,1.23,1.24,1.25,1.26,1.27,1.28,1.29,1.30,1.31,1.32,1.33,1.34,1.35,1.36,1.37,1.38,1.39,1.40,1.41,1.42,1.43,1.44,1.45,1.46,1.47,1.48,1.49,1.50,1.51,1.52,1.53,1.54,1.55,1.56,1.57,1.58,2.2' tmp_tmr <(sort -k 1 tmrs_out.txt) >> "$N"_annot_tmr.tab

cd ..


