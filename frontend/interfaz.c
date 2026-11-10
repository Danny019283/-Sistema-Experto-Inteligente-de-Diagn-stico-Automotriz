#include "interfaz.h"
#include "menu.h"

#include <stdio.h>
#include <string.h>

#define NK_INCLUDE_FIXED_TYPES
#define NK_INCLUDE_STANDARD_IO
#define NK_INCLUDE_STANDARD_VARARGS
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_INCLUDE_VERTEX_BUFFER_OUTPUT
#define NK_INCLUDE_FONT_BAKING
#define NK_IMPLEMENTATION
#define NK_SDL_RENDERER_IMPLEMENTATION
#define NK_SDL_RENDERER_SDL_H <SDL2/SDL.h>
/* Nuklear no es nuestro código: sus warnings no cuentan. */
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wall"
#pragma GCC diagnostic ignored "-Wextra"
#include "nuklear.h"
#include "nuklear_sdl_renderer.h"
#pragma GCC diagnostic pop

#ifndef FUENTE_TTF
#error "FUENTE_TTF la define el Makefile (DejaVu Sans)"
#endif

#define PING_CADA_MS 5000

/* Una fila por línea del texto (nk_text_wrap ignora los '\n'). */
static void lineas(struct nk_context *ctx, const char *txt, float alto) {
    nk_layout_row_dynamic(ctx, alto, 1);
    for (const char *p = txt; *p;) {
        const char *nl = strchr(p, '\n');
        int len = nl ? (int)(nl - p) : (int)strlen(p);
        nk_text_wrap(ctx, p, len);
        p += len + (nl ? 1 : 0);
    }
}

/* Fila "etiqueta + campo de texto" y, debajo, el error del campo si lo hay (RNF-02). */
static void campo_texto(struct nk_context *ctx, const char *etiqueta, char *buf, int n, const char *err) {
    nk_layout_row_dynamic(ctx, 32, 2);
    nk_label(ctx, etiqueta, NK_TEXT_LEFT);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, buf, n, nk_filter_default);
    if (err[0]) {
        nk_layout_row_dynamic(ctx, 22, 1);
        nk_label_colored(ctx, err, NK_TEXT_LEFT, nk_rgb(230, 80, 80));
    }
}

/* F04: formulario del vehículo. El texto escrito vive en k->form y no se toca al fallar. */
static void pantalla_vehiculo(struct nk_context *ctx, Controlador *k, Menu *m) {
    FormVehiculo *f = &k->form;
    if (k->registrado) {
        char r[512];
        vehiculo_resumen(&k->guardado, r, sizeof r);
        nk_layout_row_dynamic(ctx, 26, 1);
        nk_label_colored(ctx, "Vehículo registrado:", NK_TEXT_LEFT, nk_rgb(90, 200, 120));
        nk_label(ctx, r, NK_TEXT_LEFT);
    }
    campo_texto(ctx, "Marca", f->marca, sizeof f->marca, k->errores[VF_MARCA]);
    campo_texto(ctx, "Modelo", f->modelo, sizeof f->modelo, k->errores[VF_MODELO]);
    campo_texto(ctx, "Año", f->anio, sizeof f->anio, k->errores[VF_ANIO]);
    campo_texto(ctx, "Cilindrada", f->cilindrada, sizeof f->cilindrada, k->errores[VF_CILINDRADA]);
    nk_layout_row_dynamic(ctx, 32, 2);
    nk_label(ctx, "Combustible", NK_TEXT_LEFT);
    if (nk_combo_begin_label(ctx, f->combustible >= 0 ? VF_COMBUSTIBLE_ETIQUETA[f->combustible] : "Elige...",
                             nk_vec2(nk_widget_width(ctx), 180))) {
        nk_layout_row_dynamic(ctx, 28, 1);
        for (int i = 0; i < VF_N_COMBUSTIBLES; i++)
            if (nk_combo_item_label(ctx, VF_COMBUSTIBLE_ETIQUETA[i], NK_TEXT_LEFT)) f->combustible = i;
        nk_combo_end(ctx);
    }
    if (k->errores[VF_COMBUSTIBLE][0]) {
        nk_layout_row_dynamic(ctx, 22, 1);
        nk_label_colored(ctx, k->errores[VF_COMBUSTIBLE], NK_TEXT_LEFT, nk_rgb(230, 80, 80));
    }
    campo_texto(ctx, "Kilometraje", f->km, sizeof f->km, k->errores[VF_KM]);
    if (k->error_form[0]) {
        nk_layout_row_dynamic(ctx, 60, 1);
        nk_label_colored_wrap(ctx, k->error_form, nk_rgb(230, 80, 80));
    }
    nk_layout_row_dynamic(ctx, 38, 1);
    if (nk_button_label(ctx, k->registrado ? "Guardar cambios" : "Registrar vehículo")
        && controlador_registrar_vehiculo(k))
        m->vehiculo = 1;
}

/* ------------------------------------------------------------------ F05 / F06 ---- */
#define VERDE  nk_rgb(90, 200, 120)
#define AMBAR  nk_rgb(240, 180, 60)
#define GRIS   nk_rgb(140, 140, 140)
#define ROJO   nk_rgb(230, 80, 80)
#define AZUL   nk_rgb(120, 170, 255)

/* Mayúsculas ASCII y letras acentuadas Latin-1 en UTF-8 (á -> Á, ó -> Ó, ñ -> Ñ...). */
static void mayusculas(const char *src, char *dst, size_t n) {
    size_t i = 0;
    for (; src[i] && i + 1 < n; i++) {
        unsigned char c = (unsigned char)src[i];
        if (c >= 'a' && c <= 'z') dst[i] = (char)(c - 32);
        else if (c == 0xC3 && src[i + 1] && i + 2 < n) {
            unsigned char d = (unsigned char)src[i + 1];
            dst[i++] = (char)c;
            dst[i] = (char)((d >= 0xA0 && d <= 0xBE && d != 0xB7) ? d - 0x20 : d);
        } else dst[i] = (char)c;
    }
    dst[i] = '\0';
}

