# Linux

Project based on: https://youtube.com/watch?v=QlzoegSulzg

# build your own Linux distro (custom kernel, shell, syscalls)
It's assembling a minimal Linux system—from compiling the kernel and packaging a lightweight user-space with BusyBox, to setting up the bootloader and finally booting the system using an emulator (QEMU). 


Install packages for next steps:
$ apt update -y && apt install -y bzip2 git vim make gcc libncurses-dev flex bison bc cpio libelf-dev libssl-dev

Clone git kernel fiels:
$ git clone --depth 1 https://github.com/torvalds/linux.git && cd linux/

Prepare .config file for kernel configuration:
$ make menuconfig (make sure to enable 64-bit kernel)

Compile kernel:
$ make -j4


$ cp arch/x86/boot/bzImage /custom-distro/boot-files/

We will use busybox for user-space (allows running shell commands like vi, grep, ls in single executable file and we will use in our filesystsem inside our custom distro)
$ git clone --depth 1 https://git.busybox.net/busybox && cd busybox
Prepare config
$ make menuconfig -> disable setting "build static binary (no shared libs)
Build busybox:
$ make -j4 

Prepare structure for our new distro:
$ mkdir /custom-distro/boot-files/initramfs
Initramfs is the initial file system the kernel loads after booting we will put busybox over there:
$ make CONFIG_PREFIX=/custom-distro/boot-files/initramfs install && cd /custom-distro/boot-files/imitramfs/

Create init file:

#!/bin/sh
/bin/sh

^this will start shell when kernel finish booting up
$ chmod +x ./init
$ find . | cpio -o -H newc > ../init.cpio

```
^Above config is equivalent to:
"mkdir -p initramfs/{bin,sbin,etc,proc,sys,usr/bin,usr/sbin} && cd initramfs && cp -v $(which busybox) bin/ && ln -s busybox bin/sh && find . | cpio -o --format=newc | gzip > ../initramfs.img
```

Add Bootloader syslinux:
$ apt install syslinux

Create boot file:
$ dd if=/dev/zero of=boot bs=1M count=50
^create a file of 50MB with zeros, will use this file to create filesystem on this file and install bootloader and put kernel and initramfs inside it

Create filesystem on boot file:
$ apt install dosfstools
$ mkfs -t fat boot
 
Install bootloader onto a storage device and configure it for booting. We will include kernel and our 'cpio' file inside our filesystem
$ syslinux boot
$ mkdir m
$ mount boot m
$ cp bzImage init.cpio m
$ umount m

Run distro:
$ qemu-system-x86_64 boot 
^boot file is our distro file containing filesystem, kernel, busybox, initramfs
Other command to boot:
$ qemu-system-x86_64 boot -nographic