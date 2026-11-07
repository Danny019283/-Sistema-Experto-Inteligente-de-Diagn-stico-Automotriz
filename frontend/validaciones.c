#include "validaciones.h"

#include <ctype.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

int validar_no_vacio(const char *txt) {
    for (; txt && *txt; txt++)
        if (!isspace((unsigned char)*txt)) return 1;
    return 0;
}

int validar_entero(const char *txt, long min, long max, long *out) {
    if (!validar_no_vacio(txt)) return 0;
    char *fin;
    errno = 0;
    long v = strtol(txt, &fin, 10);
    while (isspace((unsigned char)*fin)) fin++;
    if (errno || *fin || v < min || v > max) return 0;
    if (out) *out = v;
    return 1;
}

int validar_texto(const char *txt, int max_cars) {
    while (*txt == ' ' || *txt == '\t') txt++;
    const char *fin = txt + strlen(txt);
    while (fin > txt && (fin[-1] == ' ' || fin[-1] == '\t')) fin--;
    if (fin == txt) return 0;
    int n = 0;
    for (const unsigned char *p = (const unsigned char *)txt; p < (const unsigned char *)fin; p++) {
        if (*p < 0x20 || *p == 0x7f) return 0;
        if ((*p & 0xC0) != 0x80) n++; /* cuenta caracteres, no bytes de continuación */
    }
    return n <= max_cars;
}
