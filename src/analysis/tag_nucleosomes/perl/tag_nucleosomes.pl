#!/usr/bin/env perl

# Libraries
use strict;
use Compress::Zlib;

# Arguments
my $scriptname = $0;
my $peak_chr_gz = @ARGV[0];
my $smooth_chr_gz = @ARGV[1];

# Variables
my $nucleosome_tag = 1;

# Open peak_chr_file
my $peak_chr_fh = gzopen($peak_chr_gz, "rb") or die("can't open file:$!");

# Loop through the file
while ($peak_chr_fh->gzreadline($_) > 0) 
{
    chomp $_;
    ## Read peak info
    my @line = split(/\s+/, $_);
    my $peak_chr=$line[0];
    my $peak_pos=$line[1] ;
    my $peak_counts=$line[2];
    # Other variables
    my $nucleosome=0;
    my $first_min=1;
    my $first_min_pos=0;
    my $second_min=0;
    my $second_min_pos=0;
    my $prev_pos=0;
    my @window_score = (0) x 200;
    ## Look for the nucleosome in the smooth file
    my $smooth_chr_fh = gzopen($smooth_chr_gz, "rb") or die("can't open file:$!");
    while (($smooth_chr_fh->gzreadline($_) > 0)) 
    {
        chomp $_;
        ## Read smooth info
        my @line = split(/\s+/, $_);
        my $smooth_chr=$line[0];
        my $smooth_pos=$line[1] ;
        my $smooth_counts=$line[2];
        # Fill array
        if(@window_score==200)
        {
            shift @window_score;
        }
        push @window_score,$smooth_counts;
        # Check if positions are equal
        if($smooth_pos==$peak_pos && $first_min==1)
        {
            $nucleosome=1;
        }
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
                if($score>0)
                {    
                    print "$peak_chr\t$i\t$score\t$nucleosome_tag\n";
                }
            }
            # Reset flags
            $first_min=0;
            $second_min=0;
            $nucleosome=0;
            # Increment nucleosome tag
            $nucleosome_tag++;
        }
        # Refresh previous position
        $prev_pos=$smooth_pos;
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
    # Close smooth file
    $smooth_chr_fh->gzclose();
}
$peak_chr_fh->gzclose();
exit;