/* Etiqueta con fondo de color (no interactiva): distingue concluyente de no concluyente. */
static void insignia(struct nk_context *ctx, const char *txt, struct nk_color fondo) {
    struct nk_style_item it = nk_style_item_color(fondo);
    nk_style_push_style_item(ctx, &ctx->style.button.normal, it);
    nk_style_push_style_item(ctx, &ctx->style.button.hover, it);
    nk_style_push_style_item(ctx, &ctx->style.button.active, it);
    nk_style_push_color(ctx, &ctx->style.button.text_normal, nk_rgb(20, 20, 20));
    nk_style_push_color(ctx, &ctx->style.button.text_hover, nk_rgb(20, 20, 20));
    nk_style_push_color(ctx, &ctx->style.button.text_active, nk_rgb(20, 20, 20));
    (void)nk_button_label(ctx, txt);
    for (int i = 0; i < 3; i++) nk_style_pop_color(ctx);
    for (int i = 0; i < 3; i++) nk_style_pop_style_item(ctx);
}

static void barra_prob(struct nk_context *ctx, double p, struct nk_color col) {
    nk_size v = (nk_size)(p * 1000.0 + 0.5);
    struct nk_style_item it = nk_style_item_color(col);
    nk_style_push_style_item(ctx, &ctx->style.progress.cursor_normal, it);
    nk_style_push_style_item(ctx, &ctx->style.progress.cursor_hover, it);
    nk_style_push_style_item(ctx, &ctx->style.progress.cursor_active, it);
    nk_progress(ctx, &v, 1000, NK_FIXED);
    for (int i = 0; i < 3; i++) nk_style_pop_style_item(ctx);
}

static struct nk_color color_estado(EstadoComp e) {
    return e == COMP_CONFIRMADO ? VERDE : e == COMP_DESCARTADO ? GRIS : AMBAR;
}

/* Catálogo agrupado por sistema; cada síntoma con presente / ausente / desconocido. */
static void panel_catalogo(struct nk_context *ctx, Controlador *k) {
    if (!k->catalogo_ok) {
        nk_layout_row_dynamic(ctx, 90, 1);
        nk_label_colored_wrap(ctx, "Catálogo vacío o no disponible: el diagnóstico queda deshabilitado. "
                                   "Revisa la conexión o la base de conocimiento.", ROJO);
        return;
    }
    static const char *rot[] = { "Presente", "Ausente", "Desconocido" };
    static const EstadoSintoma ord[] = { EST_PRESENTE, EST_AUSENTE, EST_DESCONOCIDO };
    const char *previo = "";
    for (int i = 0; i < k->cat.n; i++) {
        const SintomaCat *s = &k->cat.items[i];
        if (strcmp(s->sistema, previo) != 0) {
            char may[SISTEMA_LEN];
            mayusculas(s->sistema, may, sizeof may);
            nk_layout_row_dynamic(ctx, 28, 1);
            nk_label_colored(ctx, may, NK_TEXT_LEFT, AZUL);
            previo = s->sistema;
        }
        EstadoSintoma actual = seleccion_estado(&k->sel, s->id);
        nk_layout_row_dynamic(ctx, 22, 1);
        nk_label(ctx, s->nombre, NK_TEXT_LEFT);
        nk_layout_row_dynamic(ctx, 24, 3);
        struct nk_style_item oscuro = nk_style_item_color(nk_rgb(55, 55, 55));
        struct nk_style_item punto = nk_style_item_color(VERDE);
        nk_style_push_style_item(ctx, &ctx->style.option.normal, oscuro);
        nk_style_push_style_item(ctx, &ctx->style.option.hover, oscuro);
        nk_style_push_style_item(ctx, &ctx->style.option.active, oscuro);
        nk_style_push_style_item(ctx, &ctx->style.option.cursor_normal, punto);
        nk_style_push_style_item(ctx, &ctx->style.option.cursor_hover, punto);
        for (int j = 0; j < 3; j++)
            if (nk_option_label(ctx, rot[j], actual == ord[j]) && actual != ord[j])
                controlador_marcar(k, s->id, ord[j]);
        for (int j = 0; j < 5; j++) nk_style_pop_style_item(ctx);
    }
}

/* Panel «Síntomas seleccionados»: refleja exactamente lo que Prolog confirmó. */
static void panel_seleccion(struct nk_context *ctx, Controlador *k, Menu *m) {
    if (k->sel.n == 0) {
        nk_layout_row_dynamic(ctx, 26, 1);
        nk_label(ctx, "Aún no hay síntomas marcados.", NK_TEXT_LEFT);
    }
    for (int i = 0; i < k->sel.n; i++) {
        const SintomaSel *s = &k->sel.items[i];
        float r[] = { 0.55f, 0.45f };
        nk_layout_row_dynamic(ctx, 22, 1);
        nk_label(ctx, s->nombre, NK_TEXT_LEFT);
        nk_layout_row(ctx, NK_DYNAMIC, 24, 2, r);
        nk_label_colored(ctx, estado_texto(s->estado), NK_TEXT_LEFT,
            s->estado == EST_PRESENTE ? VERDE : s->estado == EST_AUSENTE ? AMBAR : GRIS);
        if (nk_button_label(ctx, "Quitar")) { controlador_quitar(k, s->id); break; }
    }
    nk_layout_row_dynamic(ctx, 24, 1);
    nk_labelf_colored(ctx, NK_TEXT_LEFT, nk_rgb(180, 180, 180), "Seleccionados: %d. Al cálculo: %d",
                      k->sel.n, seleccion_cuenta_calculo(&k->sel));
    nk_layout_row_dynamic(ctx, 20, 1);
    nk_label_colored(ctx, "Desconocido no entra al cálculo.", NK_TEXT_LEFT, GRIS);
    nk_layout_row_dynamic(ctx, 34, 1);
    if (nk_button_label(ctx, "Limpiar selección")) controlador_limpiar(k);
    int listo = controlador_puede_diagnosticar(k);
    if (!listo) nk_widget_disable_begin(ctx);
    if (nk_button_label(ctx, "Ir a Diagnóstico") && listo) menu_ir(m, PANT_DIAGNOSTICO);
    if (!listo) nk_widget_disable_end(ctx);
    if (!listo) {
        nk_layout_row_dynamic(ctx, 44, 1);
        nk_label_wrap(ctx, !k->catalogo_ok ? "Sin catálogo: diagnóstico deshabilitado."
            : k->contra.pendiente ? "Resuelve la contradicción para continuar."
            : "Marca al menos un síntoma como presente o ausente.");
    }
}

