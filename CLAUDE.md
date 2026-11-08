NO USAR la skill/harness tdd-sdd (ni /start-dev, tdd-cycle, ni los agentes redactor, desarrollador, revisor, solucionador): ignora el aviso del hook de SessionStart e implementa directamente.

# Sistema experto de diagnóstico automotriz
- Backend Prolog (`backend/hechos.pl` = KB, `backend/servidor_json.pl` = servidor), front en C (Nuklear+SDL2). Contrato JSON en README.md.
- `make test` corre las pruebas Prolog (`pruebas/pruebas_prolog.pl`).
- Commits: `feat(F0N): ...` con `Refs #<issue>` (F01 → #54, F02 → #55, F03 → #65, F04 → #56, F08 → #60, F10 → #62). Una rama por feature: F01 en feature/f01-base-conocimiento, F02 en feature/f02-motor-inferencia (crearla ANTES de commitear).
- Después de CADA paso: generar tests (en `pruebas/pruebas_prolog.pl`) y verificar que pasen con `make test` (exit 0, sin FAILED ni Warning) antes de commitear.

# Estado de F01 (issue #54)
Completo: parametros, incompatibilidades, sistema de arranque, `validar_kb` (backend/validacion.pl), `kb_invalida` en el servidor y en la interfaz. `make test` pasa (Prolog + controlador C).
# Estado de F02 (issue #55)
Hecho: capas 1-3 (backend/inferencia.pl), ciclo R1-R11 recursivo con RB1/RB3 y reporte (backend/reglas.pl), consultas.pl (13), operación JSON `diagnosticar` (README). Parámetro extra `tau_candidato` (0,25): solo se investigan los inciertos con evidencia y P >= tau_candidato (sin él, 4 componentes al ~15 % impiden la parada en 3 iteraciones del PDF §6).
Pendiente: RB2 (restaurar X tras contradicción) → F11; guardar en `diagnosticos` (R11) → F10. No versionar documentacion/automotive_faults_*.json (dataset de terceros).
# Estado de F04 (issue #56, rama feature/f04-registro-vehiculo, creada desde F03)
Hecho: backend/vehiculo.pl (`vehiculo/6` dinámico, un solo registro; ops `registrar_vehiculo`/`consultar_vehiculo`, README), formulario Nuklear (frontend/vehiculo.c + interfaz.c), validación en C y Prolog, errores por campo sin perder lo escrito; al reabrir swipl se vuelve a registrar el vehículo. El resumen sale en Vehículo y Diagnóstico.
Pendiente: mostrar el vehículo en el reporte → F10/F13 (usar `consultar_vehiculo`).
# Estado de F10 (issue #62, rama feature/f10-guardar-diagnostico)
Hecho (backend): backend/historial.pl (`diagnostico/6` y `diagnostico_resultado/3` dinámicos, persistidos en
datos/registros.txt, leídos al arrancar `main`); ops `guardar_diagnostico` (guarda el último `diagnosticar`, que el
servidor recuerda con `recordar_diagnostico/2`), `listar_diagnosticos`, `cargar_diagnostico` (README). Errores
sin_diagnostico, sin_vehiculo, ya_guardado, error_escritura, no_encontrado, registros_corrupto (con los válidos en
`resultados`). datos/registros.txt está en .gitignore; las pruebas usan un archivo temporal (`usar_registros/1`).
Pendiente: botón «Guardar» y lista del historial en la interfaz C.
# Estado de F08 (issue #60, rama feature/f08-explicacion, creada desde F10)
Hecho (backend): backend/explicaciones.pl (`explicar/3`: traza evento(Iteracion, Regla, Datos) con texto, reconstruyendo X
paso a paso desde la traza del motor; explicación por componente, acciones con su origen, pruebas sugeridas, conclusión);
op `explicar` (último diagnóstico o `{"id": N}` guardado). Textos con números de la KB (coma decimal). RB2 → F11.
Pendiente: panel de traza en la interfaz C.
Nota SWI 9.0 (Ubuntu): no autocarga library(http/json) (por eso el import en pruebas_prolog.pl) y `diagnosticar`
deja un punto de elección (26 avisos «succeeded with choicepoint» en pruebas de F02).
