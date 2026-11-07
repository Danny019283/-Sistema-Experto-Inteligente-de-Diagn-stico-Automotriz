#ifndef CONTROLADOR_H
#define CONTROLADOR_H

#include "conexion.h"

typedef struct {
    Conexion con;
    const char *script;
    char mensaje[4096]; /* último resultado a mostrar en pantalla */
    int hay_error;
} Controlador;

void controlador_iniciar(Controlador *k, const char *script);
/* Deja en k->mensaje el texto a mostrar para una respuesta de Prolog; devuelve 1 si estado=error.
 * Los errores muestran codigo, mensaje y los primeros `problemas` (kb_invalida) uno por línea. */
int controlador_interpretar(Controlador *k, const cJSON *resp);
void controlador_probar_conexion(Controlador *k); /* ping; reabre swipl si estaba caído */
void controlador_cerrar(Controlador *k);

#endif
