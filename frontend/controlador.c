#include "controlador.h"

#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void controlador_iniciar(Controlador *k, const char *script) {
    memset(k, 0, sizeof *k);
    k->script = script;
    vehiculo_form_iniciar(&k->form);
    snprintf(k->mensaje, sizeof k->mensaje, "Sin probar.");
}

#define MAX_PROBLEMAS 5

/* Añade texto a k->mensaje sin desbordarlo. */
static void anadir(Controlador *k, const char *fmt, const char *a) {
    size_t l = strlen(k->mensaje);
    snprintf(k->mensaje + l, sizeof k->mensaje - l, fmt, a);
}

int controlador_interpretar(Controlador *k, const cJSON *resp) {
    const cJSON *estado = cJSON_GetObjectItem(resp, "estado");
    k->hay_error = cJSON_IsString(estado) && strcmp(estado->valuestring, "error") == 0;
    if (!k->hay_error) {
        char *txt = cJSON_PrintUnformatted(resp);
        snprintf(k->mensaje, sizeof k->mensaje, "Respuesta de Prolog: %s", txt ? txt : "");
        free(txt);
        return 0;
    }
    const cJSON *err = cJSON_GetObjectItem(resp, "error");
    const cJSON *cod = cJSON_GetObjectItem(err, "codigo");
    const cJSON *msg = cJSON_GetObjectItem(err, "mensaje");
    snprintf(k->mensaje, sizeof k->mensaje, "Error de Prolog (%s): %s",
             cJSON_IsString(cod) ? cod->valuestring : "desconocido",
             cJSON_IsString(msg) ? msg->valuestring : "sin detalle");
    const cJSON *ps = cJSON_GetObjectItem(err, "problemas");
    int n = cJSON_IsArray(ps) ? cJSON_GetArraySize(ps) : 0;
    for (int i = 0; i < n && i < MAX_PROBLEMAS; i++) {
        const cJSON *p = cJSON_GetArrayItem(ps, i);
        if (cJSON_IsString(p)) anadir(k, "\n- %s", p->valuestring);
    }
    if (n > MAX_PROBLEMAS) {
        char resto[32];
        snprintf(resto, sizeof resto, "%d", n - MAX_PROBLEMAS);
        anadir(k, "\n… y %s más", resto);
    }
    return 1;
}

static int enviar_vehiculo(Controlador *k, const FormVehiculo *f, FormVehiculo *recibido) {
    char err[256] = "";
    k->error_form[0] = '\0';
    memset(k->errores, 0, sizeof k->errores);
    cJSON *r = conexion_peticion(&k->con, "registrar_vehiculo", vehiculo_a_json(f), err, sizeof err);
    if (!r) {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "Error de conexión: %s", err);
        return 0;
    }
    int ok = 0;
    if (controlador_interpretar(k, r)) {
        k->hay_error = 0; /* Prolog respondió: la conexión está bien, el error es de los datos */
        if (!vehiculo_errores_prolog(r, k->errores)) snprintf(k->error_form, sizeof k->error_form, "%s", k->mensaje);
    } else {
        ok = vehiculo_desde_json(recibido, cJSON_GetArrayItem(cJSON_GetObjectItem(r, "resultados"), 0));
        if (!ok) snprintf(k->error_form, sizeof k->error_form, "Respuesta inesperada de Prolog al registrar el vehículo");
    }
    cJSON_Delete(r);
    return ok;
}

int controlador_registrar_vehiculo(Controlador *k) {
    if (vehiculo_validar(&k->form, k->errores)) {
        k->error_form[0] = '\0';
        return 0;
    }
    FormVehiculo v;
    if (!enviar_vehiculo(k, &k->form, &v)) return 0;
    k->form = k->guardado = v;
    k->registrado = 1;
    return 1;
}

typedef enum { LL_OK, LL_SIN_RES, LL_ERR_PROLOG, LL_ERR_CONEXION } Llamada;
static Llamada llamar_crudo(Controlador *k, const char *op, cJSON *args, cJSON **resp);

