/* Pruebas de integración C <-> swipl REAL (F12): cada operación del contrato con una petición
 * real, y los casos de RNF (validación y gestión de errores), sobre la KB y el motor reales.
 * Se ejecuta desde la raíz del proyecto (make test). */
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "controlador.h"

#define SERVIDOR "backend/servidor_json.pl"
#define KB_ROTA "pruebas/servidor_kb_rota.pl"
#define SIN_HIPOTESIS "pruebas/servidor_sin_hipotesis.pl"

static int fallos = 0, total = 0;
#define CHECK(c, nombre) do { total++; if (c) printf("    [ok]    %s\n", nombre); \
    else { fallos++; printf("    [FALLA] %s  (línea %d)\n", nombre, __LINE__); } } while (0)

static const char *estado_de(const cJSON *r) {
    const cJSON *e = cJSON_GetObjectItem(r, "estado");
    return cJSON_IsString(e) ? e->valuestring : "";
}
static const char *codigo_de(const cJSON *r) {
    const cJSON *c = cJSON_GetObjectItem(cJSON_GetObjectItem(r, "error"), "codigo");
    return cJSON_IsString(c) ? c->valuestring : "";
}
static cJSON *pet(Conexion *c, const char *op, cJSON *args) {
    char err[256] = "";
    cJSON *r = conexion_peticion(c, op, args, err, sizeof err);
    if (!r) printf("    (transporte: %s)\n", err);
    return r;
}
static const Componente *comp(const Diagnostico *d, const char *id) {
    for (int i = 0; i < d->n; i++) if (!strcmp(d->comps[i].id, id)) return &d->comps[i];
    return NULL;
}
static int cerca(double a, double b, double tol) { return a - b <= tol && b - a <= tol; }
static void listo(Controlador *k, const char *servidor) {
    controlador_iniciar(k, servidor);
    controlador_probar_conexion(k);   /* abre swipl y carga el catálogo, como la interfaz */
}
static void sintomas_pdf(Controlador *k) {
    controlador_marcar(k, "chirrido_frenos", EST_PRESENTE);
    controlador_marcar(k, "pedal_freno_esponjoso", EST_PRESENTE);
}

/* ---------------------------------------------------------------- I1..I5 -- */

static void i1_catalogo(void) {
    puts("I1 · catalogo_sintomas con swipl real y la KB real");
    Controlador k; listo(&k, SERVIDOR);
    CHECK(k.catalogo_ok && !k.hay_error, "el catálogo se pide a Prolog y se carga");
    CHECK(k.cat.n == 50, "50 síntomas (los hallazgos hall_* no entran al catálogo)");
    int hall = 0;
    for (int i = 0; i < k.cat.n; i++) if (!strncmp(k.cat.items[i].id, "hall_", 5)) hall++;
    CHECK(hall == 0, "ningún hallazgo en el catálogo");
    CHECK(!strcmp(k.cat.items[0].sistema, "Admisión y escape"), "agrupado y ordenado por sistema");
    int frenos = 0;
    for (int i = 0; i < k.cat.n; i++)
        if (!strcmp(k.cat.items[i].id, "chirrido_frenos") && !strcmp(k.cat.items[i].sistema, "Frenos")) frenos = 1;
    CHECK(frenos, "chirrido_frenos aparece en el sistema Frenos");
    controlador_cerrar(&k);
}

