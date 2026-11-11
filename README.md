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
make consola # interfaz de texto en la terminal (menú numerado), sin ventana
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
- Errores del historial (F10): `sin_diagnostico`, `sin_vehiculo`, `ya_guardado`, `error_escritura`,
  `no_encontrado`, `registros_corrupto` (ver «guardar_diagnostico» abajo).
- Operaciones: `ping` → `[{"mensaje": "pong"}]`; `diagnosticar`, `registrar_vehiculo` y
  `consultar_vehiculo` (abajo); `catalogo_sintomas`, `marcar_sintoma`, `quitar_sintoma`,
  `limpiar_sintomas`, `fijar_seleccion`, `resolver_contradiccion` y `cancelar_contradiccion`
  («Síntomas y contradicciones»); `guardar_diagnostico`, `listar_diagnosticos` y
  `cargar_diagnostico` (historial, F10); `explicar` (F08); `recomendar_pruebas` y
  `registrar_resultado_prueba` (F07); `acciones_correctivas` (F09); `reporte_textual` (F13).

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

### `guardar_diagnostico` / `listar_diagnosticos` / `cargar_diagnostico` (F10)

Historial persistente en `datos/registros.txt` (`backend/historial.pl`): hechos
`diagnostico(Id, Fecha, Vehiculo, Concluyente, Motivo, Iteraciones)` y
`diagnostico_resultado(Id, Clave, Valor)`, uno por línea. Se lee al arrancar el servidor y cada
guardado agrega líneas al final; el archivo y la carpeta se crean si faltan. La variable de entorno
`SE_REGISTROS` cambia la ruta del archivo (las pruebas de integración y `make capturas` la usan para
no tocar el historial real). En la interfaz: botón "Guardar diagnóstico" en Diagnóstico y pantalla
Historial (lista y detalle de cada diagnóstico guardado).

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

### `explicar` (F08)

Justifica el diagnóstico con textos generados desde la KB (`backend/explicaciones.pl`, regla R10).
Sin args explica el último `diagnosticar`; con `{"id": N}`, uno guardado en el historial.
`resultados[0]`:
- `conclusion`: texto final (concluyente o no; siempre aclara que es una hipótesis).
- `traza`: eventos en orden cronológico, cada uno con `iteracion`, `regla` (`RB2`, `R2-R5`, `R2b`, `R7`,
  `R7-R8`, `RB1`, `RB3`, `R6`, `R9`, `R10`), `texto` y `datos` (los números, p. ej. la prueba
  `{"foco", "prueba", "resultado", "antes", "despues", "aporte"}`). Los `RB2` del inicio son las
  contradicciones resueltas o canceladas al marcar los síntomas (F11): el servidor las guarda con el
  diagnóstico en la clave `rb2`, así que también salen al explicar uno del historial.
  Ej.: «Iteración 1 (R7-R8): foco «Pastillas de freno» (63,3 %)… baja de 63,3 % a 3,9 %».
- `explicacion`: por componente (`componente, nombre, probabilidad, estado, texto`): por qué se
  confirma (prior y síntomas que más aportaron al logit), se descarta o sigue incierto.
- `acciones`: `accion, nombre, relevancia, componentes` (confirmados que la originan) y `texto`.
- `pruebas`: las sugeridas, con los síntomas presentes que las hacen relevantes.

Errores: `sin_diagnostico` («Primero genere un diagnóstico»), `no_encontrado`, `entrada_invalida`.

### `recomendar_pruebas` / `registrar_resultado_prueba` (F07)

Trabajan sobre el último `diagnosticar` (`backend/pruebas_adicionales.pl`, reglas R7-R8).

