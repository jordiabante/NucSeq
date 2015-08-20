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
