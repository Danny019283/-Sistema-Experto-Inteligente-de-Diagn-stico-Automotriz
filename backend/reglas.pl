% Reglas del ciclo de inferencia (F02, PDF §4): validación de la entrada (RNF-01), R2b,
% clasificación (R5) y candidatos a foco (R6/R7). El ciclo recursivo está más abajo.
% X es la memoria de trabajo: lista de Sintoma-Estado (ver inferencia.pl).
:- module(reglas, [validar_entrada/2, contradicciones/2, tiene_evidencia/2, clasificar/2,
                   candidatos/2, confirmados/2]).
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
