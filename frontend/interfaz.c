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

/* Contenido provisional de las pantallas pendientes (F05-F10). Los botones "Simular"
 * solo encienden banderas para recorrer el flujo. */
static void pantalla(struct nk_context *ctx, Controlador *k, Menu *m) {
    nk_layout_row_dynamic(ctx, 30, 1);
    nk_label(ctx, menu_titulo(m->actual), NK_TEXT_LEFT);
    if (m->actual == PANT_VEHICULO) {
        pantalla_vehiculo(ctx, k, m);
        return;
    }
    if (k->registrado && m->actual == PANT_DIAGNOSTICO) { /* resumen del vehículo (F04) */
        char r[512];
        vehiculo_resumen(&k->guardado, r, sizeof r);
        nk_label_wrap(ctx, r);
    }
    nk_label_wrap(ctx, "Pantalla pendiente de implementar.");
    nk_layout_row_dynamic(ctx, 34, 1);
    switch (m->actual) {
    case PANT_SINTOMAS:
        if (!m->sintomas && nk_button_label(ctx, "Simular síntomas seleccionados")) m->sintomas = 1;
        break;
    case PANT_DIAGNOSTICO:
        if (!m->diagnostico && nk_button_label(ctx, "Simular diagnóstico calculado")) m->diagnostico = 1;
        break;
    default: break;
    }
}

/* Devuelve 1 si el usuario pidió salir. */
static int interfaz_marco(struct nk_context *ctx, Controlador *k, Menu *m, int w, int h) {
    int salir = 0;
    if (!nk_begin(ctx, "Sistema experto", nk_rect(0, 0, (float)w, (float)h), NK_WINDOW_NO_SCROLLBAR)) {
        nk_end(ctx);
        return 0;
    }
    int caido = k->hay_error || !conexion_viva(&k->con);
    int bloqueado = caido; /* con el diálogo abierto, el resto no responde */

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

int interfaz_ejecutar(Controlador *k) {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "Error: no hay display disponible (%s)\n", SDL_GetError());
        return 1;
    }
    SDL_Window *win = SDL_CreateWindow("Sistema experto de diagnóstico automotriz",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 960, 600, SDL_WINDOW_SHOWN);
    SDL_Renderer *ren = win ? SDL_CreateRenderer(win, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC) : NULL;
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
    controlador_probar_conexion(k);
    /* shortcut: el ping es síncrono y bloquea hasta CONEXION_TIMEOUT_MS si swipl se cuelga;
     * pasar a un hilo si molesta. */
    Uint32 ultimo_ping = SDL_GetTicks();

    for (int salir = 0; !salir;) {
        SDL_Event e;
        nk_input_begin(ctx);
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) salir = 1;
            nk_sdl_handle_event(&e);
        }
        nk_sdl_handle_grab();
        nk_input_end(ctx);

        if (!k->hay_error && SDL_GetTicks() - ultimo_ping >= PING_CADA_MS) {
            controlador_probar_conexion(k);
            ultimo_ping = SDL_GetTicks();
        }

        int w, h;
        SDL_GetWindowSize(win, &w, &h);
        if (interfaz_marco(ctx, k, &m, w, h)) salir = 1;

        SDL_SetRenderDrawColor(ren, 30, 30, 30, 255);
        SDL_RenderClear(ren);
        nk_sdl_render(NK_ANTI_ALIASING_ON);
        SDL_RenderPresent(ren);
    }

    nk_sdl_shutdown();
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
    return 0;
}
