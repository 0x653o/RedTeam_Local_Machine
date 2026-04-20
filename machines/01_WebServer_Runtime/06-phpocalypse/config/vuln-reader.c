/*
 * vuln-reader.c — SUID File Reader (Privilege Escalation Binary)
 *
 * This binary runs as root (SUID) and reads any file passed as argument.
 * Players use it to read /root/root.txt after gaining www-data shell.
 * 
 * Compiled and installed as: /usr/local/bin/vuln-reader (chmod u+s)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: vuln-reader <file>\n");
        fprintf(stderr, "Example: vuln-reader /root/root.txt\n");
        return 1;
    }

    /* Security note: intentionally no path validation — this IS the vuln */
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror("vuln-reader: cannot open file");
        return 1;
    }

    char buf[4096];
    size_t n;
    while ((n = fread(buf, 1, sizeof(buf), f)) > 0) {
        fwrite(buf, 1, n, stdout);
    }
    fclose(f);
    return 0;
}
