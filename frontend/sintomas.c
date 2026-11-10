#include "sintomas.h"

#include <stdio.h>
#include <string.h>

const char *estado_texto(EstadoSintoma e) {
    switch (e) {
    case EST_PRESENTE: return "presente";
    case EST_AUSENTE:  return "ausente";
    default:           return "desconocido";
    }
}

int estado_desde_texto(const char *t, EstadoSintoma *e) {
    if (!t) return -1;
    if (!strcmp(t, "presente"))    { *e = EST_PRESENTE;    return 0; }
    if (!strcmp(t, "ausente"))     { *e = EST_AUSENTE;     return 0; }
    if (!strcmp(t, "desconocido")) { *e = EST_DESCONOCIDO; return 0; }
    return -1;
}

int json_texto(const cJSON *obj, const char *clave, char *dst, size_t cap,
               char *err, size_t nerr) {
    const cJSON *v = cJSON_IsObject(obj) ? cJSON_GetObjectItemCaseSensitive(obj, clave) : NULL;
    if (!cJSON_IsString(v) || !v->valuestring || !*v->valuestring) {
        snprintf(err, nerr, "falta el campo de texto '%s'", clave);
        return -1;
    }
    if (strlen(v->valuestring) >= cap) {
        snprintf(err, nerr, "el campo '%s' es demasiado largo", clave);
        return -1;
    }
    snprintf(dst, cap, "%s", v->valuestring);
    return 0;
}

int catalogo_parsear(Catalogo *c, const cJSON *resultados, char *err, size_t nerr) {
    if (!cJSON_IsArray(resultados)) {
        snprintf(err, nerr, "el catálogo no es una lista");
        return -1;
    }
    static Catalogo nuevo; /* validar todo antes de reemplazar */
    nuevo.n = 0;
    const cJSON *g;
    cJSON_ArrayForEach(g, resultados) {
        char sistema[SISTEMA_LEN];
        if (json_texto(g, "sistema", sistema, sizeof sistema, err, nerr) < 0) return -1;
        const cJSON *lista = cJSON_GetObjectItemCaseSensitive(g, "sintomas"), *s;
        if (!cJSON_IsArray(lista)) {
            snprintf(err, nerr, "el sistema '%s' no trae lista de síntomas", sistema);
            return -1;
        }
        cJSON_ArrayForEach(s, lista) {
            if (nuevo.n >= SINT_MAX) {
                snprintf(err, nerr, "el catálogo supera %d síntomas", SINT_MAX);
                return -1;
            }
            SintomaCat *it = &nuevo.items[nuevo.n];
            if (json_texto(s, "id", it->id, sizeof it->id, err, nerr) < 0 ||
                json_texto(s, "nombre", it->nombre, sizeof it->nombre, err, nerr) < 0)
                return -1;
            snprintf(it->sistema, sizeof it->sistema, "%s", sistema);
            nuevo.n++;
        }
    }
    *c = nuevo;
    return 0;
}

int catalogo_contiene(const Catalogo *c, const char *id) {
    for (int i = 0; i < c->n; i++)
        if (!strcmp(c->items[i].id, id)) return 1;
    return 0;
}

int seleccion_parsear(Seleccion *s, const cJSON *arr, char *err, size_t nerr) {
    if (!cJSON_IsArray(arr)) {
        snprintf(err, nerr, "la selección no es una lista");
        return -1;
    }
    static Seleccion nueva;
    nueva.n = 0;
    const cJSON *it;
    cJSON_ArrayForEach(it, arr) {
        char est[24];
        if (nueva.n >= SINT_MAX) {
            snprintf(err, nerr, "la selección supera %d síntomas", SINT_MAX);
            return -1;
        }
        SintomaSel *d = &nueva.items[nueva.n];
        if (json_texto(it, "id", d->id, sizeof d->id, err, nerr) < 0 ||
            json_texto(it, "nombre", d->nombre, sizeof d->nombre, err, nerr) < 0 ||
            json_texto(it, "estado", est, sizeof est, err, nerr) < 0)
            return -1;
        if (estado_desde_texto(est, &d->estado) < 0) {
            snprintf(err, nerr, "estado desconocido '%s' en la selección", est);
            return -1;
        }
        nueva.n++;
    }
    *s = nueva;
    return 0;
}

EstadoSintoma seleccion_estado(const Seleccion *s, const char *id) {
    for (int i = 0; i < s->n; i++)
        if (!strcmp(s->items[i].id, id)) return s->items[i].estado;
    return EST_DESCONOCIDO;
}

int seleccion_cuenta_calculo(const Seleccion *s) {
    int n = 0;
    for (int i = 0; i < s->n; i++)
        if (s->items[i].estado != EST_DESCONOCIDO) n++;
    return n;
}

int seleccion_validar_envio(const Seleccion *s, const Catalogo *c, char *err, size_t nerr) {
    for (int i = 0; i < s->n; i++)
        if (!catalogo_contiene(c, s->items[i].id)) {
            snprintf(err, nerr, "El síntoma '%s' no está en el catálogo: no se envía.",
                     s->items[i].id);
            return -1;
        }
    if (seleccion_cuenta_calculo(s) == 0) {
        snprintf(err, nerr,
                 "Marca al menos un síntoma como presente o ausente para diagnosticar.");
        return -1;
    }
    return 0;
}

static cJSON *armar(const Seleccion *s, int solo_calculo) {
    cJSON *args = cJSON_CreateObject(), *mapa = cJSON_AddObjectToObject(args, "sintomas");
    for (int i = 0; i < s->n; i++) {
        if (solo_calculo && s->items[i].estado == EST_DESCONOCIDO) continue;
        cJSON_AddStringToObject(mapa, s->items[i].id, estado_texto(s->items[i].estado));
    }
    return args;
}

cJSON *seleccion_a_args(const Seleccion *s) { return armar(s, 1); }
cJSON *seleccion_a_args_completa(const Seleccion *s) { return armar(s, 0); }
