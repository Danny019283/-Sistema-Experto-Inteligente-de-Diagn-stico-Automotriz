#include "interfaz.h"

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

int interfaz_ejecutar(Controlador *k) {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "Error: no hay display disponible (%s)\n", SDL_GetError());
        return 1;
    }
    SDL_Window *win = SDL_CreateWindow("Sistema experto de diagnóstico automotriz",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 720, 420, SDL_WINDOW_SHOWN);
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

    for (int salir = 0; !salir;) {
        SDL_Event e;
        nk_input_begin(ctx);
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) salir = 1;
            nk_sdl_handle_event(&e);
        }
        nk_sdl_handle_grab();
        nk_input_end(ctx);

        int w, h;
        SDL_GetWindowSize(win, &w, &h);
        if (nk_begin(ctx, "Conexión", nk_rect(0, 0, (float)w, (float)h), NK_WINDOW_BORDER)) {
            nk_layout_row_dynamic(ctx, 30, 1);
            nk_label(ctx, "Prueba de conexión C <-> SWI-Prolog", NK_TEXT_LEFT);
            if (nk_button_label(ctx, "Probar conexión")) controlador_probar_conexion(k);
            if (k->hay_error && nk_button_label(ctx, "Reintentar")) {
                controlador_cerrar(k);
                controlador_probar_conexion(k);
            }
            nk_layout_row_dynamic(ctx, 120, 1);
            nk_label_wrap(ctx, k->mensaje);
        }
        nk_end(ctx);

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