/* Argumentos de diagnosticar: la selección y los resultados de pruebas ya registrados (F07). */
static cJSON *args_diagnostico(const Controlador *k) {
    cJSON *args = seleccion_a_args(&k->sel);
    if (k->n_hall > 0) {
        cJSON *h = cJSON_AddObjectToObject(args, "hallazgos");
        for (int i = 0; i < k->n_hall; i++) cJSON_AddStringToObject(h, k->hall[i].id, k->hall[i].estado);
    }
    return args;
}

/* swipl nuevo: el estado de la sesión vivía en el proceso anterior. Se vuelve a registrar el
 * vehículo (F04) y a enviar la selección de síntomas (F05); un diálogo RB2 pendiente se pierde,
 * pero la selección que había es la anterior a la contradicción. Si había un diagnóstico en
 * pantalla se recalcula (con los hallazgos de F07) para que Prolog vuelva a recordarlo: las
 * pruebas, la explicación y el guardado trabajan sobre ese último diagnóstico. */
static void reponer_sesion(Controlador *k) {
    k->contra.pendiente = 0;
    if (k->registrado) {
        FormVehiculo v;
        enviar_vehiculo(k, &k->guardado, &v);
    }
    if (k->sel.n > 0) {
        cJSON *r;
        llamar_crudo(k, "fijar_seleccion", seleccion_a_args_completa(&k->sel), &r);
        cJSON_Delete(r);
    }
    if (k->hay_diag) {
        cJSON *r;
        llamar_crudo(k, "diagnosticar", args_diagnostico(k), &r);
        cJSON_Delete(r);
        k->rec_al_dia = 0;
    }
}

void controlador_probar_conexion(Controlador *k) {
    char err[256] = "";
    int nuevo = !conexion_viva(&k->con);
    if (nuevo && conexion_abrir(&k->con, k->script, err, sizeof err) < 0) {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "No se pudo lanzar swipl: %s", err);
        return;
    }
    if (nuevo) reponer_sesion(k);
    cJSON *r = conexion_peticion(&k->con, "ping", NULL, err, sizeof err);
    if (!r) {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "Error de conexión: %s", err);
        return;
    }
    controlador_interpretar(k, r);
    cJSON_Delete(r);
    if (!k->hay_error && !k->catalogo_ok) controlador_cargar_catalogo(k);   /* F05 */
}

void controlador_cerrar(Controlador *k) { conexion_cerrar(&k->con); }

/* ===================== F05 · F06 · F11: operaciones contra Prolog ===================== */

/* Una petición sin reconexión. Los fallos de transporte marcan hay_error (diálogo de conexión de la
 * interfaz); un error de Prolog sobre datos NO lo marca (el sistema sigue conectado), salvo
 * kb_invalida, que la interfaz muestra igual que antes. En LL_OK/LL_SIN_RES deja el JSON en *resp. */
static Llamada llamar_crudo(Controlador *k, const char *op, cJSON *args, cJSON **resp) {
    char err[256] = "";
    *resp = NULL;
    cJSON *r = conexion_peticion(&k->con, op, args, err, sizeof err);
    if (!r) {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "Error de conexión: %s", err);
        return LL_ERR_CONEXION;
    }
    const cJSON *estado = cJSON_GetObjectItemCaseSensitive(r, "estado");
    const char *e = cJSON_IsString(estado) ? estado->valuestring : "";
    if (!strcmp(e, "ok") || !strcmp(e, "sin_resultados")) {
        *resp = r;
        return e[0] == 'o' ? LL_OK : LL_SIN_RES;
    }
    if (!strcmp(e, "error")) {
        controlador_interpretar(k, r);   /* deja código, mensaje y problemas en k->mensaje */
        const cJSON *cod = cJSON_GetObjectItemCaseSensitive(cJSON_GetObjectItemCaseSensitive(r, "error"), "codigo");
        if (!cJSON_IsString(cod) || strcmp(cod->valuestring, "kb_invalida") != 0) k->hay_error = 0;
    } else {
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "Respuesta de Prolog con estado inválido");
    }
    cJSON_Delete(r);
    return LL_ERR_PROLOG;
}

/* Sin conexión no se reabre swipl por detrás: la interfaz muestra el diálogo de error y solo
 * «Reintentar» (controlador_probar_conexion) reabre y repone la sesión. */
