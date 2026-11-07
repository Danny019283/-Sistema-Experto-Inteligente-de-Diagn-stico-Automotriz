#ifndef VEHICULO_H
#define VEHICULO_H

#include "cJSON.h"

/* Formulario del vehículo (F04): estado de edición, validación (RNF-01) y JSON.
 * Los límites coinciden con backend/vehiculo.pl (Prolog vuelve a validar). */
enum { VF_MARCA, VF_MODELO, VF_ANIO, VF_MOTOR, VF_COMBUSTIBLE, VF_KM, VF_N };
#define VF_TEXTO 128        /* buffer de los textos libres (UTF-8) */
#define VF_ERR 128          /* mensaje de error por campo */
#define VF_MAX_CARS 40
#define VF_ANIO_MIN 1950
#define VF_KM_MAX 3000000L
#define VF_N_COMBUSTIBLES 5

extern const char *const VF_COMBUSTIBLE_ID[VF_N_COMBUSTIBLES];        /* los ids que acepta Prolog */
extern const char *const VF_COMBUSTIBLE_ETIQUETA[VF_N_COMBUSTIBLES];  /* texto para el usuario */
extern const char *const VF_CAMPO[VF_N];                              /* nombre del campo en el JSON */

typedef struct {
    char marca[VF_TEXTO], modelo[VF_TEXTO], motor[VF_TEXTO];
    char anio[16], km[16];
    int combustible;  /* índice en VF_COMBUSTIBLE_*; -1 = sin elegir */
} FormVehiculo;

void vehiculo_form_iniciar(FormVehiculo *f);
/* Rellena err[campo] con el motivo de cada campo inválido ("" si es válido); devuelve cuántos. */
int vehiculo_validar(const FormVehiculo *f, char err[VF_N][VF_ERR]);
/* args de registrar_vehiculo; el llamador lo libera con cJSON_Delete (o lo cede a conexion_peticion). */
cJSON *vehiculo_a_json(const FormVehiculo *f);
/* Reparte los `problemas` ("campo: motivo") de una respuesta entrada_invalida en err[campo];
 * devuelve cuántos campos recibieron mensaje. */
int vehiculo_errores_prolog(const cJSON *resp, char err[VF_N][VF_ERR]);
/* Carga el vehículo de `resultados[0]` de registrar_vehiculo/consultar_vehiculo; 1 si es válido. */
int vehiculo_desde_json(FormVehiculo *f, const cJSON *v);
/* "Toyota Corolla 2015 · 1.8 L · Gasolina · 120000 km" */
void vehiculo_resumen(const FormVehiculo *f, char *out, size_t n);

#endif
