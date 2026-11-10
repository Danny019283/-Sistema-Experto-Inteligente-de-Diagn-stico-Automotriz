#ifndef MENU_H
#define MENU_H

/* Flujo de pantallas. Solo banderas de estado de la interfaz: el razonamiento
 * del dominio vive en Prolog. */
typedef enum {
    PANT_VEHICULO, PANT_SINTOMAS, PANT_DIAGNOSTICO, PANT_PRUEBAS,
    PANT_EXPLICACION, PANT_ACCIONES, PANT_REPORTE, PANT_HISTORIAL, PANT_SALIR, PANT_N
} Pantalla;

typedef struct {
    int vehiculo;     /* hay vehículo registrado (F04) */
    int sintomas;     /* hay síntomas seleccionados (F05) */
    int diagnostico;  /* hay un diagnóstico calculado (F06) */
    Pantalla actual;
} Menu;

void menu_iniciar(Menu *m);
const char *menu_titulo(Pantalla p);
/* Vehículo, Síntomas, Historial (F10) y Salir siempre; Diagnóstico con síntomas; el resto con
 * diagnóstico. */
int menu_habilitada(const Menu *m, Pantalla p);
/* Cambia de pantalla si está habilitada (no vale para PANT_SALIR); 1 si navegó. */
int menu_ir(Menu *m, Pantalla p);

#endif