static void pantalla_sintomas(struct nk_context *ctx, Controlador *k, Menu *m) {
    float alto = nk_window_get_content_region(ctx).h - 30 - 16 - (k->aviso[0] ? 70.0f : 0.0f);
    if (alto < 220) alto = 220;
    if (k->aviso[0]) {
        nk_layout_row_dynamic(ctx, 70, 1);
        nk_label_colored_wrap(ctx, k->aviso, ROJO);
    }
    float r2[] = { 0.56f, 0.44f };
    nk_layout_row(ctx, NK_DYNAMIC, alto, 2, r2);
    if (nk_group_begin(ctx, "Catálogo de síntomas", NK_WINDOW_BORDER | NK_WINDOW_TITLE)) {
        panel_catalogo(ctx, k);
        nk_group_end(ctx);
    }
    if (nk_group_begin(ctx, "Síntomas seleccionados", NK_WINDOW_BORDER | NK_WINDOW_TITLE)) {
        panel_seleccion(ctx, k, m);
        nk_group_end(ctx);
    }
}

static void fila_componente(struct nk_context *ctx, const Componente *c) {
    char tit[NOMBRE_LEN + SISTEMA_LEN + 8], pct[24];
    snprintf(tit, sizeof tit, "%s  (%s)", c->nombre, c->sistema);
    nk_layout_row_dynamic(ctx, 22, 1);
    nk_label(ctx, tit, NK_TEXT_LEFT);
    float r[] = { 0.52f, 0.20f, 0.28f };
    nk_layout_row(ctx, NK_DYNAMIC, 22, 3, r);
    barra_prob(ctx, c->prob, color_estado(c->estado));
    snprintf(pct, sizeof pct, "%.1f %%", c->prob * 100.0);
    nk_label(ctx, pct, NK_TEXT_RIGHT);
    nk_label_colored(ctx, estado_comp_texto(c->estado), NK_TEXT_LEFT, color_estado(c->estado));
}

static void resultado_diagnostico(struct nk_context *ctx, const Diagnostico *d) {
    char t[160];
    nk_layout_row_dynamic(ctx, 36, 1);
    insignia(ctx, d->concluyente ? "DIAGNÓSTICO CONCLUYENTE" : "DIAGNÓSTICO NO CONCLUYENTE",
             d->concluyente ? VERDE : AMBAR);
    nk_layout_row_dynamic(ctx, 24, 1);
    nk_labelf(ctx, NK_TEXT_LEFT, "Iteraciones usadas: %d de %d", d->iteraciones, d->max_iteraciones);
    snprintf(t, sizeof t, "Motivo: %s.", motivo_texto(d->motivo));
    nk_layout_row_dynamic(ctx, 44, 1);
    nk_label_colored_wrap(ctx, t, d->concluyente ? nk_rgb(180, 180, 180) : AMBAR);
    if (!d->concluyente && d->prueba_sugerida[0]) {
        snprintf(t, sizeof t, "Prueba sugerida: %s", d->prueba_sugerida);
        nk_layout_row_dynamic(ctx, 44, 1);
        nk_label_colored_wrap(ctx, t, AMBAR);
    }
    nk_layout_row_dynamic(ctx, 28, 1);
    nk_label_colored(ctx, "HIPÓTESIS (por probabilidad)", NK_TEXT_LEFT, AZUL);
    int hay_desc = 0;
    for (int i = 0; i < d->n; i++) {
        if (d->comps[i].estado == COMP_DESCARTADO) { hay_desc = 1; continue; }
        fila_componente(ctx, &d->comps[i]);
    }
    if (hay_desc) {   /* las descartadas se muestran aparte, con su probabilidad */
        nk_layout_row_dynamic(ctx, 28, 1);
        nk_label_colored(ctx, "DESCARTADAS", NK_TEXT_LEFT, GRIS);
        for (int i = 0; i < d->n; i++)
            if (d->comps[i].estado == COMP_DESCARTADO) fila_componente(ctx, &d->comps[i]);
    }
}

static void pantalla_diagnostico(struct nk_context *ctx, Controlador *k, Menu *m) {
    if (k->registrado) {   /* resumen del vehículo (F04) */
        char r[512];
        vehiculo_resumen(&k->guardado, r, sizeof r);
        nk_layout_row_dynamic(ctx, 26, 1);
        nk_label(ctx, r, NK_TEXT_LEFT);
    }
    nk_layout_row_dynamic(ctx, 24, 1);
    nk_labelf(ctx, NK_TEXT_LEFT, "Síntomas seleccionados: %d (al cálculo: %d)", k->sel.n,
              seleccion_cuenta_calculo(&k->sel));
    int listo = controlador_puede_diagnosticar(k);
    nk_layout_row_dynamic(ctx, 40, 1);
    if (!listo) nk_widget_disable_begin(ctx);
    if (nk_button_label(ctx, "Diagnosticar") && listo) controlador_diagnosticar(k);
    if (!listo) nk_widget_disable_end(ctx);
    if (k->aviso_diag[0]) {
        nk_layout_row_dynamic(ctx, 84, 1);
        nk_label_colored_wrap(ctx, k->aviso_diag, k->aviso_diag_error ? ROJO : AMBAR);
    } else if (!k->hay_diag) {
        nk_layout_row_dynamic(ctx, 44, 1);
        nk_label_wrap(ctx, "Pulsa Diagnosticar para ver todas las hipótesis.");
    }
    if (k->hay_diag && !k->diag.concluyente && k->diag.prueba_sugerida[0]) {   /* F07 */
        nk_layout_row_dynamic(ctx, 36, 1);
        if (nk_button_label(ctx, "Registrar el resultado de la prueba sugerida")) menu_ir(m, PANT_PRUEBAS);
    }
    if (k->hay_diag) resultado_diagnostico(ctx, &k->diag);
}

