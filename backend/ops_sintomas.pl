% F05 · Seleccionar síntomas observados (paso 9).
%
% Operaciones del contrato JSON:
%   catalogo_sintomas {}                       -> [ {sistema, sintomas:[{id,nombre}]} ]
%   marcar_sintoma    {id, estado}             -> [ {seleccion:[{id,nombre,estado}], contradiccion} ]
%   quitar_sintoma    {id}                     -> [ {seleccion, contradiccion:null} ]
%   limpiar_sintomas  {}                       -> [ {seleccion:[], contradiccion:null} ]
%   fijar_seleccion   {sintomas:{id: estado}}  -> [ {seleccion, contradiccion:null} ] (todo o nada;
%                                                  lo usa C para reenviar la selección tras reabrir swipl)
% El catálogo sale de la KB en cada petición (solo tipo `sintoma`; los hallazgos entran con el
% resultado de una prueba, F07): agregar un síntoma en hechos.pl lo hace aparecer sin tocar C.
% Estados: presente | ausente | desconocido. `desconocido` no entra al cálculo (queda el prior).
% Entradas inválidas -> `entrada_invalida` con la lista `problemas`, como `diagnosticar`.
:- module(ops_sintomas, [catalogo/1, seleccion_json/1, arg_texto/3, a_atomo/2]).
:- use_module(memoria_x).
:- use_module(sistemas).

:- multifile servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.
:- discontiguous servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.

% Puntos de enganche que F11 (retroceso.pl) implementa; sin F11 no hacen nada.
:- multifile despues_de_marcar/4, seleccion_modificada/0, validar_seleccion/1.
:- dynamic   despues_de_marcar/4, seleccion_modificada/0, validar_seleccion/1.

servidor_json:operacion_conocida(catalogo_sintomas).
servidor_json:operacion_conocida(marcar_sintoma).
servidor_json:operacion_conocida(quitar_sintoma).
servidor_json:operacion_conocida(limpiar_sintomas).
servidor_json:operacion_conocida(fijar_seleccion).

servidor_json:ejecutar(catalogo_sintomas, _, Grupos) :- catalogo(Grupos).
servidor_json:ejecutar(marcar_sintoma, Args, [Res])  :- op_marcar(Args, Res).
servidor_json:ejecutar(quitar_sintoma, Args, [Res])  :- op_quitar(Args, Res).
servidor_json:ejecutar(limpiar_sintomas, _, [Res])   :- op_limpiar(Res).
servidor_json:ejecutar(fijar_seleccion, Args, [Res]) :- op_fijar(Args, Res).

% ---------------------------------------------------------------- catálogo --

%% catalogo(-Grupos): síntomas (tipo sintoma) agrupados por sistema y ordenados por nombre.
catalogo(Grupos) :-
    findall(Sis-(Nombre-Id), ( sintoma(Id, Nombre, sintoma), sistema_sintoma(Id, Sis) ), Filas0),
    sort(0, @=<, Filas0, Filas),
    group_pairs_by_key(Filas, Agrupadas),
    findall(_{sistema: Sis, sintomas: Items},
            ( member(Sis-Pares, Agrupadas),
              findall(_{id: Id, nombre: Nombre}, member(Nombre-Id, Pares), Items) ),
            Grupos).

% ------------------------------------------------------------ validaciones --

%% arg_texto(+Args, +Clave, -Texto): argumento obligatorio de tipo texto (si no, entrada_invalida).
arg_texto(Args, Clave, Texto) :-
    (   get_dict(Clave, Args, V), ( string(V) ; atom(V) ), V \== null, V \== ''
    ->  atom_string(V, Texto)
    ;   format(string(P), "falta el argumento de texto '~w'", [Clave]),
        throw(entrada_invalida([P]))
    ).

%% problemas_marca(+Id, +Estado, -Ps): vacío si Id es un síntoma (no hallazgo) y Estado es válido.
problemas_marca(Id, Estado, Ps) :-
    findall(P, problema_marca(Id, Estado, P), Ps0), sort(Ps0, Ps).

problema_marca(Id, _, P) :-
    \+ sintoma(Id, _, _), format(string(P), "síntoma inexistente: ~w", [Id]).
problema_marca(Id, _, P) :-
    sintoma(Id, _, hallazgo),
    format(string(P), "~w es un hallazgo de una prueba, no un síntoma", [Id]).
problema_marca(Id, Estado, P) :-
    \+ estado_valido(Estado), format(string(P), "estado inválido para ~w: ~w", [Id, Estado]).

% Texto -> átomo con tope de longitud (no se crean átomos desde entradas enormes).
a_atomo(Texto, Atomo) :-
    (   string_length(Texto, L), L >= 1, L =< 64
    ->  atom_string(Atomo, Texto)
    ;   throw(entrada_invalida(["identificador vacío o de más de 64 caracteres"]))
    ).

par_marca(Args, Id, Estado) :-
    arg_texto(Args, id, IdT), arg_texto(Args, estado, EstT),
    a_atomo(IdT, Id), a_atomo(EstT, Estado),
    problemas_marca(Id, Estado, Ps),
    (   Ps == [] -> true ; throw(entrada_invalida(Ps)) ).

nombre_de(Id, Nombre) :- ( sintoma(Id, N, _) -> Nombre = N ; Nombre = Id ).

%% seleccion_json(-Lista): X actual con nombre, tal como la ve el panel de C.
seleccion_json(Lista) :-
    x_obtener(X),
    findall(_{id: Id, nombre: N, estado: E}, ( member(Id-E, X), nombre_de(Id, N) ), Lista).

% ------------------------------------------------------------ operaciones --

op_marcar(Args, Res) :-
    par_marca(Args, Id, Estado),
    x_obtener(Antes),
    x_poner(Id, Estado),
    (   catch(despues_de_marcar(Id, Estado, Antes, Info), E,
              ( x_fijar(Antes), throw(E) ))
    ->  true
    ;   Info = null
    ),
    respuesta(Info, Res).

op_quitar(Args, Res) :-
    arg_texto(Args, id, IdT), a_atomo(IdT, Id),
    (   x_quitar(Id)
    ->  true
    ;   format(string(P), "el síntoma ~w no está en la selección", [Id]),
        throw(entrada_invalida([P]))
    ),
    avisar_cambio,
    respuesta(null, Res).

op_limpiar(Res) :- x_limpiar, avisar_cambio, respuesta(null, Res).

op_fijar(Args, Res) :-
    (   get_dict(sintomas, Args, D), is_dict(D) -> true
    ;   throw(entrada_invalida(["'sintomas' debe ser un objeto {id: estado}"]))
    ),
    dict_pairs(D, _, Pares0),
    findall(Id-Estado-Ps,
            ( member(K-V, Pares0), atom_string(K, KT), a_atomo(KT, Id),
              ( ( string(V) ; atom(V) ) -> atom_string(Estado, V) ; Estado = V ),
              problemas_marca(Id, Estado, Ps) ),
            Revisados),
    findall(P, ( member(_-_-Ps, Revisados), member(P, Ps) ), Problemas0), sort(Problemas0, Problemas),
    (   Problemas == [] -> true ; throw(entrada_invalida(Problemas)) ),
    findall(Id-Estado, member(Id-Estado-_, Revisados), Pares),
    (   validar_seleccion(Pares) -> true ; true ),
    x_fijar(Pares),
    avisar_cambio,
    respuesta(null, Res).

avisar_cambio :- ( seleccion_modificada -> true ; true ).

respuesta(Info, _{seleccion: Sel, contradiccion: Info}) :- seleccion_json(Sel).