static void i2_seleccion(void) {
    puts("I2 · marcar_sintoma / quitar_sintoma / limpiar_sintomas / fijar_seleccion");
    Controlador k; listo(&k, SERVIDOR);
    controlador_marcar(&k, "chirrido_frenos", EST_PRESENTE);
    controlador_marcar(&k, "pedal_freno_esponjoso", EST_AUSENTE);
    controlador_marcar(&k, "luz_check_engine", EST_DESCONOCIDO);
    CHECK(k.sel.n == 3 && seleccion_cuenta_calculo(&k.sel) == 2, "3 marcados, 2 entran al cálculo");
    CHECK(seleccion_estado(&k.sel, "pedal_freno_esponjoso") == EST_AUSENTE, "el estado vuelve de Prolog");
    controlador_quitar(&k, "luz_check_engine");
    CHECK(k.sel.n == 2, "quitar elimina de la selección");
    controlador_limpiar(&k);
    CHECK(k.sel.n == 0 && !controlador_puede_diagnosticar(&k), "limpiar vacía y deshabilita el diagnóstico");
    cJSON *args = cJSON_CreateObject(), *m = cJSON_AddObjectToObject(args, "sintomas");
    cJSON_AddStringToObject(m, "chirrido_frenos", "presente");
    cJSON *r = pet(&k.con, "fijar_seleccion", args);
    CHECK(r && !strcmp(estado_de(r), "ok"), "fijar_seleccion acepta una selección válida");
    cJSON_Delete(r);
    controlador_cerrar(&k);
}

static void i3_diagnosticar(void) {
    puts("I3 · diagnosticar (escenario PDF §6) y su validación en C");
    Controlador k; listo(&k, SERVIDOR);
    sintomas_pdf(&k);
    CHECK(controlador_puede_diagnosticar(&k), "con síntomas presentes se habilita Diagnosticar");
    controlador_diagnosticar(&k);
    CHECK(k.hay_diag && k.diag.n >= 3, "Pastillas, Líquido y Discos (y las demás hipótesis)");
    CHECK(!strcmp(k.diag.comps[0].id, "pastillas_freno") && cerca(k.diag.comps[0].prob, 0.63, 0.02), "Pastillas ≈63 %");
    CHECK(cerca(comp(&k.diag, "liquido_frenos")->prob, 0.44, 0.02), "Líquido ≈44 %");
    CHECK(cerca(comp(&k.diag, "discos_freno")->prob, 0.31, 0.02), "Discos ≈31 %");
    CHECK(!strcmp(comp(&k.diag, "discos_freno")->sistema, "Frenos"), "cada componente trae su sistema");
    CHECK(!k.diag.concluyente && k.diag.iteraciones == 0 && k.diag.max_iteraciones == 5 &&
          !strcmp(k.diag.motivo, "prueba_pendiente"), "no concluyente, 0 de 5 iteraciones, prueba pendiente");
    CHECK(k.diag.prueba_sugerida[0] != '\0', "propone la prueba que falta");
    controlador_cerrar(&k);
}

static void i4_rb1_rb3(void) {
    puts("I4 · RB1 y RB3 (escenarios 1 y 2 de F11) vía diagnosticar con hallazgos");
    Controlador k; listo(&k, SERVIDOR);
    sintomas_pdf(&k);
    controlador_hallazgo(&k, "hall_medir_espesor_pastillas_freno", "normal");
    controlador_diagnosticar(&k);
    CHECK(k.hay_diag && k.diag.iteraciones == 1, "tras la primera prueba: 1 iteración");
    CHECK(comp(&k.diag, "pastillas_freno")->estado == COMP_DESCARTADO, "RB1: Pastillas refutada con espesor normal");
    CHECK(strstr(k.diag.prueba_sugerida, "líquido") || strstr(k.diag.prueba_sugerida, "liquido") ||
          strstr(k.diag.prueba_sugerida, "Líquido"), "y se pasa al siguiente candidato (Líquido)");
    controlador_hallazgo(&k, "hall_revisar_nivel_estado_liquido_frenos", "severo");
    controlador_diagnosticar(&k);
    CHECK(k.diag.iteraciones == 2 && comp(&k.diag, "liquido_frenos")->estado == COMP_CONFIRMADO,
          "RB3: Líquido confirmado, el motor vuelve al punto #1");
    controlador_hallazgo(&k, "hall_inspeccionar_disco_rayaduras_alabeo", "normal");
    controlador_diagnosticar(&k);
    CHECK(k.diag.concluyente && k.diag.iteraciones == 3 && !strcmp(k.diag.motivo, "sin_inciertos"),
          "Discos descartado: concluyente en 3 de 5");
    CHECK(comp(&k.diag, "discos_freno")->estado == COMP_DESCARTADO &&
          comp(&k.diag, "pastillas_freno")->estado == COMP_DESCARTADO, "Pastillas y Discos descartadas");
    CHECK(!controlador_hallazgo(&k, "no_es_hallazgo", "normal") &&
          !controlador_hallazgo(&k, "hall_x", "raro"), "hallazgos mal formados no se aceptan");
    controlador_cerrar(&k);
}

