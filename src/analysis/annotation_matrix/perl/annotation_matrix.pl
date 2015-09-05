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
#use strict;
use Compress::Zlib;

# Read arguments
my $scriptname = $0;
my $input_gz = @ARGV[0];

# Variables
my %gff=();         # Hash containing the annotation info
my %matrix=();      # Hash containing the output matrix
my @input=();       # Array containing the input content

## Main
read_input();
get_gff();
build_matrix();
#print_gff();
#print_input();

## Read in input file
sub read_input
{
    # Open the peaks file
    my $input_fh = gzopen($input_gz, "rb") or die("Can't open file:'$input_gz'\n$!");
    # Parse the input file
    while ($input_fh->gzreadline(my $line) > 0) 
    {
        # Chomp new line
        chomp $line;
        # Push array
        push @input,$line;
    }
    # Close the input file
    $input_fh->gzclose();
}

## Deduce the features
sub get_gff
{
    LINE:foreach my $line (@input)
    {
        my @line = split "\t", $line;
        # Skip line if the feature is already stored
        next LINE if(exists($gff{@line[3]}));
        # Store the feature
        $gff{@line[3]}{start}=@line[4];   # Start
        $gff{@line[3]}{end}=@line[5];     # End
        $gff{@line[3]}{strand}=@line[6];  # Strand
    }
}

## Build matrix
sub build_matrix
{
    foreach my $key (keys %gff)
    {
        ## Construct row
        my @row=($gff{$key}{start}..$gff{$key}{end});
        ## Matrix
        foreach my $coord (@row) 
        {
            $matrix{$key}{$coord}=0; 
        }       
        ## Values
        LINE:foreach my $line (@input)
        {
            my @line = split "\t", $line;
            next LINE unless ($line[3] eq $key);
            # Assign the score to the position
            $matrix{$key}{$line[1]}=$line[2];
        }
        ## Print row
        print "$key\t";
        if($gff{$key}{strand} eq "+")
        {
            foreach my $coord  (sort keys %{$matrix{$key}})
            {
                    print "$matrix{$key}{$coord}\t";
            }
        }
        else
        {
            foreach my $coord  (reverse sort keys %{$matrix{$key}})
            {
                    print "$matrix{$key}{$coord}\t";
            }

        }       
        print "\n";
    }
}

## Print gff
sub print_gff
{
    foreach my $key (sort keys %gff)
    {   
        print STDERR "$key\t$gff{$key}{start}\t$gff{$key}{end}\t$gff{$key}{strand}\n";
    }   
}

## Print input
sub print_input
{
    foreach my $line (@input)
    {
        print STDERR "$line\n";
    }
}
