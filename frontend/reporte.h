#ifndef REPORTE_H
#define REPORTE_H
/* F13 · Reporte textual: el texto lo arma Prolog (`reporte_textual`) desde el diagnóstico guardado;
 * aquí se valida la respuesta y se escribe el archivo en datos/reportes/ (RF-15). */
#include <stddef.h>
#include <time.h>
#include "cJSON.h"

#define REPORTE_MAX 65536
#define REPORTES_DIR "datos/reportes"   /* la variable de entorno SE_REPORTES la reemplaza */

typedef struct {
    int id;                             /* número del diagnóstico en el historial */
    char texto[REPORTE_MAX];
} Reporte;

/* `resultados` de reporte_textual. 0 ok; -1 y err (texto vacío, id inválido); `r` queda intacto. */
int reporte_parsear(Reporte *r, const cJSON *resultados, char *err, size_t nerr);

/* "diagnostico_AAAAMMDD_HHMMSS.txt" con la hora local de `t`. */
void reporte_nombre(time_t t, char *out, size_t n);

/* RNF-01: `dir` no vacío y sin "..". Crea la carpeta si falta (RNF-02) y escribe el texto en un
 * archivo nuevo, sin sobrescribir: si el nombre ya existe agrega _2, _3... Deja la ruta en `ruta`.
 * 0 ok; -1 y err con el motivo (permisos, disco lleno, carpeta inválida); no deja archivos a medias. */
int reporte_exportar(const char *dir, const char *texto, time_t t, char *ruta, size_t nruta,
                     char *err, size_t nerr);

#endif
