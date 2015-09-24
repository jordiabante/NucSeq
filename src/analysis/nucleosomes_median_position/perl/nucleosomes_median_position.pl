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
my $cdf_gz = @ARGV[0];
my @cdf_file=();

# Variables
my $score_1 = 0;
my $pos_1 = -1;
my $chr="";
my $new_pos=0;
my $new_score=0;
my $new_id=0;
# Nucleosome parameters
my $med_pos=0;
my $med_score=0;
my $nuc_end=0;
my $nuc_start=0;
# Flags
my $nucleosome_found=0;
my $start_over=0;
my $first_line=1;


# Main
read_cdf();
process_cdf();

# Subs
sub read_cdf
{
    # Read in input file to an array
    my $cdf_fh = gzopen($cdf_gz, "rb") or die("can't open file:$!");
    while ($cdf_fh->gzreadline(my $cdf) > 0)  
    {
        push @cdf_file,$cdf;
    }
    # Close gz file
    $cdf_fh->gzclose();
}

sub process_cdf
{
    # Loop through the array
    PDF:foreach my $CDF (@cdf_file)
    {
        # Chomp new line
        chomp($CDF);
        # Get chr, pos and score
        my @line = split(/\s+/,$CDF);
        $chr=$line[0];
        $new_pos=$line[1] ;
        $new_score=$line[2];
        $new_id=$line[3];
        # Check if nucleosome starts
        if(($start_over==1)or($first_line==1))
        {   
            $nuc_start=$new_pos;
            $start_over=0;
            $first_line=0;
        }
        # Check for median
        if(($score_1<0.5)and($new_score>0.5))
        {
            if((0.5-$score_1)<=($new_score-0.5))
            {
                $med_pos=$pos_1;
                $med_score=$score_1;
            }
            else
            {
                $med_pos=$new_pos;
                $med_score=$new_score;
            }
            $nucleosome_found=1;
        }
        # Check if nucleosome is over
        if(($new_score ==1)and($nucleosome_found==1))
        {   
            $nuc_end=$new_pos;
            print "$chr\t$med_pos\t$med_score\t$nuc_start\t$nuc_end\n"; 
            $start_over=1;
            $nucleosome_found=0;
        }
        # Update scores
        $pos_1 = $new_pos;
        $score_1 = $new_score;
    }
}

