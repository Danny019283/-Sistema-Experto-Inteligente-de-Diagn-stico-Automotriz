% Reglas del ciclo de inferencia (F02, PDF §4): validación de la entrada (RNF-01), R2b,
% clasificación (R5) y candidatos a foco (R6/R7). El ciclo recursivo está más abajo.
% X es la memoria de trabajo: lista de Sintoma-Estado (ver inferencia.pl).
:- module(reglas, [validar_entrada/2, contradicciones/2, tiene_evidencia/2, clasificar/2,
                   candidatos/2, confirmados/2, diagnosticar/2]).
:- use_module(inferencia).

% ---------- RNF-01: validación de la entrada ----------
% validar_entrada(+Entrada, -Problemas): Entrada = lista de Sintoma-Estado; [] si es válida.
validar_entrada(Entrada, Problemas) :-
    findall(P, problema_entrada(Entrada, P), Ps), sort(Ps, Problemas).

problema_entrada(E, P) :- \+ is_list(E), !, P = "la entrada debe ser una lista".
problema_entrada(E, P) :- member(X, E), \+ X = _-_, format(string(P), "entrada mal formada: ~q", [X]).
problema_entrada(E, P) :- member(S-_, E), \+ sintoma(S, _, _),
    format(string(P), "síntoma inexistente: ~w", [S]).
problema_entrada(E, P) :- member(S-Est, E), sintoma(S, _, T), \+ estado_valido(T, Est),
    format(string(P), "estado inválido para ~w: ~w", [S, Est]).
problema_entrada(E, P) :- member(S-_, E), sintoma(S, _, hallazgo),
    ( sub_atom(S, 0, _, _, hall_) -> sub_atom(S, 5, _, 0, Prueba) ; Prueba = S ),
    \+ prueba(Prueba, _),
    format(string(P), "hallazgo de una prueba inexistente: ~w", [S]).
problema_entrada(E, P) :- select(S-_, E, Resto), memberchk(S-_, Resto),
    format(string(P), "síntoma repetido: ~w", [S]).

estado_valido(sintoma, Est) :- memberchk(Est, [presente, ausente, desconocido]).
estado_valido(hallazgo, Est) :- memberchk(Est, [normal, leve, severo]).

% ---------- R2b: contradicciones ----------
% contradicciones(+X, -Pares): pares incompatibles presentes a la vez.
contradicciones(X, Pares) :-
    findall(A-B, ( incompatibilidad(A, B), memberchk(A-presente, X), memberchk(B-presente, X) ),
            Pares).

% ---------- R5: clasificación ----------
% Un componente solo entra al análisis si algún dato de X tiene fila para él: sin evidencia
% queda en su prior (p. ej. «pastillas» 0,40 ante «no arranca») y no es una hipótesis.
tiene_evidencia(C, X) :-
    member(S-E, X), E \== desconocido, componente_sintoma(C, S, _, _, _), !.

% clasificar(+X, -Lista): P-C-Estado de cada componente con evidencia, de mayor a menor P.
clasificar(X, Lista) :-
    findall(P-C-Est, ( componente(C, _, _, _), tiene_evidencia(C, X),
                       probabilidad(C, X, P), estado_componente(P, Est) ), L0),
    sort(0, @>=, L0, Lista).

confirmados(X, Conf) :-
    clasificar(X, L), findall(C-P, member(P-C-confirmado, L), Conf).

% ---------- R6/R7: candidatos a foco ----------
% candidatos(+X, -Cs): inciertos con P >= tau_candidato, de mayor a menor P.
candidatos(X, Cs) :-
    parametro(tau_candidato, Min), clasificar(X, L),
    findall(C, ( member(P-C-incierto, L), P >= Min ), Cs).

