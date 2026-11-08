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
make test    # pruebas Prolog + C (controlador, validadores e integración con swipl real; sin SDL2)
make capturas   # capturas de pantalla reproducibles en pruebas/evidencia/ (necesita display / xvfb-run)
make calibrar   # ventana válida de tau_alto / tau_bajo con los casos de prueba
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
- `entrada_invalida` (`diagnosticar`, `marcar_sintoma`, `quitar_sintoma`, `fijar_seleccion`): síntomas
  inexistentes, estados fuera de rango, repetidos, hallazgos de pruebas inexistentes o
  `sintomas`/`hallazgos` que no son objetos; añade `error.problemas` (lista de textos).
- Errores de dominio de F11: `contradiccion`, `sin_contradiccion`, `eleccion_invalida`, `pila_vacia`,
  `snapshot_invalido` (llevan `error.mensaje`).
- Operaciones: `ping` → `[{"mensaje": "pong"}]`; `diagnosticar`, `registrar_vehiculo` y
  `consultar_vehiculo` (abajo); `catalogo_sintomas`, `marcar_sintoma`, `quitar_sintoma`,
  `limpiar_sintomas`, `fijar_seleccion`, `resolver_contradiccion` y `cancelar_contradiccion`
  («Síntomas y contradicciones»).

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
(`id, nombre, sistema, probabilidad, estado`), `max_iteraciones`, `acciones` (`relevancia`),
`pruebas_sugeridas`, `explicacion`, `traza` (apilar / prueba / rb1 / rb3 / rb2), `pruebas_hechas`. Un resultado no
concluyente no es un error: pide la prueba de `pruebas_sugeridas[0]`; el cliente la repite con
su hallazgo. Solo se investigan los inciertos con evidencia y P ≥ `tau_candidato` (0,25).

### Síntomas y contradicciones (F05, F11)

La selección de síntomas (memoria de trabajo X) vive en Prolog; el cliente C solo dibuja lo que
Prolog devuelve y, si swipl se reabre, la reenvía con `fijar_seleccion`.

- `catalogo_sintomas` (sin args) → una lista de `{sistema, sintomas: [{id, nombre}]}`, solo síntomas
  (los `hall_*` entran con el resultado de una prueba). El catálogo sale de la KB en cada petición.
  El sistema de cada síntoma se deduce de la KB (`backend/sistemas.pl`).
- `marcar_sintoma {id, estado}` (`presente | ausente | desconocido`; `desconocido` no entra al
  cálculo) → `[{seleccion: [{id, nombre, estado}], contradiccion}]`. Si el síntoma choca con otro
  presente (R2b, `incompatibilidad/2`) Prolog hace **RB2**: restaura X al snapshot anterior y
  `contradiccion` trae `{par: [{id, nombre}, {id, nombre}], entrada, restaurado: true, mensaje}`; si no,
  `contradiccion` es `null`.
- `resolver_contradiccion {elegido}`: solo uno de los dos del par (`eleccion_invalida`); el otro se
  descarta y el elegido vuelve a R2 (puede devolver otra contradicción). `cancelar_contradiccion`
  conserva el estado anterior. Ambas devuelven `{seleccion, contradiccion}`.
- `quitar_sintoma {id}`, `limpiar_sintomas`, `fijar_seleccion {sintomas: {id: estado}}` (todo o nada;
  rechaza una selección con contradicción) devuelven `{seleccion, contradiccion: null}`.

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

## Integración de F05, F06, F11 y F12

Qué se añadió y qué se tocó en F00–F04, y las decisiones de diseño a revisar:
`documentacion/integracion_f05_f06_f11_f12.md`. Los 15 casos de prueba con entradas, expectativas,
resultados y evidencia: `pruebas/casos_prueba.txt`. Demo sin interfaz interactiva:

```
./sistema_experto --pantalla diagnostico --accion marcar:chirrido_frenos=presente \
    --accion marcar:pedal_freno_esponjoso=presente --accion diagnosticar --captura salida.bmp
```
