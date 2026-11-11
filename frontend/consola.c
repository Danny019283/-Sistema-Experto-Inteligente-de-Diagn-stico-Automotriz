#include "consola.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

/* Estado de la sesión de consola: el controlador compartido con la ventana y los flujos. */
typedef struct {
    Controlador *k;
    FILE *in, *out;
    int fin;                /* fin de la entrada o Salir */
} Consola;

#define ANCHO 92

/* ------------------------------------------------------------------ entrada ---- */

/* Lee una línea sin el salto final ni espacios en los extremos; 0 ok, -1 al fin de la entrada. */
static int leer_linea(Consola *c, char *buf, size_t n) {
    if (c->fin || !fgets(buf, (int)n, c->in)) { c->fin = 1; buf[0] = '\0'; return -1; }
    size_t l = strlen(buf);
    if (l == n - 1 && buf[l - 1] != '\n') {          /* línea demasiado larga: se descarta el resto */
        int ch;
        while ((ch = fgetc(c->in)) != EOF && ch != '\n') {}
    }
    while (l > 0 && (buf[l - 1] == '\n' || buf[l - 1] == '\r' || buf[l - 1] == ' ')) buf[--l] = '\0';
    size_t i = 0;
    while (buf[i] == ' ' || buf[i] == '\t') i++;
    if (i) memmove(buf, buf + i, strlen(buf + i) + 1);
    return 0;
}

/* RNF-01: pide un entero en [min, max] hasta que sea válido; -1 al fin de la entrada. */
static int leer_opcion(Consola *c, const char *pregunta, int min, int max) {
    char buf[64];
    for (;;) {
        fprintf(c->out, "%s [%d-%d]: ", pregunta, min, max);
        fflush(c->out);
        if (leer_linea(c, buf, sizeof buf) < 0) { fputc('\n', c->out); return -1; }
        char *fin;
        long v = strtol(buf, &fin, 10);
        if (buf[0] && *fin == '\0' && v >= min && v <= max) return (int)v;
        fprintf(c->out, "  Opción inválida: escriba un número entre %d y %d.\n", min, max);
    }
}

/* Pregunta de sí o no; 1 = sí, 0 = no o fin de la entrada. */
static int confirmar(Consola *c, const char *pregunta) {
    char buf[16];
    for (;;) {
        fprintf(c->out, "%s (s/n): ", pregunta);
        fflush(c->out);
        if (leer_linea(c, buf, sizeof buf) < 0) { fputc('\n', c->out); return 0; }
        if (buf[0] == 's' || buf[0] == 'S') return 1;
        if (buf[0] == 'n' || buf[0] == 'N') return 0;
        fprintf(c->out, "  Responda s o n.\n");
    }
}

/* ------------------------------------------------------------------ salida ----- */

/* Caracteres visibles de un texto UTF-8 (los bytes de continuación no cuentan). */
static int visibles(const char *s, size_t n) {
    int v = 0;
    for (size_t i = 0; i < n; i++) v += ((unsigned char)s[i] & 0xC0) != 0x80;
    return v;
}

/* Párrafo con sangría, cortado por palabras a ANCHO columnas. */
static void parrafo(Consola *c, int sangria, const char *txt) {
    int col = 0;
    const char *p = txt;
    fprintf(c->out, "%*s", sangria, "");
    col = sangria;
    while (*p) {
        while (*p == ' ') p++;
        if (!*p) break;
        const char *q = p;
        while (*q && *q != ' ') q++;
        int w = visibles(p, (size_t)(q - p));
        if (col > sangria && col + 1 + w > ANCHO) {
            fprintf(c->out, "\n%*s", sangria, "");
            col = sangria;
        } else if (col > sangria) {
            fputc(' ', c->out);
            col++;
        }
        fwrite(p, 1, (size_t)(q - p), c->out);
        col += w;
        p = q;
    }
    fputc('\n', c->out);
}

static void titulo(Consola *c, const char *t) {
    fprintf(c->out, "\n--- %s ", t);
    for (int i = visibles(t, strlen(t)) + 5; i < ANCHO; i++) fputc('-', c->out);
    fputc('\n', c->out);
}

