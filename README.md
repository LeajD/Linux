# Linux






1. Linux Hardening project
2. Linux LVM&RAID project
3. Linux Overview
4. Linux kernel compilation
5. Shell Scripting & Automation with cronjob project 
6. Process Management & Monitoring projhect
7.  list of 15 most useful cli tools for linux 
8. linux logging/troubleshooting project

Introduction to Linux:

Core Linux Concepts
Kernel – The core of Linux, managing hardware, processes, memory, and system calls.
Shell – A command-line interface (Bash, Zsh) that interprets user commands.
Processes – Programs running in memory, managed by the kernel (e.g., ps, top).
Users & Permissions – Access control using user roles, groups, and file permissions (chmod, chown).
Package Management – Software installation and dependency management (apt, yum, dnf, pacman).
File System – Hierarchical structure organizing files and directories (ext4, XFS, Btrfs).
Systemd & Init – Service and process management system (systemctl, service).
Networking – Configuration and management of network interfaces (ip, netstat, iptables).
Logging – System logs stored in /var/log/ (journalctl, syslog).
Device Management – Interaction with hardware using device files (/dev, udev).

How Linux is Built
Source Code – Written in C, available publicly (e.g., kernel.org).
Compilation – The source is compiled using gcc or clang into a binary kernel.
Modules – Additional functionality is provided via loadable kernel modules (lsmod, modprobe).
Bootloader – GRUB or Syslinux loads the kernel into memory at startup.
Init Process – systemd or SysVinit initializes services and mounts filesystems.
User Space – Includes shell, utilities, and applications running above the kernel.


![Linux filesystem structure](https://www.linuxfoundation.org/hubfs/Imported_Blog_Media/standard-unix-filesystem-hierarchy-1.png)
