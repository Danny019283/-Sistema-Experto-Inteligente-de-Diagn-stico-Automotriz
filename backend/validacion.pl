% Validación de la base de conocimiento (RNF-01).
% validar_kb(-Problemas): lista (ordenada, sin repetidos) de cadenas; [] si la KB es válida.
% validar_kb/0: éxito si es válida; si no, imprime los problemas por stderr y falla.
% Los hechos viven en `user` (backend/hechos.pl): el módulo los ve por herencia.
:- module(validacion, [validar_kb/0, validar_kb/1]).
:- discontiguous problema/1.

validar_kb(Problemas) :-
    findall(P, problema(P), Ps),
    sort(Ps, Problemas).

validar_kb :-
    validar_kb(Ps),
    (   Ps == []
    ->  true
    ;   forall(member(P, Ps), format(user_error, "KB inválida: ~s~n", [P])),
        fail
    ).

msg(Fmt, Args, P) :- format(string(P), Fmt, Args).
prob(X) :- number(X), X >= 0, X =< 1.
cnt(X)  :- integer(X), X >= 0.

% ---- ids y filas duplicadas ----
dup(Tabla, Id, Meta, P) :-
    findall(Id, Meta, Ids), msort(Ids, S), nextto(Id, Id, S),
    msg("~w: id duplicado ~q", [Tabla, Id], P).

problema(P) :- dup(sintoma, I, sintoma(I,_,_), P).
problema(P) :- dup(componente, I, componente(I,_,_,_), P).
problema(P) :- dup(accion, I, accion(I,_), P).
problema(P) :- dup(prueba, I, prueba(I,_), P).
problema(P) :- dup(componente_sintoma, C-S-E, componente_sintoma(C,S,E,_,_), P).
problema(P) :- dup(prueba_sintoma, X-S, prueba_sintoma(X,S,_), P).
problema(P) :- dup(prueba_componente, X-C, prueba_componente(X,C), P).
problema(P) :- dup(accion_componente, A-C, accion_componente(A,C,_), P).
problema(P) :- dup(incompatibilidad, A-B, incompatibilidad(A,B), P).
problema(P) :- dup(parametro, N, parametro(N,_), P).

% ---- ids referenciados que no existen ----
ref(Tabla, Tipo, Id, P) :- msg("~w: ~w inexistente ~q", [Tabla, Tipo, Id], P).

problema(P) :- componente_sintoma(C,_,_,_,_), \+ componente(C,_,_,_), ref(componente_sintoma, componente, C, P).
problema(P) :- componente_sintoma(_,S,_,_,_), \+ sintoma(S,_,_), ref(componente_sintoma, sintoma, S, P).
problema(P) :- accion_componente(A,_,_), \+ accion(A,_), ref(accion_componente, accion, A, P).
problema(P) :- accion_componente(_,C,_), \+ componente(C,_,_,_), ref(accion_componente, componente, C, P).
problema(P) :- prueba_sintoma(X,_,_), \+ prueba(X,_), ref(prueba_sintoma, prueba, X, P).
problema(P) :- prueba_sintoma(_,S,_), \+ sintoma(S,_,_), ref(prueba_sintoma, sintoma, S, P).
problema(P) :- prueba_componente(X,_), \+ prueba(X,_), ref(prueba_componente, prueba, X, P).
problema(P) :- prueba_componente(_,C), \+ componente(C,_,_,_), ref(prueba_componente, componente, C, P).

% ---- probabilidades, relevancias y efectividades en [0, 1] ----
problema(P) :- accion_componente(A,C,M), \+ prob(M),
    msg("accion_componente(~q, ~q): efectividad fuera de [0, 1]: ~q", [A,C,M], P).
problema(P) :- prueba_sintoma(X,S,R), \+ prob(R),
    msg("prueba_sintoma(~q, ~q): relevancia fuera de [0, 1]: ~q", [X,S,R], P).

