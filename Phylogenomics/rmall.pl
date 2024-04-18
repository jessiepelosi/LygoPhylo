#!/usr/bin/perl -w

# Written by Gordon Burleigh

@filearray = glob("L*.afterMerge.mafft.oneline.fasta");

for $file(@filearray)
{
    if ($file =~ m/L(\d+).afterMerge.mafft.oneline.fasta/)
    {
	$filenum = $1;
	open FH, "<$file";
	$len = 0;
	%namehash = ();
	while (<FH>)
	{
	    if (/^>(\S+)\.\d+/)
	    {
		$name = $1;
		if (! exists $namehash{$name})
		{
		    $namehash{$name} = 1;
		}
		else {$namehash{$name}++;}
	    }
	    elsif (/^(\S+)/)
	    {
		$len = length $1;
	    }
	}
	close FH;

	$num = 0;
	for $temp(keys %namehash)
	{
	    if ($namehash{$temp} == 1)
	    {
		$num++;
	    }
	}

	if ($num > 3)
	{
	    open OUT, ">L$filenum.nodups.phy";
	    print OUT "$num $len\n";
	    $ok = 0;
	    open FH2, "<$file";
	    while (<FH2>)
	    {
		if (/^>(\S+)\.\d+/)
		{
		    $Name = $1;
		    if ($namehash{$Name} == 1)
		    {
			print OUT "$Name\t";
			$ok = 1;
		    }
		    else {$ok = 0;}
		}
		elsif ((/^(\S+)/) && ($ok == 1))
		{
		    print OUT "$1\n";
		}
	    }
	    close FH2;
	    close OUT;
	}
    }
}

	    
