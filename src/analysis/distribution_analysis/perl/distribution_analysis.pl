#!/usr/bin/env perl

# Libraries
use strict;
use Compress::Zlib;

# Read arguments
my $scriptname = $0;
my $smooth_gz = @ARGV[0];

# Variables
my $score_1 = 0;
my $pos_1 = 0;
my $score_2 = 0; 
my $pos_2 = 0;
my $sum =0;
my $coverage =0;

# Open chr_file
my $smooth_fh = gzopen($smooth_gz, "rb") or die("can't open file:$!");

# Loop through the file
while ($smooth_fh->gzreadline($_) > 0) {
    # Chomp new line
    chomp $_;
    # Get chr, pos and score
    my @line = split(/\s+/, $_);
    my $chr=$line[0];
    my $new_pos=$line[1] ;
    my $new_score=$line[2];
    # Update coverage
    $sum += $new_score;
    $coverage = $sum / $new_pos;
    # Look for local maximum
    if (($score_2 < $score_1) && ($score_1 > $new_score) && ($new_score > $coverage )){
        print "$chr\t$pos_1\t$score_1\n";
    }
    # Update scores
    $pos_2 = $pos_1;
    $score_2 = $score_1;
    $pos_1 = $new_pos;
    $score_1 = $new_score;
}

# Close gz file
$smooth_fh->gzclose();

# Exit
exit;
