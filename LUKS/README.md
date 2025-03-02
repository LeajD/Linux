# Linux



![Linux filesystem structure](https://www.linuxfoundation.org/hubfs/Imported_Blog_Media/standard-unix-filesystem-hierarchy-1.png)






LUKS (Linux Unified Key Setup) 
- standard for disk encryption on Linux. It provides a secure method to encrypt entire block devices, like hard drives or partitions, using a standardized format that supports key management and multiple user keys
- LUKS protects data at-rest (on device/disk level)
- when creating new LUKS partition it erases all data already stored there
- on AWS you can encrypt volumes at rest using built-in AWS functionalities (no need to duplicate this and use LUKS - on AWS there is no "console" access so decrypting linux OS when booting is more complicated, but you can use "/etc/crypttab" file)



You cannot encrypt an active (mounted) root (/) partition with LUKS while the system is running. You need to do it from outside the running system (using a live USB or fresh install with LUKS enabled from beginning)


# Encryption procedure:
$ fdisk -> create partitions
$ partprobe /dev/sdb -> inform the kernel about partition table changes without requiring a reboot. 
$ cryptsetup luksFormat /dev/sdb1 -> initializes a LUKS encrypted partition, formatting it with encryption
$ cryptsetup luksDump /dev/sdb1 -> info on luks partition
$ cryptsetup luksOpen /dev/sdb1 encrypted -> decrypt and open a LUKS-encrypted partition, making it accessible as a mapped device to mount or manage via LVM
//  /dev/mapper/encrypted -> is created 
$ cryptsetup -v status encrypted
$ vgcreate encrypted_vg /dev/mapper/encrypted
$ lvcreate -n encrypted_lv -L +200M encrypted_vg
// lsblk
$ mkfs.ext4 /dev/encrypted_vg/encrypted_lv
$ mkdir /disk2
$ mount /dev/encrypteed_vg/encrypted_lv /disk2
$ mount | grep encrypted
    /etc/crypttab:
    encrypted /dev/sdb1 /root/enpass.txt (without enpass.txt OS will ask for password)
// we can manage access enpass.txt, it is not encrypted but we are working on "at-rest" encryption and when intruder would have access to OS-level (and could see enpass.txt) there is no sense in protecting this file
$ cryptsetup luksAddKey /dev/sdb1 /root/enpass.txt
    /etc/fstab:
    /dev/encrypted_vg/encrypted_lv /disk2 ext4 defaults 0 2

//cryptsetup luksAddKey / luksRemoveKey -> for managing encryption passwords after we created encrypted pattition