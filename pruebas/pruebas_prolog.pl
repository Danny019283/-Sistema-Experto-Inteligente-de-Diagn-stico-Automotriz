:- use_module(library(plunit)).
:- use_module('../backend/servidor_json').

:- begin_tests(contrato_base).
test(ping) :-
    procesar_linea("{\"id\":1,\"op\":\"ping\",\"args\":{}}", R),
    R.id == 1, R.estado == ok, R.resultados = [P], P.mensaje == "pong".
test(ping_sin_args) :-
    procesar_linea("{\"id\":2,\"op\":\"ping\"}", R), R.estado == ok.
test(json_invalido) :-
    procesar_linea("{no es json", R),
    R.estado == error, R.error.codigo == json_invalido.
test(sin_op) :-
    procesar_linea("{\"id\":3}", R), R.error.codigo == json_invalido.
test(op_desconocida) :-
    procesar_linea("{\"id\":4,\"op\":\"xyz\",\"args\":{}}", R),
    R.id == 4, R.error.codigo == op_desconocida.
test(args_invalidos) :-
    procesar_linea("{\"id\":5,\"op\":\"ping\",\"args\":[1]}", R),
    R.error.codigo == args_invalidos.
:- end_tests(contrato_base).

:- consult('../backend/hechos').

:- begin_tests(parametros).
test(valores_del_issue, [forall(member(N-V, [tau_alto-0.85, tau_bajo-0.05,
                                             max_iteraciones-5, alpha-1]))]) :-
    parametro(N, V).
test(sin_duplicados, [forall(member(N, [tau_alto, tau_bajo, max_iteraciones, alpha]))]) :-
    findall(V, parametro(N, V), [_]).
:- end_tests(parametros).
