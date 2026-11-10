#ifndef ACCIONES_H
#define ACCIONES_H
/* F09 · Modelo de la respuesta de `acciones_correctivas`: acciones derivadas de los componentes
 * confirmados, ordenadas por Ra. Se valida todo (Ra, P y efectividad en [0, 1], cada acción con
 * al menos un componente de origen) antes de mostrar nada (RNF-01). Ra lo calcula Prolog. */
#include <stddef.h>
#include "cJSON.h"
#include "sintomas.h"

#define ACCIONES_MAX 48
#define ORIGEN_MAX 8
#define TEXTO_ACCION_LEN 768

typedef struct {
    char id[ID_LEN], nombre[NOMBRE_LEN];
    double probabilidad, efectividad;   /* P(C|S) del confirmado y Maj de la KB */
} OrigenAccion;

typedef struct {
    char id[ID_LEN], nombre[NOMBRE_LEN];
    double relevancia;                  /* Ra */
    OrigenAccion origen[ORIGEN_MAX];    /* componentes confirmados que la originan */
    int n_origen;
    char texto[TEXTO_ACCION_LEN];
} Accion;

typedef struct {
    Accion items[ACCIONES_MAX];         /* de mayor a menor Ra */
    int n;
    int n_confirmados;
    char mensaje[TEXTO_ACCION_LEN];     /* resumen, o por qué no hay acciones */
} Acciones;

/* `resultados` de acciones_correctivas. 0 ok; -1 y err si es inválida (`a` queda intacto). */
int acciones_parsear(Acciones *a, const cJSON *resultados, char *err, size_t nerr);

#endif
