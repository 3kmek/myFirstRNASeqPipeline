#!/bin/bash
 
SECONDS=0

#1 go to script containing directory
#cd SecondPipeline/scripts/

#2 trimleme isleminin gerekli olup olmadigina karar vermek icin fastqc
fastqc 1_rawdata/rna-seq.fastq -o 2_fastqc_before/

#3 trimmomatic
java -jar ~/tools/trimmomatic/Trimmomatic-0.39/trimmomatic-0.39.jar SE -threads 4 1_rawdata/rna-seq.fastq 3_trimmeddata/rna-seq_trimmed.fastq TRAILING:10 -phred33
echo "Trimmomatic finished running!"

#4 fastqc after
fastqc 3_trimmeddata/rna-seq_trimmed.fastq -o 4_fastqc_after/
echo "New FastQC report is ready."

#5 hisat2 alignment
echo "HISAT2 alignment has just started."
hisat2 -q --rna-strandness R -x reference_hisat2index/grch38/genome -U 3_trimmeddata/rna-seq_trimmed.fastq | samtools sort -o reference_hisat2index/alignment/rna-seq_trimmed.bam
echo "HISAT2 alignment has finished."

#6 featureCounts - quantification
echo "featureCounts - quantification has just started."
featureCounts -S 2 -a reference_gtf/Homo_sapiens.GRCh38.111.gtf -o 5_quants/rna-seq_trimmed_featurecounts.txt reference_hisat2index/alignment/rna-seq_trimmed.bam 
echo "featureCounts - quantification has finished."

cat 5_quants/rna-seq_trimmed_featurecounts.txt | cut -f1,7 > 5_quants/rna-seq_trimmed_featurecounts_cut.txt

duration=$SECONDS
echo "This pipeline took $(($duration / 60)) minutes and $(($duration % 60)) seconds."