/* ----------------------------------------------------------------------- F07 ---- */

/* Una prueba sugerida: nombre, componente que verifica y relevancia Rp con su barra. */
static void fila_prueba(struct nk_context *ctx, const PruebaInfo *p) {
    char pct[24];
    nk_layout_row_dynamic(ctx, 22, 1);
    nk_label(ctx, p->nombre, NK_TEXT_LEFT);
    float r[] = { 0.48f, 0.32f, 0.20f };
    nk_layout_row(ctx, NK_DYNAMIC, 22, 3, r);
    nk_label_colored(ctx, p->nombre_componente, NK_TEXT_LEFT, GRIS);
    barra_prob(ctx, p->relevancia, AZUL);
    snprintf(pct, sizeof pct, "Rp %.1f %%", p->relevancia * 100.0);
    nk_label(ctx, pct, NK_TEXT_RIGHT);
}

/* Tarjeta de la prueba pendiente: por qué se sugiere, resultado a elegir y botón Registrar.
 * El resultado elegido se olvida si la prueba pendiente cambia. */
static void tarjeta_pendiente(struct nk_context *ctx, Controlador *k) {
    static char prueba_de[ID_LEN] = "", elegido[RESULTADO_LEN] = "";
    const Recomendacion *rec = &k->rec;
    const PruebaInfo *p = &rec->pendiente;
    if (strcmp(prueba_de, p->prueba) != 0) {
        snprintf(prueba_de, sizeof prueba_de, "%s", p->prueba);
        elegido[0] = '\0';
    }
    nk_layout_row_dynamic(ctx, 28, 1);
    nk_label_colored(ctx, "PRUEBA RECOMENDADA", NK_TEXT_LEFT, AZUL);
    fila_prueba(ctx, p);
    nk_layout_row_dynamic(ctx, 66, 1);
    nk_label_wrap(ctx, p->texto);
    nk_layout_row_dynamic(ctx, 24, 1);
    nk_label(ctx, "Resultado de la prueba:", NK_TEXT_LEFT);
    nk_layout_row_dynamic(ctx, 28, rec->n_resultados);
    for (int i = 0; i < rec->n_resultados; i++)
        if (nk_option_label(ctx, resultado_prueba_texto(rec->resultados[i]),
                            !strcmp(elegido, rec->resultados[i])))
            snprintf(elegido, sizeof elegido, "%s", rec->resultados[i]);
    int listo = elegido[0] != '\0';
    nk_layout_row_dynamic(ctx, 38, 1);
    if (!listo) nk_widget_disable_begin(ctx);
    if (nk_button_label(ctx, "Registrar resultado") && listo) {
        char r[RESULTADO_LEN];
        snprintf(r, sizeof r, "%s", elegido);
        if (controlador_registrar_resultado(k, p->prueba, r)) elegido[0] = '\0';
    }
    if (!listo) nk_widget_disable_end(ctx);
    if (!listo) {
        nk_layout_row_dynamic(ctx, 22, 1);
        nk_label_colored(ctx, "Elija normal, leve o severo para registrar.", NK_TEXT_LEFT, GRIS);
    }
}

/* Columna izquierda: la pendiente (o por qué no hay) y las de los demás candidatos. */
static void panel_recomendadas(struct nk_context *ctx, Controlador *k) {
    const Recomendacion *rec = &k->rec;
    if (rec->hay_pendiente) {
        tarjeta_pendiente(ctx, k);
    } else {   /* RNF-02: un mensaje que explica por qué, no una lista vacía */
        nk_layout_row_dynamic(ctx, 28, 1);
        nk_label_colored(ctx, "SIN PRUEBAS PENDIENTES", NK_TEXT_LEFT, AZUL);
        nk_layout_row_dynamic(ctx, 66, 1);
        nk_label_colored_wrap(ctx, rec->mensaje, k->diag.concluyente ? VERDE : AMBAR);
    }
    if (rec->n_foco > 0) {
        nk_layout_row_dynamic(ctx, 28, 1);
        nk_label_colored(ctx, "OTRAS PRUEBAS DEL MISMO COMPONENTE", NK_TEXT_LEFT, AZUL);
        for (int i = 0; i < rec->n_foco; i++) fila_prueba(ctx, &rec->del_foco[i]);
    }
    nk_layout_row_dynamic(ctx, 28, 1);
    nk_label_colored(ctx, "PRUEBAS DE OTROS CANDIDATOS", NK_TEXT_LEFT, AZUL);
    if (rec->n_otras == 0) {
        nk_layout_row_dynamic(ctx, 22, 1);
        nk_label_colored(ctx, "No hay pruebas para otros candidatos.", NK_TEXT_LEFT, GRIS);
    }
    for (int i = 0; i < rec->n_otras; i++) fila_prueba(ctx, &rec->otras[i]);
    if (rec->hay_pendiente && rec->n_otras + rec->n_foco > 0) {
        nk_layout_row_dynamic(ctx, 44, 1);
        nk_label_colored_wrap(ctx, "El sistema las pedirá en orden: primero registre la prueba recomendada.", GRIS);
    }
}

