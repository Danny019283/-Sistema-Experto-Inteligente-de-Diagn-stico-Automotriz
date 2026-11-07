#ifndef CONTROLADOR_H
#define CONTROLADOR_H

#include "conexion.h"
#include "vehiculo.h"

typedef struct {
    Conexion con;
    const char *script;
    char mensaje[4096]; /* último resultado a mostrar en pantalla */
    int hay_error;
    /* Vehículo (F04). `form` es lo que se edita; `guardado` lo último que Prolog aceptó. */
    FormVehiculo form, guardado;
    int registrado;
    char errores[VF_N][VF_ERR]; /* mensaje junto a cada campo ("" = sin error) */
    char error_form[4096];      /* error de Prolog que no es de un campo concreto */
} Controlador;

void controlador_iniciar(Controlador *k, const char *script);
/* Deja en k->mensaje el texto a mostrar para una respuesta de Prolog; devuelve 1 si estado=error.
 * Los errores muestran codigo, mensaje y los primeros `problemas` (kb_invalida) uno por línea. */
int controlador_interpretar(Controlador *k, const cJSON *resp);
void controlador_probar_conexion(Controlador *k); /* ping; reabre swipl si estaba caído */
/* Valida k->form en C (RNF-01) y, si pasa, envía registrar_vehiculo. Reemplaza el registro
 * anterior y deja `form` y `guardado` con lo que devolvió Prolog. Devuelve 1 si quedó guardado.
 * Los errores (de campo o de Prolog) quedan en k->errores / k->error_form SIN tocar k->form
 * (RNF-02); un fallo de transporte además marca k->hay_error. */
int controlador_registrar_vehiculo(Controlador *k);
void controlador_cerrar(Controlador *k);

#endif
