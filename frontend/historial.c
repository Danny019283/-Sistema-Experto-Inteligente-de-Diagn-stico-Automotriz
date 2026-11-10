#include "historial.h"
#include "vehiculo.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

static int entero(const cJSON *o, const char *clave, int min, int *dst, char *err, size_t nerr) {
    const cJSON *v = cJSON_GetObjectItemCaseSensitive(o, clave);
    if (!cJSON_IsNumber(v) || v->valuedouble != floor(v->valuedouble) ||
        v->valuedouble < min || v->valuedouble > 100000000) {
        snprintf(err, nerr, "'%s' debe ser un entero >= %d", clave, min);
        return -1;
    }
    *dst = (int)v->valuedouble;
    return 0;
}

int resumen_parsear(ResumenDiag *r, const cJSON *o, char *err, size_t nerr) {
    ResumenDiag x;
    memset(&x, 0, sizeof x);
    if (!cJSON_IsObject(o)) {
        snprintf(err, nerr, "resumen de diagnóstico inválido");
        return -1;
    }
    const cJSON *c = cJSON_GetObjectItemCaseSensitive(o, "concluyente");
    if (entero(o, "id", 1, &x.id, err, nerr) < 0 ||
        json_texto(o, "fecha", x.fecha, sizeof x.fecha, err, nerr) < 0 ||
        json_texto(o, "vehiculo", x.vehiculo, sizeof x.vehiculo, err, nerr) < 0 ||
        json_texto(o, "motivo", x.motivo, sizeof x.motivo, err, nerr) < 0 ||
        entero(o, "iteraciones", 0, &x.iteraciones, err, nerr) < 0)
        return -1;
    if (!cJSON_IsBool(c)) {
        snprintf(err, nerr, "diagnóstico %d: falta 'concluyente' (booleano)", x.id);
        return -1;
    }
    x.concluyente = cJSON_IsTrue(c);
    const cJSON *pr = cJSON_GetObjectItemCaseSensitive(o, "principal");
    const cJSON *p = cJSON_GetObjectItemCaseSensitive(o, "probabilidad");
    x.probabilidad = -1;
    if (cJSON_IsString(pr)) {            /* con principal, su probabilidad en [0, 1] */
        if (json_texto(o, "principal", x.principal, sizeof x.principal, err, nerr) < 0) return -1;
        if (!cJSON_IsNumber(p) || !(p->valuedouble >= 0.0 && p->valuedouble <= 1.0)) {
            snprintf(err, nerr, "diagnóstico %d: probabilidad fuera de [0, 1]", x.id);
            return -1;
        }
        x.probabilidad = p->valuedouble;
    } else if (pr && !cJSON_IsNull(pr)) {
        snprintf(err, nerr, "diagnóstico %d: 'principal' inválido", x.id);
        return -1;
    }
    *r = x;
    return 0;
}

int historial_parsear(Historial *h, const cJSON *resultados, char *err, size_t nerr) {
    if (!cJSON_IsArray(resultados)) {
        snprintf(err, nerr, "el historial no es una lista");
        return -1;
    }
    static Historial nuevo;   /* no se toca `h` hasta validar todo */
    memset(&nuevo, 0, sizeof nuevo);
    const cJSON *o;
    cJSON_ArrayForEach(o, resultados) {
        if (nuevo.n >= HIST_MAX) break;   /* solo se muestran los primeros */
        if (resumen_parsear(&nuevo.items[nuevo.n], o, err, nerr) < 0) return -1;
        nuevo.n++;
    }
    *h = nuevo;
    return 0;
}

/* "Toyota Corolla 2015 · 1.8 L · gasolina · 120000 km" desde el objeto del vehículo. */
static int vehiculo_texto(const cJSON *v, char *out, size_t n, char *err, size_t nerr) {
    char ma[64], mo[64], ci[64], co[32];
    int anio, km;
    if (json_texto(v, "marca", ma, sizeof ma, err, nerr) < 0 ||
        json_texto(v, "modelo", mo, sizeof mo, err, nerr) < 0 ||
        json_texto(v, "cilindrada", ci, sizeof ci, err, nerr) < 0 ||
        json_texto(v, "combustible", co, sizeof co, err, nerr) < 0 ||
        entero(v, "anio", 1900, &anio, err, nerr) < 0 ||
        entero(v, "kilometraje", 0, &km, err, nerr) < 0)
        return -1;
    const char *etiqueta = co;          /* "gasolina" -> "Gasolina", como en el formulario (F04) */
    for (int i = 0; i < VF_N_COMBUSTIBLES; i++)
        if (!strcmp(VF_COMBUSTIBLE_ID[i], co)) etiqueta = VF_COMBUSTIBLE_ETIQUETA[i];
    snprintf(out, n, "%s %s %d · %s · %s · %d km", ma, mo, anio, ci, etiqueta, km);
    return 0;
}

int diagnostico_guardado_parsear(DiagGuardado *g, const cJSON *resultados, char *err, size_t nerr) {
    const cJSON *r = cJSON_IsArray(resultados) ? cJSON_GetArrayItem(resultados, 0) : NULL;
    if (!cJSON_IsObject(r)) {
        snprintf(err, nerr, "se esperaba un diagnóstico guardado");
        return -1;
    }
    static DiagGuardado nuevo;
    memset(&nuevo, 0, sizeof nuevo);
    if (entero(r, "id", 1, &nuevo.id, err, nerr) < 0 ||
        json_texto(r, "fecha", nuevo.fecha, sizeof nuevo.fecha, err, nerr) < 0)
        return -1;
    const cJSON *v = cJSON_GetObjectItemCaseSensitive(r, "vehiculo");
    if (!cJSON_IsObject(v) || vehiculo_texto(v, nuevo.vehiculo, sizeof nuevo.vehiculo, err, nerr) < 0) {
        if (!cJSON_IsObject(v)) snprintf(err, nerr, "falta el vehículo del diagnóstico");
        return -1;
    }
    const cJSON *e = cJSON_GetObjectItemCaseSensitive(r, "entrada"), *x;
    if (!cJSON_IsObject(e)) {
        snprintf(err, nerr, "falta la entrada del diagnóstico");
        return -1;
    }
    cJSON_ArrayForEach(x, e) {
        if (nuevo.n_entrada >= ENTRADA_MAX) break;
        if (!cJSON_IsString(x) || !x->string || strlen(x->string) >= ID_LEN ||
            strlen(x->valuestring) >= sizeof nuevo.entrada[0].estado) {
            snprintf(err, nerr, "dato de entrada inválido");
            return -1;
        }
        snprintf(nuevo.entrada[nuevo.n_entrada].id, ID_LEN, "%s", x->string);
        snprintf(nuevo.entrada[nuevo.n_entrada].estado, sizeof nuevo.entrada[0].estado, "%s", x->valuestring);
        nuevo.n_entrada++;
    }
    /* El resultado se valida con el mismo parser de F06: se muestra igual que cuando se generó. */
    const cJSON *res = cJSON_GetObjectItemCaseSensitive(r, "resultado");
    cJSON *lista = cJSON_CreateArray();
    cJSON_AddItemReferenceToArray(lista, (cJSON *)res);
    int rc = cJSON_IsObject(res) ? diagnostico_parsear(&nuevo.diag, lista, err, nerr) : -1;
    if (!cJSON_IsObject(res)) snprintf(err, nerr, "falta el resultado del diagnóstico");
    cJSON_Delete(lista);                 /* borra solo la referencia, no `res` */
    if (rc < 0) return -1;
    *g = nuevo;
    return 0;
}
