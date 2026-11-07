#include "vehiculo.h"
#include "validaciones.h"

#include <stdio.h>
#include <string.h>
#include <time.h>

const char *const VF_COMBUSTIBLE_ID[VF_N_COMBUSTIBLES] =
    { "gasolina", "diesel", "hibrido", "electrico", "gas" };
const char *const VF_COMBUSTIBLE_ETIQUETA[VF_N_COMBUSTIBLES] =
    { "Gasolina", "Diésel", "Híbrido", "Eléctrico", "Gas (GLP/GNV)" };
const char *const VF_CAMPO[VF_N] =
    { "marca", "modelo", "anio", "cilindrada", "combustible", "kilometraje" };

void vehiculo_form_iniciar(FormVehiculo *f) {
    memset(f, 0, sizeof *f);
    f->combustible = -1;
}

static int anio_maximo(void) {
    time_t t = time(NULL);
    return localtime(&t)->tm_year + 1900 + 1;
}

static void texto(const char *v, const char *campo, char *err) {
    if (!validar_no_vacio(v)) snprintf(err, VF_ERR, "%s no puede estar vacío", campo);
    else if (!validar_texto(v, VF_MAX_CARS))
        snprintf(err, VF_ERR, "%s: máximo %d caracteres y sin caracteres de control", campo, VF_MAX_CARS);
}

int vehiculo_validar(const FormVehiculo *f, char err[VF_N][VF_ERR]) {
    memset(err, 0, (size_t)VF_N * VF_ERR);
    texto(f->marca, "La marca", err[VF_MARCA]);
    texto(f->modelo, "El modelo", err[VF_MODELO]);
    texto(f->cilindrada, "La cilindrada", err[VF_CILINDRADA]);
    if (!validar_entero(f->anio, VF_ANIO_MIN, anio_maximo(), NULL))
        snprintf(err[VF_ANIO], VF_ERR, "El año debe ser un entero entre %d y %d", VF_ANIO_MIN, anio_maximo());
    if (f->combustible < 0 || f->combustible >= VF_N_COMBUSTIBLES)
        snprintf(err[VF_COMBUSTIBLE], VF_ERR, "Elige un combustible");
    if (!validar_entero(f->km, 0, VF_KM_MAX, NULL))
        snprintf(err[VF_KM], VF_ERR, "El kilometraje debe ser un entero entre 0 y %ld", VF_KM_MAX);
    int n = 0;
    for (int i = 0; i < VF_N; i++) n += err[i][0] != '\0';
    return n;
}

cJSON *vehiculo_a_json(const FormVehiculo *f) {
    long anio = 0, km = 0;
    validar_entero(f->anio, 0, 1000000, &anio);
    validar_entero(f->km, 0, VF_KM_MAX, &km);
    cJSON *o = cJSON_CreateObject();
    cJSON_AddStringToObject(o, "marca", f->marca);
    cJSON_AddStringToObject(o, "modelo", f->modelo);
    cJSON_AddNumberToObject(o, "anio", (double)anio);
    cJSON_AddStringToObject(o, "cilindrada", f->cilindrada);
    cJSON_AddStringToObject(o, "combustible",
        f->combustible >= 0 && f->combustible < VF_N_COMBUSTIBLES ? VF_COMBUSTIBLE_ID[f->combustible] : "");
    cJSON_AddNumberToObject(o, "kilometraje", (double)km);
    return o;
}

int vehiculo_errores_prolog(const cJSON *resp, char err[VF_N][VF_ERR]) {
    memset(err, 0, (size_t)VF_N * VF_ERR);
    const cJSON *ps = cJSON_GetObjectItem(cJSON_GetObjectItem(resp, "error"), "problemas");
    int n = 0;
    const cJSON *p;
    cJSON_ArrayForEach(p, ps) {
        if (!cJSON_IsString(p)) continue;
        for (int i = 0; i < VF_N; i++) {
            size_t l = strlen(VF_CAMPO[i]);
            if (strncmp(p->valuestring, VF_CAMPO[i], l) == 0 && p->valuestring[l] == ':' && !err[i][0]) {
                snprintf(err[i], VF_ERR, "%s", p->valuestring);
                n++;
            }
        }
    }
    return n;
}

int vehiculo_desde_json(FormVehiculo *f, const cJSON *v) {
    const cJSON *ma = cJSON_GetObjectItem(v, "marca"), *mo = cJSON_GetObjectItem(v, "modelo"),
                *mt = cJSON_GetObjectItem(v, "cilindrada"), *an = cJSON_GetObjectItem(v, "anio"),
                *km = cJSON_GetObjectItem(v, "kilometraje"), *co = cJSON_GetObjectItem(v, "combustible");
    if (!cJSON_IsString(ma) || !cJSON_IsString(mo) || !cJSON_IsString(mt) || !cJSON_IsNumber(an)
        || !cJSON_IsNumber(km) || !cJSON_IsString(co)) return 0;
    vehiculo_form_iniciar(f);
    snprintf(f->marca, sizeof f->marca, "%s", ma->valuestring);
    snprintf(f->modelo, sizeof f->modelo, "%s", mo->valuestring);
    snprintf(f->cilindrada, sizeof f->cilindrada, "%s", mt->valuestring);
    snprintf(f->anio, sizeof f->anio, "%ld", (long)an->valuedouble);
    snprintf(f->km, sizeof f->km, "%ld", (long)km->valuedouble);
    for (int i = 0; i < VF_N_COMBUSTIBLES; i++)
        if (strcmp(co->valuestring, VF_COMBUSTIBLE_ID[i]) == 0) f->combustible = i;
    return f->combustible >= 0;
}

void vehiculo_resumen(const FormVehiculo *f, char *out, size_t n) {
    snprintf(out, n, "%s %s %s · %s · %s · %s km", f->marca, f->modelo, f->anio, f->cilindrada,
             f->combustible >= 0 && f->combustible < VF_N_COMBUSTIBLES
                 ? VF_COMBUSTIBLE_ETIQUETA[f->combustible] : "?", f->km);
}