static Llamada llamar(Controlador *k, const char *op, cJSON *args, cJSON **resp) {
    (void)op;
    *resp = NULL;
    if (!conexion_viva(&k->con)) {
        cJSON_Delete(args);
        k->hay_error = 1;
        snprintf(k->mensaje, sizeof k->mensaje, "Error de conexión: Prolog no está conectado");
        return LL_ERR_CONEXION;
    }
    return llamar_crudo(k, op, args, resp);
}

static void texto(char *dst, size_t n, const char *src) { snprintf(dst, n, "%s", src); }

/* ---------------------------------------------------------------- F05 ---- */

void controlador_cargar_catalogo(Controlador *k) {
    cJSON *resp;
    char err[256] = "";
    k->catalogo_ok = 0;
    k->aviso[0] = '\0';
    Llamada l = llamar(k, "catalogo_sintomas", NULL, &resp);
    if (l == LL_OK) {
        if (catalogo_parsear(&k->cat, cJSON_GetObjectItemCaseSensitive(resp, "resultados"), err, sizeof err) < 0)
            snprintf(k->aviso, sizeof k->aviso, "Catálogo inválido: %s", err);
        else
            k->catalogo_ok = k->cat.n > 0;
    } else if (l == LL_SIN_RES) {
        k->cat.n = 0;
        texto(k->aviso, sizeof k->aviso, "El catálogo de síntomas está vacío (revisa la base de conocimiento).");
    } else if (l == LL_ERR_PROLOG) {
        texto(k->aviso, sizeof k->aviso, k->mensaje);
    }
    cJSON_Delete(resp);
}

/* Aplica {seleccion, contradiccion} de una respuesta de marcar/quitar/limpiar/resolver/cancelar.
 * Si es inválida no toca nada (la selección previa queda intacta). 0 ok, -1 inválida. */
static int aplicar_estado(Controlador *k, const cJSON *resp) {
    char err[256] = "";
    const cJSON *res = cJSON_GetObjectItemCaseSensitive(resp, "resultados");
    const cJSON *r0 = cJSON_IsArray(res) ? cJSON_GetArrayItem(res, 0) : NULL;
    const cJSON *sel = cJSON_GetObjectItemCaseSensitive(r0, "seleccion");
    const cJSON *con = cJSON_GetObjectItemCaseSensitive(r0, "contradiccion");
    Contradiccion c;
    memset(&c, 0, sizeof c);

    if (cJSON_IsObject(con)) {
        const cJSON *par = cJSON_GetObjectItemCaseSensitive(con, "par");
        const cJSON *a = cJSON_GetArrayItem(par, 0), *b = cJSON_GetArrayItem(par, 1);
        if (!cJSON_IsArray(par) || cJSON_GetArraySize(par) != 2 ||
            json_texto(a, "id", c.id_a, sizeof c.id_a, err, sizeof err) < 0 ||
            json_texto(a, "nombre", c.nombre_a, sizeof c.nombre_a, err, sizeof err) < 0 ||
            json_texto(b, "id", c.id_b, sizeof c.id_b, err, sizeof err) < 0 ||
            json_texto(b, "nombre", c.nombre_b, sizeof c.nombre_b, err, sizeof err) < 0 ||
            json_texto(con, "mensaje", c.mensaje, sizeof c.mensaje, err, sizeof err) < 0) {
            snprintf(k->aviso, sizeof k->aviso, "Respuesta inválida de Prolog (contradicción): %s",
                     err[0] ? err : "formato inesperado");
            return -1;
        }
        c.pendiente = 1;
    } else if (con && !cJSON_IsNull(con)) {
        texto(k->aviso, sizeof k->aviso, "Respuesta inválida de Prolog: 'contradiccion'");
        return -1;
    }
    if (seleccion_parsear(&k->sel, sel, err, sizeof err) < 0) {
        snprintf(k->aviso, sizeof k->aviso, "Respuesta inválida de Prolog (selección): %s", err);
        return -1;
    }
    k->contra = c;
    return 0;
}

