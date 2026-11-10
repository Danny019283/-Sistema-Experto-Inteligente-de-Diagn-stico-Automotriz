#ifndef PRUEBAS_ADICIONALES_H
#define PRUEBAS_ADICIONALES_H
/* F07 · Modelo de la respuesta de `recomendar_pruebas`: la prueba pendiente, las de otros
 * candidatos y las ya realizadas. Se valida todo (textos, Rp en [0, 1], resultados permitidos)
 * antes de mostrar nada (RNF-01). Qué prueba recomendar lo decide Prolog (R7). */
#include <stddef.h>
#include "cJSON.h"
#include "sintomas.h"

#define PRUEBAS_MAX 32
#define RESULTADOS_MAX 3
#define RESULTADO_LEN 16
#define TEXTO_PRUEBA_LEN 768

typedef struct {
    char prueba[ID_LEN], nombre[NOMBRE_LEN];
    char componente[ID_LEN], nombre_componente[NOMBRE_LEN];
    double relevancia;                  /* Rp; no se usa en las realizadas */
    char texto[TEXTO_PRUEBA_LEN];       /* por qué se sugiere ("" en las realizadas) */
    char resultado[RESULTADO_LEN];      /* solo en las realizadas: normal | leve | severo */
} PruebaInfo;

typedef struct {
    int hay_pendiente;
    PruebaInfo pendiente;
    char resultados[RESULTADOS_MAX][RESULTADO_LEN]; /* los que acepta la pendiente */
    int n_resultados;
    PruebaInfo del_foco[PRUEBAS_MAX];   /* las demás pruebas del componente en foco, por Rp */
    int n_foco;
    PruebaInfo otras[PRUEBAS_MAX];      /* la mejor prueba de cada otro candidato */
    int n_otras;
    PruebaInfo realizadas[PRUEBAS_MAX];
    int n_realizadas;
    char mensaje[TEXTO_PRUEBA_LEN];     /* por qué se sugiere, o por qué ya no hay pruebas */
    int iteraciones, max_iteraciones;
} Recomendacion;

/* 1 si `r` es normal, leve o severo. */
int resultado_prueba_valido(const char *r);
/* "Normal", "Leve", "Severo" para la pantalla. */
const char *resultado_prueba_texto(const char *r);
/* 1 si `r` está entre los resultados que acepta la prueba pendiente. */
int recomendacion_acepta(const Recomendacion *rec, const char *r);

/* `resultados` de recomendar_pruebas. 0 ok; -1 y err si es inválida (`rec` queda intacto). */
int recomendacion_parsear(Recomendacion *rec, const cJSON *resultados, char *err, size_t nerr);

#endif
