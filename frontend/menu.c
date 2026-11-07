#include "menu.h"

void menu_iniciar(Menu *m) { *m = (Menu){ .actual = PANT_VEHICULO }; }

const char *menu_titulo(Pantalla p) {
    static const char *t[PANT_N] = { "Vehículo", "Síntomas", "Diagnóstico", "Pruebas",
        "Explicación", "Acciones", "Reporte", "Salir" };
    return p >= 0 && p < PANT_N ? t[p] : "";
}

int menu_habilitada(const Menu *m, Pantalla p) {
    switch (p) {
    case PANT_VEHICULO: case PANT_SINTOMAS: case PANT_SALIR: return 1;
    case PANT_DIAGNOSTICO: return m->sintomas;
    case PANT_PRUEBAS: case PANT_EXPLICACION: case PANT_ACCIONES: case PANT_REPORTE:
        return m->diagnostico;
    default: return 0;
    }
}

int menu_ir(Menu *m, Pantalla p) {
    if (p == PANT_SALIR || p < 0 || p >= PANT_N || !menu_habilitada(m, p)) return 0;
    m->actual = p;
    return 1;
}