- `recomendar_pruebas` (sin args) → `resultados[0]`: `pendiente` (la prueba que el ciclo pide
  ahora: `prueba, nombre, componente, nombre_componente, relevancia` (Rp), `resultados` válidos
  según la KB y `texto`; `null` si no hay), `del_foco` (las demás pruebas de ese componente por Rp,
  sin las realizadas; mismo formato sin `resultados`), `otras` (la mejor de cada otro candidato), `realizadas` (`prueba, nombre, componente, nombre_componente, resultado`, en
  orden), `mensaje` (por qué se sugiere la pendiente o, sin pendiente, por qué no hacen falta más
  pruebas: sin hipótesis abiertas, máximo de iteraciones, sin pruebas o contradicción),
  `iteraciones` y `max_iteraciones`.
- `registrar_resultado_prueba {prueba, resultado}` (`normal | leve | severo`): agrega
  `hall_<prueba>` a la entrada del último diagnóstico y vuelve a ejecutar el ciclo. Devuelve el
  diagnóstico nuevo (igual que `diagnosticar`) con `hallazgo: {id, prueba, resultado}`; ese pasa
  a ser el último diagnóstico (`explicar`, `guardar_diagnostico`). Solo se acepta la prueba
  **pendiente**: el motor aplica un hallazgo únicamente cuando R7 pide esa prueba.

Errores (el diagnóstico anterior no cambia): `sin_diagnostico`, `entrada_invalida` (prueba
inexistente, resultado inválido, falta un argumento), `ya_registrada`, `prueba_no_pendiente`
(el mensaje dice cuál es la pendiente, o que no hay ninguna).

### `acciones_correctivas` (F09)

Acciones del último `diagnosticar` (`backend/acciones.pl`, capa 3 y regla R9):
`Ra = 1 − Π(1 − P(Cj|S)·Maj)` solo sobre los componentes **confirmados** que existen en la KB
(las efectividades `Maj` se leen de la KB en cada petición). `resultados[0]`:
- `acciones`: de mayor a menor Ra, cada una con `accion, nombre, relevancia, texto` y
  `componentes` (`id, nombre, probabilidad, efectividad`: los confirmados que la originan).
- `confirmados`: `id, nombre, probabilidad`.
- `mensaje`: resumen; sin confirmados, "Sin acciones: ningún componente confirmado." y qué hacer
  (registrar la prueba recomendada, corregir una contradicción o revisar las pruebas).

Errores: `sin_diagnostico`.

### `reporte_textual` (F13)

Texto plano del reporte de un diagnóstico **guardado** (`backend/reporte.pl`, RF-15): sin args, el
último diagnóstico si ya se guardó; con `{"id": N}`, uno del historial. `resultados[0]`: `id` y
`texto` (fecha, vehículo, síntomas, pruebas realizadas, componentes con probabilidad y estado,
acciones con Ra, traza resumida y estado final). Se arma desde el registro guardado (F10) con los
textos de `explicar` (F08); las secciones vacías lo dicen ("Sin resultados", "Sin acciones").
Errores: `sin_diagnostico`, `sin_guardar` (hay diagnóstico pero no se guardó), `no_encontrado`,
`entrada_invalida`. La interfaz lo muestra y lo exporta a
`datos/reportes/diagnostico_AAAAMMDD_HHMMSS.txt` (crea la carpeta, nunca sobrescribe; la variable de
entorno `SE_REPORTES` cambia la carpeta, la usan las pruebas).

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

## Documentación

- `documentacion/manual_tecnico.docx`: problema, arquitectura, base de conocimiento, reglas, recursividad,
  backtracking, integración C-Prolog, cumplimiento de requisitos y decisiones de diseño.
- `documentacion/manual_usuario.docx`: instalación, compilación, ejecución, uso de cada pantalla y ejemplos.
- `documentacion/casos_prueba.docx`: los 15 casos de prueba y 10 adicionales, con entradas, expectativas,
  resultados y capturas (el mismo contenido en texto plano está en `pruebas/casos_prueba.txt`).
- `documentacion/manual_tecnico.pdf` y `documentacion/manual_usuario.pdf`: los dos manuales en PDF (sección 8 del
  enunciado), exportados desde los .docx.
