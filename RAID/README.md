# Linux



# Native LVM RAID:
- We want to create example RAID 1 (mirrored logical volume) over 2 EBS volumes. If one disk fails, the other continues to operate without data loss.

pvcreate /dev/xvdf /dev/xvdg
vgcreate my_vg /dev/xvdf /dev/xvdg
lvcreate --type raid1 -L 10G -n my_lv my_vg
mkfs.ext4 /dev/my_vg/my_lv
mkdir -p /mnt/my_lv
mount /dev/my_vg/my_lv /mnt/my_lv
... optionally mount LV via entry in /etc/fstab 
lsblk to validate RAID1

Test RAID:
cat /proc/mdstat
mdadm --detail /dev/md0
e.g. unattach EC2 volume and check that data is still accessible by other LV that is part of RAID1



# Snapshots vs RAID:
- RAID mirroring (e.g., RAID1 and RAID10) continuously duplicates data for immediate redundancy, while snapshots capture data at a specific moment, allowing you to restore to a previous state but not providing ongoing duplicate copies.
- Usage: RAID mirrorings are used for high availability and fault tolerance. Snapshots are used for backup, system recovery, or testing changes without affecting live data.
- Performance Impact: RAID mirroring happens in real-time with minimal performance variation (aside from write overhead), whereas snapshots generally have little impact until they are accessed for recovery.

