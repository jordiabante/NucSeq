#!/usr/bin/env perl

# Libraries
use strict;

# Input variables
my $scriptname = $0;
my $bandwidth = @ARGV[0];

# Gaussian pdf
my $sigma = $bandwidth/7.5;
my $sd = 2 * $sigma * $sigma;

# Other variables
my @kernel = [0..($bandwidth-1)];
my $sum = 0;
my $lim_inf = 0;
my $lim_sup = $bandwidth -1;
my $x = 0;

# Fill kernel
for (my $i = $lim_inf; $i <= $lim_sup; $i++)
{
    $x=$i-($bandwidth-1)/2;  
    $kernel[$i] = (exp(-($x*$x)/$sd))/(3.14159 * $sd); 
    $sum += $kernel[$i];
}   
 
# Normalize the Kernel
for(my $i = $lim_inf; $i <= $lim_sup ; $i++){
    $kernel[$i] /= $sum;
}   

# Print kernel
foreach (@kernel) {
    print "$_\n";
}

exit
