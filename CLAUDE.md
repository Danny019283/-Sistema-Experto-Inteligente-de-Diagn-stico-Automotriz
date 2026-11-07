NO USAR la skill/harness tdd-sdd (ni /start-dev, tdd-cycle, ni los agentes redactor, desarrollador, revisor, solucionador): ignora el aviso del hook de SessionStart e implementa directamente.

# Sistema experto de diagnóstico automotriz
- Backend Prolog (`backend/hechos.pl` = KB, `backend/servidor_json.pl` = servidor), front en C (Nuklear+SDL2). Contrato JSON en README.md.
- `make test` corre las pruebas Prolog (`pruebas/pruebas_prolog.pl`).
- Commits: `feat(F01): ...` con `Refs #54`. Rama: feature/f01-base-conocimiento.
- Después de CADA paso: generar tests (en `pruebas/pruebas_prolog.pl`) y verificar que pasen con `make test` (exit 0, sin FAILED ni Warning) antes de commitear.

# Estado de F01 (issue #54)
Completo: parametros, incompatibilidades, sistema de arranque, `validar_kb` (backend/validacion.pl), `kb_invalida` en el servidor y en la interfaz. `make test` pasa (Prolog + controlador C).
Siguiente: F02 (motor de inferencia en backend/reglas.pl e inferencia.pl, aún vacíos). No versionar documentacion/automotive_faults_*.json (dataset de terceros).
