% F07 · Pruebas adicionales (issue #59; PDF §4 reglas R7-R8, paso 13; RF-08).
%
% Operaciones del contrato JSON (ver README):
%   recomendar_pruebas {}                          -> [ {pendiente, del_foco, otras, realizadas,
%                                                        mensaje, iteraciones, max_iteraciones} ]
%   registrar_resultado_prueba {prueba, resultado} -> [ diagnóstico nuevo (como `diagnosticar`)
%                                                        + hallazgo:{id, prueba, resultado} ]
% Las dos trabajan sobre el último `diagnosticar` que recuerda historial.pl (F10).
%
% Decisión: solo se registra el resultado de la prueba PENDIENTE (la que el ciclo recomienda
% ahora). El motor aplica un hallazgo únicamente cuando R7 pide esa prueba, así que registrar otra
% no cambiaría nada y quedaría como "hallazgo no aplicado".
% RNF-01: con cualquier error (prueba inexistente, resultado inválido, ya registrada, no pendiente)
% se lanza la excepción antes de tocar el diagnóstico recordado: el estado anterior queda igual.
:- module(pruebas_adicionales, [recomendar_pruebas/1, registrar_resultado_prueba/3,
                                resultados_posibles/2]).
:- use_module(reglas).
:- use_module(inferencia, [pruebas_del_componente/4]).
:- use_module(sistemas).
:- use_module(historial).
:- use_module(explicaciones).
:- use_module(ops_sintomas, [arg_texto/3]).

:- multifile servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.
:- discontiguous servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.

servidor_json:operacion_conocida(recomendar_pruebas).
servidor_json:operacion_conocida(registrar_resultado_prueba).

servidor_json:ejecutar(recomendar_pruebas, _, [R]) :- recomendar_pruebas(R).
servidor_json:ejecutar(registrar_resultado_prueba, Args, [R]) :-
    arg_texto(Args, prueba, Pt), arg_texto(Args, resultado, Rt),
    atom_string(P, Pt), atom_string(Est, Rt),
    registrar_resultado_prueba(P, Est, R).

% ------------------------------------------------------------ recomendar --

%% recomendar_pruebas(-R): la prueba pendiente, las demás del mismo componente, las de otros
% candidatos y las ya realizadas.
% Sin diagnóstico calculado -> historial_error(sin_diagnostico, ...), como `explicar`.
recomendar_pruebas(R) :-
    actual(Entrada, Res),
    once(recomendar(Entrada, Res, R)).            % un solo resultado: se cierran los puntos de elección

recomendar(Entrada, Res, _{pendiente: Pend, del_foco: Foco, otras: Otras, realizadas: Hechas,
                           mensaje: M, iteraciones: Res.iteraciones, max_iteraciones: Max}) :-
    max_iteraciones(Res, Max),
    pruebas_texto(Res.pruebas_sugeridas, Entrada, Sug),
    (   Res.motivo == prueba_pendiente, Sug = [P0|Otras0]
    ->  tarjeta(P0, Pend), M = P0.texto
    ;   Pend = null, Otras0 = Sug, mensaje_sin_pendiente(Res, Max, M)
    ),
    otras(Otras0, Otras),
    del_foco(Pend, Entrada, Res.pruebas_hechas, Foco),
    realizadas(Res.pruebas_hechas, Entrada, Hechas).

%% del_foco(+Pendiente, +Entrada, +Hechas, -Lista): las otras pruebas que verifican el componente en
% foco (prueba_componente/2), de mayor a menor Rp, sin la pendiente ni las ya realizadas. Si el foco
% sigue incierto después de la pendiente, R7 pedirá la primera de esta lista.
del_foco(null, _, _, []) :- !.
del_foco(Pend, Entrada, Hechas, L) :-
    C = Pend.componente,
    pruebas_del_componente(C, Entrada, [Pend.prueba|Hechas], Rps),
    sugeridas_de(Rps, C, Ds),
    pruebas_texto(Ds, Entrada, Ts),
    otras(Ts, L).

%% sugeridas_de(+RpPruebas, +C, -Dicts): Rp-Prueba al formato de pruebas_sugeridas (recursión).
sugeridas_de([], _, []).
sugeridas_de([Rp-P|Ps], C, [_{prueba: P, nombre: N, componente: C, relevancia: Rp}|Ds]) :-
    prueba(P, N),
    sugeridas_de(Ps, C, Ds).

max_iteraciones(Res, Max) :-
    ( get_dict(max_iteraciones, Res, Max) -> true ; parametro(max_iteraciones, Max) ).

%% tarjeta(+Sugerida, -Pendiente): la prueba pendiente con su componente y los resultados válidos.
tarjeta(D, _{prueba: D.prueba, nombre: D.nombre, componente: D.componente, nombre_componente: Nc,
             relevancia: D.relevancia, resultados: Rs, texto: D.texto}) :-
    componente(D.componente, Nc, _, _),
    resultados_posibles(D.prueba, Rs).

%% otras(+Sugeridas, -Lista): las pruebas de los demás candidatos (recursión sobre la lista).
% Caso base: lista vacía. Cada elemento agrega el nombre del componente que verifica.
otras([], []).
otras([D|Ds], [_{prueba: D.prueba, nombre: D.nombre, componente: D.componente,
                 nombre_componente: Nc, relevancia: D.relevancia, texto: D.texto}|Os]) :-
    componente(D.componente, Nc, _, _),
    otras(Ds, Os).

%% realizadas(+Hechas, +Entrada, -Lista): pruebas aplicadas por el motor, en orden, con su resultado.
% Caso base: no quedan pruebas. El resultado se busca en la entrada (hall_<prueba>-Estado).
realizadas([], _, []).
realizadas([P|Ps], Entrada, [_{prueba: P, nombre: N, componente: C, nombre_componente: Nc,
                               resultado: Est}|Rs]) :-
    prueba(P, N),
    prueba_componente(P, C), componente(C, Nc, _, _), !,   % la primera fila basta para mostrarla
    atom_concat(hall_, P, Hall), memberchk(Hall-Est, Entrada),
    realizadas(Ps, Entrada, Rs).

%% mensaje_sin_pendiente(+Res, +Max, -Texto): RNF-02, por qué no hay prueba que hacer.
mensaje_sin_pendiente(Res, Max, T) :-
    motivo_atomo(Res, M),
    texto_motivo(M, Res.iteraciones, Max, T).

motivo_atomo(Res, M) :- V = Res.motivo, ( atom(V) -> M = V ; atom_string(M, V) ).

texto_motivo(sin_inciertos, _, _, "No hacen falta más pruebas: no quedan hipótesis abiertas por investigar.") :- !.
texto_motivo(max_iteraciones, _, Max, T) :- !,
    format(string(T), "Se alcanzó el máximo de ~w iteraciones; no se recomiendan más pruebas. El diagnóstico no es concluyente.", [Max]).
texto_motivo(sin_pruebas, _, _, "No quedan pruebas disponibles para los componentes inciertos; el diagnóstico no es concluyente.") :- !.
texto_motivo(contradiccion, _, _, "Los síntomas son contradictorios; resuelva la contradicción antes de hacer pruebas.") :- !.
texto_motivo(_, _, _, "No hay pruebas recomendadas en este momento.").

%% resultados_posibles(+Prueba, -Estados): los estados de su hallazgo en la KB (normal, leve, severo).
resultados_posibles(P, Rs) :-
    atom_concat(hall_, P, Hall),
    findall(E, ( member(E, [normal, leve, severo]),
                 once(componente_sintoma(_, Hall, E, _, _)) ), Rs).

% ------------------------------------------------------------- registrar --

%% registrar_resultado_prueba(+Prueba, +Estado, -R): agrega hall_<Prueba>-Estado a la entrada del
% último diagnóstico y vuelve a ejecutar el ciclo (R8 -> R2..R4). R es el diagnóstico nuevo,
% enriquecido como el de `diagnosticar`, con la clave `hallazgo`.
registrar_resultado_prueba(P, Est, R) :-
    actual(Entrada, Res),
    validar_registro(P, Est, Entrada, Res),
    atom_concat(hall_, P, Hall),
    append(Entrada, [Hall-Est], Entrada1),
    validar_entrada(Entrada1, Problemas),
    (   Problemas \== [] -> throw(entrada_invalida(Problemas)) ; true ),
    once(diagnosticar(Entrada1, R0)),
    enriquecer_diagnostico(R0, R1),
    recordar_diagnostico(Entrada1, R1),                  % solo aquí cambia el estado
    R = R1.put(hallazgo, _{id: Hall, prueba: P, resultado: Est}).

%% validar_registro(+P, +Est, +Entrada, +Res): lanza el primer error que encuentra.
validar_registro(P, _, _, _) :-
    \+ prueba(P, _), !,
    format(string(M), "prueba inexistente: ~w", [P]),
    throw(entrada_invalida([M])).
validar_registro(P, Est, _, _) :-
    resultados_posibles(P, Rs), \+ memberchk(Est, Rs), !,
    atomic_list_concat(Rs, ', ', Lista),
    format(string(M), "resultado inválido para ~w: ~w (válidos: ~w)", [P, Est, Lista]),
    throw(entrada_invalida([M])).
validar_registro(P, _, Entrada, _) :-
    atom_concat(hall_, P, Hall), memberchk(Hall-_, Entrada), !,
    prueba(P, N),
    format(string(M), "Ya se registró el resultado de \"~w\".", [N]),
    throw(error_contrato(ya_registrada, M)).
validar_registro(P, _, _, Res) :-
    \+ pendiente(Res, P), !,
    (   pendiente(Res, Q), prueba(Q, Nq)
    ->  format(string(M), "La prueba recomendada ahora es \"~w\"; registre primero su resultado.", [Nq])
    ;   M = "No hay ninguna prueba pendiente para este diagnóstico."
    ),
    throw(error_contrato(prueba_no_pendiente, M)).
validar_registro(_, _, _, _).

%% pendiente(+Res, -P): la prueba que el ciclo dejó pendiente (la primera sugerida).
pendiente(Res, P) :-
    motivo_atomo(Res, prueba_pendiente),
    Res.pruebas_sugeridas = [D|_],
    V = D.prueba, ( atom(V) -> P = V ; atom_string(P, V) ).

actual(Entrada, Res) :-
    (   diagnostico_actual(Entrada, Res) -> true
    ;   throw(historial_error(sin_diagnostico, "Primero genere un diagnóstico"))
    ).