static void i5_rb2(void) {
    puts("I5 · RB2: contradicción, restauración del snapshot y elección del usuario");
    Controlador k; listo(&k, SERVIDOR);
    controlador_marcar(&k, "no_arranca", EST_PRESENTE);
    controlador_marcar(&k, "ralenti_inestable", EST_PRESENTE);
    CHECK(k.contra.pendiente, "R2b detecta el par y se abre el diálogo");
    CHECK(strstr(k.contra.mensaje, "incompatibles") && strstr(k.contra.mensaje, "Ralentí"),
          "el mensaje nombra los dos síntomas");
    CHECK(k.sel.n == 1 && seleccion_estado(&k.sel, "no_arranca") == EST_PRESENTE,
          "X restaurada al snapshot anterior (solo «no arranca»)");
    CHECK(!controlador_puede_diagnosticar(&k), "diagnosticar queda bloqueado hasta resolver");
    controlador_resolver(&k, "chirrido_frenos");
    CHECK(k.contra.pendiente && strstr(k.aviso, "uno de los dos"), "elegir un síntoma ajeno al conflicto se rechaza");
    controlador_resolver(&k, "ralenti_inestable");
    CHECK(!k.contra.pendiente && k.sel.n == 1 && seleccion_estado(&k.sel, "ralenti_inestable") == EST_PRESENTE,
          "la elección vuelve a R2: queda «ralentí inestable»");
    controlador_marcar(&k, "no_arranca", EST_PRESENTE);
    CHECK(k.contra.pendiente, "otro choque abre el diálogo de nuevo");
    controlador_cancelar_contradiccion(&k);
    CHECK(!k.contra.pendiente && k.sel.n == 1 && seleccion_estado(&k.sel, "ralenti_inestable") == EST_PRESENTE,
          "cancelar conserva el estado anterior sin cerrar la aplicación");
    controlador_cerrar(&k);
}

/* ----------------------------------------------------------------- N1..N5 -- */

static void n1_validacion(void) {
    puts("N1 · RNF-01: entradas inválidas se rechazan ANTES de llegar a Prolog");
    Controlador k; controlador_iniciar(&k, "/no/existe/servidor.pl"); /* si enviara, fallaría el lanzamiento */
    k.catalogo_ok = 1;
    snprintf(k.cat.items[0].id, ID_LEN, "chirrido_frenos"); k.cat.n = 1;
    controlador_marcar(&k, "no_existe", EST_PRESENTE);
    CHECK(strstr(k.aviso, "no está en el catálogo") && !strstr(k.aviso, "swipl"),
          "id fuera del catálogo: mensaje esperado y sin tocar swipl");
    controlador_accion(&k, "marcar:chirrido_frenos=quizas");
    CHECK(strstr(k.aviso, "Estado inválido") && !strstr(k.aviso, "swipl"), "estado inválido se rechaza en C");
    controlador_diagnosticar(&k);
    CHECK(k.aviso_diag_error && strstr(k.aviso_diag, "al menos un síntoma") && !k.hay_diag,
          "diagnosticar sin síntomas: mensaje esperado, motor no invocado");
    CHECK(!conexion_viva(&k.con) && !k.hay_error, "ninguna de las tres entradas llegó al motor");
    controlador_cerrar(&k);
    /* y con Prolog conectado, la segunda barrera: Prolog valida y la selección no cambia */
    listo(&k, SERVIDOR);
    controlador_marcar(&k, "chirrido_frenos", EST_PRESENTE);
    cJSON *a = cJSON_CreateObject();
    cJSON_AddStringToObject(a, "id", "chirrido_frenos");
    cJSON_AddStringToObject(a, "estado", "quizas");
    cJSON *r = pet(&k.con, "marcar_sintoma", a);
    CHECK(r && !strcmp(codigo_de(r), "entrada_invalida"), "Prolog rechaza un estado inválido (entrada_invalida)");
    cJSON_Delete(r);
    CHECK(k.sel.n == 1 && !k.hay_error, "la selección previa no se altera");
    controlador_cerrar(&k);
}

