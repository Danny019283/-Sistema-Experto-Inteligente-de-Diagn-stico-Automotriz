#include "controlador.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void controlador_iniciar(Controlador *k, const char *script) {
    memset(k, 0, sizeof *k);
    k->script = script;
    vehiculo_form_iniciar(&k->form);
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

static int enviar_vehiculo(Controlador *k, const FormVehiculo *f, FormVehiculo *recibido) {
    char err[256] = "";
    k->error_form[0] = '\0';
    memset(k->errores, 0, sizeof k->errores);
    cJSON *r = conexion_peticion(&k->con, "registrar_vehiculo", vehiculo_a_json(f), err, sizeof err);
    if (!r) {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "Error de conexión: %s", err);
        return 0;
    }
    int ok = 0;
    if (controlador_interpretar(k, r)) {
        k->hay_error = 0; /* Prolog respondió: la conexión está bien, el error es de los datos */
        if (!vehiculo_errores_prolog(r, k->errores)) snprintf(k->error_form, sizeof k->error_form, "%s", k->mensaje);
    } else {
        ok = vehiculo_desde_json(recibido, cJSON_GetArrayItem(cJSON_GetObjectItem(r, "resultados"), 0));
        if (!ok) snprintf(k->error_form, sizeof k->error_form, "Respuesta inesperada de Prolog al registrar el vehículo");
    }
    cJSON_Delete(r);
    return ok;
}

int controlador_registrar_vehiculo(Controlador *k) {
    if (vehiculo_validar(&k->form, k->errores)) {
        k->error_form[0] = '\0';
        return 0;
    }
    FormVehiculo v;
    if (!enviar_vehiculo(k, &k->form, &v)) return 0;
    k->form = k->guardado = v;
    k->registrado = 1;
    return 1;
}

void controlador_probar_conexion(Controlador *k) {
    char err[256] = "";
    int nuevo = !conexion_viva(&k->con);
    if (nuevo && conexion_abrir(&k->con, k->script, err, sizeof err) < 0) {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "No se pudo lanzar swipl: %s", err);
        return;
    }
    if (nuevo && k->registrado) { /* swipl nuevo: el vehículo vive en Prolog, se vuelve a registrar */
        FormVehiculo v;
        enviar_vehiculo(k, &k->guardado, &v);
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
