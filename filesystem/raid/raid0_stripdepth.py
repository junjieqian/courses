# !/usr/bin/python
# Junjie Qian, jqian@cse.unl.edu
# Problem 3 (2), CSCE837 Homework3
import string, math
import os, sys
from decimal import Decimal
import matplotlib.pyplot as plt

origi_file = "/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3.parv"

modified_file = "/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3_raid0_stripedepth.parv"

stripdepth = []
response_list = []

for i in range(2, 7):
    depthunit = 2
    depth = depthunit * math.pow(2,i)
    stripdepth.append('%s KB'%int(0.5*depth))
    origin = open(origi_file, 'r')
    modified = open(modified_file, 'w+')
    for line in origin:
        if line.find('   Stripe unit  =  64,') == 0:
            modified.write('   Stripe unit = %s, \n'%int(depth))
            print "depth"
        else:
             modified.write(line)
    print int(depth)
    origin.close()
    modified.close()

    os.system('/home/jqian/courses/disksim-4-0-x64-master/src/disksim hw3p3_raid0_stripedepth.parv hw3p3_raid0_stripedepth.outv ascii 0 1')

    temp_file = open('/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3_raid0_stripedepth.outv', 'r')
    for l in temp_file:
        if l.find('IOdriver Response time average:') == 0:
            word = l.split(': ', 2)
            response_list.append(float(word[1]))
#    os.remove('/home/jqian/courses/disksim-4-0-x64-master/valid/hw3p3_raid0_stripedepth.parv')
    temp_file.close()

tmp = range(0, 5, 1)
print tmp
print stripdepth
print response_list

plt.figure(1)
plt.plot(tmp, response_list, 'ko-')
plt.axis([0, 4, 4.5, 5.5])
#plt.xticks(rotation=20)
plt.xticks(tmp, stripdepth)
plt.title('Impact of RAID 0 strip depth on IOdriver Response time average')
plt.xlabel('different strip depthes')
plt.ylabel('IOdriver Response time average')

plt.savefig('impactofraid0stripdepth.png')