/* Un aviso del controlador ("" = nada que decir). */
static void aviso(Consola *c, const char *txt, int es_error) {
    if (!txt[0]) return;
    char linea[4200];
    snprintf(linea, sizeof linea, "%s%s", es_error ? "ATENCIÓN: " : "", txt);
    for (char *s = linea; *s; s++) if (*s == '\n') *s = ' ';
    parrafo(c, 2, linea);
}

static void porcentaje(double p, char *out, size_t n) { snprintf(out, n, "%5.1f %%", p * 100.0); }

/* RNF-02: si Prolog no responde, se informa y se ofrece reintentar sin cerrar el programa. */
static void revisar_conexion(Consola *c) {
    Controlador *k = c->k;
    while (!c->fin && (k->hay_error || !conexion_viva(&k->con))) {
        titulo(c, "Error de conexión con Prolog");
        parrafo(c, 2, k->mensaje[0] ? k->mensaje : "Prolog no está conectado.");
        fprintf(c->out, "  1. Reintentar\n  0. Salir\n");
        int op = leer_opcion(c, "Opción", 0, 1);
        if (op != 1) { c->fin = 1; return; }
        controlador_cerrar(k);
        k->hay_error = 0;
        controlador_probar_conexion(k);
        if (!k->hay_error) fprintf(c->out, "  Conexión restablecida.\n");
    }
}

/* ------------------------------------------------------------- 1. vehículo ---- */

static void leer_campo(Consola *c, const char *etiqueta, char *dst, size_t n) {
    char buf[256];
    fprintf(c->out, "  %s [%s]: ", etiqueta, dst[0] ? dst : "vacío");
    fflush(c->out);
    if (leer_linea(c, buf, sizeof buf) == 0 && buf[0]) {   /* se recorta al tamaño del campo */
        size_t l = strlen(buf);
        if (l >= n) l = n - 1;
        memcpy(dst, buf, l);
        dst[l] = '\0';
    }
}

static void menu_vehiculo(Consola *c) {
    Controlador *k = c->k;
    FormVehiculo *f = &k->form;
    titulo(c, "Vehículo");
    if (k->registrado) {
        char r[512];
        vehiculo_resumen(&k->guardado, r, sizeof r);
        fprintf(c->out, "  Registrado: %s\n", r);
    }
    fprintf(c->out, "  Escriba cada dato y pulse Enter (Enter solo conserva el valor entre corchetes).\n");
    leer_campo(c, "Marca", f->marca, sizeof f->marca);
    leer_campo(c, "Modelo", f->modelo, sizeof f->modelo);
    leer_campo(c, "Año", f->anio, sizeof f->anio);
    leer_campo(c, "Cilindrada (por ejemplo 1.8 L)", f->cilindrada, sizeof f->cilindrada);
    fprintf(c->out, "  Combustible:\n");
    for (int i = 0; i < VF_N_COMBUSTIBLES; i++) fprintf(c->out, "    %d. %s\n", i + 1, VF_COMBUSTIBLE_ETIQUETA[i]);
    int op = leer_opcion(c, "  Combustible", 1, VF_N_COMBUSTIBLES);
    if (op < 0) return;
    f->combustible = op - 1;
    leer_campo(c, "Kilometraje", f->km, sizeof f->km);
    if (controlador_registrar_vehiculo(k)) {
        char r[512];
        vehiculo_resumen(&k->guardado, r, sizeof r);
        fprintf(c->out, "  Vehículo registrado: %s\n", r);
        return;
    }
    fprintf(c->out, "  No se registró el vehículo (los datos escritos se conservan para corregirlos):\n");
    for (int i = 0; i < VF_N; i++)
        if (k->errores[i][0]) fprintf(c->out, "    - %s\n", k->errores[i]);
    aviso(c, k->error_form, 1);
}

/* ------------------------------------------------------------- 2. síntomas ---- */