/* Columna derecha: el diagnóstico actualizado y las pruebas ya realizadas con su resultado. */
static void panel_estado_pruebas(struct nk_context *ctx, Controlador *k) {
    const Diagnostico *d = &k->diag;
    nk_layout_row_dynamic(ctx, 36, 1);
    insignia(ctx, d->concluyente ? "DIAGNÓSTICO CONCLUYENTE" : "DIAGNÓSTICO NO CONCLUYENTE",
             d->concluyente ? VERDE : AMBAR);
    nk_layout_row_dynamic(ctx, 24, 1);
    nk_labelf(ctx, NK_TEXT_LEFT, "Iteraciones usadas: %d de %d", k->rec.iteraciones, k->rec.max_iteraciones);
    nk_layout_row_dynamic(ctx, 28, 1);
    nk_label_colored(ctx, "PRUEBAS REALIZADAS", NK_TEXT_LEFT, AZUL);
    if (k->rec.n_realizadas == 0) {
        nk_layout_row_dynamic(ctx, 22, 1);
        nk_label_colored(ctx, "Todavía no se registró ninguna.", NK_TEXT_LEFT, GRIS);
    }
    for (int i = 0; i < k->rec.n_realizadas; i++) {
        const PruebaInfo *p = &k->rec.realizadas[i];
        char t[NOMBRE_LEN + 8];
        snprintf(t, sizeof t, "%d. %s", i + 1, p->nombre);
        nk_layout_row_dynamic(ctx, 40, 1);           /* dos líneas: los nombres de prueba son largos */
        nk_label_wrap(ctx, t);
        nk_layout_row_dynamic(ctx, 22, 2);
        nk_label_colored(ctx, p->nombre_componente, NK_TEXT_LEFT, GRIS);
        nk_labelf_colored(ctx, NK_TEXT_LEFT, strcmp(p->resultado, "normal") ? AMBAR : VERDE,
                          "Resultado: %s", resultado_prueba_texto(p->resultado));
    }
    nk_layout_row_dynamic(ctx, 28, 1);
    nk_label_colored(ctx, "HIPÓTESIS (por probabilidad)", NK_TEXT_LEFT, AZUL);
    for (int i = 0; i < d->n; i++)
        if (d->comps[i].estado != COMP_DESCARTADO) fila_componente(ctx, &d->comps[i]);
}

/* F07 · paso 13: el sistema recomienda la prueba de mayor Rp (Prolog, R7) y el usuario registra
 * su resultado; Prolog recalcula (R8) y aquí se ve el diagnóstico actualizado. */
static void pantalla_pruebas(struct nk_context *ctx, Controlador *k) {
    if (k->hay_diag && !k->rec_al_dia) controlador_recomendar_pruebas(k);   /* al entrar o si cambió */
    nk_layout_row_dynamic(ctx, 34, 1);
    if (nk_button_label(ctx, "Actualizar recomendaciones")) controlador_recomendar_pruebas(k);
    if (k->aviso_pruebas[0]) {
        nk_layout_row_dynamic(ctx, 50, 1);
        nk_label_colored_wrap(ctx, k->aviso_pruebas, k->aviso_pruebas_error ? ROJO : VERDE);
    }
    if (!k->hay_rec) {
        if (!k->aviso_pruebas[0]) {
            nk_layout_row_dynamic(ctx, 44, 1);
            nk_label_wrap(ctx, "Primero genere un diagnóstico.");
        }
        return;
    }
    float alto = nk_window_get_content_region(ctx).h - 30 - 34 - 16 - (k->aviso_pruebas[0] ? 54.0f : 0.0f);
    if (alto < 260) alto = 260;
    float r2[] = { 0.54f, 0.46f };
    nk_layout_row(ctx, NK_DYNAMIC, alto, 2, r2);
    if (nk_group_begin(ctx, "Pruebas recomendadas", NK_WINDOW_BORDER | NK_WINDOW_TITLE)) {
        panel_recomendadas(ctx, k);
        nk_group_end(ctx);
    }
    if (nk_group_begin(ctx, "Diagnóstico actualizado", NK_WINDOW_BORDER | NK_WINDOW_TITLE)) {
        panel_estado_pruebas(ctx, k);
        nk_group_end(ctx);
    }
}

/* ----------------------------------------------------------------------- F08 ---- */

/* Párrafo con salto de línea: el alto de la fila se calcula midiendo el texto con la fuente
 * (nk_label_wrap necesita un alto fijo y los textos de Prolog tienen largo variable). */
static void parrafo(struct nk_context *ctx, const char *txt, struct nk_color col) {
    const struct nk_user_font *f = ctx->style.font;
    float ancho = nk_window_get_content_region(ctx).w - 24;
    float total = f->width(f->userdata, f->height, txt, (int)strlen(txt));
    int lineas = ancho > 40 ? (int)(total * 1.12f / ancho) + 1 : 1;   /* margen por el corte de palabras */
    nk_layout_row_dynamic(ctx, lineas * (f->height + 4) + 4, 1);
    nk_label_colored_wrap(ctx, txt, col);
}

static struct nk_color color_regla(const char *r) {
    if (!strncmp(r, "RB", 2)) return AMBAR;                   /* retrocesos RB1, RB2, RB3 */
    if (!strcmp(r, "R10") || !strcmp(r, "R9")) return VERDE;  /* aportes y acciones */
    if (!strcmp(r, "R2b")) return ROJO;
    return nk_rgb(215, 215, 215);
}

/* Traza: un nodo desplegable por iteración, con sus eventos en orden cronológico. */
static void traza_por_iteracion(struct nk_context *ctx, const Explicacion *x) {
    int max = explicacion_max_iteracion(x);
    for (int it = 0; it <= max; it++) {
        int n = 0;
        for (int i = 0; i < x->n_traza; i++) n += x->traza[i].iteracion == it;
        if (n == 0) continue;
        char tit[64];
        if (it == 0) snprintf(tit, sizeof tit, "Antes de las pruebas (iteración 0)");
        else         snprintf(tit, sizeof tit, "Iteración %d", it);
        if (nk_tree_push_id(ctx, NK_TREE_NODE, tit, NK_MAXIMIZED, it)) {
            for (int i = 0; i < x->n_traza; i++)
                if (x->traza[i].iteracion == it) parrafo(ctx, x->traza[i].texto, color_regla(x->traza[i].regla));
            nk_tree_pop(ctx);
        }
    }
}

