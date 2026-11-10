#ifndef HISTORIAL_H
#define HISTORIAL_H
/* F10 · Modelo del historial de diagnósticos: los resúmenes de `listar_diagnosticos` /
 * `guardar_diagnostico` y el diagnóstico completo de `cargar_diagnostico`. Se valida todo antes
 * de mostrarlo (RNF-01); el historial vive en Prolog (datos/registros.txt). */
#include <stddef.h>
#include "cJSON.h"
#include "diagnostico.h"
#include "sintomas.h"

#define HIST_MAX 200
#define FECHA_LEN 24
#define VEH_TEXTO_LEN 256
#define ENTRADA_MAX 96

typedef struct {
    int id;
    char fecha[FECHA_LEN];              /* "2026-11-10 10:30:00" */
    char vehiculo[VEH_TEXTO_LEN];       /* "Toyota Corolla 2015" */
    int concluyente;
    char motivo[MOTIVO_LEN];
    int iteraciones;
    char principal[NOMBRE_LEN];         /* componente más probable ("" si no hay) */
    double probabilidad;                /* -1 si no hay principal */
} ResumenDiag;

typedef struct {
    ResumenDiag items[HIST_MAX];        /* del más antiguo al más nuevo */
    int n;
} Historial;

typedef struct { char id[ID_LEN]; char estado[16]; } DatoEntrada;

typedef struct {
    int id;
    char fecha[FECHA_LEN];
    char vehiculo[VEH_TEXTO_LEN];       /* "Toyota Corolla 2015 · 1.8 L · gasolina · 120000 km" */
    DatoEntrada entrada[ENTRADA_MAX];   /* síntomas y hallazgos tal como se pidieron */
    int n_entrada;
    Diagnostico diag;                   /* el resultado, validado igual que en F06 */
} DiagGuardado;

/* Un resumen (objeto). 0 ok; -1 y err. */
int resumen_parsear(ResumenDiag *r, const cJSON *obj, char *err, size_t nerr);
/* `resultados` de listar_diagnosticos (también los válidos de registros_corrupto). 0 ok; -1 y err
 * si es inválida (`h` queda intacto). */
int historial_parsear(Historial *h, const cJSON *resultados, char *err, size_t nerr);
/* `resultados` de cargar_diagnostico. 0 ok; -1 y err (`g` queda intacto). */
int diagnostico_guardado_parsear(DiagGuardado *g, const cJSON *resultados, char *err, size_t nerr);

#endif