static void mostrar_seleccion(Consola *c) {
    Controlador *k = c->k;
    if (k->sel.n == 0) { fprintf(c->out, "  Aún no hay síntomas marcados.\n"); return; }
    for (int i = 0; i < k->sel.n; i++)
        fprintf(c->out, "  %2d. %-58s %s\n", i + 1, k->sel.items[i].nombre, estado_texto(k->sel.items[i].estado));
    fprintf(c->out, "  Seleccionados: %d. Al cálculo: %d (desconocido no entra al cálculo).\n",
            k->sel.n, seleccion_cuenta_calculo(&k->sel));
}

/* Catálogo numerado por sistema, con el estado actual de cada síntoma marcado. */
static void mostrar_catalogo(Consola *c) {
    Controlador *k = c->k;
    const char *previo = "";
    for (int i = 0; i < k->cat.n; i++) {
        const SintomaCat *s = &k->cat.items[i];
        if (strcmp(s->sistema, previo) != 0) { fprintf(c->out, "  %s\n", s->sistema); previo = s->sistema; }
        EstadoSintoma e = seleccion_estado(&k->sel, s->id);
        int marcado = 0;
        for (int j = 0; j < k->sel.n; j++) marcado |= !strcmp(k->sel.items[j].id, s->id);
        fprintf(c->out, "    %2d. %s%s%s%s\n", i + 1, s->nombre, marcado ? "  [" : "",
                marcado ? estado_texto(e) : "", marcado ? "]" : "");
    }
}

/* Elige un síntoma del catálogo por número o por su identificador; -1 si no es válido. */
static int elegir_sintoma(Consola *c) {
    Controlador *k = c->k;
    char buf[128];
    fprintf(c->out, "Número o identificador del síntoma (Enter para volver): ");
    fflush(c->out);
    if (leer_linea(c, buf, sizeof buf) < 0 || !buf[0]) return -1;
    char *fin;
    long v = strtol(buf, &fin, 10);
    if (*fin == '\0' && v >= 1 && v <= k->cat.n) return (int)v - 1;
    for (int i = 0; i < k->cat.n; i++) if (!strcmp(k->cat.items[i].id, buf)) return i;
    fprintf(c->out, "  \"%s\" no está en el catálogo.\n", buf);   /* RNF-01 */
    return -1;
}

/* RB2: dos síntomas incompatibles; Prolog ya restauró la selección anterior. */
static void dialogo_contradiccion(Consola *c) {
    Controlador *k = c->k;
    Contradiccion *x = &k->contra;
    titulo(c, "Contradicción detectada");
    char m[600];
    snprintf(m, sizeof m, "Marcó \"%s\" y \"%s\", que son incompatibles. La selección volvió a como estaba "
             "antes de la última marca. ¿Cuál es correcta?", x->nombre_a, x->nombre_b);
    parrafo(c, 2, m);
    fprintf(c->out, "  1. Es correcta: %s\n  2. Es correcta: %s\n  0. Cancelar (conservar la selección anterior)\n",
            x->nombre_a, x->nombre_b);
    int op = leer_opcion(c, "Opción", 0, 2);
    char a[ID_LEN], b[ID_LEN];
    snprintf(a, sizeof a, "%s", x->id_a);
    snprintf(b, sizeof b, "%s", x->id_b);
    if (op == 1) controlador_resolver(k, a);
    else if (op == 2) controlador_resolver(k, b);
    else controlador_cancelar_contradiccion(k);
    aviso(c, k->aviso, 0);
    if (k->contra.pendiente && !c->fin) dialogo_contradiccion(c);   /* contradicción encadenada */
}

