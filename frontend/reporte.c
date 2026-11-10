#include "reporte.h"

#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

int reporte_parsear(Reporte *r, const cJSON *resultados, char *err, size_t nerr) {
    const cJSON *o = cJSON_IsArray(resultados) ? cJSON_GetArrayItem(resultados, 0) : NULL;
    const cJSON *id = cJSON_GetObjectItemCaseSensitive(o, "id");
    const cJSON *t = cJSON_GetObjectItemCaseSensitive(o, "texto");
    if (!cJSON_IsObject(o) || !cJSON_IsNumber(id) || id->valuedouble != floor(id->valuedouble) ||
        id->valuedouble < 1) {
        snprintf(err, nerr, "se esperaba un reporte con 'id' entero positivo");
        return -1;
    }
    if (!cJSON_IsString(t) || !t->valuestring[0]) {   /* RNF-02: nunca un reporte vacío */
        snprintf(err, nerr, "el reporte está vacío");
        return -1;
    }
    if (strlen(t->valuestring) >= REPORTE_MAX) {
        snprintf(err, nerr, "el reporte es demasiado largo");
        return -1;
    }
    r->id = (int)id->valuedouble;
    snprintf(r->texto, sizeof r->texto, "%s", t->valuestring);
    return 0;
}

void reporte_nombre(time_t t, char *out, size_t n) {
    struct tm tm;
    localtime_r(&t, &tm);
    strftime(out, n, "diagnostico_%Y%m%d_%H%M%S.txt", &tm);
}

static const char *motivo_errno(int e) {
    switch (e) {
    case EACCES: case EPERM: case EROFS: return "sin permiso de escritura";
    case ENOSPC: case EDQUOT:            return "el disco está lleno";
    case ENOENT: case ENOTDIR:           return "la carpeta no existe y no se pudo crear";
    default:                             return strerror(e);
    }
}

/* mkdir -p: crea cada componente de la ruta que falte. */
static int crear_carpeta(const char *dir, char *err, size_t nerr) {
    char p[512];
    snprintf(p, sizeof p, "%s", dir);
    for (char *c = p + 1; ; c++) {
        if (*c == '/' || *c == '\0') {
            char fin = *c;
            *c = '\0';
            if (mkdir(p, 0755) < 0 && errno != EEXIST) {
                snprintf(err, nerr, "No se pudo crear la carpeta %s: %s", p, motivo_errno(errno));
                return -1;
            }
            *c = fin;
            if (fin == '\0') break;
        }
    }
    struct stat st;
    if (stat(dir, &st) < 0 || !S_ISDIR(st.st_mode)) {
        snprintf(err, nerr, "%s no es una carpeta", dir);
        return -1;
    }
    return 0;
}

int reporte_exportar(const char *dir, const char *texto, time_t t, char *ruta, size_t nruta,
                     char *err, size_t nerr) {
    if (!dir || !dir[0] || strstr(dir, "..") || strlen(dir) > 400) {   /* RNF-01: ruta válida */
        snprintf(err, nerr, "Carpeta de reportes inválida.");
        return -1;
    }
    if (!texto || !texto[0]) {
        snprintf(err, nerr, "No hay reporte que exportar.");
        return -1;
    }
    if (crear_carpeta(dir, err, nerr) < 0) return -1;
    char nombre[64], base[64];
    reporte_nombre(t, nombre, sizeof nombre);
    snprintf(base, sizeof base, "%.*s", (int)(strlen(nombre) - 4), nombre);   /* sin ".txt" */
    FILE *f = NULL;
    for (int i = 1; i <= 99 && !f; i++) {          /* "wx": falla si ya existe, nunca sobrescribe */
        if (i == 1) snprintf(ruta, nruta, "%s/%s", dir, nombre);
        else        snprintf(ruta, nruta, "%s/%s_%d.txt", dir, base, i);
        f = fopen(ruta, "wx");
        if (!f && errno != EEXIST) {
            snprintf(err, nerr, "No se pudo crear %s: %s", ruta, motivo_errno(errno));
            return -1;
        }
    }
    if (!f) {
        snprintf(err, nerr, "Ya existen demasiados reportes con la hora %s.", base);
        return -1;
    }
    int ok = fputs(texto, f) >= 0 && fputc('\n', f) != EOF;
    int e = errno;
    if (fclose(f) != 0 && ok) { ok = 0; e = errno; }
    if (!ok) {                                      /* RNF-02: no queda un archivo a medias */
        remove(ruta);
        snprintf(err, nerr, "No se pudo escribir el reporte: %s", motivo_errno(e));
        return -1;
    }
    return 0;
}