/* Por componente: los confirmados abiertos (con sus síntomas de mayor aporte); el resto plegado. */
static void explicacion_componentes(struct nk_context *ctx, const Explicacion *x, int confirmados) {
    int n = 0;
    for (int i = 0; i < x->n_comps; i++) {
        const ExplComponente *c = &x->comps[i];
        if ((c->estado == COMP_CONFIRMADO) != confirmados) continue;
        char tit[NOMBRE_LEN + 48];
        snprintf(tit, sizeof tit, "%s: %.1f %% (%s)", c->nombre, c->probabilidad * 100.0, estado_comp_texto(c->estado));
        nk_layout_row_dynamic(ctx, 24, 1);
        nk_label_colored(ctx, tit, NK_TEXT_LEFT, color_estado(c->estado));
        parrafo(ctx, c->texto, nk_rgb(200, 200, 200));
        n++;
    }
    if (n == 0) {
        nk_layout_row_dynamic(ctx, 24, 1);
        nk_label_colored(ctx, confirmados ? "Ningún componente quedó confirmado." : "No hay otros componentes.",
                         NK_TEXT_LEFT, GRIS);
    }
}

static void explicacion_items(struct nk_context *ctx, const ExplItem *it, int n, const char *vacio) {
    if (n == 0) {
        nk_layout_row_dynamic(ctx, 24, 1);
        nk_label_colored(ctx, vacio, NK_TEXT_LEFT, GRIS);
    }
    for (int i = 0; i < n; i++) parrafo(ctx, it[i].texto, nk_rgb(200, 200, 200));
}

/* F08 · paso 15: por qué el sistema llegó a su conclusión (traza R2-R10 y retrocesos). */
static void pantalla_explicacion(struct nk_context *ctx, Controlador *k) {
    if (k->hay_diag && !k->expl_al_dia) controlador_explicar(k);   /* al entrar o si cambió */
    nk_layout_row_dynamic(ctx, 34, 1);
    if (nk_button_label(ctx, "Actualizar explicación")) controlador_explicar(k);
    if (k->aviso_expl[0]) {              /* RNF-02: error o traza vacía, sin romper la pantalla */
        nk_layout_row_dynamic(ctx, 60, 1);
        nk_label_colored_wrap(ctx, k->aviso_expl, k->aviso_expl_error ? ROJO : AMBAR);
    }
    if (!k->hay_expl) return;
    const Explicacion *x = &k->expl;
    nk_layout_row_dynamic(ctx, 36, 1);
    insignia(ctx, k->diag.concluyente ? "DIAGNÓSTICO CONCLUYENTE" : "DIAGNÓSTICO NO CONCLUYENTE",
             k->diag.concluyente ? VERDE : AMBAR);
    parrafo(ctx, x->conclusion, k->diag.concluyente ? VERDE : AMBAR);
    float alto = nk_window_get_content_region(ctx).h - 30 - 34 - 36 - 70 - (k->aviso_expl[0] ? 64.0f : 0.0f);
    if (alto < 240) alto = 240;
    nk_layout_row_dynamic(ctx, alto, 1);
    if (nk_group_begin(ctx, "Razonamiento", NK_WINDOW_BORDER)) {
        if (nk_tree_push(ctx, NK_TREE_TAB, "Resumen por componente confirmado", NK_MAXIMIZED)) {
            explicacion_componentes(ctx, x, 1);
            nk_tree_pop(ctx);
        }
        if (nk_tree_push(ctx, NK_TREE_TAB, "Traza del razonamiento (por iteración)", NK_MAXIMIZED)) {
            traza_por_iteracion(ctx, x);
            nk_tree_pop(ctx);
        }
        if (nk_tree_push(ctx, NK_TREE_TAB, "Por qué se recomiendan las acciones", NK_MINIMIZED)) {
            explicacion_items(ctx, x->acciones, x->n_acciones, "No hay acciones: ningún componente confirmado.");
            nk_tree_pop(ctx);
        }
        if (nk_tree_push(ctx, NK_TREE_TAB, "Por qué se sugieren las pruebas", NK_MINIMIZED)) {
            explicacion_items(ctx, x->pruebas, x->n_pruebas, "No quedan pruebas sugeridas.");
            nk_tree_pop(ctx);
        }
        if (nk_tree_push(ctx, NK_TREE_TAB, "Otros componentes (inciertos y descartados)", NK_MINIMIZED)) {
            explicacion_componentes(ctx, x, 0);
            nk_tree_pop(ctx);
        }
        nk_group_end(ctx);
    }
}

/* ----------------------------------------------------------------------- F09 ---- */

/* Una acción: nombre, barra de Ra con su porcentaje y los confirmados que la originan. */
static void fila_accion(struct nk_context *ctx, int i, const Accion *a) {
    char t[NOMBRE_LEN + 8], pct[24];
    snprintf(t, sizeof t, "%d. %s", i + 1, a->nombre);
    nk_layout_row_dynamic(ctx, 24, 1);
    nk_label(ctx, t, NK_TEXT_LEFT);
    float r[] = { 0.70f, 0.30f };
    nk_layout_row(ctx, NK_DYNAMIC, 22, 2, r);
    barra_prob(ctx, a->relevancia, VERDE);
    snprintf(pct, sizeof pct, "Ra %.1f %%", a->relevancia * 100.0);
    nk_label(ctx, pct, NK_TEXT_RIGHT);
    for (int j = 0; j < a->n_origen; j++) {
        const OrigenAccion *o = &a->origen[j];
        nk_layout_row_dynamic(ctx, 22, 1);
        nk_labelf_colored(ctx, NK_TEXT_LEFT, GRIS, "    Origen: %s (P = %.1f %%, efectividad %.2f)",
                          o->nombre, o->probabilidad * 100.0, o->efectividad);
    }
}