static void menu_sintomas(Consola *c) {
    Controlador *k = c->k;
    if (!k->catalogo_ok) controlador_cargar_catalogo(k);
    while (!c->fin) {
        revisar_conexion(c);
        if (c->fin) return;
        titulo(c, "Síntomas");
        if (!k->catalogo_ok) { aviso(c, k->aviso[0] ? k->aviso : "No hay catálogo de síntomas.", 1); return; }
        mostrar_seleccion(c);
        fprintf(c->out, "\n  1. Marcar un síntoma\n  2. Ver el catálogo\n  3. Quitar un síntoma\n"
                        "  4. Limpiar la selección\n  0. Volver al menú\n");
        int op = leer_opcion(c, "Opción", 0, 4);
        if (op <= 0) return;
        if (op == 2) { mostrar_catalogo(c); continue; }
        if (op == 4) { controlador_limpiar(k); aviso(c, k->aviso, 1); continue; }
        if (op == 3) {
            if (k->sel.n == 0) continue;
            int i = leer_opcion(c, "Número del síntoma a quitar", 1, k->sel.n);
            if (i > 0) { char id[ID_LEN]; snprintf(id, sizeof id, "%s", k->sel.items[i - 1].id); controlador_quitar(k, id); }
            aviso(c, k->aviso, 1);
            continue;
        }
        mostrar_catalogo(c);
        int s = elegir_sintoma(c);
        if (s < 0) continue;
        fprintf(c->out, "  %s\n  1. Presente\n  2. Ausente\n  3. Desconocido\n", k->cat.items[s].nombre);
        int e = leer_opcion(c, "Estado", 1, 3);
        if (e < 0) return;
        static const EstadoSintoma est[] = { EST_PRESENTE, EST_AUSENTE, EST_DESCONOCIDO };
        controlador_marcar(k, k->cat.items[s].id, est[e - 1]);
        if (k->contra.pendiente) dialogo_contradiccion(c);
        else aviso(c, k->aviso, 1);
    }
}

/* ------------------------------------------------------------- 3. diagnóstico -- */

static void mostrar_componentes(Consola *c, const Diagnostico *d) {
    char p[24];
    fprintf(c->out, "  Hipótesis (de mayor a menor probabilidad):\n");
    for (int pasada = 0; pasada < 2; pasada++) {
        if (pasada == 1) {
            int hay = 0;
            for (int i = 0; i < d->n; i++) hay |= d->comps[i].estado == COMP_DESCARTADO;
            if (!hay) break;
            fprintf(c->out, "  Descartadas:\n");
        }
        for (int i = 0; i < d->n; i++) {
            const Componente *x = &d->comps[i];
            if ((x->estado == COMP_DESCARTADO) != pasada) continue;
            porcentaje(x->prob, p, sizeof p);
            fprintf(c->out, "    %s  %-11s %s (%s)\n", p, estado_comp_texto(x->estado), x->nombre, x->sistema);
        }
    }
}

static void mostrar_diagnostico(Consola *c, const Diagnostico *d) {
    fprintf(c->out, "  DIAGNÓSTICO %s\n", d->concluyente ? "CONCLUYENTE" : "NO CONCLUYENTE");
    fprintf(c->out, "  Iteraciones usadas: %d de %d\n", d->iteraciones, d->max_iteraciones);
    char m[300];
    snprintf(m, sizeof m, "Motivo: %s.", motivo_texto(d->motivo));
    parrafo(c, 2, m);
    if (!d->concluyente && d->prueba_sugerida[0]) {
        snprintf(m, sizeof m, "Prueba sugerida: %s (opción 4 del menú para registrar su resultado).", d->prueba_sugerida);
        parrafo(c, 2, m);
    }
    mostrar_componentes(c, d);
    fprintf(c->out, "  Es una hipótesis del sistema experto, no una certeza: confírmela con un técnico.\n");
}

static void menu_diagnosticar(Consola *c) {
    Controlador *k = c->k;
    titulo(c, "Diagnóstico");
    if (!controlador_puede_diagnosticar(k)) {          /* RNF-01: no se consulta a Prolog */
        aviso(c, k->contra.pendiente ? "Resuelva la contradicción para continuar."
                                     : "Marque al menos un síntoma como presente o ausente (opción 2).", 1);
        return;
    }
    controlador_diagnosticar(k);
    aviso(c, k->aviso_diag, k->aviso_diag_error);
    if (k->hay_diag) mostrar_diagnostico(c, &k->diag);
}

