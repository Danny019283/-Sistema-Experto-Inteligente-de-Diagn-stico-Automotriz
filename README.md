# Sistema experto inteligente de diagnóstico automotriz

Front-end en C (Nuklear + SDL2) que habla con un motor de inferencia en SWI-Prolog
mediante mensajes JSON de una línea por los pipes de un proceso `swipl` hijo.

## Requisitos

| Dependencia | Fedora | Debian/Ubuntu |
|---|---|---|
| gcc, make, pkg-config | `sudo dnf install gcc make pkgconf` | `sudo apt install build-essential pkg-config` |
| SWI-Prolog | `sudo dnf install pl` | `sudo apt install swi-prolog` |
| SDL2 (headers) | `sudo dnf install SDL2-devel` | `sudo apt install libsdl2-dev` |
| Fuente DejaVu Sans (tildes) | `sudo dnf install dejavu-sans-fonts` | `sudo apt install fonts-dejavu-core` |

Nuklear y cJSON ya vienen vendorizados (`frontend/vendor/`, `integracion/vendor/`).
`make` verifica las dependencias y falla con un mensaje claro si falta alguna.

## Quick start

```
make build   # compila ./sistema_experto (-Wall -Wextra)
make run     # abre la ventana; «Probar conexión» envía `ping` a Prolog
make test    # pruebas Prolog (no requiere SDL2)
make clean
```

Ejecutar siempre desde la raíz del repo (el binario busca `backend/`).

## Contrato JSON

Una línea JSON por mensaje.

Petición: `{"id": 1, "op": "ping", "args": {}}`

Respuesta:
```
{"id": 1, "estado": "ok", "resultados": [{"mensaje": "pong"}]}
{"id": 1, "estado": "error", "resultados": [],
 "error": {"codigo": "op_desconocida", "mensaje": "..."}}
```

- `estado`: `ok` | `sin_resultados` | `error`. `error` solo aparece con `estado: "error"`.
- Códigos de error: `json_invalido` (mal formado o sin `id`/`op`; `id` sale `null`),
  `op_desconocida`, `args_invalidos` (`args` no es objeto), `excepcion_prolog`.
  `kb_invalida` (la base de conocimiento no pasa `validar_kb`): toda operación conocida
  responde así y añade `error.problemas`, la lista de problemas en texto. Los mensajes mal
  formados, `op_desconocida` y `args_invalidos` conservan su propio código.
```
{"id": 1, "estado": "error", "resultados": [],
 "error": {"codigo": "kb_invalida", "mensaje": "la base de conocimiento es inválida",
           "problemas": ["accion_componente: accion inexistente fantasma"]}}
```
- `entrada_invalida` (solo `diagnosticar`): síntomas inexistentes, estados fuera de rango,
  repetidos, hallazgos de pruebas inexistentes o `sintomas`/`hallazgos` que no son objetos;
  añade `error.problemas` (lista de textos).
- Operaciones: `ping` → `[{"mensaje": "pong"}]`; `diagnosticar`, `registrar_vehiculo`,
  `consultar_vehiculo`, `guardar_diagnostico`, `listar_diagnosticos` y `cargar_diagnostico` (abajo).

### `diagnosticar`

```
{"id": 2, "op": "diagnosticar", "args": {
  "sintomas":  {"chirrido_frenos": "presente", "pedal_freno_esponjoso": "presente"},
  "hallazgos": {"hall_medir_espesor_pastillas_freno": "normal"}}}
```
`sintomas`: `presente | ausente | desconocido`. `hallazgos` (opcional, resultados de pruebas,
id `hall_<prueba>`): `normal | leve | severo`; se aplican cuando el ciclo recomienda esa prueba
(`hallazgos_no_aplicados` lista los que no se pidieron). Sin síntomas → `sin_resultados`.
Un resultado (`resultados[0]`): `concluyente`, `motivo` (`sin_inciertos`, `max_iteraciones`,
`prueba_pendiente`, `sin_pruebas`, `contradiccion`), `iteraciones`, `componentes`
(`id, nombre, probabilidad, estado`), `acciones` (`relevancia`), `pruebas_sugeridas`,
`explicacion`, `traza` (apilar / prueba / rb1 / rb3), `pruebas_hechas`. Un resultado no
concluyente no es un error: pide la prueba de `pruebas_sugeridas[0]`; el cliente la repite con
su hallazgo. Solo se investigan los inciertos con evidencia y P ≥ `tau_candidato` (0,25).

