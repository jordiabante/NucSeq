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
my $window_gz = @ARGV[0];

# Variables
my $center = 0;
my $string = '+';
my $start = 0;
my $end = 0;

# Arrays
my @negative = ();
my @positive = ();

########### MAIN ##########
read_file();


############################


########### SUBS ##########
sub read_file {
    # Read in input file to an array
    my $window_fh = gzopen($window_gz, "rb") or die("can't open file:$!");
    my @window_file=();
    while ($window_fh->gzreadline(my $window) > 0)  
    {
        push @window_file,$window;
    }
    # Loop through the array
    NUC:foreach my $NUC (@window_file)
    {
        # Chomp new line
        chomp($NUC);
        # Get chr, pos and score
        my @line = split(/\s+/,$NUC);
        $chr=$line[0];
        $pos=$line[1] ;
        $junk=$line[2];
        $junk=$line[3];
    # Close gz file
    $window_fh->gzclose();
}

sub label_nucleosomes {
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
