% Servidor JSON: una línea JSON por stdin -> una línea JSON por stdout.
% Petición:  {"id": N, "op": "...", "args": {...}}
% Respuesta: {"id": N, "estado": "ok|sin_resultados|error", "resultados": [...],
%             "error": {"codigo": "...", "mensaje": "..."}}   (error solo si estado=error;
%             kb_invalida añade "problemas": [cadenas])
:- module(servidor_json, [main/0, procesar_linea/2]).
:- use_module(library(http/json)).
:- use_module(validacion).
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

operacion_conocida(ping).

% RNF-02: con la KB inválida toda operación conocida responde kb_invalida (se valida
% en cada petición: la KB es chica y así también se detectan cambios en caliente).
despachar(Id, Op, Args, Resp) :-
    validar_kb(Problemas),
    (   Problemas \== []
    ->  Resp = _{id: Id, estado: error, resultados: [],
                 error: _{codigo: kb_invalida,
                          mensaje: "la base de conocimiento es inválida",
                          problemas: Problemas}}
    ;   catch(ejecutar(Op, Args, Res), E, true),
        (   var(E)
        ->  estado_resultados(Res, Estado),
            Resp = _{id: Id, estado: Estado, resultados: Res}
        ;   message_to_string(E, M),
            error(Id, excepcion_prolog, M, Resp)
        )
    ).

estado_resultados([], sin_resultados) :- !.
estado_resultados(_, ok).

ejecutar(ping, _, [_{mensaje: "pong"}]).

error(Id, Codigo, Mensaje, _{id: Id, estado: error, resultados: [],
                             error: _{codigo: Codigo, mensaje: Mensaje}}).

message_to_string(E, S) :- format(string(S), "~p", [E]).
