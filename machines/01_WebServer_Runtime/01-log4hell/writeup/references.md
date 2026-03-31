# Machine 01: Log4Hell — References

## CVE Details

- **CVE ID**: [CVE-2021-44228](https://nvd.nist.gov/vuln/detail/CVE-2021-44228)
- **CVSS Score**: 10.0 (Critical)
- **CWE**: CWE-502 (Deserialization of Untrusted Data), CWE-400, CWE-20
- **Published**: 2021-12-10
- **Affected**: Apache Log4j 2.0-beta9 through 2.14.1

## Original Advisories

- [Apache Log4j Security Advisory](https://logging.apache.org/log4j/2.x/security.html)
- [NIST NVD Entry](https://nvd.nist.gov/vuln/detail/CVE-2021-44228)
- [LunaSec Advisory](https://www.lunasec.io/docs/blog/log4j-zero-day/)
- [CERT/CC VU#930724](https://www.kb.cert.org/vuls/id/930724)

## Technical Analysis

- [Randori Log4j Attack Surface](https://www.randori.com/blog/cve-2021-44228/)
- [Swiss CERT Analysis](https://www.govcert.ch/blog/zero-day-exploit-targeting-popular-java-library-log4j/)
- [Cloudflare Log4j Exploitation](https://blog.cloudflare.com/actual-cve-2021-44228-payloads-captured-in-the-wild/)

## Exploitation Tools

- [marshalsec](https://github.com/mbechler/marshalsec) — JNDI exploitation utilities
- [rogue-jndi](https://github.com/veracode-research/rogue-jndi) — Rogue JNDI server
- [log4j-scan](https://github.com/fullhunt/log4j-scan) — Log4j vulnerability scanner
- [JNDI-Exploit-Kit](https://github.com/pimps/JNDI-Exploit-Kit) — Full exploitation toolkit

## Patches

- **Fixed in**: Log4j 2.15.0 (partial), 2.16.0 (JNDI disabled by default), 2.17.0 (complete fix)
- [Apache Log4j 2.17.0 Release](https://logging.apache.org/log4j/2.x/download.html)

## MITRE ATT&CK

- [T1190 — Exploit Public-Facing Application](https://attack.mitre.org/techniques/T1190/)
- [T1059.004 — Unix Shell](https://attack.mitre.org/techniques/T1059/004/)
- [T1548.001 — Setuid and Setgid](https://attack.mitre.org/techniques/T1548/001/)
