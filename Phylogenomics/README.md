# Assemblies 
Sequence data were filtered, trimmed, and assembled using the scripts available from [Breinholt et al. (2021)](https://bsapubs.onlinelibrary.wiley.com/doi/full/10.1002/aps3.11406). This is a series of perl scripts that uses an iterative baited assembly (IBA) approach. 

## HybPiper

We used [HyPiper ver 2.0.1](https://github.com/mossmatters/HybPiper) to also assemble the nuclear target loci from trimmed reads for each sample. 
```
hybpiper assemble --cpu 16 -t_dna hybpiperRefSeqs.cat.fasta -r trimmed_reads/"$name"*.fq.gz --prefix "$name" --bwa
```
To get supercontigs, we then ran:
```
hybpiper assemble --run_intronerate --start_from exonerate_contigs --cpu 16 -t_dna hybpiperRefSeqs.cat.fasta -r "$name"*.fq.gz --prefix "$name" --bwa
```
General statistics for each dataset were generated with the folllowing commands: 
```
hybpiper stats -t_dna hybpiperRefSeqs.cat.fasta gene name.list 
hybpiper stats -t_dna hybpiperRefSeqs.cat.fasta supercontig name.list
```

# Nuclear Phylogenomics 
Using the output from either HybPiper or the GoFlag pipeline: 

Each locus was aligned with [MAFFT ver 7.490](https://academic.oup.com/nar/article/33/2/511/2549118?login=false). 
```
mafft --thread 4 --adjustdirectionaccurately --allowshift --unalignlevel 0.8 --leavegappyregion --maxiterate 5 --globalpair $file > $file.aln
```

For the GoFlag data, we removed columns with less than 4 tips present using the perl script `deletecol_13Aug.pl`. For the HybPiper alignments, we removed columns with >80% missing tips using [trimAl ver 1.4.1](http://trimal.cgenomics.org/trimal). 

```
trimal -in $file.aln -out $file.aln.trim -gt 0.2
```

Gene trees were generated with [IQTREE ver 2.1.3](https://academic.oup.com/mbe/article/37/5/1530/5721363). 
```
iqtree2 -s $file -m MFP --alrt 1000 -B 1000 --redo -T 1
```

Species trees were generated with [ASTRAL ver 5.7.7](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-018-2129-y). 
```
cat *.treefile > genetrees.tre 
astral -in genetrees.tre -out speciestree.tre 
```


# Plastid Phylogenomics 
Plastid genes were assembled from filtereed and trimmed reads using [GetOrganelle ver 1.7.3.5](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-020-02154-5).  
```
get_organelle_from_reads.py -1 $file.R1.fq.gz -2 $file.R2.fq.gz -o $file -R 15 -k 21,45,65,85,95,105 -F embplant_pt -s fern_plastomes.fasta
```

[PhyloHerb ver 1.1](https://bsapubs.onlinelibrary.wiley.com/doi/10.1002/aps3.11475) was then used to assemble orthologous loci.
```
python phyloherb.py -i fern_fastas/ -o fern_asm -m ortho -suffix .fasta
```

We used MAFFT and IQTREE to generate individual gene trees for each locus and assessed them individually for strange artifacts. After removing sequences that were suspect, we concatenated the reamining loci and generated a maximum-likelihood species tree with partitioning the matrix by locus. 

# Allelic Phasing 

Multiple different pipelines were used to assess allele phasing in the <i>Lygodium</i> dataset. 

## PATÉ
We used [PATÉ](https://www.biorxiv.org/content/10.1101/2021.05.04.442457v1) to phase alleles based on the target and target+flanking regions. 
```
perl PATE.pl --controlFile PATE.ctl --runmode species --template template.sh --genotype consensus
perl PATE.pl --controlFile PATE.ctl --runmode alleles --template template.sh --genotype consensus
```

Again, we used MAFFT and IQTREE to generate gene trees for each locus. We assessed each tree individually and manually assigned putative subgenomes to each allele where possible. We distributed these alleles into their respective original locus alignments using a custom python script. 
```
python distribute_alleles.py -l $locus -i $locus.fasta -p $locus_Phased.fasta -s subgenomes.csv 
```
With the alleles now in their appropriate loci, we re-aligned and generated new gene trees and a species tree as above. 

## Homologizer 

The 20 loci with the greatest taxon occupancy from the PATÉ phasing were used as input for [homologizer](https://github.com/wf8/homologizer/tree/main) in RevBayes 1.1. We used a multi-processor version of homologizer to run the program more efficiently. 
```
mpirun -np 6 rb-mpi lygodium_homologizer.rev
```
The data and scripts for running homologizer are available under `Phylogenomics/homologizer/`. 

## HybPhaser 

We further used [HybPhaser ver 2.0](https://github.com/LarsNauheimer/HybPhaser) to phase alleles.

The first step in HybPhaser was to generate consensus sequences by re-mapping sample reads to the output from HybPiper. 
```
bash 1_generate_consensus_sequences.sh -s $sample -o HybPhaser_out -p ../HybPiper
```
Several R scripts are then run to generate basic statistics and filter the resulting consensus sequences. Note that I made some minor changes to 1b and 1c as there were issues with the ones provided in the HybPhaser repository (these scripts can be found in this directory). 
```
Rscript 1a_count_snps.R
Rscript 1b_assess_dataset_JAP.R
Rscript_1c_generate_sequence_lists_JAP.R
```
The reads mapping to the output from HybPiper are then extracted from the total set of reads. 
```
bash 2_extract_mapped_reads.sh -p ./
```
The R script `2a_prepare_bbsplit_script.R` is then run to generate the bash scripts to run bbsplit (simultaneous mapping to the designated references). 



