#!/usr/bin/perl -w

# Written by J. Goron Burleigh 

#This script opens all *.phy files in a directory
#It prunes all of these alignments to remove columns with
#less that $minpercent characters.
#It outputs files called *.pruned.nex

#minimum amount of data required to keep a column 
#Right now I set the minimum number of characters to 4 in the line $minnum = 4;. 
#If you want to change it to a percentage, uncomment the next line and the line that says $minnum = $minpercent * $numtax;.
#$minpercent = 0.2;

#$TOTAL = 0;
system "ls -l *nodups.phy >filenames";

open FHx, "<filenames";

while (<FHx>)
{

#open each nexus file
    if (/(\S+).phy/ && ! /prune/)
    {
	$file = $1;
	print "$file\n";
	open FH, "<$file.phy";
	$ok = 0;
	%columnhash = ();

#Read through the nexus file
#count number of a,c,g, or t characters in each column
	while (<FH>)
	{
	    if (/^(\d+)\s+(\d+)/)
	    {
		$numtax = $1;
		$nchar = $2;
		$ok++;
	    }


	    elsif (/^\S+\s+(\S+)/ && $ok > 0)
	    {
		$seq = $1;
#turning each sequence into an array of characters
		@seqarray = split('',$seq);
		$char = 0;
		for $nuc(@seqarray)
		{
		    $char++;
#I have a hash- the keys are the column numbers.  The values are the number of times an a,c,g, or t is in the column.
		    if ($nuc =~ m/[A-Z]/)
		    {
			$columnhash{$char}++;
		    }
		}
	    }
	}
	close FH;

#now I will count how many alignment columns characters meet minimum requirement
#	$minnum = $minpercent * $numtax;
	$minnum = 4;
	$keepchars = 0;

	for (1..$nchar)
	{
	    $count = $_;
#	    print "$count\t$columnhash{$count}\n";
	    if (exists $columnhash{$count})
	    {
		if ($columnhash{$count} >= $minnum)
		{
		    $keepchars++;
		}
	    }
	}

#	print "$file\t$keepchars\n";

#	$TOTAL = $TOTAL + $keepchars;
    
#	print "$minpercent\t$TOTAL\n";

#now i will open a new nexus file for the pruned data
#I will print only the columns with data in more than $minpercent of the cells

	open FH2, "<$file.phy";
	open OUT, ">$file.prune.phy";
	print OUT "$numtax $keepchars\n";

	while (<FH2>)
	{
	    if (/^(\S+)\s+(\S+)/ && ! /^\d+/)
	    {
		$TAX = $1;
		$SEQ = $2;
		print OUT "$TAX\t";
		@SEQARRAY = split('',$SEQ);
		$NUM = 0;
		for $NUC(@SEQARRAY)
		{
		    $NUM++;
		    if (exists $columnhash{$NUM})
		    {
			if ($columnhash{$NUM} >= $minnum)
			{
			    print OUT "$NUC";
			}
		    }
		}
		print OUT "\n";
	    }
	}
	close FH2;
    }
}

	    
