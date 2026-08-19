#!/bin/bash

D1="volatile_data_$(date +%Y%m%d_%H%M%S)"
mkdir "$D1"

#Collect System Date and time
echo "Collecting system date and time..."
date > "$D1/Date.txt"

#Collect System Uptime
echo "Collecting System Uptime..."
uptime > "$D1/uptime.txt"

#Collect logged-in users
echo "Collecting logged-in users..."
who -a > "$D1/users.txt"

#Collect running processes
echo "Collecting running processes..."
ps aux > "$D1/processes.txt"

#Collect network interface and configuration
echo "Collecting network interfaces and configuration..."
ifconfig -a > "$D1/ifconfig.txt"

#Collect network connections
echo "Collecting network connections..."
netstat -anpt > "$D1/netstat.txt"

#Collect open files
echo "Collecting open files..."
sudo lsof > "$D1/open-files.txt"

#Collect loaded kernel modules
echo "Collecting loaded kernel modules..."
lsmod > "$D1/lsmod.txt"

#Collect mounted filesystems
echo "Collecting mounted filesystems..."
mount > "$D1/mount.txt"

#Compress the directory into a zip file
echo "Compressing the directory into a zip file..."
zip -r "%D1"

#Deleting the original directory
echo "Deleting the original directory..."
rm -rf "$D1"


echo "Volatile data collection is complete"

#make this script executable. 
#run the command: chmod 744 <filename.sh>
#run script: ./<filename.sh>