static void n2_json_malformado(void) {
    puts("N2 · JSON malformado: json_invalido y el servidor sigue vivo");
    Controlador k; listo(&k, SERVIDOR);
    const char *malo = "{esto no es json\n";
    ssize_t w = write(k.con.fd_envio, malo, strlen(malo));
    (void)w;
    char buf[2048] = ""; size_t n = 0;
    struct pollfd pfd = { k.con.fd_lectura, POLLIN, 0 };
    while (n < sizeof buf - 1 && poll(&pfd, 1, 3000) > 0) {
        ssize_t r = read(k.con.fd_lectura, buf + n, sizeof buf - 1 - n);
        if (r <= 0) break;
        n += (size_t)r; buf[n] = '\0';
        if (strchr(buf, '\n')) break;
    }
    cJSON *resp = cJSON_Parse(buf);
    CHECK(resp && !strcmp(estado_de(resp), "error") && !strcmp(codigo_de(resp), "json_invalido"),
          "código json_invalido en el contrato");
    cJSON_Delete(resp);
    cJSON *r = pet(&k.con, "ping", NULL);
    CHECK(r && !strcmp(estado_de(r), "ok"), "el servidor sigue atendiendo (ping ok)");
    cJSON_Delete(r);
    controlador_cerrar(&k);
}

static void n3_swipl_caido(void) {
    puts("N3 · swipl caído: error controlado, sin cierre, y se recupera con la selección");
    Controlador k; listo(&k, SERVIDOR);
    controlador_marcar(&k, "chirrido_frenos", EST_PRESENTE);
    controlador_accion(&k, "matar");
    controlador_marcar(&k, "pedal_freno_esponjoso", EST_PRESENTE);
    CHECK(k.hay_error && strstr(k.mensaje, "Error de conexión"), "error de conexión (la interfaz abre su diálogo)");
    CHECK(k.sel.n == 1 && k.catalogo_ok, "la selección previa y el catálogo no se alteran");
    controlador_diagnosticar(&k);
    CHECK(!k.hay_diag && k.aviso_diag_error && k.hay_error,
          "con el sistema caído el diagnóstico no se dibuja, avisa y no reabre swipl por su cuenta");
    controlador_cerrar(&k);               /* lo que hace «Reintentar» en el diálogo */
    k.hay_error = 0;
    controlador_probar_conexion(&k);
    CHECK(!k.hay_error && conexion_viva(&k.con), "Reintentar reabre swipl");
    controlador_marcar(&k, "pedal_freno_esponjoso", EST_PRESENTE);
    CHECK(k.sel.n == 2 && seleccion_estado(&k.sel, "chirrido_frenos") == EST_PRESENTE,
          "la selección anterior se reenvió al proceso nuevo");
    controlador_diagnosticar(&k);
    CHECK(k.hay_diag && comp(&k.diag, "pastillas_freno") != NULL, "y el diagnóstico funciona con el proceso nuevo");
    controlador_cerrar(&k);
}

