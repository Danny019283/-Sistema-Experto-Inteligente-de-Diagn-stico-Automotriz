#include "acciones.h"

#include <stdio.h>
#include <string.h>

/* Número obligatorio en [0, 1]; si no, -1 y err con la clave y el dueño. */
static int unidad(const cJSON *o, const char *clave, const char *de, double *dst, char *err, size_t nerr) {
    const cJSON *v = cJSON_GetObjectItemCaseSensitive(o, clave);
    if (!cJSON_IsNumber(v) || !(v->valuedouble >= 0.0 && v->valuedouble <= 1.0)) {
        snprintf(err, nerr, "'%s' de '%s' no está en [0, 1]", clave, de);
        return -1;
    }
    *dst = v->valuedouble;
    return 0;
}

static int origen_parsear(const cJSON *o, OrigenAccion *x, char *err, size_t nerr) {
    memset(x, 0, sizeof *x);
    if (json_texto(o, "id", x->id, sizeof x->id, err, nerr) < 0 ||
        json_texto(o, "nombre", x->nombre, sizeof x->nombre, err, nerr) < 0 ||
        unidad(o, "probabilidad", x->id, &x->probabilidad, err, nerr) < 0 ||
        unidad(o, "efectividad", x->id, &x->efectividad, err, nerr) < 0)
        return -1;
    return 0;
}

static int accion_parsear(const cJSON *o, Accion *a, char *err, size_t nerr) {
    memset(a, 0, sizeof *a);
    if (json_texto(o, "accion", a->id, sizeof a->id, err, nerr) < 0 ||
        json_texto(o, "nombre", a->nombre, sizeof a->nombre, err, nerr) < 0 ||
        json_texto(o, "texto", a->texto, sizeof a->texto, err, nerr) < 0 ||
        unidad(o, "relevancia", a->id, &a->relevancia, err, nerr) < 0)
        return -1;
    const cJSON *cs = cJSON_GetObjectItemCaseSensitive(o, "componentes"), *c;
    if (!cJSON_IsArray(cs) || cJSON_GetArraySize(cs) == 0) {   /* RNF-01: solo de confirmados */
        snprintf(err, nerr, "la acción '%s' no trae los componentes que la originan", a->id);
        return -1;
    }
    cJSON_ArrayForEach(c, cs) {
        if (a->n_origen >= ORIGEN_MAX) break;                  /* solo se muestran los primeros */
        if (origen_parsear(c, &a->origen[a->n_origen], err, nerr) < 0) return -1;
        a->n_origen++;
    }
    return 0;
}

int acciones_parsear(Acciones *a, const cJSON *resultados, char *err, size_t nerr) {
    const cJSON *r = cJSON_IsArray(resultados) ? cJSON_GetArrayItem(resultados, 0) : NULL;
    if (!cJSON_IsObject(r)) {
        snprintf(err, nerr, "se esperaba un objeto de acciones");
        return -1;
    }
    static Acciones nuevo;   /* no se toca `a` hasta validar todo */
    memset(&nuevo, 0, sizeof nuevo);
    if (json_texto(r, "mensaje", nuevo.mensaje, sizeof nuevo.mensaje, err, nerr) < 0) return -1;
    const cJSON *lista = cJSON_GetObjectItemCaseSensitive(r, "acciones"), *x;
    const cJSON *conf = cJSON_GetObjectItemCaseSensitive(r, "confirmados");
    if (!cJSON_IsArray(lista) || !cJSON_IsArray(conf)) {
        snprintf(err, nerr, "faltan las listas 'acciones' y 'confirmados'");
        return -1;
    }
    nuevo.n_confirmados = cJSON_GetArraySize(conf);
    cJSON_ArrayForEach(x, lista) {
        if (nuevo.n >= ACCIONES_MAX) {
            snprintf(err, nerr, "demasiadas acciones (máx. %d)", ACCIONES_MAX);
            return -1;
        }
        if (accion_parsear(x, &nuevo.items[nuevo.n], err, nerr) < 0) return -1;
        nuevo.n++;
    }
    if (nuevo.n > 0 && nuevo.n_confirmados == 0) {
        snprintf(err, nerr, "hay acciones sin componentes confirmados");
        return -1;
    }
    /* Orden por Ra descendente (inserción: la lista es corta y casi siempre ya viene ordenada). */
    for (int i = 1; i < nuevo.n; i++) {
        Accion t = nuevo.items[i];
        int j = i - 1;
        while (j >= 0 && nuevo.items[j].relevancia < t.relevancia) {
            nuevo.items[j + 1] = nuevo.items[j];
            j--;
        }
        nuevo.items[j + 1] = t;
    }
    *a = nuevo;
    return 0;
}
