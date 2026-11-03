% ============================================================
% Base de conocimiento (F01). Esquema según PDF §3 y issue #54.
% ============================================================
:- encoding(utf8).
:- discontiguous sintoma/3.

% ---------- Síntomas ----------
% sintoma(Id, Nombre, Tipo)   Tipo: sintoma | hallazgo
% (los hallazgos —resultado de una prueba— se agregan junto con las pruebas)

sintoma(luz_abs_encendida, 'Luz de ABS encendida', sintoma).
sintoma(ac_no_enfria, 'El aire acondicionado no enfría (sale aire tibio)', sintoma).
sintoma(ac_no_enfria_ralenti, 'El aire acondicionado no enfría en ralentí', sintoma).
sintoma(ac_no_funciona, 'El aire acondicionado no funciona', sintoma).
sintoma(ac_ruido_anormal, 'Ruido anormal o fuerte cuando el A/C está encendido', sintoma).
sintoma(ac_presion_baja, 'Baja presión en el sistema de A/C', sintoma).
sintoma(ruido_eje_al_girar, 'Ruido del eje al girar', sintoma).
sintoma(luz_bateria_encendida, 'Luz de advertencia de la batería encendida', sintoma).
sintoma(humo_negro_escape, 'Humo negro por el escape', sintoma).
sintoma(humo_azul_escape, 'Humo azul por el escape', sintoma).
sintoma(freno_arrastra, 'Los frenos arrastran', sintoma).
sintoma(fuga_liquido_frenos, 'Fuga de líquido de frenos', sintoma).
sintoma(pedal_freno_pulsa, 'Pulsación en el pedal de freno', sintoma).
sintoma(freno_jala_a_un_lado, 'El vehículo se jala hacia un lado al frenar', sintoma).
sintoma(luz_freno_encendida, 'Luz de advertencia de frenos encendida', sintoma).
sintoma(pedal_freno_esponjoso, 'Pedal de freno esponjoso o blando', sintoma).
sintoma(pedal_freno_duro, 'Pedal de freno duro', sintoma).
sintoma(chirrido_frenos, 'Los frenos chirrían', sintoma).
sintoma(olor_aceite_quemado, 'Olor a aceite quemado en el compartimiento del motor', sintoma).
sintoma(luz_check_engine, 'Luz de «check engine» encendida', sintoma).
sintoma(chasquidos_al_girar, 'Chasquidos o clics al girar', sintoma).
sintoma(clic_puerta, 'Clic proveniente de la puerta', sintoma).
sintoma(clic_al_arrancar, 'Clic al girar la llave o al intentar arrancar', sintoma).
sintoma(golpeteo_al_acelerar, 'Golpeteo seco (clunk) al acelerar', sintoma).
sintoma(golpeteo_al_cambiar, 'Golpeteo seco (clunk) al cambiar de marcha', sintoma).
sintoma(pedal_embrague_flojo, 'Pedal de embrague flojo', sintoma).
sintoma(pedal_embrague_esponjoso, 'Pedal de embrague esponjoso o blando', sintoma).
sintoma(embrague_patina, 'El embrague patina', sintoma).
sintoma(fuga_fluido_embrague, 'Fuga de fluido cerca del pedal de embrague', sintoma).
sintoma(fuga_refrigerante, 'Fuga de refrigerante bajo el vehículo', sintoma).
sintoma(fuga_refrigerante_frente_motor, 'Fuga de refrigerante en la parte frontal del motor', sintoma).
sintoma(olor_refrigerante_cabina, 'Olor a refrigerante (dulce) en la cabina', sintoma).
sintoma(rendimiento_motor_deficiente, 'Rendimiento deficiente del motor', sintoma).
sintoma(perdida_potencia, 'Pérdida de potencia', sintoma).
sintoma(retraso_cambios, 'Retraso al engranar o cambiar de marcha', sintoma).
sintoma(dificultad_meter_cambios, 'Dificultad para meter los cambios', sintoma).
sintoma(dificultad_arrancar, 'Dificultad para arrancar el motor', sintoma).
sintoma(no_arranca, 'El motor no arranca', sintoma).
sintoma(motor_no_gira, 'El motor de arranque no gira el motor', sintoma).
sintoma(arranque_lento, 'El motor gira lento al arrancar', sintoma).
sintoma(arranque_dificil_frio, 'Arranque difícil en clima frío', sintoma).
sintoma(faros_tenues, 'Faros tenues', sintoma).
sintoma(faro_no_funciona, 'Faro que no funciona', sintoma).
sintoma(cerradura_no_responde, 'El seguro de la puerta no responde', sintoma).
sintoma(vibracion_eje_transmision, 'Vibración del eje de transmisión', sintoma).
sintoma(vibracion_al_conducir, 'Vibración al conducir', sintoma).
sintoma(vibracion_alta_velocidad, 'Vibración del vehículo a alta velocidad', sintoma).
sintoma(vibracion_motor, 'Vibración del motor', sintoma).
sintoma(vibracion_volante, 'Vibración del volante', sintoma).
sintoma(rueda_bambolea, 'La rueda se bambolea', sintoma).
sintoma(motor_titubea, 'El motor titubea al acelerar', sintoma).
sintoma(motor_golpetea, 'El motor golpetea o cascabelea', sintoma).
sintoma(motor_fallos_encendido, 'Fallos de encendido del motor', sintoma).
sintoma(motor_sobrecalienta, 'El motor se sobrecalienta', sintoma).
sintoma(motor_tose_alta_velocidad, 'El motor tose a alta velocidad', sintoma).
sintoma(motor_se_apaga, 'El motor se apaga', sintoma).
sintoma(se_apaga_ralenti, 'El motor se apaga en ralentí', sintoma).
sintoma(ralenti_inestable, 'Ralentí inestable o irregular', sintoma).
sintoma(cambios_erraticos, 'Cambios de marcha erráticos', sintoma).
sintoma(transmision_no_cambia, 'La transmisión no cambia de marcha', sintoma).
sintoma(transmision_patina, 'La transmisión patina', sintoma).
sintoma(transmision_sobrecalienta, 'La transmisión se sobrecalienta', sintoma).
sintoma(velocimetro_erratico, 'Velocímetro errático', sintoma).
sintoma(motor_se_mueve_excesivo, 'Movimiento excesivo del motor', sintoma).
sintoma(olor_escape_cabina, 'Olor a gases de escape en la cabina', sintoma).
sintoma(olor_combustible, 'Olor a combustible', sintoma).
sintoma(fuga_combustible, 'Fuga visible de combustible bajo el vehículo', sintoma).
sintoma(luz_tapon_gasolina, 'Luz de advertencia del tapón de gasolina', sintoma).
sintoma(luz_bujias_incandescentes, 'Luz indicadora de bujías incandescentes siempre encendida', sintoma).
sintoma(rechinido_ruedas, 'Ruido de rechinido o molido en las ruedas', sintoma).
sintoma(ventilador_hvac_erratico, 'Ventilador del A/C-calefacción con velocidad errática o solo en ciertas posiciones', sintoma).
sintoma(ruido_hvac, 'Ruido fuerte del sistema de climatización', sintoma).
sintoma(sin_aire_ventilas, 'No sale aire por las ventilas', sintoma).
sintoma(flujo_aire_reducido, 'Flujo de aire reducido por las ventilas', sintoma).
sintoma(olor_humedo_ventilas, 'Olor a humedad por las ventilas', sintoma).
sintoma(sin_calefaccion, 'No sale calor por las ventilas', sintoma).
sintoma(ruido_motor_fuerte, 'Ruido fuerte del motor', sintoma).
sintoma(ruido_escape_fuerte, 'Ruido fuerte del escape', sintoma).
sintoma(ruido_eje_trasero, 'Ruido fuerte del eje trasero', sintoma).
sintoma(zumbido_tren_motriz, 'Zumbido del tren motriz', sintoma).
sintoma(zumbido_diferencial, 'Zumbido en la parte trasera del vehículo', sintoma).
sintoma(ruido_tren_motriz_giros, 'Ruido del tren motriz al girar', sintoma).
sintoma(ruido_al_girar_volante, 'Ruido o quejido al girar el volante', sintoma).
sintoma(volante_duro, 'Volante duro', sintoma).
sintoma(luz_refrigerante_bajo, 'Luz de refrigerante bajo encendida', sintoma).
sintoma(luz_presion_aceite, 'Luz de baja presión de aceite encendida', sintoma).
sintoma(presion_llantas_baja, 'Baja presión en las llantas', sintoma).
sintoma(luz_tpms, 'Luz del TPMS encendida', sintoma).
sintoma(voltaje_bajo, 'Voltaje bajo', sintoma).
sintoma(claxon_no_suena, 'El claxon no suena al presionar el botón', sintoma).
sintoma(sin_chorro_limpiaparabrisas, 'No sale líquido limpiaparabrisas', sintoma).
sintoma(chorro_debil_limpiaparabrisas, 'Chorro débil de líquido limpiaparabrisas', sintoma).
sintoma(fuga_aceite_tapa_valvulas, 'Fuga de aceite alrededor de la tapa de válvulas', sintoma).
sintoma(fuga_aceite, 'Fugas de aceite', sintoma).
sintoma(mala_aceleracion, 'Mala aceleración', sintoma).
sintoma(mal_consumo_combustible, 'Mal consumo de combustible', sintoma).
sintoma(olor_huevo_podrido, 'Olor a huevo podrido por el escape', sintoma).
sintoma(temblor_al_acelerar, 'Temblor durante la aceleración', sintoma).
sintoma(chirrido_correa, 'Chirrido proveniente del compartimiento del motor', sintoma).
sintoma(temperatura_zona_roja, 'Indicador de temperatura en zona roja', sintoma).
sintoma(turbo_lag, 'Retraso en la respuesta del turbo', sintoma).
sintoma(desgaste_irregular_llantas, 'Desgaste irregular de las llantas', sintoma).
sintoma(vehiculo_se_traba_giros, 'El vehículo se traba al dar vuelta', sintoma).
sintoma(vehiculo_rebota, 'El vehículo rebota sobre los baches', sintoma).
sintoma(vehiculo_se_inclina, 'El vehículo se inclina hacia un lado', sintoma).
sintoma(mangueras_desgastadas, 'Desgaste o grietas visibles en las mangueras', sintoma).
sintoma(fugas_escape_visibles, 'Fugas de escape visibles', sintoma).
sintoma(ventana_no_se_mueve, 'El vidrio de la ventana no se mueve', sintoma).
sintoma(ventana_intermitente, 'El vidrio de la ventana se mueve de forma intermitente', sintoma).
sintoma(ventana_descarrilada, 'El vidrio de la ventana se sale de la guía', sintoma).
sintoma(ventana_atascada, 'El vidrio de la ventana se queda atascado', sintoma).
sintoma(limpiaparabrisas_no_funciona, 'Los limpiaparabrisas no funcionan', sintoma).
sintoma(limpiaparabrisas_intermitente, 'Los limpiaparabrisas funcionan de forma intermitente', sintoma).

