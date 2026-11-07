:- use_module(library(plunit)).
:- use_module('../backend/servidor_json').
:- use_module('../backend/validacion').
:- use_module('../backend/inferencia').
:- ensure_loaded('../backend/hechos').

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

% Daña la KB (quita/agrega hechos), corre Meta y la restaura.
:- meta_predicate modificada(+, +, 0).
modificada(Quitar, Agregar, Meta) :-
    setup_call_cleanup(modificar(Quitar, Agregar, U), Meta, deshacer(U)).
modificar(Quitar, Agregar, undo(Refs, Quitar)) :-
    forall(member(H, Quitar), clause(user:H, true, _)),
    forall(member(H, Quitar), (clause(user:H, true, R), erase(R))),
    findall(R, (member(H, Agregar), assertz(user:H, R)), Refs).
deshacer(undo(Refs, Quitados)) :-
    forall(member(R, Refs), erase(R)),
    forall(member(H, Quitados), assertz(user:H)).

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
    prueba_componente(P, C), !.
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

% ---------------------------------------------------------------------------
% validar_kb/0,1: detecta una KB inválida. Cada test daña la KB y la restaura.
% ---------------------------------------------------------------------------
:- begin_tests(validar_kb).


% Con Quitar/Agregar aplicados, validar_kb/1 debe reportar un problema que contenga Fragmento.
reporta(Quitar, Agregar, Fragmento) :-
    modificada(Quitar, Agregar,
               ( validar_kb(Ps), member(P, Ps), sub_string(P, _, _, _, Fragmento) )), !.

test(kb_actual_valida)      :- validar_kb([]).
test(validar_kb_0_exito)    :- validar_kb.
test(validar_kb_0_falla_si_invalida, [fail]) :-
    modificada([], [sintoma(luz_abs_encendida, dup, sintoma)], validar_kb).

test(sintoma_duplicado)    :- reporta([], [sintoma(luz_abs_encendida, dup, sintoma)], "id duplicado").
test(componente_duplicado) :- reporta([], [componente(bateria, dup, 1, 1)], "id duplicado").
test(accion_duplicada)     :- reporta([], [accion(cargar_bateria, dup)], "id duplicado").
test(prueba_duplicada)     :- reporta([], [prueba(medir_voltaje_bateria, dup)], "id duplicado").
test(fila_duplicada) :-
    reporta([], [componente_sintoma(bateria, arranque_lento, presente, 24, 48)], "id duplicado").
test(parametro_duplicado)  :- reporta([], [parametro(alpha, 2)], "id duplicado").

test(ref_componente_inexistente) :-
    reporta([], [componente_sintoma(fantasma, arranque_lento, presente, 1, 1)], "inexistente").
test(ref_sintoma_inexistente) :-
    reporta([], [componente_sintoma(bateria, fantasma, presente, 1, 1)], "inexistente").
test(ref_accion_inexistente) :-
    reporta([], [accion_componente(fantasma, bateria, 0.5)], "inexistente").
test(ref_prueba_inexistente) :-
    reporta([], [prueba_componente(fantasma, bateria)], "inexistente").
test(ref_prueba_sintoma_inexistente) :-
    reporta([], [prueba_sintoma(medir_voltaje_bateria, fantasma, 0.5)], "inexistente").

test(efectividad_fuera_de_rango) :-
    reporta([], [accion_componente(cargar_bateria, motor_arranque, 1.5)], "fuera de [0, 1]").
test(relevancia_fuera_de_rango) :-
    reporta([], [prueba_sintoma(medir_voltaje_bateria, no_arranca, -0.1)], "fuera de [0, 1]").

test(conteo_negativo_componente) :-
    reporta([componente(motor_arranque, 'Motor de arranque', 40, 960)],
            [componente(motor_arranque, 'Motor de arranque', -1, 960)], "conteo inválido").
test(conteo_no_entero_relacion) :-
    reporta([], [componente_sintoma(bateria, no_arranca, presente, 1.5, 1)], "conteo inválido").
test(conteo_excede_al_componente) :-
    reporta([], [componente_sintoma(bateria, no_arranca, presente, 41, 1)], "excede").