/* F09 · paso 16: acciones correctivas de los componentes confirmados, de mayor a menor Ra. */
static void pantalla_acciones(struct nk_context *ctx, Controlador *k, Menu *m) {
    if (k->hay_diag && !k->acc_al_dia) controlador_acciones(k);   /* al entrar o si cambió */
    nk_layout_row_dynamic(ctx, 34, 1);
    if (nk_button_label(ctx, "Actualizar acciones")) controlador_acciones(k);
    if (k->aviso_acc[0]) {               /* RNF-02: error de Prolog, sin cerrar la aplicación */
        nk_layout_row_dynamic(ctx, 60, 1);
        nk_label_colored_wrap(ctx, k->aviso_acc, k->aviso_acc_error ? ROJO : AMBAR);
    }
    if (!k->hay_acc) return;
    const Acciones *a = &k->acc;
    if (a->n == 0) {                     /* sin confirmados: el motivo y remitir a Pruebas */
        nk_layout_row_dynamic(ctx, 36, 1);
        insignia(ctx, "SIN ACCIONES", AMBAR);
        nk_layout_row_dynamic(ctx, 66, 1);
        nk_label_colored_wrap(ctx, a->mensaje, AMBAR);
        if (!k->diag.concluyente && k->diag.prueba_sugerida[0]) {
            nk_layout_row_dynamic(ctx, 36, 1);
            if (nk_button_label(ctx, "Ir a Pruebas")) menu_ir(m, PANT_PRUEBAS);
        }
        return;
    }
    nk_layout_row_dynamic(ctx, 26, 1);
    nk_label_colored(ctx, a->mensaje, NK_TEXT_LEFT, nk_rgb(180, 180, 180));
    float alto = nk_window_get_content_region(ctx).h - 30 - 34 - 26 - 16 - (k->aviso_acc[0] ? 64.0f : 0.0f);
    if (alto < 220) alto = 220;
    nk_layout_row_dynamic(ctx, alto, 1);
    if (nk_group_begin(ctx, "Acciones correctivas (por relevancia Ra)", NK_WINDOW_BORDER | NK_WINDOW_TITLE)) {
        for (int i = 0; i < a->n; i++) fila_accion(ctx, i, &a->items[i]);
        nk_layout_row_dynamic(ctx, 44, 1);
        nk_label_colored_wrap(ctx, "Son recomendaciones del sistema experto, no una certeza: confírmelas con un técnico.", GRIS);
        nk_group_end(ctx);
    }
}

/* F11 · RB2: «Marcaste X e Y, que son incompatibles. ¿Cuál es correcta?» */
static void dialogo_contradiccion(struct nk_context *ctx, Controlador *k, int w, int h) {
    struct nk_rect r = nk_rect(w / 2.0f - 380, h / 2.0f - 150, 760, 300);
    if (nk_popup_begin(ctx, NK_POPUP_STATIC, "Contradicción detectada",
            NK_WINDOW_TITLE | NK_WINDOW_CLOSABLE | NK_WINDOW_BORDER | NK_WINDOW_NO_SCROLLBAR, r)) {
        char b[2 * NOMBRE_LEN + 32];
        int cerrar = 0;
        nk_layout_row_dynamic(ctx, 70, 1);
        nk_label_wrap(ctx, k->contra.mensaje);
        nk_layout_row_dynamic(ctx, 36, 1);
        snprintf(b, sizeof b, "Es correcta: %s", k->contra.nombre_a);
        if (nk_button_label(ctx, b)) { controlador_resolver(k, k->contra.id_a); cerrar = 1; }
        snprintf(b, sizeof b, "Es correcta: %s", k->contra.nombre_b);
        if (!cerrar && nk_button_label(ctx, b)) { controlador_resolver(k, k->contra.id_b); cerrar = 1; }
        if (!cerrar && nk_button_label(ctx, "Cancelar (conservar la selección anterior)")) {
            controlador_cancelar_contradiccion(k);
            cerrar = 1;
        }
        if (cerrar) nk_popup_close(ctx);
        nk_popup_end(ctx);
    } else {
        controlador_cancelar_contradiccion(k);   /* cerrarlo con la X equivale a cancelar */
    }
}

/* Contenido de cada pantalla; Reporte (F13) sigue pendiente. */
static void pantalla(struct nk_context *ctx, Controlador *k, Menu *m) {
    nk_layout_row_dynamic(ctx, 30, 1);
    nk_label(ctx, menu_titulo(m->actual), NK_TEXT_LEFT);
    if (m->actual == PANT_VEHICULO) {
        pantalla_vehiculo(ctx, k, m);
        return;
    }
    if (m->actual == PANT_SINTOMAS) { pantalla_sintomas(ctx, k, m); return; }
    if (m->actual == PANT_DIAGNOSTICO) { pantalla_diagnostico(ctx, k, m); return; }
    if (m->actual == PANT_PRUEBAS) { pantalla_pruebas(ctx, k); return; }
    if (m->actual == PANT_ACCIONES) { pantalla_acciones(ctx, k, m); return; }
    if (m->actual == PANT_EXPLICACION) { pantalla_explicacion(ctx, k); return; }
    nk_label_wrap(ctx, "Pantalla pendiente de implementar.");
}