% ---------- Componentes afectados ----------
% componente(Id, Nombre, NPos, NNeg)
%   NPos = casos (virtuales) con el componente afectado, NNeg = casos con el componente sano.
%   P(Cj) = (NPos + 1) / (NPos + NNeg + 2)   (PDF §2.1, Laplace con alfa = 1)
:- discontiguous componente/4.

componente(modulo_abs, 'Módulo de control ABS', 40, 960).
componente(sensor_velocidad_rueda, 'Sensor de velocidad de rueda (ABS)', 40, 960).
componente(servofreno, 'Servofreno (booster)', 40, 960).
componente(caliper_freno, 'Caliper de freno', 40, 960).
componente(manguera_freno, 'Manguera de freno', 40, 960).
componente(cilindro_maestro_freno, 'Cilindro maestro de freno', 40, 960).
componente(pastillas_freno, 'Pastillas de freno', 399, 601).
componente(discos_freno, 'Discos de freno', 199, 801).
componente(zapatas_tambor, 'Zapatas y tambor de freno', 40, 960).
componente(compresor_ac, 'Compresor del A/C', 40, 960).
componente(condensador_ac, 'Condensador del A/C', 40, 960).
componente(evaporador_ac, 'Evaporador del A/C', 40, 960).
componente(carga_refrigerante_ac, 'Carga de refrigerante del A/C (baja o con fuga)', 40, 960).
componente(filtro_cabina, 'Filtro de aire de la cabina', 40, 960).
componente(motor_ventilador_hvac, 'Motor del ventilador de calefacción/A/C', 40, 960).
componente(resistencia_ventilador_hvac, 'Resistencia del motor del ventilador', 40, 960).
componente(refrigerante, 'Refrigerante / anticongelante', 40, 960).
componente(termostato, 'Termostato / sistema de enfriamiento del motor', 40, 960).
componente(nucleo_calefaccion, 'Núcleo de calefacción (heater core)', 40, 960).
componente(manguera_calefaccion, 'Manguera de calefacción', 40, 960).
componente(ventilador_radiador, 'Ventilador del radiador', 40, 960).
componente(manguera_radiador, 'Manguera del radiador', 40, 960).
componente(bomba_agua, 'Bomba de agua', 40, 960).
componente(engranes_conicos, 'Engranes cónicos', 40, 960).
componente(diferencial_central, 'Diferencial central', 40, 960).
componente(cable_embrague, 'Cable del embrague', 40, 960).
componente(cilindro_esclavo_embrague, 'Cilindro esclavo del embrague', 40, 960).
componente(diferencial, 'Diferencial', 40, 960).
componente(eje_motriz, 'Eje motriz (eje vivo)', 40, 960).
componente(eje_rigido, 'Eje rígido', 40, 960).
componente(transmision_automatica, 'Transmisión automática', 40, 960).
componente(junta_universal, 'Junta universal (cruceta)', 40, 960).
componente(acoplamiento_viscoso, 'Acoplamiento viscoso', 40, 960).
componente(bateria, 'Batería', 40, 960).
componente(sistema_carga, 'Sistema de carga (alternador)', 40, 960).
componente(motor_vidrio_puerta, 'Motor del vidrio eléctrico', 40, 960).
componente(regulador_vidrio_puerta, 'Regulador del vidrio eléctrico', 40, 960).
componente(foco_faro, 'Foco del faro', 40, 960).
componente(tapa_distribuidor, 'Tapa del distribuidor', 40, 960).
componente(cables_bujias, 'Juego de cables de bujías', 40, 960).
componente(actuador_seguro_puerta, 'Actuador del seguro eléctrico de puerta', 40, 960).
componente(motor_arranque, 'Motor de arranque', 40, 960).
componente(bomba_limpiaparabrisas, 'Bomba del limpiaparabrisas', 40, 960).
componente(motor_limpiaparabrisas, 'Motor del limpiaparabrisas', 40, 960).
componente(valvula_purga_canister, 'Válvula de purga del canister', 40, 960).
componente(catalizador, 'Convertidor catalítico', 40, 960).
componente(canister_carbon, 'Canister de carbón activado', 40, 960).
componente(multiple_escape, 'Múltiple de escape', 40, 960).
componente(junta_multiple_escape, 'Junta del múltiple de escape', 40, 960).
componente(sensor_presion_tanque, 'Sensor de presión del tanque de combustible', 40, 960).
componente(sensor_detonacion, 'Sensor de detonación (knock)', 40, 960).
componente(sensor_map, 'Sensor MAP', 40, 960).
componente(sensor_oxigeno, 'Sensor de oxígeno', 40, 960).
componente(eje_balanceo, 'Eje de balanceo', 40, 960).
componente(presion_turbo, 'Presión de sobrealimentación (turbo/intercooler)', 40, 960).
componente(bomba_inyeccion_diesel, 'Bomba de inyección diésel', 40, 960).
componente(bujia_incandescente, 'Bujía incandescente (diésel)', 40, 960).
componente(soportes_motor, 'Soportes del motor', 40, 960).
componente(valvula_escape, 'Válvula de escape', 40, 960).
componente(inyector_combustible, 'Inyector de combustible', 40, 960).
componente(valvula_iac, 'Válvula de control de aire de ralentí (IAC)', 40, 960).
componente(valvula_admision, 'Válvula de admisión', 40, 960).
componente(bomba_aceite, 'Bomba de aceite', 40, 960).
componente(anillos_piston, 'Anillos de pistón', 40, 960).
componente(banda_distribucion, 'Banda de distribución', 40, 960).
componente(junta_tapa_valvulas, 'Junta de la tapa de válvulas', 40, 960).
componente(banda_accesorios, 'Banda del motor / ventilador', 40, 960).
componente(claxon, 'Claxon', 40, 960).
componente(liquido_direccion, 'Líquido de la dirección asistida', 40, 960).
componente(eje_y_llantas, 'Eje de transmisión y llantas (balanceo/alineación)', 40, 960).
componente(filtro_aire, 'Filtro de aire del motor', 40, 960).
componente(ecu, 'Unidad de control del motor (ECU)', 40, 960).
componente(aceite_motor, 'Aceite del motor', 40, 960).
componente(filtro_combustible, 'Filtro de combustible', 40, 960).
componente(valvula_pcv, 'Válvula PCV', 40, 960).
componente(cuerpo_aceleracion, 'Cuerpo de aceleración', 40, 960).
componente(regulador_presion_combustible, 'Regulador de presión de combustible', 40, 960).
componente(bomba_combustible, 'Bomba de combustible', 40, 960).
componente(tanque_combustible, 'Tanque de combustible', 40, 960).
componente(sensor_tps, 'Sensor de posición del acelerador (TPS)', 40, 960).
componente(liquido_frenos, 'Líquido de frenos', 99, 901).
componente(deposito_refrigerante, 'Depósito de refrigerante', 40, 960).
componente(radiador, 'Radiador', 40, 960).
componente(liquido_limpiaparabrisas, 'Líquido limpiaparabrisas', 40, 960).
componente(cilindro_maestro_embrague, 'Cilindro maestro del embrague', 40, 960).
componente(convertidor_par, 'Convertidor de par', 40, 960).
componente(fluido_transmision, 'Fluido de la transmisión', 40, 960).
componente(filtro_transmision, 'Filtro de la transmisión', 40, 960).
componente(solenoide_transmision, 'Solenoide de la transmisión', 40, 960).
componente(balero_rueda, 'Balero (rodamiento) de rueda', 40, 960).
componente(sensor_tpms, 'Sensor TPMS', 40, 960).
componente(maza_rueda, 'Maza de rueda', 40, 960).