test(estado_invalido_sintoma) :-
    reporta([], [componente_sintoma(bateria, no_arranca, leve, 1, 1)], "estado inválido").
test(estado_invalido_hallazgo) :-
    reporta([], [componente_sintoma(bateria, hall_probar_rele_arranque, presente, 1, 1)],
            "estado inválido").
test(hallazgo_sin_tres_estados) :-
    reporta([], [componente_sintoma(bateria, hall_probar_rele_arranque, normal, 1, 1)],
            "estados").
test(estados_no_suman_conteos) :-
    reporta([componente_sintoma(rele_arranque, hall_medir_voltaje_bateria, leve, 3, 143)],
            [componente_sintoma(rele_arranque, hall_medir_voltaje_bateria, leve, 4, 143)], "suman").

test(incompatibilidad_con_sintoma_inexistente) :-
    reporta([], [incompatibilidad(no_arranca, fantasma)], "síntoma existente").
test(incompatibilidad_con_hallazgo) :-
    reporta([], [incompatibilidad(no_arranca, hall_medir_voltaje_bateria)], "síntoma existente").
test(incompatibilidad_consigo_mismo) :-
    reporta([], [incompatibilidad(no_arranca, no_arranca)], "consigo mismo").

test(parametro_faltante) :-
    reporta([parametro(alpha, 1)], [], "falta el parámetro").
test(tau_fuera_de_rango) :-
    reporta([parametro(tau_alto, 0.85)], [parametro(tau_alto, 1.5)], "tau_alto").
test(tau_bajo_no_menor_que_alto) :-
    reporta([parametro(tau_bajo, 0.05)], [parametro(tau_bajo, 0.9)], "tau_bajo").
test(max_iteraciones_invalido) :-
    reporta([parametro(max_iteraciones, 5)], [parametro(max_iteraciones, 0)], "max_iteraciones").
test(alpha_invalido) :-
    reporta([parametro(alpha, 1)], [parametro(alpha, 0)], "alpha").

test(reporta_todos_los_problemas) :-
    modificada([], [accion_componente(fantasma, bateria, 0.5), incompatibilidad(no_arranca, no_arranca)],
               ( validar_kb(Ps), length(Ps, N), N >= 2 )).
test(la_kb_queda_restaurada) :-
    aggregate_all(count, componente(_,_,_,_), A),
    ( modificada([], [componente(bateria, dup, 1, 1)], true) -> true ; true ),
    aggregate_all(count, componente(_,_,_,_), A).
:- end_tests(validar_kb).

% ---------------------------------------------------------------------------
% RNF-02: una KB inválida no arranca en silencio (kb_invalida).
% ---------------------------------------------------------------------------

:- begin_tests(servidor_kb).
% Sin notación R.campo dentro de metallamadas: se expandiría antes de ejecutarlas.
ping(Id, R) :-
    format(string(L), "{\"id\":~w,\"op\":\"ping\",\"args\":{}}", [Id]),
    procesar_linea(L, R).
estado(R, E) :- get_dict(estado, R, E).
codigo(R, C) :- get_dict(error, R, Er), get_dict(codigo, Er, C).
rota([accion_componente(fantasma, bateria, 0.5)]).

test(servidor_carga_la_kb) :- sintoma(luz_abs_encendida, _, _).
test(kb_valida_ping_ok) :- ping(1, R), estado(R, ok).
test(kb_invalida_responde_error) :-
    rota(H),
    modificada([], H, ( ping(7, R), get_dict(id, R, 7), estado(R, error),
                        codigo(R, kb_invalida), get_dict(resultados, R, []) )).
test(kb_invalida_lista_los_problemas) :-
    rota(H),
    modificada([], H, ( ping(1, R), get_dict(error, R, Er),
                        get_dict(problemas, Er, Ps), is_list(Ps), Ps \== [],
                        member(P, Ps), sub_string(P, _, _, _, "fantasma"),
                        get_dict(mensaje, Er, M), string(M) )).
