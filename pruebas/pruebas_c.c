/* Pruebas unitarias de los modelos C de F05/F06: validan las respuestas de Prolog antes de
 * dibujar (RNF-01). No necesitan swipl ni SDL. */
#include <stdio.h>
#include <string.h>

#include "diagnostico.h"
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

    printf("\npruebas_c: %d verificaciones, %d fallos\n", total, fallos);
    return fallos ? 1 : 0;
}
