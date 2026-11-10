% Explicación del razonamiento (F08, issue #60; PDF §4 regla R10, paso 15; RF-11).
% A partir de la entrada y del resultado de `diagnosticar` genera:
%   - la traza: eventos evento(Iteracion, Regla, Datos) en orden cronológico, cada uno con su texto
%     (estado inicial R2-R5, R7/R8 por cada prueba, RB1/RB3, R6, R9 y R10);
%   - la explicación por componente (por qué se confirma, se descarta o sigue incierto);
%   - por qué se recomienda cada acción y cada prueba, y la conclusión.
% Los textos se arman con los nombres y números de la KB: si cambia un hecho, cambia el texto.
% Las probabilidades se recalculan con el motor (inferencia.pl): la traza de reglas.pl dice qué
% prueba se hizo y con qué resultado; aquí se reconstruye la memoria de trabajo X paso a paso.
:- module(explicaciones, [explicar/3, eventos/3, texto_evento/2, porcentaje/2, aporte_texto/2,
                          pruebas_texto/3]).   % pruebas_texto lo reutiliza F07
:- use_module(inferencia).
:- use_module(reglas).

% explicar(+Entrada, +Res, -Explicacion): Entrada = lista Sintoma-Estado (síntomas y hallazgos),
% Res = resultado de `diagnosticar`. Explicacion es un diccionario listo para JSON.
% Hay una sola explicación por diagnóstico: once/1 cierra los puntos de elección que dejan los
% cálculos del motor (verosimilitud/4 recorre varias filas de componente_sintoma/5).
explicar(Entrada, Res, X) :- once(explicar_(Entrada, Res, X)).

explicar_(Entrada, Res, _{conclusion: Conc, traza: Traza, explicacion: PorComp,
                          acciones: Acs, pruebas: Prs}) :-
    solo_sintomas(Entrada, X0),
    eventos(X0, Res, Eventos),
    eventos_dict(Eventos, Traza),
    componentes_texto(Res.componentes, Eventos, PorComp),
    acciones_texto(Res.acciones, Res.componentes, Acs),
    pruebas_texto(Res.pruebas_sugeridas, X0, Prs),
    conclusion(Res, Conc).

% solo_sintomas(+Entrada, -X0): la memoria de trabajo inicial (sin hallazgos), como en reglas.pl.
solo_sintomas([], []).
solo_sintomas([S-_|Es], X) :- sintoma(S, _, hallazgo), !, solo_sintomas(Es, X).
solo_sintomas([S-E|Es], [S-E|X]) :- solo_sintomas(Es, X).

% ---------- Eventos (la traza) ----------
% eventos(+X0, +Res, -Eventos): lista de evento(Iteracion, Regla, Datos).
eventos(_, Res, Eventos) :-
    get_dict(motivo, Res, M), a_atomo(M, contradiccion), !,
    findall(A-B, ( member(D, Res.contradicciones), a_atomo(D.a, A), a_atomo(D.b, B) ), Pares),
    Eventos = [evento(0, 'R2b', contradiccion(Pares)),
               evento(0, 'RB2', rb2_motor(Pares)),
               evento(0, 'R6', fin(contradiccion, false, 0))].
eventos(X0, Res, Eventos) :-
    rb2_eventos(Res, Rb2),                       % contradicciones resueltas al marcar los síntomas
    clasificar(X0, Clasif),
    pasos(Res.traza, X0, 0, Pasos, Iter),
    confirmados_de(Res.componentes, Conf),
    finales(Res, Conf, Iter, Fin),
    append([Rb2, [evento(0, 'R2-R5', inicial(Clasif))], Pasos, Fin], Eventos).

% rb2_eventos(+Res, -Eventos): los RB2 que registró retroceso.pl (F11) antes de diagnosticar, en
% orden; historial.pl los guarda en la clave `rb2`. Sin esa clave no hubo contradicciones.
rb2_eventos(Res, Evs) :-
    (   get_dict(rb2, Res, L) -> rb2_lista(L, Evs) ; Evs = [] ).

% rb2_lista(+Registros, -Eventos): recursión sobre los registros; uno desconocido se salta.
rb2_lista([], []).
rb2_lista([R|Rs], [evento(0, 'RB2', D)|Es]) :-
    rb2_dato(R, D), !,
    rb2_lista(Rs, Es).
rb2_lista([_|Rs], Es) :-
    rb2_lista(Rs, Es).

rb2_dato(R, rb2_restaurado(P, N)) :-
    a_atomo(R.evento, rb2), !, a_atomo(R.previo, P), a_atomo(R.nuevo, N).
rb2_dato(R, rb2_resuelta(E, D)) :-
    a_atomo(R.evento, rb2_resuelta), !, a_atomo(R.elegido, E), a_atomo(R.descartado, D).
rb2_dato(R, rb2_cancelada(P, N)) :-
    a_atomo(R.evento, rb2_cancelada), a_atomo(R.previo, P), a_atomo(R.nuevo, N).

% pasos(+TrazaMotor, +X, +Iter, -Eventos, -IterFinal): recorre los eventos del ciclo (recursión).
% Caso base: no quedan eventos. Cada prueba agrega su hallazgo a X, como hizo el motor (R8).
pasos([], _, I, [], I).
pasos([T|Ts], X, I0, [Ev|Evs], I) :-
    paso(T, X, I0, Ev, X1, I1),
    pasos(Ts, X1, I1, Evs, I).

paso(T, X, I, evento(I, 'R7', apilar(Punto, Cands)), X, I) :-
    get_dict(evento, T, apilar), !,
    Punto = T.punto, maplist(a_atomo, T.candidatos, Cands).
paso(T, X, _, evento(I, 'R7-R8', prueba(C, P, Est, Antes, Despues, Aporte)), [H-Est|X], I) :-
    get_dict(evento, T, prueba), !,
    I = T.iteracion, a_atomo(T.foco, C), a_atomo(T.prueba, P), a_atomo(T.resultado, Est),
    atom_concat(hall_, P, H),
    probabilidad(C, X, Antes), probabilidad(C, [H-Est|X], Despues),
    contribucion(C, H, Est, Aporte).
paso(T, X, I, evento(I, Regla, retroceso(C, P)), X, I) :-
    get_dict(evento, T, Ev0), a_atomo(Ev0, Ev), memberchk(Ev-Regla, [rb1-'RB1', rb3-'RB3']), !,
    a_atomo(T.foco, C), P = T.probabilidad.
paso(T, X, I, evento(I, 'R7', sin_pruebas(C)), X, I) :-
    a_atomo(T.foco, C).

% finales: R6 (por qué se detuvo), R9 (acciones) y R10 (explicación de cada confirmado).
finales(Res, Conf, I, [evento(I, Regla, fin(Motivo, Res.concluyente, I))|Resto]) :-
    a_atomo(Res.motivo, Motivo),
    % R6 detiene por falta de inciertos o por máximo de iteraciones; R7, si falta o no hay prueba.
    (   memberchk(Motivo, [prueba_pendiente, sin_pruebas]) -> Regla = 'R7' ; Regla = 'R6' ),
    (   Res.acciones = [_|_] -> Acc = [evento(I, 'R9', acciones(Res.acciones))] ; Acc = [] ),
    findall(evento(I, 'R10', aportes(C, P, Ap)),
            ( member(C-P, Conf), aportes_de(Res, C, Ap) ), R10),
    append(Acc, R10, Resto).

confirmados_de(Comps, Conf) :-
    findall(C-P, ( member(D, Comps), estado_de(D, confirmado), a_atomo(D.id, C),
                   P = D.probabilidad ), Conf).

aportes_de(Res, C, Ap) :-
    (   member(E, Res.explicacion), a_atomo(E.componente, C) -> Ap = E.aportes ; Ap = [] ).

estado_de(D, Est) :- a_atomo(D.estado, Est).
a_atomo(V, A) :- ( atom(V) -> A = V ; atom_string(A, V) ).

% ---------- Texto de cada evento ----------
eventos_dict([], []).
eventos_dict([evento(I, R, D)|Es], [_{iteracion: I, regla: R, texto: T, datos: Dd}|Ds]) :-
    texto_evento(evento(I, R, D), T), datos_dict(D, Dd),
    eventos_dict(Es, Ds).

% texto_evento(+Evento, -Texto)
texto_evento(evento(_, _, inicial(Clasif)), T) :- !,
    (   Clasif == []
    ->  T = "Estado inicial (R2-R5): ningún componente tiene evidencia con los síntomas dados."
    ;   primeros(Clasif, 3, Top), length(Clasif, N), Resto is N - 3,
        maplist(texto_clasificado, Top, Partes), unir(Partes, Lista),
        (   Resto > 0 -> format(string(Mas), " y ~d más", [Resto]) ; Mas = "" ),
        format(string(T), "Estado inicial (R2-R5): ~s~s.", [Lista, Mas])
    ).
texto_evento(evento(_, _, contradiccion(Pares)), T) :- !,
    maplist(texto_par, Pares, Partes), unir(Partes, Lista),
    format(string(T), "R2b: hay datos incompatibles: ~s. No pueden ser ciertos a la vez; corrija la entrada.", [Lista]).
texto_evento(evento(_, _, rb2_motor(_)), T) :- !,
    T = "RB2: con datos incompatibles el ciclo se detiene; la memoria de trabajo vuelve al estado anterior y el usuario debe elegir cuál de los dos es correcto.".
texto_evento(evento(_, _, rb2_restaurado(P, N)), T) :- !,
    nombre_dato(P, Np), nombre_dato(N, Nn),
    format(string(T), "RB2: al marcar ~s se detectó que es incompatible con ~s; la memoria de trabajo se restauró al estado anterior a esa entrada.",
           [Nn, Np]).
texto_evento(evento(_, _, rb2_resuelta(E, D)), T) :- !,
    nombre_dato(E, Ne), nombre_dato(D, Nd),
    format(string(T), "RB2: el usuario eligió ~s como correcto; ~s se descartó y el elegido volvió a evaluarse (R2).",
           [Ne, Nd]).
texto_evento(evento(_, _, rb2_cancelada(_, N)), T) :- !,
    nombre_dato(N, Nn),
    format(string(T), "RB2: el usuario canceló la elección; se conservó la selección anterior, sin ~s.", [Nn]).
texto_evento(evento(_, _, apilar(Punto, Cands)), T) :- !,
    maplist(comillas_componente, Cands, Ns), unir(Ns, Lista),
    format(string(T), "R7: se apila el punto de decisión ~w con los candidatos ~s, de mayor a menor probabilidad.",
           [Punto, Lista]).
texto_evento(evento(I, _, prueba(C, P, Est, Antes, Despues, Aporte)), T) :- !,
    comillas_componente(C, Nc), prueba(P, Np), porcentaje(Antes, A), porcentaje(Despues, D),
    aporte_texto(Aporte, Ap),
    (   Despues >= Antes -> Verbo = "sube" ; Verbo = "baja" ),
    format(string(T), "Iteración ~w (R7-R8): foco ~s (~s). Se realiza la prueba \"~w\" y el resultado es \"~w\" (aporte ~s al logit): ~s ~s de ~s a ~s.",
           [I, Nc, A, Np, Est, Ap, Nc, Verbo, A, D]).
texto_evento(evento(_, 'RB1', retroceso(C, P)), T) :- !,
    comillas_componente(C, Nc), porcentaje(P, Pp), parametro(tau_bajo, B), porcentaje(B, Bp),
    format(string(T), "RB1: ~s queda descartado (~s, menor o igual que el umbral de ~s). Se retrocede al punto de decisión y se pasa al siguiente candidato; el hallazgo se conserva.",
           [Nc, Pp, Bp]).
texto_evento(evento(_, 'RB3', retroceso(C, P)), T) :- !,
    comillas_componente(C, Nc), porcentaje(P, Pp), parametro(tau_alto, A), porcentaje(A, Ap),
    format(string(T), "RB3: ~s queda confirmado (~s, mayor o igual que el umbral de ~s). Se vuelve al punto de decisión para buscar otros componentes afectados.",
           [Nc, Pp, Ap]).
texto_evento(evento(_, _, sin_pruebas(C)), T) :- !,
    comillas_componente(C, Nc),
    format(string(T), "R7: ~s no tiene pruebas disponibles; se pasa al siguiente candidato.", [Nc]).
texto_evento(evento(_, _, fin(Motivo, _, I)), T) :- !,
    texto_fin(Motivo, I, T).
texto_evento(evento(_, _, acciones(Acs)), T) :- !,
    findall(S, ( member(A, Acs), porcentaje(A.relevancia, R), format(string(S), "\"~w\" (~s)", [A.nombre, R]) ),
            Partes),
    unir(Partes, Lista),
    format(string(T), "R9: acciones correctivas sobre los componentes confirmados: ~s.", [Lista]).
texto_evento(evento(_, _, aportes(C, P, Ap)), T) :-
    comillas_componente(C, Nc), porcentaje(P, Pp),
    (   Ap == []
    ->  format(string(T), "R10: ~s (~s): ningún dato aportó a favor; se confirmó por su probabilidad previa.", [Nc, Pp])
    ;   maplist(texto_aporte, Ap, Partes), unir(Partes, Lista),
        format(string(T), "R10: ~s (~s): ~s al logit.", [Nc, Pp, Lista])
    ).

texto_fin(sin_inciertos, I, T) :- !, parametro(max_iteraciones, M),
    format(string(T), "R6: no quedan componentes inciertos; parada concluyente en ~w de ~w iteraciones.", [I, M]).
texto_fin(max_iteraciones, I, T) :- !,
    format(string(T), "R6: se alcanzó el máximo de ~w iteraciones; el resultado no es concluyente.", [I]).
texto_fin(prueba_pendiente, I, T) :- !,
    format(string(T), "R7: tras ~w iteraciones falta el resultado de la prueba recomendada; el diagnóstico sigue abierto.", [I]).
texto_fin(sin_pruebas, I, T) :- !,
    format(string(T), "R7: tras ~w iteraciones no quedan pruebas para los componentes inciertos; el resultado no es concluyente.", [I]).
texto_fin(contradiccion, _, "R6: el ciclo no continúa mientras haya datos contradictorios.") :- !.
texto_fin(M, I, T) :- format(string(T), "R6: el ciclo terminó (~w) tras ~w iteraciones.", [M, I]).

texto_clasificado(P-C-Est, S) :-
    comillas_componente(C, Nc), porcentaje(P, Pp), format(string(S), "~s ~s (~w)", [Nc, Pp, Est]).
texto_par(A-B, S) :- nombre_dato(A, Na), nombre_dato(B, Nb), format(string(S), "~s y ~s", [Na, Nb]).

% texto_aporte(+Aporte, -S): un sumando del logit, con el nombre del síntoma o del hallazgo.
texto_aporte(A, S) :-
    a_atomo(A.sintoma, Sid), nombre_dato(Sid, N), aporte_texto(A.aporte, Ap),
    format(string(S), "~s aportó ~s", [N, Ap]).

% datos_dict(+Datos, -D): los números del evento, para que la interfaz no tenga que leer el texto.
datos_dict(inicial(Cl), _{componentes: Cs}) :- !,
    findall(_{id: C, probabilidad: P, estado: E}, member(P-C-E, Cl), Cs).
datos_dict(contradiccion(Pares), _{pares: Ps}) :- !, findall([A, B], member(A-B, Pares), Ps).
datos_dict(rb2_motor(Pares), _{pares: Ps}) :- !, findall([A, B], member(A-B, Pares), Ps).
datos_dict(rb2_restaurado(P, N), _{previo: P, nuevo: N, restaurado: true}) :- !.
datos_dict(rb2_resuelta(E, D), _{elegido: E, descartado: D}) :- !.
datos_dict(rb2_cancelada(P, N), _{previo: P, nuevo: N}) :- !.
datos_dict(apilar(Pt, Cs), _{punto: Pt, candidatos: Cs}) :- !.
datos_dict(prueba(C, P, E, A, D, L), _{foco: C, prueba: P, resultado: E, antes: A, despues: D, aporte: L}) :- !.
datos_dict(retroceso(C, P), _{foco: C, probabilidad: P}) :- !.
datos_dict(sin_pruebas(C), _{foco: C}) :- !.
datos_dict(fin(M, Conc, I), _{motivo: M, concluyente: Conc, iteraciones: I}) :- !.
datos_dict(acciones(As), _{acciones: Ids}) :- !, findall(Id, ( member(A, As), Id = A.id ), Ids).
datos_dict(aportes(C, P, Ap), _{componente: C, probabilidad: P, aportes: Ap}).

% ---------- Explicación por componente ----------
% componentes_texto(+Comps, +Eventos, -Lista): por qué cada componente quedó como quedó.
componentes_texto([], _, []).
componentes_texto([D|Ds], Evs, [_{componente: C, nombre: D.nombre, probabilidad: P, estado: Est,
                                  texto: T}|Ts]) :-
    a_atomo(D.id, C), estado_de(D, Est), P = D.probabilidad,
    texto_componente(Est, C, P, Evs, T),
    componentes_texto(Ds, Evs, Ts).

texto_componente(confirmado, C, P, Evs, T) :- !,
    comillas_componente(C, Nc), porcentaje(P, Pp), prior(C, Pr), porcentaje(Pr, Prp),
    (   member(evento(_, 'R10', aportes(C, _, Ap)), Evs), Ap = [_|_]
    ->  maplist(texto_aporte, Ap, Partes), unir(Partes, Lista),
        format(string(Por), "; lo que más pesó: ~s", [Lista])
    ;   Por = ""
    ),
    format(string(T), "Posible falla en ~s (~s, confirmado). Partió de una probabilidad previa de ~s~s.",
           [Nc, Pp, Prp, Por]).
texto_componente(descartado, C, P, Evs, T) :- !,
    comillas_componente(C, Nc), porcentaje(P, Pp),
    (   member(evento(_, _, prueba(C, Pr, Est, A, _, _)), Evs)
    ->  prueba(Pr, Np), porcentaje(A, Ap),
        format(string(T), "~s se descarta (~s): el resultado \"~w\" de la prueba \"~w\" lo bajó desde ~s.",
               [Nc, Pp, Est, Np, Ap])
    ;   parametro(tau_bajo, B), porcentaje(B, Bp),
        format(string(T), "~s se descarta: su probabilidad (~s) quedó por debajo de ~s con los datos dados.",
               [Nc, Pp, Bp])
    ).
texto_componente(_, C, P, _, T) :-
    comillas_componente(C, Nc), porcentaje(P, Pp),
    format(string(T), "~s sigue incierto (~s): los datos no alcanzan para confirmarlo ni descartarlo.", [Nc, Pp]).

% prior(+C, -P): probabilidad sin ningún dato (memoria de trabajo vacía).
prior(C, P) :- probabilidad(C, [], P).

% ---------- Acciones y pruebas ----------
% acciones_texto(+Acciones, +Comps, -Lista): qué componentes confirmados originan cada acción.
acciones_texto([], _, []).
acciones_texto([A|As], Comps, [_{accion: Id, nombre: A.nombre, relevancia: A.relevancia,
                                 componentes: Cs, texto: T}|Ts]) :-
    a_atomo(A.id, Id),
    findall(C-P-M, ( member(D, Comps), estado_de(D, confirmado), a_atomo(D.id, C),
                     P = D.probabilidad, accion_componente(Id, C, M) ), Origen),
    findall(C, member(C-_-_, Origen), Cs),
    maplist(texto_origen, Origen, Partes), unir(Partes, Lista), porcentaje(A.relevancia, R),
    format(string(T), "\"~w\" (relevancia ~s): atiende ~s.", [A.nombre, R, Lista]),
    acciones_texto(As, Comps, Ts).

texto_origen(C-P-M, S) :-
    comillas_componente(C, Nc), porcentaje(P, Pp), decimal(M, Mt),
    format(string(S), "~s (~s, con efectividad ~s)", [Nc, Pp, Mt]).

% pruebas_texto(+Sugeridas, +X0, -Lista): qué síntomas presentes hacen relevante cada prueba.
pruebas_texto([], _, []).
pruebas_texto([D|Ds], X0, [_{prueba: P, nombre: D.nombre, componente: C, relevancia: D.relevancia,
                              texto: T}|Ts]) :-
    a_atomo(D.prueba, P), a_atomo(D.componente, C),
    comillas_componente(C, Nc), porcentaje(D.relevancia, R),
    findall(N, ( prueba_sintoma(P, S, _), memberchk(S-presente, X0), nombre_dato(S, N) ), Ss),
    (   Ss == []
    ->  format(string(T), "Se sugiere \"~w\" (relevancia ~s) para verificar ~s.", [D.nombre, R, Nc])
    ;   unir(Ss, Lista),
        format(string(T), "Se sugiere \"~w\" (relevancia ~s) para verificar ~s, porque está presente: ~s.",
               [D.nombre, R, Nc, Lista])
    ),
    pruebas_texto(Ds, X0, Ts).

% ---------- Conclusión ----------
conclusion(Res, T) :-
    confirmados_de(Res.componentes, Conf),
    findall(N, ( member(C-_, Conf), comillas_componente(C, N) ), Ns),
    a_atomo(Res.motivo, M),
    conclusion_motivo(M, Ns, Res, T0),
    (   M == contradiccion -> T = T0
    ;   string_concat(T0, " Es una hipótesis del sistema experto, no una certeza: confírmela con un técnico.", T)
    ).

conclusion_motivo(contradiccion, _, _, "Los datos ingresados son contradictorios; corríjalos para poder diagnosticar.") :- !.
conclusion_motivo(_, [], Res, T) :- !,
    (   Res.concluyente == true
    ->  T = "No quedan hipótesis abiertas y ningún componente se confirmó."
    ;   T = "Diagnóstico no concluyente: ningún componente se confirmó todavía; realice las pruebas sugeridas."
    ).
conclusion_motivo(_, Ns, Res, T) :-
    unir(Ns, Lista),
    (   Res.concluyente == true
    ->  format(string(T), "Diagnóstico concluyente: posible falla en ~s.", [Lista])
    ;   format(string(T), "Diagnóstico no concluyente; por ahora se confirma: ~s.", [Lista])
    ).

% ---------- Utilidades de texto ----------
comillas_componente(C, S) :- componente(C, N, _, _), !, format(string(S), "\"~w\"", [N]).
comillas_componente(C, S) :- format(string(S), "\"~w\"", [C]).

% nombre_dato(+S, -Texto): un síntoma por su nombre; un hallazgo como el resultado de su prueba.
nombre_dato(S, T) :-
    sintoma(S, N, Tipo), !,
    (   Tipo == hallazgo, sub_atom(S, 0, _, _, hall_), sub_atom(S, 5, _, 0, P), prueba(P, Np)
    ->  format(string(T), "el resultado de \"~w\"", [Np])
    ;   format(string(T), "\"~w\"", [N])
    ).
nombre_dato(S, T) :- format(string(T), "\"~w\"", [S]).

% porcentaje(+P, -Texto): 0.6331 -> "63,3 %" (coma decimal).
porcentaje(P, T) :- X is P * 100, format(string(S), "~1f", [X]), coma(S, D), string_concat(D, " %", T).
% aporte_texto(+L, -Texto): 2.197 -> "+2,2"; -3.75 -> "-3,8" (un decimal, como el PDF §6).
aporte_texto(L, T) :-
    format(string(S), "~1f", [L]), coma(S, D),
    ( L >= 0 -> string_concat("+", D, T) ; T = D ).
% decimal(+X, -Texto): un decimal con coma; "0,95" conserva los dos si el segundo no es cero.
decimal(X, T) :-
    format(string(S2), "~2f", [X]),
    (   sub_string(S2, _, 1, 0, "0") -> format(string(S), "~1f", [X]) ; S = S2 ),
    coma(S, T).
coma(S, T) :- split_string(S, ".", "", Partes), atomic_list_concat(Partes, ',', A), atom_string(A, T).

% primeros(+Lista, +N, -Prefijo): los N primeros (o todos si hay menos). Recursión sobre la lista.
primeros([], _, []).
primeros([X|Xs], N, Ys) :- ( N =:= 0 -> Ys = [] ; N1 is N - 1, Ys = [X|Ys1], primeros(Xs, N1, Ys1) ).

% unir(+Partes, -Texto): ["a","b","c"] -> "a, b y c". Recursión sobre la lista.
unir([], "").
unir([A|As], T) :- unir_resto(As, A, T).
unir_resto([], A, A).
unir_resto([B], A, T) :- !, format(string(T), "~s y ~s", [A, B]).
unir_resto([B|Bs], A, T) :- unir_resto(Bs, B, R), format(string(T), "~s, ~s", [A, R]).
