/* Pruebas unitarias de los modelos C de F05/F06: validan las respuestas de Prolog antes de
 * dibujar (RNF-01). No necesitan swipl ni SDL. */
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include "acciones.h"
#include "diagnostico.h"
#include "explicacion.h"
#include "historial.h"
#include "reporte.h"
#include "pruebas_adicionales.h"
#include "sintomas.h"

static int fallos = 0, total = 0;
#define CHECK(c, nombre) do { total++; if (c) printf("  [ok]    %s\n", nombre); \
    else { fallos++; printf("  [FALLA] %s  (%s:%d)\n", nombre, __FILE__, __LINE__); } } while (0)

static int diag(const char *txt, Diagnostico *d, char *err) {
    cJSON *r = cJSON_Parse(txt);
    int rc = diagnostico_parsear(d, r, err, 256);
    cJSON_Delete(r);
    return rc;
}

#define COMP(id, p, e) "{\"id\":\"" id "\",\"nombre\":\"N\",\"sistema\":\"Frenos\",\"probabilidad\":" p ",\"estado\":\"" e "\"}"
#define DIAG(comps, conc, it, max) "[{\"componentes\":[" comps "],\"concluyente\":" conc \
    ",\"motivo\":\"prueba_pendiente\",\"iteraciones\":" it ",\"max_iteraciones\":" max "}]"

