% Fixture de make test (F12, caso sin hipótesis): el servidor normal, pero con un síntoma que
% ningún componente explica. Se lanza igual que el real:
%   swipl -q -g main -t halt pruebas/servidor_sin_hipotesis.pl
:- use_module('../backend/servidor_json').
:- assertz(user:sintoma(sin_relacion, 'Ruido raro sin componente asociado', sintoma)).
