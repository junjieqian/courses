#!/usr/bin/python
# problem1a_trace_analysis.py
# Junjie Qian, jqian@cse.unl.edu
# python source code for the Problem 1, analyze each 1-hour trace and get the inter-arrival times

import string
from decimal import Decimal
from sys import argv

script, filename = argv

f = open(filename, 'r')

# read in the lines of the file
lines = f.readlines()
f.close()

temp = 0 # for future store information

read_list = []
write_list = []

for l in lines:
    words = string.split(l, ' ')
    inter_arrival = Decimal(words[0]) - temp
    temp = Decimal(words[0])
    if Decimal(words[4]) == 1:
       read_list.append(inter_arrival)
    else:
       write_list.append(inter_arrival)

read_list.sort()
write_list.sort()

# compute values for read requests
i = len(read_list)

if i ==0:
   read_min = 0
   read_max = 0
   read_mean = 0
   read_media =0
else:
   read_sum = 0
   for m in range(0, i, 1):
         read_sum += Decimal(read_list[m])
   read_min = min(read_list)
   read_max = max(read_list)
   read_mean = read_sum/i
   if i%2 == 0:
        read_media = (Decimal(read_list[i/2]) + Decimal(read_list[1+i/2]))/2
   else:
        read_media = Decimal(read_list[(i-1)/2])



# compute values for write requests
j = len(write_list)
write_sum = 0
for n in range(0, j, 1):
    write_sum += Decimal(write_list[n])

write_min = min(write_list)
write_max = max(write_list)
write_mean = write_sum/j

if j%2 == 0:
   write_media = (Decimal(write_list[j/2]) + Decimal(write_list[1+j/2]))/2
else:
   write_media = Decimal(write_list[(j-1)/2])
    
print 'read_min, read_max, read_mean, read_media'
print read_min, read_max, read_mean, read_media

print 'write_min, write_max, write_mean, write_media'
print write_min, write_max, write_mean, write_media


