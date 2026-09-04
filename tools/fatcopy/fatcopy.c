/*
 * IsoDock FAT image file replacer.
 * Uses Ventoy's bundled fat_io_lib (GPL-compatible) to update files inside
 * the VTOYEFI FAT16 image without loop-mount privileges.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include "fat_filelib.h"

static int g_fd = -1;

static int media_read(uint32 sector, uint8 *buffer, uint32 sector_count) {
    off_t off = (off_t)sector * 512;
    size_t bytes = (size_t)sector_count * 512;
    if (lseek(g_fd, off, SEEK_SET) < 0) return 0;
    return read(g_fd, buffer, bytes) == (ssize_t)bytes;
}
static int media_write(uint32 sector, uint8 *buffer, uint32 sector_count) {
    off_t off = (off_t)sector * 512;
    size_t bytes = (size_t)sector_count * 512;
    if (lseek(g_fd, off, SEEK_SET) < 0) return 0;
    return write(g_fd, buffer, bytes) == (ssize_t)bytes;
}
static int copy_host_to_fat(const char *host, const char *fatpath) {
    FILE *in = fopen(host, "rb");
    if (!in) { perror(host); return 1; }
    /* fat_filelib does not always truncate an existing file on fopen("w"). */
    fl_remove(fatpath);
    void *out = fl_fopen(fatpath, "w");
    if (!out) { fprintf(stderr, "Cannot open FAT path for write: %s\n", fatpath); fclose(in); return 1; }
    unsigned char buf[64 * 1024];
    size_t n;
    int rc = 0;
    while ((n = fread(buf, 1, sizeof(buf), in)) > 0) {
        if (fl_fwrite(buf, 1, (int)n, out) != (int)n) { fprintf(stderr, "Short write to %s\n", fatpath); rc = 1; break; }
    }
    if (ferror(in)) rc = 1;
    fl_fclose(out);
    fclose(in);
    return rc;
}
static int copy_fat_to_host(const char *fatpath, const char *host) {
    void *in = fl_fopen(fatpath, "rb");
    if (!in) { fprintf(stderr, "Cannot open FAT path for read: %s\n", fatpath); return 1; }
    FILE *out = fopen(host, "wb");
    if (!out) { perror(host); fl_fclose(in); return 1; }
    unsigned char buf[64 * 1024];
    int n, rc = 0;
    while ((n = fl_fread(buf, 1, sizeof(buf), in)) > 0) {
        if (fwrite(buf, 1, (size_t)n, out) != (size_t)n) { rc = 1; break; }
    }
    fclose(out);
    fl_fclose(in);
    return rc;
}
int main(int argc, char **argv) {
    if (argc != 5 || (strcmp(argv[1], "put") && strcmp(argv[1], "get"))) {
        fprintf(stderr, "Usage: %s put <image> <host-file> <fat-path>\n", argv[0]);
        fprintf(stderr, "       %s get <image> <fat-path> <host-file>\n", argv[0]);
        return 2;
    }
    const char *image = argv[2];
    g_fd = open(image, strcmp(argv[1], "put") == 0 ? O_RDWR : O_RDONLY);
    if (g_fd < 0) { perror(image); return 1; }
    fl_init();
    if (fl_attach_media(media_read, strcmp(argv[1], "put") == 0 ? media_write : NULL) != FAT_INIT_OK) {
        fprintf(stderr, "FAT attach failed: %s\n", image); close(g_fd); return 1;
    }
    int rc = strcmp(argv[1], "put") == 0 ? copy_host_to_fat(argv[3], argv[4]) : copy_fat_to_host(argv[3], argv[4]);
    fl_shutdown();
    fsync(g_fd);
    close(g_fd);
    return rc;
}
