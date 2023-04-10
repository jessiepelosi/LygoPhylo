# Usage: python get_longest.py file.fasta > outfile.fasta 
# Purpose: get the longest sequence in a fasta file 
#From Devon Ryan, https://bioinformatics.stackexchange.com/questions/595/how-can-longest-isoforms-per-gene-be-extracted-from-a-fasta-file

#!/usr/bin/env python
from Bio import SeqIO
import sys

lastGene = None
longest = (None, None)
for rec in SeqIO.parse(sys.argv[1], "fasta"):
    gene = rec.id
   # print(gene)
    l = len(rec)
    if lastGene is not None:
        if gene == lastGene:
            if longest[0] < l:
                longest = (l, rec)
        else:
            lastGene = gene
            SeqIO.write(longest[1], sys.stdout, "fasta")
            longest = (l, rec)
    else:
        lastGene = gene
        longest = (l, rec)
SeqIO.write(longest[1], sys.stdout, "fasta")
