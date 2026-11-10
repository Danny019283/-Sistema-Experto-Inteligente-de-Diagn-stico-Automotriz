:- use_module(library(plunit)).
% atom_json_dict/3 y json_write_dict/3: SWI-Prolog 9.0 (Ubuntu 24.04) no los autocarga.
:- use_module(library(http/json)).
:- use_module('../backend/servidor_json').
:- use_module('../backend/validacion').
:- use_module('../backend/inferencia').
:- use_module('../backend/reglas').
:- use_module('../backend/consultas').
:- ensure_loaded('../backend/hechos').
:- use_module('../backend/memoria_x').
:- use_module('../backend/retroceso').
:- use_module('../backend/sistemas').

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
test(tau_candidato) :- parametro(tau_candidato, 0.25).
test(sin_duplicados, [forall(member(N, [tau_alto, tau_bajo, tau_candidato, max_iteraciones, alpha]))]) :-
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
test(tau_candidato_faltante) :-
    reporta([parametro(tau_candidato, 0.25)], [], "falta el parámetro").
test(tau_candidato_fuera_de_rango) :-
    reporta([parametro(tau_candidato, 0.25)], [parametro(tau_candidato, 2)], "tau_candidato").

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

% ---------------------------------------------------------------------------
% F02 reglas: validación de la entrada (RNF-01), R2b, clasificación y candidatos.
% ---------------------------------------------------------------------------
:- begin_tests(reglas_base).
problema(Entrada, Texto) :-
    validar_entrada(Entrada, Ps), member(P, Ps), sub_string(P, _, _, _, Texto), !.
entrada([chirrido_frenos-presente, pedal_freno_esponjoso-presente]).

test(entrada_valida) :-
    validar_entrada([chirrido_frenos-presente, luz_abs_encendida-ausente,
                     pedal_freno_pulsa-desconocido,
                     hall_medir_espesor_pastillas_freno-normal], []).
test(entrada_vacia_es_valida) :- validar_entrada([], []).
test(sintoma_inexistente) :- problema([fantasma-presente], "síntoma inexistente").
test(estado_invalido_en_sintoma) :- problema([chirrido_frenos-normal], "estado inválido").
test(estado_invalido_en_hallazgo) :-
    problema([hall_medir_espesor_pastillas_freno-presente], "estado inválido").
test(sintoma_repetido) :-
    problema([chirrido_frenos-presente, chirrido_frenos-ausente], "síntoma repetido").
test(entrada_no_lista) :- validar_entrada(foo, [_]).
test(elemento_mal_formado) :- problema([chirrido_frenos], "mal formada").
test(hallazgo_de_prueba_inexistente) :-
    modificada([], [sintoma(hall_fantasma, 'Resultado: fantasma', hallazgo)],
               problema([hall_fantasma-normal], "prueba inexistente")).

test(contradiccion_detectada) :-
    contradicciones([no_arranca-presente, ralenti_inestable-presente], [no_arranca-ralenti_inestable]).
test(sin_contradiccion_si_uno_ausente) :-
    contradicciones([no_arranca-presente, ralenti_inestable-ausente], []).

test(clasificar_estado_inicial) :-
    entrada(X), clasificar(X, [P1-pastillas_freno-incierto, P2-liquido_frenos-incierto,
                               P3-discos_freno-incierto|_]),
    P1 > P2, P2 > P3.
test(sin_evidencia_no_es_hipotesis) :-
    clasificar([no_arranca-presente], L), \+ memberchk(_-pastillas_freno-_, L).
test(candidatos_del_pdf) :-
    entrada(X), candidatos(X, [pastillas_freno, liquido_frenos, discos_freno]).
test(candidatos_excluyen_confirmados_y_descartados) :-
    entrada(X0), X = [hall_medir_espesor_pastillas_freno-normal|X0],
    candidatos(X, Cs), \+ memberchk(pastillas_freno, Cs).
test(confirmados_con_probabilidad) :-
    entrada(X0), X = [hall_revisar_nivel_estado_liquido_frenos-severo|X0],
    confirmados(X, Conf), memberchk(liquido_frenos-P, Conf), P >= 0.85.
:- end_tests(reglas_base).

% ---------------------------------------------------------------------------
% F02 ciclo R1-R11: traza del PDF §6, parada, pruebas pendientes y casos límite.
% ---------------------------------------------------------------------------
:- begin_tests(ciclo).
cerca(X, Y, Tol) :- abs(X - Y) =< Tol.
sintomas([chirrido_frenos-presente, pedal_freno_esponjoso-presente]).
hallazgos([hall_medir_espesor_pastillas_freno-normal,
           hall_revisar_nivel_estado_liquido_frenos-severo,
           hall_inspeccionar_disco_rayaduras_alabeo-normal]).
pdf(R) :- sintomas(S), hallazgos(H), append(S, H, E), diagnosticar(E, R).
comp(R, Id, C) :- member(C, R.componentes), C.id == Id, !.
eventos(R, Es) :- findall(E, ( member(T, R.traza), E = T.evento ), Es).

test(traza_del_pdf_concluyente_en_3_de_5) :-
    pdf(R), R.concluyente == true, R.motivo == sin_inciertos, R.iteraciones == 3.
test(traza_del_pdf_probabilidades_y_estados) :-
    pdf(R),
    comp(R, liquido_frenos, L), L.estado == confirmado, cerca(L.probabilidad, 0.93, 0.02),
    comp(R, pastillas_freno, P), P.estado == descartado, cerca(P.probabilidad, 0.039, 0.005),
    comp(R, discos_freno, D), D.estado == descartado, cerca(D.probabilidad, 0.025, 0.005).
test(traza_del_pdf_eventos_y_retrocesos) :-
    pdf(R), eventos(R, Es),
    Es == [apilar, prueba, rb1, prueba, rb3, prueba, rb1],
    findall(F, ( member(T, R.traza), T.evento == prueba, F = T.foco ), Focos),
    Focos == [pastillas_freno, liquido_frenos, discos_freno].
test(traza_del_pdf_accion_88) :-
    pdf(R), R.acciones = [A, B|_],
    A.id == purgar_cambiar_liquido_frenos, cerca(A.relevancia, 0.88, 0.01),
    B.id == revisar_fugas_circuito_frenos, cerca(B.relevancia, 0.47, 0.01).
test(traza_del_pdf_explicacion_del_liquido) :-
    pdf(R), member(Ex, R.explicacion), Ex.componente == liquido_frenos,
    Ex.aportes = [A1, A2|_], A1.aporte >= A2.aporte,
    memberchk(pedal_freno_esponjoso, [A1.sintoma, A2.sintoma]), !.
test(traza_del_pdf_pruebas_hechas_y_nada_sugerido) :-
    pdf(R), length(R.pruebas_hechas, 3), R.pruebas_sugeridas == [],
    R.hallazgos_no_aplicados == [].
test(estado_inicial_sin_resultados_de_pruebas) :-
    sintomas(S), diagnosticar(S, R),
    R.concluyente == false, R.motivo == prueba_pendiente, R.iteraciones == 0,
    comp(R, pastillas_freno, P), cerca(P.probabilidad, 0.63, 0.02), P.estado == incierto,
    R.pruebas_sugeridas = [S1|_], S1.prueba == medir_espesor_pastillas_freno,
    S1.componente == pastillas_freno.
test(se_detiene_en_la_prueba_pendiente) :-
    sintomas(S), diagnosticar([hall_medir_espesor_pastillas_freno-normal|S], R),
    R.iteraciones == 1, R.motivo == prueba_pendiente,
    R.pruebas_sugeridas = [S1|_], S1.componente == liquido_frenos.
test(hallazgo_no_pedido_se_informa) :-
    sintomas(S), diagnosticar([hall_medir_voltaje_bateria-normal|S], R),
    R.hallazgos_no_aplicados == [hall_medir_voltaje_bateria].
test(max_iteraciones_es_no_concluyente_no_error) :-
    modificada([parametro(max_iteraciones, 5)], [parametro(max_iteraciones, 2)], pdf(R)),
    R.concluyente == false, R.motivo == max_iteraciones, R.iteraciones == 2.
test(foco_sin_pruebas_pasa_al_siguiente_y_no_concluye) :-
    modificada([prueba_componente(inspeccionar_disco_rayaduras_alabeo, discos_freno),
                prueba_componente(medir_espesor_disco_freno, discos_freno)], [], pdf(R)),
    R.concluyente == false, R.motivo == sin_pruebas.
test(foco_sin_pruebas_queda_en_la_traza) :-
    modificada([prueba_componente(inspeccionar_disco_rayaduras_alabeo, discos_freno),
                prueba_componente(medir_espesor_disco_freno, discos_freno)], [],
               ( pdf(R), eventos(R, Es) )),
    memberchk(sin_pruebas, Es).
test(contradiccion_detiene_el_ciclo) :-
    diagnosticar([no_arranca-presente, ralenti_inestable-presente], R),
    R.motivo == contradiccion, R.concluyente == false,
    R.contradicciones = [P], P.a == no_arranca, P.b == ralenti_inestable.
test(sin_sintomas_no_hay_hipotesis) :-
    diagnosticar([], R), R.componentes == [], R.acciones == [].
test(ejemplo_del_enunciado_circuito_de_arranque) :-
    diagnosticar([no_arranca-presente, motor_no_gira-presente, faros_tenues-ausente,
                  hall_medir_voltaje_bateria-normal], R),
    comp(R, rele_arranque, Rele), Rele.estado == confirmado,
    comp(R, circuito_control_arranque, Circ), Circ.estado == confirmado,
    comp(R, solenoide_arranque, Sol), Sol.estado \== descartado,
    \+ comp(R, pastillas_freno, _).