% ---------- Ciclo R1-R11 (recursivo) ----------
% Estado: e(X, Hechas, Iter, Pila, Resp, Traza)
%   X       memoria de trabajo (Sintoma-Estado, crece con los hallazgos aplicados)
%   Hechas  pruebas ya realizadas        Iter  iteración (una por prueba aplicada)
%   Pila    [punto(Id, Snapshot, Candidatos, Indice)]; Indice = foco actual (RB1/RB3 lo avanzan)
%   Resp    resultados de pruebas dados por el usuario (hall_*-Estado); se aplican al pedirse la prueba
%   Traza   eventos, el más reciente primero
% RB2 (restaurar X al snapshot tras una contradicción) se completa en F11: aquí R2b solo detecta.

% diagnosticar(+Entrada, -Resultado): Entrada validada (validar_entrada/2) = lista Sintoma-Estado.
% Los hallazgos de la entrada no entran de golpe: se aplican cuando el ciclo recomienda esa
% prueba, como en la traza del PDF §6 (así cuenta las iteraciones).
diagnosticar(Entrada, Res) :-
    partition([S-_]>>sintoma(S, _, hallazgo), Entrada, Resp, X0),
    contradicciones(X0, Pares),
    (   Pares \== []
    ->  findall(_{a: A, b: B}, member(A-B, Pares), Cs),               % R2b -> RB2 (F11)
        Res = _{concluyente: false, motivo: contradiccion, contradicciones: Cs,
                iteraciones: 0, componentes: [], acciones: [], pruebas_sugeridas: [],
                explicacion: [], traza: [], pruebas_hechas: [], hallazgos_no_aplicados: []}
    ;   ciclo(e(X0, [], 0, [], Resp, []), Final),
        reporte(Final, Res)
    ).

% ciclo(+E, -Final): Final = final(Concluyente, Motivo, E, Pendiente).
ciclo(E, Final) :-
    E = e(X, _, Iter, _, _, _),
    parametro(max_iteraciones, Max),
    candidatos(X, Cands),
    (   Cands == []                                                  % R6: sin inciertos
    ->  Final = final(true, sin_inciertos, E, ninguna)
    ;   Iter >= Max                                                  % R6: no concluyente
    ->  Final = final(false, max_iteraciones, E, ninguna)
    ;   foco(E, Cands, E1, C)                                        % R7
    ->  paso(E1, C, Final)
    ;   Final = final(false, sin_pruebas, E, ninguna)
    ).

% foco(+E, +Cands, -E1, -C): apila el punto de decisión la primera vez y elige el primer
% candidato del punto, desde el índice actual, que siga siendo candidato.
foco(e(X, H, I, Pila0, R, T0), Cands, e(X, H, I, [punto(Id, Snap, Cs, Idx)], R, T), C) :-
    (   Pila0 = [punto(Id, Snap, Cs, Idx0)]
    ->  T = T0
    ;   Id = 1, Snap = X, Cs = Cands, Idx0 = 0, T = [apilar(Id, Cands)|T0]
    ),
    length(Pre, Idx0), append(Pre, Resto, Cs),
    primer_candidato(Resto, Idx0, Cands, Idx, C).

primer_candidato([C0|Cs], I, Cands, Idx, C) :-
    (   memberchk(C0, Cands) -> Idx = I, C = C0
    ;   I1 is I + 1, primer_candidato(Cs, I1, Cands, Idx, C)
    ).

% paso(+E, +C, -Final): R7 recomienda la prueba de mayor Rp del foco; R8 aplica su resultado.
paso(e(X, H, I, [punto(Id, S, Cs, Idx)], R, T), C, Final) :-
    pruebas_del_componente(C, X, H, Pruebas),
    (   Pruebas = [Rp-Prueba|_]
    ->  atom_concat(hall_, Prueba, Hall),
        (   memberchk(Hall-Est, R)
        ->  I1 is I + 1,
            E2 = e([Hall-Est|X], [Prueba|H], I1, [punto(Id, S, Cs, Idx)], R,
                   [prueba(I1, C, Prueba, Est)|T]),
            retroceder(E2, C, E3),
            ciclo(E3, Final)                                         % R8 -> R2..R4 con otro foco o prueba
        ;   Final = final(false, prueba_pendiente,
                          e(X, H, I, [punto(Id, S, Cs, Idx)], R, T), pendiente(C, Prueba, Rp))
        )
    ;   Idx1 is Idx + 1,                                             % sin pruebas para el foco: siguiente
        ciclo(e(X, H, I, [punto(Id, S, Cs, Idx1)], R, [sin_pruebas(C)|T]), Final)
    ).

