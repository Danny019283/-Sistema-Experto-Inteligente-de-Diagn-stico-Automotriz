#include "controlador.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void controlador_iniciar(Controlador *k, const char *script) {
    memset(k, 0, sizeof *k);
    k->script = script;
    snprintf(k->mensaje, sizeof k->mensaje, "Sin probar.");
}

void controlador_probar_conexion(Controlador *k) {
    char err[256] = "";
    if (!conexion_viva(&k->con) && conexion_abrir(&k->con, k->script, err, sizeof err) < 0) {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "No se pudo lanzar swipl: %s", err);
        return;
    }
    cJSON *r = conexion_peticion(&k->con, "ping", NULL, err, sizeof err);
    if (!r) {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "Error de conexión: %s", err);
        return;
    }
    char *txt = cJSON_PrintUnformatted(r);
    cJSON *estado = cJSON_GetObjectItem(r, "estado");
    k->hay_error = strcmp(estado->valuestring, "error") == 0;
    snprintf(k->mensaje, sizeof k->mensaje, "Respuesta de Prolog: %s", txt ? txt : "");
    free(txt);
    cJSON_Delete(r);
}

void controlador_cerrar(Controlador *k) { conexion_cerrar(&k->con); }
