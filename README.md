**<font color="grey"><font size=200>UPSTREAM ANALYSIS of ChIP-Seq </font></font>**
<font size=5><font color="grey"><p align="right">2020.10.27</p></font></font>
# <font color="steelblue">Pipe for ChIP</font>

- [<font size=4>1   mapping reads (RNA-seq mappers)</font>](#-font-size-4-1---mapping-reads--rna-seq-mappers---font-)
- [<font size=4>2   sorting alignment and converting <kbd>samtools</kbd></font>](#-font-size-4-2---sorting-alignment-and-converting--kbd-samtools--kbd---font-)
- [<font size=4> 3 removing the PCR duplication</font>](#-font-size-4--3-removing-the-pcr-duplication--font-)
- [<font size=4> 4 peak calling <kbd>macs2</kbd> </font>](#-font-size-4--4-peak-calling--kbd-macs2--kbd----font-)
 - [[ChIP.sh](https://github.com/asuang/ChIP_seq/blob/main/ChIP_seq.sh)]

##   <font size=4>1   mapping reads (RNA-seq mappers)</font> ##
Using the RNA-seq mappers , such as <kbd>hisat2</kbd> , <kbd>bowtie</kbd> , <kbd>bowtie2</kbd> or another , mapping the reads against the genome reference and identifying their genomic positions.

```shell
1) bowtie -S -p 16 -m 1 -5 5 -3 10 --best --strata /media/hp/disk1/song/Genomes/NC10/Sequences/WholeGenomeFasta/bowtie/NC10 -1 ${input}_1.fq.gz -2 ${input}_2.fq.gz ${input}/${input}.sam 2>> ../mapping_report.txt

2) bowtie2 -S ${input}.sam -p 16 -5 5 -3 10 -x /media/hp/disk1/song/Genomes/NC10/Sequences/WholeGenomeFasta/bowtie2/NC10 -1 ${input}_1.fq.gz -2 ${input}_2.fq.gz 2>> ../mapping_report.txt
```
##  <font size=4>2   sorting alignment and converting <kbd>samtools</kbd></font> 
Sorting the alignment by the genomic positions or names .
```shell
samtools view -@ 16 -Sb ${line}.sam > ${line}.bam
```
Converting .bam to .sam saves the storage.
```shell
samtools sort -@ 16 ${line}.bam -o ${line}.sort.bam
```
## <font size=4> 3 removing the PCR duplication</font>
We can use the <kbd>picard</kbd> to remove PCR duplication in the pair-end data and choose <kbd>samtools</kbd> to remove PCR duplication in the single-end data.
```shell
1) java -jar ~/picard/picard.jar MarkDuplicates I=${input}.sort.bam O=${input}.sort.markdup.bam M=${input}.markdup.txt
samtools index ${input}.sort.markdup.bam

2) samtools view -bq 1 $input\_sorted.bam > $input.unique.bam
```
Creating the index for the .bam.
```shell
samtools index ${line}.sort.bam
```
Making .bw files
```shell
bamCoverage -b ${input}.sort.markdup.bam -o $input.bw --binSize 10 --normalizeUsing RPGC --effectiveGenomeSize 41000000 --extendReads
```
## <font size=4> 4 peak calling <kbd>macs2</kbd> </font>
Finding  the significant peaks.
```shell
macs2 callpeak -t ${input}.bam -c ../wt_input/wt_input.bam -f BAM -g 4.1e8 -q 0.05 --broad --max-gap 500 -n $input
```
