#!/usr/bin/env perl

# Libraries
use strict;
use Compress::Zlib;

# Read arguments
my $scriptname = $0;
my $peaks_gz = @ARGV[0];
my $reference = @ARGV[1];

# Variables

# Open reference file
open REFERENCE, $reference or die $!;

# Loop through the file
while (my $feat = <REFERENCE>){
    # Chomp new line
    chomp $feat;
    # Get info from the feature
    my ($feat_chr,$feat_origin,$feat_type,$feat_st,$feat_end,$junk,$feat_strand,$junk,$feat_id)=split "\t", $feat; 
    # Open the peaks file
    my $peaks_fh = gzopen($peaks_gz, "rb") or die("can't open file:'$peaks_gz' $!");
    # Parse the peaks file
    while ($peaks_fh->gzreadline($_) > 0) {
        # Chomp new line
        chomp $_;
        # Get chr, pos and score
        my ($peak_chr, $peak_pos, $peak_score,$nucleosome)=split "\t", $_;
        if (($feat_chr eq $peak_chr) && ($feat_st <= $peak_pos) && ($feat_end >= $peak_pos)){
            my $score = sprintf '%.4f', "$peak_score";
            print "$peak_chr\t$peak_pos\t$score\t$nucleosome\t$feat_id\t$feat_st\t$feat_end\t$feat_strand\n";
        }
    }
    # Close the peaks file
    $peaks_fh->gzclose();
}

# Close files
close REFERENCE or die $!;

# Exit
exit;