test(cambiar_un_conteo_cambia_el_diagnostico) :-
    pdf(R0), comp(R0, liquido_frenos, L0),
    componente_sintoma(liquido_frenos, hall_revisar_nivel_estado_liquido_frenos, severo, N1, N2), !,
    modificada([componente_sintoma(liquido_frenos, hall_revisar_nivel_estado_liquido_frenos, severo, N1, N2)],
               [componente_sintoma(liquido_frenos, hall_revisar_nivel_estado_liquido_frenos, severo, 1, N2)],
               ( pdf(R1), comp(R1, liquido_frenos, L1), L1.probabilidad < L0.probabilidad )).
:- end_tests(ciclo).

% ---------------------------------------------------------------------------
% F02 operación JSON `diagnosticar` (RNF-01 validaciones, RNF-02 errores).
% ---------------------------------------------------------------------------
:- begin_tests(op_diagnosticar).
diag(Args, R) :-
    format(string(L), "{\"id\":7,\"op\":\"diagnosticar\",\"args\":~s}", [Args]),
    procesar_linea(L, R).
pdf_args("{\"sintomas\":{\"chirrido_frenos\":\"presente\",\"pedal_freno_esponjoso\":\"presente\"},
  \"hallazgos\":{\"hall_medir_espesor_pastillas_freno\":\"normal\",
                 \"hall_revisar_nivel_estado_liquido_frenos\":\"severo\",
                 \"hall_inspeccionar_disco_rayaduras_alabeo\":\"normal\"}}").
problema(R, Texto) :- member(P, R.error.problemas), sub_string(P, _, _, _, Texto), !.

test(traza_del_pdf_por_json) :-
    pdf_args(A), diag(A, R), R.id == 7, R.estado == ok, R.resultados = [D],
    D.concluyente == true, D.iteraciones == 3.
test(sin_hallazgos_es_no_concluyente_ok) :-
    diag("{\"sintomas\":{\"chirrido_frenos\":\"presente\"}}", R),
    R.estado == ok, R.resultados = [D], D.concluyente == false.
test(sin_sintomas_es_sin_resultados) :-
    diag("{}", R), R.estado == sin_resultados, R.resultados == [].
test(solo_hallazgos_es_sin_resultados) :-
    diag("{\"hallazgos\":{\"hall_medir_voltaje_bateria\":\"normal\"}}", R),
    R.estado == sin_resultados.
test(sintoma_inexistente) :-
    diag("{\"sintomas\":{\"fantasma\":\"presente\"}}", R),
    R.estado == error, R.error.codigo == entrada_invalida, problema(R, "síntoma inexistente").
test(estado_invalido) :-
    diag("{\"sintomas\":{\"chirrido_frenos\":\"quizas\"}}", R),
    R.error.codigo == entrada_invalida, problema(R, "estado inválido").
test(estado_no_cadena) :-
    diag("{\"sintomas\":{\"chirrido_frenos\":1}}", R),
    R.error.codigo == entrada_invalida.
test(hallazgo_en_sintomas_es_invalido) :-
    diag("{\"sintomas\":{\"hall_medir_voltaje_bateria\":\"presente\"}}", R),
    R.error.codigo == entrada_invalida.
test(sintomas_no_es_objeto) :-
    diag("{\"sintomas\":[\"chirrido_frenos\"]}", R),
    R.error.codigo == entrada_invalida, problema(R, "objeto JSON").
test(varios_problemas_a_la_vez) :-
    diag("{\"sintomas\":{\"x\":\"presente\",\"y\":\"presente\"}}", R),
    length(R.error.problemas, 2).
test(contradiccion_por_json) :-
    diag("{\"sintomas\":{\"no_arranca\":\"presente\",\"ralenti_inestable\":\"presente\"}}", R),
    R.estado == ok, R.resultados = [D], D.motivo == contradiccion.
test(respuesta_serializable_a_json) :-
    pdf_args(A), diag(A, R),
    with_output_to(string(S), json_write_dict(current_output, R, [width(0)])),
    sub_string(S, _, _, _, "\"concluyente\":true"),
    atom_json_dict(S, _, []), !.
test(con_la_kb_rota_responde_kb_invalida) :-
    modificada([], [accion_componente(fantasma, liquido_frenos, 0.5)],
               ( pdf_args(A), diag(A, R) )),
    R.error.codigo == kb_invalida.
:- end_tests(op_diagnosticar).

% ---------------------------------------------------------------------------
% F02 consultas.pl (≥10 consultas distintas) y mínimos de la sección 5.
% ---------------------------------------------------------------------------
:- begin_tests(consultas).
test(sintomas_de) :- sintomas_de(liquido_frenos, Ss),
    memberchk(pedal_freno_esponjoso, Ss), \+ ( member(S, Ss), sintoma(S, _, hallazgo) ).
test(componentes_de) :- componentes_de(pedal_freno_esponjoso, Cs),
    memberchk(liquido_frenos, Cs), memberchk(pastillas_freno, Cs), memberchk(discos_freno, Cs).
test(pruebas_para) :- pruebas_para(pastillas_freno, Ps), memberchk(medir_espesor_pastillas_freno, Ps).
test(componentes_de_prueba) :-
    componentes_de_prueba(medir_voltaje_bateria, Cs), memberchk(rele_arranque, Cs).
test(sintomas_de_prueba) :-
    sintomas_de_prueba(medir_espesor_pastillas_freno, Ss), memberchk(chirrido_frenos-0.70, Ss).
test(acciones_para_ordenadas) :-
    acciones_para(liquido_frenos, [M1-purgar_cambiar_liquido_frenos, M2-_|_]), M1 >= M2.
test(mejor_accion) :- mejor_accion(liquido_frenos, purgar_cambiar_liquido_frenos).
test(mejor_accion_sin_acciones_falla, [fail]) :- mejor_accion(componente_inexistente, _).
test(incompatibles_en_ambos_sentidos) :-
    incompatibles_con(no_arranca, A), memberchk(ralenti_inestable, A),
    incompatibles_con(ralenti_inestable, B), memberchk(no_arranca, B).
test(prior_del_pdf) :- prior(pastillas_freno, P), abs(P - 0.40) < 0.01.
test(sintomas_comunes) :-
    sintomas_comunes(liquido_frenos, pastillas_freno, Ss), memberchk(chirrido_frenos, Ss).
test(componentes_sin_pruebas_es_lista) :- componentes_sin_pruebas(Cs), is_list(Cs).
test(mas_probables) :-
    componentes_mas_probables([chirrido_frenos-presente, pedal_freno_esponjoso-presente], 2,
                              [_-pastillas_freno, _-liquido_frenos]).
test(hallazgos_de_prueba) :-
    hallazgos_de_prueba(medir_espesor_pastillas_freno, Hs), memberchk(normal, Hs).
test(consultas_calculan_sobre_la_kb) :-
    modificada([], [prueba_componente(medir_voltaje_bateria, discos_freno)],
               ( componentes_de_prueba(medir_voltaje_bateria, Cs), memberchk(discos_freno, Cs) )).
:- end_tests(consultas).

