#ifndef DIAGNOSTICO_H
#define DIAGNOSTICO_H
/* F06 · Modelo del resultado de `diagnosticar`: valida la respuesta de Prolog (campos
 * obligatorios, probabilidades en [0, 1]) antes de dibujar nada (RNF-01). */
#include <stddef.h>
#include "cJSON.h"
#include "sintomas.h"

#define DIAG_MAX 96
#define MOTIVO_LEN 40

typedef enum { COMP_CONFIRMADO, COMP_INCIERTO, COMP_DESCARTADO } EstadoComp;

typedef struct {
    char id[ID_LEN], nombre[NOMBRE_LEN], sistema[SISTEMA_LEN];
    double prob;
    EstadoComp estado;
} Componente;

typedef struct {
    Componente comps[DIAG_MAX]; /* ordenados por probabilidad descendente */
    int n;
    int concluyente;
    char motivo[MOTIVO_LEN];    /* sin_inciertos | max_iteraciones | prueba_pendiente | ... */
    int iteraciones, max_iteraciones;
    char prueba_sugerida[NOMBRE_LEN]; /* nombre de pruebas_sugeridas[0], "" si no hay */
    char contra_a[ID_LEN], contra_b[ID_LEN]; /* par de motivo "contradiccion", "" si no */
} Diagnostico;

const char *estado_comp_texto(EstadoComp e);
/* Frase para el usuario según `motivo` (presentación; el razonamiento vive en Prolog). */
const char *motivo_texto(const char *motivo);

/* `resultados` de diagnosticar = [{componentes:[{id,nombre,sistema,probabilidad,estado}],
 * concluyente, motivo, iteraciones, max_iteraciones, pruebas_sugeridas, contradicciones}].
 * 0 ok; -1 y err si es inválida (en ese caso `d` queda intacto). */
int diagnostico_parsear(Diagnostico *d, const cJSON *resultados, char *err, size_t nerr);

#endif
