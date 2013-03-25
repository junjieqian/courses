# !/usr/bin/python
# Junjie Qian, jqian@cse.unl.edu
# Problem 3 (1), CSCE837 Homework3
import string
import os, sys
from decimal import Decimal
import matplotlib.pyplot as plt

origi_file = "/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3.parv"

modified_file = "/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3_raid0_diskno.parv"

diskno = []
response_list = []

for i in range(2, 11):
    string = '   devices = [ disk0 '    # write the changed the parameters
    diskno.append(i)
    origin = open(origi_file, 'r')
    modified = open(modified_file, 'w+')
    for line in origin:
        if line.find('   devices = [ d') == 0:
            for j in range (1, i, 1):
                string += ', disk%s '%j
            string += ' ],\n'
            modified.write(string)
     #       print string
        else:
             modified.write(line)
    origin.close()
    modified.close()

    os.system('/home/jqian/courses/disksim-4-0-x64-master/src/disksim hw3p3_raid0_diskno.parv hw3p3_raid0_diskno.outv ascii 0 1')

    temp_file = open('/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3_raid0_diskno.outv', 'r')
    for l in temp_file:
        if l.find('IOdriver Response time average:') == 0:
            word = l.split(': ', 2)
            response_list.append(float(word[1]))
    os.remove('/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3_raid0_diskno.parv')
    temp_file.close()

tmp = range(0, 9, 1)
#print tmp
#print response_list

plt.figure(1)
plt.plot(tmp, response_list, 'ko-')
plt.axis([0,9, 0, 7])
plt.xticks(rotation=60)
plt.xticks(tmp, diskno)
plt.title('Impact of RAID 0 disks numbers on IOdriver Response time average')
plt.xlabel('different disk numbers')
plt.ylabel('IOdriver Response time average')

plt.savefig('impactofraid0diskno.png')