% ---------- Relación componente - síntoma ----------
% componente_sintoma(Componente, Sintoma, Estado, NPos, NNeg)
%   NPos = N(si ∩ Cj+): casos con el componente afectado que muestran el síntoma.
%   NNeg = N(si ∩ Cj-): casos con el componente sano que lo muestran.
%   Si no hay fila (C, S), el síntoma S no aporta evidencia a C (el motor lo omite en la suma del logit).
%   Estado = presente para síntomas binarios (|Vi| = 2); normal|leve|severo para hallazgos (|Vi| = 3).
:- discontiguous componente_sintoma/5.

componente_sintoma(modulo_abs, luz_abs_encendida, presente, 24, 72).
componente_sintoma(modulo_abs, pedal_freno_pulsa, presente, 24, 95).
componente_sintoma(sensor_velocidad_rueda, luz_abs_encendida, presente, 24, 72).
componente_sintoma(sensor_velocidad_rueda, velocimetro_erratico, presente, 24, 48).
componente_sintoma(servofreno, pedal_freno_esponjoso, presente, 24, 142).
componente_sintoma(servofreno, pedal_freno_duro, presente, 24, 48).
componente_sintoma(caliper_freno, freno_jala_a_un_lado, presente, 24, 48).
componente_sintoma(caliper_freno, freno_arrastra, presente, 24, 72).
componente_sintoma(manguera_freno, fuga_liquido_frenos, presente, 24, 72).
componente_sintoma(manguera_freno, pedal_freno_esponjoso, presente, 24, 142).
componente_sintoma(cilindro_maestro_freno, pedal_freno_esponjoso, presente, 24, 142).
componente_sintoma(cilindro_maestro_freno, fuga_liquido_frenos, presente, 24, 72).
componente_sintoma(pastillas_freno, chirrido_frenos, presente, 320, 129).
componente_sintoma(pastillas_freno, pedal_freno_pulsa, presente, 239, 60).
componente_sintoma(pastillas_freno, pedal_freno_esponjoso, presente, 39, 85).
componente_sintoma(discos_freno, pedal_freno_pulsa, presente, 119, 79).
componente_sintoma(discos_freno, vibracion_volante, presente, 119, 40).
componente_sintoma(discos_freno, chirrido_frenos, presente, 120, 244).
componente_sintoma(discos_freno, pedal_freno_esponjoso, presente, 19, 88).
componente_sintoma(zapatas_tambor, pedal_freno_esponjoso, presente, 24, 142).
componente_sintoma(zapatas_tambor, freno_arrastra, presente, 24, 72).
componente_sintoma(compresor_ac, ac_no_enfria, presente, 24, 95).
componente_sintoma(compresor_ac, ac_ruido_anormal, presente, 24, 48).
componente_sintoma(compresor_ac, ac_no_funciona, presente, 24, 48).
componente_sintoma(condensador_ac, ac_no_enfria, presente, 24, 95).
componente_sintoma(evaporador_ac, olor_humedo_ventilas, presente, 24, 72).
componente_sintoma(evaporador_ac, flujo_aire_reducido, presente, 24, 72).
componente_sintoma(carga_refrigerante_ac, ac_no_enfria, presente, 24, 95).
componente_sintoma(carga_refrigerante_ac, ac_presion_baja, presente, 24, 48).
componente_sintoma(filtro_cabina, olor_humedo_ventilas, presente, 24, 72).
componente_sintoma(filtro_cabina, flujo_aire_reducido, presente, 24, 72).
componente_sintoma(motor_ventilador_hvac, sin_aire_ventilas, presente, 24, 48).
componente_sintoma(motor_ventilador_hvac, ruido_hvac, presente, 24, 48).
componente_sintoma(resistencia_ventilador_hvac, ventilador_hvac_erratico, presente, 24, 48).
componente_sintoma(refrigerante, motor_sobrecalienta, presente, 24, 190).
componente_sintoma(refrigerante, fuga_refrigerante, presente, 24, 119).
componente_sintoma(termostato, motor_sobrecalienta, presente, 24, 190).
componente_sintoma(termostato, temperatura_zona_roja, presente, 24, 48).
componente_sintoma(nucleo_calefaccion, sin_calefaccion, presente, 24, 48).
componente_sintoma(nucleo_calefaccion, olor_refrigerante_cabina, presente, 24, 72).
componente_sintoma(manguera_calefaccion, olor_refrigerante_cabina, presente, 24, 72).
componente_sintoma(manguera_calefaccion, fuga_refrigerante, presente, 24, 119).
componente_sintoma(ventilador_radiador, motor_sobrecalienta, presente, 24, 190).
componente_sintoma(ventilador_radiador, ac_no_enfria_ralenti, presente, 24, 48).
componente_sintoma(manguera_radiador, fuga_refrigerante, presente, 24, 119).
componente_sintoma(manguera_radiador, mangueras_desgastadas, presente, 24, 48).
componente_sintoma(bomba_agua, motor_sobrecalienta, presente, 24, 190).
componente_sintoma(bomba_agua, fuga_refrigerante_frente_motor, presente, 24, 48).
componente_sintoma(engranes_conicos, zumbido_tren_motriz, presente, 24, 48).
componente_sintoma(engranes_conicos, dificultad_meter_cambios, presente, 24, 72).
componente_sintoma(diferencial_central, vehiculo_se_traba_giros, presente, 24, 72).
componente_sintoma(diferencial_central, ruido_tren_motriz_giros, presente, 24, 72).
componente_sintoma(cable_embrague, pedal_embrague_flojo, presente, 24, 48).
componente_sintoma(cable_embrague, dificultad_meter_cambios, presente, 24, 72).
componente_sintoma(cilindro_esclavo_embrague, pedal_embrague_esponjoso, presente, 24, 72).
componente_sintoma(cilindro_esclavo_embrague, fuga_fluido_embrague, presente, 24, 48).
componente_sintoma(diferencial, zumbido_diferencial, presente, 24, 48).
componente_sintoma(diferencial, vibracion_alta_velocidad, presente, 24, 48).
componente_sintoma(eje_motriz, ruido_eje_al_girar, presente, 24, 48).
componente_sintoma(eje_motriz, vehiculo_se_inclina, presente, 24, 48).
componente_sintoma(eje_rigido, vehiculo_rebota, presente, 24, 48).
componente_sintoma(eje_rigido, ruido_eje_trasero, presente, 24, 48).
componente_sintoma(transmision_automatica, transmision_patina, presente, 24, 119).
componente_sintoma(transmision_automatica, retraso_cambios, presente, 24, 72).
componente_sintoma(junta_universal, vibracion_eje_transmision, presente, 24, 48).
componente_sintoma(junta_universal, golpeteo_al_cambiar, presente, 24, 48).
componente_sintoma(acoplamiento_viscoso, vehiculo_se_traba_giros, presente, 24, 72).
componente_sintoma(acoplamiento_viscoso, ruido_tren_motriz_giros, presente, 24, 72).
componente_sintoma(bateria, arranque_lento, presente, 24, 48).
componente_sintoma(bateria, clic_al_arrancar, presente, 24, 72).
componente_sintoma(sistema_carga, luz_bateria_encendida, presente, 24, 48).
componente_sintoma(sistema_carga, faros_tenues, presente, 24, 72).
componente_sintoma(sistema_carga, voltaje_bajo, presente, 24, 48).
componente_sintoma(motor_vidrio_puerta, ventana_no_se_mueve, presente, 24, 48).
componente_sintoma(motor_vidrio_puerta, ventana_intermitente, presente, 24, 48).
componente_sintoma(regulador_vidrio_puerta, ventana_descarrilada, presente, 24, 48).
componente_sintoma(regulador_vidrio_puerta, ventana_atascada, presente, 24, 48).
componente_sintoma(foco_faro, faro_no_funciona, presente, 24, 48).
componente_sintoma(foco_faro, faros_tenues, presente, 24, 72).
componente_sintoma(tapa_distribuidor, motor_fallos_encendido, presente, 24, 213).
componente_sintoma(tapa_distribuidor, dificultad_arrancar, presente, 24, 48).
componente_sintoma(cables_bujias, motor_fallos_encendido, presente, 24, 213).
componente_sintoma(cables_bujias, mal_consumo_combustible, presente, 24, 142).
componente_sintoma(actuador_seguro_puerta, cerradura_no_responde, presente, 24, 48).
componente_sintoma(actuador_seguro_puerta, clic_puerta, presente, 24, 48).
componente_sintoma(motor_arranque, motor_no_gira, presente, 24, 48).
componente_sintoma(motor_arranque, clic_al_arrancar, presente, 24, 72).
componente_sintoma(bomba_limpiaparabrisas, sin_chorro_limpiaparabrisas, presente, 24, 72).
componente_sintoma(bomba_limpiaparabrisas, chorro_debil_limpiaparabrisas, presente, 24, 72).
componente_sintoma(motor_limpiaparabrisas, limpiaparabrisas_no_funciona, presente, 24, 48).
componente_sintoma(motor_limpiaparabrisas, limpiaparabrisas_intermitente, presente, 24, 48).
componente_sintoma(valvula_purga_canister, luz_check_engine, presente, 24, 166).
componente_sintoma(valvula_purga_canister, ralenti_inestable, presente, 24, 190).
componente_sintoma(catalizador, olor_huevo_podrido, presente, 24, 48).
componente_sintoma(catalizador, luz_check_engine, presente, 24, 166).
componente_sintoma(canister_carbon, olor_combustible, presente, 24, 72).
componente_sintoma(canister_carbon, luz_check_engine, presente, 24, 166).
componente_sintoma(multiple_escape, ruido_escape_fuerte, presente, 24, 72).
componente_sintoma(multiple_escape, olor_escape_cabina, presente, 24, 48).
componente_sintoma(junta_multiple_escape, ruido_escape_fuerte, presente, 24, 72).
componente_sintoma(junta_multiple_escape, fugas_escape_visibles, presente, 24, 48).
componente_sintoma(sensor_presion_tanque, luz_check_engine, presente, 24, 166).
componente_sintoma(sensor_presion_tanque, luz_tapon_gasolina, presente, 24, 48).
componente_sintoma(sensor_detonacion, motor_golpetea, presente, 24, 72).
componente_sintoma(sensor_detonacion, mal_consumo_combustible, presente, 24, 142).
componente_sintoma(sensor_map, luz_check_engine, presente, 24, 166).
componente_sintoma(sensor_map, ralenti_inestable, presente, 24, 190).
componente_sintoma(sensor_oxigeno, luz_check_engine, presente, 24, 166).
componente_sintoma(sensor_oxigeno, mal_consumo_combustible, presente, 24, 142).
componente_sintoma(eje_balanceo, vibracion_motor, presente, 24, 48).
componente_sintoma(eje_balanceo, ralenti_inestable, presente, 24, 190).
componente_sintoma(presion_turbo, perdida_potencia, presente, 24, 95).
componente_sintoma(presion_turbo, turbo_lag, presente, 24, 48).
componente_sintoma(bomba_inyeccion_diesel, motor_fallos_encendido, presente, 24, 213).
componente_sintoma(bomba_inyeccion_diesel, humo_negro_escape, presente, 24, 95).
componente_sintoma(bujia_incandescente, arranque_dificil_frio, presente, 24, 48).
componente_sintoma(bujia_incandescente, luz_bujias_incandescentes, presente, 24, 48).
componente_sintoma(soportes_motor, motor_se_mueve_excesivo, presente, 24, 48).
componente_sintoma(soportes_motor, golpeteo_al_acelerar, presente, 24, 48).
componente_sintoma(valvula_escape, motor_fallos_encendido, presente, 24, 213).
componente_sintoma(valvula_escape, ralenti_inestable, presente, 24, 190).
componente_sintoma(inyector_combustible, motor_fallos_encendido, presente, 24, 213).
componente_sintoma(inyector_combustible, mal_consumo_combustible, presente, 24, 142).
componente_sintoma(valvula_iac, ralenti_inestable, presente, 24, 190).
componente_sintoma(valvula_iac, se_apaga_ralenti, presente, 24, 95).
componente_sintoma(valvula_admision, motor_fallos_encendido, presente, 24, 213).
componente_sintoma(valvula_admision, ralenti_inestable, presente, 24, 190).
componente_sintoma(bomba_aceite, luz_presion_aceite, presente, 24, 72).
componente_sintoma(bomba_aceite, motor_golpetea, presente, 24, 72).
componente_sintoma(anillos_piston, humo_azul_escape, presente, 24, 48).
componente_sintoma(anillos_piston, perdida_potencia, presente, 24, 95).
componente_sintoma(banda_distribucion, motor_fallos_encendido, presente, 24, 213).
componente_sintoma(banda_distribucion, no_arranca, presente, 24, 48).
componente_sintoma(junta_tapa_valvulas, fuga_aceite_tapa_valvulas, presente, 24, 48).
componente_sintoma(junta_tapa_valvulas, olor_aceite_quemado, presente, 24, 48).
componente_sintoma(banda_accesorios, motor_sobrecalienta, presente, 24, 190).
componente_sintoma(banda_accesorios, chirrido_correa, presente, 24, 48).
componente_sintoma(banda_accesorios, rendimiento_motor_deficiente, presente, 24, 72).
componente_sintoma(claxon, claxon_no_suena, presente, 24, 48).
componente_sintoma(liquido_direccion, ruido_al_girar_volante, presente, 24, 48).
componente_sintoma(liquido_direccion, volante_duro, presente, 24, 48).
componente_sintoma(eje_y_llantas, desgaste_irregular_llantas, presente, 24, 72).
componente_sintoma(eje_y_llantas, vibracion_al_conducir, presente, 24, 48).
componente_sintoma(filtro_aire, rendimiento_motor_deficiente, presente, 24, 72).
componente_sintoma(filtro_aire, humo_negro_escape, presente, 24, 95).
componente_sintoma(ecu, motor_fallos_encendido, presente, 24, 213).
componente_sintoma(ecu, mal_consumo_combustible, presente, 24, 142).
componente_sintoma(aceite_motor, luz_presion_aceite, presente, 24, 72).
componente_sintoma(aceite_motor, ruido_motor_fuerte, presente, 24, 48).
componente_sintoma(filtro_combustible, motor_se_apaga, presente, 24, 72).
componente_sintoma(filtro_combustible, mala_aceleracion, presente, 24, 72).
componente_sintoma(valvula_pcv, fuga_aceite, presente, 24, 48).
componente_sintoma(valvula_pcv, ralenti_inestable, presente, 24, 190).
componente_sintoma(cuerpo_aceleracion, mala_aceleracion, presente, 24, 72).
componente_sintoma(cuerpo_aceleracion, se_apaga_ralenti, presente, 24, 95).
componente_sintoma(regulador_presion_combustible, motor_se_apaga, presente, 24, 72).
componente_sintoma(regulador_presion_combustible, humo_negro_escape, presente, 24, 95).
componente_sintoma(bomba_combustible, motor_tose_alta_velocidad, presente, 24, 48).
componente_sintoma(bomba_combustible, perdida_potencia, presente, 24, 95).
componente_sintoma(tanque_combustible, olor_combustible, presente, 24, 72).
componente_sintoma(tanque_combustible, fuga_combustible, presente, 24, 48).
componente_sintoma(sensor_tps, motor_titubea, presente, 24, 48).
componente_sintoma(sensor_tps, se_apaga_ralenti, presente, 24, 95).
componente_sintoma(liquido_frenos, pedal_freno_esponjoso, presente, 85, 84).
componente_sintoma(liquido_frenos, luz_freno_encendida, presente, 59, 45).
componente_sintoma(liquido_frenos, chirrido_frenos, presente, 19, 225).
componente_sintoma(deposito_refrigerante, motor_sobrecalienta, presente, 24, 190).
componente_sintoma(deposito_refrigerante, luz_refrigerante_bajo, presente, 24, 48).
componente_sintoma(radiador, motor_sobrecalienta, presente, 24, 190).
componente_sintoma(radiador, fuga_refrigerante, presente, 24, 119).
componente_sintoma(liquido_limpiaparabrisas, sin_chorro_limpiaparabrisas, presente, 24, 72).
componente_sintoma(liquido_limpiaparabrisas, chorro_debil_limpiaparabrisas, presente, 24, 72).
componente_sintoma(cilindro_maestro_embrague, pedal_embrague_esponjoso, presente, 24, 72).
componente_sintoma(cilindro_maestro_embrague, embrague_patina, presente, 24, 48).
componente_sintoma(convertidor_par, transmision_patina, presente, 24, 119).
componente_sintoma(convertidor_par, temblor_al_acelerar, presente, 24, 48).
componente_sintoma(fluido_transmision, transmision_patina, presente, 24, 119).
componente_sintoma(fluido_transmision, transmision_sobrecalienta, presente, 24, 48).
componente_sintoma(filtro_transmision, retraso_cambios, presente, 24, 72).
componente_sintoma(filtro_transmision, transmision_patina, presente, 24, 119).
componente_sintoma(solenoide_transmision, cambios_erraticos, presente, 24, 48).
componente_sintoma(solenoide_transmision, transmision_no_cambia, presente, 24, 48).
componente_sintoma(balero_rueda, rechinido_ruedas, presente, 24, 48).
componente_sintoma(balero_rueda, desgaste_irregular_llantas, presente, 24, 72).
componente_sintoma(sensor_tpms, luz_tpms, presente, 24, 48).
componente_sintoma(sensor_tpms, presion_llantas_baja, presente, 24, 48).
componente_sintoma(maza_rueda, chasquidos_al_girar, presente, 24, 48).
componente_sintoma(maza_rueda, rueda_bambolea, presente, 24, 48).

