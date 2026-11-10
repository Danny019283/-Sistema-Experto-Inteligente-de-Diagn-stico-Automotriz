% F09 · Acciones correctivas (issue #61; PDF §2.3 capa 3, regla R9, paso 16; RF-10).
%
% Operación del contrato JSON (ver README):
%   acciones_correctivas {} -> [ {acciones, confirmados, mensaje} ]
%     acciones:    [{accion, nombre, relevancia, componentes:[{id, nombre, probabilidad,
%                    efectividad}], texto}]  de mayor a menor Ra
%     confirmados: [{id, nombre, probabilidad}]
%     mensaje:     resumen; sin confirmados, "Sin acciones: ningún componente confirmado" y qué hacer
% Trabaja sobre el último diagnóstico (historial.pl, F10), igual que `explicar` y `recomendar_pruebas`.
%
% Ra = 1 - prod(1 - P(Cj|S) * Maj) solo sobre los componentes confirmados (noisy-OR). Las
% efectividades Maj se leen de la KB en cada petición: si cambian en hechos.pl, cambia el orden.
% RNF-01: solo entran componentes que existen en la KB, que el diagnóstico marcó como confirmados
% y cuya probabilidad sigue alcanzando tau_alto.
:- module(acciones, [acciones_correctivas/1, acciones_de/2]).
:- use_module(inferencia, [acciones_ordenadas/2]).
:- use_module(historial).
:- use_module(explicaciones, [porcentaje/2]).

:- multifile servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.
:- discontiguous servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.

servidor_json:operacion_conocida(acciones_correctivas).
servidor_json:ejecutar(acciones_correctivas, _, [R]) :- acciones_correctivas(R).

%% acciones_correctivas(-R): acciones del último diagnóstico. Sin diagnóstico -> sin_diagnostico.
acciones_correctivas(R) :-
    (   diagnostico_actual(_, Res) -> true
    ;   throw(historial_error(sin_diagnostico, "Primero genere un diagnóstico"))
    ),
    once(acciones_de(Res, R)).

%% acciones_de(+Res, -R): calcula las acciones a partir del resultado de `diagnosticar`.
acciones_de(Res, _{acciones: Acs, confirmados: Cs, mensaje: M}) :-
    confirmados_validos(Res.componentes, Conf),
    confirmados_dict(Conf, Cs),
    acciones_ordenadas(Conf, Ordenadas),                 % R9: Ra-Accion, de mayor a menor
    acciones_dict(Ordenadas, Conf, Acs),
    mensaje(Conf, Acs, Res, M).

%% confirmados_validos(+Componentes, -Conf): pares C-P de los confirmados que existen en la KB.
% Recursión sobre la lista: caso base la lista vacía; un componente que no cumple se salta.
confirmados_validos([], []).
confirmados_validos([D|Ds], [C-P|Cs]) :-
    atomo(D.id, C), atomo(D.estado, confirmado),
    componente(C, _, _, _),
    P = D.probabilidad, number(P),
    parametro(tau_alto, Alto), P >= Alto, !,
    confirmados_validos(Ds, Cs).
confirmados_validos([_|Ds], Cs) :-
    confirmados_validos(Ds, Cs).

confirmados_dict([], []).
confirmados_dict([C-P|Cs], [_{id: C, nombre: N, probabilidad: P}|Ds]) :-
    componente(C, N, _, _),
    confirmados_dict(Cs, Ds).

%% acciones_dict(+Ordenadas, +Conf, -Lista): cada acción con los confirmados que la originan.
acciones_dict([], _, []).
acciones_dict([Ra-A|As], Conf, [_{accion: A, nombre: N, relevancia: Ra, componentes: Origen,
                                  texto: T}|Ds]) :-
    accion(A, N),
    origen(Conf, A, Origen),
    texto_accion(N, Ra, Origen, T),
    acciones_dict(As, Conf, Ds).

%% origen(+Conf, +A, -Lista): los confirmados que A atiende, con su efectividad Maj.
origen([], _, []).
origen([C-P|Cs], A, [_{id: C, nombre: N, probabilidad: P, efectividad: M}|Os]) :-
    accion_componente(A, C, M), !,
    componente(C, N, _, _),
    origen(Cs, A, Os).
origen([_|Cs], A, Os) :-
    origen(Cs, A, Os).

texto_accion(N, Ra, Origen, T) :-
    porcentaje(Ra, Rt),
    partes(Origen, Ps), unir(Ps, Lista),
    format(string(T), "\"~w\" (relevancia ~s): atiende ~s.", [N, Rt, Lista]).

partes([], []).
partes([O|Os], [S|Ss]) :-
    porcentaje(O.probabilidad, Pp), efectividad_texto(O.efectividad, Mt),
    format(string(S), "\"~w\" (~s, con efectividad ~s)", [O.nombre, Pp, Mt]),
    partes(Os, Ss).

%% mensaje(+Conf, +Acs, +Res, -Texto): RNF-02, sin confirmados dice el motivo y remite a Pruebas.
mensaje([], _, Res, T) :- !,
    atomo(Res.motivo, Motivo),
    siguiente_paso(Motivo, Res, Paso),
    string_concat("Sin acciones: ningún componente confirmado. ", Paso, T).
mensaje(Conf, [], _, T) :- !,
    length(Conf, N), cantidad(N, "componente confirmado", "componentes confirmados", Ct),
    format(string(T), "Hay ~s, pero la base de conocimiento no tiene acciones registradas.", [Ct]).
mensaje(Conf, Acs, _, T) :-
    length(Conf, N), length(Acs, NA),
    cantidad(NA, "acción", "acciones", At), cantidad(N, "componente confirmado", "componentes confirmados", Ct),
    format(string(T), "~s para ~s, de mayor a menor relevancia.", [At, Ct]).

siguiente_paso(contradiccion, _, "Los síntomas son contradictorios: corríjalos y vuelva a diagnosticar.") :- !.
siguiente_paso(prueba_pendiente, Res, T) :-
    Res.pruebas_sugeridas = [D|_], !,
    format(string(T), "Registre el resultado de la prueba recomendada (\"~w\") en la pantalla Pruebas.", [D.nombre]).
siguiente_paso(_, _, T) :-
    parametro(tau_alto, A), porcentaje(A, At),
    format(string(T), "Ningún componente alcanzó el umbral de confirmación (~s); revise las pruebas recomendadas.", [At]).

% ---------- auxiliares ----------
% cantidad(+N, +Singular, +Plural, -Texto): 1 -> "1 acción"; 3 -> "3 acciones".
cantidad(1, S, _, T) :- !, format(string(T), "1 ~s", [S]).
cantidad(N, _, P, T) :- format(string(T), "~w ~s", [N, P]).

atomo(V, A) :- ( atom(V) -> A = V ; string(V) -> atom_string(A, V) ).

% efectividad_texto(+M, -T): 0.95 -> "0,95"; 0.5 -> "0,5".
efectividad_texto(M, T) :-
    format(string(S2), "~2f", [M]),
    (   sub_string(S2, _, 1, 0, "0") -> format(string(S), "~1f", [M]) ; S = S2 ),
    split_string(S, ".", "", Partes), atomic_list_concat(Partes, ',', A), atom_string(A, T).

unir([], "").
unir([A], A) :- !.
unir([A, B], T) :- !, format(string(T), "~s y ~s", [A, B]).
unir([A|As], T) :- unir(As, R), format(string(T), "~s, ~s", [A, R]).
