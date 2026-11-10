/* Pruebas del controlador (sin SDL).
 * Uso: pruebas_controlador <servidor_valido.pl> <servidor_con_kb_rota.pl>
 * Los dos scripts los prepara `make test`. */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <sys/wait.h>

#include "controlador.h"
#include "menu.h"
#include "validaciones.h"
#include "vehiculo.h"
#include <time.h>

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
    for (Pantalla p = PANT_PRUEBAS; p < PANT_SALIR; p++)
        if (p != PANT_HISTORIAL) CHECK(!menu_habilitada(&m, p));   /* el historial (F10) no depende del diagnóstico */
    CHECK(menu_habilitada(&m, PANT_HISTORIAL));
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

static FormVehiculo form_valido(void) {
    FormVehiculo f;
    vehiculo_form_iniciar(&f);
    strcpy(f.marca, "Toyota"); strcpy(f.modelo, "Corolla"); strcpy(f.cilindrada, "1.8 L");
    strcpy(f.anio, "2015"); strcpy(f.km, "120000"); f.combustible = 0;
    return f;
}

static void test_validar_texto(void) {
    CHECK(validar_texto("Ford", 40) && validar_texto("  Ford \t", 40));
    CHECK(!validar_texto("", 40) && !validar_texto("   ", 40));
    CHECK(!validar_texto("Fo\x07rd", 40) && !validar_texto("a\nb", 40));
    char largo[64];
    memset(largo, 'a', 41); largo[41] = 0;
    CHECK(!validar_texto(largo, 40));
    largo[40] = 0;
    CHECK(validar_texto(largo, 40));
    CHECK(validar_texto("\xc3\xb1\xc3\xb1\xc3\xb1", 3) && !validar_texto("\xc3\xb1\xc3\xb1\xc3\xb1", 2)); /* ñññ: 3 caracteres, 6 bytes */
}

static void test_vehiculo_validar(void) {
    char err[VF_N][VF_ERR];
    FormVehiculo f = form_valido();
    CHECK(vehiculo_validar(&f, err) == 0);
    time_t t = time(NULL);
    int max = localtime(&t)->tm_year + 1900 + 1;
    char txt[16];
    snprintf(txt, sizeof txt, "%d", max); strcpy(f.anio, txt);
    CHECK(vehiculo_validar(&f, err) == 0);
    snprintf(txt, sizeof txt, "%d", max + 1); strcpy(f.anio, txt);
    CHECK(vehiculo_validar(&f, err) == 1 && err[VF_ANIO][0]);
    strcpy(f.anio, "1950"); CHECK(vehiculo_validar(&f, err) == 0);
    strcpy(f.anio, "1949"); CHECK(vehiculo_validar(&f, err) == 1);
    strcpy(f.anio, "20x5"); CHECK(vehiculo_validar(&f, err) == 1);
    strcpy(f.anio, "2015");
    strcpy(f.km, "-1"); CHECK(vehiculo_validar(&f, err) == 1 && err[VF_KM][0]);
    strcpy(f.km, "1.5"); CHECK(vehiculo_validar(&f, err) == 1);
    strcpy(f.km, "0"); CHECK(vehiculo_validar(&f, err) == 0);
    strcpy(f.km, "3000001"); CHECK(vehiculo_validar(&f, err) == 1);
    strcpy(f.km, "1");
    f.combustible = -1; CHECK(vehiculo_validar(&f, err) == 1 && err[VF_COMBUSTIBLE][0]);
    f.combustible = 0;
    f.marca[0] = 0; CHECK(vehiculo_validar(&f, err) == 1 && err[VF_MARCA][0] && !err[VF_MODELO][0]);
    strcpy(f.marca, "Ford"); strcpy(f.modelo, "  "); strcpy(f.cilindrada, "x\x01");
    CHECK(vehiculo_validar(&f, err) == 2 && err[VF_MODELO][0] && err[VF_CILINDRADA][0]); /* uno por campo, todos a la vez */
    FormVehiculo v; vehiculo_form_iniciar(&v);
    CHECK(vehiculo_validar(&v, err) == VF_N);
}