test(kb_invalida_serializa_a_json) :-
    rota(H),
    modificada([], H,
        ( ping(1, R),
          with_output_to(string(S), json_write_dict(current_output, R, [width(0)])),
          sub_string(S, _, _, _, "\"kb_invalida\""), sub_string(S, _, _, _, "\"problemas\":"), sub_string(S, _, _, _, "fantasma"), ! )).
test(kb_invalida_afecta_a_toda_operacion_conocida) :-
    rota(H),
    modificada([], H, ( ping(1, R1), codigo(R1, kb_invalida),
                        procesar_linea("{\"id\":2,\"op\":\"ping\"}", R2),
                        codigo(R2, kb_invalida) )).
test(mensajes_mal_formados_conservan_su_error) :-
    rota(H),
    modificada([], H,
        ( procesar_linea("{no es json", R1), codigo(R1, json_invalido),
          procesar_linea("{\"id\":4,\"op\":\"xyz\"}", R2), codigo(R2, op_desconocida),
          procesar_linea("{\"id\":5,\"op\":\"ping\",\"args\":[1]}", R3),
          codigo(R3, args_invalidos) )).
test(se_recupera_al_arreglar_la_kb) :-
    rota(H),
    modificada([], H, ( ping(1, R1), estado(R1, error) )),
    ping(2, R2), estado(R2, ok).
test(validar_en_cada_peticion_es_rapido) :-
    statistics(cputime, T0),
    forall(between(1, 20, I), ( ping(I, R), estado(R, ok) )),
    statistics(cputime, T1), T1 - T0 < 5.
:- end_tests(servidor_kb).

% ---------------------------------------------------------------------------
% PDF §6: con los conteos de la KB, Naive Bayes + Laplace reproduce la traza.
% (Cálculo propio del test: el motor real llega en F02.)
% ---------------------------------------------------------------------------
:- begin_tests(pdf_seccion6).
lr(C, S, E, LR) :-
    componente(C, _, Np, Nn), componente_sintoma(C, S, E, P, N),
    sintoma(S, _, T), ( T == sintoma -> V = 2 ; V = 3 ),
    LR is ((P + 1) / (Np + V)) / ((N + 1) / (Nn + V)).
% P(C | evidencia) en odds; un síntoma sin fila para C no aporta (queda el prior).
prob(C, Evidencia, P) :-
    componente(C, _, Np, Nn), Pr is (Np + 1) / (Np + Nn + 2),
    foldl([S-E, O0, O]>>( lr(C, S, E, L) -> O is O0 * L ; O = O0 ),
          Evidencia, Pr / (1 - Pr), Odds),
    P is Odds / (1 + Odds).
cerca(X, Y, Tol) :- abs(X - Y) =< Tol.

entrada([chirrido_frenos-presente, pedal_freno_esponjoso-presente]).

test(estado_inicial_63_44_31,
     [forall(member(C-Esp, [pastillas_freno-0.63, liquido_frenos-0.44, discos_freno-0.31]))]) :-
    entrada(X), prob(C, X, P), cerca(P, Esp, 0.02).
test(lr_ruido_y_pedal,
     [forall(member(C-S-Esp, [discos_freno-chirrido_frenos-1.97, pastillas_freno-chirrido_frenos-3.7,
                              liquido_frenos-chirrido_frenos-0.8,
                              discos_freno-pedal_freno_esponjoso-0.9, pastillas_freno-pedal_freno_esponjoso-0.7,
                              liquido_frenos-pedal_freno_esponjoso-9.0]))]) :-
    lr(C, S, presente, L), cerca(L, Esp, 0.06 * Esp + 0.02).
test(el_orden_inicial_es_pastillas_liquido_discos) :-
    entrada(X), prob(pastillas_freno, X, A), prob(liquido_frenos, X, B), prob(discos_freno, X, D),
    A > B, B > D.
test(iteracion_1_pastillas_refutada) :-
    entrada(X),
    prob(pastillas_freno, [hall_medir_espesor_pastillas_freno-normal|X], P),
    cerca(P, 0.039, 0.005), P =< 0.05.
