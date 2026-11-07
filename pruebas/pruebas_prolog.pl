:- use_module(library(plunit)).
:- use_module('../backend/servidor_json').

:- begin_tests(contrato_base).
test(ping) :-
    procesar_linea("{\"id\":1,\"op\":\"ping\",\"args\":{}}", R),
    R.id == 1, R.estado == ok, R.resultados = [P], P.mensaje == "pong".
test(ping_sin_args) :-
    procesar_linea("{\"id\":2,\"op\":\"ping\"}", R), R.estado == ok.
test(json_invalido) :-
    procesar_linea("{no es json", R),
    R.estado == error, R.error.codigo == json_invalido.
test(sin_op) :-
    procesar_linea("{\"id\":3}", R), R.error.codigo == json_invalido.
test(op_desconocida) :-
    procesar_linea("{\"id\":4,\"op\":\"xyz\",\"args\":{}}", R),
    R.id == 4, R.error.codigo == op_desconocida.
test(args_invalidos) :-
    procesar_linea("{\"id\":5,\"op\":\"ping\",\"args\":[1]}", R),
    R.error.codigo == args_invalidos.
:- end_tests(contrato_base).

:- consult('../backend/hechos').

:- begin_tests(parametros).
test(valores_del_issue, [forall(member(N-V, [tau_alto-0.85, tau_bajo-0.05,
                                             max_iteraciones-5, alpha-1]))]) :-
    parametro(N, V).
test(sin_duplicados, [forall(member(N, [tau_alto, tau_bajo, max_iteraciones, alpha]))]) :-
    findall(V, parametro(N, V), [_]).
:- end_tests(parametros).

:- begin_tests(incompatibilidades).
test(al_menos_cuatro) :-
    aggregate_all(count, incompatibilidad(_, _), N), N >= 4.
test(extremos_son_sintomas, [forall(incompatibilidad(A, B))]) :-
    sintoma(A, _, sintoma), sintoma(B, _, sintoma), A \== B.
test(sin_pares_repetidos, [forall(incompatibilidad(A, B))]) :-
    \+ incompatibilidad(B, A),
    findall(x, incompatibilidad(A, B), [_]).
:- end_tests(incompatibilidades).

:- begin_tests(arranque).
componente_arranque(rele_arranque).
componente_arranque(solenoide_arranque).
componente_arranque(circuito_control_arranque).

test(existe, [forall(componente_arranque(C))]) :- componente(C, _, 40, 960).
test(tiene_sintomas, [forall(componente_arranque(C))]) :-
    componente_sintoma(C, S, presente, _, _), sintoma(S, _, sintoma), !.
test(tiene_accion, [forall(componente_arranque(C))]) :-
    accion_componente(A, C, _), accion(A, _), !.
test(tiene_prueba_propia, [forall(componente_arranque(C))]) :-
    prueba_componente(P, C), P \== medir_voltaje_bateria, prueba(P, _), !.
test(voltaje_adecuado_los_distingue, [forall(componente_arranque(C))]) :-
    prueba_componente(medir_voltaje_bateria, C),
    componente_sintoma(C, hall_medir_voltaje_bateria, normal, NP, _),
    componente_sintoma(bateria, hall_medir_voltaje_bateria, normal, BP, _),
    NP > BP, !.

% Reglas generales de los hallazgos (sirven de red de seguridad para toda la KB).
test(estados_suman_conteos_del_componente,
     [forall((componente(C, _, Np, Nn), sintoma(H, _, hallazgo),
              componente_sintoma(C, H, _, _, _)))]) :-
    aggregate_all(sum(P), componente_sintoma(C, H, _, P, _), Np),
    aggregate_all(sum(N), componente_sintoma(C, H, _, _, N), Nn).
test(fila_de_hallazgo_tiene_prueba_componente,
     [forall((componente_sintoma(C, H, _, _, _), sintoma(H, _, hallazgo),
              atom_concat(hall_, P, H)))]) :-
    prueba_componente(P, C).
:- end_tests(arranque).
