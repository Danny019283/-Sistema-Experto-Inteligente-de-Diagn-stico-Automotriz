#include "explicacion.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

static int unidad(const cJSON *o, const char *clave, double *dst, char *err, size_t nerr) {
    const cJSON *v = cJSON_GetObjectItemCaseSensitive(o, clave);
    if (!cJSON_IsNumber(v) || !(v->valuedouble >= 0.0 && v->valuedouble <= 1.0)) {
        snprintf(err, nerr, "'%s' no está en [0, 1]", clave);
        return -1;
    }
    *dst = v->valuedouble;
    return 0;
}

static int evento_parsear(const cJSON *o, EventoTraza *e, char *err, size_t nerr) {
    const cJSON *it = cJSON_GetObjectItemCaseSensitive(o, "iteracion");
    if (!cJSON_IsNumber(it) || it->valuedouble != floor(it->valuedouble) ||
        it->valuedouble < 0 || it->valuedouble > 1000) {
        snprintf(err, nerr, "evento de la traza sin 'iteracion' entera");
        return -1;
    }
    e->iteracion = (int)it->valuedouble;
    return json_texto(o, "regla", e->regla, sizeof e->regla, err, nerr) < 0 ||
           json_texto(o, "texto", e->texto, sizeof e->texto, err, nerr) < 0 ? -1 : 0;
}

static int componente_parsear(const cJSON *o, ExplComponente *c, char *err, size_t nerr) {
    char est[24];
    if (json_texto(o, "componente", c->id, sizeof c->id, err, nerr) < 0 ||
        json_texto(o, "nombre", c->nombre, sizeof c->nombre, err, nerr) < 0 ||
        json_texto(o, "estado", est, sizeof est, err, nerr) < 0 ||
        json_texto(o, "texto", c->texto, sizeof c->texto, err, nerr) < 0 ||
        unidad(o, "probabilidad", &c->probabilidad, err, nerr) < 0)
        return -1;
    if (!strcmp(est, "confirmado"))      c->estado = COMP_CONFIRMADO;
    else if (!strcmp(est, "descartado")) c->estado = COMP_DESCARTADO;
    else if (!strcmp(est, "incierto"))   c->estado = COMP_INCIERTO;
    else {
        snprintf(err, nerr, "estado '%s' inválido en '%s'", est, c->id);
        return -1;
    }
    return 0;
}

static int item_parsear(const cJSON *o, ExplItem *i, char *err, size_t nerr) {
    return json_texto(o, "nombre", i->nombre, sizeof i->nombre, err, nerr) < 0 ||
           json_texto(o, "texto", i->texto, sizeof i->texto, err, nerr) < 0 ||
           unidad(o, "relevancia", &i->relevancia, err, nerr) < 0 ? -1 : 0;
}

/* Lista obligatoria: recorre `clave` y llena hasta `max` elementos con `parsear`. */
#define LISTA(obj, clave, arr, n, max, parsear)                                         \
    do {                                                                                \
        const cJSON *l_ = cJSON_GetObjectItemCaseSensitive(obj, clave), *e_;            \
        if (!cJSON_IsArray(l_)) {                                                       \
            snprintf(err, nerr, "falta la lista '%s'", clave);                          \
            return -1;                                                                  \
        }                                                                               \
        cJSON_ArrayForEach(e_, l_) {                                                    \
            if ((n) >= (max)) break;            /* solo se muestran los primeros */     \
            if (parsear(e_, &(arr)[n], err, nerr) < 0) return -1;                       \
            (n)++;                                                                      \
        }                                                                               \
    } while (0)

int explicacion_parsear(Explicacion *x, const cJSON *resultados, char *err, size_t nerr) {
    const cJSON *r = cJSON_IsArray(resultados) ? cJSON_GetArrayItem(resultados, 0) : NULL;
    if (!cJSON_IsObject(r)) {
        snprintf(err, nerr, "se esperaba un objeto de explicación");
        return -1;
    }
    static Explicacion nuevo;   /* no se toca `x` hasta validar todo */
    memset(&nuevo, 0, sizeof nuevo);
    if (json_texto(r, "conclusion", nuevo.conclusion, sizeof nuevo.conclusion, err, nerr) < 0) return -1;
    LISTA(r, "traza", nuevo.traza, nuevo.n_traza, TRAZA_MAX, evento_parsear);
    if (nuevo.n_traza == 0) {   /* RNF-02: una traza vacía se informa, no se dibuja */
        snprintf(err, nerr, "la traza está vacía");
        return -1;
    }
    LISTA(r, "explicacion", nuevo.comps, nuevo.n_comps, EXPL_MAX, componente_parsear);
    LISTA(r, "acciones", nuevo.acciones, nuevo.n_acciones, EXPL_ITEMS_MAX, item_parsear);
    LISTA(r, "pruebas", nuevo.pruebas, nuevo.n_pruebas, EXPL_ITEMS_MAX, item_parsear);
    *x = nuevo;
    return 0;
}

int explicacion_max_iteracion(const Explicacion *x) {
    int m = 0;
    for (int i = 0; i < x->n_traza; i++)
        if (x->traza[i].iteracion > m) m = x->traza[i].iteracion;
    return m;
}
