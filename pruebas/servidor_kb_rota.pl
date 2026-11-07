% Fixture de make test: el servidor normal, pero con un hecho inválido (acción inexistente).
% Se lanza igual que el real: swipl -q -g main -t halt pruebas/servidor_kb_rota.pl
:- use_module('../backend/servidor_json').
:- assertz(user:accion_componente(fantasma, bateria, 1.5)).
