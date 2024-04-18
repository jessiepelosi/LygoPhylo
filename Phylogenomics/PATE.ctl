#input and output paths
PHASING_ROOT = /blue/barbazuk/jessiepelosi/local_prgms/Phasing
REF = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/PROBE_ref
GENOTYPE_OUT = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/genotypeOutput
PHASE_OUT = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/PROBE_phased
FASTA_OUT = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/PROBE_fasta_out
IUPAC_OUT = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/PROBE_iupac
SUMMARYSTATS_OUT = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/PROBE_stats
ESTPLOIDY_OUT = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/PROBE_estploidy
FQ = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/trimmed_reads
PLOIDY = /blue/barbazuk/jessiepelosi/lygodium_phylogeny/PATE/allDiploid.txt


#paths to software or just the binaries if already in your path
BWA = bwa 
PICARD = picard
GATK = gatk
SAMTOOLS = samtools
BAMTOOLS = bamtools
BGZIP = bgzip
TABIX = tabix
HPOPG = /blue/barbazuk/jessiepelosi/local_prgms/H-PoPG/H-PoPGv0.2.0.jar
SCHEDULER = sbatch

#Path to the root directory of the helperScripts folder in the PATE repo
HELPERSCRIPTS = /blue/barbazuk/jessiepelosi/local_prgms/Phasing/helperScripts

#gatk filter options
GATK_FILTER_EXPRESSION = "QD < 2.0" "QD_lt2"
GATK_FILTER_EXPRESSION = "FS > 60.0" "FS_gt60"
GATK_FILTER_EXPRESSION = "MQ < 40.0" "MQ_lt40"
GATK_FILTER_EXPRESSION = "ReadPosRankSum < -8.0" "ReadPosRankSum_ltm8"
GATK_FILTER_EXPRESSION = "AF < 0.025" "AF_lt025"
GATK_FILTER_EXPRESSION = "AF > 0.975" "AF_gt975"
GATK_FILTER_EXPRESSION = "DP < 10" "DP_lt10"

#Name of reference individual that matches the header in the reference fasta file
#REFERENCEIND = KJM225

#Should only unique sequences be printed to the fasta files of all phased haplotype sequences (0 = no | 1 = yes)
UNIQUE_ONLY = 1
REMOVE_READ_DUPLICATES = 0
OUTPUT_EXPECTED_DOSAGE = 0
