#ifndef VALIDACIONES_H
#define VALIDACIONES_H

/* Validadores de entrada compartidos por todas las pantallas (RNF-01). */

/* 1 si txt tiene algún carácter que no sea espacio. */
int validar_no_vacio(const char *txt);

/* 1 si txt es un entero decimal completo (sin basura) dentro de [min, max];
 * en ese caso lo deja en *out (out puede ser NULL). */
int validar_entero(const char *txt, long min, long max, long *out);

#endif
