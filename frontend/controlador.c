#include "controlador.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void controlador_iniciar(Controlador *k, const char *script) {
    memset(k, 0, sizeof *k);
    k->script = script;
    snprintf(k->mensaje, sizeof k->mensaje, "Sin probar.");
}

#define MAX_PROBLEMAS 5

/* Añade texto a k->mensaje sin desbordarlo. */
static void anadir(Controlador *k, const char *fmt, const char *a) {
    size_t l = strlen(k->mensaje);
    snprintf(k->mensaje + l, sizeof k->mensaje - l, fmt, a);
}

int controlador_interpretar(Controlador *k, const cJSON *resp) {
    const cJSON *estado = cJSON_GetObjectItem(resp, "estado");
    k->hay_error = cJSON_IsString(estado) && strcmp(estado->valuestring, "error") == 0;
    if (!k->hay_error) {
        char *txt = cJSON_PrintUnformatted(resp);
        snprintf(k->mensaje, sizeof k->mensaje, "Respuesta de Prolog: %s", txt ? txt : "");
        free(txt);
        return 0;
    }
    const cJSON *err = cJSON_GetObjectItem(resp, "error");
    const cJSON *cod = cJSON_GetObjectItem(err, "codigo");
    const cJSON *msg = cJSON_GetObjectItem(err, "mensaje");
    snprintf(k->mensaje, sizeof k->mensaje, "Error de Prolog (%s): %s",
             cJSON_IsString(cod) ? cod->valuestring : "desconocido",
             cJSON_IsString(msg) ? msg->valuestring : "sin detalle");
    const cJSON *ps = cJSON_GetObjectItem(err, "problemas");
    int n = cJSON_IsArray(ps) ? cJSON_GetArraySize(ps) : 0;
    for (int i = 0; i < n && i < MAX_PROBLEMAS; i++) {
        const cJSON *p = cJSON_GetArrayItem(ps, i);
        if (cJSON_IsString(p)) anadir(k, "\n- %s", p->valuestring);
    }
    if (n > MAX_PROBLEMAS) {
        char resto[32];
        snprintf(resto, sizeof resto, "%d", n - MAX_PROBLEMAS);
        anadir(k, "\n… y %s más", resto);
    }
    return 1;
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
    controlador_interpretar(k, r);
    cJSON_Delete(r);
}

void controlador_cerrar(Controlador *k) { conexion_cerrar(&k->con); }
