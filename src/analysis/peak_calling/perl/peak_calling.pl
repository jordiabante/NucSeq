#!/usr/bin/env perl
# ------------------------------------------------------------------------------
##The MIT License (MIT)
##
##Copyright (c) 2015 Jordi Abante
##
##Permission is hereby granted, free of charge, to any person obtaining a copy
##of this software and associated documentation files (the "Software"), to deal
##in the Software without restriction, including without limitation the rights
##to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##copies of the Software, and to permit persons to whom the Software is
##furnished to do so, subject to the following conditions:
##
##The above copyright notice and this permission notice shall be included in all
##copies or substantial portions of the Software.
##
##THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##SOFTWARE.
# ------------------------------------------------------------------------------

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
my $coverage = 0;
my $chr_length = 0;

## Get average coverage
# Open chr_file
my $smooth_fh = gzopen($smooth_gz, "rb") or die("can't open file:$!");
while ($smooth_fh->gzreadline($_) > 0) {
    # Chomp new line
    chomp $_;
    # Get chr, pos and score
    my @line = split(/\s+/, $_);
    my $chr=$line[0];
    my $pos=$line[1] ;
    my $score=$line[2];
    # Update counts
    $sum+=$score;
    $chr_length=$pos;
}
$coverage= $sum / $chr_length;
# Close gz file
$smooth_fh->gzclose();

## Look for significant peaks
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