% ---------- Acciones correctivas ----------
% accion(Id, Nombre)
% accion_componente(Accion, Componente, Maj)   Maj = efectividad de la acción sobre el componente, en [0, 1].
%   Ra = 1 - prod_j (1 - P(Cj|S) * Maj)   sobre los componentes confirmados (PDF §2.3).
%   Una acción puede servir a varios componentes y un componente admite varias acciones.
:- discontiguous accion/2.
:- discontiguous accion_componente/3.

accion(purgar_cambiar_liquido_frenos, 'Purgar y cambiar el líquido de frenos').
accion(revisar_fugas_circuito_frenos, 'Revisar fugas del circuito de frenos').
accion(rectificar_discos, 'Rectificar los discos de freno').
accion(rectificar_tambor, 'Rectificar el tambor de freno').
accion(localizar_fugas_refrigerante, 'Localizar y reparar fugas del sistema de enfriamiento').
accion(rellenar_refrigerante, 'Rellenar refrigerante').
accion(reemplazar_tapon_radiador, 'Reemplazar el tapón del radiador').
accion(desobstruir_radiador_condensador, 'Limpiar y desobstruir radiador o condensador').
accion(localizar_fugas_aceite, 'Localizar y sellar fugas de aceite').
accion(rellenar_aceite_motor, 'Rellenar aceite del motor').
accion(detectar_fugas_recargar_ac, 'Detectar fugas y recargar el refrigerante del A/C').
accion(limpiar_evaporador_ac, 'Limpiar el evaporador (moho y humedad)').
accion(localizar_fugas_combustible, 'Localizar y reparar fugas de combustible').
accion(reemplazar_tapon_gasolina, 'Reemplazar el tapón del tanque de gasolina').
accion(sellar_fugas_escape, 'Sellar fugas del sistema de escape').
accion(reapretar_pernos, 'Reapretar pernos de sujeción').
accion(reparar_cableado, 'Reparar cableado y conectores').
accion(reemplazar_fusible_rele, 'Reemplazar fusible o relé').
accion(limpiar_terminales_bateria, 'Limpiar y apretar los terminales de la batería').
accion(cargar_bateria, 'Cargar la batería').
accion(ajustar_tension_banda, 'Ajustar tensión y alineación de la banda').
accion(ajustar_cable_embrague, 'Ajustar la tensión del cable del embrague').
accion(purgar_embrague, 'Purgar el sistema hidráulico del embrague').
accion(limpiar_cuerpo_aceleracion, 'Limpiar el cuerpo de aceleración y la válvula IAC').
accion(limpiar_carbonilla_valvulas, 'Limpiar la carbonilla de las válvulas').
accion(ajustar_holgura_valvulas, 'Ajustar la holgura de válvulas').
accion(limpiar_inyectores, 'Limpiar los inyectores y verificar su patrón de rocío').
accion(reprogramar_ecu, 'Reprogramar o reiniciar la ECU').
accion(alinear_balancear, 'Alinear y balancear las ruedas').
accion(ajustar_presion_llantas, 'Ajustar la presión de las llantas').
accion(alinear_tren_motriz, 'Alinear el tren motriz').
accion(rellenar_liquido_direccion, 'Rellenar líquido de la dirección asistida').
accion(rellenar_liquido_limpiaparabrisas, 'Rellenar líquido limpiaparabrisas').
accion(rellenar_fluido_transmision, 'Rellenar fluido de la transmisión').
accion(cambiar_aceite_diferenciales, 'Cambiar el aceite del diferencial').
accion(rellenar_liquido_embrague, 'Rellenar líquido del embrague').
accion(lubricar_guia_vidrio, 'Lubricar y realinear la guía del vidrio').
accion(reemplazar_modulo_abs, 'Reemplazar módulo de control ABS').
accion(reemplazar_sensor_velocidad_rueda, 'Reemplazar sensor de velocidad de rueda (ABS)').
accion(reemplazar_servofreno, 'Reemplazar servofreno (booster)').
accion(reemplazar_caliper_freno, 'Reemplazar caliper de freno').
accion(reemplazar_manguera_freno, 'Reemplazar manguera de freno').
accion(reemplazar_cilindro_maestro_freno, 'Reemplazar cilindro maestro de freno').
accion(reemplazar_pastillas_freno, 'Reemplazar pastillas de freno').
accion(reemplazar_discos_freno, 'Reemplazar discos de freno').
accion(reemplazar_zapatas_tambor, 'Reemplazar zapatas y tambor de freno').
accion(reemplazar_compresor_ac, 'Reemplazar compresor del A/C').
accion(reemplazar_condensador_ac, 'Reemplazar condensador del A/C').
accion(reemplazar_evaporador_ac, 'Reemplazar evaporador del A/C').
accion(cambiar_filtro_cabina, 'Cambiar filtro de aire de la cabina').
accion(reemplazar_motor_ventilador_hvac, 'Reemplazar motor del ventilador de calefacción/A/C').
accion(reemplazar_resistencia_ventilador_hvac, 'Reemplazar resistencia del motor del ventilador').
accion(cambiar_refrigerante, 'Cambiar refrigerante / anticongelante').
accion(reemplazar_termostato, 'Reemplazar termostato / sistema de enfriamiento del motor').
accion(reemplazar_nucleo_calefaccion, 'Reemplazar núcleo de calefacción (heater core)').
accion(reemplazar_manguera_calefaccion, 'Reemplazar manguera de calefacción').
accion(reemplazar_ventilador_radiador, 'Reemplazar ventilador del radiador').
accion(reemplazar_manguera_radiador, 'Reemplazar manguera del radiador').
accion(reemplazar_bomba_agua, 'Reemplazar bomba de agua').
accion(reemplazar_engranes_conicos, 'Reemplazar engranes cónicos').
accion(reemplazar_diferencial_central, 'Reemplazar diferencial central').
accion(reemplazar_cable_embrague, 'Reemplazar cable del embrague').
accion(reemplazar_cilindro_esclavo_embrague, 'Reemplazar cilindro esclavo del embrague').
accion(reemplazar_diferencial, 'Reemplazar diferencial').
accion(reemplazar_eje_motriz, 'Reemplazar eje motriz (eje vivo)').
accion(reemplazar_eje_rigido, 'Reemplazar eje rígido').
accion(reemplazar_transmision_automatica, 'Reemplazar transmisión automática').
accion(reemplazar_junta_universal, 'Reemplazar junta universal (cruceta)').
accion(reemplazar_acoplamiento_viscoso, 'Reemplazar acoplamiento viscoso').
accion(reemplazar_bateria, 'Reemplazar batería').
accion(reemplazar_sistema_carga, 'Reemplazar sistema de carga (alternador)').
accion(reemplazar_motor_vidrio_puerta, 'Reemplazar motor del vidrio eléctrico').
accion(reemplazar_regulador_vidrio_puerta, 'Reemplazar regulador del vidrio eléctrico').
accion(reemplazar_foco_faro, 'Reemplazar foco del faro').
accion(reemplazar_tapa_distribuidor, 'Reemplazar tapa del distribuidor').
accion(reemplazar_cables_bujias, 'Reemplazar juego de cables de bujías').
accion(reemplazar_actuador_seguro_puerta, 'Reemplazar actuador del seguro eléctrico de puerta').
accion(reemplazar_motor_arranque, 'Reemplazar motor de arranque').
accion(reemplazar_bomba_limpiaparabrisas, 'Reemplazar bomba del limpiaparabrisas').
accion(reemplazar_motor_limpiaparabrisas, 'Reemplazar motor del limpiaparabrisas').
accion(reemplazar_valvula_purga_canister, 'Reemplazar válvula de purga del canister').
accion(reemplazar_catalizador, 'Reemplazar convertidor catalítico').
accion(reemplazar_canister_carbon, 'Reemplazar canister de carbón activado').
accion(reemplazar_multiple_escape, 'Reemplazar múltiple de escape').
accion(reemplazar_junta_multiple_escape, 'Reemplazar junta del múltiple de escape').
accion(reemplazar_sensor_presion_tanque, 'Reemplazar sensor de presión del tanque de combustible').
accion(reemplazar_sensor_detonacion, 'Reemplazar sensor de detonación (knock)').
accion(reemplazar_sensor_map, 'Reemplazar sensor MAP').
accion(reemplazar_sensor_oxigeno, 'Reemplazar sensor de oxígeno').
accion(reemplazar_eje_balanceo, 'Reemplazar eje de balanceo').
accion(reemplazar_presion_turbo, 'Reemplazar presión de sobrealimentación (turbo/intercooler)').
accion(reemplazar_bomba_inyeccion_diesel, 'Reemplazar bomba de inyección diésel').
accion(reemplazar_bujia_incandescente, 'Reemplazar bujía incandescente (diésel)').
accion(reemplazar_soportes_motor, 'Reemplazar soportes del motor').
accion(reemplazar_valvula_escape, 'Reemplazar válvula de escape').
accion(reemplazar_inyector_combustible, 'Reemplazar inyector de combustible').
accion(reemplazar_valvula_iac, 'Reemplazar válvula de control de aire de ralentí (IAC)').
accion(reemplazar_valvula_admision, 'Reemplazar válvula de admisión').
accion(reemplazar_bomba_aceite, 'Reemplazar bomba de aceite').
accion(reemplazar_anillos_piston, 'Reemplazar anillos de pistón').
accion(reemplazar_banda_distribucion, 'Reemplazar banda de distribución').
accion(reemplazar_junta_tapa_valvulas, 'Reemplazar junta de la tapa de válvulas').
accion(reemplazar_banda_accesorios, 'Reemplazar banda del motor / ventilador').
accion(reemplazar_claxon, 'Reemplazar claxon').
accion(cambiar_liquido_direccion, 'Cambiar líquido de la dirección asistida').
accion(reemplazar_eje_y_llantas, 'Reemplazar eje de transmisión y llantas (balanceo/alineación)').
accion(cambiar_filtro_aire, 'Cambiar filtro de aire del motor').
accion(reemplazar_ecu, 'Reemplazar unidad de control del motor (ECU)').
accion(cambiar_aceite_motor, 'Cambiar aceite del motor').
accion(cambiar_filtro_combustible, 'Cambiar filtro de combustible').
accion(reemplazar_valvula_pcv, 'Reemplazar válvula PCV').
accion(reemplazar_cuerpo_aceleracion, 'Reemplazar cuerpo de aceleración').
accion(reemplazar_regulador_presion_combustible, 'Reemplazar regulador de presión de combustible').
accion(reemplazar_bomba_combustible, 'Reemplazar bomba de combustible').
accion(reemplazar_tanque_combustible, 'Reemplazar tanque de combustible').
accion(reemplazar_sensor_tps, 'Reemplazar sensor de posición del acelerador (TPS)').
accion(reemplazar_deposito_refrigerante, 'Reemplazar depósito de refrigerante').
accion(reemplazar_radiador, 'Reemplazar radiador').
accion(cambiar_liquido_limpiaparabrisas, 'Cambiar líquido limpiaparabrisas').
accion(reemplazar_cilindro_maestro_embrague, 'Reemplazar cilindro maestro del embrague').
accion(reemplazar_convertidor_par, 'Reemplazar convertidor de par').
accion(cambiar_fluido_transmision, 'Cambiar fluido de la transmisión').
accion(cambiar_filtro_transmision, 'Cambiar filtro de la transmisión').
accion(reemplazar_solenoide_transmision, 'Reemplazar solenoide de la transmisión').
accion(reemplazar_balero_rueda, 'Reemplazar balero (rodamiento) de rueda').
accion(reemplazar_sensor_tpms, 'Reemplazar sensor TPMS').
accion(reemplazar_maza_rueda, 'Reemplazar maza de rueda').

