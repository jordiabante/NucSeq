#!/usr/bin/env perl

# Libraries
use strict;
use Compress::Zlib;

# Inputs
my $scriptname = $0;
my $chr_gz = @ARGV[0];
my $kernel_file = @ARGV[1];
my $bandwidth = @ARGV[2];

# Variables
my $total = 0;
my $length = 0;
my $coverage = 0;

## Check total number of fragments
# Open chr_file
my $chr_fh = gzopen($chr_gz, "rb") or die("can't open file:$!");
# Loop through the file
while ($chr_fh->gzreadline($_) > 0) {
    chomp $_;
    my @line = split(/\s+/, $_);
    my $chr=$line[0];
    my $pos=$line[1] ;
    my $counts=$line[2];
    $total += $counts;
    $length = $pos;
}
$chr_fh->gzclose();

# Estimation of average coverage per base
$coverage = $total / $length;

## Apply kernel and normalize
# Open chr_file
my $chr_fh = gzopen($chr_gz, "rb") or die("can't open file:$!");
# Loop through the file
while ($chr_fh->gzreadline($_) > 0) {
    chomp $_;
    my @line = split(/\s+/, $_);
    my $chr=$line[0];
    my $pos=$line[1] ;
    my $counts=$line[2];
    open ( my $kernel_fh,$kernel_file) or die ("can't open file:$!");
    my $i= $pos - int $bandwidth/2;
    while (my $kernel_value = <$kernel_fh>) {
        chomp $kernel_value;
        my $score= $counts * $kernel_value / $coverage;
        if (($i>=1)&&($score>0)){
            print "$chr\t$i\t$score\n";
        }
        $i++;
    }
}
$chr_fh->gzclose();

exit;