/* Las opciones 4 a 6 y 9 necesitan un diagnóstico calculado. */
static int requiere_diagnostico(Consola *c) {
    if (c->k->hay_diag) return 1;
    fprintf(c->out, "  Primero genere un diagnóstico (opción 3).\n");
    return 0;
}

/* ------------------------------------------------------------- 4. pruebas ------ */

static void fila_prueba(Consola *c, const PruebaInfo *p) {
    char pct[24];
    porcentaje(p->relevancia, pct, sizeof pct);
    fprintf(c->out, "    Rp %s  %s (%s)\n", pct, p->nombre, p->nombre_componente);
}

static void menu_pruebas(Consola *c) {
    Controlador *k = c->k;
    titulo(c, "Pruebas adicionales");
    if (!requiere_diagnostico(c)) return;
    controlador_recomendar_pruebas(k);
    while (!c->fin) {
        aviso(c, k->aviso_pruebas, k->aviso_pruebas_error);
        if (!k->hay_rec) return;
        const Recomendacion *r = &k->rec;
        fprintf(c->out, "  Iteraciones usadas: %d de %d\n", r->iteraciones, r->max_iteraciones);
        if (r->n_realizadas) {
            fprintf(c->out, "  Pruebas realizadas:\n");
            for (int i = 0; i < r->n_realizadas; i++)
                fprintf(c->out, "    %d. %s (%s): %s\n", i + 1, r->realizadas[i].nombre,
                        r->realizadas[i].nombre_componente, resultado_prueba_texto(r->realizadas[i].resultado));
        }
        if (!r->hay_pendiente) {
            fprintf(c->out, "  Sin pruebas pendientes.\n");
            parrafo(c, 2, r->mensaje);
            if (k->hay_diag) mostrar_componentes(c, &k->diag);
            return;
        }
        fprintf(c->out, "  PRUEBA RECOMENDADA\n");
        fila_prueba(c, &r->pendiente);
        parrafo(c, 4, r->pendiente.texto);
        if (r->n_foco) {
            fprintf(c->out, "  Otras pruebas del mismo componente:\n");
            for (int i = 0; i < r->n_foco; i++) fila_prueba(c, &r->del_foco[i]);
        }
        if (r->n_otras) {
            fprintf(c->out, "  Pruebas de otros candidatos (el sistema las pedirá en orden):\n");
            for (int i = 0; i < r->n_otras; i++) fila_prueba(c, &r->otras[i]);
        }
        fprintf(c->out, "  Resultado de la prueba recomendada:\n");
        for (int i = 0; i < r->n_resultados; i++)
            fprintf(c->out, "    %d. %s\n", i + 1, resultado_prueba_texto(r->resultados[i]));
        fprintf(c->out, "    0. Volver al menú sin registrar\n");
        int op = leer_opcion(c, "Resultado", 0, r->n_resultados);
        if (op <= 0) return;
        char prueba[ID_LEN], res[RESULTADO_LEN];
        snprintf(prueba, sizeof prueba, "%s", r->pendiente.prueba);
        snprintf(res, sizeof res, "%s", r->resultados[op - 1]);
        controlador_registrar_resultado(k, prueba, res);
        revisar_conexion(c);
    }
}

/* ------------------------------------------------------------- 5. explicación -- */

