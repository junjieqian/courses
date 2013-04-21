# !/usr/bin/sh
# bash

# this is the homework 5, problem 1a script

for n in {0..3}
do
	for i in  b c d e f
	do
		mkfs.ext4 /dev/xvd$i
		mount /dev/xvd$i /mnt
		echo "-------------------starting /dev/xvd$i randomeread filebench" >> problem1a
		echo "-----------------------------------------------------------" >> problem1a
		filebench -f ~/filebench-1.4.9.1/workloads/randomread_problem1a.f >> problem1a
		echo "-------------------starting /dev/xvd$i randomewrite filebench" >> problem1a
		filebench -f ~/filebench-1.4.9.1/workloads/randomwrite_problem1a.f >> problem1a
	        echo "-----------------------------------------------------------" >> problem1a
		umount /dev/xvd$i
		echo "the /dev/xvd$i file begins to execute"
	done
	echo "$n run"
done
 