accion_componente(purgar_cambiar_liquido_frenos, liquido_frenos, 0.95).
accion_componente(revisar_fugas_circuito_frenos, liquido_frenos, 0.50).
accion_componente(revisar_fugas_circuito_frenos, manguera_freno, 0.70).
accion_componente(revisar_fugas_circuito_frenos, cilindro_maestro_freno, 0.60).
accion_componente(revisar_fugas_circuito_frenos, caliper_freno, 0.50).
accion_componente(rectificar_discos, discos_freno, 0.85).
accion_componente(rectificar_tambor, zapatas_tambor, 0.60).
accion_componente(localizar_fugas_refrigerante, refrigerante, 0.50).
accion_componente(localizar_fugas_refrigerante, manguera_radiador, 0.60).
accion_componente(localizar_fugas_refrigerante, manguera_calefaccion, 0.60).
accion_componente(localizar_fugas_refrigerante, nucleo_calefaccion, 0.50).
accion_componente(localizar_fugas_refrigerante, bomba_agua, 0.50).
accion_componente(localizar_fugas_refrigerante, radiador, 0.50).
accion_componente(localizar_fugas_refrigerante, deposito_refrigerante, 0.50).
accion_componente(rellenar_refrigerante, refrigerante, 0.80).
accion_componente(rellenar_refrigerante, deposito_refrigerante, 0.70).
accion_componente(reemplazar_tapon_radiador, radiador, 0.50).
accion_componente(reemplazar_tapon_radiador, deposito_refrigerante, 0.30).
accion_componente(desobstruir_radiador_condensador, radiador, 0.60).
accion_componente(desobstruir_radiador_condensador, condensador_ac, 0.80).
accion_componente(localizar_fugas_aceite, aceite_motor, 0.50).
accion_componente(localizar_fugas_aceite, junta_tapa_valvulas, 0.60).
accion_componente(localizar_fugas_aceite, valvula_pcv, 0.40).
accion_componente(localizar_fugas_aceite, bomba_aceite, 0.40).
accion_componente(rellenar_aceite_motor, aceite_motor, 0.70).
accion_componente(detectar_fugas_recargar_ac, carga_refrigerante_ac, 0.85).
accion_componente(detectar_fugas_recargar_ac, compresor_ac, 0.40).
accion_componente(detectar_fugas_recargar_ac, condensador_ac, 0.50).
accion_componente(detectar_fugas_recargar_ac, evaporador_ac, 0.30).
accion_componente(limpiar_evaporador_ac, evaporador_ac, 0.70).
accion_componente(localizar_fugas_combustible, tanque_combustible, 0.60).
accion_componente(localizar_fugas_combustible, inyector_combustible, 0.40).
accion_componente(localizar_fugas_combustible, bomba_combustible, 0.30).
accion_componente(localizar_fugas_combustible, regulador_presion_combustible, 0.30).
accion_componente(reemplazar_tapon_gasolina, sensor_presion_tanque, 0.60).
accion_componente(reemplazar_tapon_gasolina, tanque_combustible, 0.40).
accion_componente(sellar_fugas_escape, multiple_escape, 0.60).
accion_componente(sellar_fugas_escape, junta_multiple_escape, 0.60).
accion_componente(sellar_fugas_escape, catalizador, 0.30).
accion_componente(reapretar_pernos, junta_tapa_valvulas, 0.50).
accion_componente(reapretar_pernos, junta_multiple_escape, 0.50).
accion_componente(reapretar_pernos, multiple_escape, 0.40).
accion_componente(reapretar_pernos, soportes_motor, 0.40).
accion_componente(reparar_cableado, modulo_abs, 0.60).
accion_componente(reparar_cableado, sensor_velocidad_rueda, 0.60).
accion_componente(reparar_cableado, sensor_oxigeno, 0.50).
accion_componente(reparar_cableado, sensor_tps, 0.50).
accion_componente(reparar_cableado, sensor_map, 0.40).
accion_componente(reparar_cableado, sensor_detonacion, 0.40).
accion_componente(reparar_cableado, sensor_presion_tanque, 0.30).
accion_componente(reparar_cableado, solenoide_transmision, 0.50).
accion_componente(reparar_cableado, ecu, 0.40).
accion_componente(reparar_cableado, motor_vidrio_puerta, 0.50).
accion_componente(reparar_cableado, actuador_seguro_puerta, 0.50).
accion_componente(reparar_cableado, motor_limpiaparabrisas, 0.50).
accion_componente(reparar_cableado, bomba_limpiaparabrisas, 0.50).
accion_componente(reparar_cableado, claxon, 0.40).
accion_componente(reparar_cableado, foco_faro, 0.50).
accion_componente(reparar_cableado, sensor_tpms, 0.40).
accion_componente(reparar_cableado, cables_bujias, 0.50).
accion_componente(reemplazar_fusible_rele, modulo_abs, 0.50).
accion_componente(reemplazar_fusible_rele, claxon, 0.80).
accion_componente(reemplazar_fusible_rele, ventilador_radiador, 0.50).
accion_componente(reemplazar_fusible_rele, motor_ventilador_hvac, 0.30).
accion_componente(limpiar_terminales_bateria, bateria, 0.60).
accion_componente(limpiar_terminales_bateria, motor_arranque, 0.30).
accion_componente(cargar_bateria, bateria, 0.50).
accion_componente(ajustar_tension_banda, banda_accesorios, 0.70).
accion_componente(ajustar_tension_banda, sistema_carga, 0.50).
accion_componente(ajustar_cable_embrague, cable_embrague, 0.80).
accion_componente(purgar_embrague, cilindro_esclavo_embrague, 0.60).
accion_componente(purgar_embrague, cilindro_maestro_embrague, 0.60).
accion_componente(limpiar_cuerpo_aceleracion, cuerpo_aceleracion, 0.85).
accion_componente(limpiar_cuerpo_aceleracion, valvula_iac, 0.85).
accion_componente(limpiar_carbonilla_valvulas, valvula_admision, 0.70).
accion_componente(limpiar_carbonilla_valvulas, valvula_escape, 0.70).
accion_componente(ajustar_holgura_valvulas, valvula_admision, 0.70).
accion_componente(ajustar_holgura_valvulas, valvula_escape, 0.70).
accion_componente(limpiar_inyectores, inyector_combustible, 0.70).
accion_componente(limpiar_inyectores, bomba_inyeccion_diesel, 0.40).
accion_componente(reprogramar_ecu, ecu, 0.60).
accion_componente(alinear_balancear, eje_y_llantas, 0.90).
accion_componente(ajustar_presion_llantas, eje_y_llantas, 0.60).
accion_componente(ajustar_presion_llantas, sensor_tpms, 0.60).
accion_componente(alinear_tren_motriz, junta_universal, 0.60).
accion_componente(rellenar_liquido_direccion, liquido_direccion, 0.80).
accion_componente(rellenar_liquido_limpiaparabrisas, liquido_limpiaparabrisas, 0.90).
accion_componente(rellenar_fluido_transmision, fluido_transmision, 0.70).
accion_componente(rellenar_fluido_transmision, transmision_automatica, 0.40).
accion_componente(rellenar_fluido_transmision, convertidor_par, 0.30).
accion_componente(cambiar_aceite_diferenciales, diferencial, 0.70).
accion_componente(cambiar_aceite_diferenciales, diferencial_central, 0.60).
accion_componente(cambiar_aceite_diferenciales, engranes_conicos, 0.60).
accion_componente(rellenar_liquido_embrague, cilindro_maestro_embrague, 0.50).
accion_componente(rellenar_liquido_embrague, cilindro_esclavo_embrague, 0.40).
accion_componente(lubricar_guia_vidrio, regulador_vidrio_puerta, 0.70).
accion_componente(lubricar_guia_vidrio, motor_vidrio_puerta, 0.20).
accion_componente(reemplazar_modulo_abs, modulo_abs, 0.95).
accion_componente(reemplazar_sensor_velocidad_rueda, sensor_velocidad_rueda, 0.95).
accion_componente(reemplazar_servofreno, servofreno, 0.95).
accion_componente(reemplazar_caliper_freno, caliper_freno, 0.95).
accion_componente(reemplazar_manguera_freno, manguera_freno, 0.95).
accion_componente(reemplazar_cilindro_maestro_freno, cilindro_maestro_freno, 0.95).
accion_componente(reemplazar_pastillas_freno, pastillas_freno, 0.95).
accion_componente(reemplazar_discos_freno, discos_freno, 0.95).
accion_componente(reemplazar_zapatas_tambor, zapatas_tambor, 0.95).
accion_componente(reemplazar_compresor_ac, compresor_ac, 0.95).
accion_componente(reemplazar_condensador_ac, condensador_ac, 0.95).
accion_componente(reemplazar_evaporador_ac, evaporador_ac, 0.95).
accion_componente(cambiar_filtro_cabina, filtro_cabina, 0.90).
accion_componente(reemplazar_motor_ventilador_hvac, motor_ventilador_hvac, 0.95).
accion_componente(reemplazar_resistencia_ventilador_hvac, resistencia_ventilador_hvac, 0.95).
accion_componente(cambiar_refrigerante, refrigerante, 0.90).
accion_componente(reemplazar_termostato, termostato, 0.95).
accion_componente(reemplazar_nucleo_calefaccion, nucleo_calefaccion, 0.95).
accion_componente(reemplazar_manguera_calefaccion, manguera_calefaccion, 0.95).
accion_componente(reemplazar_ventilador_radiador, ventilador_radiador, 0.95).
accion_componente(reemplazar_manguera_radiador, manguera_radiador, 0.95).
accion_componente(reemplazar_bomba_agua, bomba_agua, 0.95).
accion_componente(reemplazar_engranes_conicos, engranes_conicos, 0.95).
accion_componente(reemplazar_diferencial_central, diferencial_central, 0.95).
accion_componente(reemplazar_cable_embrague, cable_embrague, 0.95).
accion_componente(reemplazar_cilindro_esclavo_embrague, cilindro_esclavo_embrague, 0.95).
accion_componente(reemplazar_diferencial, diferencial, 0.95).
accion_componente(reemplazar_eje_motriz, eje_motriz, 0.95).
accion_componente(reemplazar_eje_rigido, eje_rigido, 0.95).
accion_componente(reemplazar_transmision_automatica, transmision_automatica, 0.95).
accion_componente(reemplazar_junta_universal, junta_universal, 0.95).
accion_componente(reemplazar_acoplamiento_viscoso, acoplamiento_viscoso, 0.95).
accion_componente(reemplazar_bateria, bateria, 0.95).
accion_componente(reemplazar_sistema_carga, sistema_carga, 0.95).
accion_componente(reemplazar_motor_vidrio_puerta, motor_vidrio_puerta, 0.95).
accion_componente(reemplazar_regulador_vidrio_puerta, regulador_vidrio_puerta, 0.95).
accion_componente(reemplazar_foco_faro, foco_faro, 0.95).
accion_componente(reemplazar_tapa_distribuidor, tapa_distribuidor, 0.95).
accion_componente(reemplazar_cables_bujias, cables_bujias, 0.95).
accion_componente(reemplazar_actuador_seguro_puerta, actuador_seguro_puerta, 0.95).
accion_componente(reemplazar_motor_arranque, motor_arranque, 0.95).
accion_componente(reemplazar_bomba_limpiaparabrisas, bomba_limpiaparabrisas, 0.95).
accion_componente(reemplazar_motor_limpiaparabrisas, motor_limpiaparabrisas, 0.95).
accion_componente(reemplazar_valvula_purga_canister, valvula_purga_canister, 0.95).
accion_componente(reemplazar_catalizador, catalizador, 0.95).
accion_componente(reemplazar_canister_carbon, canister_carbon, 0.95).
accion_componente(reemplazar_multiple_escape, multiple_escape, 0.95).
accion_componente(reemplazar_junta_multiple_escape, junta_multiple_escape, 0.95).
accion_componente(reemplazar_sensor_presion_tanque, sensor_presion_tanque, 0.95).
accion_componente(reemplazar_sensor_detonacion, sensor_detonacion, 0.95).
accion_componente(reemplazar_sensor_map, sensor_map, 0.95).
accion_componente(reemplazar_sensor_oxigeno, sensor_oxigeno, 0.95).
accion_componente(reemplazar_eje_balanceo, eje_balanceo, 0.95).
accion_componente(reemplazar_presion_turbo, presion_turbo, 0.95).
accion_componente(reemplazar_bomba_inyeccion_diesel, bomba_inyeccion_diesel, 0.95).
accion_componente(reemplazar_bujia_incandescente, bujia_incandescente, 0.95).
accion_componente(reemplazar_soportes_motor, soportes_motor, 0.95).
accion_componente(reemplazar_valvula_escape, valvula_escape, 0.95).
accion_componente(reemplazar_inyector_combustible, inyector_combustible, 0.95).
accion_componente(reemplazar_valvula_iac, valvula_iac, 0.95).
accion_componente(reemplazar_valvula_admision, valvula_admision, 0.95).
accion_componente(reemplazar_bomba_aceite, bomba_aceite, 0.95).
accion_componente(reemplazar_anillos_piston, anillos_piston, 0.95).
accion_componente(reemplazar_banda_distribucion, banda_distribucion, 0.95).
accion_componente(reemplazar_junta_tapa_valvulas, junta_tapa_valvulas, 0.95).
accion_componente(reemplazar_banda_accesorios, banda_accesorios, 0.95).
accion_componente(reemplazar_claxon, claxon, 0.95).
accion_componente(cambiar_liquido_direccion, liquido_direccion, 0.90).
accion_componente(reemplazar_eje_y_llantas, eje_y_llantas, 0.95).
accion_componente(cambiar_filtro_aire, filtro_aire, 0.90).
accion_componente(reemplazar_ecu, ecu, 0.95).
accion_componente(cambiar_aceite_motor, aceite_motor, 0.90).
accion_componente(cambiar_filtro_combustible, filtro_combustible, 0.90).
accion_componente(reemplazar_valvula_pcv, valvula_pcv, 0.95).
accion_componente(reemplazar_cuerpo_aceleracion, cuerpo_aceleracion, 0.95).
accion_componente(reemplazar_regulador_presion_combustible, regulador_presion_combustible, 0.95).
accion_componente(reemplazar_bomba_combustible, bomba_combustible, 0.95).
accion_componente(reemplazar_tanque_combustible, tanque_combustible, 0.95).
accion_componente(reemplazar_sensor_tps, sensor_tps, 0.95).
accion_componente(reemplazar_deposito_refrigerante, deposito_refrigerante, 0.95).
accion_componente(reemplazar_radiador, radiador, 0.95).
accion_componente(cambiar_liquido_limpiaparabrisas, liquido_limpiaparabrisas, 0.90).
accion_componente(reemplazar_cilindro_maestro_embrague, cilindro_maestro_embrague, 0.95).
accion_componente(reemplazar_convertidor_par, convertidor_par, 0.95).
accion_componente(cambiar_fluido_transmision, fluido_transmision, 0.90).
accion_componente(cambiar_filtro_transmision, filtro_transmision, 0.90).
accion_componente(reemplazar_solenoide_transmision, solenoide_transmision, 0.95).
accion_componente(reemplazar_balero_rueda, balero_rueda, 0.95).
accion_componente(reemplazar_sensor_tpms, sensor_tpms, 0.95).
accion_componente(reemplazar_maza_rueda, maza_rueda, 0.95).