### `registrar_vehiculo` / `consultar_vehiculo`

```
{"id": 3, "op": "registrar_vehiculo", "args": {"marca": "Toyota", "modelo": "Corolla",
  "anio": 2015, "cilindrada": "1.8 L", "combustible": "gasolina", "kilometraje": 120000}}
```
Guarda `vehiculo/6` (hecho dinámico, un solo registro: registrar de nuevo reemplaza el anterior) y
devuelve el vehículo en `resultados[0]`. `consultar_vehiculo` (sin args) devuelve el registrado o
`sin_resultados`. Validación (RNF-01): `marca`, `modelo`, `cilindrada` (p. ej. "1.8 L") texto no vacío de ≤ 40 caracteres
sin caracteres de control (se recortan los espacios de los extremos); `anio` entero entre 1950 y
el año actual + 1; `kilometraje` entero entre 0 y 3 000 000; `combustible`: `gasolina | diesel |
hibrido | electrico | gas`. Si algo falla: `entrada_invalida` con un `"campo: motivo"` por campo
inválido y el registro anterior queda intacto.

### `guardar_diagnostico` / `listar_diagnosticos` / `cargar_diagnostico` (F10)

Historial persistente en `datos/registros.txt` (`backend/historial.pl`): hechos
`diagnostico(Id, Fecha, Vehiculo, Concluyente, Motivo, Iteraciones)` y
`diagnostico_resultado(Id, Clave, Valor)`, uno por línea. Se lee al arrancar el servidor y cada
guardado agrega líneas al final; el archivo y la carpeta se crean si faltan.

- `guardar_diagnostico` (sin args): guarda el **último** `diagnosticar` (concluyente o no) con el
  vehículo registrado; Prolog lo recuerda, el cliente no reenvía nada. Devuelve el resumen
  (abajo) en `resultados[0]`. Errores: `sin_diagnostico` (no se calculó ninguno),
  `sin_vehiculo`, `ya_guardado` (ese diagnóstico ya está en el historial), `error_escritura`
  (no se pudo escribir el archivo; no cambia nada).
- `listar_diagnosticos` (sin args): un resumen por diagnóstico, del más antiguo al más nuevo:
  `id, fecha, vehiculo` ("Toyota Corolla 2015"), `concluyente, motivo, iteraciones`, `principal`
  y `probabilidad` (el componente más probable, o `null`). Vacío → `sin_resultados`.
  Si el archivo tiene líneas dañadas o con formato inválido, se omiten y la respuesta es
  `registros_corrupto` con `error.problemas` (texto por línea) **y los registros válidos en
  `resultados`** (única respuesta de error con `resultados` no vacío).
- `cargar_diagnostico` `{"id": 1}`: `id, fecha, vehiculo` (objeto como en `consultar_vehiculo`),
  `entrada` (`{"sintoma": "estado"}` tal como se pidió) y `resultado` (el objeto de
  `diagnosticar`, igual que cuando se generó). Errores: `entrada_invalida` (id no entero),
  `no_encontrado`.

El cliente C correlaciona la respuesta por `id` y trata swipl caído / timeout (5 s) /
respuesta inválida como error de conexión, mostrado en la ventana con botón «Reintentar».

## Base de conocimiento

`backend/hechos.pl` (hechos Prolog; agregar un síntoma o componente no toca el código C) y
`backend/validacion.pl`. `validar_kb/0` se ejecuta al cargar `hechos.pl` y `validar_kb/1`
devuelve la lista de problemas: ids duplicados o inexistentes, relevancias/efectividades
en [0, 1], conteos enteros ≥ 0, estados (`presente` o `normal|leve|severo`, que deben sumar
N+ y N−), incompatibilidades y parámetros. La ventana muestra el código, el mensaje y los
primeros problemas.

`make test` corre las pruebas Prolog (`pruebas/pruebas_prolog.pl`) y las del controlador en C
(`pruebas/pruebas_controlador.c`, incluido un servidor con la KB rota).
