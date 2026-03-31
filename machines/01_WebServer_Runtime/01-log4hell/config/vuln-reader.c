/*
 * vuln-reader.c — SUID binary for privilege escalation
 * 
 * This binary reads a file as root. Players must discover
 * it and realize it can read /root/root.txt.
 * 
 * Installed as: /usr/local/bin/vuln-reader (SUID root)
 * 
 * Vulnerability: No path sanitization — can read any file.
 * Usage: /usr/local/bin/vuln-reader /path/to/file
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_BUF 4096

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <logfile>\n", argv[0]);
        printf("Read application log files.\n");
        return 1;
    }
    
    // "Security check" — easily bypassable
    // Only checks if the path starts with /var/log (can be bypassed with ../../../)
    if (strncmp(argv[1], "/var/log", 8) != 0 && 
        strstr(argv[1], "../") == NULL) {
        // Direct path not starting with /var/log and no traversal
        // But we DON'T check symlinks or /proc/self/root tricks
    }
    
    // Actually just reads any file (the "check" above is a red herring)
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
