# Integración de F05, F06, F11 y F12 con F00–F04

Resumen de qué aporta cada feature, qué archivos del resto del equipo se tocaron y las decisiones
de diseño que conviene revisar en grupo.

## Archivos nuevos

| Archivo | Feature | Contenido |
|---|---|---|
| `backend/ops_sintomas.pl` | F05 | ops `catalogo_sintomas`, `marcar_sintoma`, `quitar_sintoma`, `limpiar_sintomas`, `fijar_seleccion` |
| `backend/memoria_x.pl` | F05/F11 | memoria de trabajo X (selección actual); `x_para_motor/1` excluye `desconocido` |
| `backend/retroceso.pl` | F11 | RB2: snapshots, pila, R2b al marcar, ops `resolver_contradiccion` / `cancelar_contradiccion` |
| `backend/sistemas.pl` | F05/F06 | sistema de cada componente (tabla) y de cada síntoma (deducido de la KB) |
| `frontend/sintomas.*`, `frontend/diagnostico.*` | F05/F06 | modelos C y validación de las respuestas de Prolog |
| `pruebas/pruebas_c.c`, `pruebas_integracion.c`, `servidor_sin_hipotesis.pl`, `calibracion.pl`, `casos_prueba.txt`, `evidencia/` | F12 | pruebas, calibración y capturas |

## Archivos de F00–F04 que se modificaron (cambios mínimos)

* `backend/servidor_json.pl`: `operacion_conocida/1` y `ejecutar/3` pasan a `multifile` (las features
  registran sus ops con cláusulas); `despachar/4` traduce `throw(error_contrato(Codigo, Mensaje))` a
  `estado:"error"` y ya no deja morir el bucle si una operación falla; `diagnosticar` pasa su resultado
  por `enriquecer_diagnostico/2`; al final carga `ops_sintomas` y `retroceso`.
* `backend/reglas.pl`: en la rama de contradicción de `diagnosticar`, la traza lleva el evento `rb2`.
* `frontend/controlador.*`: campos y operaciones de F05/F06/F11; `controlador_probar_conexion` ahora
  también repone la selección y carga el catálogo al reabrir swipl.
* `frontend/interfaz.*`: pantallas **Síntomas** y **Diagnóstico** (antes provisionales), diálogo RB2,
  banderas del menú calculadas desde el estado real, ventana de 1120×700 redimensionable.
* `frontend/main.c`: flags de demo `--backend`, `--pantalla`, `--accion`, `--captura` (evidencia).
* `Makefile`: seguimiento de cabeceras (`-MMD`; sin eso un cambio en un `struct` dejaba objetos viejos),
  mis ejecutables de prueba y los objetivos `capturas` y `calibrar`.
* `pruebas/pruebas_prolog.pl`: `use_module(library(http/json))` (en SWI-Prolog 9.0.4 los módulos de
  prueba no autocargan `atom_json_dict/3`) y, al final, las unidades `f12_razonamiento`,
  `f05_sintomas` y `f11_retroceso`.

## Respuesta de `diagnosticar`: campos añadidos para F06

Cada componente trae `sistema` y el resultado trae `max_iteraciones` (el motor de F02 no los emitía).
Se añaden en `sistemas:enriquecer_diagnostico/2` sin tocar `reglas.pl`.

## Decisiones de diseño a revisar

1. **«Sistema» no existe en la KB** (ni en el PDF). F05 agrupa por sistema y F06 lo muestra, así que se
   resolvió sin tocar `hechos.pl`: `sistemas.pl` clasifica los 80 componentes en 11 sistemas con una tabla
   y **deduce** el sistema de cada síntoma (el sistema con más casos positivos). Un síntoma nuevo se
   agrupa solo; uno sin evidencia cae en «General»; hay excepciones manuales (`fuga_aceite`,
   `arranque_lento`). Una prueba avisa si algún componente nuevo quedó sin clasificar. **Conviene que
   quien hizo F01 revise la tabla.**
2. **La selección vive en Prolog** (como `vehiculo/6`): C solo refleja lo que Prolog confirma, y si
   swipl se cae se reenvía con `fijar_seleccion` junto con el vehículo. `diagnosticar` sigue sin estado:
   C le manda los síntomas del panel y los hallazgos conocidos.
3. **F11 se redujo a RB2.** RB1/RB3 ya estaban en el ciclo recursivo de `reglas.pl`; los escenarios 1 y 2
   se prueban sobre ese motor (casos R3 e I4). RB2 actúa al marcar cada síntoma (ahí existe «la última
   entrada»; en `diagnosticar` el objeto JSON no tiene orden). `diagnosticar` conserva su aviso
   `motivo: contradiccion` y ahora lo deja en la traza.
4. **Un fallo de conexión no se oculta ni se repara por detrás**: sigue el diálogo «Error de conexión»
   de F03 y solo «Reintentar» reabre swipl. Los errores de datos (`entrada_invalida`, etc.) no cuentan
   como caída y se muestran en la pantalla; `kb_invalida` conserva el diálogo de F01.
5. **Hallazgos en el controlador** (`controlador_hallazgo`, `--accion hallazgo:...`): lo mínimo para
   enviar resultados de pruebas a `diagnosticar` y demostrar RB1/RB3 en pantalla. La pantalla Pruebas
   (F07) debe usarlo.

## Para la defensa

* **Recursividad**: el ciclo R6–R8 de `reglas.pl` (F02), que termina por `sin_inciertos`,
  `max_iteraciones`, `prueba_pendiente` o `sin_pruebas`.
* **Backtracking nativo**: `retroceso:par_en_conflicto/3` (`member/2` sobre los pares de R2b) y el
  retroceso explícito RB1/RB3 (F02) y RB2 (F11) con pila de decisiones y snapshots.
* **Listas**: X como lista `Id-Estado`, candidatos ordenados, `findall`, `sort/4`, `group_pairs_by_key`.

## Calibración (make calibrar)

Con la KB real: `tau_bajo ∈ [0,0388; 0,1459)` y `tau_alto ∈ (0,7215; 0,8698]`. Los valores del PDF
(0,05 y 0,85) sirven, pero 0,85 queda a 2 pp de Relé/Circuito de control (87 %) y 0,05 a 1,1 pp de
Pastillas (3,9 %). No se cambiaron; ver `pruebas/casos_prueba.txt` §D.
