CC      ?= gcc
BIN     := sistema_experto
SRC     := $(wildcard frontend/*.c) $(wildcard integracion/*.c) integracion/vendor/cJSON.c
OBJ     := $(SRC:.c=.o)
FUENTE  := $(shell fc-list 2>/dev/null | cut -d: -f1 | grep -m1 'DejaVuSans\.ttf$$')
CFLAGS  := -std=gnu11 -O2 -Wall -Wextra -MMD -MP -Ifrontend -Ifrontend/vendor -Iintegracion \
           -Iintegracion/vendor -DFUENTE_TTF='"$(FUENTE)"' $(shell pkg-config --cflags sdl2 2>/dev/null)
LDLIBS  := $(shell pkg-config --libs sdl2 2>/dev/null) -lm

TEST_C  := pruebas/pruebas_controlador
TEST_C2 := pruebas/pruebas_c
TEST_IN := pruebas/pruebas_integracion
# Todo el front-end que no necesita SDL: lo comparten las pruebas del controlador y las de integración.
TEST_LIB := frontend/controlador.c frontend/menu.c frontend/validaciones.c frontend/vehiculo.c \
            frontend/sintomas.c frontend/diagnostico.c frontend/pruebas_adicionales.c frontend/acciones.c frontend/explicacion.c frontend/historial.c frontend/reporte.c integracion/conexion.c integracion/vendor/cJSON.c
TEST_CFLAGS := -std=gnu11 -Wall -Wextra -w -Ifrontend -Iintegracion -Iintegracion/vendor

.PHONY: build run test clean deps capturas calibrar

build: deps $(BIN)

-include $(OBJ:.o=.d)

$(BIN): $(OBJ)
	$(CC) -o $@ $^ $(LDLIBS)

# cJSON es código de terceros: sin warnings propios.
integracion/vendor/cJSON.o: CFLAGS += -w

run: build
	./$(BIN)

# Prolog (plunit) + controlador (F03/F04) + validadores de respuesta (F05/F06) + integración
# y RNF con un swipl real (F12). LANG=C.UTF-8 para que swipl lea bien los acentos.
test:
	@command -v swipl >/dev/null || { echo "Falta swipl (SWI-Prolog)."; exit 1; }
	LANG=C.UTF-8 swipl -q -g run_tests -t halt pruebas/pruebas_prolog.pl
	$(CC) $(TEST_CFLAGS) -o $(TEST_C) $(TEST_C).c $(TEST_LIB) -lm
	./$(TEST_C) backend/servidor_json.pl pruebas/servidor_kb_rota.pl 2>/dev/null
	$(CC) $(TEST_CFLAGS) -o $(TEST_C2) $(TEST_C2).c frontend/sintomas.c frontend/diagnostico.c frontend/pruebas_adicionales.c frontend/acciones.c frontend/explicacion.c frontend/historial.c frontend/reporte.c frontend/vehiculo.c frontend/validaciones.c integracion/vendor/cJSON.c -lm
	./$(TEST_C2)
	$(CC) $(TEST_CFLAGS) -o $(TEST_IN) $(TEST_IN).c $(TEST_LIB) -lm
	LANG=C.UTF-8 ./$(TEST_IN)

clean:
	rm -f $(BIN) $(OBJ) $(OBJ:.o=.d) $(TEST_C) $(TEST_C2) $(TEST_IN)

deps:
	@command -v gcc >/dev/null || { echo "Falta gcc."; exit 1; }
	@command -v swipl >/dev/null || { echo "Falta swipl (SWI-Prolog): sudo dnf install pl | sudo apt install swi-prolog"; exit 1; }
	@pkg-config --exists sdl2 || { echo "Falta SDL2 (headers): sudo dnf install SDL2-devel | sudo apt install libsdl2-dev"; exit 1; }
	@[ -n "$(FUENTE)" ] || { echo "Falta la fuente DejaVu Sans: sudo dnf install dejavu-sans-fonts | sudo apt install fonts-dejavu-core"; exit 1; }

# Calibra tau_alto / tau_bajo con los casos de prueba (F12): ventana válida y márgenes.
calibrar:
	@LANG=C.UTF-8 swipl -q -g calibrar -t halt pruebas/calibracion.pl

# Capturas de pantalla reproducibles (evidencia F12) con la KB real. Necesitan display
# (xvfb-run si no hay uno). Salida: pruebas/evidencia/*.bmp
# SE_REGISTROS / SE_REPORTES: el historial y los reportes de las capturas van aparte, no a datos/ (F10, F13).
EVD := pruebas/evidencia
CAP := SE_REGISTROS=$(EVD)/registros_capturas.txt SE_REPORTES=$(EVD)/reportes_capturas ./$(BIN)
VEH := --accion vehiculo:Toyota,Corolla,2015,1.8\ L,gasolina,120000
capturas: build
	@mkdir -p $(EVD)
	@rm -f $(EVD)/registros_capturas.txt
	$(CAP) --pantalla sintomas --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=ausente \
	  --accion marcar:luz_check_engine=desconocido --captura $(EVD)/f05_seleccion_estados.bmp
	$(CAP) --pantalla diagnostico --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion diagnosticar --captura $(EVD)/f06_diagnostico_no_concluyente.bmp
	$(CAP) --pantalla diagnostico --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion hallazgo:hall_medir_espesor_pastillas_freno=normal \
	  --accion hallazgo:hall_revisar_nivel_estado_liquido_frenos=severo \
	  --accion hallazgo:hall_inspeccionar_disco_rayaduras_alabeo=normal \
	  --accion diagnosticar --captura $(EVD)/f06_diagnostico_concluyente.bmp
	$(CAP) --pantalla pruebas --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion diagnosticar --accion recomendar --accion registrar:medir_espesor_pastillas_freno=normal \
	  --captura $(EVD)/f07_pruebas_registrada.bmp
	$(CAP) --pantalla pruebas --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion diagnosticar --accion recomendar --accion registrar:medir_espesor_pastillas_freno=normal \
	  --accion registrar:revisar_nivel_estado_liquido_frenos=severo \
	  --accion registrar:inspeccionar_disco_rayaduras_alabeo=normal --captura $(EVD)/f07_pruebas_concluyente.bmp
	$(CAP) --pantalla acciones --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion hallazgo:hall_medir_espesor_pastillas_freno=normal \
	  --accion hallazgo:hall_revisar_nivel_estado_liquido_frenos=severo \
	  --accion hallazgo:hall_inspeccionar_disco_rayaduras_alabeo=normal \
	  --accion diagnosticar --accion acciones --captura $(EVD)/f09_acciones.bmp
	$(CAP) --pantalla acciones --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion diagnosticar --accion acciones --captura $(EVD)/f09_sin_acciones.bmp
	$(CAP) --pantalla explicacion --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion hallazgo:hall_medir_espesor_pastillas_freno=normal \
	  --accion hallazgo:hall_revisar_nivel_estado_liquido_frenos=severo \
	  --accion hallazgo:hall_inspeccionar_disco_rayaduras_alabeo=normal \
	  --accion diagnosticar --accion explicar --captura $(EVD)/f08_explicacion.bmp
	$(CAP) --pantalla explicacion --accion marcar:no_arranca=presente --accion marcar:ralenti_inestable=presente \
	  --accion resolver:no_arranca --accion diagnosticar --accion explicar --captura $(EVD)/f08_explicacion_rb2.bmp
	$(CAP) --pantalla diagnostico $(VEH) --accion marcar:chirrido_frenos=presente \
	  --accion marcar:pedal_freno_esponjoso=presente --accion diagnosticar --accion guardar \
	  --captura $(EVD)/f10_guardado.bmp
	$(CAP) --pantalla historial $(VEH) --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion hallazgo:hall_medir_espesor_pastillas_freno=normal \
	  --accion hallazgo:hall_revisar_nivel_estado_liquido_frenos=severo \
	  --accion hallazgo:hall_inspeccionar_disco_rayaduras_alabeo=normal \
	  --accion diagnosticar --accion guardar --accion listar --accion abrir:2 --captura $(EVD)/f10_historial.bmp
	$(CAP) --pantalla reporte $(VEH) --accion marcar:chirrido_frenos=presente --accion marcar:pedal_freno_esponjoso=presente \
	  --accion hallazgo:hall_medir_espesor_pastillas_freno=normal \
	  --accion hallazgo:hall_revisar_nivel_estado_liquido_frenos=severo \
	  --accion hallazgo:hall_inspeccionar_disco_rayaduras_alabeo=normal \
	  --accion diagnosticar --accion guardar --accion reporte:3 --accion exportar --captura $(EVD)/f13_reporte.bmp
	@rm -rf $(EVD)/registros_capturas.txt $(EVD)/reportes_capturas
	$(CAP) --pantalla sintomas --accion marcar:no_arranca=presente --accion marcar:ralenti_inestable=presente \
	  --captura $(EVD)/f11_dialogo_rb2.bmp
	$(CAP) --backend pruebas/servidor_sin_hipotesis.pl --pantalla diagnostico --accion marcar:sin_relacion=presente \
	  --accion diagnosticar --captura $(EVD)/f12_rnf_sin_hipotesis.bmp
	$(CAP) --pantalla sintomas --accion marcar:chirrido_frenos=presente --accion matar \
	  --accion marcar:pedal_freno_esponjoso=presente --captura $(EVD)/f12_rnf_swipl_caido.bmp
	$(CAP) --backend pruebas/servidor_kb_rota.pl --pantalla sintomas --captura $(EVD)/f12_rnf_kb_invalida.bmp
