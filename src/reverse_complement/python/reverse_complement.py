#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL 
#Ignore SIG_PIPE and don't throw exceptions on it... (http://docs.python.org/library/signal.html)
signal(SIGPIPE,SIG_DFL) 

from Bio.Seq import Seq
from sys import stdin
for line in stdin:
    line = line.rstrip('\n')
    print Seq(line).reverse_complement()
