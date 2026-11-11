#ifndef CONSOLA_H
#define CONSOLA_H
/* Interfaz de consola (restricción 42 del enunciado: "interfaz funcional mediante consola").
 * Menú de texto numerado sobre el mismo controlador que la ventana: todas las operaciones van a
 * Prolog por el contrato JSON; aquí solo se leen y validan entradas y se escriben resultados.
 * Se inicia con `./sistema_experto --consola` (o `make consola`). */
#include <stdio.h>
#include "controlador.h"

/* Bucle del menú. Lee de `in` y escribe en `out` (stdin/stdout, o un guion en las pruebas).
 * Conecta con Prolog al empezar. Termina con la opción Salir o al llegar al fin de la entrada.
 * Devuelve 0. */
int consola_ejecutar(Controlador *k, FILE *in, FILE *out);

#endif
