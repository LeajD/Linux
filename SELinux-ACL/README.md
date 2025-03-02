# Linux




![Linux filesystem structure](https://www.linuxfoundation.org/hubfs/Imported_Blog_Media/standard-unix-filesystem-hierarchy-1.png)



# SELinux:
- layer of security beyond traditional/default Linux access control model (DAC - Discretionary Access Control) -> based on permissions on owner/group/other (rwx, chown, chgrp ... and special permission bits setuid, setgid, sticky bit)
- ACL are extension of DAC -> allows fine-grained permission control beyond traditional rwx bits -> settings permissions for multiple users or groups. ACL is used when mulktiple users needs pecific permissions without changing file ownership or group ownership (getfact, setfacl)
// The problem is that users/owners can override permissions (SELinux enforces security polocies independent of user discretion)
- SELinux is MAC (mandatory access Control), it uses "labels" with "context" and "sensitivity level"
- SELinux violations and events are logged in /var/log/audit/audit.log
- SELinux Booleans are used to toggle certain policies without requiring a full policy modification

SELinux Modes:
- Enforcing → Actively blocks unauthorized access.
- Permissive → Logs policy violations but doesn’t block.
- Disabled → SELinux is turned off.


# Explaination:
- root by default has "unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023" SELinux context in format "SELinuxUser:Role:Type:Sensitivity"
- $ semanage login -l -> get all users labels/contexts
- $ id -Z -> get current user labels/context
- $ semanage fcontext -> for applications-level (general approach)
- $ semanage fcontext -l -> list contexts
- run user context for user-level (more granular approach)
- run SELinux context on port-level (more-granular approach for systemd services)

# SELinux Sensivity level (Multi-Level Security - MLS)
- shown ins "ls -lZ" as last argument (e.g. "s0")
- used in Multi-Level Security (MLS) environments to define the security level of data, processes, and users
- Sensitivity levels are primarily used in high-security environments where multiple levels of classified information must be handled (it's even "deeper" than using SELinux labels/contexts)
- $chcon -t user_home_t -s s1 /home/user/file -> change sensitivity level

# Example:
//this example checks context for html directory, changes context for index.html inside this directory and then index.html will not be accessed from httpd service

$ ls -lZ -> check file information with SELinux context
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 html
// Full SELinux context: "user:role:type(context):sensitivity", labels are individual parts inside context
// context is "httpd_sys_content_t" ... so if we have such directory files inside have to be in the same context to be allowed for access

To change context:
$ chcon -t default_t /var/www/html/index.html 

To restoure default context:
$ restorecon -Rv /var/www/html/index.html

//context can be different (e.g. default_t) for /var/www/html and for index.html is "httpd_sys_content_t" and this works fine to display httpd page

^in this cale httpd will not be able to access "index.html" file inside this directory (because it requires "httpd_sys-content_t" context that is linked to httpd service)

//when "copy" files between directories file is getting overriden context of a directory it is copied to
//when "mv" files between directories file is preserving context

# audit tool for SELinux and Custom Policy:
$ audit2why < /var/log/audit/audit.log -> returns informations about SELinux policies issues
$ audit2allow -a -M my_custom_policy -> creates selinux policy to allow (e.g. allow httpd access to index.html file)
$ semodule -i my_custom_policy.pp -> apply generated policy
$ semodule -l | grep my_custom_policy -> verify generated policy
$ sealert -l $name_of_alert (from audit file) -> get complete SELinux message

# Prevent linux user from using sudo via SELinux:


# Example SELinux setup for linux server running cronjobs, metricbeat, jenkins worker and k8s cluster
1. Jenkins:
semanage fcontext -a -t jenkins_home_t "/var/lib/jenkins(/.*)?" (correct context for the Jenkins home directory for Jenkins service)
$ setsebool -P httpd_can_network_connect on (if jenkins accessing the network - git, plugins)
$ setsebool -P container_manage_cgroup on (if jenkins runs builds in docker)

2. Kubernetes:
$ setsebool -P container_runtime_tty on
$ setsebool -P container_manage_cgroup on
$ semanage fcontext -a -t container_file_t "/mnt/k8s-volumes(/.*)?" (hostPath location on host)
$ setsebool -P daemons_enable_cluster_mode on (for kubelet systemd service)

3. Metricbeat:
$ semanage fcontext -a -t proc_t "/proc(/.*)?" (read system stats)
$ semanage fcontext -a -t sysfs_t "/sys(/.*)?" (read system stats)
$ setsebool -P httpd_can_network_connect on (ensure metricbeat can send metrics over network)

4. Cron Jobs:
$ semanage fcontext -a -t bin_t "/path/to/your/script.sh" (allow "x" execution on a file/binary execution)
$ setsebool -P cron_can_network_connect on (allow cronjobs to access network)

5. SSHD service:
$ semanage fcontext -a -t sshd_config_t '/etc/ssh/sshd_config'
$ semanage fcontext -a -t ssh_home_t '/home/user/.ssh(/.*)?'
$ semanage fcontext -a -t var_log_t '/var/log/secure'
$ setsebool -P ssh_home_dir 1
$ semanage port -a -t ssh_port_t -p tcp 2222 (if using custom port)
$ setsebool -P sshd_bind_all_unreserved_ports 1 (if using custom port)

# SELinux boolean
this enables httpd to establish network connections:
$ setsebool -P httpd_can_network_connect on

Get booleans:
$ getsebool -a
