:- encoding(utf8).
% Memoria de trabajo X (PDF §3): estado de cada síntoma/hallazgo observado.
% Se guarda como lista ordenada por inserción de Id-Estado, con Estado en
% {presente, ausente, desconocido}. Un síntoma que no aparece equivale a
% desconocido. El motor (F02) debe leer la entrada con x_para_motor/1:
% desconocido NO entra en el cálculo (queda el prior, PDF §2.1).
:- module(memoria_x, [
    x_obtener/1,      % -Lista        todo lo marcado (incluye desconocido)
    x_para_motor/1,   % -Lista        solo presente/ausente
    x_fijar/1,        % +Lista        reemplaza X completa
    x_poner/2,        % +Id, +Estado  agrega o reemplaza conservando la posición
    x_quitar/1,       % +Id           elimina (falla si no estaba)
    x_limpiar/0,
    estado_valido/1   % ?Estado
]).

:- dynamic x_actual/1.
x_actual([]).

estado_valido(presente).
estado_valido(ausente).
estado_valido(desconocido).

x_obtener(X) :- x_actual(X).

x_para_motor(Calculo) :-
    x_actual(X),
    findall(Id-E, (member(Id-E, X), E \== desconocido), Calculo).

x_fijar(X) :- retractall(x_actual(_)), assertz(x_actual(X)).

x_limpiar :- x_fijar([]).

x_poner(Id, Estado) :-
    x_actual(X0),
    (   selectchk(Id-_, X0, _)
    ->  maplist(reemplazar(Id, Estado), X0, X)
    ;   append(X0, [Id-Estado], X)
    ),
    x_fijar(X).

reemplazar(Id, Estado, Id-_, Id-Estado) :- !.
reemplazar(_, _, Par, Par).

x_quitar(Id) :-
    x_actual(X0),
    selectchk(Id-_, X0, X),
    x_fijar(X).
