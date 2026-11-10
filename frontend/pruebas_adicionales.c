#include "pruebas_adicionales.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

int resultado_prueba_valido(const char *r) {
    return !strcmp(r, "normal") || !strcmp(r, "leve") || !strcmp(r, "severo");
}

const char *resultado_prueba_texto(const char *r) {
    if (!strcmp(r, "normal")) return "Normal";
    if (!strcmp(r, "leve"))   return "Leve";
    if (!strcmp(r, "severo")) return "Severo";
    return r;
}

int recomendacion_acepta(const Recomendacion *rec, const char *r) {
    if (!rec->hay_pendiente) return 0;
    for (int i = 0; i < rec->n_resultados; i++)
        if (!strcmp(rec->resultados[i], r)) return 1;
    return 0;
}

/* Campos comunes de una prueba: prueba, nombre, componente y nombre_componente. */
static int prueba_base(const cJSON *o, PruebaInfo *p, char *err, size_t nerr) {
    return json_texto(o, "prueba", p->prueba, sizeof p->prueba, err, nerr) < 0 ||
           json_texto(o, "nombre", p->nombre, sizeof p->nombre, err, nerr) < 0 ||
           json_texto(o, "componente", p->componente, sizeof p->componente, err, nerr) < 0 ||
           json_texto(o, "nombre_componente", p->nombre_componente, sizeof p->nombre_componente,
                      err, nerr) < 0 ? -1 : 0;
}

/* Prueba sugerida: además relevancia (Rp en [0, 1]) y el texto que la justifica. */
static int prueba_sugerida(const cJSON *o, PruebaInfo *p, char *err, size_t nerr) {
    memset(p, 0, sizeof *p);
    if (prueba_base(o, p, err, nerr) < 0 ||
        json_texto(o, "texto", p->texto, sizeof p->texto, err, nerr) < 0)
        return -1;
    const cJSON *rp = cJSON_GetObjectItemCaseSensitive(o, "relevancia");
    if (!cJSON_IsNumber(rp) || !(rp->valuedouble >= 0.0 && rp->valuedouble <= 1.0)) {
        snprintf(err, nerr, "la relevancia de '%s' no está en [0, 1]", p->prueba);
        return -1;
    }
    p->relevancia = rp->valuedouble;
    return 0;
}

/* Prueba realizada: además su resultado (normal | leve | severo). */
static int prueba_realizada(const cJSON *o, PruebaInfo *p, char *err, size_t nerr) {
    memset(p, 0, sizeof *p);
    if (prueba_base(o, p, err, nerr) < 0 ||
        json_texto(o, "resultado", p->resultado, sizeof p->resultado, err, nerr) < 0)
        return -1;
    if (!resultado_prueba_valido(p->resultado)) {
        snprintf(err, nerr, "resultado '%s' inválido en '%s'", p->resultado, p->prueba);
        return -1;
    }
    return 0;
}

static int entero(const cJSON *o, const char *clave, int min, int *dst, char *err, size_t nerr) {
    const cJSON *v = cJSON_GetObjectItemCaseSensitive(o, clave);
    if (!cJSON_IsNumber(v) || v->valuedouble != floor(v->valuedouble) ||
        v->valuedouble < min || v->valuedouble > 1000000) {
        snprintf(err, nerr, "'%s' debe ser un entero >= %d", clave, min);
        return -1;
    }
    *dst = (int)v->valuedouble;
    return 0;
}

int recomendacion_parsear(Recomendacion *rec, const cJSON *resultados, char *err, size_t nerr) {
    const cJSON *r = cJSON_IsArray(resultados) ? cJSON_GetArrayItem(resultados, 0) : NULL;
    if (!cJSON_IsObject(r)) {
        snprintf(err, nerr, "se esperaba un objeto de recomendación");
        return -1;
    }
    static Recomendacion nuevo;   /* no se toca `rec` hasta validar todo */
    memset(&nuevo, 0, sizeof nuevo);

    if (json_texto(r, "mensaje", nuevo.mensaje, sizeof nuevo.mensaje, err, nerr) < 0 ||
        entero(r, "iteraciones", 0, &nuevo.iteraciones, err, nerr) < 0 ||
        entero(r, "max_iteraciones", 1, &nuevo.max_iteraciones, err, nerr) < 0)
        return -1;

    const cJSON *pend = cJSON_GetObjectItemCaseSensitive(r, "pendiente");
    if (cJSON_IsObject(pend)) {
        if (prueba_sugerida(pend, &nuevo.pendiente, err, nerr) < 0) return -1;
        const cJSON *rs = cJSON_GetObjectItemCaseSensitive(pend, "resultados"), *x;
        if (!cJSON_IsArray(rs) || cJSON_GetArraySize(rs) == 0) {
            snprintf(err, nerr, "la prueba pendiente no trae 'resultados'");
            return -1;
        }
        cJSON_ArrayForEach(x, rs) {
            if (!cJSON_IsString(x) || !resultado_prueba_valido(x->valuestring) ||
                nuevo.n_resultados >= RESULTADOS_MAX) {
                snprintf(err, nerr, "resultado posible inválido en la prueba pendiente");
                return -1;
            }
            snprintf(nuevo.resultados[nuevo.n_resultados++], RESULTADO_LEN, "%s", x->valuestring);
        }
        nuevo.hay_pendiente = 1;
    } else if (!cJSON_IsNull(pend)) {
        snprintf(err, nerr, "falta 'pendiente' (objeto o null)");
        return -1;
    }

    const cJSON *otras = cJSON_GetObjectItemCaseSensitive(r, "otras"), *o;
    const cJSON *foco = cJSON_GetObjectItemCaseSensitive(r, "del_foco");
    const cJSON *hechas = cJSON_GetObjectItemCaseSensitive(r, "realizadas");
    if (!cJSON_IsArray(otras) || !cJSON_IsArray(foco) || !cJSON_IsArray(hechas)) {
        snprintf(err, nerr, "faltan las listas 'del_foco', 'otras' y 'realizadas'");
        return -1;
    }
    cJSON_ArrayForEach(o, foco) {
        if (nuevo.n_foco >= PRUEBAS_MAX) break;                /* solo se muestran las primeras */
        if (prueba_sugerida(o, &nuevo.del_foco[nuevo.n_foco], err, nerr) < 0) return -1;
        nuevo.n_foco++;
    }
    cJSON_ArrayForEach(o, otras) {
        if (nuevo.n_otras >= PRUEBAS_MAX) break;               /* solo se muestran las primeras */
        if (prueba_sugerida(o, &nuevo.otras[nuevo.n_otras], err, nerr) < 0) return -1;
        nuevo.n_otras++;
    }
    cJSON_ArrayForEach(o, hechas) {
        if (nuevo.n_realizadas >= PRUEBAS_MAX) {
            snprintf(err, nerr, "demasiadas pruebas realizadas (máx. %d)", PRUEBAS_MAX);
            return -1;
        }
        if (prueba_realizada(o, &nuevo.realizadas[nuevo.n_realizadas], err, nerr) < 0) return -1;
        nuevo.n_realizadas++;
    }
    *rec = nuevo;
    return 0;
}
