#!/usr/bin/python
# problem1b_trace_size_analysis.py
# Junjie Qian, jqian@cse.unl.edu
# python source code for the Problem 1b, analyze 24-hour trace and get the different request sizes

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
       read_list.append(words[3])
    else:
       write_list.append(words[3])

i = len(read_list)
j = len(write_list)
read_sum = 0

for m in range (0, i-1, 1):
    read_sum += Decimal(read_list[m])

read_min = min(read_list)
read_max = max(read_list)
read_mean = read_sum/i

read_list.sort()
if i%2 == 0:
   read_media = read_list[i/2]
else:
   read_media = (Decimal(read_list[(i+1)/2]) + Decimal(read_list[(i-1)/2]))/2

print 'read requests sizes in sector'
print read_min, read_max, read_mean, read_media

write_sum = 0

for m in range (0, j-1, 1):
    write_sum += Decimal(write_list[m])

write_min = min(write_list)
write_max = max(write_list)
write_mean = write_sum/j

write_list.sort()
if j%2 == 0:
   write_media = write_list[j/2]
else:
   write_media = (Decimal(write_list[(j+1)/2]) + Decimal(write_list[(j-1)/2]))/2

print 'write requests sizes in sector'
print write_min, write_max, write_mean, write_media