static void enviar_seleccion(Controlador *k, const char *op, cJSON *args) {
    cJSON *resp;
    Llamada l = llamar(k, op, args, &resp);
    k->aviso[0] = '\0';
    if (l == LL_OK || l == LL_SIN_RES) {
        aplicar_estado(k, resp);
        k->hay_diag = 0;                 /* el diagnóstico mostrado ya no corresponde a la selección */
        k->aviso_diag[0] = '\0';
        k->hay_rec = k->rec_al_dia = 0;  /* F07: tampoco las pruebas recomendadas */
    } else if (l == LL_ERR_PROLOG) {     /* RNF-02: la selección previa no se altera */
        texto(k->aviso, sizeof k->aviso, k->mensaje);
    }
    cJSON_Delete(resp);
}

void controlador_marcar(Controlador *k, const char *id, EstadoSintoma estado) {
    if (!catalogo_contiene(&k->cat, id)) {   /* RNF-01: solo ids del catálogo recibido */
        snprintf(k->aviso, sizeof k->aviso, "El síntoma '%s' no está en el catálogo: no se envía.", id);
        return;
    }
    cJSON *args = cJSON_CreateObject();
    cJSON_AddStringToObject(args, "id", id);
    cJSON_AddStringToObject(args, "estado", estado_texto(estado));
    enviar_seleccion(k, "marcar_sintoma", args);
}

void controlador_quitar(Controlador *k, const char *id) {
    cJSON *args = cJSON_CreateObject();
    cJSON_AddStringToObject(args, "id", id);
    enviar_seleccion(k, "quitar_sintoma", args);
}

void controlador_limpiar(Controlador *k) {
    k->n_hall = 0;                       /* los resultados de pruebas dependían de esos síntomas */
    enviar_seleccion(k, "limpiar_sintomas", NULL);
}

int controlador_puede_diagnosticar(const Controlador *k) {
    return k->catalogo_ok && !k->contra.pendiente && seleccion_cuenta_calculo(&k->sel) > 0;
}

/* ---------------------------------------------------------------- F06 ---- */

static void aviso_diag(Controlador *k, int es_error, const char *txt) {
    k->aviso_diag_error = es_error;
    texto(k->aviso_diag, sizeof k->aviso_diag, txt);
}

int controlador_hallazgo(Controlador *k, const char *id, const char *estado) {
    if (strncmp(id, "hall_", 5) != 0 || strlen(id) >= ID_LEN ||
        (strcmp(estado, "normal") && strcmp(estado, "leve") && strcmp(estado, "severo")))
        return 0;
    for (int i = 0; i < k->n_hall; i++)
        if (!strcmp(k->hall[i].id, id)) { texto(k->hall[i].estado, sizeof k->hall[i].estado, estado); return 1; }
    if (k->n_hall >= HALL_MAX) return 0;
    texto(k->hall[k->n_hall].id, ID_LEN, id);
    texto(k->hall[k->n_hall].estado, sizeof k->hall[0].estado, estado);
    k->n_hall++;
    return 1;
}

void controlador_diagnosticar(Controlador *k) {
    char err[256] = "";
    k->hay_diag = 0;
    k->aviso_diag[0] = '\0';
    k->hay_rec = k->rec_al_dia = 0;      /* F07: las pruebas se vuelven a pedir para el nuevo */
    k->aviso_pruebas[0] = '\0';
    if (!k->catalogo_ok) {
        aviso_diag(k, 1, "No hay catálogo de síntomas: no se puede diagnosticar.");
        return;
    }
    if (seleccion_validar_envio(&k->sel, &k->cat, err, sizeof err) < 0) {   /* RNF-01: antes de llamar */
        aviso_diag(k, 1, err);
        return;
    }
    cJSON *resp;
    Llamada l = llamar(k, "diagnosticar", args_diagnostico(k), &resp);
    switch (l) {
    case LL_OK:
        if (diagnostico_parsear(&k->diag, cJSON_GetObjectItemCaseSensitive(resp, "resultados"), err, sizeof err) < 0) {
            char m[600];
            snprintf(m, sizeof m, "Respuesta inválida de Prolog, no se muestra: %s", err);
            aviso_diag(k, 1, m);
        } else if (k->diag.n == 0) {     /* sin hipótesis: lo mismo que sin_resultados */
            aviso_diag(k, 0, "No hay hipótesis con los síntomas ingresados. Agrega más síntomas o revisa sus estados.");
        } else {
            k->hay_diag = 1;
        }
        break;
    case LL_SIN_RES:
        aviso_diag(k, 0, "No hay hipótesis con los síntomas ingresados. Agrega más síntomas o revisa sus estados.");
        break;
    default:
        aviso_diag(k, 1, k->mensaje);    /* código y mensaje del error, sin cerrar la aplicación */
        break;
    }
    cJSON_Delete(resp);
}

