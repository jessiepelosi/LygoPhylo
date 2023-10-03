# Assembly 
Sequence data were filtered, trimmed, and assembled using the scripts available from [Breinholt et al. (2021)](https://bsapubs.onlinelibrary.wiley.com/doi/full/10.1002/aps3.11406). This is a series of perl scripts that uses an iterative baited assembly (IBA) approach. 

# Nuclear Phylogenomics
Each locus was aligned with [MAFFT ver 7.490](https://academic.oup.com/nar/article/33/2/511/2549118?login=false). 
```
mafft --thread 4 --adjustdirectionaccurately --allowshift --unalignlevel 0.8 --leavegappyregion --maxiterate 5 --globalpair $file > $file.aln
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

