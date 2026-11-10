% F13 · Reporte textual de un diagnóstico guardado (issue #66; RF-15).
%
% Operación del contrato JSON (ver README):
%   reporte_textual {}        -> [ {id, texto} ]  del último diagnóstico, si ya se guardó
%   reporte_textual {id: N}   -> [ {id, texto} ]  de un diagnóstico del historial
% El texto se arma desde el registro guardado (historial.pl, F10): coincide con lo que se guardó y
% con lo que muestra la interfaz. Los textos de la traza, las acciones y la conclusión son los de
% `explicar` (explicaciones.pl, F08). C lo muestra y lo escribe en datos/reportes/.
% RNF-01: sin diagnóstico guardado no hay reporte (sin_guardar / no_encontrado).
% Texto plano, sin comillas tipográficas ni símbolos especiales: se lee en cualquier editor.
:- module(reporte, [reporte_textual/2]).
:- use_module(historial).
:- use_module(explicaciones).

:- multifile servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.
:- discontiguous servidor_json:operacion_conocida/1, servidor_json:ejecutar/3.

servidor_json:operacion_conocida(reporte_textual).
servidor_json:ejecutar(reporte_textual, Args, [_{id: Id, texto: T}]) :-
    (   get_dict(id, Args, Id)
    ->  (   integer(Id) -> true ; throw(entrada_invalida(["id: debe ser un número entero"])) )
    ;   id_guardado_actual(Id) -> true
    ;   diagnostico_actual(_, _)
    ->  throw(historial_error(sin_guardar, "Guarde el diagnóstico antes de generar el reporte"))
    ;   throw(historial_error(sin_diagnostico, "Primero genere un diagnóstico"))
    ),
    reporte_textual(Id, T).

%% reporte_textual(+Id, -Texto): el reporte del diagnóstico guardado Id (no_encontrado si no existe).
reporte_textual(Id, Texto) :-
    cargar_diagnostico(Id, D),
    ( diagnostico_resultado(Id, entrada, Entrada) -> true ; Entrada = [] ),
    Res = D.resultado,
    once(explicar(Entrada, Res, X)),
    once(lineas(D, Entrada, Res, X, Ls)),
    atomic_list_concat(Ls, '\n', A),
    atom_string(A, Texto).

lineas(D, Entrada, Res, X, Ls) :-
    V = D.vehiculo,
    format(string(Veh), "~w ~w ~w, ~w, ~w, ~w km",
           [V.marca, V.modelo, V.anio, V.cilindrada, V.combustible, V.kilometraje]),
    format(string(L1), "Diagnóstico número: ~w", [D.id]),
    format(string(L2), "Fecha: ~w", [D.fecha]),
    format(string(L3), "Vehículo: ~s", [Veh]),
    sintomas(Entrada, Ss),
    realizadas(Res.pruebas_hechas, Entrada, 1, Ps),
    componentes(Res.componentes, 1, Cs),
    acciones(X.acciones, 1, As),
    traza(X.traza, Ts),
    estado_final(Res, X, Fs),
    append([ ["REPORTE DE DIAGNÓSTICO", "Sistema experto de diagnóstico automotriz",
              "==========================================", L1, L2, L3, ""],
             ["SÍNTOMAS INGRESADOS"], Ss, [""],
             ["PRUEBAS REALIZADAS"], Ps, [""],
             ["COMPONENTES (de mayor a menor probabilidad)"], Cs, [""],
             ["ACCIONES CORRECTIVAS (por relevancia Ra)"], As, [""],
             ["TRAZA RESUMIDA DEL RAZONAMIENTO"], Ts, [""],
             ["ESTADO FINAL"], Fs ], Ls).

% ---------- secciones (recursión sobre cada lista; el caso vacío lo dice, no queda en blanco) ----------

%% sintomas(+Entrada, -Lineas): solo los síntomas (los hallazgos van en pruebas realizadas).
sintomas(Entrada, Ls) :-
    sintomas_(Entrada, Ls0),
    ( Ls0 == [] -> Ls = ["- Ninguno."] ; Ls = Ls0 ).
sintomas_([], []).
sintomas_([S-E|Es], [L|Ls]) :-
    sintoma(S, N, sintoma), !,
    format(string(L), "- ~w: ~w", [N, E]),
    sintomas_(Es, Ls).
sintomas_([_|Es], Ls) :- sintomas_(Es, Ls).

%% realizadas(+Hechas, +Entrada, +I, -Lineas): las pruebas que aplicó el motor, con su resultado.
realizadas([], _, 1, ["- Ninguna."]) :- !.
realizadas([], _, _, []).
realizadas([P0|Ps], Entrada, I, [L|Ls]) :-
    atomo(P0, P), prueba(P, N),
    ( prueba_componente(P, C), componente(C, Nc, _, _) -> true ; Nc = "?" ), !,
    atom_concat(hall_, P, H), ( memberchk(H-Est, Entrada) -> true ; Est = "?" ),
    format(string(L), "~w. ~w (~w): ~w", [I, N, Nc, Est]),
    I1 is I + 1,
    realizadas(Ps, Entrada, I1, Ls).

%% componentes(+Comps, +I, -Lineas): el ranking con probabilidad y estado.
componentes([], 1, ["- Sin resultados: ningún componente tiene evidencia con los datos ingresados."]) :- !.
componentes([], _, []).
componentes([C|Cs], I, [L|Ls]) :-
    porcentaje(C.probabilidad, P),
    ( get_dict(sistema, C, S) -> format(string(Sis), " (~w)", [S]) ; Sis = "" ),
    format(string(L), "~t~w~3|. ~w~s: ~s, ~w", [I, C.nombre, Sis, P, C.estado]),
    I1 is I + 1,
    componentes(Cs, I1, Ls).

%% acciones(+Acciones, +I, -Lineas): las de explicar (Ra y los confirmados que las originan).
acciones([], 1, ["- Sin acciones: ningún componente confirmado."]) :- !.
acciones([], _, []).
acciones([A|As], I, [L|Ls]) :-
    format(string(L), "~w. ~s", [I, A.texto]),
    I1 is I + 1,
    acciones(As, I1, Ls).

%% traza(+Eventos, -Lineas): un renglón por evento (el texto ya lleva la regla).
traza([], ["- Sin eventos."]) :- !.
traza(Es, Ls) :- traza_(Es, Ls).
traza_([], []).
traza_([E|Es], [L|Ls]) :-
    format(string(L), "- ~s", [E.texto]),
    traza_(Es, Ls).

estado_final(Res, X, [L1, L2]) :-
    ( Res.concluyente == true -> E = "Concluyente" ; E = "No concluyente" ),
    ( get_dict(max_iteraciones, Res, Max) -> true ; parametro(max_iteraciones, Max) ),
    format(string(L1), "~s, con ~w de ~w iteraciones.", [E, Res.iteraciones, Max]),
    L2 = X.conclusion.

atomo(V, A) :- ( atom(V) -> A = V ; atom_string(A, V) ).
