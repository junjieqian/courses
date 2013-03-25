# !/usr/bin/python
# Junjie Qian, jqian@cse.unl.edu
# Problem 4 (1), CSCE837 Homework3
import string
import os, sys
from decimal import Decimal
import matplotlib.pyplot as plt

origi_file = "/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3.parv"

modified_file = "/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p4_raid4.parv"
diskno = []
response_list = []

for i in range(7, 11):
    diskno.append(i)
    origin = open(origi_file, 'r')
    modified = open(modified_file, 'w+')
    string ="    devices = [ disk0"
    for line in origin:
        if line.find("   Redundancy scheme = ") == 0:
            modified.write("   Redundancy scheme = Parity_disk,\n")
        elif line.find("   devices = [ dis") == 0:
            for j in range(1, i):
                string += ", disk%s"%j
            string += " ],\n"
            modified.write(string)
        else:
             modified.write(line)
    origin.close()
    modified.close()

    os.system('/home/jqian/courses/disksim-4-0-x64-master/src/disksim hw3p4_raid4.parv hw3p4_raid4.outv ascii 0 1')

    temp_file = open('/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p4_raid4.outv', 'r')
    for l in temp_file:
        if l.find('Overall I/O System Response time average:') == 0:
            word = l.split(': ', 2)
            response_list.append(float(word[1]))
    os.remove('/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p4_raid4.parv')
    temp_file.close()

tmp = range(0, 4, 1)

plt.figure(1)
plt.plot(tmp, response_list, 'ko-')
plt.axis([0,4, 60, 70])
#plt.xticks(rotation=60)
plt.xticks(tmp, diskno)
plt.title('Impact of RAID 4 disks numbers on IOdriver Response time average')
plt.xlabel('different disk numbers')
plt.ylabel('Overall I/O System Response time average')

plt.savefig('impactofraid4diskno.png')