% R8: si el foco quedó descartado (RB1) o confirmado (RB3) se vuelve al punto con el
% siguiente candidato; X se conserva. Si sigue incierto, otra prueba del mismo foco.
retroceder(e(X, H, I, [punto(Id, S, Cs, Idx)], R, T), C, E1) :-
    probabilidad(C, X, P), estado_componente(P, Est),
    (   memberchk(Est-Rb, [descartado-rb1, confirmado-rb3])
    ->  Idx1 is Idx + 1,
        E1 = e(X, H, I, [punto(Id, S, Cs, Idx1)], R, [retroceso(Rb, C, P)|T])
    ;   E1 = e(X, H, I, [punto(Id, S, Cs, Idx)], R, T)
    ).

% ---------- R9-R11: acciones, explicación y reporte ----------
reporte(final(Conc, Motivo, e(X, H, I, _, R, T), Pend), Res) :-
    clasificar(X, Cl), confirmados(X, Conf), acciones_ordenadas(Conf, Acs),
    findall(_{id: C, nombre: N, probabilidad: P, estado: Est},
            ( member(P-C-Est, Cl), componente(C, N, _, _) ), Comps),
    findall(_{id: A, nombre: N, relevancia: Ra}, ( member(Ra-A, Acs), accion(A, N) ), Acciones),
    findall(_{componente: C, aportes: Ap}, ( member(C-_, Conf), aportes(C, X, Ap) ), Expl),
    (   Conc == true -> Sug = [] ; sugeridas(X, H, Pend, Sug) ),
    findall(Hl, ( member(Hl-_, R), \+ memberchk(Hl-_, X) ), NoAplicados),
    reverse(T, Traza0), maplist(evento_dict, Traza0, Traza),
    reverse(H, Hechas),
    Res = _{concluyente: Conc, motivo: Motivo, iteraciones: I, componentes: Comps,
            acciones: Acciones, pruebas_sugeridas: Sug, explicacion: Expl, traza: Traza,
            pruebas_hechas: Hechas, hallazgos_no_aplicados: NoAplicados}.

% R10: los 3 síntomas de mayor contribución positiva al logit del componente.
aportes(C, X, Top) :-
    contribuciones(C, X, Cs),
    findall(L-S, ( member(S-L, Cs), L > 0 ), Ps), sort(0, @>=, Ps, Orden),
    (   length(Orden, Len), Len > 3 -> length(Pre, 3), append(Pre, _, Orden) ; Pre = Orden ),
    findall(_{sintoma: S, nombre: N, aporte: L}, ( member(L-S, Pre), sintoma(S, N, _) ), Top).

% Pruebas sugeridas si no fue concluyente: la pendiente primero y la mejor de cada candidato.
sugeridas(X, H, Pend, Sug) :-
    candidatos(X, Cands),
    findall(_{prueba: P, nombre: N, componente: C, relevancia: Rp},
            ( member(C, Cands), pruebas_del_componente(C, X, H, [Rp-P|_]), prueba(P, N) ), Todas),
    (   Pend = pendiente(Cp, Pp, Rpp), prueba(Pp, Np)
    ->  exclude([D]>>get_dict(prueba, D, Pp), Todas, Otras),
        Sug = [_{prueba: Pp, nombre: Np, componente: Cp, relevancia: Rpp}|Otras]
    ;   Sug = Todas
    ).

evento_dict(apilar(Id, Cs), _{evento: apilar, punto: Id, candidatos: Cs}).
evento_dict(prueba(I, C, P, Est), _{evento: prueba, iteracion: I, foco: C, prueba: P, resultado: Est}).
evento_dict(retroceso(Rb, C, P), _{evento: Rb, foco: C, probabilidad: P}).
evento_dict(sin_pruebas(C), _{evento: sin_pruebas, foco: C}).
