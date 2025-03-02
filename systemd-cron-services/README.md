# Linux

# Systemd
systemd is the init system and service manager in modern Linux distributions. It controls the boot process and manages services, processes, and system resources.

- Unit Files: Configurations for services (e.g., *.service, *.socket, *.target).
- System Boot: Manages the boot sequence using parallelized service startup.
- Service Management: Start, stop, and monitor services (systemctl start, systemctl status, systemctl enable).
- Target Units: Groups of services, similar to runlevels (multi-user.target, graphical.target).
- Logging: Uses journalctl for system logs, allowing centralized logging.



![Linux filesystem structure](https://www.linuxfoundation.org/hubfs/Imported_Blog_Media/standard-unix-filesystem-hierarchy-1.png)


#By default, logs from services managed by systemd are captured and accessible via journalctl but you can specify other logging options in the service file.

/usr/lib/systemd/systemd/ -> default service files installed by system packages, managed by OS package manager
/etc/systemd/system/ -> custom service overrides and user-defined services, managed by the user (sysadmin)

... in /etc/systemd/system you can find multiple directies for different categories of systemd services
multi-user.target.wants/ -> services required for multi-user mode (e.g. network services, SSH,cron)
graphical.target.wants/ -> services requried for graphical UI
basic.target.wants/ -> essential low-level services required to bring the system up (e.g. device management)
default.target.wants/ -> services that start by default when booting
sysinit.target.wants/ -> early boot services (e.g. mounting filesystems)
shutdown.target.wants/ -> services that run during system shutdown
sleep.target.wants/ -> services activated when system goes to sleep
reboot.target.wants/ -> services that run before reboot
rescue.target.wants/ -> minimal services required for rescue mode
sockets.target.wants/ -> systemd socket-activated services
timers.target.wants/ -> timers that schedule tasks (alternative to cronjobs)
cloud.target.wants/ -> cloud-specific tasks like fetching metadata, initializing SSH keys, or configuring networking
remote-fs.target.wants/ -> services responsible for remote.network filesystems mounting
system-update.target.wants/ -> services that should be executed during system updates


[Unit] section:
Description=	Short description of the service.	
After=	Starts after the specified unit(s).
Before=	Starts before the specified unit(s).	
Requires=	The service must start with the specified dependency.
Wants=	A soft dependency; failure doesn’t prevent startup.	
Conflicts=	Prevents simultaneous execution with another service.	

[Service] section:
ExecStart=	Main command to start the service.	
ExecStop=	Command to stop the service.	
ExecReload=	Command to reload configuration.	
Restart=	When to restart the service (always, on-failure, etc.).	
RestartSec=	Time (in seconds) before restarting.	
User=	Runs the service as a specific user.	
Group=	Runs the service as a specific group.	
WorkingDirectory=	Directory where the process runs.	
Environment=	Defines environment variables.	
StandardOutput=	Where to send stdout (journal, syslog, null, file).	
StandardError=	Where to send stderr (journal, syslog, null, file).	

[Install] section:
WantedBy=	Defines the target (runlevel) where the service starts.	
Alias=	Alternative name for the service.
