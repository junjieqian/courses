# !/usr/bin/python
# Junjie Qian, jqian@cse.unl.edu
# Problem 4 (2), CSCE837 Homework3
import string
import os, sys
from decimal import Decimal
import matplotlib.pyplot as plt

origi_file = "/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3.parv"

modified_file = "/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p4_raid5.parv"

ratio = []
response_list = []

for i in range(0, 11):
    ratio.append("%s%%"%int(i*10))
    origin = open(origi_file, 'r')
    modified = open(modified_file, 'w+')
    for line in origin:
        if line.find("   Redundancy scheme = ") == 0:
            modified.write("   Redundancy scheme = Parity_rotated,\n")
        elif line.find("   Probability of read access = ") == 0:
            modified.write("   Probability of read access =  %s,\n"%float(i*0.1))
        elif line.find("   devices = [ dis") == 0:
            modified.write("   devices = [ disk0, disk1, disk2, disk3, disk4, disk5, disk6, disk7, disk8, disk9 ],\n")
        else:
            modified.write(line)
    origin.close()
    modified.close()

    os.system('/home/jqian/courses/disksim-4-0-x64-master/src/disksim hw3p4_raid5.parv hw3p4_raid5.outv ascii 0 1')

    temp_file = open('/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p4_raid5.outv', 'r')
    for l in temp_file:
        if l.find('Overall I/O System Response time average:') == 0:
            word = l.split(': ', 2)
            response_list.append(float(word[1]))
    os.remove('/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p4_raid5.parv')
    temp_file.close()

tmp = range(0, 11, 1)
print tmp
print ratio
print response_list

plt.figure(1)
plt.plot(tmp, response_list, 'ko-')
plt.axis([0, 10, 9, 20])
#plt.xticks(rotation=60)
plt.xticks(tmp, ratio)
plt.title('Impact of RAID 5 disks numbers on IOdriver Response time average')
plt.xlabel('different disk numbers')
plt.ylabel('Overall I/O System Response time average')

plt.savefig('impactofraid5diskno.png')