test(iteracion_2_liquido_confirmado) :-
    entrada(X),
    prob(liquido_frenos, [hall_revisar_nivel_estado_liquido_frenos-severo|X], P),
    cerca(P, 0.93, 0.02), P >= 0.85.
test(iteracion_3_discos_descartado) :-
    entrada(X),
    prob(discos_freno, [hall_inspeccionar_disco_rayaduras_alabeo-normal|X], P),
    cerca(P, 0.025, 0.005), P =< 0.05.
test(acciones_del_resultado_final) :-
    accion_componente(purgar_cambiar_liquido_frenos, liquido_frenos, M1),
    accion_componente(revisar_fugas_circuito_frenos, liquido_frenos, M2),
    cerca(1 - (1 - 0.93 * M1), 0.88, 0.01),
    cerca(1 - (1 - 0.93 * M2), 0.47, 0.01), !.
:- end_tests(pdf_seccion6).

% ---------------------------------------------------------------------------
% F02 capa 1: Naive Bayes + Laplace en log-odds (backend/inferencia.pl).
% ---------------------------------------------------------------------------
:- begin_tests(capa1).
cerca(X, Y, Tol) :- abs(X - Y) =< Tol.
entrada([chirrido_frenos-presente, pedal_freno_esponjoso-presente]).

test(estado_inicial_63_44_31,
     [forall(member(C-Esp, [pastillas_freno-0.63, liquido_frenos-0.44, discos_freno-0.31]))]) :-
    entrada(X), probabilidad(C, X, P), cerca(P, Esp, 0.02),
    estado_componente(P, incierto).
test(verosimilitud_laplace) :-
    verosimilitud(liquido_frenos, pedal_freno_esponjoso, presente, PP-PN),
    cerca(PP, 86/101, 1.0e-9), cerca(PN, 85/903, 1.0e-9).
test(hallazgo_usa_tres_estados) :-      % |Vi| = 3
    componente_sintoma(pastillas_freno, hall_medir_espesor_pastillas_freno, normal, P, N),
    componente(pastillas_freno, _, Np, Nn),
    verosimilitud(pastillas_freno, hall_medir_espesor_pastillas_freno, normal, PP-PN),
    cerca(PP, (P + 1) / (Np + 3), 1.0e-9), cerca(PN, (N + 1) / (Nn + 3), 1.0e-9), !.
test(iteracion_1_pastillas_refutada) :-
    entrada(X),
    probabilidad(pastillas_freno, [hall_medir_espesor_pastillas_freno-normal|X], P),
    cerca(P, 0.039, 0.005), estado_componente(P, descartado).
test(iteracion_2_liquido_confirmado) :-
    entrada(X),
    probabilidad(liquido_frenos, [hall_revisar_nivel_estado_liquido_frenos-severo|X], P),
    cerca(P, 0.93, 0.02), estado_componente(P, confirmado).
test(iteracion_3_discos_descartado) :-
    entrada(X),
    probabilidad(discos_freno, [hall_inspeccionar_disco_rayaduras_alabeo-normal|X], P),
    cerca(P, 0.025, 0.005), estado_componente(P, descartado).
test(desconocido_no_entra) :-
    entrada(X), probabilidad(pastillas_freno, X, P),
    probabilidad(pastillas_freno, [luz_abs_encendida-desconocido|X], P).
test(ausente_excluye) :-
    probabilidad(pastillas_freno, [chirrido_frenos-ausente], A),
    probabilidad(pastillas_freno, [], Prior), A < Prior.
test(sintoma_sin_fila_no_aporta) :-
    probabilidad(discos_freno, [], P0),
    probabilidad(discos_freno, [luz_abs_encendida-presente], P0).
test(contribuciones_explican_el_logit) :-
    entrada(X), contribuciones(liquido_frenos, X, Cs),
    memberchk(pedal_freno_esponjoso-L, Cs), cerca(L, log(9.0), 0.1).
test(sin_ln_cero_con_conteos_extremos) :-
    modificada([componente_sintoma(liquido_frenos, chirrido_frenos, presente, 19, 225)],
               [componente_sintoma(liquido_frenos, chirrido_frenos, presente, 0, 0)],
               ( contribucion(liquido_frenos, chirrido_frenos, ausente, L), number(L) )).
