#ifndef CONEXION_H
#define CONEXION_H

#include <stddef.h>
#include <sys/types.h>
#include "cJSON.h"

#define CONEXION_TIMEOUT_MS 5000

typedef struct {
    pid_t pid;          /* 0 = sin proceso */
    int fd_envio;       /* stdin de swipl */
    int fd_lectura;     /* stdout de swipl */
    char *buf;          /* bytes leídos aún sin consumir */
    size_t len, cap;
    long siguiente_id;
} Conexion;

/* 1 si `swipl` está en el PATH. */
int conexion_swipl_disponible(void);

/* Lanza `swipl -q script`. 0 = ok; si falla escribe el motivo en err. */
int conexion_abrir(Conexion *c, const char *script, char *err, size_t n);

/* Envía {id, op, args} y devuelve la respuesta con el mismo id (cJSON*, liberar
 * con cJSON_Delete). Toma posesión de `args` (puede ser NULL = {}). NULL si hay
 * error de transporte (swipl murió, timeout, respuesta inválida): err lo explica
 * y la conexión queda cerrada para poder reintentar con conexion_abrir. */
cJSON *conexion_peticion(Conexion *c, const char *op, cJSON *args,
                         char *err, size_t n);

int conexion_viva(const Conexion *c);
void conexion_cerrar(Conexion *c);

#endif
