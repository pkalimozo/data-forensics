#!/bin/bash

# ----------------------------------------------------------------------
#Directory/Folder creation
# ----------------------------------------------------------------------
M1="volatile_data_$(date +%Y%m%d_%H%M%S)"
mkdir "$M1"

# ----------------------------------------------------------------------
#Collect system date and time
# ----------------------------------------------------------------------
echo "Collecting system date and time..."
date > "$M1/date.txt"

# ----------------------------------------------------------------------
#Collect system uptime
# ----------------------------------------------------------------------
echo "Collecting system uptime..."
uptime > "$M1/uptime.txt"

# ----------------------------------------------------------------------
#Collect logged-in users
# ----------------------------------------------------------------------
echo "Collecting logged-in users..."
who > "$M1/users.txt"

# ----------------------------------------------------------------------
#Collect running processes
# ----------------------------------------------------------------------
echo "Collecting running processes..."
ps aux > "$M1/ps.txt"

# ----------------------------------------------------------------------
#Collect network interfaces and configuration
# ----------------------------------------------------------------------
echo "Collecting network inferfaces and configuration..."
ifconfig > "$M1/network.txt"

# ----------------------------------------------------------------------
#Collect network connections
# ----------------------------------------------------------------------
echo "Collecting network network connections..."
netstat -anv > "$M1/network-connections.txt"

# ----------------------------------------------------------------------
#Collect open files
# ----------------------------------------------------------------------
echo "Collecting open files..."
lsof > "$M1/files.txt"

# ----------------------------------------------------------------------
#Collect  loaded kernel extensions
# ----------------------------------------------------------------------
echo "Collecting loaded kernel extensions..."
kextstat > "$M1/kernel-extensions.txt"

# ----------------------------------------------------------------------
#Collect mounted filesystem/storage
# ----------------------------------------------------------------------
echo "Collecting mounted filesystems and storages..."
mount > "$M1/mount.txt"

# ----------------------------------------------------------------------
#Compress the directory into a zip file
# ----------------------------------------------------------------------
echo "Compressing the directory into a zip file..."
zip -r "$M1.zip" "$M1"

# ----------------------------------------------------------------------
#Delete the original directory (Optional)
# ----------------------------------------------------------------------
echo "Deleting the original directory..."
rm -rf "$M1"

echo "Volatile data collection is complete!"


# ----------------------------------------------------------------------
#make this script executable. 
#run the command: chmod 744 <filename.sh>
#run script: ./<filename.sh>
#github.com/pkalimozo
# ----------------------------------------------------------------------