test(cambiar_un_conteo_cambia_el_resultado) :-
    entrada(X), probabilidad(liquido_frenos, X, P0),
    modificada([componente_sintoma(liquido_frenos, pedal_freno_esponjoso, presente, 85, 84)],
               [componente_sintoma(liquido_frenos, pedal_freno_esponjoso, presente, 10, 84)],
               ( probabilidad(liquido_frenos, X, P1), P1 < P0 )).
test(umbrales, [forall(member(P-E, [0.85-confirmado, 0.9-confirmado, 0.05-descartado,
                                    0.01-descartado, 0.5-incierto]))]) :-
    estado_componente(P, E).
:- end_tests(capa1).

% ---------------------------------------------------------------------------
% F02 capas 2 y 3: noisy-OR (pruebas y acciones).
% ---------------------------------------------------------------------------
:- begin_tests(capas23).
cerca(X, Y, Tol) :- abs(X - Y) =< Tol.
entrada([chirrido_frenos-presente, pedal_freno_esponjoso-presente]).

test(rp_un_sintoma_presente) :-
    relevancia_prueba(medir_espesor_pastillas_freno, [chirrido_frenos-presente], R),
    cerca(R, 0.70, 1.0e-9).
test(rp_noisy_or_de_dos_sintomas) :-      % 1 - (1-0.70)(1-0.70) = 0.91
    relevancia_prueba(medir_espesor_pastillas_freno,
                      [chirrido_frenos-presente, pedal_freno_pulsa-presente], R),
    cerca(R, 0.91, 1.0e-9).
test(rp_solo_cuentan_los_presentes) :-
    relevancia_prueba(medir_espesor_pastillas_freno,
                      [chirrido_frenos-ausente, pedal_freno_pulsa-desconocido], R),
    R =:= 0.
test(rp_prueba_inexistente_falla, [fail]) :-
    relevancia_prueba(no_existe, [], _).
test(pruebas_ordenadas_y_sin_las_hechas) :-
    entrada(X),
    pruebas_del_componente(pastillas_freno, X, [], L),
    L = [R1-medir_espesor_pastillas_freno|_], R1 > 0,
    pruebas_del_componente(pastillas_freno, X, [medir_espesor_pastillas_freno], L2),
    \+ memberchk(_-medir_espesor_pastillas_freno, L2),
    msort(L, M), reverse(M, Desc), pairs_keys(Desc, Ks), pairs_keys(L, Ks).
test(ra_del_pdf_88_y_47) :-
    Conf = [liquido_frenos-0.93],
    relevancia_accion(purgar_cambiar_liquido_frenos, Conf, A),
    relevancia_accion(revisar_fugas_circuito_frenos, Conf, B),
    cerca(A, 0.88, 0.01), cerca(B, 0.47, 0.01).
test(ra_sin_confirmados_es_cero) :-
    relevancia_accion(purgar_cambiar_liquido_frenos, [], R), R =:= 0.
test(ra_ignora_componentes_que_la_accion_no_atiende) :-
    relevancia_accion(purgar_cambiar_liquido_frenos, [pastillas_freno-0.99], R), R =:= 0.
test(ra_noisy_or_de_dos_componentes) :-   % 1 - (1-0.9*0.8)(1-0.9*0.5)
    accion_componente(rellenar_liquido_embrague, cilindro_maestro_embrague, M1),
    accion_componente(rellenar_liquido_embrague, cilindro_esclavo_embrague, M2),
    relevancia_accion(rellenar_liquido_embrague,
                      [cilindro_maestro_embrague-0.9, cilindro_esclavo_embrague-0.9], R),
    cerca(R, 1 - (1 - 0.9 * M1) * (1 - 0.9 * M2), 1.0e-9), !.
test(acciones_ordenadas_de_mayor_a_menor) :-
    acciones_ordenadas([liquido_frenos-0.93], L),
    L = [R1-purgar_cambiar_liquido_frenos, R2-_|_], R1 >= R2,
    \+ ( member(R-_, L), R =< 0 ).
:- end_tests(capas23).
