#!/usr/bin/perl

use strict; use warnings; use Getopt::Long; use Data::Dumper;

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn,$fOut);
GetOptions(
				"help|?" =>\&USAGE,
				"o:s"=>\$fOut,
				"i:s"=>\$fIn,
				) or &USAGE;
&USAGE unless ($fIn);

sub USAGE {#
	my $usage=<<"USAGE";
Description:	this program is used to generate look up table for embl id, flybase id and source id
Usage:
  Options:
  -i <file>  input file, required
  -o <file>  output file, not required  
  -h         Help

USAGE
	print $usage;
	exit;
}

open (IN, '<', $fIn) or die $!;

if ($fOut) {
    open (OUT, '>', $fOut);
} else {
    open(OUT, ">&STDOUT");
}

my @lines=();
my @embl_id=();
my @species=();
my @te_name=();
my @fb_id=();
my @source_id=();

#read line of TE file from standard input
while (my $line = <IN>) {
	push (@lines, $line);
}

my $length = @lines;
my $idx = -1;

for (my $i=0; $i<$length; $i++) {
    if ($lines[$i] =~ /^ID/) {
        $idx = $idx + 1;
        my $out = $lines[$i];
        my @out = split(' ', $out);
        $embl_id[$idx] = $out[1];
        push (@fb_id, "");
        push (@source_id, "");
    }
    if ($lines[$i] =~ /^DR/) {
        my $out = $lines[$i];
        my @out = split('; ', $out);
        $fb_id[$idx] = $out[1];
        my $out2 = $out[2];
        $out2 =~ s/\.$//g;
        $out2 =~ s/\\/,/g;
        chomp $out2;
        my @out3 = split(',', $out2);
        $species[$idx] = $out3[0];
        $te_name[$idx] = $out3[1];
    }
    if ($lines[$i] =~ /^FT.*source/) {
        my $out = $lines[$i];
        # print "$out\n";
        my @out = split(' ', $out);
        my $out2 = $out[2];
        $out2 =~ s/:.*//g;
        $out2 =~ s/.*\(//g;
        $source_id[$idx] = $out2;
    }
}

while (@embl_id || @fb_id || @source_id || @species || @te_name) {
   print OUT shift(@embl_id) . "," . shift(@fb_id) . "," . shift(@source_id) . "," . shift(@species) . "," . shift(@te_name) . "\n";
}

close IN;
close OUT;