/* ---------------------------------------------------------------- F07 ---- */

static void aviso_pruebas(Controlador *k, int es_error, const char *txt) {
    k->aviso_pruebas_error = es_error;
    texto(k->aviso_pruebas, sizeof k->aviso_pruebas, txt);
}

void controlador_recomendar_pruebas(Controlador *k) {
    char err[256] = "";
    k->rec_al_dia = 1;                   /* un intento por diagnóstico; el botón Actualizar repite */
    if (!k->hay_diag) {                  /* RNF-01: sin diagnóstico no hay nada que recomendar */
        k->hay_rec = 0;
        aviso_pruebas(k, 0, "Primero genere un diagnóstico.");
        return;
    }
    cJSON *resp;
    Llamada l = llamar(k, "recomendar_pruebas", NULL, &resp);
    if (l == LL_OK) {
        if (recomendacion_parsear(&k->rec, cJSON_GetObjectItemCaseSensitive(resp, "resultados"),
                                  err, sizeof err) < 0) {
            char m[600];
            snprintf(m, sizeof m, "Respuesta inválida de Prolog, no se muestra: %s", err);
            k->hay_rec = 0;
            aviso_pruebas(k, 1, m);
        } else {
            k->hay_rec = 1;
            k->aviso_pruebas[0] = '\0';
        }
    } else if (l == LL_SIN_RES) {
        k->hay_rec = 0;
        aviso_pruebas(k, 1, "Prolog no devolvió recomendaciones.");
    } else {
        k->hay_rec = 0;
        aviso_pruebas(k, 1, k->mensaje);
    }
    cJSON_Delete(resp);
}

int controlador_registrar_resultado(Controlador *k, const char *prueba, const char *resultado) {
    char err[256] = "", hall[ID_LEN], m[1024];
    /* RNF-01: solo la prueba pendiente y uno de sus resultados; si no, no se llama a Prolog. */
    if (!k->hay_rec || !k->rec.hay_pendiente) {
        aviso_pruebas(k, 1, "No hay ninguna prueba pendiente para este diagnóstico.");
        return 0;
    }
    if (strcmp(prueba, k->rec.pendiente.prueba) != 0) {
        snprintf(m, sizeof m, "La prueba recomendada ahora es \"%s\"; registre primero su resultado.",
                 k->rec.pendiente.nombre);
        aviso_pruebas(k, 1, m);
        return 0;
    }
    if (!recomendacion_acepta(&k->rec, resultado)) {
        aviso_pruebas(k, 1, "Elija un resultado: normal, leve o severo.");
        return 0;
    }
    if (snprintf(hall, sizeof hall, "hall_%s", prueba) >= (int)sizeof hall) {
        aviso_pruebas(k, 1, "Identificador de prueba demasiado largo.");
        return 0;
    }
    cJSON *args = cJSON_CreateObject();
    cJSON_AddStringToObject(args, "prueba", prueba);
    cJSON_AddStringToObject(args, "resultado", resultado);
    cJSON *resp;
    Llamada l = llamar(k, "registrar_resultado_prueba", args, &resp);
    if (l != LL_OK) {                    /* RNF-02: el diagnóstico y las pruebas quedan como estaban */
        aviso_pruebas(k, 1, l == LL_SIN_RES ? "Prolog no devolvió el diagnóstico nuevo." : k->mensaje);
        cJSON_Delete(resp);
        return 0;
    }
    /* Prolog ya aplicó el hallazgo: se guarda aquí también para que Diagnosticar lo reenvíe. */
    controlador_hallazgo(k, hall, resultado);
    int ok = diagnostico_parsear(&k->diag, cJSON_GetObjectItemCaseSensitive(resp, "resultados"),
                                 err, sizeof err) == 0;
    cJSON_Delete(resp);
    if (!ok) {
        k->hay_diag = 0;                 /* el anterior ya no corresponde; Diagnosticar lo rehace */
        k->hay_rec = 0;
        snprintf(m, sizeof m, "Resultado registrado, pero la respuesta de Prolog es inválida: %s", err);
        aviso_pruebas(k, 1, m);
        return 1;
    }
    k->hay_diag = 1;
    k->aviso_diag[0] = '\0';
    char nombre[NOMBRE_LEN];
    texto(nombre, sizeof nombre, k->rec.pendiente.nombre);
    controlador_recomendar_pruebas(k);   /* nuevas recomendaciones para el diagnóstico nuevo */
    if (k->hay_rec) {
        snprintf(m, sizeof m, "Resultado registrado: \"%s\" = %s. El diagnóstico se actualizó.",
                 nombre, resultado_prueba_texto(resultado));
        aviso_pruebas(k, 0, m);
    }
    return 1;
}

