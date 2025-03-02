# Networking layer of Linux:
The networking layer in Linux is responsible for managing all aspects of networking, from physical devices to communication protocols. It follows the OSI model and consists of several layers:

- Network Interfaces: Physical or virtual network devices (eth0, wlan0, lo).
- Networking Protocols: Implements TCP/IP stack (TCP, UDP, IP, ICMP, ARP, etc.).
- Routing: Routes data packets across networks using ip routing (configured via ip or route).
- Firewalling: Controlled via iptables or firewalld for packet filtering and security.
- Sockets: Communication interface for network services and applications (using tools like netstat, ss, and nc).
- Network Services: Servers and clients that use network protocols (e.g., ssh, http, ftp, dns, dhcp).

# Iptables concepts:

Chains: A set of rules applied to packets. Common chains are:
- INPUT: For incoming traffic.
- OUTPUT: For outgoing traffic.
- FORWARD: For packets being routed through the system.

Tables: Iptables rules are organized into tables. Common tables are:
- filter: Default table for packet filtering.
- nat: Used for Network Address Translation (NAT), such as port forwarding.
- mangle: Used for packet modification.
- raw: Used for configurations before connection tracking.
- Rules: Each rule specifies conditions and actions (e.g., allow or block traffic based on source IP, destination port, etc.).

# Chains
In iptables, chains are set of rules that define how network packets are handled (e.g. if packet will be ACCEPT or DROP) at various stages of processing. Each packet that passes through the firewall is evaluated against a chain (if packet destined is for local machine - it goes through INPUT chain, if it leaves system - it goes through OUTPUT chain, if packet needs to be forwarded - FORWARD chain), and the chain decides whether the packet should be allowed, rejected, or modified. Chains exist within different tables in iptables. You can add multiple rules in a single chain for advanced filtering.

# Example INPUT Chain for web server exposing nginx service:
- Accept traffic from localhost
$ iptables -A INPUT -i lo -j ACCEPT
- Accept established and related connections
$ iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
- Allow SSH (optional, secure access to server)
$ iptables -A INPUT -p tcp --dport 22 -j ACCEPT
- Allow HTTP (port 80) traffic
- Allow HTTPS (port 443) traffic
$ iptables -A INPUT -p tcp --dport 443 -j ACCEPT
- Drop all other incoming traffic
$ iptables -A INPUT -j DROP
- Allow Incoming Traffic on Port 80 (HTTP):
$ iptables -A INPUT -p tcp --dport 80 -j ACCEPT
- Block Incoming Traffic from an IP (e.g., 192.168.1.100):
$ iptables -A INPUT -s 192.168.1.100 -j DROP
- Allow Outgoing Traffic on Port 443 (HTTPS):
$ iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Masquerade 
When using a Linux box as a gateway, you can enable masquerading to share its internet connection:

$ iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
Example: Enable Masquerading on the outbound network interface (e.g., eth0):

# Destination NAT (DNAT)
used to forward incoming traffic on a specific port to an internal server, such as a web server or a game server.
$ iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.1.100:80
Example: Port Forwarding from port 8080 to an internal server (192.168.1.100) on port 80:


# Source NAT (SNAT)
Used to modify the source address of outgoing packets, typically used for outbound traffic from a private network to a public network (e.g., when the private network is behind a router and shares a single public IP).

$ iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j SNAT --to-source 203.0.113.10
Example: SNAT all outgoing traffic from the private network (192.168.1.0/24) to use a specific public IP (203.0.113.10):

# LOG
Purpose: Logs the matching packet information (such as source, destination IP, etc.) to the system's log files.
Example: Log dropped packets from a specific IP.
$ iptables -A INPUT -s 192.168.1.100 -j LOG

# Connection tracking:
The -m and --ctstate options in iptables are used for connection tracking.

- In the case of --ctstate, the -m option is used to load the connection tracking module (conntrack), which provides access to connection tracking states.
- --ctstate option is used to match packets based on the connection tracking state

CTSTATE Options:
NEW: The packet is initiating a new connection (i.e., the first packet of a connection).
ESTABLISHED: The packet is part of an already established connection.
RELATED: The packet is related to an existing connection, such as an FTP data connection established after an initial FTP control connection.
INVALID: The packet is considered invalid, meaning the connection tracking system cannot track it, or the packet doesn't fit any of the valid states.

Example:Allow Established and Related Connections (Stateful Filtering):
$ iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

Drop New Incoming Connections for a Specific Port:
$ iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 80 -j DROP

Allow New and Established SSH Connections:
$ iptables -A INPUT -m conntrack --ctstate NEW,ESTABLISHED -p tcp --dport 22 -j ACCEPT

# Optional Enhacements:
- Rate-limit SSH to prevent brute force attacks:
$ iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m limit --limit 3/min --limit-burst 5 -j ACCEPT

- Allow ICMP (ping) but prevent flooding:
$ iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 5 -j ACCEPT

- Prevent port scanning:
$ iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

- Prevent excessive connections:
$ iptables -A INPUT -p tcp --dport 443 -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT

- Redirect Port 80 to 443 (Force HTTPS):
$ iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 443