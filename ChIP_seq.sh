#!/bin/sh

### created and update on 2020.10.01 by shuang as a ChIP seq pipeline
########################################################################################
#this is the step1, for alignment
########################################################################################

# Print start status message.
echo "job started"
start_time=`date +%s`

ls -d */ |sed 's/\///' | uniq > filelist.txt
#ls | sed 's/_[12].fq.gz//' | uniq > filelist.txt
#ls *.fq.gz | sed 's/_[12].fq.gz//' | uniq > filelist.txt

cat filelist.txt | while read LINE; do

	
input=`echo "$LINE" `

###   selecting different method(mkdir cd) in step with
#mkdir ${input}
echo ${input}
echo ${input} > mapping_report.txt
cd ${input}


##################################################################
#-S means generate sam format
##################################################################

#using bowtie or bowtie2
#bowtie -S -p 16 -m 1 -5 5 -3 10 --best --strata /media/hp/disk1/song/Genomes/NC10/Sequences/WholeGenomeFasta/bowtie/NC10 -1 ${input}_1.fq.gz -2 ${input}_2.fq.gz ${input}/${input}.sam 2>> .v/mapping_report.txt

#bowtie2 -S ${input}/${input}.sam -p 16 -5 5 -3 10 -x /media/hp/disk1/song/Genomes/NC10/Sequences/WholeGenomeFasta/bowtie2/NC10 -1 ${input}_1.fq.gz -2 ${input}_2.fq.gz 2>> ../mapping_report.txt
bowtie2 -S ${input}.sam -p 16 -5 5 -3 10 -x /media/hp/disk1/song/Genomes/NC10/Sequences/WholeGenomeFasta/bowtie2/NC10 -1 ${input}_1.fq.gz -2 ${input}_2.fq.gz 2>> ../mapping_report.txt
 

##     if  runing line 28 , you should also run line 43 
#cd ${input}

samtools view -@ 16 -Sb ${input}.sam > ${input}.bam
samtools sort -@ 16 ${input}.bam -o ${input}.sort.bam

java -jar ~/picard/picard.jar MarkDuplicates I=${input}.sort.bam O=${input}.sort.markdup.bam M=${input}.markdup.txt
samtools index ${input}.sort.markdup.bam
#samtools view -bq 1 $input\_sorted.bam > $input.unique.bam  #GET THE UNIQUE READS
# make bw files 
bamCoverage -b ${input}.sort.markdup.bam -o $input.bw --binSize 10 --normalizeUsing RPGC --effectiveGenomeSize 41000000 --extendReads

cd ..
 
done

#peak calling 
grep -v _input filelist.txt >file.txt
cat file.txt | while read LINE; do
	
input=`echo "$LINE" `

cd ${input}
 
macs2 callpeak -t ${input}.bam -c ../wt_input/wt_input.bam -f BAM -g 4.1e8 -q 0.05 --broad --max-gap 500 -n $input 

cd ..

done





