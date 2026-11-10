#include "diagnostico.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

const char *estado_comp_texto(EstadoComp e) {
    switch (e) {
    case COMP_CONFIRMADO: return "confirmado";
    case COMP_DESCARTADO: return "descartado";
    default:              return "incierto";
    }
}

const char *motivo_texto(const char *m) {
    if (!strcmp(m, "sin_inciertos"))     return "no quedan hipótesis inciertas por investigar";
    if (!strcmp(m, "max_iteraciones"))   return "se alcanzó el máximo de iteraciones";
    if (!strcmp(m, "prueba_pendiente"))  return "falta el resultado de una prueba";
    if (!strcmp(m, "sin_pruebas"))       return "no hay pruebas para las hipótesis restantes";
    if (!strcmp(m, "contradiccion"))     return "hay síntomas incompatibles";
    return m;
}

static int estado_comp_desde(const char *t, EstadoComp *e) {
    if (!strcmp(t, "confirmado")) { *e = COMP_CONFIRMADO; return 0; }
    if (!strcmp(t, "incierto"))   { *e = COMP_INCIERTO;   return 0; }
    if (!strcmp(t, "descartado")) { *e = COMP_DESCARTADO; return 0; }
    return -1;
}

static int entero(const cJSON *obj, const char *clave, int min, int *dst, char *err, size_t nerr) {
    const cJSON *v = cJSON_GetObjectItemCaseSensitive(obj, clave);
    if (!cJSON_IsNumber(v) || v->valuedouble != floor(v->valuedouble) ||
        v->valuedouble < min || v->valuedouble > 1000000) {
        snprintf(err, nerr, "'%s' debe ser un entero >= %d", clave, min);
        return -1;
    }
    *dst = (int)v->valuedouble;
    return 0;
}

int diagnostico_parsear(Diagnostico *d, const cJSON *resultados, char *err, size_t nerr) {
    const cJSON *raiz = cJSON_IsArray(resultados) ? cJSON_GetArrayItem(resultados, 0) : NULL;
    if (!cJSON_IsObject(raiz)) {
        snprintf(err, nerr, "se esperaba un objeto de diagnóstico");
        return -1;
    }
    static Diagnostico nuevo; /* no se toca `d` hasta validar todo */
    memset(&nuevo, 0, sizeof nuevo);

    const cJSON *conc = cJSON_GetObjectItemCaseSensitive(raiz, "concluyente");
    if (!cJSON_IsBool(conc)) {
        snprintf(err, nerr, "falta 'concluyente' (booleano)");
        return -1;
    }
    nuevo.concluyente = cJSON_IsTrue(conc);
    if (json_texto(raiz, "motivo", nuevo.motivo, sizeof nuevo.motivo, err, nerr) < 0 ||
        entero(raiz, "iteraciones", 0, &nuevo.iteraciones, err, nerr) < 0 ||
        entero(raiz, "max_iteraciones", 1, &nuevo.max_iteraciones, err, nerr) < 0)
        return -1;
    if (nuevo.iteraciones > nuevo.max_iteraciones) {
        snprintf(err, nerr, "iteraciones (%d) supera max_iteraciones (%d)",
                 nuevo.iteraciones, nuevo.max_iteraciones);
        return -1;
    }

    const cJSON *lista = cJSON_GetObjectItemCaseSensitive(raiz, "componentes"), *c;
    if (!cJSON_IsArray(lista)) {
        snprintf(err, nerr, "falta la lista 'componentes'");
        return -1;
    }
    cJSON_ArrayForEach(c, lista) {
        char est[24];
        if (nuevo.n >= DIAG_MAX) {
            snprintf(err, nerr, "demasiados componentes (máx. %d)", DIAG_MAX);
            return -1;
        }
        Componente *x = &nuevo.comps[nuevo.n];
        if (json_texto(c, "id", x->id, sizeof x->id, err, nerr) < 0 ||
            json_texto(c, "nombre", x->nombre, sizeof x->nombre, err, nerr) < 0 ||
            json_texto(c, "sistema", x->sistema, sizeof x->sistema, err, nerr) < 0 ||
            json_texto(c, "estado", est, sizeof est, err, nerr) < 0)
            return -1;
        const cJSON *p = cJSON_GetObjectItemCaseSensitive(c, "probabilidad");
        if (!cJSON_IsNumber(p) || !(p->valuedouble >= 0.0 && p->valuedouble <= 1.0)) {
            snprintf(err, nerr, "la probabilidad de '%s' no está en [0, 1]", x->id);
            return -1;
        }
        x->prob = p->valuedouble;
        if (estado_comp_desde(est, &x->estado) < 0) {
            snprintf(err, nerr, "estado '%s' inválido en '%s'", est, x->id);
            return -1;
        }
        nuevo.n++;
    }
    /* Opcionales: primera prueba sugerida y par de la contradicción. */
    const cJSON *sug = cJSON_GetArrayItem(cJSON_GetObjectItemCaseSensitive(raiz, "pruebas_sugeridas"), 0);
    const cJSON *nom = cJSON_GetObjectItemCaseSensitive(sug, "nombre");
    if (cJSON_IsString(nom) && strlen(nom->valuestring) < sizeof nuevo.prueba_sugerida)
        snprintf(nuevo.prueba_sugerida, sizeof nuevo.prueba_sugerida, "%s", nom->valuestring);
    const cJSON *par = cJSON_GetArrayItem(cJSON_GetObjectItemCaseSensitive(raiz, "contradicciones"), 0);
    if (cJSON_IsObject(par)) {
        char e2[64];
        json_texto(par, "a", nuevo.contra_a, sizeof nuevo.contra_a, e2, sizeof e2);
        json_texto(par, "b", nuevo.contra_b, sizeof nuevo.contra_b, e2, sizeof e2);
    }
    /* Orden por P(Cj|S) descendente (inserción: estable). */
    for (int i = 1; i < nuevo.n; i++) {
        Componente t = nuevo.comps[i];
        int j = i - 1;
        while (j >= 0 && nuevo.comps[j].prob < t.prob) { nuevo.comps[j + 1] = nuevo.comps[j]; j--; }
        nuevo.comps[j + 1] = t;
    }
    *d = nuevo;
    return 0;
}