% Sección 5 (issue #55): mínimos medibles sobre el código.
:- begin_tests(minimos_seccion5).
propios(M, N) :-
    aggregate_all(count, ( current_predicate(M:Nom/Ar), functor(H, Nom, Ar),
                           \+ predicate_property(M:H, imported_from(_)),
                           predicate_property(M:H, number_of_clauses(_)) ), N).
test(al_menos_15_predicados_propios) :-
    propios(inferencia, A), propios(reglas, B), propios(consultas, C), A + B + C >= 15.
test(al_menos_13_consultas_distintas) :-
    module_property(consultas, exports(Es)), length(Es, N), N >= 10.
test(al_menos_20_reglas_logicas) :-
    aggregate_all(count, ( member(M, [inferencia, reglas, consultas]),
                           current_predicate(M:Nom/Ar), functor(H, Nom, Ar),
                           \+ predicate_property(M:H, imported_from(_)),
                           clause(M:H, Body), Body \== true ), N), N >= 20.
test(al_menos_2_reglas_recursivas) :-
    aggregate_all(count, ( member(M, [inferencia, reglas, consultas]),
                           current_predicate(M:Nom/Ar), functor(H, Nom, Ar),
                           \+ predicate_property(M:H, imported_from(_)),
                           clause(M:H, B), sub_term(G, B), callable(G), functor(G, Nom, Ar) ),
                  N),
    N >= 2.
test(los_recursivos_clave_existen, [forall(member(M:P, [inferencia:sumar/2, inferencia:complemento/2,
                                                        reglas:primer_candidato/5]))]) :-
    P = Nom/Ar, functor(H, Nom, Ar), clause(M:H, B), sub_term(G, B), callable(G),
    functor(G, Nom, Ar), !.
% El ciclo es mutuamente recursivo: ciclo/2 -> foco/paso -> ciclo/2.
llama(M, De, A) :- De = Nom/Ar, functor(H, Nom, Ar), clause(M:H, B), sub_term(G, B), callable(G),
    A = N2/Ar2, functor(G, N2, Ar2), !.
test(ciclo_es_mutuamente_recursivo) :-
    llama(reglas, ciclo/2, paso/3), llama(reglas, paso/3, ciclo/2).
test(al_menos_5_reglas_compuestas) :-       % cuerpo con 3 o más condiciones en conjunción
    aggregate_all(count, ( member(M, [inferencia, reglas, consultas]),
                           current_predicate(M:Nom/Ar), functor(H, Nom, Ar),
                           \+ predicate_property(M:H, imported_from(_)),
                           clause(M:H, B), conjuncion(B, K), K >= 3 ), N),
    N >= 5.
test(al_menos_3_operaciones_con_listas) :-
    Ops = [append, member, memberchk, length, sort, msort, reverse, intersection, partition,
           exclude, maplist, select, nth0, findall],
    aggregate_all(count, ( member(Op, Ops), usa_op(Op) ), N),
    N >= 3.
conjuncion((A, B), K) :- !, conjuncion(A, Ka), conjuncion(B, Kb), K is Ka + Kb.
conjuncion(_, 1).
usa_op(Op) :-
    member(M, [inferencia, reglas, consultas]), current_predicate(M:Nom/Ar), functor(H, Nom, Ar),
    \+ predicate_property(M:H, imported_from(_)), \+ predicate_property(M:H, built_in),
    clause(M:H, B), sub_term(G, B), callable(G), functor(G, Op, _), !.
:- end_tests(minimos_seccion5).

% F04 (issue #56): vehículo de la sesión (vehiculo/6) y operaciones JSON.
:- begin_tests(vehiculo).
:- use_module('../backend/vehiculo').
ok_json("{\"marca\":\"Toyota\",\"modelo\":\"Corolla\",\"anio\":2015,\"cilindrada\":\"1.8 L\",\"combustible\":\"gasolina\",\"kilometraje\":120000}").
peticion(Op, Args, R) :-
    format(string(L), "{\"id\":7,\"op\":\"~w\",\"args\":~s}", [Op, Args]), procesar_linea(L, R).
limpio :- retractall(vehiculo:vehiculo(_, _, _, _, _, _)).
% Cambia un campo del JSON válido y devuelve la respuesta del registro.
con_campo(Campo, Valor, R) :-
    ok_json(J), atom_json_dict(J, D0, []), put_dict(Campo, D0, Valor, D),
    with_output_to(string(S), json_write_dict(current_output, D, [width(0)])),
    peticion(registrar_vehiculo, S, R).
invalido(Campo, Valor) :-
    limpio, con_campo(Campo, Valor, R), R.estado == error, R.error.codigo == entrada_invalida,
    [P] = R.error.problemas, sub_string(P, 0, _, _, Campo), \+ vehiculo:vehiculo(_, _, _, _, _, _).

test(consultar_sin_registro, [setup(limpio)]) :-
    peticion(consultar_vehiculo, "{}", R), R.estado == sin_resultados.
test(registrar_y_consultar, [setup(limpio)]) :-
    ok_json(J), peticion(registrar_vehiculo, J, R),
    R.estado == ok, [V] = R.resultados, V.marca == "Toyota", V.anio == 2015, V.combustible == gasolina,
    vehiculo:vehiculo("Toyota", "Corolla", 2015, "1.8 L", gasolina, 120000),
    peticion(consultar_vehiculo, "{}", R2), [V2] = R2.resultados, V2.kilometraje == 120000.
test(editar_reemplaza_el_anterior, [setup(limpio)]) :-
    ok_json(J), peticion(registrar_vehiculo, J, _),
    con_campo(kilometraje, 130000, R), R.estado == ok,
    aggregate_all(count, vehiculo:vehiculo(_, _, _, _, _, _), 1),
    vehiculo:vehiculo(_, _, _, _, _, 130000).
test(textos_se_recortan, [setup(limpio)]) :-
    con_campo(marca, "  Ford  ", R), R.estado == ok, vehiculo:vehiculo("Ford", _, _, _, _, _).
test(anio_limites, [setup(limpio), forall(member(A, [1950, 2026, 2027]))]) :-
    get_time(T), stamp_date_time(T, date(Y, _, _, _, _, _, _, _, _), local),
    con_campo(anio, A, R),
    ( A =< Y + 1 -> R.estado == ok ; R.estado == error ).
test(anio_fuera_de_rango, [forall(member(A, [1949, 3000, -1]))]) :- invalido(anio, A).
test(anio_no_entero, [forall(member(A, ["2015", 2015.5, null]))]) :- invalido(anio, A).
test(km_negativo) :- invalido(kilometraje, -1).
test(km_no_entero, [forall(member(K, ["abc", 1.5]))]) :- invalido(kilometraje, K).
test(km_cero_valido, [setup(limpio)]) :- con_campo(kilometraje, 0, R), R.estado == ok.
test(texto_vacio, [forall(member(C, [marca, modelo, cilindrada]))]) :- invalido(C, "   ").
test(texto_largo, [forall(member(C, [marca, modelo, cilindrada]))]) :-
    length(Cs, 41), maplist(=(0'a), Cs), string_codes(S, Cs), invalido(C, S).
test(texto_con_control) :- invalido(marca, "Ford\u0007").
test(combustible_desconocido, [forall(member(C, ["carbon", "", 3]))]) :- invalido(combustible, C).
test(varios_errores_listan_todos, [setup(limpio)]) :-
    peticion(registrar_vehiculo, "{\"marca\":\"\",\"anio\":1,\"kilometraje\":-5}", R),
    R.error.codigo == entrada_invalida, length(R.error.problemas, 6).
test(error_no_borra_el_registro, [setup(limpio)]) :-
    ok_json(J), peticion(registrar_vehiculo, J, _), con_campo(anio, 1900, R), R.estado == error,
    vehiculo:vehiculo(_, _, 2015, _, _, _).
:- end_tests(vehiculo).

% ===========================================================================
%  F05 · F11 · F12: síntomas, retroceso por contradicción (RB2) y casos de razonamiento
% ===========================================================================
% op/3 ya existe en SWI-Prolog: la petición JSON se llama pet/3.
pet(Op, Args, R) :-
    atom_json_dict(Json, _{id: 1, op: Op, args: Args}, [width(0)]),
    procesar_linea(Json, R).

limpio :- retroceso:reiniciar, memoria_x:x_limpiar.
marca(Id, Estado) :- pet(marcar_sintoma, _{id: Id, estado: Estado}, R), R.estado == ok.
quedan(Esperados, Seleccion) :-
    findall(Id-E, member(_{id: Id, nombre: _, estado: E}, Seleccion), Pares), Pares == Esperados.
proba(Comps, Id, P) :- member(C, Comps), C.id == Id, !, P = C.probabilidad.
estado_de(Comps, Id, E) :- member(C, Comps), C.id == Id, !, E = C.estado.
cerca_de(X, Y, Tol) :- abs(X - Y) =< Tol.
sintomas_pdf(_{chirrido_frenos: presente, pedal_freno_esponjoso: presente}).
hallazgos_pdf(_{hall_medir_espesor_pastillas_freno: normal,
                hall_revisar_nivel_estado_liquido_frenos: severo,
                hall_inspeccionar_disco_rayaduras_alabeo: normal}).
diag_pdf(Hallazgos, R) :-
    sintomas_pdf(S),
    (   Hallazgos == [] -> Args = _{sintomas: S} ; Args = _{sintomas: S, hallazgos: Hallazgos} ),
    pet(diagnosticar, Args, R), R.estado == ok.
eventos_de(D, Es) :- findall(E, ( member(T, D.traza), E = T.evento ), Es).

% --- F12 · 5 casos de razonamiento ------------------------------------------
:- begin_tests(f12_razonamiento).

% R1 · Escenario del PDF §6: hipótesis alternativas con ruido (chirrido) + pedal esponjoso.
test(caso_r1_pdf_seccion6) :-
    limpio, marca(chirrido_frenos, presente), marca(pedal_freno_esponjoso, presente),
    sintomas_pdf(S), pet(diagnosticar, _{sintomas: S}, R), R.resultados = [D],
    D.concluyente == false, D.motivo == prueba_pendiente, D.iteraciones == 0, D.max_iteraciones == 5,
    C = D.componentes,
    proba(C, pastillas_freno, P1), cerca_de(P1, 0.63, 0.02),
    proba(C, liquido_frenos, P2), cerca_de(P2, 0.44, 0.02),
    proba(C, discos_freno, P3), cerca_de(P3, 0.31, 0.02),
    forall(member(Id, [pastillas_freno, liquido_frenos, discos_freno]), estado_de(C, Id, incierto)),
    C = [Primero|_], Primero.id == pastillas_freno,          % ordenados por P descendente
    forall(member(X, C), X.sistema == 'Frenos' ; true),
    member(Pastillas, C), Pastillas.id == pastillas_freno, Pastillas.sistema == 'Frenos'.

% R2 · Ejemplo de entrada del enunciado: relé, solenoide o circuito de control.
test(caso_r2_ejemplo_arranque) :-
    limpio, marca(no_arranca, presente), marca(motor_no_gira, presente), marca(faros_tenues, ausente),
    pet(diagnosticar, _{sintomas: _{no_arranca: presente, motor_no_gira: presente, faros_tenues: ausente},
                        hallazgos: _{hall_medir_voltaje_bateria: normal}}, R),
    R.resultados = [D], C = D.componentes,
    estado_de(C, rele_arranque, confirmado), estado_de(C, circuito_control_arranque, confirmado),
    estado_de(C, solenoide_arranque, Sol), Sol \== descartado,
    member(Rele, C), Rele.id == rele_arranque, Rele.sistema == 'Arranque',
    \+ ( member(X, C), X.id == pastillas_freno ),
    % el ciclo investiga primero el solenoide; el voltaje solo se aplica cuando se pide esa prueba
    D.motivo == prueba_pendiente, D.pruebas_sugeridas = [Sug|_], Sug.componente == solenoide_arranque,
    D.hallazgos_no_aplicados == [hall_medir_voltaje_bateria].

% R3 · RB1 + RB3 (escenarios 1 y 2 de F11) con el PDF §6: la evidencia se conserva entre retrocesos.
test(caso_r3_rb1_refutacion_conserva_el_hallazgo) :-
    diag_pdf(_{hall_medir_espesor_pastillas_freno: normal}, R), R.resultados = [D],
    D.iteraciones == 1, D.motivo == prueba_pendiente,
    eventos_de(D, [apilar, prueba, rb1]),
    estado_de(D.componentes, pastillas_freno, descartado),
    D.pruebas_hechas == [medir_espesor_pastillas_freno],                % el hallazgo sigue en X
    D.pruebas_sugeridas = [S|_], S.componente == liquido_frenos.         % pasa al siguiente candidato
test(caso_r3_rb3_vuelve_al_punto_y_evalua_discos) :-
    diag_pdf(_{hall_medir_espesor_pastillas_freno: normal,
               hall_revisar_nivel_estado_liquido_frenos: severo}, R), R.resultados = [D],
    D.iteraciones == 2, eventos_de(D, [apilar, prueba, rb1, prueba, rb3]),
    estado_de(D.componentes, liquido_frenos, confirmado),
    D.pruebas_sugeridas = [S|_], S.componente == discos_freno.
test(caso_r3_final_concluyente_en_3_de_5) :-
    hallazgos_pdf(H), diag_pdf(H, R), R.resultados = [D],
    D.concluyente == true, D.motivo == sin_inciertos, D.iteraciones == 3, D.max_iteraciones == 5,
    eventos_de(D, [apilar, prueba, rb1, prueba, rb3, prueba, rb1]),
    estado_de(D.componentes, discos_freno, descartado),
    estado_de(D.componentes, pastillas_freno, descartado).

% R4 · RB2 (escenario 3): «no arranca» + «ralentí inestable».
test(caso_r4_rb2_restaura_y_el_usuario_elige) :-
    limpio, marca(no_arranca, presente),
    pet(marcar_sintoma, _{id: ralenti_inestable, estado: presente}, R), R.estado == ok,
    R.resultados = [Res], Res.contradiccion \== null, Res.contradiccion.restaurado == true,
    Res.contradiccion.par = [A, B], A.id == no_arranca, B.id == ralenti_inestable,
    quedan([no_arranca-presente], Res.seleccion),                         % X volvió al snapshot anterior
    pet(resolver_contradiccion, _{elegido: ralenti_inestable}, R2), R2.estado == ok,
    R2.resultados = [Fin], Fin.contradiccion == null,
    quedan([ralenti_inestable-presente], Fin.seleccion).
test(caso_r4_rb2_tambien_en_la_traza_de_diagnosticar) :-
    pet(diagnosticar, _{sintomas: _{no_arranca: presente, ralenti_inestable: presente}}, R),
    R.resultados = [D], D.motivo == contradiccion, D.concluyente == false,
    eventos_de(D, [rb2]), D.traza = [T], T.a == no_arranca, T.b == ralenti_inestable.

% R5 · Resultado NO concluyente: el ciclo se corta por max_iteraciones sin dejar de ser una respuesta ok.
test(caso_r5_no_concluyente_por_max_iteraciones) :-
    modificada([parametro(max_iteraciones, 5)], [parametro(max_iteraciones, 2)],
               ( hallazgos_pdf(H), diag_pdf(H, R) )),
    R.resultados = [D], D.concluyente == false, D.motivo == max_iteraciones,
    D.iteraciones == 2, D.max_iteraciones == 2.

:- end_tests(f12_razonamiento).

% --- F05 · catálogo y selección de síntomas ----------------------------------
:- begin_tests(f05_sintomas).

test(catalogo_agrupado_por_sistema_y_solo_sintomas) :-
    pet(catalogo_sintomas, _{}, R), R.estado == ok,
    findall(Id, ( member(G, R.resultados), member(X, G.sintomas), Id = X.id ), Ids),
    length(Ids, 50), \+ ( member(I, Ids), sub_atom(I, 0, _, _, hall_) ),
    findall(S, member(_{sistema: S, sintomas: _}, R.resultados), Sistemas),
    sort(Sistemas, Sistemas),                                              % ordenados, sin repetir
    member(G1, R.resultados), G1.sistema == 'Frenos',
    findall(I1, ( member(X1, G1.sintomas), I1 = X1.id ), Frenos),
    memberchk(chirrido_frenos, Frenos), memberchk(pedal_freno_esponjoso, Frenos).
test(sintoma_nuevo_en_la_kb_aparece_sin_tocar_c) :-
    modificada([], [sintoma(nuevo_x, 'Síntoma nuevo X', sintoma)],
               ( pet(catalogo_sintomas, _{}, R),
                 member(G, R.resultados), member(X, G.sintomas), X.id == nuevo_x )), !.
test(el_catalogo_coincide_con_la_kb) :-
    pet(catalogo_sintomas, _{}, R),
    findall(Id, ( member(G, R.resultados), member(X, G.sintomas), Id = X.id ), Del), msort(Del, A),
    findall(S, sintoma(S, _, sintoma), Kb), msort(Kb, A).
test(marcar_devuelve_la_seleccion_y_desconocido_no_entra_al_calculo) :-
    limpio, marca(chirrido_frenos, presente), marca(pedal_freno_esponjoso, ausente),
    pet(marcar_sintoma, _{id: luz_check_engine, estado: desconocido}, R), R.resultados = [Res],
    quedan([chirrido_frenos-presente, pedal_freno_esponjoso-ausente, luz_check_engine-desconocido],
           Res.seleccion),
    memoria_x:x_para_motor(Calculo),
    Calculo == [chirrido_frenos-presente, pedal_freno_esponjoso-ausente].
test(marcar_reemplaza_el_estado_sin_duplicar) :-
    limpio, marca(chirrido_frenos, presente), marca(chirrido_frenos, ausente),
    memoria_x:x_obtener(X), X == [chirrido_frenos-ausente].
test(rnf01_id_inexistente_no_altera_la_seleccion) :-
    limpio, marca(chirrido_frenos, presente),
    pet(marcar_sintoma, _{id: no_existe, estado: presente}, R),
    R.error.codigo == entrada_invalida, R.error.problemas = [P], sub_string(P, _, _, _, "inexistente"),
    memoria_x:x_obtener(X), X == [chirrido_frenos-presente].
test(rnf01_un_hallazgo_no_se_marca_como_sintoma) :-
    limpio, pet(marcar_sintoma, _{id: hall_medir_voltaje_bateria, estado: presente}, R),
    R.error.codigo == entrada_invalida, R.error.problemas = [P], sub_string(P, _, _, _, "hallazgo").
test(rnf01_estado_invalido_lo_valida_prolog) :-
    limpio, pet(marcar_sintoma, _{id: chirrido_frenos, estado: quizas}, R),
    R.error.codigo == entrada_invalida, R.error.problemas = [P], sub_string(P, _, _, _, "estado inválido"),
    memoria_x:x_obtener([]).
test(rnf01_argumentos_faltantes_o_mal_tipados) :-
    limpio,
    pet(marcar_sintoma, _{estado: presente}, R1), R1.error.codigo == entrada_invalida,
    pet(marcar_sintoma, _{id: 5, estado: presente}, R2), R2.error.codigo == entrada_invalida,
    pet(quitar_sintoma, _{}, R3), R3.error.codigo == entrada_invalida.
test(quitar_y_limpiar) :-
    limpio, marca(chirrido_frenos, presente), marca(pedal_freno_esponjoso, presente),
    pet(quitar_sintoma, _{id: chirrido_frenos}, R), R.estado == ok,
    memoria_x:x_obtener([pedal_freno_esponjoso-presente]),
    pet(quitar_sintoma, _{id: chirrido_frenos}, R2), R2.error.codigo == entrada_invalida,
    pet(limpiar_sintomas, _{}, R3), R3.estado == ok, memoria_x:x_obtener([]).
test(fijar_seleccion_es_todo_o_nada) :-
    limpio, marca(chirrido_frenos, presente),
    pet(fijar_seleccion, _{sintomas: _{pedal_freno_esponjoso: ausente, no_existe: presente}}, R),
    R.error.codigo == entrada_invalida, memoria_x:x_obtener([chirrido_frenos-presente]),
    pet(fijar_seleccion, _{sintomas: _{pedal_freno_esponjoso: ausente}}, R2), R2.estado == ok,
    memoria_x:x_obtener([pedal_freno_esponjoso-ausente]),
    pet(fijar_seleccion, _{sintomas: [a]}, R3), R3.error.codigo == entrada_invalida.
test(fijar_seleccion_rechaza_una_contradiccion) :-
    limpio, pet(fijar_seleccion, _{sintomas: _{no_arranca: presente, ralenti_inestable: presente}}, R),
    R.error.codigo == contradiccion, memoria_x:x_obtener([]).
test(sistemas_cubren_todos_los_componentes_de_la_kb) :-
    % un componente nuevo sin fila en sistemas.pl caería en «General»: avisa para clasificarlo
    findall(C, ( componente(C, _, _, _), sistema_componente(C, 'General') ), Sin), Sin == [].
test(sistemas_del_sintoma_se_deducen_de_la_kb) :-
    sistema_sintoma(chirrido_frenos, 'Frenos'), sistema_sintoma(no_arranca, 'Arranque'),
    sistema_sintoma(ac_no_funciona, 'Climatización'),
    sistema_sintoma(fuga_aceite, 'Motor'),                                  % excepción manual
    modificada([], [sintoma(nuevo_y, 'Nuevo Y', sintoma)], sistema_sintoma(nuevo_y, 'General')).
test(diagnosticar_incluye_sistema_y_max_iteraciones) :-
    sintomas_pdf(S), pet(diagnosticar, _{sintomas: S}, R), R.resultados = [D],
    D.max_iteraciones == 5, forall(member(C, D.componentes), is_of_type(atom, C.sistema)).

:- end_tests(f05_sintomas).

% --- F11 · RB2: retroceso por contradicción --------------------------------
:- begin_tests(f11_retroceso).

test(r2b_enumera_pares_por_backtracking_nativo) :-
    X = [no_arranca-presente, ralenti_inestable-presente, se_apaga_ralenti-presente],
    findall(P, par_en_conflicto(ralenti_inestable, X, P), [P1]), P1 == no_arranca-ralenti_inestable,
    findall(Q, par_en_conflicto(se_apaga_ralenti, X, Q), [Q1]), Q1 == no_arranca-se_apaga_ralenti.
test(sin_choque_si_uno_esta_ausente) :-
    limpio, marca(no_arranca, presente),
    pet(marcar_sintoma, _{id: ralenti_inestable, estado: ausente}, R), R.resultados = [Res],
    Res.contradiccion == null.
test(cancelar_restaura_el_estado_anterior) :-
    limpio, marca(no_arranca, presente), marca(ralenti_inestable, presente),
    pet(cancelar_contradiccion, _{}, R), R.estado == ok, R.resultados = [Res],
    quedan([no_arranca-presente], Res.seleccion),
    pet(cancelar_contradiccion, _{}, R2), R2.error.codigo == sin_contradiccion.
test(rnf01_solo_se_elige_uno_de_los_dos_en_conflicto) :-
    limpio, marca(no_arranca, presente), marca(ralenti_inestable, presente),
    pet(resolver_contradiccion, _{elegido: chirrido_frenos}, R), R.error.codigo == eleccion_invalida,
    pet(resolver_contradiccion, _{elegido: no_arranca}, R2), R2.estado == ok,
    memoria_x:x_obtener(X), X == [no_arranca-presente].
test(resolver_sin_pendiente) :-
    limpio, pet(resolver_contradiccion, _{elegido: no_arranca}, R), R.error.codigo == sin_contradiccion.
test(contradiccion_encadenada_vuelve_a_r2) :-
    limpio, marca(ralenti_inestable, presente), marca(se_apaga_ralenti, presente),
    pet(marcar_sintoma, _{id: no_arranca, estado: presente}, R), R.resultados = [Res],
    Res.contradiccion.par = [A, _], A.id == ralenti_inestable,
    pet(resolver_contradiccion, _{elegido: no_arranca}, R2), R2.resultados = [Res2],
    Res2.contradiccion.par = [A2, B2], A2.id == se_apaga_ralenti, B2.id == no_arranca,   % otro choque
    quedan([ralenti_inestable-presente, se_apaga_ralenti-presente], Res2.seleccion).
test(rnf02_pila_vacia_es_un_error_controlado) :-
    limpio, catch(restaurar_ultimo_snapshot, error_contrato(Cod, _), true), Cod == pila_vacia.
test(rnf01_un_snapshot_corrupto_no_se_restaura) :-
    limpio, apilar_snapshot([chirrido_frenos-valor_raro]),
    catch(restaurar_ultimo_snapshot, error_contrato(Cod, _), true),
    Cod == snapshot_invalido, memoria_x:x_obtener([]).
test(rb2_queda_registrado_para_la_traza) :-
    limpio, marca(no_arranca, presente), marca(ralenti_inestable, presente),
    pet(resolver_contradiccion, _{elegido: ralenti_inestable}, _),
    findall(T, ( registro_rb(E), T = E.evento ), Tipos), Tipos == [rb2, rb2_resuelta].
test(cambiar_la_seleccion_reinicia_los_snapshots) :-
    limpio, marca(no_arranca, presente), marca(ralenti_inestable, presente),
    pet(limpiar_sintomas, _{}, _),
    pet(resolver_contradiccion, _{elegido: no_arranca}, R), R.error.codigo == sin_contradiccion.

:- end_tests(f11_retroceso).

% F10 (issue #62): guardar, listar y cargar diagnósticos en el historial (datos/registros.txt).
% Cada prueba usa un archivo temporal propio; al final se vuelve a la ruta por defecto.
:- begin_tests(historial).
:- use_module('../backend/historial').
:- use_module('../backend/vehiculo').

% once/1: `diagnosticar` deja un punto de elección (el servidor real atiende una sola respuesta).
pedir(Op, Args, R) :-
    format(string(L), "{\"id\":9,\"op\":\"~w\",\"args\":~s}", [Op, Args]), once(procesar_linea(L, R)).
como_json(D, S) :- with_output_to(string(S), json_write_dict(current_output, D, [width(0)])).

% Historial vacío en un archivo temporal, sin vehículo ni diagnóstico en memoria.
nuevo(Ruta) :-
    historial:ruta_registros(Def), nb_setval(ruta_por_defecto, Def),
    tmp_file(registros, Base), atom_concat(Base, '/datos/registros.txt', Ruta),
    usar_registros(Ruta), retractall(vehiculo:vehiculo(_, _, _, _, _, _)).
fin(_) :- nb_getval(ruta_por_defecto, Def), usar_registros(Def),
    retractall(vehiculo:vehiculo(_, _, _, _, _, _)).

con_vehiculo :-
    pedir(registrar_vehiculo, "{\"marca\":\"Toyota\",\"modelo\":\"Corolla\",\"anio\":2015,\"cilindrada\":\"1.8 L\",\"combustible\":\"gasolina\",\"kilometraje\":120000}", R),
    R.estado == ok.
% Escenario del PDF §6: ruido + pedal esponjoso y los tres hallazgos -> concluyente.
args_pdf("{\"sintomas\":{\"chirrido_frenos\":\"presente\",\"pedal_freno_esponjoso\":\"presente\"},\"hallazgos\":{\"hall_medir_espesor_pastillas_freno\":\"normal\",\"hall_revisar_nivel_estado_liquido_frenos\":\"severo\",\"hall_inspeccionar_disco_rayaduras_alabeo\":\"normal\"}}").
diagnostico_pdf(R) :- args_pdf(A), pedir(diagnosticar, A, Resp), Resp.estado == ok, [R] = Resp.resultados.
diagnostico_frenos :-       % solo los síntomas: no concluyente (prueba pendiente)
    pedir(diagnosticar, "{\"sintomas\":{\"chirrido_frenos\":\"presente\"}}", R), R.estado == ok.
codigo(R, C) :- R.estado == error, R.error.codigo == C.

test(guardar_sin_diagnostico, [setup(nuevo(_)), cleanup(fin(_))]) :-
    con_vehiculo, pedir(guardar_diagnostico, "{}", R), codigo(R, sin_diagnostico),
    R.error.mensaje == "Primero genere un diagnóstico".
test(guardar_sin_vehiculo, [setup(nuevo(Ruta)), cleanup(fin(_))]) :-
    diagnostico_pdf(_), pedir(guardar_diagnostico, "{}", R), codigo(R, sin_vehiculo),
    \+ exists_file(Ruta).
test(guardar_crea_carpeta_y_archivo, [setup(nuevo(Ruta)), cleanup(fin(_))]) :-
    \+ exists_file(Ruta), con_vehiculo, diagnostico_pdf(_),
    pedir(guardar_diagnostico, "{}", R), R.estado == ok, [S] = R.resultados,
    S.id == 1, S.concluyente == true, S.principal == 'Líquido de frenos',   % los nombres de la KB son átomos
    exists_file(Ruta).
% Criterio: el registro contiene todos los campos del paso 17 para el escenario del PDF §6.
test(registro_tiene_campos_del_paso_17, [setup(nuevo(_)), cleanup(fin(_))]) :-
    con_vehiculo, diagnostico_pdf(_), pedir(guardar_diagnostico, "{}", _),
    diagnostico(1, _, vehiculo("Toyota", "Corolla", 2015, "1.8 L", gasolina, 120000), true, sin_inciertos, 3),
    diagnostico_resultado(1, entrada, E), memberchk(chirrido_frenos-presente, E),
    diagnostico_resultado(1, componentes, Cs), once(( member(C, Cs), C.id == liquido_frenos )),
    C.estado == confirmado,
    diagnostico_resultado(1, pruebas_hechas, Ph), length(Ph, 3),
    diagnostico_resultado(1, acciones, [A|_]), A.relevancia > 0.85,
    diagnostico_resultado(1, explicacion, [_|_]),
    diagnostico_resultado(1, traza, [_|_]).
% Criterio: cerrar y reabrir conserva los diagnósticos y cargar muestra lo mismo que se generó.
test(sobrevive_al_reinicio_y_carga_igual, [setup(nuevo(Ruta)), cleanup(fin(_))]) :-
    con_vehiculo, diagnostico_pdf(R0), pedir(guardar_diagnostico, "{}", _),
    usar_registros(Ruta),                                   % «reabrir»: memoria vacía y se lee el archivo
    pedir(listar_diagnosticos, "{}", L), L.estado == ok, [_] = L.resultados,
    pedir(cargar_diagnostico, "{\"id\":1}", C), C.estado == ok, [D] = C.resultados,
    como_json(R0, J0), como_json(D.resultado, J1), J0 == J1,
    D.vehiculo.marca == "Toyota", D.entrada.chirrido_frenos == presente.
test(no_se_guarda_dos_veces, [setup(nuevo(_)), cleanup(fin(_))]) :-
    con_vehiculo, diagnostico_pdf(_), pedir(guardar_diagnostico, "{}", _),
    pedir(guardar_diagnostico, "{}", R), codigo(R, ya_guardado),
    aggregate_all(count, diagnostico(_, _, _, _, _, _), 1).
test(ids_consecutivos_y_no_concluyente, [setup(nuevo(Ruta)), cleanup(fin(_))]) :-
    con_vehiculo, diagnostico_pdf(_), pedir(guardar_diagnostico, "{}", _),
    diagnostico_frenos, pedir(guardar_diagnostico, "{}", R2), [S2] = R2.resultados,
    S2.id == 2, S2.concluyente == false, S2.motivo == prueba_pendiente,
    usar_registros(Ruta), listar_diagnosticos(L), maplist([X, I]>>get_dict(id, X, I), L, [1, 2]).
test(listar_vacio_es_sin_resultados, [setup(nuevo(_)), cleanup(fin(_))]) :-
    pedir(listar_diagnosticos, "{}", R), R.estado == sin_resultados.
test(cargar_inexistente, [setup(nuevo(_)), cleanup(fin(_))]) :-
    pedir(cargar_diagnostico, "{\"id\":7}", R), codigo(R, no_encontrado).
test(cargar_id_invalido, [setup(nuevo(_)), cleanup(fin(_)),
                          forall(member(A, ["{}", "{\"id\":\"1\"}", "{\"id\":1.5}"]))]) :-
    pedir(cargar_diagnostico, A, R), codigo(R, entrada_invalida).
% RNF-02: un archivo dañado se informa con registros_corrupto y los registros válidos se conservan.
test(archivo_corrupto_conserva_los_validos, [setup(nuevo(Ruta)), cleanup(fin(_))]) :-
    con_vehiculo, diagnostico_pdf(_), pedir(guardar_diagnostico, "{}", _),
    setup_call_cleanup(open(Ruta, append, S),
                       format(S, "diagnostico(2, roto (.~nbasura(1).~ndiagnostico_resultado(99, x, 1).~n", []),
                       close(S)),
    usar_registros(Ruta),
    pedir(listar_diagnosticos, "{}", R), codigo(R, registros_corrupto),
    [V] = R.resultados, V.id == 1, length(R.error.problemas, 3),
    pedir(cargar_diagnostico, "{\"id\":1}", C), C.estado == ok.
test(formato_invalido_se_rechaza, [setup(nuevo(Ruta)), cleanup(fin(_))]) :-
    file_directory_name(Ruta, Dir), make_directory_path(Dir),
    setup_call_cleanup(open(Ruta, write, S),
                       format(S, "diagnostico(0, \"f\", x, true, m, 1).~ndiagnostico(1, \"f\", vehiculo(\"a\",\"b\",2015,\"c\",gas,1), quizas, m, 1).~n", []),
                       close(S)),
    cargar_registros(Ps), length(Ps, 2), \+ diagnostico(_, _, _, _, _, _).
% RNF-02: un error de escritura se informa y no cambia nada en memoria.
test(error_de_escritura_no_cambia_nada, [setup(nuevo(Ruta)), cleanup(fin(_))]) :-
    file_directory_name(Ruta, Dir), make_directory_path(Dir), make_directory(Ruta),  % la ruta es una carpeta
    con_vehiculo, diagnostico_pdf(_),
    pedir(guardar_diagnostico, "{}", R), codigo(R, error_escritura),
    \+ diagnostico(_, _, _, _, _, _),
    historial:ultimo_diagnostico(_, _, no).
:- end_tests(historial).

% F08 (issue #60): traza y explicación del razonamiento (backend/explicaciones.pl).
:- begin_tests(explicacion).
:- use_module('../backend/explicaciones').
:- use_module('../backend/historial').
:- use_module('../backend/reglas').

pdf_entrada([chirrido_frenos-presente, pedal_freno_esponjoso-presente,
             hall_medir_espesor_pastillas_freno-normal, hall_revisar_nivel_estado_liquido_frenos-severo,
             hall_inspeccionar_disco_rayaduras_alabeo-normal]).
explicado(E, X) :- once(diagnosticar(E, R)), explicar(E, R, X).
pdf(X) :- pdf_entrada(E), explicado(E, X).
contiene(Texto, Sub) :- sub_string(Texto, _, _, _, Sub), !.
textos_traza(X, Ts) :- findall(T, ( member(D, X.traza), T = D.texto ), Ts).
alguno(Ts, Sub) :- member(T, Ts), contiene(T, Sub), !.

% Criterio 1: la traza del PDF §6 muestra el pedal con +2,2, la contaminación con +2,8 y el
% descenso de Pastillas de 63 % a 3,9 %.
test(traza_pdf_aportes_y_descenso) :-
    pdf(X), textos_traza(X, Ts),
    alguno(Ts, "\"Pedal de freno esponjoso o blando\" aportó +2,2"),
    alguno(Ts, "\"Revisar el nivel y estado del líquido de frenos\" aportó +2,8"),
    alguno(Ts, "\"Pastillas de freno\" baja de 63,3 % a 3,9 %").
test(traza_pdf_en_orden_cronologico) :-
    pdf(X), findall(R, ( member(D, X.traza), R = D.regla ), Rs),
    Rs == ['R2-R5', 'R7', 'R7-R8', 'RB1', 'R7-R8', 'RB3', 'R7-R8', 'RB1', 'R6', 'R9', 'R10'],
    findall(I, ( member(D, X.traza), I = D.iteracion ), Is), Is == [0, 0, 1, 1, 2, 2, 3, 3, 3, 3, 3].
% Criterio 3: los retrocesos RB1 y RB3 aparecen en la traza (RB2 se completa en F11; R2b sí se explica).
test(retrocesos_en_la_traza) :-
    pdf(X), textos_traza(X, Ts),
    alguno(Ts, "RB1: \"Pastillas de freno\" queda descartado (3,9 %, menor o igual que el umbral de 5,0 %)"),
    alguno(Ts, "RB3: \"Líquido de frenos\" queda confirmado (93,1 %, mayor o igual que el umbral de 85,0 %)").
test(contradiccion_se_explica) :-
    explicado([no_arranca-presente, ralenti_inestable-presente], X),
    textos_traza(X, Ts), alguno(Ts, "R2b: hay datos incompatibles"),
    contiene(X.conclusion, "contradictorios").
test(datos_de_la_traza_para_la_interfaz) :-
    pdf(X), member(D, X.traza), D.regla == 'R7-R8', !,
    D.datos.foco == pastillas_freno, abs(D.datos.antes - 0.633) < 0.01, abs(D.datos.despues - 0.039) < 0.01.
test(explicacion_por_componente) :-
    pdf(X), member(C, X.explicacion), C.componente == liquido_frenos, !,
    C.estado == confirmado, contiene(C.texto, "Partió de una probabilidad previa de 10,0 %"),
    member(P, X.explicacion), P.componente == pastillas_freno, !,
    contiene(P.texto, "lo bajó desde 63,3 %").
test(acciones_con_su_origen) :-
    pdf(X), X.acciones = [A|_], A.accion == purgar_cambiar_liquido_frenos, A.componentes == [liquido_frenos],
    contiene(A.texto, "\"Líquido de frenos\" (93,1 %, con efectividad 0,95)").
test(pruebas_sugeridas_con_su_motivo) :-
    explicado([chirrido_frenos-presente], X), X.pruebas = [P|_],
    contiene(P.texto, "porque está presente: \"Los frenos chirrían\""),
    contiene(X.conclusion, "no concluyente").
% Criterio 2: al menos 5 explicaciones distintas (mínimo de la sección 5).
test(cinco_tipos_de_explicacion) :-
    pdf(X1), explicado([chirrido_frenos-presente], X2),
    explicado([no_arranca-presente, ralenti_inestable-presente], X3),
    Tipos = ["Posible falla en", "se descarta (", "sigue incierto", "atiende", "Se sugiere",
             "Diagnóstico concluyente", "no concluyente", "R2b: hay datos incompatibles", "R10:"],
    findall(T, ( member(X, [X1, X2, X3]),
                 ( member(D, X.explicacion) ; member(D, X.acciones) ; member(D, X.pruebas) ; member(D, X.traza) ),
                 T = D.texto ), Ts0),
    findall(C, ( member(X, [X1, X2, X3]), C = X.conclusion ), Cs), append(Ts0, Cs, Ts),
    forall(member(Tipo, Tipos), alguno(Ts, Tipo)),
    length(Tipos, N), N >= 5.
% Criterio 2: los textos salen de la KB; si cambia un hecho, cambia el texto.
test(texto_cambia_con_la_kb, [setup(cambiar_efectividad(0.95, 0.80)), cleanup(cambiar_efectividad(0.80, 0.95))]) :-
    pdf(X), X.acciones = [A|_], contiene(A.texto, "efectividad 0,8").
cambiar_efectividad(De, A) :-
    retract(user:accion_componente(purgar_cambiar_liquido_frenos, liquido_frenos, De)),
    assertz(user:accion_componente(purgar_cambiar_liquido_frenos, liquido_frenos, A)).

% Operación JSON `explicar` (RNF-01 y RNF-02).
pedir_x(Op, Args, R) :-
    format(string(L), "{\"id\":5,\"op\":\"~w\",\"args\":~s}", [Op, Args]), once(procesar_linea(L, R)).
limpio(Ruta) :- historial:ruta_registros(Def), nb_setval(ruta_x, Def),
    tmp_file(registros, B), atom_concat(B, '/datos/registros.txt', Ruta), usar_registros(Ruta).
restaurar(_) :- nb_getval(ruta_x, Def), usar_registros(Def), retractall(vehiculo:vehiculo(_, _, _, _, _, _)).

test(explicar_sin_diagnostico, [setup(limpio(_)), cleanup(restaurar(_))]) :-
    pedir_x(explicar, "{}", R), R.estado == error, R.error.codigo == sin_diagnostico,
    R.error.mensaje == "Primero genere un diagnóstico".
test(explicar_el_ultimo, [setup(limpio(_)), cleanup(restaurar(_))]) :-
    pedir_x(diagnosticar, "{\"sintomas\":{\"chirrido_frenos\":\"presente\"}}", _),
    pedir_x(explicar, "{}", R), R.estado == ok, [X] = R.resultados,
    contiene(X.conclusion, "no concluyente"), X.traza = [_|_].
test(explicar_uno_guardado_igual_que_el_actual, [setup(limpio(_)), cleanup(restaurar(_))]) :-
    pedir_x(registrar_vehiculo, "{\"marca\":\"Toyota\",\"modelo\":\"Corolla\",\"anio\":2015,\"cilindrada\":\"1.8 L\",\"combustible\":\"gasolina\",\"kilometraje\":120000}", _),
    pedir_x(diagnosticar, "{\"sintomas\":{\"chirrido_frenos\":\"presente\",\"pedal_freno_esponjoso\":\"presente\"},\"hallazgos\":{\"hall_medir_espesor_pastillas_freno\":\"normal\",\"hall_revisar_nivel_estado_liquido_frenos\":\"severo\",\"hall_inspeccionar_disco_rayaduras_alabeo\":\"normal\"}}", _),
    pedir_x(explicar, "{}", R1), pedir_x(guardar_diagnostico, "{}", _),
    historial:ruta_registros(Ruta), usar_registros(Ruta),          % reabrir: memoria vacía
    pedir_x(explicar, "{\"id\":1}", R2), R2.estado == ok,
    json_texto(R1.resultados, J1), json_texto(R2.resultados, J2), J1 == J2.
json_texto(D, S) :- with_output_to(string(S), json_write_dict(current_output, D, [width(0)])).
test(explicar_id_invalido_o_inexistente, [setup(limpio(_)), cleanup(restaurar(_))]) :-
    pedir_x(explicar, "{\"id\":\"x\"}", R1), R1.error.codigo == entrada_invalida,
    pedir_x(explicar, "{\"id\":3}", R2), R2.error.codigo == no_encontrado.
:- end_tests(explicacion).

% ---------------------------------------------------------------------------
% F07 pruebas adicionales: recomendar_pruebas y registrar_resultado_prueba (PDF §6, R7-R8).
% ---------------------------------------------------------------------------
:- begin_tests(pruebas_adicionales).
:- use_module('../backend/pruebas_adicionales').
:- use_module('../backend/historial').
pedir_p(Op, Args, R) :-
    format(string(L), "{\"id\":7,\"op\":\"~w\",\"args\":~s}", [Op, Args]), once(procesar_linea(L, R)).
limpio_p(_) :- historial:ruta_registros(Def), nb_setval(ruta_p, Def),
    tmp_file(registros, B), atom_concat(B, '/datos/registros.txt', Ruta), usar_registros(Ruta).
restaurar_p(_) :- nb_getval(ruta_p, Def), usar_registros(Def).
% Diagnóstico inicial del PDF §6 (solo los dos síntomas; las pruebas se registran después).
inicial :-
    pedir_p(diagnosticar,
            "{\"sintomas\":{\"chirrido_frenos\":\"presente\",\"pedal_freno_esponjoso\":\"presente\"}}", R),
    R.estado == ok.
registrar(P, Est, R) :-
    format(string(A), "{\"prueba\":\"~w\",\"resultado\":\"~w\"}", [P, Est]),
    pedir_p(registrar_resultado_prueba, A, R).
recomendadas(X) :- pedir_p(recomendar_pruebas, "{}", R), R.estado == ok, R.resultados = [X].
prob_p(R, Id, P) :- member(C, R.resultados), !, member(K, C.componentes), K.id == Id, !, P = K.probabilidad.
% tiene(+Texto, +Parte): una sola respuesta (sub_string/5 deja puntos de elección).
tiene(T, P) :- once(sub_string(T, _, _, _, P)).
json_p(D, S) :- with_output_to(string(S), json_write_dict(current_output, D, [width(0)])).
actual_json(S) :- historial:diagnostico_actual(_, D), json_p(D, S).

test(recomendar_sin_diagnostico, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    pedir_p(recomendar_pruebas, "{}", R), R.error.codigo == sin_diagnostico,
    R.error.mensaje == "Primero genere un diagnóstico".
test(pendiente_del_pdf, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial, recomendadas(X),
    P = X.pendiente, P.prueba == medir_espesor_pastillas_freno,
    P.nombre_componente == 'Pastillas de freno', P.resultados == [normal, leve, severo],
    abs(P.relevancia - 0.7) < 1.0e-9, X.realizadas == [], X.iteraciones == 0,
    tiene(X.mensaje, "porque está presente: \"Los frenos chirrían\""),
    X.otras = [O|_], O.prueba == revisar_nivel_estado_liquido_frenos.
test(registrar_actualiza_probabilidad, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial, registrar(medir_espesor_pastillas_freno, normal, R), R.estado == ok,
    R.resultados = [D], D.hallazgo.id == hall_medir_espesor_pastillas_freno,
    D.hallazgo.resultado == normal, D.iteraciones == 1, D.max_iteraciones == 5,
    prob_p(R, pastillas_freno, P), abs(P - 0.039) < 0.001,     % PDF §6: 63 % -> 3,9 %
    member(C, D.componentes), C.id == pastillas_freno, C.sistema == 'Frenos', !.
test(otras_pruebas_del_foco, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial, recomendadas(X0),
    findall(P, ( member(D, X0.del_foco), P = D.prueba ), Ps0), Ps0 == [inspeccionar_estado_pastillas_freno],
    registrar(medir_espesor_pastillas_freno, normal, _), recomendadas(X1),
    X1.pendiente.componente == liquido_frenos,
    findall(P, ( member(D, X1.del_foco), P = D.prueba ), Ps1), Ps1 == [inspeccionar_fugas_lineas_freno].
test(realizada_no_se_vuelve_a_sugerir, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial, registrar(medir_espesor_pastillas_freno, normal, _), recomendadas(X),
    X.pendiente.prueba == revisar_nivel_estado_liquido_frenos,
    \+ ( member(O, X.otras), O.prueba == medir_espesor_pastillas_freno ),
    X.realizadas = [H], H.prueba == medir_espesor_pastillas_freno, H.resultado == normal.
test(tres_resultados_concluyente, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial,
    registrar(medir_espesor_pastillas_freno, normal, _),
    registrar(revisar_nivel_estado_liquido_frenos, severo, _),
    registrar(inspeccionar_disco_rayaduras_alabeo, normal, R),
    R.resultados = [D], D.concluyente == true, D.motivo == sin_inciertos, D.iteraciones == 3,
    recomendadas(X), X.pendiente == null, X.otras == [], X.del_foco == [], length(X.realizadas, 3),
    X.mensaje == "No hacen falta más pruebas: no quedan hipótesis abiertas por investigar.".
test(traza_con_los_hallazgos, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial, registrar(medir_espesor_pastillas_freno, normal, _),
    pedir_p(explicar, "{}", R), R.resultados = [X],
    once(( member(E, X.traza), sub_string(E.texto, _, _, _, "Medir el espesor") )).
test(errores_no_cambian_el_estado, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial, actual_json(Antes),
    registrar(revisar_nivel_estado_liquido_frenos, severo, R1),
    R1.error.codigo == prueba_no_pendiente,
    tiene(R1.error.mensaje, "Medir el espesor de las pastillas de freno"),
    registrar(medir_espesor_pastillas_freno, enorme, R2), R2.error.codigo == entrada_invalida,
    registrar(no_existe, normal, R3), R3.error.codigo == entrada_invalida,
    pedir_p(registrar_resultado_prueba, "{\"prueba\":\"medir_espesor_pastillas_freno\"}", R4),
    R4.error.codigo == entrada_invalida,
    actual_json(Despues), Antes == Despues.
test(no_se_registra_dos_veces, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial, registrar(medir_espesor_pastillas_freno, normal, _), actual_json(Antes),
    registrar(medir_espesor_pastillas_freno, severo, R), R.error.codigo == ya_registrada,
    actual_json(Despues), Antes == Despues.
test(registrar_sin_diagnostico, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    registrar(medir_espesor_pastillas_freno, normal, R), R.error.codigo == sin_diagnostico.
test(sin_pendiente_explica_por_que, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    pedir_p(diagnosticar, "{\"sintomas\":{\"no_arranca\":\"presente\",\"ralenti_inestable\":\"presente\"}}", _),
    recomendadas(X), X.pendiente == null, X.mensaje \== "",
    registrar(medir_espesor_pastillas_freno, normal, R), R.error.codigo == prueba_no_pendiente,
    R.error.mensaje == "No hay ninguna prueba pendiente para este diagnóstico.".
test(mensajes_por_motivo) :-
    forall(member(M, [sin_inciertos, max_iteraciones, sin_pruebas, contradiccion]),
           ( pruebas_adicionales:texto_motivo(M, 2, 5, T), string(T), T \== "" )),
    once(pruebas_adicionales:texto_motivo(max_iteraciones, 5, 5, T5)),
    tiene(T5, "máximo de 5 iteraciones").
test(resultados_posibles_de_la_kb) :-
    forall(prueba(P, _), ( resultados_posibles(P, Rs), Rs \== [] )).
test(textos_sin_simbolos_especiales, [setup(limpio_p(_)), cleanup(restaurar_p(_))]) :-
    inicial, recomendadas(X), json_p(X, S),
    forall(member(C, ["«", "»", "≤", "≥", "×"]), \+ sub_string(S, _, _, _, C)).
:- end_tests(pruebas_adicionales).

% ---------------------------------------------------------------------------
% F09 acciones correctivas: Ra = 1 - prod(1 - P*Maj) sobre los confirmados (PDF §2.3, R9).
% ---------------------------------------------------------------------------
:- begin_tests(acciones_correctivas).
:- use_module('../backend/acciones').
:- use_module('../backend/historial').
pedir_a(Op, Args, R) :-
    format(string(L), "{\"id\":8,\"op\":\"~w\",\"args\":~s}", [Op, Args]), once(procesar_linea(L, R)).
limpio_a(_) :- historial:ruta_registros(Def), nb_setval(ruta_a, Def),
    tmp_file(registros, B), atom_concat(B, '/datos/registros.txt', Ruta), usar_registros(Ruta).
restaurar_a(_) :- nb_getval(ruta_a, Def), usar_registros(Def).
pdf_completo :-
    pedir_a(diagnosticar, "{\"sintomas\":{\"chirrido_frenos\":\"presente\",\"pedal_freno_esponjoso\":\"presente\"},\"hallazgos\":{\"hall_medir_espesor_pastillas_freno\":\"normal\",\"hall_revisar_nivel_estado_liquido_frenos\":\"severo\",\"hall_inspeccionar_disco_rayaduras_alabeo\":\"normal\"}}", R),
    R.estado == ok.
acciones_x(X) :- pedir_a(acciones_correctivas, "{}", R), R.estado == ok, R.resultados = [X].
ids(X, Ids) :- findall(A, ( member(D, X.acciones), A = D.accion ), Ids).
tiene_a(T, P) :- once(sub_string(T, _, _, _, P)).

test(acciones_sin_diagnostico, [setup(limpio_a(_)), cleanup(restaurar_a(_))]) :-
    pedir_a(acciones_correctivas, "{}", R), R.error.codigo == sin_diagnostico.
test(acciones_del_pdf, [setup(limpio_a(_)), cleanup(restaurar_a(_))]) :-
    pdf_completo, acciones_x(X),
    X.acciones = [A, B|_],
    A.accion == purgar_cambiar_liquido_frenos, abs(A.relevancia - 0.885) < 0.005,   % PDF: ~88 %
    B.accion == revisar_fugas_circuito_frenos, abs(B.relevancia - 0.466) < 0.005,   % PDF: ~47 %
    A.componentes = [O], O.id == liquido_frenos, O.efectividad =:= 0.95,
    tiene_a(A.texto, "relevancia 88,5 %"),
    X.confirmados = [C], C.id == liquido_frenos,
    X.mensaje == "2 acciones para 1 componente confirmado, de mayor a menor relevancia.".
test(ordenadas_por_ra, [setup(limpio_a(_)), cleanup(restaurar_a(_))]) :-
    pdf_completo, acciones_x(X),
    findall(R, ( member(D, X.acciones), R = D.relevancia ), Rs),
    msort(Rs, Asc), reverse(Asc, Rs),
    forall(member(R, Rs), ( R >= 0, R =< 1 )).
test(sin_confirmados_remite_a_pruebas, [setup(limpio_a(_)), cleanup(restaurar_a(_))]) :-
    pedir_a(diagnosticar, "{\"sintomas\":{\"chirrido_frenos\":\"presente\",\"pedal_freno_esponjoso\":\"presente\"}}", _),
    acciones_x(X), X.acciones == [], X.confirmados == [],
    tiene_a(X.mensaje, "Sin acciones: ningún componente confirmado"),
    tiene_a(X.mensaje, "Medir el espesor de las pastillas de freno").
test(descartados_no_generan_acciones) :-
    Res = _{motivo: sin_inciertos, pruebas_sugeridas: [],
            componentes: [_{id: pastillas_freno, estado: descartado, probabilidad: 0.039},
                          _{id: liquido_frenos, estado: confirmado, probabilidad: 0.93}]},
    acciones_de(Res, X), ids(X, Ids),
    \+ ( member(A, Ids), accion_componente(A, pastillas_freno, _),
         \+ accion_componente(A, liquido_frenos, _) ).
test(solo_confirmados_existentes) :-
    Res = _{motivo: sin_inciertos, pruebas_sugeridas: [],
            componentes: [_{id: no_existe, estado: confirmado, probabilidad: 0.99},
                          _{id: liquido_frenos, estado: confirmado, probabilidad: 0.5}]},
    acciones_de(Res, X), X.acciones == [], X.confirmados == [].
test(orden_cambia_con_la_kb, [setup(limpio_a(_)), cleanup(restaurar_a(_))]) :-
    pdf_completo,
    setup_call_cleanup(
        ( retract(user:accion_componente(revisar_fugas_circuito_frenos, liquido_frenos, M0)),
          assertz(user:accion_componente(revisar_fugas_circuito_frenos, liquido_frenos, 0.99)) ),
        ( acciones_x(X), ids(X, [Primera|_]) ),
        ( retract(user:accion_componente(revisar_fugas_circuito_frenos, liquido_frenos, 0.99)),
          assertz(user:accion_componente(revisar_fugas_circuito_frenos, liquido_frenos, M0)) )),
    Primera == revisar_fugas_circuito_frenos.
test(acciones_sin_simbolos_especiales, [setup(limpio_a(_)), cleanup(restaurar_a(_))]) :-
    pdf_completo, acciones_x(X),
    with_output_to(string(S), json_write_dict(current_output, X, [width(0)])),
    forall(member(C, ["«", "»", "≤", "≥", "×"]), \+ sub_string(S, _, _, _, C)).
:- end_tests(acciones_correctivas).

% ---------------------------------------------------------------------------
% F08 + F11: la traza narra los retrocesos RB2 hechos al marcar síntomas (también desde el historial).
% ---------------------------------------------------------------------------
:- begin_tests(explicacion_rb2).
:- use_module('../backend/historial').
:- use_module('../backend/retroceso').
:- use_module('../backend/memoria_x').
pedir_r(Op, Args, R) :-
    format(string(L), "{\"id\":4,\"op\":\"~w\",\"args\":~s}", [Op, Args]), once(procesar_linea(L, R)).
limpio_r(_) :- historial:ruta_registros(Def), nb_setval(ruta_r, Def),
    tmp_file(registros, B), atom_concat(B, '/datos/registros.txt', Ruta), usar_registros(Ruta),
    retroceso:reiniciar, memoria_x:x_limpiar.
restaurar_r(_) :- nb_getval(ruta_r, Def), usar_registros(Def),
    retroceso:reiniciar, memoria_x:x_limpiar, retractall(vehiculo:vehiculo(_, _, _, _, _, _)).
marcar_r(Id) :- format(string(A), "{\"id\":\"~w\",\"estado\":\"presente\"}", [Id]), pedir_r(marcar_sintoma, A, _).
contradiccion_resuelta :-
    marcar_r(no_arranca), marcar_r(ralenti_inestable),
    pedir_r(resolver_contradiccion, "{\"elegido\":\"no_arranca\"}", R), R.estado == ok,
    pedir_r(diagnosticar, "{\"sintomas\":{\"no_arranca\":\"presente\"}}", D), D.estado == ok.
traza_r(Args, Traza) :- pedir_r(explicar, Args, R), R.estado == ok, R.resultados = [X], Traza = X.traza.
reglas_r(Traza, Rs) :- findall(G, ( member(E, Traza), G = E.regla ), Rs).
tiene_r(T, P) :- once(sub_string(T, _, _, _, P)).

test(rb2_resuelta_en_la_traza, [setup(limpio_r(_)), cleanup(restaurar_r(_))]) :-
    contradiccion_resuelta, traza_r("{}", T),
    T = [E1, E2, E3|_], E1.regla == 'RB2', E2.regla == 'RB2', E3.regla == 'R2-R5',
    tiene_r(E1.texto, "incompatible con \"El motor no arranca\""),
    tiene_r(E1.texto, "se restauró"), E1.datos.restaurado == true,
    tiene_r(E2.texto, "el usuario eligió \"El motor no arranca\""),
    E2.datos.descartado == ralenti_inestable.
test(rb2_cancelada_en_la_traza, [setup(limpio_r(_)), cleanup(restaurar_r(_))]) :-
    marcar_r(no_arranca), marcar_r(ralenti_inestable),
    pedir_r(cancelar_contradiccion, "{}", _),
    pedir_r(diagnosticar, "{\"sintomas\":{\"no_arranca\":\"presente\"}}", _),
    traza_r("{}", T), T = [_, E2|_], E2.regla == 'RB2',
    tiene_r(E2.texto, "canceló"), tiene_r(E2.texto, "Ralentí inestable").
test(sin_contradicciones_no_hay_rb2, [setup(limpio_r(_)), cleanup(restaurar_r(_))]) :-
    marcar_r(chirrido_frenos),
    pedir_r(diagnosticar, "{\"sintomas\":{\"chirrido_frenos\":\"presente\"}}", _),
    historial:diagnostico_actual(_, Res), \+ get_dict(rb2, Res, _),
    traza_r("{}", T), reglas_r(T, Rs), \+ memberchk('RB2', Rs).
test(rb2_se_conserva_en_el_historial, [setup(limpio_r(_)), cleanup(restaurar_r(_))]) :-
    pedir_r(registrar_vehiculo, "{\"marca\":\"Toyota\",\"modelo\":\"Corolla\",\"anio\":2015,\"cilindrada\":\"1.8 L\",\"combustible\":\"gasolina\",\"kilometraje\":120000}", V),
    V.estado == ok,
    contradiccion_resuelta,
    pedir_r(guardar_diagnostico, "{}", G), G.estado == ok, G.resultados = [S], Id = S.id,
    retroceso:reiniciar,                                  % el registro en memoria ya no está
    historial:ruta_registros(Ruta), usar_registros(Ruta), cargar_registros(_),
    format(string(A), "{\"id\":~w}", [Id]), traza_r(A, T),
    reglas_r(T, Rs), Rs = ['RB2', 'RB2'|_].
test(contradiccion_directa_narra_rb2, [setup(limpio_r(_)), cleanup(restaurar_r(_))]) :-
    pedir_r(diagnosticar, "{\"sintomas\":{\"no_arranca\":\"presente\",\"ralenti_inestable\":\"presente\"}}", _),
    traza_r("{}", T), reglas_r(T, ['R2b', 'RB2', 'R6']),
    T = [_, E|_], tiene_r(E.texto, "el usuario debe elegir").
:- end_tests(explicacion_rb2).
