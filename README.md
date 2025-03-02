# Linux






1. Linux Hardening project...
2. Linux LVM
3. Linux RAID using LVM 
4. Linux Overview
5. Linux kernel compilation (own distro?)
6. Cronjob and systemd service project 


# Introduction to Linux:

# Core Linux Concepts
- Kernel – The core of Linux, managing hardware, processes, memory, and system calls.
- Shell – A command-line interface (Bash, Zsh) that interprets user commands.
- Processes – Programs running in memory, managed by the kernel (e.g., ps, top).
- Users & Permissions – Access control using user roles, groups, and file permissions (chmod, chown).
- Package Management – Software installation and dependency management (apt, yum, dnf, pacman).
- File System – Hierarchical structure organizing files and directories (ext4, XFS, Btrfs).
- Systemd & Init – Service and process management system (systemctl, service).
- Networking – Configuration and management of network interfaces (ip, netstat, iptables).
- Logging – System logs stored in /var/log/ (journalctl, syslog).
- Device Management – Interaction with hardware using device files (/dev, udev).



![Linux filesystem structure](https://www.linuxfoundation.org/hubfs/Imported_Blog_Media/standard-unix-filesystem-hierarchy-1.png)



# Niceness of Linux: (ps -l)
- high "niceness" means the process will not have high priority of resource allocation 
- range of nice (-20,19)
- apply niceness by -> "nice -n -15 sleep 5 &" -> proces will get nice of '-15' which means low niceness which means high priority of resource allocation

# OOM functionality:
- in Linux kernel source code there is function "select_bad_process()" that finds a "victim process" to kill when server is running low on memory -> function calculates "badness" of process by comparings it's memory usage and time of execution
Source: https://www.kernel.org/doc/gorman/html/understand/understand016.html

# System Calls:
- allows user-space programs to interact with Linux kernel (e.g. create new process, terminate process, open file, read data, run chmod, get time)
- strace to get process' system calls
- example:
write simple "main.c" file:
#!bin/bash
#include <unistd.h>
void main() {    write(1, "\nIt Works!\n", 11); }
run "gcc main.c" -> "strace ./a.out" and see it's system calls

# Linux Kernel modules: (e.g. new driver?)

file module.c:
#include <linux/module.h>
#include <linux/kernel.h>
int init_module() {
    printk(KERN_INFO "module loaded\n");
    return 0;
}
void cleanup_module() {
    printk(KERN_INFO "module unload\n");
}

file Makefile:
obj-m +=cats.o

$ make -C /lib/modules/'uname- -r'/build M=$PWD
$ insmod module.ko
$ dmesg | tail -n 1

# sysctl kernel file
/etc/sysctl.conf file is used to configure kernel parameters at runtime
For Example:
Enable IP forwarding (for routing between networks):
sysctl -w net.ipv4.ip_forward=1

# Linux redirections
1> file → Explicitly redirects stdout to a file
2> file → Redirects stderr to a file
command > file 2>&1 → Redirects both stdout and stderr to the same file
you can use "/dev/null" as file name in order to discard info returned by a process

# Linux special variables
$? -> exit status of last executed command (0=success, non-zero=failure)
$$ -> PID of the current shell
$! -> PID of the last background process

$0 -> name of script or command
$1, $2 ... -> arguments passed to the script ($1 = first argument, $2 = second, etc.)
$# -> number of arguments passed to the script

# Linux processes states

R (Running or Runnable) – The process is either executing or waiting in the ready queue to be scheduled.
S (Sleeping - Interruptible) – The process is waiting for an event (e.g., I/O) and can be woken up.
D (Sleeping - Uninterruptible) – The process is in deep sleep (usually waiting on hardware) and cannot be interrupted.
Z (Zombie) – The process has finished execution, but its parent hasn't read its exit status.
T (Stopped/Traced) – The process is stopped (e.g., by SIGSTOP or debugging).
X (Dead/Exited) – The process is terminated and will be removed from the process table.

- Example:
make_zombie.c file C code:
#include <unistd.h>
void main() { if(fork() > 0) {  while(1) {} }}
#above code creates "child process" (as zombie process) using "fork()" function and ">0" checks PID (if currently is used parent process we wait)
$ gcc make_zombie.c -o make_zombie && ./make_zombie &
$ ps -l | greo zombie 
#above command returns process with it's state (in this case Z because of Zombie state)



