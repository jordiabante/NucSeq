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
sub cdf;

# Read arguments
my $scriptname = $0;
my $pdf_gz = @ARGV[0];

# Variables
my $score_1 = 0;
my $pos_1 = -1;
my $chr="";
my $new_pos=0;
my $new_score=0;
my @window_pos = ();
my @window_score = ();
my @window_cdf = ();

# Read in input file to an array
my $pdf_fh = gzopen($pdf_gz, "rb") or die("can't open file:$!");
my @pdf_file=();
while ($pdf_fh->gzreadline(my $PDF) > 0)  
{
    push @pdf_file,$PDF;
}
# Close gz file
$pdf_fh->gzclose();

# Loop through the array
PDF:foreach my $PDF (@pdf_file)
{
    # Chomp new line
    chomp($PDF);
    # Get chr, pos and score
    my @line = split(/\s+/,$PDF);
    $chr=$line[0];
    $new_pos=$line[1] ;
    $new_score=$line[2];
    $new_id=$line[3];
    # Check for continuity
    if( $new_pos == $pos_1 + 1 )
    {
        push @window_pos,$new_pos;
        push @window_score,$new_score;
    } 
    else
    {   
        # CDF
        @window_cdf = cdf(\@window_pos,\@window_score);
        # Print
        print_nuc($chr,\@window_pos,\@window_cdf,\@window_score);
        # Re-initialize arrays
        splice(@window_pos);
        splice(@window_score);
        splice(@window_cdf);
    } 
    # Update scores
    $pos_1 = $new_pos;
    $score_1 = $new_score;
}
# Print last group
@window_cdf = cdf(\@window_pos,\@window_score);
print_nuc($chr,\@window_pos,\@window_cdf,\@window_score);

# Subroutine to compute CDF
sub cdf {
    # References
    my $pos_ref = shift;
    my $score_ref = shift;
    # Get arrays
    my @pos = @{$pos_ref};
    my @score = @{$score_ref};
    # Output
    my @cdf=();
    my $sum=0;
    my $dy=0;   
    # Loop through scores
    foreach my $point (@score){
        $sum+=$point;
        push @cdf,$sum;
    }
    # Normalize cdf
    foreach my $x (@cdf) { $x = $x / $sum; }
    # Return cdf
    return @cdf;
}

# Subroutine to print
sub print_nuc {
    # References
    my $chr = shift;
    my $pos_ref = shift;
    my $cdf_ref = shift;
    my $score_ref = shift;
    # Get arrays
    my @pos = @{$pos_ref};
    my @cdf = @{$cdf_ref};
    my @score = @{$score_ref};
    # Print
    print "$chr\t$pos[$_]\t$cdf[$_]\n" for (0 .. $#cdf);
}