static void menu_explicacion(Consola *c) {
    Controlador *k = c->k;
    titulo(c, "Explicación del razonamiento");
    if (!requiere_diagnostico(c)) return;
    controlador_explicar(k);
    aviso(c, k->aviso_expl, k->aviso_expl_error);
    if (!k->hay_expl) return;
    const Explicacion *x = &k->expl;
    parrafo(c, 2, x->conclusion);
    fprintf(c->out, "\n  Resumen por componente confirmado:\n");
    int conf = 0;
    for (int i = 0; i < x->n_comps; i++)
        if (x->comps[i].estado == COMP_CONFIRMADO) { parrafo(c, 4, x->comps[i].texto); conf++; }
    if (!conf) fprintf(c->out, "    Ningún componente quedó confirmado.\n");
    fprintf(c->out, "\n  Traza del razonamiento:\n");
    int max = explicacion_max_iteracion(x);
    for (int it = 0; it <= max; it++) {
        int hay = 0;
        for (int i = 0; i < x->n_traza; i++) hay |= x->traza[i].iteracion == it;
        if (!hay) continue;
        if (it == 0) fprintf(c->out, "  [Antes de las pruebas]\n");
        else fprintf(c->out, "  [Iteración %d]\n", it);
        for (int i = 0; i < x->n_traza; i++)
            if (x->traza[i].iteracion == it) parrafo(c, 4, x->traza[i].texto);
    }
    if (x->n_pruebas) {
        fprintf(c->out, "\n  Por qué se sugieren las pruebas:\n");
        for (int i = 0; i < x->n_pruebas; i++) parrafo(c, 4, x->pruebas[i].texto);
    }
}

/* ------------------------------------------------------------- 6. acciones ----- */

static void menu_acciones(Consola *c) {
    Controlador *k = c->k;
    titulo(c, "Acciones correctivas");
    if (!requiere_diagnostico(c)) return;
    controlador_acciones(k);
    aviso(c, k->aviso_acc, k->aviso_acc_error);
    if (!k->hay_acc) return;
    parrafo(c, 2, k->acc.mensaje);
    char p[24];
    for (int i = 0; i < k->acc.n; i++) {
        const Accion *a = &k->acc.items[i];
        porcentaje(a->relevancia, p, sizeof p);
        fprintf(c->out, "  %d. Ra %s  %s\n", i + 1, p, a->nombre);
        for (int j = 0; j < a->n_origen; j++)
            fprintf(c->out, "       Origen: %s (P = %.1f %%, efectividad %.2f)\n", a->origen[j].nombre,
                    a->origen[j].probabilidad * 100.0, a->origen[j].efectividad);
    }
}

/* ------------------------------------------------------------- 7. guardar ------ */

static void menu_guardar(Consola *c) {
    Controlador *k = c->k;
    titulo(c, "Guardar diagnóstico");
    controlador_guardar(k);
    aviso(c, k->aviso_guardar, k->aviso_guardar_error);
}

/* ------------------------------------------------------------- 8. historial ---- */

static void exportar_reporte(Consola *c, int id) {
    Controlador *k = c->k;
    if (controlador_reporte(k, id)) controlador_exportar(k);
    aviso(c, k->aviso_rep, k->aviso_rep_error);
}

static void mostrar_guardado(Consola *c, const DiagGuardado *g) {
    Controlador *k = c->k;
    fprintf(c->out, "  Diagnóstico %d · %s\n  Vehículo: %s\n  Datos ingresados:\n", g->id, g->fecha, g->vehiculo);
    for (int i = 0; i < g->n_entrada; i++) {
        const char *nom = g->entrada[i].id;
        for (int j = 0; j < k->cat.n; j++) if (!strcmp(k->cat.items[j].id, nom)) nom = k->cat.items[j].nombre;
        fprintf(c->out, "    - %s: %s\n", nom, g->entrada[i].estado);
    }
    mostrar_diagnostico(c, &g->diag);
}

static void menu_historial(Consola *c) {
    Controlador *k = c->k;
    titulo(c, "Historial");
    controlador_listar(k);
    aviso(c, k->aviso_hist, k->aviso_hist_error);
    if (!k->hay_hist) return;
    if (k->hist.n == 0) { fprintf(c->out, "  Todavía no hay diagnósticos guardados (opción 7).\n"); return; }
    for (int i = 0; i < k->hist.n; i++) {
        const ResumenDiag *r = &k->hist.items[i];
        fprintf(c->out, "  %d. %s · %s · %s", r->id, r->fecha, r->vehiculo, r->concluyente ? "Concluyente" : "No concluyente");
        if (r->probabilidad >= 0) fprintf(c->out, " · %s %.1f %%", r->principal, r->probabilidad * 100.0);
        fputc('\n', c->out);
    }
    int max = k->hist.items[k->hist.n - 1].id;
    int id = leer_opcion(c, "Número del diagnóstico a ver (0 para volver)", 0, max);
    if (id <= 0) return;
    if (!controlador_abrir(k, id)) { aviso(c, k->aviso_hist, 1); return; }
    mostrar_guardado(c, &k->abierto);
    if (confirmar(c, "¿Exportar el reporte de este diagnóstico?")) exportar_reporte(c, id);
}

