#ifndef CONTROLADOR_H
#define CONTROLADOR_H

#include "acciones.h"
#include "conexion.h"
#include "diagnostico.h"
#include "explicacion.h"
#include "historial.h"
#include "pruebas_adicionales.h"
#include "reporte.h"
#include "sintomas.h"
#include "vehiculo.h"

#define HALL_MAX 32

/* F11 · diálogo RB2: par incompatible que detectó R2b en Prolog. */
typedef struct {
    int pendiente;
    char id_a[ID_LEN], nombre_a[NOMBRE_LEN]; /* el síntoma previo */
    char id_b[ID_LEN], nombre_b[NOMBRE_LEN]; /* el recién marcado */
    char mensaje[256];
} Contradiccion;

/* Resultado de una prueba (hall_<prueba> = normal | leve | severo) que se envía a diagnosticar. */
typedef struct { char id[ID_LEN]; char estado[16]; } HallazgoSel;

typedef struct {
    Conexion con;
    const char *script;
    char mensaje[4096]; /* último resultado a mostrar en pantalla */
    int hay_error;
    /* Vehículo (F04). `form` es lo que se edita; `guardado` lo último que Prolog aceptó. */
    FormVehiculo form, guardado;
    int registrado;
    char errores[VF_N][VF_ERR]; /* mensaje junto a cada campo ("" = sin error) */
    char error_form[4096];      /* error de Prolog que no es de un campo concreto */

    /* F05 · síntomas. `sel` es siempre lo último que Prolog confirmó. */
    Catalogo cat;
    int catalogo_ok;            /* catálogo cargado y no vacío */
    Seleccion sel;
    char aviso[4096];           /* error de Prolog al operar con síntomas ("" = ninguno) */
    /* F06 · diagnóstico */
    Diagnostico diag;
    int hay_diag;
    char aviso_diag[4096];      /* sin hipótesis / error de Prolog / respuesta inválida */
    int aviso_diag_error;
    HallazgoSel hall[HALL_MAX]; /* resultados de pruebas ya conocidos (los llena F07) */
    int n_hall;
    /* F07 · pruebas adicionales. `rec` es lo último que devolvió recomendar_pruebas. */
    Recomendacion rec;
    int hay_rec;
    int rec_al_dia;             /* 0: el diagnóstico cambió y hay que volver a pedir las pruebas */
    char aviso_pruebas[4096];   /* resultado registrado / error de Prolog ("" = ninguno) */
    int aviso_pruebas_error;
    /* F09 · acciones correctivas del diagnóstico actual (las calcula Prolog, R9). */
    Acciones acc;
    int hay_acc;
    int acc_al_dia;             /* 0: el diagnóstico cambió y hay que volver a pedirlas */
    char aviso_acc[4096];       /* error de Prolog / respuesta inválida ("" = ninguno) */
    int aviso_acc_error;
    /* F08 · explicación del diagnóstico actual (traza y porqués, generados en Prolog, R10). */
    Explicacion expl;
    int hay_expl;
    int expl_al_dia;            /* 0: el diagnóstico cambió y hay que volver a pedirla */
    char aviso_expl[4096];      /* error de Prolog / respuesta inválida ("" = ninguno) */
    int aviso_expl_error;
    /* F10 · historial. `guardado_id` es el número con que se guardó el diagnóstico actual (0 = no). */
    int guardado_id;
    char aviso_guardar[4096];
    int aviso_guardar_error;
    Historial hist;             /* lo último que devolvió listar_diagnosticos */
    int hay_hist;
    int hist_al_dia;            /* 0: se guardó algo o se reabrió swipl; hay que volver a listar */
    DiagGuardado abierto;       /* el diagnóstico del historial que se está viendo */
    int hay_abierto;
    char aviso_hist[4096];      /* registros dañados, error de Prolog ("" = ninguno) */
    int aviso_hist_error;
    /* F13 · reporte textual del diagnóstico guardado `rep.id` (lo arma Prolog). */
    Reporte rep;
    int hay_rep;
    int rep_pedido;             /* id del último reporte pedido (evita repetir la petición al dibujar) */
    char aviso_rep[4096];       /* exportado en ..., o el error ("" = ninguno) */
    int aviso_rep_error;
    /* F11 · RB2 */
    Contradiccion contra;
} Controlador;

void controlador_iniciar(Controlador *k, const char *script);
/* Deja en k->mensaje el texto a mostrar para una respuesta de Prolog; devuelve 1 si estado=error.
 * Los errores muestran codigo, mensaje y los primeros `problemas` (kb_invalida) uno por línea. */