static void n4_kb_invalida(void) {
    puts("N4 · KB inválida: kb_invalida, catálogo deshabilitado, aplicación en pie");
    Controlador k; listo(&k, KB_ROTA);
    CHECK(k.hay_error && strstr(k.mensaje, "kb_invalida"), "la interfaz recibe el código kb_invalida");
    CHECK(!k.catalogo_ok, "el catálogo queda deshabilitado");
    controlador_cargar_catalogo(&k);
    CHECK(strstr(k.aviso, "kb_invalida") && k.hay_error, "pedir el catálogo con KB rota conserva el error kb_invalida");
    controlador_diagnosticar(&k);
    CHECK(k.aviso_diag_error && strstr(k.aviso_diag, "No hay catálogo") && !k.hay_diag,
          "diagnosticar queda bloqueado con mensaje en pantalla");
    CHECK(conexion_viva(&k.con), "swipl sigue vivo: no hubo cierre ni bloqueo");
    controlador_cerrar(&k);
}

static void n5_sin_hipotesis(void) {
    puts("N5 · sin hipótesis: mensaje y sugerencia, sin cerrar");
    Controlador k; listo(&k, SIN_HIPOTESIS);
    CHECK(k.catalogo_ok, "el síntoma sin componentes está en el catálogo");
    controlador_marcar(&k, "sin_relacion", EST_PRESENTE);
    controlador_diagnosticar(&k);
    CHECK(!k.hay_diag && strstr(k.aviso_diag, "No hay hipótesis con los síntomas ingresados"),
          "mensaje «No hay hipótesis con los síntomas ingresados»");
    CHECK(strstr(k.aviso_diag, "Agrega más síntomas") && !k.aviso_diag_error && !k.hay_error,
          "sugiere agregar síntomas y no es un error");
    cJSON *a = cJSON_CreateObject(); cJSON_AddObjectToObject(a, "sintomas");
    cJSON *r = pet(&k.con, "diagnosticar", a);
    CHECK(r && !strcmp(estado_de(r), "sin_resultados"), "sin síntomas el contrato responde sin_resultados");
    cJSON_Delete(r);
    controlador_marcar(&k, "chirrido_frenos", EST_PRESENTE);
    controlador_diagnosticar(&k);
    CHECK(k.hay_diag, "al agregar un síntoma útil el diagnóstico se recupera");
    controlador_cerrar(&k);
}

/* ------------------------------------------------------------------ F07 -- */