/* ------------------------------------------------------------- 9. reporte ------ */

static void menu_reporte(Consola *c) {
    Controlador *k = c->k;
    titulo(c, "Reporte");
    if (!requiere_diagnostico(c)) return;
    if (k->guardado_id == 0) {                          /* RNF-01: el reporte sale del historial */
        fprintf(c->out, "  El reporte se genera desde el historial: primero hay que guardar el diagnóstico.\n");
        if (!confirmar(c, "¿Guardarlo ahora?")) return;
        controlador_guardar(k);
        aviso(c, k->aviso_guardar, k->aviso_guardar_error);
        if (k->guardado_id == 0) return;
    }
    if (!controlador_reporte(k, k->guardado_id)) { aviso(c, k->aviso_rep, 1); return; }
    fprintf(c->out, "\n%s\n\n", k->rep.texto);
    if (confirmar(c, "¿Exportar el reporte a un archivo?")) {
        controlador_exportar(k);
        aviso(c, k->aviso_rep, k->aviso_rep_error);
    }
}

/* ------------------------------------------------------------- menú principal -- */

static void estado(Consola *c) {
    Controlador *k = c->k;
    char v[512] = "sin registrar";
    if (k->registrado) vehiculo_resumen(&k->guardado, v, sizeof v);
    fprintf(c->out, "  Prolog: %s · Vehículo: %s\n", (k->hay_error || !conexion_viva(&k->con)) ? "sin conexión" : "conectado", v);
    fprintf(c->out, "  Síntomas: %d · Diagnóstico: %s%s\n", k->sel.n,
            !k->hay_diag ? "no calculado" : k->diag.concluyente ? "concluyente" : "no concluyente",
            k->guardado_id ? " (guardado)" : "");
}

int consola_ejecutar(Controlador *k, FILE *in, FILE *out) {
    Consola c = { k, in, out, 0 };
    fprintf(out, "SISTEMA EXPERTO DE DIAGNÓSTICO AUTOMOTRIZ (modo consola)\n");
    fprintf(out, "Los resultados son hipótesis, no certezas: confírmelos con un técnico.\n");
    controlador_probar_conexion(k);
    while (!c.fin) {
        revisar_conexion(&c);
        if (c.fin) break;
        titulo(&c, "Menú principal");
        estado(&c);
        const char *req = k->hay_diag ? "" : "  (requiere diagnóstico)";
        fprintf(out, "\n  1. Registrar o editar el vehículo\n  2. Seleccionar síntomas\n  3. Diagnosticar\n"
                     "  4. Pruebas adicionales%s\n  5. Explicación del razonamiento%s\n  6. Acciones correctivas%s\n"
                     "  7. Guardar diagnóstico\n  8. Historial de diagnósticos\n  9. Reporte%s\n  0. Salir\n",
                req, req, req, req);
        int op = leer_opcion(&c, "Opción", 0, 9);
        switch (op) {
        case 1: menu_vehiculo(&c); break;
        case 2: menu_sintomas(&c); break;
        case 3: menu_diagnosticar(&c); break;
        case 4: menu_pruebas(&c); break;
        case 5: menu_explicacion(&c); break;
        case 6: menu_acciones(&c); break;
        case 7: menu_guardar(&c); break;
        case 8: menu_historial(&c); break;
        case 9: menu_reporte(&c); break;
        default: c.fin = 1; break;      /* 0 = Salir, -1 = fin de la entrada */
        }
    }
    fprintf(out, "Hasta luego.\n");
    return 0;
}
