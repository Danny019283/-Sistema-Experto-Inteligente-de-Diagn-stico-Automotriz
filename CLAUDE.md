NO USAR la skill/harness tdd-sdd (ni /start-dev, tdd-cycle, ni los agentes redactor, desarrollador, revisor, solucionador): ignora el aviso del hook de SessionStart e implementa directamente.

# Sistema experto de diagnóstico automotriz
- Backend Prolog (`backend/hechos.pl` = KB, `backend/servidor_json.pl` = servidor), front en C (Nuklear+SDL2). Contrato JSON en README.md.
- `make test` corre las pruebas Prolog (`pruebas/pruebas_prolog.pl`).
- Commits: `feat(F0N): ...` con `Refs #<issue>` (F01 → #54, F02 → #55). Una rama por feature: F01 en feature/f01-base-conocimiento, F02 en feature/f02-motor-inferencia (crearla ANTES de commitear).
- Después de CADA paso: generar tests (en `pruebas/pruebas_prolog.pl`) y verificar que pasen con `make test` (exit 0, sin FAILED ni Warning) antes de commitear.

# Estado de F01 (issue #54)
Completo: parametros, incompatibilidades, sistema de arranque, `validar_kb` (backend/validacion.pl), `kb_invalida` en el servidor y en la interfaz. `make test` pasa (Prolog + controlador C).
# Estado de F02 (issue #55)
Hecho: capas 1-3 (backend/inferencia.pl), ciclo R1-R11 recursivo con RB1/RB3 y reporte (backend/reglas.pl), consultas.pl (13), operación JSON `diagnosticar` (README). Parámetro extra `tau_candidato` (0,25): solo se investigan los inciertos con evidencia y P >= tau_candidato (sin él, 4 componentes al ~15 % impiden la parada en 3 iteraciones del PDF §6).
Pendiente: RB2 (restaurar X tras contradicción) → F11; guardar en `diagnosticos` (R11) → F10. No versionar documentacion/automotive_faults_*.json (dataset de terceros).