int main(void) {
    Diagnostico d;
    char err[256];

    puts("diagnostico_parsear (F06, RNF-01: validar antes de dibujar)");
    CHECK(diag(DIAG(COMP("a", "0.2", "incierto") "," COMP("b", "0.9", "confirmado"), "false", "0", "5"), &d, err) == 0,
          "respuesta válida se acepta");
    CHECK(d.n == 2 && !strcmp(d.comps[0].id, "b"), "se ordena por P descendente");
    CHECK(d.max_iteraciones == 5 && d.concluyente == 0 && !strcmp(d.comps[0].sistema, "Frenos"),
          "iteraciones, concluyente y sistema");
    CHECK(diag(DIAG(COMP("a", "1.5", "incierto"), "false", "0", "5"), &d, err) < 0 && strstr(err, "[0, 1]"),
          "probabilidad > 1 se rechaza");
    CHECK(diag(DIAG(COMP("a", "-0.1", "incierto"), "false", "0", "5"), &d, err) < 0, "probabilidad < 0 se rechaza");
    CHECK(diag(DIAG(COMP("a", "\"alta\"", "incierto"), "false", "0", "5"), &d, err) < 0, "probabilidad no numérica se rechaza");
    CHECK(diag(DIAG(COMP("a", "0.5", "quizas"), "false", "0", "5"), &d, err) < 0, "estado desconocido se rechaza");
    CHECK(diag(DIAG(COMP("a", "0.5", "incierto"), "false", "9", "5"), &d, err) < 0, "iteraciones > max se rechaza");
    CHECK(diag(DIAG(COMP("a", "0.5", "incierto"), "\"si\"", "0", "5"), &d, err) < 0, "'concluyente' no booleano se rechaza");
    CHECK(diag("[{\"componentes\":[],\"concluyente\":true,\"iteraciones\":0,\"max_iteraciones\":5}]", &d, err) < 0
          && strstr(err, "motivo"), "falta 'motivo'");
    CHECK(diag("[{\"concluyente\":true,\"motivo\":\"m\",\"iteraciones\":0,\"max_iteraciones\":5}]", &d, err) < 0
          && strstr(err, "componentes"), "falta la lista 'componentes'");
    CHECK(diag("[]", &d, err) < 0 && diag("{}", &d, err) < 0, "estructura inesperada se rechaza");
    CHECK(diag("[{\"componentes\":[{\"id\":\"a\",\"nombre\":\"N\",\"probabilidad\":0.5,\"estado\":\"incierto\"}],"
               "\"concluyente\":true,\"motivo\":\"m\",\"iteraciones\":0,\"max_iteraciones\":5}]", &d, err) < 0
          && strstr(err, "sistema"), "campo obligatorio ausente se rechaza (sistema)");
    CHECK(diag(DIAG("", "true", "0", "5"), &d, err) == 0 && d.n == 0, "sin componentes es válido (se muestra «sin hipótesis»)");
    {   /* una respuesta inválida no corrompe el diagnóstico anterior */
        diag(DIAG(COMP("ok", "0.4", "incierto"), "false", "1", "5"), &d, err);
        diag(DIAG(COMP("mal", "7", "incierto"), "false", "1", "5"), &d, err);
        CHECK(d.n == 1 && !strcmp(d.comps[0].id, "ok"), "tras un rechazo queda intacto el diagnóstico previo");
    }
    CHECK(diag("[{\"componentes\":[" COMP("a", "0.5", "incierto") "],\"concluyente\":false,\"motivo\":\"prueba_pendiente\","
               "\"iteraciones\":1,\"max_iteraciones\":5,\"pruebas_sugeridas\":[{\"nombre\":\"Medir voltaje\"}]}]", &d, err) == 0
          && !strcmp(d.prueba_sugerida, "Medir voltaje"), "prueba sugerida opcional");
    CHECK(diag("[{\"componentes\":[],\"concluyente\":false,\"motivo\":\"contradiccion\",\"iteraciones\":0,\"max_iteraciones\":5,"
               "\"contradicciones\":[{\"a\":\"x\",\"b\":\"y\"}]}]", &d, err) == 0
          && !strcmp(d.contra_a, "x") && !strcmp(d.contra_b, "y"), "par de la contradicción");
    CHECK(!strcmp(motivo_texto("max_iteraciones"), "se alcanzó el máximo de iteraciones"), "texto del motivo");

    puts("catalogo_parsear / seleccion (F05)");
    Catalogo c;
    CHECK(catalogo_parsear(&c, cJSON_Parse("[{\"sistema\":\"Frenos\",\"sintomas\":[{\"id\":\"ruido\",\"nombre\":\"Ruido\"}]}]"),
                           err, sizeof err) == 0 && c.n == 1 && !strcmp(c.items[0].sistema, "Frenos"), "catálogo válido");
    CHECK(catalogo_parsear(&c, cJSON_Parse("[{\"sistema\":\"Frenos\",\"sintomas\":[{\"id\":\"x\"}]}]"), err, sizeof err) < 0
          && c.n == 1, "catálogo sin nombre se rechaza y no pisa el anterior");
    CHECK(catalogo_parsear(&c, cJSON_Parse("{}"), err, sizeof err) < 0, "catálogo que no es lista se rechaza");
    CHECK(catalogo_contiene(&c, "ruido") && !catalogo_contiene(&c, "otro"), "catalogo_contiene");

    Seleccion s = { .n = 0 };
    CHECK(seleccion_validar_envio(&s, &c, err, sizeof err) < 0 && strstr(err, "al menos un"),
          "RNF-01: sin síntomas no se diagnostica");
    snprintf(s.items[0].id, ID_LEN, "ruido"); s.items[0].estado = EST_DESCONOCIDO; s.n = 1;
    CHECK(seleccion_validar_envio(&s, &c, err, sizeof err) < 0, "solo 'desconocido' tampoco basta");
    s.items[0].estado = EST_PRESENTE;
    CHECK(seleccion_validar_envio(&s, &c, err, sizeof err) == 0, "un presente es suficiente");
    snprintf(s.items[0].id, ID_LEN, "fantasma");
    CHECK(seleccion_validar_envio(&s, &c, err, sizeof err) < 0 && strstr(err, "catálogo"),
          "RNF-01: id fuera del catálogo no se envía");
    {
        Seleccion t = { .n = 0 };
        snprintf(t.items[0].id, ID_LEN, "a"); t.items[0].estado = EST_PRESENTE;
        snprintf(t.items[1].id, ID_LEN, "b"); t.items[1].estado = EST_DESCONOCIDO; t.n = 2;
        cJSON *a = seleccion_a_args(&t), *f = seleccion_a_args_completa(&t);
        const cJSON *ma = cJSON_GetObjectItem(a, "sintomas"), *mf = cJSON_GetObjectItem(f, "sintomas");
        CHECK(cJSON_GetArraySize(ma) == 1 && !strcmp(cJSON_GetObjectItem(ma, "a")->valuestring, "presente"),
              "desconocido no entra a los args del cálculo (mapa id: estado)");
        CHECK(cJSON_GetArraySize(mf) == 2, "fijar_seleccion lleva toda la selección");
        cJSON_Delete(a); cJSON_Delete(f);
    }
    {
        Seleccion t = { .n = 0 };
        CHECK(seleccion_parsear(&t, cJSON_Parse("[{\"id\":\"a\",\"nombre\":\"A\",\"estado\":\"presente\"}]"), err, sizeof err) == 0
              && t.n == 1 && seleccion_estado(&t, "a") == EST_PRESENTE, "selección válida");
        CHECK(seleccion_parsear(&t, cJSON_Parse("[{\"id\":\"a\",\"nombre\":\"A\",\"estado\":\"quizas\"}]"), err, sizeof err) < 0
              && t.n == 1, "selección con estado inválido se rechaza y no pisa la anterior");
        EstadoSintoma e;
        CHECK(estado_desde_texto("ausente", &e) == 0 && e == EST_AUSENTE && estado_desde_texto("quizas", &e) < 0,
              "estados válidos: presente/ausente/desconocido");
    }

    puts("recomendacion_parsear (F07, RNF-01)");
    {
        Recomendacion rec;
        memset(&rec, 0, sizeof rec);
#define PEND(rp, res) "{\"prueba\":\"p1\",\"nombre\":\"Prueba 1\",\"componente\":\"c1\"," \
    "\"nombre_componente\":\"Comp 1\",\"relevancia\":" rp ",\"resultados\":[" res "],\"texto\":\"Se sugiere\"}"
#define REC(pend, hechas) "[{\"pendiente\":" pend ",\"del_foco\":[],\"otras\":[],\"realizadas\":[" hechas "]," \
    "\"mensaje\":\"M\",\"iteraciones\":1,\"max_iteraciones\":5}]"
#define HECHA(res) "{\"prueba\":\"p0\",\"nombre\":\"P0\",\"componente\":\"c0\",\"nombre_componente\":\"C0\",\"resultado\":\"" res "\"}"
        cJSON *j = cJSON_Parse(REC(PEND("0.7", "\"normal\",\"leve\",\"severo\""), HECHA("leve")));
        CHECK(recomendacion_parsear(&rec, j, err, sizeof err) == 0 && rec.hay_pendiente &&
              rec.n_resultados == 3 && rec.n_realizadas == 1 && rec.max_iteraciones == 5,
              "recomendación válida con pendiente y una realizada");
        CHECK(recomendacion_acepta(&rec, "leve") && !recomendacion_acepta(&rec, "enorme"),
              "solo acepta los resultados de la pendiente");
        cJSON_Delete(j);
        j = cJSON_Parse(REC(PEND("1.4", "\"normal\""), ""));
        CHECK(recomendacion_parsear(&rec, j, err, sizeof err) < 0 && strstr(err, "[0, 1]") &&
              rec.n_realizadas == 1, "Rp fuera de [0, 1] se rechaza y no pisa la anterior");
        cJSON_Delete(j);
        j = cJSON_Parse(REC(PEND("0.5", "\"grave\""), ""));
        CHECK(recomendacion_parsear(&rec, j, err, sizeof err) < 0, "resultado posible desconocido se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse(REC("null", HECHA("quizas")));
        CHECK(recomendacion_parsear(&rec, j, err, sizeof err) < 0, "realizada con resultado inválido se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse(REC("null", ""));
        CHECK(recomendacion_parsear(&rec, j, err, sizeof err) == 0 && !rec.hay_pendiente &&
              !recomendacion_acepta(&rec, "normal") && !strcmp(rec.mensaje, "M"),
              "sin pendiente (null) se acepta con su mensaje");
        cJSON_Delete(j);
        j = cJSON_Parse("[{\"pendiente\":null,\"del_foco\":[],\"otras\":[],\"realizadas\":[],\"iteraciones\":0,\"max_iteraciones\":5}]");
        CHECK(recomendacion_parsear(&rec, j, err, sizeof err) < 0, "sin 'mensaje' se rechaza");
        cJSON_Delete(j);
        CHECK(!strcmp(resultado_prueba_texto("severo"), "Severo") && resultado_prueba_valido("leve") &&
              !resultado_prueba_valido("presente"), "resultados normal/leve/severo");
    }

    puts("acciones_parsear (F09, RNF-01: Ra en [0, 1] y solo de confirmados)");
    {
        Acciones ac;
        memset(&ac, 0, sizeof ac);
#define ORIG "{\"id\":\"c1\",\"nombre\":\"C1\",\"probabilidad\":0.93,\"efectividad\":0.95}"
#define ACC(id, ra, comps) "{\"accion\":\"" id "\",\"nombre\":\"N\",\"relevancia\":" ra \
    ",\"componentes\":[" comps "],\"texto\":\"T\"}"
#define ACS(acs, conf) "[{\"acciones\":[" acs "],\"confirmados\":[" conf "],\"mensaje\":\"M\"}]"
#define CONF "{\"id\":\"c1\",\"nombre\":\"C1\",\"probabilidad\":0.93}"
        cJSON *j = cJSON_Parse(ACS(ACC("b", "0.47", ORIG) "," ACC("a", "0.88", ORIG), CONF));
        CHECK(acciones_parsear(&ac, j, err, sizeof err) == 0 && ac.n == 2 && ac.n_confirmados == 1,
              "respuesta válida se acepta");
        CHECK(!strcmp(ac.items[0].id, "a") && ac.items[0].origen[0].efectividad == 0.95,
              "se ordena por Ra descendente y trae el origen");
        cJSON_Delete(j);
        j = cJSON_Parse(ACS(ACC("a", "1.2", ORIG), CONF));
        CHECK(acciones_parsear(&ac, j, err, sizeof err) < 0 && strstr(err, "[0, 1]") && ac.n == 2,
              "Ra fuera de [0, 1] se rechaza y no pisa la anterior");
        cJSON_Delete(j);
        j = cJSON_Parse(ACS(ACC("a", "0.5", ""), CONF));
        CHECK(acciones_parsear(&ac, j, err, sizeof err) < 0, "acción sin componentes de origen se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse(ACS(ACC("a", "0.5", ORIG), ""));
        CHECK(acciones_parsear(&ac, j, err, sizeof err) < 0, "acciones sin confirmados se rechazan");
        cJSON_Delete(j);
        j = cJSON_Parse(ACS(ACC("a", "0.5", "{\"id\":\"c1\",\"nombre\":\"C1\",\"probabilidad\":0.9,\"efectividad\":3}"), CONF));
        CHECK(acciones_parsear(&ac, j, err, sizeof err) < 0, "efectividad fuera de [0, 1] se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse(ACS("", ""));
        CHECK(acciones_parsear(&ac, j, err, sizeof err) == 0 && ac.n == 0 && !strcmp(ac.mensaje, "M"),
              "sin acciones se acepta con su mensaje");
        cJSON_Delete(j);
    }

    puts("explicacion_parsear (F08, RNF-01/02)");
    {
        Explicacion ex;
        memset(&ex, 0, sizeof ex);
#define EV(it, r) "{\"iteracion\":" it ",\"regla\":\"" r "\",\"texto\":\"T\",\"datos\":{}}"
#define EXPL(traza, comps) "[{\"conclusion\":\"C\",\"traza\":[" traza "],\"explicacion\":[" comps "]," \
    "\"acciones\":[{\"accion\":\"a\",\"nombre\":\"A\",\"relevancia\":0.88,\"componentes\":[],\"texto\":\"TA\"}]," \
    "\"pruebas\":[]}]"
#define EC(est, p) "{\"componente\":\"c\",\"nombre\":\"C\",\"probabilidad\":" p ",\"estado\":\"" est "\",\"texto\":\"X\"}"
        cJSON *j = cJSON_Parse(EXPL(EV("0", "RB2") "," EV("0", "R2-R5") "," EV("2", "R7-R8"), EC("confirmado", "0.93")));
        CHECK(explicacion_parsear(&ex, j, err, sizeof err) == 0 && ex.n_traza == 3 && ex.n_comps == 1 &&
              ex.n_acciones == 1 && !strcmp(ex.traza[0].regla, "RB2"), "explicación válida se acepta");
        CHECK(explicacion_max_iteracion(&ex) == 2 && ex.comps[0].estado == COMP_CONFIRMADO,
              "iteración máxima y estado del componente");
        cJSON_Delete(j);
        j = cJSON_Parse(EXPL("", EC("confirmado", "0.93")));
        CHECK(explicacion_parsear(&ex, j, err, sizeof err) < 0 && strstr(err, "vacía") && ex.n_traza == 3,
              "traza vacía se informa y no pisa la anterior");
        cJSON_Delete(j);
        j = cJSON_Parse(EXPL(EV("1", "R6"), EC("quizas", "0.5")));
        CHECK(explicacion_parsear(&ex, j, err, sizeof err) < 0, "estado de componente inválido se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse(EXPL(EV("1", "R6"), EC("incierto", "1.7")));
        CHECK(explicacion_parsear(&ex, j, err, sizeof err) < 0, "probabilidad fuera de [0, 1] se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse(EXPL("{\"iteracion\":\"uno\",\"regla\":\"R6\",\"texto\":\"T\"}", ""));
        CHECK(explicacion_parsear(&ex, j, err, sizeof err) < 0, "iteración no entera se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse("[{\"traza\":[],\"explicacion\":[],\"acciones\":[],\"pruebas\":[]}]");
        CHECK(explicacion_parsear(&ex, j, err, sizeof err) < 0, "sin 'conclusion' se rechaza");
        cJSON_Delete(j);
    }

    puts("historial (F10, RNF-01: validar antes de mostrar)");
    {
        Historial h;
        DiagGuardado g;
        memset(&h, 0, sizeof h);
#define RES(id, pr, p) "{\"id\":" id ",\"fecha\":\"2026-11-10 10:00:00\",\"vehiculo\":\"Toyota Corolla 2015\"," \
    "\"concluyente\":true,\"motivo\":\"sin_inciertos\",\"iteraciones\":3,\"principal\":" pr ",\"probabilidad\":" p "}"
        cJSON *j = cJSON_Parse("[" RES("1", "\"Líquido de frenos\"", "0.93") "," RES("2", "null", "null") "]");
        CHECK(historial_parsear(&h, j, err, sizeof err) == 0 && h.n == 2 && h.items[0].probabilidad == 0.93 &&
              h.items[1].probabilidad < 0 && !h.items[1].principal[0], "lista válida, con y sin componente principal");
        cJSON_Delete(j);
        j = cJSON_Parse("[" RES("1", "\"X\"", "1.5") "]");
        CHECK(historial_parsear(&h, j, err, sizeof err) < 0 && h.n == 2, "probabilidad fuera de [0, 1] se rechaza sin pisar la lista");
        cJSON_Delete(j);
        j = cJSON_Parse("[" RES("0", "null", "null") "]");
        CHECK(historial_parsear(&h, j, err, sizeof err) < 0, "id no positivo se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse("[]");
        CHECK(historial_parsear(&h, j, err, sizeof err) == 0 && h.n == 0, "historial vacío");
        cJSON_Delete(j);
#define GUARD(res) "[{\"id\":2,\"fecha\":\"2026-11-10 10:00:00\",\"vehiculo\":{\"marca\":\"Toyota\",\"modelo\":\"Corolla\"," \
    "\"anio\":2015,\"cilindrada\":\"1.8 L\",\"combustible\":\"gasolina\",\"kilometraje\":120000}," \
    "\"entrada\":{\"chirrido_frenos\":\"presente\"},\"resultado\":" res "}]"
        j = cJSON_Parse(GUARD("{\"componentes\":[" COMP("a", "0.9", "confirmado") "],\"concluyente\":true,"
                              "\"motivo\":\"sin_inciertos\",\"iteraciones\":1,\"max_iteraciones\":5}"));
        CHECK(diagnostico_guardado_parsear(&g, j, err, sizeof err) == 0 && g.id == 2 && g.n_entrada == 1 &&
              g.diag.n == 1 && g.diag.concluyente && strstr(g.vehiculo, "Toyota Corolla 2015"),
              "diagnóstico guardado válido (vehículo, entrada y resultado)");
        cJSON_Delete(j);
        j = cJSON_Parse(GUARD("{\"componentes\":[" COMP("a", "2", "confirmado") "],\"concluyente\":true,"
                              "\"motivo\":\"sin_inciertos\",\"iteraciones\":1,\"max_iteraciones\":5}"));
        CHECK(diagnostico_guardado_parsear(&g, j, err, sizeof err) < 0 && g.id == 2,
              "el resultado guardado se valida como en F06 y no pisa el anterior");
        cJSON_Delete(j);
        j = cJSON_Parse("[{\"id\":3,\"fecha\":\"f\",\"entrada\":{},\"resultado\":{}}]");
        CHECK(diagnostico_guardado_parsear(&g, j, err, sizeof err) < 0, "sin vehículo se rechaza");
        cJSON_Delete(j);
    }

    puts("reporte (F13, RNF-01/02: validar, no sobrescribir, informar errores de escritura)");
    {
        Reporte rp;
        memset(&rp, 0, sizeof rp);
        char ruta[512], ruta2[512], nombre[64];
        cJSON *j = cJSON_Parse("[{\"id\":2,\"texto\":\"REPORTE\nlinea\"}]");
        CHECK(reporte_parsear(&rp, j, err, sizeof err) == 0 && rp.id == 2 && !strcmp(rp.texto, "REPORTE\nlinea"),
              "reporte válido se acepta");
        cJSON_Delete(j);
        j = cJSON_Parse("[{\"id\":2,\"texto\":\"\"}]");
        CHECK(reporte_parsear(&rp, j, err, sizeof err) < 0 && rp.id == 2, "un reporte vacío se rechaza");
        cJSON_Delete(j);
        j = cJSON_Parse("[{\"id\":0,\"texto\":\"X\"}]");
        CHECK(reporte_parsear(&rp, j, err, sizeof err) < 0, "id no positivo se rechaza");
        cJSON_Delete(j);
        struct tm tm = { .tm_year = 2026 - 1900, .tm_mon = 10, .tm_mday = 16, .tm_hour = 9, .tm_min = 5, .tm_sec = 7, .tm_isdst = -1 };
        time_t t = mktime(&tm);
        reporte_nombre(t, nombre, sizeof nombre);
        CHECK(!strcmp(nombre, "diagnostico_20261116_090507.txt"), "nombre diagnostico_AAAAMMDD_HHMMSS.txt");
        char dir[256];
        snprintf(dir, sizeof dir, "/tmp/se_reportes_unit_%d/datos/reportes", (int)getpid());
        CHECK(reporte_exportar(dir, "uno", t, ruta, sizeof ruta, err, sizeof err) == 0 && strstr(ruta, nombre),
              "exporta y crea la carpeta que falta");
        CHECK(reporte_exportar(dir, "dos", t, ruta2, sizeof ruta2, err, sizeof err) == 0 &&
              strstr(ruta2, "diagnostico_20261116_090507_2.txt"), "a la misma hora no sobrescribe: agrega _2");
        FILE *f = fopen(ruta, "r");
        char buf[16] = "";
        if (f) { if (!fgets(buf, sizeof buf, f)) buf[0] = '\0'; fclose(f); }
        CHECK(!strcmp(buf, "uno\n"), "el primer reporte queda intacto");
        remove(ruta); remove(ruta2);
        CHECK(reporte_exportar("datos/../../etc", "x", t, ruta, sizeof ruta, err, sizeof err) < 0, "una ruta con .. se rechaza");
        CHECK(reporte_exportar("/proc/sin_permiso", "x", t, ruta, sizeof ruta, err, sizeof err) < 0 &&
              strstr(err, "No se pudo crear"), "carpeta sin permiso: se informa el motivo");
        CHECK(reporte_exportar(dir, "", t, ruta, sizeof ruta, err, sizeof err) < 0, "sin texto no se exporta");
    }

    printf("\npruebas_c: %d verificaciones, %d fallos\n", total, fallos);
    return fallos ? 1 : 0;
}
