# Linux




![Linux filesystem structure](https://www.linuxfoundation.org/hubfs/Imported_Blog_Media/standard-unix-filesystem-hierarchy-1.png)


#!/bin/bash
# DevOps Portfolio Project: LVM + RAID Setup
# This script sets up RAID 1 and configures LVM on top of it.

set -e  # Exit on error

# Variables
RAID_DEV=/dev/md0
DISK1=/dev/sdb
DISK2=/dev/sdc
VG_NAME=vg_raid
LV_NAME=lv_data
MOUNT_POINT=/mnt/lvm_data
LV_SIZE=5G

# 1. Install necessary tools
sudo apt update && sudo apt install -y mdadm lvm2

# 2. Create RAID 1 array
sudo mdadm --create --verbose $RAID_DEV --level=1 --raid-devices=2 $DISK1 $DISK2
sudo mdadm --detail --scan >> /etc/mdadm/mdadm.conf
sudo update-initramfs -u

# 3. Create Physical Volume on RAID
sudo pvcreate $RAID_DEV

# 4. Create Volume Group
sudo vgcreate $VG_NAME $RAID_DEV

# 5. Create Logical Volume
sudo lvcreate -L $LV_SIZE -n $LV_NAME $VG_NAME

# 6. Format and Mount the Volume
sudo mkfs.ext4 /dev/$VG_NAME/$LV_NAME
sudo mkdir -p $MOUNT_POINT
sudo mount /dev/$VG_NAME/$LV_NAME $MOUNT_POINT

echo "$MOUNT_POINT successfully mounted."

echo "LVM + RAID setup complete. Add to /etc/fstab for persistence."

# Display disk and RAID info
lsblk
df -h





fdisk -l
mkfs.ext4 /dev/sdb
mkdir -p /dev2/
mount /dev/sdb /dev2/
lsblk -> check
blkid /dev/sdb
UUID=<your-disk-uuid>  /dev2  ext4  defaults  0  2

fdisk /dev/sdb
mkfs.ext4 /dev/my_vg/my_lv
pvcreate /dev/sdb /dev/sdc
vgcreate my_vg /dev/sdb /dev/sdc
lvcreate -l 100%FREE -n my_lv my_vg

lsblk
blkid


1. Why Use LVM?
✅ Flexible Resizing – Easily grow or shrink volumes as needed.
✅ Multiple Disks as One – Combine multiple disks into a single logical volume.
✅ Snapshots – Create backups without downtime.
✅ Performance Optimization – Striping data across multiple disks improves speed.
✅ Easier Disk Management – Logical partitions simplify maintenance.

lvcreate -L 10G -s -n my_snapshot /dev/my_vg/my_lv
#check snapshot:
lvs
#mount snapshot:
mount /dev/my_vg/my_snapshot /mnt/snapshot


5. Restore from Snapshot (If Needed)
If the original LV is corrupted or needs restoration:
lvconvert --merge /dev/my_vg/my_snapshot
