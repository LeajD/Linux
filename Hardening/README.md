# Linux




![Linux filesystem structure](https://www.linuxfoundation.org/hubfs/Imported_Blog_Media/standard-unix-filesystem-hierarchy-1.png)


Linux Hardening Best Practices:
1. (access) Disable root login via SSH ; enforce strong passwords and MFA (sshd service)
2. (access) Allow SSH access and set SSH trusted IPs restrictions (sshd service)
3. Use firewall for traffic filtering (e.g. iptables)
4. Disable not-required services and close open ports (netstat, systemctl)
5. Regularly update system (package-manager update)
6. Set proper permissions and ownership (chmod, chown, umask, setfacl)
7. System/Kernel Hardening (enable SELinux/AppArmor)
8. Logging and monitoring (rsyslog/journalctl)
9. Create filesystem/os backups/snapshots
10. Manage disks/partitions using RAID/LVM


