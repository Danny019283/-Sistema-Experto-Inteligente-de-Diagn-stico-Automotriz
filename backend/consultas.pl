% Consultas sobre la KB (F02, sección 5): cada una calcula desde los hechos de `user`.
:- module(consultas, [sintomas_de/2, componentes_de/2, pruebas_para/2, componentes_de_prueba/2,
                      sintomas_de_prueba/2, acciones_para/2, mejor_accion/2, incompatibles_con/2,
                      prior/2, sintomas_comunes/3, componentes_sin_pruebas/1,
                      componentes_mas_probables/3, hallazgos_de_prueba/2]).
:- use_module(inferencia).
:- use_module(reglas).

% 1. sintomas_de(+C, -Ss): síntomas (sin hallazgos) con fila para el componente.
sintomas_de(C, Ss) :-
    findall(S, ( componente_sintoma(C, S, _, _, _), sintoma(S, _, sintoma) ), L), sort(L, Ss).
% 2. componentes_de(+S, -Cs): componentes que se asocian al síntoma.
componentes_de(S, Cs) :-
    findall(C, componente_sintoma(C, S, _, _, _), L), sort(L, Cs).
% 3. pruebas_para(+C, -Ps): pruebas que verifican el componente.
pruebas_para(C, Ps) :- findall(P, prueba_componente(P, C), L), sort(L, Ps).
% 4. componentes_de_prueba(+P, -Cs): componentes que verifica una prueba.
componentes_de_prueba(P, Cs) :- findall(C, prueba_componente(P, C), L), sort(L, Cs).
% 5. sintomas_de_prueba(+P, -Ss): síntomas que vuelven relevante la prueba, con su Aps.
sintomas_de_prueba(P, Ss) :- findall(S-A, prueba_sintoma(P, S, A), Ss).
% 6. acciones_para(+C, -As): M-Accion, de mayor a menor efectividad.
acciones_para(C, As) :-
    findall(M-A, accion_componente(A, C, M), L), sort(0, @>=, L, As).
% 7. mejor_accion(+C, -A): la acción de mayor efectividad (falla si no hay).
mejor_accion(C, A) :- acciones_para(C, [_-A|_]).
% 8. incompatibles_con(+S, -Ss): síntomas que no pueden darse junto con S (en ambos sentidos).
incompatibles_con(S, Ss) :-
    findall(O, ( incompatibilidad(S, O) ; incompatibilidad(O, S) ), L), sort(L, Ss).
% 9. prior(+C, -P): P(C) con Laplace.
prior(C, P) :-
    componente(C, _, Np, Nn), parametro(alpha, A), P is (Np + A) / (Np + Nn + 2 * A).
% 10. sintomas_comunes(+C1, +C2, -Ss): síntomas que comparten dos componentes.
sintomas_comunes(C1, C2, Ss) :-
    sintomas_de(C1, S1), sintomas_de(C2, S2), intersection(S1, S2, Ss).
% 11. componentes_sin_pruebas(-Cs): componentes que ninguna prueba verifica (revisión de la KB).
componentes_sin_pruebas(Cs) :-
    findall(C, ( componente(C, _, _, _), \+ prueba_componente(_, C) ), Cs).
% 12. componentes_mas_probables(+X, +N, -Top): los N primeros P-C de clasificar/2.
componentes_mas_probables(X, N, Top) :-
    clasificar(X, L), findall(P-C, member(P-C-_, L), PCs),
    ( length(PCs, Len), Len > N -> length(Top, N), append(Top, _, PCs) ; Top = PCs ).
% 13. hallazgos_de_prueba(+P, -Hs): estados posibles del resultado de una prueba.
hallazgos_de_prueba(P, Hs) :-
    atom_concat(hall_, P, H),
    findall(E, componente_sintoma(_, H, E, _, _), L), sort(L, Hs).
