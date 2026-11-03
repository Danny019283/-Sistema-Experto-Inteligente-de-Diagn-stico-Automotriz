#ifndef INTERFAZ_H
#define INTERFAZ_H

#include "controlador.h"

/* Abre la ventana y corre el bucle hasta cerrarla. 0 = ok, !=0 si no hay display. */
int interfaz_ejecutar(Controlador *k);

#endif
