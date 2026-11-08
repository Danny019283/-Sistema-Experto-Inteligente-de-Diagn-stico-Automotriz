% F11 · Retroceso por contradicción de datos (RB2, PDF §5).
%
% RB1 (refutación) y RB3 (retorno tras confirmar) ya viven en el ciclo recursivo de F02
% (reglas.pl: retroceder/3 sobre la pila de puntos de decisión). Aquí está lo que faltaba:
% cada síntoma marcado es una ENTRADA; antes de aplicarla se apila un snapshot de X y R2b
% (reglas:contradicciones/2) busca un par de incompatibilidad/2 con ambos presentes. Si lo hay:
%   RB2  X vuelve al snapshot anterior a la última entrada, se informa qué par chocó y el
%        usuario elige cuál dato es correcto; la elección vuelve a R2 (puede disparar otra
%        contradicción encadenada). Cancelar conserva el estado anterior.
%
% Backtracking nativo: par_en_conflicto/3 enumera con member/2 los pares que devuelve R2b.
%
% Operaciones del contrato JSON (devuelven {seleccion, contradiccion}):
%   resolver_contradiccion {elegido}   solo admite uno de los dos síntomas en conflicto
%   cancelar_contradiccion {}          restaura el estado anterior
% Errores: sin_contradiccion, eleccion_invalida, pila_vacia, snapshot_invalido, contradiccion.
:- module(retroceso, [apilar_snapshot/1, restaurar_ultimo_snapshot/0, par_en_conflicto/3,
                      registro_rb/1, reiniciar/0]).
:- use_module(memoria_x).
:- use_module(reglas, [contradicciones/2]).
:- use_module(ops_sintomas, [seleccion_json/1, arg_texto/3, a_atomo/2]).

:- multifile servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.
:- discontiguous servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.
:- multifile ops_sintomas:despues_de_marcar/4, ops_sintomas:seleccion_modificada/0,
             ops_sintomas:validar_seleccion/1.

:- dynamic pila_snap/1.     % pila_snap([snap(N, X)|...]) tope primero
:- dynamic pendiente/1.     % pendiente(Previo-Nuevo): diálogo RB2 sin resolver
:- dynamic registro_rb/1.   % eventos RB2 en orden de ocurrencia (F08 los consume)
:- dynamic contador/1.

pila_snap([]).
contador(0).

servidor_json:operacion_conocida(resolver_contradiccion).
servidor_json:operacion_conocida(cancelar_contradiccion).
servidor_json:ejecutar(resolver_contradiccion, Args, [Res]) :-
    arg_texto(Args, elegido, T), a_atomo(T, Id), resolver(Id, Res).
servidor_json:ejecutar(cancelar_contradiccion, _, [Res]) :- cancelar(Res).

% Enganches con F05 ----------------------------------------------------------------
ops_sintomas:despues_de_marcar(Id, Estado, Antes, Info) :- verificar_entrada(Id, Estado, Antes, Info).
ops_sintomas:seleccion_modificada :- reiniciar.
ops_sintomas:validar_seleccion(Pares) :-
    (   contradicciones(Pares, [A-B|_])
    ->  format(string(M), "la selección contiene ~w y ~w, que son incompatibles", [A, B]),
        throw(error_contrato(contradiccion, M))
    ;   true
    ).

%% reiniciar: borra snapshots, diálogo pendiente y registro (cambia la selección entera).
reiniciar :-
    retractall(pila_snap(_)), assertz(pila_snap([])),
    retractall(pendiente(_)), retractall(registro_rb(_)),
    retractall(contador(_)), assertz(contador(0)).

% ------------------------------------------------------------- R2b y snapshots --

%% par_en_conflicto(+Nuevo, +X, -Previo-Nuevo): par de R2b que involucra a la última entrada
%% (si el choque no la involucra, el primer par). member/2 retrocede sobre los pares de R2b.
par_en_conflicto(Nuevo, X, Previo-Nuevo) :-
    contradicciones(X, Pares),
    (   member(A-B, Pares), ( B == Nuevo, Previo = A ; A == Nuevo, Previo = B )
    ->  true
    ;   Pares = [Previo-Nuevo|_]
    ).

