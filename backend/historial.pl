% Historial de diagnósticos (F10, issue #62; PDF §3 «diagnosticos» y regla R11).
% Persistencia (RF-14) en datos/registros.txt como hechos Prolog, uno por línea:
%   diagnostico(Id, Fecha, Vehiculo, Concluyente, Motivo, Iteraciones)
%       Vehiculo = vehiculo(Marca, Modelo, Anio, Cilindrada, Combustible, Km)
%   diagnostico_resultado(Id, Clave, Valor)
%       Clave = entrada (lista Sintoma-Estado) o un campo del resultado de `diagnosticar`
%       (componentes, acciones, pruebas_sugeridas, explicacion, traza, pruebas_hechas, ...).
% Al arrancar el servidor se leen esos hechos y se agregan con assertz (hechos dinámicos), así
% el historial se conserva entre ejecuciones. Guardar agrega las líneas al final del archivo.
:- module(historial, [recordar_diagnostico/2, diagnostico_actual/2,
                      guardar_diagnostico/1, listar_diagnosticos/1,
                      cargar_diagnostico/2, cargar_registros/1, problemas_registros/1,
                      usar_registros/1, ruta_registros/1, id_guardado_actual/1,
                      diagnostico/6, diagnostico_resultado/3]).
:- use_module(vehiculo).

:- dynamic diagnostico/6, diagnostico_resultado/3.
:- dynamic ultimo_diagnostico/3.        % ultimo_diagnostico(Entrada, Resultado, Guardado)
:- dynamic ruta_actual/1, problemas_actuales/1.

% Ruta por defecto: <repo>/datos/registros.txt (relativa a este archivo, no al directorio actual).
% La variable de entorno SE_REGISTROS la reemplaza: las pruebas de integración en C y las capturas
% la usan para no tocar el historial real.
:- (   getenv('SE_REGISTROS', Ruta), Ruta \== ''
   ->  true
   ;   prolog_load_context(directory, Dir),
       atomic_list_concat([Dir, '/../datos/registros.txt'], Ruta)
   ),
   retractall(ruta_actual(_)), assertz(ruta_actual(Ruta)).

ruta_registros(Ruta) :- ruta_actual(Ruta).

% Errores propios: el servidor los convierte en {"estado":"error","error":{"codigo":Codigo,...}}.
falla(Codigo, Mensaje) :- throw(historial_error(Codigo, Mensaje)).

% ---------- Memoria del último diagnóstico ----------
% recordar_diagnostico(+Entrada, +Resultado): lo llama el servidor tras cada `diagnosticar`.
% Guardado = no hasta que se guarde; luego el Id con que quedó en el historial.
% F08: si al marcar los síntomas hubo contradicciones (RB2, retroceso.pl), sus eventos se guardan
% con el resultado en la clave `rb2`, para que la traza los narre también desde el historial.
recordar_diagnostico(Entrada, Resultado0) :-
    con_rb2(Resultado0, Resultado),
    retractall(ultimo_diagnostico(_, _, _)),
    assertz(ultimo_diagnostico(Entrada, Resultado, no)).

con_rb2(R0, R) :-
    (   \+ get_dict(rb2, R0, _),
        current_predicate(retroceso:registro_rb/1),
        findall(E, retroceso:registro_rb(E), Es), Es \== []
    ->  put_dict(rb2, R0, Es, R)
    ;   R = R0
    ).

% id_guardado_actual(-Id): número con que se guardó el último diagnóstico (falla si no se guardó).
id_guardado_actual(Id) :- ultimo_diagnostico(_, _, Id), Id \== no.

% diagnostico_actual(-Entrada, -Resultado): el último `diagnosticar` (falla si no hay ninguno).
diagnostico_actual(Entrada, Resultado) :- ultimo_diagnostico(Entrada, Resultado, _).

% ---------- Guardar (R11) ----------
% guardar_diagnostico(-Resumen): guarda el último diagnóstico con el vehículo registrado.
% RNF-01: sin diagnóstico calculado, sin vehículo o ya guardado -> error y no se escribe nada.
% RNF-02: si el archivo no se puede escribir, la memoria queda como estaba (se escribe primero).
guardar_diagnostico(Resumen) :-
    (   ultimo_diagnostico(Entrada, Res, Guardado) -> true
    ;   falla(sin_diagnostico, "Primero genere un diagnóstico")
    ),
    (   Guardado == no -> true
    ;   format(string(M), "este diagnóstico ya se guardó con el id ~w", [Guardado]),
        falla(ya_guardado, M)
    ),
    (   vehiculo(Ma, Mo, A, Ci, Co, Km) -> V = vehiculo(Ma, Mo, A, Ci, Co, Km)
    ;   falla(sin_vehiculo, "Registre el vehículo antes de guardar el diagnóstico")
    ),
    siguiente_id(Id), fecha_actual(Fecha),
    terminos_registro(Id, Fecha, V, Entrada, Res, Terminos),
    escribir_terminos(Terminos),
    afirmar_lista(Terminos),
    retractall(ultimo_diagnostico(_, _, _)),
    assertz(ultimo_diagnostico(Entrada, Res, Id)),
    resumen(Id, Resumen).

siguiente_id(Id) :-
    findall(I, diagnostico(I, _, _, _, _, _), Ids),
    maximo(Ids, 0, Max), Id is Max + 1.

% maximo(+Lista, +Acum, -Max): recursión sobre la lista; caso base la lista vacía.
maximo([], M, M).
maximo([X|Xs], M0, M) :- M1 is max(X, M0), maximo(Xs, M1, M).

fecha_actual(Fecha) :- get_time(T), format_time(string(Fecha), "%Y-%m-%d %H:%M:%S", T).

% terminos_registro(+Id, +Fecha, +V, +Entrada, +Res, -Terminos): la cabecera y un
% diagnostico_resultado por campo. concluyente, motivo e iteraciones van en la cabecera.
terminos_registro(Id, Fecha, V, Entrada, Res, [Cab, diagnostico_resultado(Id, entrada, Entrada)|Rs]) :-
    Cab = diagnostico(Id, Fecha, V, Res.concluyente, Res.motivo, Res.iteraciones),
    dict_pairs(Res, _, Pares),
    campos_resultado(Pares, Id, Rs).

% campos_resultado(+Pares, +Id, -Terminos): recursión sobre los pares Clave-Valor.
campos_resultado([], _, []).
campos_resultado([K-_|Ps], Id, Ts) :-
    memberchk(K, [concluyente, motivo, iteraciones]), !,
    campos_resultado(Ps, Id, Ts).
campos_resultado([K-V|Ps], Id, [diagnostico_resultado(Id, K, V)|Ts]) :-
    campos_resultado(Ps, Id, Ts).

afirmar_lista([]).
afirmar_lista([T|Ts]) :- assertz(T), afirmar_lista(Ts).

% ---------- Escritura del archivo ----------
% escribir_terminos(+Terminos): agrega al final; crea la carpeta y el archivo si faltan.
escribir_terminos(Terminos) :-
    ruta_actual(Ruta),
    catch(( file_directory_name(Ruta, Dir), make_directory_path(Dir),
            ( exists_file(Ruta) -> Nuevo = false ; Nuevo = true ),
            setup_call_cleanup(open(Ruta, append, S, [encoding(utf8)]),
                               ( encabezado(Nuevo, S), escribir_lista(Terminos, S) ),
                               close(S)) ),
          E,
          ( message_to_codes_texto(E, Txt),
            format(string(M), "no se pudo escribir ~w: ~s", [Ruta, Txt]),
            falla(error_escritura, M) )).

encabezado(false, _).
encabezado(true, S) :-
    format(S, "% Historial de diagnósticos (generado por backend/historial.pl, no editar a mano).~n", []).

% escribir_lista(+Terminos, +S): un hecho por línea; recursión hasta la lista vacía.
% La lista va primero: Prolog indexa por el primer argumento y así elige la cláusula sin dejar
% un punto de elección; si quedara uno, setup_call_cleanup no cerraría (ni vaciaría) el archivo.
escribir_lista([], _).
escribir_lista([T|Ts], S) :- format(S, "~q.~n", [T]), escribir_lista(Ts, S).

message_to_codes_texto(E, Txt) :-
    (   E = error(Formal, _) -> format(string(Txt), "~w", [Formal]) ; format(string(Txt), "~w", [E]) ).

% ---------- Lectura del archivo (al arrancar) ----------
% cargar_registros(-Problemas): reemplaza el historial en memoria por el del archivo.
% Archivo ausente -> historial vacío. Líneas dañadas o con formato inválido se saltan y se
% informan en Problemas (RNF-02: no se pierden los registros válidos).
cargar_registros(Problemas) :-
    retractall(diagnostico(_, _, _, _, _, _)),
    retractall(diagnostico_resultado(_, _, _)),
    ruta_actual(Ruta),
    (   exists_file(Ruta)
    ->  catch(setup_call_cleanup(open(Ruta, read, In, [encoding(utf8)]),
                                 leer_terminos(In, Problemas),
                                 close(In)),
              E, ( message_to_codes_texto(E, Txt),
                   format(string(P), "no se pudo leer ~w: ~s", [Ruta, Txt]),
                   Problemas = [P] ))
    ;   Problemas = []
    ),
    retractall(problemas_actuales(_)), assertz(problemas_actuales(Problemas)).

problemas_registros(Ps) :- ( problemas_actuales(Ps) -> true ; Ps = [] ).

% usar_registros(+Ruta): cambia el archivo (las pruebas usan uno temporal) y lo carga.
usar_registros(Ruta) :-
    retractall(ruta_actual(_)), assertz(ruta_actual(Ruta)),
    retractall(ultimo_diagnostico(_, _, _)),
    cargar_registros(_).

% leer_terminos(+In, -Problemas): lee un término por vuelta (recursión). Caso base: fin del
% archivo. Un error de sintaxis no detiene la lectura: read_term continúa con el siguiente.
leer_terminos(In, Problemas) :-
    catch(read_term(In, T, [double_quotes(string)]), E, true),
    (   nonvar(E)
    ->  error_sintaxis(E, P), Problemas = [P|Ps], leer_terminos(In, Ps)
    ;   T == end_of_file
    ->  Problemas = []
    ;   validar_termino(T, Ok)
    ->  (   Ok == ok -> assertz(T), Problemas = Ps ; Problemas = [Ok|Ps] ),
        leer_terminos(In, Ps)
    ).

error_sintaxis(error(syntax_error(Que), Donde), P) :-
    (   ( Donde = file(_, L, _, _) ; Donde = stream(_, L, _, _) ) -> true ; L = "?" ), !,
    format(string(P), "línea ~w: error de sintaxis (~w)", [L, Que]).
error_sintaxis(E, P) :- format(string(P), "error al leer: ~q", [E]).

% validar_termino(+T, -Ok): Ok = ok, o el texto del problema. El orden importa: la cabecera
% diagnostico/6 va antes que sus diagnostico_resultado/3.
validar_termino(diagnostico(Id, F, V, C, M, I), Ok) :- !,
    (   \+ ( integer(Id), Id > 0 ) -> fmt(Ok, "id inválido: ~q", [Id])
    ;   diagnostico(Id, _, _, _, _, _) -> fmt(Ok, "id repetido: ~w", [Id])
    ;   \+ string(F) -> fmt(Ok, "diagnóstico ~w: fecha inválida", [Id])
    ;   \+ vehiculo_valido(V) -> fmt(Ok, "diagnóstico ~w: vehículo inválido", [Id])
    ;   \+ memberchk(C, [true, false]) -> fmt(Ok, "diagnóstico ~w: concluyente inválido", [Id])
    ;   \+ atom(M) -> fmt(Ok, "diagnóstico ~w: motivo inválido", [Id])
    ;   \+ ( integer(I), I >= 0 ) -> fmt(Ok, "diagnóstico ~w: iteraciones inválidas", [Id])
    ;   Ok = ok
    ).
validar_termino(diagnostico_resultado(Id, K, _), Ok) :- !,
    (   \+ atom(K) -> fmt(Ok, "resultado de ~q: clave inválida", [Id])
    ;   \+ diagnostico(Id, _, _, _, _, _) -> fmt(Ok, "resultado de un diagnóstico inexistente: ~q", [Id])
    ;   diagnostico_resultado(Id, K, _) -> fmt(Ok, "diagnóstico ~w: campo repetido ~w", [Id, K])
    ;   Ok = ok
    ).
validar_termino(T, Ok) :- fmt(Ok, "término desconocido: ~q", [T]).

vehiculo_valido(vehiculo(Ma, Mo, A, Ci, Co, Km)) :-
    string(Ma), string(Mo), integer(A), string(Ci), atom(Co), integer(Km).

fmt(S, F, A) :- format(string(S), F, A).

% ---------- Consultas ----------
% listar_diagnosticos(-Lista): un resumen por diagnóstico guardado, del más antiguo al más nuevo.
listar_diagnosticos(Lista) :-
    findall(Id, diagnostico(Id, _, _, _, _, _), Ids0), msort(Ids0, Ids),
    resumenes(Ids, Lista).

resumenes([], []).
resumenes([Id|Ids], [R|Rs]) :- resumen(Id, R), resumenes(Ids, Rs).

% resumen(+Id, -R): datos para la lista de la interfaz; `principal` es el componente más probable.
resumen(Id, R) :-
    diagnostico(Id, Fecha, vehiculo(Ma, Mo, A, _, _, _), C, M, I),
    format(string(Veh), "~w ~w ~w", [Ma, Mo, A]),
    (   diagnostico_resultado(Id, componentes, [P|_])
    ->  Principal = P.nombre, Prob = P.probabilidad
    ;   Principal = null, Prob = null
    ),
    R = _{id: Id, fecha: Fecha, vehiculo: Veh, concluyente: C, motivo: M, iteraciones: I,
          principal: Principal, probabilidad: Prob}.

% cargar_diagnostico(+Id, -D): el diagnóstico guardado tal como se generó.
cargar_diagnostico(Id, D) :-
    (   diagnostico(Id, Fecha, vehiculo(Ma, Mo, A, Ci, Co, Km), C, M, I) -> true
    ;   format(string(Msg), "no existe el diagnóstico ~w", [Id]), falla(no_encontrado, Msg)
    ),
    (   diagnostico_resultado(Id, entrada, Entrada) -> true ; Entrada = [] ),
    findall(K-V, ( diagnostico_resultado(Id, K, V), K \== entrada ), Campos),
    dict_pairs(Res, _, [concluyente-C, motivo-M, iteraciones-I|Campos]),
    dict_pairs(EntradaD, _, Entrada),
    D = _{id: Id, fecha: Fecha,
          vehiculo: _{marca: Ma, modelo: Mo, anio: A, cilindrada: Ci, combustible: Co,
                      kilometraje: Km},
          entrada: EntradaD, resultado: Res}.
