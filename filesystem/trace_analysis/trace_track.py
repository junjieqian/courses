#!/usr/bin/python
# problem1_trace_capture.py
# Junjie Qian, jqian@cse.unl.edu
# python source code for the Problem 1, track 24-hour trace from 1-month trace
import string
import os
from decimal import Decimal
from sys import argv

script, filename = argv

f = open(filename)

lines = f.readlines()

f0 = file('prxy_24_tmp.csv', 'w')  # f0, the 24-hour trace file

for l in lines:
     if l.find('128167255024360895') == -1:
        f0.write(l)
     else:
        break

f0.close()

f1 = file('prxy_24_tmp.csv', 'r')
f2 = file('prxy_24_hour.csv', 'w')

line = f1.readlines()
for l0 in line:
     words = string.split(l0, ',')

# reorganize different columns in the trace file, and put into the new trace file

     Timestamp = Decimal(words[0])/10000000
     diskid = 0
     sector_offset = int(words[4])/512
     sector_size = int(words[5])/512
     if words[3] == 'Write':
          Type = 0
     else:
          Type = 1
     response_time = float(words[6])/10000

     f2.write(str(Timestamp))
     f2.write(' ' )
     f2.write(str(diskid))
     f2.write(' ' )
     f2.write(str(sector_offset))
     f2.write(' ')
     f2.write(str(sector_size))
     f2.write(' ')
     f2.write(str(Type))
     f2.write(' ')
     f2.write(str(response_time))
     f2.write(' ')
     f2.write('\n')
#     print 'done'

f1.close()
f2.close()

#os.remove('prxy_24.csv')
