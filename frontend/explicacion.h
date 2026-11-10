#ifndef EXPLICACION_H
#define EXPLICACION_H
/* F08 · Modelo de la respuesta de `explicar`: la traza del razonamiento (eventos con iteración,
 * regla y texto), la explicación por componente, las acciones, las pruebas y la conclusión. Los
 * textos los genera Prolog desde la KB (R10); aquí solo se validan antes de mostrarlos (RNF-01). */
#include <stddef.h>
#include "cJSON.h"
#include "diagnostico.h"
#include "sintomas.h"

#define TRAZA_MAX 96
#define EXPL_MAX DIAG_MAX
#define EXPL_ITEMS_MAX 48
#define REGLA_LEN 16
#define TEXTO_EXPL_LEN 768

typedef struct {
    int iteracion;
    char regla[REGLA_LEN];              /* R2-R5, R2b, RB2, R7, R7-R8, RB1, RB3, R6, R9, R10 */
    char texto[TEXTO_EXPL_LEN];
} EventoTraza;

typedef struct {
    char id[ID_LEN], nombre[NOMBRE_LEN];
    double probabilidad;
    EstadoComp estado;
    char texto[TEXTO_EXPL_LEN];         /* por qué se confirma, se descarta o sigue incierto */
} ExplComponente;

typedef struct {                        /* una acción o una prueba sugerida, con su porqué */
    char nombre[NOMBRE_LEN];
    double relevancia;
    char texto[TEXTO_EXPL_LEN];
} ExplItem;

typedef struct {
    char conclusion[TEXTO_EXPL_LEN];
    EventoTraza traza[TRAZA_MAX];       /* en orden cronológico */
    int n_traza;
    ExplComponente comps[EXPL_MAX];
    int n_comps;
    ExplItem acciones[EXPL_ITEMS_MAX];
    int n_acciones;
    ExplItem pruebas[EXPL_ITEMS_MAX];
    int n_pruebas;
} Explicacion;

/* `resultados` de explicar. 0 ok; -1 y err si es inválida (`x` queda intacto). Una traza vacía
 * es inválida: todo diagnóstico tiene al menos el estado inicial o la contradicción. */
int explicacion_parsear(Explicacion *x, const cJSON *resultados, char *err, size_t nerr);

/* La mayor iteración de la traza (el panel agrupa los eventos de 0 a esa iteración). */
int explicacion_max_iteracion(const Explicacion *x);

#endif