int controlador_interpretar(Controlador *k, const cJSON *resp);
void controlador_probar_conexion(Controlador *k); /* ping; reabre swipl si estaba caído */
/* Valida k->form en C (RNF-01) y, si pasa, envía registrar_vehiculo. Reemplaza el registro
 * anterior y deja `form` y `guardado` con lo que devolvió Prolog. Devuelve 1 si quedó guardado.
 * Los errores (de campo o de Prolog) quedan en k->errores / k->error_form SIN tocar k->form
 * (RNF-02); un fallo de transporte además marca k->hay_error. */
int controlador_registrar_vehiculo(Controlador *k);
void controlador_cerrar(Controlador *k);

/* ---- F05 · síntomas (el catálogo y la validación de estados vienen de Prolog) ---- */
void controlador_cargar_catalogo(Controlador *k);
void controlador_marcar(Controlador *k, const char *id, EstadoSintoma estado);
void controlador_quitar(Controlador *k, const char *id);
void controlador_limpiar(Controlador *k);
/* Hay catálogo, no hay contradicción pendiente y al menos un síntoma presente o ausente. */
int controlador_puede_diagnosticar(const Controlador *k);

/* ---- F06 · diagnóstico ---- */
void controlador_diagnosticar(Controlador *k);
/* Guarda el resultado de una prueba para el próximo diagnóstico; 1 si es válido (hall_*, normal|leve|severo). */
int controlador_hallazgo(Controlador *k, const char *id, const char *estado);

/* ---- F07 · pruebas adicionales (qué prueba recomendar lo decide Prolog, R7) ---- */
/* Pide recomendar_pruebas para el diagnóstico actual; sin diagnóstico no llama a Prolog. */
void controlador_recomendar_pruebas(Controlador *k);
/* Registra el resultado de la prueba pendiente (RNF-01: se valida en C antes de enviar).
 * Si Prolog lo acepta, k->diag pasa a ser el diagnóstico nuevo, el hallazgo queda en k->hall
 * (Diagnosticar lo vuelve a enviar) y se refrescan las recomendaciones. Con error no cambia
 * nada y el motivo queda en k->aviso_pruebas. Devuelve 1 si quedó registrado. */
int controlador_registrar_resultado(Controlador *k, const char *prueba, const char *resultado);

/* ---- F10 · historial de diagnósticos (datos/registros.txt, en Prolog) ---- */
/* Guarda el diagnóstico actual con el vehículo registrado. RNF-01: sin diagnóstico o sin vehículo
 * no se llama a Prolog. Los errores (ya guardado, escritura) quedan en k->aviso_guardar. */
int controlador_guardar(Controlador *k);
/* Lista el historial. Con registros_corrupto muestra los válidos y avisa de las líneas dañadas. */
void controlador_listar(Controlador *k);
/* Abre un diagnóstico guardado en k->abierto (no reemplaza al diagnóstico actual). */
int controlador_abrir(Controlador *k, int id);

/* ---- F13 · reporte textual ---- */
/* Pide el reporte del diagnóstico guardado `id` (RNF-01: id > 0; sin guardar no hay reporte). */
int controlador_reporte(Controlador *k, int id);
/* Escribe k->rep en datos/reportes/ (o SE_REPORTES) sin sobrescribir; el resultado queda en
 * k->aviso_rep (la ruta, o el motivo del error de escritura). 1 si se exportó. */
int controlador_exportar(Controlador *k);

/* ---- F08 · explicación del razonamiento ---- */
/* RNF-01: solo con un diagnóstico calculado se pide `explicar`; sin él, "Primero genere un
 * diagnóstico". Un error o una traza vacía quedan en k->aviso_expl sin dibujar nada. */
void controlador_explicar(Controlador *k);

/* ---- F09 · acciones correctivas ---- */
/* Pide acciones_correctivas para el diagnóstico actual; sin diagnóstico no llama a Prolog. Con
 * error o respuesta inválida no se muestra nada y el motivo queda en k->aviso_acc. */
void controlador_acciones(Controlador *k);

/* ---- F11 · RB2: contradicción entre síntomas ---- */
void controlador_resolver(Controlador *k, const char *id_elegido);
void controlador_cancelar_contradiccion(Controlador *k);

/* Acciones por texto (demos y evidencia de pruebas): "marcar:id=estado", "quitar:id", "limpiar",
 * "catalogo", "diagnosticar", "hallazgo:hall_x=estado", "resolver:id", "cancelar", "matar",
 * "recomendar", "registrar:prueba=resultado" (F07), "acciones" (F09), "explicar" (F08),
 * "guardar", "listar", "abrir:id" (F10), "vehiculo:marca,modelo,anio,cilindrada,combustible,km",
 * "reporte:id", "exportar" (F13).
 * 0 ok, -1 si es desconocida o está mal formada. */
int controlador_accion(Controlador *k, const char *accion);

#endif
