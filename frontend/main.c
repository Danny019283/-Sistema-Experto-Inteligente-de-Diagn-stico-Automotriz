#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "controlador.h"
#include "interfaz.h"

#define BACKEND_DIR "backend"
#define MAX_ACCIONES 64

static void uso(const char *prog) {
    fprintf(stderr,
        "Uso: %s [--backend script.pl] [--pantalla vehiculo|sintomas|diagnostico]\n"
        "          [--accion A]... [--captura salida.bmp]\n"
        "  --backend   servidor Prolog a lanzar (por defecto " BACKEND_DIR "/servidor_json.pl)\n"
        "  --accion    acción previa a dibujar (repetible): marcar:id=estado, quitar:id, limpiar,\n"
        "              diagnosticar, hallazgo:hall_x=estado, resolver:id, cancelar, matar, catalogo\n"
        "  --captura   guarda la pantalla en un .bmp y termina (evidencia de pruebas)\n", prog);
}

static int pantalla_desde(const char *n) {
    if (!strcmp(n, "vehiculo")) return PANT_VEHICULO;
    if (!strcmp(n, "sintomas")) return PANT_SINTOMAS;
    if (!strcmp(n, "diagnostico")) return PANT_DIAGNOSTICO;
    return -2;
}

int main(int argc, char **argv) {
    static const char *archivos[] = { "hechos.pl", "reglas.pl", "inferencia.pl", "consultas.pl",
        "explicaciones.pl", "servidor_json.pl", "sistemas.pl", "memoria_x.pl", "ops_sintomas.pl",
        "retroceso.pl" };
    const char *script = BACKEND_DIR "/servidor_json.pl", *captura = NULL;
    const char *acciones[MAX_ACCIONES];
    int nacc = 0, pantalla = -1;
    char ruta[256];

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--backend") && i + 1 < argc) script = argv[++i];
        else if (!strcmp(argv[i], "--captura") && i + 1 < argc) captura = argv[++i];
        else if (!strcmp(argv[i], "--pantalla") && i + 1 < argc) {
            if ((pantalla = pantalla_desde(argv[++i])) == -2) { uso(argv[0]); return 2; }
        } else if (!strcmp(argv[i], "--accion") && i + 1 < argc && nacc < MAX_ACCIONES)
            acciones[nacc++] = argv[++i];
        else { uso(argv[0]); return 2; }
    }

    if (!conexion_swipl_disponible()) {
        fprintf(stderr, "Error: no se encontró `swipl` (SWI-Prolog) en el PATH.\n");
        return 1;
    }
    for (size_t i = 0; i < sizeof archivos / sizeof *archivos; i++) {
        snprintf(ruta, sizeof ruta, BACKEND_DIR "/%s", archivos[i]);
        if (access(ruta, R_OK) != 0) {
            fprintf(stderr, "Error: falta %s (ejecuta desde la raíz del proyecto).\n", ruta);
            return 1;
        }
    }

    Controlador k;
    controlador_iniciar(&k, script);
    if (nacc > 0) {                       /* modo demo/evidencia: conecta y carga el catálogo primero */
        controlador_probar_conexion(&k);
        for (int i = 0; i < nacc; i++)
            if (controlador_accion(&k, acciones[i]) < 0) {
                fprintf(stderr, "Error: acción inválida '%s'\n", acciones[i]);
                controlador_cerrar(&k);
                return 2;
            }
    }
    int rc = interfaz_ejecutar(&k, captura, pantalla);
    controlador_cerrar(&k);
    return rc;
}
