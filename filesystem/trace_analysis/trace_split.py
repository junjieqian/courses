#!/usr/bin/python
# problem1a_trace_split.py
# Junjie Qian, jqian@cse.unl.edu
# python source code for the Problem 1, split 24-hour trace into 24 1-hour traces

import string, os
from decimal import Decimal

from sys import argv
script, filepath = argv
#f = open(filename, 'r')  # open the trace file for read

filedir, name = os.path.split(filepath)
name,ext = os.path.splitext(name)

#if not os.path.exists(filedir):
#    os.mkdir(filedir)

stream = open(filepath, 'r')
line = stream.readline()  # read the first line of the file
lines = stream.readlines()  # read all the lines in the file

partno = 0  # future 1-hour trace filename number

word = string.split(line, ' ') # capture the start timestamp word[0]

for l in lines:
    words = string.split(l, ' ')  # capture the timestamps, words[0]
    partfilename = os.path.join(name + '_' + str(partno) + ext)
    part_stream = open(partfilename, 'a')

    if Decimal(words[0])-Decimal(word[0])<3600:
      # print 'write start %s' % partfilename
       part_stream.write(l)
    else:   
       word[0] = words[0]
       part_stream.close()
       partno = partno + 1


print 'done'

stream.close()

