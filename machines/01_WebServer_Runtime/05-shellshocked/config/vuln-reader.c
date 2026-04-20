/*
 * vuln-reader.c — SUID File Reader (Machine 05: ShellShocked privesc)
 * Reads any file as root. Players use it to read /root/root.txt.
 * Compiled with: gcc -o vuln-reader vuln-reader.c && chmod u+s vuln-reader
 */
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: vuln-reader <file>\n");
        return 1;
    }
    FILE *f = fopen(argv[1], "r");
    if (!f) { perror("vuln-reader"); return 1; }
    char buf[4096]; size_t n;
    while ((n = fread(buf, 1, sizeof(buf), f)) > 0)
        fwrite(buf, 1, n, stdout);
    fclose(f);
    return 0;
}