% ---- conteos enteros >= 0 (y no mayores que los del componente) ----
problema(P) :- componente(C,_,Np,Nn), \+ ( cnt(Np), cnt(Nn) ),
    msg("componente ~q: conteo inválido ~q/~q", [C,Np,Nn], P).
problema(P) :- componente_sintoma(C,S,E,Po,Ne), \+ ( cnt(Po), cnt(Ne) ),
    msg("componente_sintoma(~q, ~q, ~q): conteo inválido ~q/~q", [C,S,E,Po,Ne], P).
problema(P) :-
    componente_sintoma(C,S,E,Po,Ne), cnt(Po), cnt(Ne),
    componente(C,_,Np,Nn), cnt(Np), cnt(Nn), ( Po > Np ; Ne > Nn ),
    msg("componente_sintoma(~q, ~q, ~q): ~q/~q excede los conteos del componente ~q/~q",
        [C,S,E,Po,Ne,Np,Nn], P).

% ---- estados: presente (síntoma) o normal|leve|severo (hallazgo, |Vi| = 3) ----
estado_valido(sintoma, presente).
estado_valido(hallazgo, E) :- memberchk(E, [normal, leve, severo]).

problema(P) :- componente_sintoma(C,S,E,_,_), sintoma(S,_,T), \+ estado_valido(T,E),
    msg("componente_sintoma(~q, ~q, ~q): estado inválido para un ~w", [C,S,E,T], P).
problema(P) :-
    componente_sintoma(C,H,_,_,_), sintoma(H,_,hallazgo),
    findall(E, componente_sintoma(C,H,E,_,_), Es), msort(Es, Orden),
    Orden \== [leve, normal, severo],
    msg("hallazgo ~q de ~q no tiene exactamente los estados normal, leve y severo: ~q",
        [H,C,Orden], P).
problema(P) :-
    componente_sintoma(C,H,_,_,_), sintoma(H,_,hallazgo),
    findall(E, componente_sintoma(C,H,E,_,_), Es), msort(Es, [leve, normal, severo]),
    forall(componente_sintoma(C,H,_,Po,Ne), ( cnt(Po), cnt(Ne) )),
    componente(C,_,Np,Nn), cnt(Np), cnt(Nn),
    aggregate_all(sum(Po), componente_sintoma(C,H,_,Po,_), SP),
    aggregate_all(sum(Ne), componente_sintoma(C,H,_,_,Ne), SN),
    ( SP =\= Np ; SN =\= Nn ),
    msg("hallazgo ~q de ~q: los estados suman ~q/~q y el componente tiene ~q/~q",
        [H,C,SP,SN,Np,Nn], P).

% ---- incompatibilidades entre síntomas existentes ----
problema(P) :- incompatibilidad(A,B), member(X, [A,B]), \+ sintoma(X,_,sintoma),
    msg("incompatibilidad(~q, ~q): ~q no es un síntoma existente", [A,B,X], P).
problema(P) :- incompatibilidad(A,A),
    msg("incompatibilidad(~q, ~q): un síntoma no es incompatible consigo mismo", [A,A], P).

% ---- parámetros ----
problema(P) :- member(N, [tau_alto, tau_bajo, max_iteraciones, alpha]), \+ parametro(N,_),
    msg("falta el parámetro ~q", [N], P).
problema(P) :- member(N, [tau_alto, tau_bajo]), parametro(N,V), \+ prob(V),
    msg("parámetro ~q: valor fuera de [0, 1]: ~q", [N,V], P).
problema(P) :- parametro(tau_alto,A), parametro(tau_bajo,B), prob(A), prob(B), B >= A,
    msg("parámetro tau_bajo (~q) debe ser menor que tau_alto (~q)", [B,A], P).
problema(P) :- parametro(max_iteraciones,V), \+ ( integer(V), V >= 1 ),
    msg("parámetro max_iteraciones: debe ser un entero >= 1: ~q", [V], P).
problema(P) :- parametro(alpha,V), \+ ( number(V), V > 0 ),
    msg("parámetro alpha: debe ser un número > 0: ~q", [V], P).
