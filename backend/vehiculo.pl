% Vehículo de la sesión (F04): hecho dinámico vehiculo/6, un único registro.
%   vehiculo(Marca, Modelo, Anio, Cilindrada, Combustible, Km)
% registrar_vehiculo(+Args, -V): valida (RNF-01), reemplaza el registro anterior y devuelve el
% vehículo como diccionario; si hay campos inválidos lanza entrada_invalida(Problemas), con un
% texto "campo: motivo" por problema.
:- module(vehiculo, [registrar_vehiculo/2, consultar_vehiculo/1, vehiculo/6]).

:- dynamic vehiculo/6.

combustible_valido(C) :- memberchk(C, [gasolina, diesel, hibrido, electrico, gas]).
max_texto(40).
anio_minimo(1950).
km_maximo(3000000).

consultar_vehiculo(V) :-
    vehiculo(Ma, Mo, A, Mt, Co, Km),
    V = _{marca: Ma, modelo: Mo, anio: A, cilindrada: Mt, combustible: Co, kilometraje: Km}.

registrar_vehiculo(Args, V) :-
    campos(Args, Ma, Mo, A, Mt, Co, Km, Ps),
    (   Ps == []
    ->  retractall(vehiculo(_, _, _, _, _, _)),
        assertz(vehiculo(Ma, Mo, A, Mt, Co, Km)),
        consultar_vehiculo(V)
    ;   throw(entrada_invalida(Ps))
    ).

% Un problema por campo como máximo; los textos válidos quedan recortados.
campos(Args, Ma, Mo, A, Mt, Co, Km, Ps) :-
    texto(Args, marca, Ma, P1), texto(Args, modelo, Mo, P2),
    entero(Args, anio, A, P3), texto(Args, cilindrada, Mt, P4),
    combustible(Args, Co, P5), entero(Args, kilometraje, Km, P6),
    exclude(==(ok), [P1, P2, P3, P4, P5, P6], Ps).

texto(Args, Campo, Valor, P) :-
    (   get_dict(Campo, Args, V), string(V)
    ->  split_string(V, "", " \t", [Valor]),
        max_texto(Max), string_length(Valor, Len),
        (   Valor == "" -> msg(Campo, "no puede estar vacío", P)
        ;   Len > Max -> msg(Campo, "supera los ~d caracteres", [Max], P)
        ;   sub_string(Valor, _, 1, _, Ch), string_code(1, Ch, Cod), code_type(Cod, cntrl)
        ->  msg(Campo, "no admite caracteres de control", P)
        ;   P = ok
        )
    ;   msg(Campo, "debe ser un texto", P)
    ).

entero(Args, anio, V, P) :- !,
    get_time(T), stamp_date_time(T, date(Y, _, _, _, _, _, _, _, _), local),
    Max is Y + 1, anio_minimo(Min),
    entre(Args, anio, Min, Max, V, P).
entero(Args, kilometraje, V, P) :- km_maximo(Max), entre(Args, kilometraje, 0, Max, V, P).

entre(Args, Campo, Min, Max, V, P) :-
    (   get_dict(Campo, Args, V), integer(V)
    ->  (   between(Min, Max, V) -> P = ok
        ;   msg(Campo, "debe estar entre ~d y ~d", [Min, Max], P)
        )
    ;   msg(Campo, "debe ser un número entero", P)
    ).

combustible(Args, Co, P) :-
    (   get_dict(combustible, Args, V), string(V), atom_string(Co, V), combustible_valido(Co)
    ->  P = ok
    ;   msg(combustible, "debe ser gasolina, diesel, hibrido, electrico o gas", P)
    ).

msg(Campo, Fmt, P) :- msg(Campo, Fmt, [], P).
msg(Campo, Fmt, Args, P) :-
    format(string(Txt), Fmt, Args), format(string(P), "~w: ~s", [Campo, Txt]).
