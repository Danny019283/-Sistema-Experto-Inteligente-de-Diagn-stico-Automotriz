#include <stdio.h>
#include <unistd.h>

#include "controlador.h"
#include "interfaz.h"

#define BACKEND_DIR "backend"

int main(void) {
    static const char *archivos[] = { "hechos.pl", "reglas.pl", "inferencia.pl",
        "consultas.pl", "explicaciones.pl", "servidor_json.pl" };
    char ruta[256];

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
    controlador_iniciar(&k, BACKEND_DIR "/servidor_json.pl");
    int rc = interfaz_ejecutar(&k);
    controlador_cerrar(&k);
    return rc;
}
