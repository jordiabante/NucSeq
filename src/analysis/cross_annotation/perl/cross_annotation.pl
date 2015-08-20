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