/* Devuelve 1 si el usuario pidió salir. */
static int interfaz_marco(struct nk_context *ctx, Controlador *k, Menu *m, int w, int h) {
    int salir = 0;
    if (!nk_begin(ctx, "Sistema experto", nk_rect(0, 0, (float)w, (float)h), NK_WINDOW_NO_SCROLLBAR)) {
        nk_end(ctx);
        return 0;
    }
    m->sintomas = seleccion_cuenta_calculo(&k->sel) > 0;   /* F05: habilita Diagnóstico */
    m->diagnostico = k->hay_diag;                          /* F06: habilita Pruebas, Explicación... */
    if (!menu_habilitada(m, m->actual)) m->actual = PANT_SINTOMAS;
    int caido = k->hay_error || !conexion_viva(&k->con);
    int bloqueado = caido || k->contra.pendiente; /* con un diálogo abierto, el resto no responde */

    nk_layout_row_dynamic(ctx, 28, 1);
    nk_labelf_colored(ctx, NK_TEXT_RIGHT, caido ? nk_rgb(230, 80, 80) : nk_rgb(90, 200, 120),
                      "Prolog: %s", caido ? "sin conexión" : "conectado");

    float alto = nk_window_get_content_region(ctx).h - 28 - 24;
    nk_layout_row_template_begin(ctx, alto);
    nk_layout_row_template_push_static(ctx, 190);
    nk_layout_row_template_push_variable(ctx, 200);
    nk_layout_row_template_end(ctx);

    if (nk_group_begin(ctx, "nav", NK_WINDOW_BORDER)) {
        nk_layout_row_dynamic(ctx, 38, 1);
        for (Pantalla p = 0; p < PANT_N; p++) {
            int on = menu_habilitada(m, p) && !bloqueado;
            if (!on) nk_widget_disable_begin(ctx);
            if (nk_button_label(ctx, menu_titulo(p)) && on) {
                if (p == PANT_SALIR) salir = 1; else menu_ir(m, p);
            }
            if (!on) nk_widget_disable_end(ctx);
        }
        nk_group_end(ctx);
    }
    if (nk_group_begin(ctx, "contenido", NK_WINDOW_BORDER)) {
        if (bloqueado) nk_widget_disable_begin(ctx);
        pantalla(ctx, k, m);
        if (bloqueado) nk_widget_disable_end(ctx);
        nk_group_end(ctx);
    }

    if (k->contra.pendiente && !caido) dialogo_contradiccion(ctx, k, w, h);   /* F11 */
    if (caido) { /* RNF-02: Prolog no responde */
        int n = 1;
        for (const char *c = k->mensaje; *c; c++) n += *c == '\n';
        float alto = 110 + 44.0f * n;
        struct nk_rect r = nk_rect(w / 2.0f - 320, (h - alto) / 2, 640, alto);
        if (nk_popup_begin(ctx, NK_POPUP_STATIC, "Error de conexión con Prolog",
                           NK_WINDOW_TITLE | NK_WINDOW_NO_SCROLLBAR, r)) {
            lineas(ctx, k->mensaje, 44);
            nk_layout_row_dynamic(ctx, 38, 2);
            if (nk_button_label(ctx, "Reintentar")) {
                controlador_cerrar(k);
                controlador_probar_conexion(k);
            }
            if (nk_button_label(ctx, "Salir")) salir = 1;
            nk_popup_end(ctx);
        }
    }
    nk_end(ctx);
    return salir;
}

/* Guarda lo dibujado en un .bmp (evidencia de pruebas, F12). */
static int guardar_bmp(SDL_Renderer *ren, const char *ruta) {
    int w, h;
    SDL_GetRendererOutputSize(ren, &w, &h);
    SDL_Surface *s = SDL_CreateRGBSurfaceWithFormat(0, w, h, 32, SDL_PIXELFORMAT_ARGB8888);
    if (!s) return -1;
    int rc = SDL_RenderReadPixels(ren, NULL, SDL_PIXELFORMAT_ARGB8888, s->pixels, s->pitch);
    if (rc == 0) rc = SDL_SaveBMP(s, ruta);
    SDL_FreeSurface(s);
    return rc;
}

int interfaz_ejecutar(Controlador *k, const char *captura_bmp, int pantalla_inicial) {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "Error: no hay display disponible (%s)\n", SDL_GetError());
        return 1;
    }
    SDL_Window *win = SDL_CreateWindow("Sistema experto de diagnóstico automotriz",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1120, 700,
        SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    SDL_Renderer *ren = win ? SDL_CreateRenderer(win, -1, captura_bmp ? SDL_RENDERER_SOFTWARE :
        (SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)) : NULL;
    if (win && !ren) ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_SOFTWARE);
    if (!ren) {
        fprintf(stderr, "Error: no se pudo crear la ventana (%s)\n", SDL_GetError());
        if (win) SDL_DestroyWindow(win);
        SDL_Quit();
        return 1;
    }

    struct nk_context *ctx = nk_sdl_init(win, ren);
    static const nk_rune rango[] = { 0x0020, 0x00FF, 0 }; /* Latin-1: tildes y ñ */
    struct nk_font_atlas *atlas;
    struct nk_font_config cfg = nk_font_config(0);
    cfg.range = rango;
    nk_sdl_font_stash_begin(&atlas);
    struct nk_font *fuente = nk_font_atlas_add_from_file(atlas, FUENTE_TTF, 18, &cfg);
    nk_sdl_font_stash_end();
    if (fuente) nk_style_set_font(ctx, &fuente->handle);

    Menu m;
    menu_iniciar(&m);
    if (pantalla_inicial >= 0 && pantalla_inicial < PANT_N) m.actual = (Pantalla)pantalla_inicial;
    if (!k->hay_error) controlador_probar_conexion(k);   /* un error previo se muestra, no se oculta */
    /* shortcut: el ping es síncrono y bloquea hasta CONEXION_TIMEOUT_MS si swipl se cuelga;
     * pasar a un hilo si molesta. */
    Uint32 ultimo_ping = SDL_GetTicks();

    int rc = 0;
    for (int salir = 0, cuadros = 0; !salir; cuadros++) {
        SDL_Event e;
        nk_input_begin(ctx);
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) salir = 1;
            nk_sdl_handle_event(&e);
        }
        nk_sdl_handle_grab();
        nk_input_end(ctx);

        if (!captura_bmp && !k->hay_error && SDL_GetTicks() - ultimo_ping >= PING_CADA_MS) {
            controlador_probar_conexion(k);
            ultimo_ping = SDL_GetTicks();
        }

        int w, h;
        SDL_GetWindowSize(win, &w, &h);
        if (interfaz_marco(ctx, k, &m, w, h)) salir = 1;

        SDL_SetRenderDrawColor(ren, 30, 30, 30, 255);
        SDL_RenderClear(ren);
        nk_sdl_render(NK_ANTI_ALIASING_ON);
        if (captura_bmp && cuadros >= 8) {
            if (guardar_bmp(ren, captura_bmp) != 0) {
                fprintf(stderr, "Error: no se pudo guardar la captura (%s)\n", SDL_GetError());
                rc = 1;
            }
            salir = 1;
        }
        SDL_RenderPresent(ren);
    }

    nk_sdl_shutdown();
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
    return rc;
}