static void i6_pruebas(void) {
    puts("I6 · F07: recomendar_pruebas y registrar_resultado_prueba (PDF §6)");
    Controlador k; listo(&k, SERVIDOR);
    controlador_recomendar_pruebas(&k);
    CHECK(!k.hay_rec && strstr(k.aviso_pruebas, "Primero genere un diagnóstico"),
          "sin diagnóstico: mensaje y no se llama a Prolog");
    sintomas_pdf(&k);
    controlador_diagnosticar(&k);
    controlador_recomendar_pruebas(&k);
    CHECK(k.hay_rec && k.rec.hay_pendiente &&
          !strcmp(k.rec.pendiente.prueba, "medir_espesor_pastillas_freno"),
          "la prueba pendiente es la del foco (Pastillas)");
    CHECK(k.rec.n_foco == 1 && !strcmp(k.rec.del_foco[0].prueba, "inspeccionar_estado_pastillas_freno"),
          "lista la otra prueba de Pastillas (del_foco), sin la pendiente");
    CHECK(cerca(k.rec.pendiente.relevancia, 0.70, 0.001) && k.rec.n_resultados == 3,
          "con su Rp (70 %) y los tres resultados posibles");
    CHECK(!strcmp(k.rec.pendiente.nombre_componente, "Pastillas de freno") && k.rec.n_realizadas == 0,
          "muestra el componente y aún no hay realizadas");
    CHECK(!controlador_registrar_resultado(&k, "revisar_nivel_estado_liquido_frenos", "severo") &&
          strstr(k.aviso_pruebas, "La prueba recomendada ahora es") && k.n_hall == 0,
          "otra prueba que no es la pendiente se rechaza en C");
    CHECK(!controlador_registrar_resultado(&k, "medir_espesor_pastillas_freno", "enorme") &&
          k.aviso_pruebas_error && k.n_hall == 0, "un resultado inválido no se envía");
    CHECK(controlador_registrar_resultado(&k, "medir_espesor_pastillas_freno", "normal"),
          "registrar el resultado de la pendiente");
    CHECK(k.hay_diag && cerca(comp(&k.diag, "pastillas_freno")->prob, 0.039, 0.002) && k.diag.iteraciones == 1,
          "el diagnóstico se actualiza: Pastillas baja a 3,9 % (iteración 1)");
    CHECK(k.n_hall == 1 && !strcmp(k.hall[0].id, "hall_medir_espesor_pastillas_freno"),
          "el hallazgo queda guardado para Diagnosticar");
    CHECK(k.hay_rec && !strcmp(k.rec.pendiente.prueba, "revisar_nivel_estado_liquido_frenos") &&
          k.rec.n_realizadas == 1 && !strcmp(k.rec.realizadas[0].resultado, "normal"),
          "la siguiente pendiente es la del Líquido y la anterior figura como realizada");
    CHECK(!k.aviso_pruebas_error && strstr(k.aviso_pruebas, "Resultado registrado"), "confirma el registro");
    controlador_accion(&k, "registrar:revisar_nivel_estado_liquido_frenos=severo");
    controlador_accion(&k, "registrar:inspeccionar_disco_rayaduras_alabeo=normal");
    CHECK(k.diag.concluyente && k.diag.iteraciones == 3, "tras tres resultados el diagnóstico es concluyente");
    CHECK(k.hay_rec && !k.rec.hay_pendiente && k.rec.n_realizadas == 3 && k.rec.mensaje[0],
          "sin pendientes: mensaje explicativo, no una lista vacía");
    CHECK(!controlador_registrar_resultado(&k, "medir_espesor_pastillas_freno", "severo") &&
          strstr(k.aviso_pruebas, "No hay ninguna prueba pendiente"), "ya no se puede registrar nada");
    controlador_diagnosticar(&k);
    CHECK(k.hay_diag && k.diag.concluyente && k.diag.iteraciones == 3,
          "Diagnosticar de nuevo reenvía los hallazgos y llega al mismo resultado");
    controlador_cerrar(&k);
}

static void n6_pruebas_tras_caida(void) {
    puts("N6 · F07: swipl se cae con pruebas registradas y al reconectar se recuperan");
    Controlador k; listo(&k, SERVIDOR);
    sintomas_pdf(&k);
    controlador_diagnosticar(&k);
    controlador_recomendar_pruebas(&k);
    controlador_registrar_resultado(&k, "medir_espesor_pastillas_freno", "normal");
    controlador_accion(&k, "matar");
    Recomendacion antes = k.rec;
    CHECK(!controlador_registrar_resultado(&k, k.rec.pendiente.prueba, "severo") && k.hay_error,
          "con swipl caído el registro falla con error de conexión");
    CHECK(k.n_hall == 1 && k.rec.n_realizadas == antes.n_realizadas && k.hay_diag,
          "el diagnóstico y las pruebas en pantalla no cambian");
    controlador_cerrar(&k);
    k.hay_error = 0;
    controlador_probar_conexion(&k);
    controlador_recomendar_pruebas(&k);
    CHECK(!k.hay_error && k.hay_rec && k.rec.n_realizadas == 1 &&
          !strcmp(k.rec.pendiente.prueba, "revisar_nivel_estado_liquido_frenos"),
          "Reintentar repone el diagnóstico con el hallazgo y sigue la misma prueba");
    controlador_cerrar(&k);
}

int main(void) {
    signal(SIGPIPE, SIG_IGN);
    if (!conexion_swipl_disponible()) { puts("Falta swipl."); return 1; }
    i1_catalogo(); i2_seleccion(); i3_diagnosticar(); i4_rb1_rb3(); i5_rb2();
    n1_validacion(); n2_json_malformado(); n3_swipl_caido(); n4_kb_invalida(); n5_sin_hipotesis();
    i6_pruebas(); n6_pruebas_tras_caida();
    printf("\npruebas_integracion: %d verificaciones, %d fallos\n", total, fallos);
    return fallos ? 1 : 0;
}
