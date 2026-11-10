% Sistemas del vehículo (F05/F06). La KB de F01 no define «sistema», pero la pantalla de
% síntomas agrupa por sistema (F05) y el diagnóstico lo muestra por componente (F06).
%  * sistema_componente/2: tabla explícita (un componente nuevo sin fila queda en «General»).
%  * sistema_sintoma/2: se DEDUCE de la KB (no se almacena): el sistema cuyos componentes
%    acumulan más casos positivos con ese síntoma. Un síntoma nuevo en hechos.pl se agrupa solo.
%  * sintoma_sistema_manual/2: excepciones cuando la deducción no convence.
% enriquecer_diagnostico/2 añade `sistema` a cada componente y `max_iteraciones` al resultado
% de `diagnosticar` (F06 los muestra); no toca reglas.pl.
:- module(sistemas, [sistema_componente/2, sistema_sintoma/2, sistemas_conocidos/1,
                     enriquecer_diagnostico/2]).

:- dynamic sintoma_sistema_manual/2.
% Excepciones: la KB las asocia a otros sistemas (fugas de aceite -> catalizador; arranque lento -> batería).
sintoma_sistema_manual(fuga_aceite, 'Motor').
sintoma_sistema_manual(arranque_lento, 'Arranque').

general('General').

% sistema_componente(+Componente, -Sistema)
sistema_componente(C, S) :- tabla(C, S0), !, S = S0.
sistema_componente(C, S) :- componente(C, _, _, _), general(S).

tabla(C, 'Frenos') :- memberchk(C, [modulo_abs, sensor_velocidad_rueda, servofreno, caliper_freno,
    manguera_freno, cilindro_maestro_freno, pastillas_freno, discos_freno, zapatas_tambor,
    liquido_frenos]).
tabla(C, 'Climatización') :- memberchk(C, [compresor_ac, condensador_ac, evaporador_ac,
    carga_refrigerante_ac, filtro_cabina, nucleo_calefaccion, manguera_calefaccion]).
tabla(C, 'Enfriamiento') :- memberchk(C, [refrigerante, termostato, ventilador_radiador,
    manguera_radiador, bomba_agua, radiador, deposito_refrigerante]).
tabla(C, 'Transmisión y embrague') :- memberchk(C, [engranes_conicos, cable_embrague,
    cilindro_esclavo_embrague, cilindro_maestro_embrague, transmision_automatica,
    convertidor_par, fluido_transmision, filtro_transmision]).
tabla(C, 'Eléctrico') :- memberchk(C, [bateria, sistema_carga, motor_vidrio_puerta, foco_faro,
    claxon, bomba_limpiaparabrisas, motor_limpiaparabrisas, liquido_limpiaparabrisas]).
tabla(C, 'Arranque') :- memberchk(C, [motor_arranque, rele_arranque, solenoide_arranque,
    circuito_control_arranque]).
tabla(C, 'Encendido') :- memberchk(C, [tapa_distribuidor, cables_bujias]).
tabla(C, 'Combustible') :- memberchk(C, [bomba_inyeccion_diesel, inyector_combustible,
    filtro_combustible, regulador_presion_combustible, bomba_combustible, tanque_combustible,
    sensor_presion_tanque]).
tabla(C, 'Admisión y escape') :- memberchk(C, [valvula_purga_canister, catalizador,
    canister_carbon, multiple_escape, junta_multiple_escape, sensor_oxigeno, sensor_map,
    presion_turbo, filtro_aire, valvula_pcv, cuerpo_aceleracion, sensor_tps, valvula_iac]).
tabla(C, 'Motor') :- memberchk(C, [eje_balanceo, valvula_escape, valvula_admision, bomba_aceite,
    anillos_piston, banda_distribucion, banda_accesorios, aceite_motor, sensor_detonacion, ecu]).
tabla(C, 'Dirección y suspensión') :- memberchk(C, [liquido_direccion, eje_y_llantas,
    balero_rueda, sensor_tpms]).

% sistema_sintoma(+Sintoma, -Sistema): override manual, o el de mayor peso en la KB.
sistema_sintoma(S, Sis) :- sintoma_sistema_manual(S, Sis0), !, Sis = Sis0.
sistema_sintoma(S, Sis) :-
    findall(Peso-Sis0, peso_por_sistema(S, Sis0, Peso), Ps),
    (   Ps == [] -> general(Sis)
    ;   sort(0, @>=, Ps, [_-Sis1|_]) -> Sis = Sis1
    ).

peso_por_sistema(S, Sis, Peso) :-
    setof(Sis0, C^N^M^( componente_sintoma(C, S, _, N, M), sistema_componente(C, Sis0) ), Sistemas),
    member(Sis, Sistemas),
    aggregate_all(sum(N), ( componente_sintoma(C1, S, _, N, _), sistema_componente(C1, Sis) ), Peso).

sistemas_conocidos(L) :- setof(S, C^tabla(C, S), L0), general(G), append(L0, [G], L).

% enriquecer_diagnostico(+Resultado, -Resultado1): `sistema` por componente y `max_iteraciones`.
enriquecer_diagnostico(R0, R) :-
    parametro(max_iteraciones, Max),
    (   get_dict(componentes, R0, Cs0)
    ->  maplist(con_sistema, Cs0, Cs), put_dict(componentes, R0, Cs, R1)
    ;   R1 = R0
    ),
    put_dict(max_iteraciones, R1, Max, R).

con_sistema(C0, C) :- sistema_componente(C0.id, S), put_dict(sistema, C0, S, C).
