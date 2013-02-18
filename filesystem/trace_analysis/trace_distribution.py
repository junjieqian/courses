#!/usr/bin/python
# problem1b_trace_distribution.py
# Junjie Qian, jqian@cse.unl.edu
# python source code for the Problem 1b, analyze 24-hour trace and get the different request sizes
from __future__ import division

import string
from decimal import Decimal
from sys import argv


script, filename = argv

f = open(filename, 'r')

lines = f.readlines()

read_list = []
write_list = []

for l in lines:
    words = string.split(l, ' ')
    if int(words[4]) == 1:
       read_list.append(Decimal(words[3]))
    else:
       write_list.append(Decimal(words[3]))

i = len(read_list)
j = len(write_list)

read_list.sort()
write_list.sort()

read_cnt = 0
temp = read_list[0]

for m in range(0, i, 1):
    if read_list[m] == temp:
#       read_cnt += 1
       temp = read_list[m]
       read_cnt += 1
    else:
       pert = read_cnt/i
       print str(read_list[m]) + '::::::::::::::'  +  str(pert)
       temp = read_list[m]


write_cnt = 0
temp2 = write_list[0]

for n in range(0, j, 1):
    if write_list[n] == temp2:
#       read_cnt += 1
       temp2 = write_list[n]
       write_cnt += 1
    else:
       pert2 = write_cnt/j
       print str(write_list[n]) + '::::::::::::::'  +  str(pert2)
       temp2 = write_list[n]

