/* Pruebas del controlador (sin SDL).
 * Uso: pruebas_controlador <servidor_valido.pl> <servidor_con_kb_rota.pl>
 * Los dos scripts los prepara `make test`. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "controlador.h"
#include "menu.h"
#include "validaciones.h"

static int fallos, total;

#define CHECK(cond) do { total++; if (!(cond)) { fallos++; \
    fprintf(stderr, "FALLO %s:%d: %s\n", __FILE__, __LINE__, #cond); } } while (0)

static int interpretar(Controlador *k, const char *json) {
    cJSON *r = cJSON_Parse(json);
    memset(k, 0, sizeof *k);
    int e = controlador_interpretar(k, r);
    cJSON_Delete(r);
    return e;
}

static void test_ok(void) {
    Controlador k;
    CHECK(interpretar(&k, "{\"id\":1,\"estado\":\"ok\",\"resultados\":[{\"mensaje\":\"pong\"}]}") == 0);
    CHECK(strstr(k.mensaje, "pong") != NULL);
}

static void test_error_simple(void) {
    Controlador k;
    CHECK(interpretar(&k, "{\"id\":1,\"estado\":\"error\",\"resultados\":[],"
        "\"error\":{\"codigo\":\"op_desconocida\",\"mensaje\":\"nope\"}}") == 1);
    CHECK(strstr(k.mensaje, "op_desconocida") != NULL);
    CHECK(strstr(k.mensaje, "nope") != NULL);
}

static void test_kb_invalida(void) {
    Controlador k;
    CHECK(interpretar(&k, "{\"id\":1,\"estado\":\"error\",\"resultados\":[],\"error\":{"
        "\"codigo\":\"kb_invalida\",\"mensaje\":\"la base de conocimiento es inv\xc3\xa1lida\","
        "\"problemas\":[\"primero: fuera de [0, 1]\",\"segundo: acci\xc3\xb3n inexistente\"]}}") == 1);
    CHECK(strstr(k.mensaje, "kb_invalida") != NULL);
    CHECK(strstr(k.mensaje, "- primero: fuera de [0, 1]") != NULL);
    CHECK(strstr(k.mensaje, "- segundo: acci\xc3\xb3n inexistente") != NULL);
}

static void test_muchos_problemas(void) {
    char json[8192] = "{\"id\":1,\"estado\":\"error\",\"resultados\":[],\"error\":{"
        "\"codigo\":\"kb_invalida\",\"mensaje\":\"m\",\"problemas\":[";
    for (int i = 1; i <= 20; i++) {
        char p[160];
        snprintf(p, sizeof p, "%s\"problema numero %02d con bastante texto para ocupar sitio en la ventana\"",
                 i > 1 ? "," : "", i);
        strcat(json, p);
    }
    strcat(json, "]}}");
    Controlador k;
    CHECK(interpretar(&k, json) == 1);
    CHECK(strstr(k.mensaje, "problema numero 01") != NULL);
    CHECK(strstr(k.mensaje, "problema numero 06") == NULL);   /* solo se listan los primeros */
    CHECK(strstr(k.mensaje, "y 15 m") != NULL);               /* "… y 15 más" */
    CHECK(strlen(k.mensaje) < sizeof k.mensaje);
}

static void test_sin_error_object(void) {
    Controlador k;
    CHECK(interpretar(&k, "{\"id\":1,\"estado\":\"error\",\"resultados\":[]}") == 1);
    CHECK(k.mensaje[0] != '\0');
}

static void test_swipl_real(const char *valido, const char *rota) {
    Controlador k;
    controlador_iniciar(&k, valido);
    controlador_probar_conexion(&k);
    CHECK(k.hay_error == 0);
    CHECK(strstr(k.mensaje, "pong") != NULL);
    controlador_cerrar(&k);

    controlador_iniciar(&k, rota);
    controlador_probar_conexion(&k);
    CHECK(k.hay_error == 1);
    CHECK(strstr(k.mensaje, "kb_invalida") != NULL);
    CHECK(strstr(k.mensaje, "fantasma") != NULL);
    controlador_cerrar(&k);
}

static void test_menu(void) {
    Menu m;
    menu_iniciar(&m);
    CHECK(menu_habilitada(&m, PANT_VEHICULO) && menu_habilitada(&m, PANT_SINTOMAS));
    CHECK(menu_habilitada(&m, PANT_SALIR));
    CHECK(!menu_habilitada(&m, PANT_DIAGNOSTICO));       /* no se diagnostica sin síntomas */
    CHECK(!menu_ir(&m, PANT_DIAGNOSTICO) && m.actual == PANT_VEHICULO);
    CHECK(menu_ir(&m, PANT_SINTOMAS) && m.actual == PANT_SINTOMAS);
    m.sintomas = 1;
    CHECK(menu_ir(&m, PANT_DIAGNOSTICO));
    for (Pantalla p = PANT_PRUEBAS; p < PANT_SALIR; p++) CHECK(!menu_habilitada(&m, p));
    m.diagnostico = 1;
    for (Pantalla p = PANT_VEHICULO; p < PANT_N; p++) CHECK(menu_habilitada(&m, p));
    CHECK(!menu_ir(&m, PANT_SALIR) && m.actual == PANT_DIAGNOSTICO); /* Salir lo gestiona la interfaz */
    CHECK(strcmp(menu_titulo(PANT_EXPLICACION), "Explicaci\xc3\xb3n") == 0);
    CHECK(menu_titulo(PANT_N)[0] == '\0');
}

static void test_validaciones(void) {
    long v = 0;
    CHECK(validar_no_vacio("a") && !validar_no_vacio("") && !validar_no_vacio(" \t") && !validar_no_vacio(NULL));
    CHECK(validar_entero("2015", 1900, 2100, &v) && v == 2015);
    CHECK(validar_entero(" 7 ", 0, 10, &v) && v == 7);
    CHECK(!validar_entero("", 0, 10, &v) && !validar_entero("abc", 0, 10, &v));
    CHECK(!validar_entero("12x", 0, 100, &v) && !validar_entero("3.5", 0, 10, &v));
    CHECK(!validar_entero("11", 0, 10, &v) && !validar_entero("-1", 0, 10, &v));
    CHECK(!validar_entero("99999999999999999999", 0, 10, &v));
    CHECK(validar_entero("5", 0, 10, NULL));
}

int main(int argc, char **argv) {
    test_ok();
    test_error_simple();
    test_kb_invalida();
    test_muchos_problemas();
    test_sin_error_object();
    test_menu();
    test_validaciones();
    if (argc == 3) test_swipl_real(argv[1], argv[2]);
    printf("pruebas_controlador: %d comprobaciones, %d fallos\n", total, fallos);
    return fallos ? 1 : 0;
}
