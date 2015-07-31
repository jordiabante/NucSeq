#!/usr/bin/env perl

# Libraries
use strict;
use Compress::Zlib;

# Variables
my $scriptname = $0;
my $chr_gz = @ARGV[0];
my $kernel_file = @ARGV[1];
my $bandwidth = @ARGV[2];

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
        my $score= $counts * $kernel_value;
        print "$chr\t$i\t$score\n";
        $i++;
    }
}
$chr_fh->gzclose();
exit;