static void test_vehiculo_json(void) {
    FormVehiculo f = form_valido(), g;
    cJSON *j = vehiculo_a_json(&f);
    CHECK(strcmp(cJSON_GetObjectItem(j, "marca")->valuestring, "Toyota") == 0);
    CHECK(cJSON_GetObjectItem(j, "anio")->valuedouble == 2015);
    CHECK(strcmp(cJSON_GetObjectItem(j, "combustible")->valuestring, "gasolina") == 0);
    CHECK(vehiculo_desde_json(&g, j) && strcmp(g.modelo, "Corolla") == 0 && strcmp(g.km, "120000") == 0
          && g.combustible == 0);
    cJSON_Delete(j);
    char r[160];
    vehiculo_resumen(&f, r, sizeof r);
    CHECK(strcmp(r, "Toyota Corolla 2015 \xc2\xb7 1.8 L \xc2\xb7 Gasolina \xc2\xb7 120000 km") == 0);
    cJSON *mal = cJSON_Parse("{\"marca\":\"x\"}");
    CHECK(!vehiculo_desde_json(&g, mal));
    cJSON_Delete(mal);
    /* los problemas de Prolog se reparten por campo; los desconocidos se ignoran */
    cJSON *e = cJSON_Parse("{\"estado\":\"error\",\"error\":{\"codigo\":\"entrada_invalida\",\"problemas\":"
        "[\"anio: debe estar entre 1950 y 2027\",\"cilindrada: no puede estar vac\xc3\xado\",\"otro: x\"]}}");
    char err[VF_N][VF_ERR];
    CHECK(vehiculo_errores_prolog(e, err) == 2);
    CHECK(strstr(err[VF_ANIO], "1950") && strstr(err[VF_CILINDRADA], "cilindrada") && !err[VF_MARCA][0]);
    cJSON_Delete(e);
}

static void test_registrar_real(const char *valido, const char *rota) {
    Controlador k;
    controlador_iniciar(&k, valido);
    controlador_probar_conexion(&k);
    k.form = form_valido();
    strcpy(k.form.marca, "  Toyota  ");
    CHECK(controlador_registrar_vehiculo(&k) == 1 && k.registrado);
    CHECK(strcmp(k.guardado.marca, "Toyota") == 0 && strcmp(k.form.marca, "Toyota") == 0); /* lo que devolvió Prolog */
    /* editar reemplaza el registro */
    strcpy(k.form.km, "130000");
    CHECK(controlador_registrar_vehiculo(&k) == 1 && strcmp(k.guardado.km, "130000") == 0);
    cJSON *r = conexion_peticion(&k.con, "consultar_vehiculo", NULL, NULL, 0);
    FormVehiculo v;
    CHECK(r && vehiculo_desde_json(&v, cJSON_GetArrayItem(cJSON_GetObjectItem(r, "resultados"), 0))
          && strcmp(v.km, "130000") == 0);
    cJSON_Delete(r);
    /* dato inválido: no se envía, no se pierde lo escrito, Prolog conserva el anterior */
    strcpy(k.form.anio, "1800");
    CHECK(controlador_registrar_vehiculo(&k) == 0 && k.errores[VF_ANIO][0] && strcmp(k.form.marca, "Toyota") == 0);
    CHECK(strcmp(k.guardado.anio, "2015") == 0 && !k.hay_error);
    /* si swipl muere y se reabre, el vehículo se vuelve a registrar */
    kill(k.con.pid, SIGKILL);
    waitpid(k.con.pid, NULL, 0);
    controlador_probar_conexion(&k);  /* detecta la caída */
    controlador_probar_conexion(&k);  /* reabre */
    r = conexion_peticion(&k.con, "consultar_vehiculo", NULL, NULL, 0);
    CHECK(r && cJSON_GetArraySize(cJSON_GetObjectItem(r, "resultados")) == 1);
    cJSON_Delete(r);
    controlador_cerrar(&k);

    /* error de Prolog que no es de un campo (KB rota): se muestra sin marcar conexión caída */
    controlador_iniciar(&k, rota);
    k.form = form_valido();
    char err[256];
    conexion_abrir(&k.con, rota, err, sizeof err);
    CHECK(controlador_registrar_vehiculo(&k) == 0 && !k.registrado && !k.hay_error);
    CHECK(strstr(k.error_form, "kb_invalida") != NULL && strcmp(k.form.marca, "Toyota") == 0);
    controlador_cerrar(&k);
}

int main(int argc, char **argv) {
    test_ok();
    test_error_simple();
    test_kb_invalida();
    test_muchos_problemas();
    test_sin_error_object();
    test_menu();
    test_validaciones();
    test_validar_texto();
    test_vehiculo_validar();
    test_vehiculo_json();
    if (argc == 3) { test_swipl_real(argv[1], argv[2]); test_registrar_real(argv[1], argv[2]); }
    printf("pruebas_controlador: %d comprobaciones, %d fallos\n", total, fallos);
    return fallos ? 1 : 0;
}
