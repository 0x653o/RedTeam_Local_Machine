/*
 * vuln-reader.c — SUID binary for privilege escalation
 * 
 * This binary is meant to "safely" read log files from /var/log/.
 * Players must discover it's SUID and that the path check is bypassable
 * using path traversal (e.g., /var/log/../../root/root.txt).
 * 
 * Installed as: /usr/local/bin/vuln-reader (SUID root)
 * 
 * Vulnerability: Path traversal bypass — only checks prefix, not resolved path.
 * Usage: /usr/local/bin/vuln-reader /var/log/../../root/root.txt
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_BUF 4096
#define ALLOWED_PREFIX "/var/log"

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <logfile>\n", argv[0]);
        printf("Read application log files from %s/\n", ALLOWED_PREFIX);
        return 1;
    }
    
    // "Security check" — checks if path STARTS with /var/log
    // Vulnerability: does NOT resolve symlinks or normalize ../
    // Bypass: /var/log/../../root/root.txt passes the check
    if (strncmp(argv[1], ALLOWED_PREFIX, strlen(ALLOWED_PREFIX)) != 0) {
        fprintf(stderr, "Error: Access denied. Only files in %s/ are allowed.\n", ALLOWED_PREFIX);
        return 1;
    }
    
    FILE *f = fopen(argv[1], "r");
    if (f == NULL) {
        perror("Cannot open file");
        return 1;
    }
    
    char buf[MAX_BUF];
    while (fgets(buf, sizeof(buf), f) != NULL) {
        printf("%s", buf);
    }
    
    fclose(f);
    return 0;
}
