% Calibración de tau_alto / tau_bajo con los casos de prueba (F12).
% El PDF advierte que Naive Bayes tiende a probabilidades extremas, así que en vez de fijar los
% umbrales a ojo se calcula la VENTANA en la que todos los casos con expectativa conocida se
% clasifican bien y cuánto margen deja cada umbral. Usa la KB y el motor reales:
%   swipl -q -g calibrar -t halt pruebas/calibracion.pl        (make calibrar)
:- use_module('../backend/reglas').
:- ensure_loaded('../backend/hechos').

% caso(Nombre, X, [Componente-EstadoEsperado])
caso('PDF §6: chirrido + pedal (inicial)',
     [chirrido_frenos-presente, pedal_freno_esponjoso-presente],
     [pastillas_freno-incierto, liquido_frenos-incierto, discos_freno-incierto, zapatas_tambor-incierto]).
caso('PDF §6: + espesor de pastillas normal (RB1)',
     [chirrido_frenos-presente, pedal_freno_esponjoso-presente, hall_medir_espesor_pastillas_freno-normal],
     [pastillas_freno-descartado, liquido_frenos-incierto, discos_freno-incierto, zapatas_tambor-incierto]).
caso('PDF §6: + líquido severo (RB3)',
     [chirrido_frenos-presente, pedal_freno_esponjoso-presente, hall_medir_espesor_pastillas_freno-normal,
      hall_revisar_nivel_estado_liquido_frenos-severo],
     [pastillas_freno-descartado, liquido_frenos-confirmado, discos_freno-incierto, zapatas_tambor-incierto]).
caso('PDF §6: + alabeo de disco normal (Discos descartado)',
     [chirrido_frenos-presente, pedal_freno_esponjoso-presente, hall_medir_espesor_pastillas_freno-normal,
      hall_revisar_nivel_estado_liquido_frenos-severo, hall_inspeccionar_disco_rayaduras_alabeo-normal],
     [pastillas_freno-descartado, liquido_frenos-confirmado, discos_freno-descartado, zapatas_tambor-incierto]).
caso('Enunciado: no arranca, motor no gira, faros bien, voltaje normal',
     [no_arranca-presente, motor_no_gira-presente, faros_tenues-ausente, hall_medir_voltaje_bateria-normal],
     [rele_arranque-confirmado, circuito_control_arranque-confirmado, solenoide_arranque-incierto]).
caso('Chirrido presente + pedal ausente',
     [chirrido_frenos-presente, pedal_freno_esponjoso-ausente],
     [liquido_frenos-descartado, pastillas_freno-incierto, discos_freno-incierto]).

calibrar :-
    findall(P-Esp-Nom-C,
            ( caso(Nom, X, Esperados), clasificar(X, L),
              member(C-Esp, Esperados), memberchk(P-C-_, L) ), Filas),
    format("~nP(Cj|S)  esperado    caso / componente~n"),
    forall(member(P-Esp-Nom-C, Filas),
           format("~4f    ~w~t~22|~w / ~w~n", [P, Esp, Nom, C])),
    probs(Filas, descartado, Desc), probs(Filas, incierto, Inc), probs(Filas, confirmado, Conf),
    max_list(Desc, MaxDesc), min_list(Inc, MinInc), max_list(Inc, MaxInc), min_list(Conf, MinConf),
    % tau_bajo: cubre al descartado más alto y queda bajo el incierto más bajo.
    % tau_alto: queda sobre el incierto más alto y bajo el confirmado más bajo.
    format("~nVentana válida:~n  tau_bajo en [~4f, ~4f)   tau_alto en (~4f, ~4f]~n", [MaxDesc, MinInc, MaxInc, MinConf]),
    parametro(tau_bajo, B), parametro(tau_alto, A),
    MB1 is (B - MaxDesc) * 100, MB2 is (MinInc - B) * 100, MA1 is (A - MaxInc) * 100, MA2 is (MinConf - A) * 100,
    format("Valores del PDF:~n  tau_bajo=~2f  margen ~1f pp sobre el descartado más alto, ~1f pp bajo el incierto más bajo~n", [B, MB1, MB2]),
    format("  tau_alto=~2f  margen ~1f pp sobre el incierto más alto, ~1f pp bajo el confirmado más bajo~n", [A, MA1, MA2]),
    (   B >= MaxDesc, B < MinInc, A > MaxInc, A =< MinConf
    ->  writeln('  -> los valores del PDF clasifican bien todos los casos')
    ;   writeln('  -> los valores del PDF NO clasifican bien todos los casos: ajustar') ),
    BR is (MaxDesc + MinInc) / 2, AR is (MaxInc + MinConf) / 2,
    format("Centro de la ventana: tau_bajo~~~2f, tau_alto~~~2f~n", [BR, AR]).

probs(Filas, Esp, Ps) :- findall(P, member(P-Esp-_-_, Filas), Ps).
