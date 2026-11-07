#include "validaciones.h"

#include <ctype.h>
#include <errno.h>
#include <stdlib.h>

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