/* ---------------------------------------------------------------- F11 ---- */

void controlador_resolver(Controlador *k, const char *id_elegido) {
    if (!k->contra.pendiente) return;
    if (strcmp(id_elegido, k->contra.id_a) && strcmp(id_elegido, k->contra.id_b)) {   /* RNF-01 */
        texto(k->aviso, sizeof k->aviso, "Solo puedes elegir uno de los dos síntomas en conflicto.");
        return;
    }
    cJSON *args = cJSON_CreateObject();
    cJSON_AddStringToObject(args, "elegido", id_elegido);
    enviar_seleccion(k, "resolver_contradiccion", args);
}

void controlador_cancelar_contradiccion(Controlador *k) {
    /* Cancelar siempre cierra el diálogo: la selección que muestra C ya es la anterior a la
     * contradicción (Prolog restauró el snapshot al detectar el choque). */
    if (!k->contra.pendiente) return;
    cJSON *resp;
    Llamada l = llamar(k, "cancelar_contradiccion", NULL, &resp);
    if (l == LL_OK || l == LL_SIN_RES) aplicar_estado(k, resp);
    cJSON_Delete(resp);
    k->contra.pendiente = 0;
    texto(k->aviso, sizeof k->aviso, "Marcado cancelado: se conserva la selección anterior.");
}

/* ------------------------------------------------------------ acciones ---- */

int controlador_accion(Controlador *k, const char *accion) {
    char buf[200];
    snprintf(buf, sizeof buf, "%s", accion);
    char *arg = strchr(buf, ':');
    if (arg) *arg++ = '\0';

    if (!strcmp(buf, "catalogo"))              controlador_cargar_catalogo(k);
    else if (!strcmp(buf, "limpiar"))          controlador_limpiar(k);
    else if (!strcmp(buf, "diagnosticar"))     controlador_diagnosticar(k);
    else if (!strcmp(buf, "cancelar"))         controlador_cancelar_contradiccion(k);
    else if (!strcmp(buf, "recomendar"))       controlador_recomendar_pruebas(k);
    else if (!strcmp(buf, "matar")) {          /* simula la caída de swipl */
        if (k->con.pid > 0) { kill(k->con.pid, SIGKILL); usleep(150000); }
    } else if (!strcmp(buf, "quitar") && arg)  controlador_quitar(k, arg);
    else if (!strcmp(buf, "resolver") && arg)  controlador_resolver(k, arg);
    else if ((!strcmp(buf, "marcar") || !strcmp(buf, "hallazgo") || !strcmp(buf, "registrar")) && arg) {
        char *igual = strchr(arg, '=');
        if (!igual) return -1;
        *igual++ = '\0';
        if (!strcmp(buf, "registrar")) {
            controlador_registrar_resultado(k, arg, igual);
        } else if (buf[0] == 'h') {
            if (!controlador_hallazgo(k, arg, igual))
                snprintf(k->aviso_diag, sizeof k->aviso_diag, "Hallazgo inválido: %s=%s", arg, igual);
        } else {
            EstadoSintoma e;
            if (estado_desde_texto(igual, &e) < 0)
                snprintf(k->aviso, sizeof k->aviso, "Estado inválido '%s': no se envía a Prolog.", igual);
            else
                controlador_marcar(k, arg, e);
        }
    } else
        return -1;
    return 0;
}
