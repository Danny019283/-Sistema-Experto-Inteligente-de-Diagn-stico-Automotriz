#ifndef CONTROLADOR_H
#define CONTROLADOR_H

#include "conexion.h"

typedef struct {
    Conexion con;
    const char *script;
    char mensaje[1024]; /* último resultado a mostrar en pantalla */
    int hay_error;
} Controlador;

void controlador_iniciar(Controlador *k, const char *script);
void controlador_probar_conexion(Controlador *k); /* ping; reabre swipl si estaba caído */
void controlador_cerrar(Controlador *k);

#endif
