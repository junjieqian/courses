#!/bin/bash

for i in 0 1 2
do
	echo "---------------------------------------------------------------------------------------------------" >> problem1b
	echo "y" | mdadm --create /dev/md0 --chunk=4 --force --level=0 --raid-device=1 /dev/xvdb
	mkfs.ext4 /dev/md0
	mount /dev/md0 /mnt
	filebench -f ~/filebench-1.4.9.1/workloads/randomread_problem1b.f >> problem1b
	echo "----------------------------------------------------------" >> problem1b
	filebench -f ~/filebench-1.4.9.1/workloads/randomwrite_problem1b.f >> problem1b
	umount /dev/md0
	mdadm --stop /dev/md0

	echo "---------------------------------------------------------------------------------------------------" >> problem1b
	echo "y" | mdadm --create /dev/md0 --chunk=4 --level=0 --raid-device=2 /dev/xvdb /dev/xvdc
	mkfs.ext4 /dev/md0
	mount /dev/md0 /mnt
	filebench -f ~/filebench-1.4.9.1/workloads/randomread_problem1b.f >> problem1b
	echo "----------------------------------------------------------" >> problem1b
	filebench -f ~/filebench-1.4.9.1/workloads/randomwrite_problem1b.f >> problem1b
	umount /dev/md0
	mdadm --stop /dev/md0

	echo "---------------------------------------------------------------------------------------------------" >> problem1b
	echo "y" | mdadm --create /dev/md0 --chunk=4 --level=0 --raid-device=3 /dev/xvdb /dev/xvdc /dev/xvdd
	mkfs.ext4 /dev/md0
	mount /dev/md0 /mnt
	filebench -f ~/filebench-1.4.9.1/workloads/randomread_problem1b.f >> problem1b
	echo "----------------------------------------------------------" >> problem1b
	filebench -f ~/filebench-1.4.9.1/workloads/randomwrite_problem1b.f >> problem1b
	umount /dev/md0
	mdadm --stop /dev/md0

	echo "---------------------------------------------------------------------------------------------------" >> problem1b
	echo "y" | mdadm --create /dev/md0 --chunk=4 --level=0 --raid-device=4 /dev/xvdb /dev/xvdc /dev/xvdd /dev/xvde
	mkfs.ext4 /dev/md0
	mount /dev/md0 /mnt
	filebench -f ~/filebench-1.4.9.1/workloads/randomread_problem1b.f >> problem1b
	echo "----------------------------------------------------------" >> problem1b
	filebench -f ~/filebench-1.4.9.1/workloads/randomwrite_problem1b.f >> problem1b
	umount /dev/md0
	mdadm --stop /dev/md0

	echo "---------------------------------------------------------------------------------------------------" >> problem1b
	echo "y" | mdadm --create /dev/md0 --chunk=4 --level=0 --raid-device=5 /dev/xvdb /dev/xvdc /dev/xvdd /dev/xvde /dev/xvdf
	mkfs.ext4 /dev/md0
	mount /dev/md0 /mnt
	filebench -f ~/filebench-1.4.9.1/workloads/randomread_problem1b.f >> problem1b
	echo "----------------------------------------------------------" >> problem1b
	filebench -f ~/filebench-1.4.9.1/workloads/randomwrite_problem1b.f >> problem1b
	umount /dev/md0
	mdadm --stop /dev/md0

done
