#ifndef SINTOMAS_H
#define SINTOMAS_H
/* F05 · Modelo del catálogo de síntomas y de la selección del usuario.
 * Solo datos y validaciones: ninguna regla del dominio vive en C. */
#include <stddef.h>
#include "cJSON.h"

#define SINT_MAX 256
#define ID_LEN 64
#define NOMBRE_LEN 128
#define SISTEMA_LEN 48

typedef enum { EST_DESCONOCIDO = 0, EST_PRESENTE, EST_AUSENTE } EstadoSintoma;

typedef struct { char id[ID_LEN]; char nombre[NOMBRE_LEN]; char sistema[SISTEMA_LEN]; } SintomaCat;
typedef struct { SintomaCat items[SINT_MAX]; int n; } Catalogo;

typedef struct { char id[ID_LEN]; char nombre[NOMBRE_LEN]; EstadoSintoma estado; } SintomaSel;
typedef struct { SintomaSel items[SINT_MAX]; int n; } Seleccion;

const char *estado_texto(EstadoSintoma e);                  /* "presente"... */
int estado_desde_texto(const char *t, EstadoSintoma *e);    /* 0 ok, -1 inválido */

/* Copia un campo de texto obligatorio de un objeto JSON; -1 y err si falta,
 * no es texto, está vacío o no cabe. */
int json_texto(const cJSON *obj, const char *clave, char *dst, size_t cap,
               char *err, size_t nerr);

/* `resultados` de catalogo_sintomas: [{sistema, sintomas:[{id,nombre}]}]. */
int catalogo_parsear(Catalogo *c, const cJSON *resultados, char *err, size_t nerr);
int catalogo_contiene(const Catalogo *c, const char *id);

/* Arreglo `seleccion` de marcar/quitar/limpiar: [{id,nombre,estado}]. Valida
 * todo antes de modificar `s` (si falla, `s` queda intacta). */
int seleccion_parsear(Seleccion *s, const cJSON *arr, char *err, size_t nerr);
EstadoSintoma seleccion_estado(const Seleccion *s, const char *id);
int seleccion_cuenta_calculo(const Seleccion *s);   /* presentes + ausentes */

/* RNF-01: ids del catálogo y al menos un presente/ausente. 0 ok, -1 y err. */
int seleccion_validar_envio(const Seleccion *s, const Catalogo *c, char *err, size_t nerr);
/* args de `diagnosticar`: {"sintomas":{id: estado}} solo presente/ausente (el llamador añade
 * "hallazgos" si los hay). */
cJSON *seleccion_a_args(const Seleccion *s);
/* args de `fijar_seleccion`: {"sintomas":{id: estado}} con toda la selección (incluye desconocido). */
cJSON *seleccion_a_args_completa(const Seleccion *s);

#endif
