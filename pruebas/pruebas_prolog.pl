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

% ---------------------------------------------------------------------------
% Integridad general de la KB (lo que luego comprobará validar_kb/0).
% ---------------------------------------------------------------------------
:- begin_tests(kb_integridad).

sin_duplicados(Plantilla, Id, Meta) :-
    findall(Id, (Meta, Plantilla), Ids),
    msort(Ids, Orden), sort(Orden, Unicos),
    length(Orden, N), length(Unicos, N).

test(minimo_diez_por_categoria,
     [forall(member(G-N, [sintoma(_,_,sintoma)-10, sintoma(_,_,hallazgo)-10,
                          componente(_,_,_,_)-10, accion(_,_)-10, prueba(_,_)-10]))]) :-
    aggregate_all(count, G, C), C >= N.
test(ids_sintoma_unicos)    :- sin_duplicados(true, S, sintoma(S,_,_)).
test(ids_componente_unicos) :- sin_duplicados(true, C, componente(C,_,_,_)).
test(ids_accion_unicos)     :- sin_duplicados(true, A, accion(A,_)).
test(ids_prueba_unicos)     :- sin_duplicados(true, P, prueba(P,_)).
test(filas_componente_sintoma_unicas) :-
    sin_duplicados(true, C-S-E, componente_sintoma(C,S,E,_,_)).
test(filas_prueba_sintoma_unicas) :- sin_duplicados(true, P-S, prueba_sintoma(P,S,_)).
test(filas_prueba_componente_unicas) :- sin_duplicados(true, P-C, prueba_componente(P,C)).
test(filas_accion_componente_unicas) :- sin_duplicados(true, A-C, accion_componente(A,C,_)).

test(tipo_de_sintoma_valido, [forall(sintoma(_, _, T))]) :- memberchk(T, [sintoma, hallazgo]).
test(nombres_no_vacios, [forall(member(G, [sintoma(_,N,_), componente(_,N,_,_),
                                           accion(_,N), prueba(_,N)]))]) :-
    forall(G, (atom(N), N \== '')).

test(referencias_componente_sintoma, [forall(componente_sintoma(C, S, _, _, _))]) :-
    componente(C, _, _, _), sintoma(S, _, _).
test(referencias_accion_componente, [forall(accion_componente(A, C, _))]) :-
    accion(A, _), componente(C, _, _, _).
test(referencias_prueba_sintoma, [forall(prueba_sintoma(P, S, _))]) :-
    prueba(P, _), sintoma(S, _, sintoma).
test(referencias_prueba_componente, [forall(prueba_componente(P, C))]) :-
    prueba(P, _), componente(C, _, _, _).
test(referencias_incompatibilidad, [forall(incompatibilidad(A, B))]) :-
    sintoma(A, _, sintoma), sintoma(B, _, sintoma).

test(efectividad_en_rango, [forall(accion_componente(_, _, M))]) :- number(M), M >= 0, M =< 1.
test(relevancia_en_rango, [forall(prueba_sintoma(_, _, A))])     :- number(A), A >= 0, A =< 1.
test(conteos_componente_validos, [forall(componente(_, _, Np, Nn))]) :-
    integer(Np), integer(Nn), Np >= 0, Nn >= 0, Np + Nn > 0.
test(prior_componente_en_rango, [forall(componente(_, _, Np, Nn))]) :-
    P is (Np + 1) / (Np + Nn + 2), P > 0, P < 1.
test(conteos_relacion_validos, [forall(componente_sintoma(C, _, _, P, N))]) :-
    integer(P), integer(N), P >= 0, N >= 0,
    componente(C, _, Np, Nn), P =< Np, N =< Nn.

test(estado_segun_tipo, [forall(componente_sintoma(_, S, E, _, _))]) :-
    sintoma(S, _, T),
    (   T == sintoma -> E == presente ; memberchk(E, [normal, leve, severo]) ).
test(hallazgo_con_tres_estados,
     [forall((componente(C, _, _, _), sintoma(H, _, hallazgo), componente_sintoma(C, H, _, _, _)))]) :-
    findall(E, componente_sintoma(C, H, E, _, _), Es),
    msort(Es, [leve, normal, severo]).

test(cada_prueba_tiene_hallazgo, [forall(prueba(P, _))]) :-
    atom_concat(hall_, P, H), sintoma(H, _, hallazgo).
test(cada_hallazgo_tiene_prueba, [forall(sintoma(H, _, hallazgo))]) :-
    atom_concat(hall_, P, H), prueba(P, _).
test(cada_prueba_verifica_algun_componente, [forall(prueba(P, _))]) :-
    prueba_componente(P, _), !.
test(cada_prueba_cubre_algun_sintoma, [forall(prueba(P, _))]) :-
    prueba_sintoma(P, _, _), !.
test(cada_componente_tiene_accion, [forall(componente(C, _, _, _))]) :-
    accion_componente(_, C, _), !.
test(cada_componente_tiene_relacion_con_sintoma, [forall(componente(C, _, _, _))]) :-
    componente_sintoma(C, _, _, _, _), !.
test(cada_sintoma_aparece_en_alguna_relacion, [forall(sintoma(S, _, sintoma))]) :-
    componente_sintoma(_, S, _, _, _), !.
test(cada_accion_sirve_a_algun_componente, [forall(accion(A, _))]) :-
    accion_componente(A, _, _), !.
:- end_tests(kb_integridad).

% ---------------------------------------------------------------------------
% Sistema de frenos y priors del PDF §6 (Pastillas 0,40 · Discos 0,20 · Líquido 0,10).
% ---------------------------------------------------------------------------
:- begin_tests(frenos).
prior(C, P) :- componente(C, _, Np, Nn), P is (Np + 1) / (Np + Nn + 2).

test(sintomas_de_frenos, [forall(member(S, [chirrido_frenos, pedal_freno_esponjoso]))]) :-
    sintoma(S, _, sintoma).
test(componentes_de_frenos, [forall(member(C, [pastillas_freno, discos_freno, liquido_frenos]))]) :-
    componente(C, _, _, _), accion_componente(_, C, _), !.
test(priors_del_pdf, [forall(member(C-Esperado, [pastillas_freno-0.40, discos_freno-0.20,
                                                  liquido_frenos-0.10]))]) :-
    prior(C, P), abs(P - Esperado) < 0.005.
test(frenos_se_relacionan_con_sus_sintomas,
     [forall(member(S, [chirrido_frenos, pedal_freno_esponjoso]))]) :-
    componente_sintoma(C, S, presente, _, _),
    memberchk(C, [pastillas_freno, discos_freno, liquido_frenos]), !.
:- end_tests(frenos).
