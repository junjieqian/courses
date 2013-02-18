#!/usr/bin/python
# problem1b_trace_unique_analysis.py
# Junjie Qian, jqian@cse.unl.edu
# python source code for the Problem 1, analyze 24-hour-long trace and get the unique request sizes for all read and write requests respectively
import string
from decimal import Decimal
from sys import argv
from collections import Counter

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

read_cnt = Counter()
for word in read_list:
    read_cnt[word] += 1
print 'numbers of different requests with different sizes for read requests:'
print read_cnt

write_cnt = Counter()
for word in write_list:
    write_cnt[word] += 1
print 'numbers of different requests with different sizes for write requests:'
print write_cnt

read_unique_list = list(set(read_list))
write_unique_list = list(set(write_list))

print 'unique request size in read requests'
print read_unique_list

print 'unique request size in write requests'
print write_unique_list

