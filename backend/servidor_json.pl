% Servidor JSON: una línea JSON por stdin -> una línea JSON por stdout.
% Petición:  {"id": N, "op": "...", "args": {...}}
% Respuesta: {"id": N, "estado": "ok|sin_resultados|error", "resultados": [...],
%             "error": {"codigo": "...", "mensaje": "..."}}   (error solo si estado=error;
%             kb_invalida añade "problemas": [cadenas])
:- module(servidor_json, [main/0, procesar_linea/2]).
:- use_module(library(http/json)).
:- use_module(validacion).
:- use_module(reglas).
:- use_module(vehiculo).
:- use_module(sistemas).       % F05/F06: sistema por componente y síntoma
% La KB son hechos de `user`: se carga ahí, no dentro de este módulo.
:- user:consult(hechos).

% Arranque: swipl -q -g main -t halt backend/servidor_json.pl (lo lanza conexion.c).
% No usa initialization(main, main): se dispararía también al cargarlo desde los tests.

main :-
    set_stream(user_input, encoding(utf8)),
    set_stream(user_output, encoding(utf8)),
    bucle.

bucle :-
    read_line_to_string(user_input, Linea),
    (   Linea == end_of_file
    ->  true
    ;   procesar_linea(Linea, Resp),
        json_write_dict(user_output, Resp, [width(0)]),
        nl(user_output), flush_output(user_output),
        bucle
    ).

% procesar_linea(+Linea, -RespuestaDict): valida el mensaje y lo despacha.
procesar_linea(Linea, Resp) :-
    (   catch(atom_json_dict(Linea, Msg, []), _, fail), is_dict(Msg),
        get_dict(id, Msg, Id), get_dict(op, Msg, Op), string(Op)
    ->  ( get_dict(args, Msg, Args) -> true ; Args = _{} ),
        (   \+ is_dict(Args)
        ->  error(Id, args_invalidos, "args debe ser un objeto JSON", Resp)
        ;   atom_string(OpA, Op),
            (   operacion_conocida(OpA)
            ->  despachar(Id, OpA, Args, Resp)
            ;   format(string(M), "operación desconocida: ~s", [Op]),
                error(Id, op_desconocida, M, Resp)
            )
        )
    ;   error(null, json_invalido, "mensaje JSON mal formado o sin id/op", Resp)
    ).

:- multifile operacion_conocida/1, ejecutar/3.
:- discontiguous operacion_conocida/1, ejecutar/3.
% Las features añaden sus operaciones con cláusulas multifile (ver ops_sintomas.pl y
% retroceso.pl). Un error de dominio se lanza con throw(error_contrato(Codigo, Mensaje)).
operacion_conocida(ping).
operacion_conocida(diagnosticar).
operacion_conocida(registrar_vehiculo).
operacion_conocida(consultar_vehiculo).

% RNF-02: con la KB inválida toda operación conocida responde kb_invalida (se valida
% en cada petición: la KB es chica y así también se detectan cambios en caliente).
despachar(Id, Op, Args, Resp) :-
    validar_kb(Problemas),
    (   Problemas \== []
    ->  Resp = _{id: Id, estado: error, resultados: [],
                 error: _{codigo: kb_invalida,
                          mensaje: "la base de conocimiento es inválida",
                          problemas: Problemas}}
    ;   (   catch(ejecutar(Op, Args, Res), E, true) -> true ; E = operacion_fallida ),
        (   var(E)
        ->  estado_resultados(Res, Estado),
            Resp = _{id: Id, estado: Estado, resultados: Res}
        ;   E = entrada_invalida(Ps)
        ->  Resp = _{id: Id, estado: error, resultados: [],
                     error: _{codigo: entrada_invalida,
                              mensaje: "la entrada no es válida", problemas: Ps}}
        ;   E = error_contrato(Codigo, Mensaje)
        ->  error(Id, Codigo, Mensaje, Resp)
        ;   message_to_string(E, M),
            error(Id, excepcion_prolog, M, Resp)
        )
    ).

estado_resultados([], sin_resultados) :- !.
estado_resultados(_, ok).

ejecutar(ping, _, [_{mensaje: "pong"}]).
% diagnosticar: args {"sintomas": {"<id>": "presente|ausente|desconocido", ...},
%                     "hallazgos": {"hall_<prueba>": "normal|leve|severo", ...}}   (hallazgos opcional)
% Sin síntomas -> sin_resultados; entrada inválida -> error entrada_invalida con "problemas".
ejecutar(diagnosticar, Args, Res) :-
    entrada_args(Args, Entrada),
    validar_entrada(Entrada, Problemas),
    (   Problemas \== [] -> throw(entrada_invalida(Problemas))
    ;   \+ ( member(S-_, Entrada), sintoma(S, _, sintoma) ) -> Res = []
    ;   diagnosticar(Entrada, R0), enriquecer_diagnostico(R0, R), Res = [R]
    ).

% registrar_vehiculo: args {marca, modelo, anio, cilindrada, combustible, kilometraje}; reemplaza el
% registro anterior y devuelve el vehículo. Campos inválidos -> error entrada_invalida.
ejecutar(registrar_vehiculo, Args, [V]) :- registrar_vehiculo(Args, V).
% consultar_vehiculo: el vehículo registrado, o sin_resultados si no hay.
ejecutar(consultar_vehiculo, _, Res) :- ( consultar_vehiculo(V) -> Res = [V] ; Res = [] ).

% Pares Sintoma-Estado desde dos objetos JSON; lo mal formado queda como término que
% validar_entrada rechaza (objeto con valores no-cadena, o args que no son objetos).
entrada_args(Args, Entrada) :-
    forall(( member(Clave, [sintomas, hallazgos]), get_dict(Clave, Args, D), \+ is_dict(D) ),
           ( format(string(M), "~w debe ser un objeto JSON", [Clave]),
             throw(entrada_invalida([M])) )),
    findall(S-E, ( member(Clave, [sintomas, hallazgos]), get_dict(Clave, Args, D), is_dict(D),
                   get_dict(K, D, V), atom_string(S, K), valor_atomo(V, E) ), Entrada).
valor_atomo(V, E) :- ( string(V) -> atom_string(E, V) ; E = V ).

error(Id, Codigo, Mensaje, _{id: Id, estado: error, resultados: [],
                             error: _{codigo: Codigo, mensaje: Mensaje}}).

message_to_string(E, S) :- format(string(S), "~p", [E]).

% Operaciones de F05 (síntomas) y F11 (RB2): se cargan al final, ya existen los puntos multifile.
:- use_module(ops_sintomas).
:- use_module(retroceso).
