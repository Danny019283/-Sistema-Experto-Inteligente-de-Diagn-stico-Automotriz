% Cálculo del motor (F02, PDF §2): capa 1 síntomas -> componentes (Naive Bayes binario con
% Laplace, en log-odds). Los hechos de la KB viven en `user` (backend/hechos.pl).
% X (memoria de trabajo) es una lista de Sintoma-Estado, Estado = presente|ausente|desconocido
% para síntomas, o un estado del hallazgo (normal|leve|severo).
:- module(inferencia, [verosimilitud/4, contribucion/4, contribuciones/3, logit/3,
                       probabilidad/3, estado_componente/2, sumar/2,
                       relevancia_prueba/3, pruebas_del_componente/4,
                       relevancia_accion/3, acciones_ordenadas/2]).

% RNF-01: las probabilidades se acotan para que ln(0) no pueda ocurrir.
epsilon(1.0e-9).
acotar(P, Q) :- epsilon(E), Q is min(1 - E, max(E, P)).

alfa(A) :- parametro(alpha, A).

% |Vi|: 2 estados para un síntoma binario, 3 para un hallazgo (normal / leve / severo).
tam_valores(S, V) :- sintoma(S, _, T), ( T == hallazgo -> V = 3 ; V = 2 ).

% verosimilitud(+C, +S, +Estado, -PosNeg): PosNeg = P(s|C+)-P(s|C-) con Laplace.
% Falla si la KB no tiene fila de (C, S, Estado): ese dato no aporta.
verosimilitud(C, S, E, PP-PN) :-
    componente(C, _, Np, Nn), componente_sintoma(C, S, E, N1, N2),
    tam_valores(S, V), alfa(A),
    PP is (N1 + A) / (Np + A * V),
    PN is (N2 + A) / (Nn + A * V).

% contribucion(+C, +S, +Estado, -Ln): sumando de la ecuación del logit (explica el razonamiento).
contribucion(_, _, desconocido, 0) :- !.
contribucion(C, S, ausente, L) :-
    verosimilitud(C, S, presente, PP-PN), !,
    acotar(1 - PP, Q1), acotar(1 - PN, Q2), L is log(Q1 / Q2).
contribucion(C, S, E, L) :-
    E \== ausente, verosimilitud(C, S, E, PP-PN), !,
    acotar(PP, Q1), acotar(PN, Q2), L is log(Q1 / Q2).
contribucion(_, _, _, 0).      % sin fila para este componente: queda el prior

% contribuciones(+C, +X, -Lista): Lista de S-Ln, una por entrada de X.
contribuciones(_, [], []).
contribuciones(C, [S-E|X], [S-L|Ls]) :- contribucion(C, S, E, L), contribuciones(C, X, Ls).

% Suma por recursión sobre la lista.
sumar([], 0).
sumar([N|Ns], T) :- sumar(Ns, T0), T is T0 + N.

% logit(+C, +X, -L): ln(prior/(1-prior)) + suma de contribuciones.
logit(C, X, L) :-
    componente(C, _, Np, Nn), alfa(A),
    acotar((Np + A) / (Np + Nn + 2 * A), Pr),
    contribuciones(C, X, Cs), findall(L1, member(_-L1, Cs), Ls), sumar(Ls, Suma),
    L is log(Pr / (1 - Pr)) + Suma.

% P(C|S) = 1 / (1 + e^-logit)
probabilidad(C, X, P) :- logit(C, X, L), P is 1 / (1 + exp(-L)).

% estado_componente(+P, -Estado): regla de decisión con tau_alto / tau_bajo.
estado_componente(P, Estado) :-
    parametro(tau_alto, Alto), parametro(tau_bajo, Bajo),
    (   P >= Alto -> Estado = confirmado
    ;   P =< Bajo -> Estado = descartado
    ;   Estado = incierto
    ).

% ---------- Capa 2: síntomas -> pruebas (noisy-OR, PDF §2.2) ----------
% Complemento por recursión: producto de (1 - Ti) sobre una lista de términos Ti.
complemento([], 1).
complemento([T|Ts], Pr) :- complemento(Ts, Pr0), Pr is Pr0 * (1 - T).

% relevancia_prueba(+Prueba, +X, -Rp): Rp = 1 - prod(1 - xs*Aps), xs = 1 si el síntoma está presente.
relevancia_prueba(Prueba, X, R) :-
    prueba(Prueba, _),
    findall(A, ( prueba_sintoma(Prueba, S, A), memberchk(S-presente, X) ), As),
    complemento(As, Pr), R is 1 - Pr.

% pruebas_del_componente(+C, +X, +Hechas, -Lista): R-Prueba de las pruebas que verifican C,
% sin las ya realizadas, de mayor a menor relevancia.
pruebas_del_componente(C, X, Hechas, Lista) :-
    findall(R-P, ( prueba_componente(P, C), \+ memberchk(P, Hechas), relevancia_prueba(P, X, R) ), L0),
    sort(1, @>=, L0, Lista).

% ---------- Capa 3: componentes -> acciones (noisy-OR, PDF §2.3) ----------
% relevancia_accion(+Accion, +Confirmados, -Ra): Confirmados = lista C-P (P = P(C|S)).
% Ra = 1 - prod(1 - P*Maj) solo sobre los componentes confirmados que la acción atiende.
relevancia_accion(Accion, Confirmados, R) :-
    accion(Accion, _),
    findall(T, ( member(C-P, Confirmados), accion_componente(Accion, C, M), T is P * M ), Ts),
    complemento(Ts, Pr), R is 1 - Pr.

% acciones_ordenadas(+Confirmados, -Lista): R-Accion con R > 0, de mayor a menor.
acciones_ordenadas(Confirmados, Lista) :-
    findall(R-A, ( accion(A, _), relevancia_accion(A, Confirmados, R), R > 0 ), L0),
    sort(1, @>=, L0, Lista).
