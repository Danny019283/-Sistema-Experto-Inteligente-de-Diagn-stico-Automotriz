#ifndef INTERFAZ_H
#define INTERFAZ_H

#include "controlador.h"
#include "menu.h"

/* Abre la ventana y corre el bucle hasta cerrarla. 0 = ok, !=0 si no hay display.
 * pantalla_inicial: una Pantalla, o -1 para la de siempre (Vehículo). Con captura_bmp != NULL
 * dibuja unos cuadros, guarda la pantalla en ese .bmp y sale (evidencia de pruebas, F12). */
int interfaz_ejecutar(Controlador *k, const char *captura_bmp, int pantalla_inicial);

#endif
