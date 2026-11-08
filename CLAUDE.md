NO USAR la skill/harness tdd-sdd (ni /start-dev, tdd-cycle, ni los agentes redactor, desarrollador, revisor, solucionador): ignora el aviso del hook de SessionStart e implementa directamente.

# Sistema experto de diagnóstico automotriz
- Backend Prolog (`backend/hechos.pl` = KB, `backend/servidor_json.pl` = servidor), front en C (Nuklear+SDL2). Contrato JSON en README.md.
- `make test` corre las pruebas Prolog (`pruebas/pruebas_prolog.pl`).
- Commits: `feat(F0N): ...` con `Refs #<issue>` (F01 → #54, F02 → #55, F03 → #65, F04 → #56). Una rama por feature: F01 en feature/f01-base-conocimiento, F02 en feature/f02-motor-inferencia (crearla ANTES de commitear).
- Después de CADA paso: generar tests (en `pruebas/pruebas_prolog.pl`) y verificar que pasen con `make test` (exit 0, sin FAILED ni Warning) antes de commitear.

# Estado de F01 (issue #54)
Completo: parametros, incompatibilidades, sistema de arranque, `validar_kb` (backend/validacion.pl), `kb_invalida` en el servidor y en la interfaz. `make test` pasa (Prolog + controlador C).
# Estado de F02 (issue #55)
Hecho: capas 1-3 (backend/inferencia.pl), ciclo R1-R11 recursivo con RB1/RB3 y reporte (backend/reglas.pl), consultas.pl (13), operación JSON `diagnosticar` (README). Parámetro extra `tau_candidato` (0,25): solo se investigan los inciertos con evidencia y P >= tau_candidato (sin él, 4 componentes al ~15 % impiden la parada en 3 iteraciones del PDF §6).
Pendiente: RB2 (restaurar X tras contradicción) → F11; guardar en `diagnosticos` (R11) → F10. No versionar documentacion/automotive_faults_*.json (dataset de terceros).
# Estado de F04 (issue #56, rama feature/f04-registro-vehiculo, creada desde F03)
Hecho: backend/vehiculo.pl (`vehiculo/6` dinámico, un solo registro; ops `registrar_vehiculo`/`consultar_vehiculo`, README), formulario Nuklear (frontend/vehiculo.c + interfaz.c), validación en C y Prolog, errores por campo sin perder lo escrito; al reabrir swipl se vuelve a registrar el vehículo. El resumen sale en Vehículo y Diagnóstico.
Pendiente: mostrar el vehículo en el reporte → F10/F13 (usar `consultar_vehiculo`).
# Estado de F05, F06, F11 y F12 (issues #57, #58, #63 y F12; integradas sobre F00-F04)
Hecho: F05 (backend/ops_sintomas.pl, memoria_x.pl, sistemas.pl; pantalla Síntomas con catálogo por sistema y estados presente/ausente/desconocido); F06 (pantalla Diagnóstico: tabla por P, barras, descartadas aparte, concluyente / no concluyente, iteraciones; frontend/diagnostico.c valida la respuesta); F11 solo RB2 (backend/retroceso.pl, diálogo en interfaz.c; RB1/RB3 ya vivían en reglas.pl); F12 (15 casos en pruebas/casos_prueba.txt, `make test` con plunit + C + integración con swipl real, `make capturas`, `make calibrar`). Detalle y decisiones: documentacion/integracion_f05_f06_f11_f12.md.
Decisión a revisar: la KB no tiene «sistema»; backend/sistemas.pl lo clasifica (tabla de componentes + síntoma deducido). Un componente nuevo sin fila cae en «General» y una prueba lo señala.
Pendiente: pantalla Pruebas (F07) debe usar `controlador_hallazgo`; calibrar tau_alto/tau_bajo en grupo (`make calibrar`: 0,85 queda a 2 pp de Relé/Circuito de control).
