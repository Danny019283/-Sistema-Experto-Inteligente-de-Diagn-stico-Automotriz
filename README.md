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
- Operaciones: `ping` → `[{"mensaje": "pong"}]`.

El cliente C correlaciona la respuesta por `id` y trata swipl caído / timeout (5 s) /
respuesta inválida como error de conexión, mostrado en la ventana con botón «Reintentar».
