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

# Arguments
my $scriptname = $0;
my $peak_chr_gz = @ARGV[0];
my $smooth_chr_gz = @ARGV[1];

# Variables
my $nucleosome_tag = 1;

# Copy peaks to an array
my $peak_chr_fh = gzopen($peak_chr_gz, "rb") or die("can't open file:$!");
my @peak_file=();
while ($peak_chr_fh->gzreadline(my $PEAK) > 0) 
{
    push @peak_file,$PEAK;
}
# Copy smooth to an array
my $smooth_chr_fh = gzopen($smooth_chr_gz, "rb") or die("can't open file:$!");
my @smooth_file=();
while ($smooth_chr_fh->gzreadline(my $SMOOTH) > 0) 
{
    push @smooth_file,$SMOOTH;
}
# Close gz files
$peak_chr_fh->gzclose();
$smooth_chr_fh->gzclose();

# Loop through the arrays
PEAK:foreach my $PEAK (@peak_file)
{
    ## Read peak info
    my @line = split(/\s+/,$PEAK);
    my $peak_chr=$line[0];
    my $peak_pos=$line[1] ;
    my $peak_counts=$line[2];
    # Other variables
    my $smooth_sentinel=0;
    my $nucleosome=0;
    my $nucleosome_flag=0;
    my $first_min=1;
    my $first_min_pos=0;
    my $second_min=0;
    my $second_min_pos=0;
    my $prev_pos=0;
    my @window_score = (0) x 250;
    SMOOTH: foreach my $SMOOTH (@smooth_file) 
    {
        ## Read smooth info
        my @line = split(/\s+/,$SMOOTH);
        my $smooth_pos=$line[1] ;
        # Check if the area in the smooth file is near the peak position
        next SMOOTH unless (($peak_pos-$smooth_pos)<=125);
        ## Read the rest of smooth info
        my $smooth_chr=$line[0];
        my $smooth_counts=$line[2];
        # Fill array
        if(@window_score==250){shift @window_score};
        push @window_score,$smooth_counts;
        # Check if positions are equal
        if($smooth_pos==$peak_pos && $first_min==1){$nucleosome=1};
        # Check for local minimum
        if(($window_score[-3]>$window_score[-2])&&($window_score[-2]<$window_score[-1])){
            if($first_min==0)
            {
                $first_min=1;
                $first_min_pos=$prev_pos;
            }
            elsif( $first_min==1 && $nucleosome==1 )
            {
                $second_min=1;
                $second_min_pos=$prev_pos;
            }
            else
            {
                $first_min=1;
                $first_min_pos=$smooth_pos;
                $nucleosome=0;
            }   
        }
        # Print nucleosome
        if (($first_min==1)&&($nucleosome==1)&&($second_min==1))
        {
            for(my $i=$first_min_pos; $i <= $second_min_pos; $i++)
            {
                my $diff=-2-($second_min_pos-$i);
                my $score=$window_score[$diff];
                if($score>0){print "$peak_chr\t$i\t$score\t$nucleosome_tag\n"};
            }
            # Remove nucleosome from smooth array
#            my $nucleosome_length=$second_min_pos-$first_min_pos;
#            my $offset=$smooth_sentinel-$nucleosome_length;
#            splice @smooth_file,$offset,$nucleosome_length;
            # Reset flags
            $first_min=0;
            $second_min=0;
            $nucleosome=0;
            # Increment nucleosome tag
            $nucleosome_tag++;
            # Stop the loop
            $nucleosome_flag=1;
        }
        # Refresh previous position
        $prev_pos=$smooth_pos;
        # Increase sentinel
        $smooth_sentinel++;
        ## Stop parsing if the nucleosome has been found
        last SMOOTH if $nucleosome_flag==1;
    }
    # Print the last nucleosome
    if ( $first_min==1 && $nucleosome==1 )
    {
        for(my $i=$first_min_pos; $i <= $prev_pos; $i++)
        {
            my $diff=-2-($prev_pos-1-$i);
            my $score=$window_score[$diff];
            print "$peak_chr\t$i\t$score\t$nucleosome_tag\n";
        }
    }
}
