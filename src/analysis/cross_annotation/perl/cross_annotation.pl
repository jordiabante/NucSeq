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
my $input_gz = @ARGV[0];
my $reference = @ARGV[1];

# Variables
my %gff=();         # Hash table containing annotation file
my @input=();       # Array containing the input content

## Main
read_gff();
read_input();
cross();
#print_gff();
#print_input();

## Read in gff file
sub read_gff
{
    open REFERENCE, $reference or die $!;
    while (my $feat = <REFERENCE>){
        # Chomp new line
        chomp $feat;
        # Get info from the feature
        my @feature = split "\t", $feat; 
        my $feature_id=$feature[8];
        # Add feature to hash table
        if (exists($gff{$feature_id}))
        {
            print STDERR "Repeated features in the gff file $reference.\n";
        }
        else
        {
            $gff{$feature_id}=[@feature];
        }
    }
    # Close files
    close REFERENCE or die $!;
}

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

## Where the magic happens
sub cross
{
    foreach my $key (keys %gff)
    {
        COORD:foreach my $line (@input)
        {
            my @line = split "\t", $line; 
            # Next feature if chromosomes are not equal
            next COORD unless (@{$gff{$key}}[0] eq @line[0]);
            # Next feature if position in input is greater than feature's
            next COORD if (@line[1] > @{$gff{$key}}[4]);
            # Check if input's position falls inside the feature area
            if ((@{$gff{$key}}[3] <= @line[1]) and (@{$gff{$key}}[4] >= @line[1]))
            {
                # Print
                print "@line[0]\t@line[1]\t@line[2]\t";
                print "@{$gff{$key}}[8]\t@{$gff{$key}}[3]\t@{$gff{$key}}[4]\t@{$gff{$key}}[6]\n";
            }

        }
    }
}

## Print gff
sub print_gff
{
    foreach my $key (sort keys %gff)
    {
        print "@{$gff{$key}}\n";
    }
}

## Print input
sub print_input
{
    foreach my $line (@input)
    {
        print "$line\n";
    }
}