apilar_snapshot(X) :-
    retract(contador(N0)), N is N0 + 1, assertz(contador(N)),
    retract(pila_snap(P)), assertz(pila_snap([snap(N, X)|P])).

%% restaurar_ultimo_snapshot: valida el snapshot y restaura X (error pila_vacia si no hay).
restaurar_ultimo_snapshot :-
    pila_snap(P),
    (   P = [snap(_, X)|Resto]
    ->  (   snapshot_valido(X)
        ->  x_fijar(X), retract(pila_snap(_)), assertz(pila_snap(Resto))
        ;   throw(error_contrato(snapshot_invalido,
                                 "el snapshot de la memoria de trabajo está corrupto"))
        )
    ;   throw(error_contrato(pila_vacia,
                             "no hay snapshot que restaurar (la pila de decisiones está vacía)"))
    ).

snapshot_valido(X) :-
    is_list(X),
    forall(member(E, X), ( E = Id-Est, atom(Id), estado_valido(Est) )).

%% verificar_entrada(+Id, +Estado, +Antes, -Info): la entrada ya está en X; Antes = X previa.
%% Info = null | dict con el par, el mensaje del diálogo y `restaurado: true`.
verificar_entrada(Id, Estado, Antes, Info) :-
    apilar_snapshot(Antes),
    x_obtener(X),
    (   Estado == presente, par_en_conflicto(Id, X, Previo-Nuevo)
    ->  restaurar_ultimo_snapshot,                                  % RB2
        retractall(pendiente(_)), assertz(pendiente(Previo-Nuevo)),
        nombre(Previo, NP), nombre(Nuevo, NN),
        registrar(rb2, _{previo: Previo, nuevo: Nuevo,
                         accion: "X restaurada al snapshot anterior a la entrada"}),
        format(string(Msg),
               "Marcaste «~w» y «~w», que son incompatibles. ¿Cuál es correcta?", [NP, NN]),
        Info = _{par: [_{id: Previo, nombre: NP}, _{id: Nuevo, nombre: NN}],
                 entrada: Nuevo, restaurado: true, mensaje: Msg}
    ;   Info = null
    ).

nombre(Id, N) :- ( sintoma(Id, N0, _) -> N = N0 ; N = Id ).

registrar(Tipo, Datos) :-
    put_dict(evento, Datos, Tipo, Ev),
    assertz(registro_rb(Ev)),
    (   predicate_property(traza:registrar(_), defined) -> catch(traza:registrar(Ev), _, true) ; true ).

% --------------------------------------------------------- resolver / cancelar --

%% resolver(+Elegido, -Res): solo uno de los dos en conflicto (RNF-01). El otro se descarta y
%% el elegido se reingresa a R2 (puede detectar una contradicción encadenada).
resolver(Elegido, Res) :-
    (   pendiente(Previo-Nuevo) -> true
    ;   throw(error_contrato(sin_contradiccion, "no hay ninguna contradicción pendiente"))
    ),
    (   Elegido == Previo -> Otro = Nuevo
    ;   Elegido == Nuevo  -> Otro = Previo
    ;   format(string(M), "solo puede elegir ~w o ~w", [Previo, Nuevo]),
        throw(error_contrato(eleccion_invalida, M))
    ),
    retractall(pendiente(_)),
    x_obtener(Antes),
    ( x_quitar(Otro) -> true ; true ),
    x_poner(Elegido, presente),
    verificar_entrada(Elegido, presente, Antes, Info),
    registrar(rb2_resuelta, _{elegido: Elegido, descartado: Otro}),
    respuesta(Info, Res).

cancelar(Res) :-
    (   retract(pendiente(Previo-Nuevo))
    ->  registrar(rb2_cancelada, _{previo: Previo, nuevo: Nuevo,
                                    accion: "se conserva el estado anterior"})
    ;   throw(error_contrato(sin_contradiccion, "no hay ninguna contradicción pendiente"))
    ),
    respuesta(null, Res).

respuesta(Info, _{seleccion: Sel, contradiccion: Info}) :- seleccion_json(Sel).
