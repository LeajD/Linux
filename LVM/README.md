# Linux

The filesystem layer organizes and manages data storage on disk. Key concepts include:

- Hierarchy: Linux uses a single-rooted file system (/), with directories like /home, /etc, /var, /tmp, etc.
- File Types: Regular files, directories, symbolic links, device files, etc.
- Mounting: Devices and partitions are mounted into the filesystem using mount (e.g., /dev/sda1 to /mnt).
- File Permissions: Files have owner, group, and other permissions (chmod, chown), enforcing access control.
- Virtual Filesystems: /proc (system information), /sys (kernel info), and /dev (device files) are virtual filesystems.
- Ext4, Btrfs, XFS: Common Linux file systems used to organize storage.


# Inodes
Every file in Linux is associated with an inode (Index Node), which stores metadata about the file:

- File type (regular file, directory, etc.)
- Owner and group
- File size
- Time of last access, modification, and inode change
- File permissions
//The inode does not contain the file's name or its actual data, just the metadata. The filename is stored in the directory entry, which links the filename to the inode.

to see inode number:
$ ls -i filename

to see data stored in inode for a file:
$ stat 'filename'


![Linux filesystem structure](https://www.linuxfoundation.org/hubfs/Imported_Blog_Media/standard-unix-filesystem-hierarchy-1.png)


# How to run LVM on Linux:
fdisk /dev/sdb -> create partitions
pvcreate /dev/sdb /dev/sdc
vgcreate my_vg /dev/sdb /dev/sdc
lvcreate -l 100%FREE -n my_lv my_vg
mkfs.ext4 /dev/my_vg/my_lv
mkdir -p /$PATH/
mount /dev/my_vg/my_lv /$PATH/
blkid /dev/sdb
UUID=<your-disk-uuid>  /dev2  ext4  defaults  0  2
syntax of fstab entry: <device UUID> <mount point> <fs type> <options (see below)> <dump (enable/disable backing up of partition)> <pass num(sequence in which fsck checks partition for errors at boot, 1 for root device)>
Fstab options: https://help.ubuntu.com/community/Fstab
//for example you can set "noexec" flag on partitions to disable execution of binaries on selected partition

# LVM Snapshots:
lvcreate -L 10G -s -n my_snapshot /dev/my_vg/my_lv
#check snapshot:
lvs
#mount snapshot:
mount /dev/my_vg/my_snapshot /mnt/snapshot
If the original LV is corrupted or needs restoration:
lvconvert --merge /dev/my_vg/my_snapshot

# resize:
lvextend /dev/my_vg/my_lv -L +2G -r
lvreduce -L 10G -r /dev/my_vg/my_lv
# -r flag is equivalent to running below procedure:
//Unmount the LV
sudo umount /mount/point
//Check the filesystem
sudo e2fsck -f /dev/my_vg/my_lv
//Resize the filesystem (e.g., to 10G)
sudo resize2fs /dev/my_vg/my_lv 10G
//Now reduce the LV size
sudo lvreduce -L 10G /dev/my_vg/my_lv
//Remount
sudo mount /dev/my_vg/my_lv /mount/point


# Why Use LVM?
- Flexible Resizing – Easily grow or shrink volumes as needed.
- Multiple Disks as One – Combine multiple disks into a single logical volume.
- Snapshots – Create backups without downtime.
- Performance Optimization – Striping data across multiple disks improves speed.
- Easier Disk Management – Logical partitions simplify maintenance.
//when managing disks/partitions it is recommended to reference LVM partitions (/dev/mapper/vg/lv) and not disks partitions (/dev/xvdb1) to target logical volumes that are more flexible and reference actual data blocks that may contain multi physical disks

# EXT filesystems:
The main difference between ext2 and ext3 is that ext3 has journaling which helps protect it from errors when the system crashes. The more modern ext4 offers improved performance, larger volume support, journaling for data integrity, and backward compatibility with ext3.

