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

% ---------- Pruebas adicionales ----------
% prueba(Id, Nombre)
% prueba_sintoma(Prueba, Sintoma, Aps)   Aps = relevancia de la prueba para el síntoma, en [0, 1]  (noisy-OR, PDF §2.2).
% prueba_componente(Prueba, Componente)  qué componente verifica la prueba.
:- discontiguous prueba/2.
:- discontiguous prueba_sintoma/3.
:- discontiguous prueba_componente/2.

prueba(ajustar_tension_cable_embrague, 'Ajustar la tensión del cable del embrague').
prueba(revisar_fusible_abs, 'Revisar el fusible del ABS').
prueba(revisar_funcionamiento_embrague_compresor_c, 'Revisar el funcionamiento del embrague del compresor del A/C').
prueba(revisar_sensor_temperatura_evaporador_c, 'Revisar el sensor de temperatura del evaporador del A/C').
prueba(revisar_funcionamiento_componentes_sistema_c, 'Revisar el funcionamiento de los componentes del sistema de A/C').
prueba(medir_presion_sistema_c_manometro, 'Medir la presión del sistema de A/C con manómetro').
prueba(revisar_codigos_falla_ecu, 'Revisar los códigos de falla de la ECU').
prueba(revisar_manguera_valvula_pcv_tiene_grietas, 'Revisar si la manguera de la válvula PCV tiene grietas').
prueba(revisar_tension_banda_alternador, 'Revisar la tensión de la banda del alternador').
prueba(revisar_desgaste_baleros_eje, 'Revisar el desgaste de los baleros del eje').
prueba(revisar_alineacion_eje_balanceo, 'Revisar la alineación del eje de balanceo').
prueba(revisar_tension_alineacion_banda, 'Revisar la tensión y alineación de la banda').
prueba(medir_presion_sobrealimentacion_manometro, 'Medir la presión de sobrealimentación con manómetro').
prueba(revisar_manguera_vacio_servofreno, 'Revisar la manguera de vacío del servofreno').
prueba(revisar_funcionamiento_piston_caliper, 'Revisar el funcionamiento del pistón del caliper').
prueba(revisar_rayaduras_grietas_tambor_freno, 'Revisar rayaduras o grietas en el tambor de freno').
prueba(revisar_nivel_estado_liquido_frenos, 'Revisar el nivel y estado del líquido de frenos').
prueba(revisar_nivel_liquido_frenos_cilindro_maestro, 'Revisar el nivel de líquido de frenos en el cilindro maestro').
prueba(medir_espesor_pastillas_freno, 'Medir el espesor de las pastillas de freno').
prueba(revisar_eficiencia_convertidor_catalitico, 'Revisar la eficiencia del convertidor catalítico').
prueba(revisar_nivel_liquido_embrague, 'Revisar el nivel del líquido del embrague').
prueba(revisar_fugas_cilindro_esclavo_embrague, 'Revisar fugas en el cilindro esclavo del embrague').
prueba(revisar_flujo_refrigerante_nucleo_calefaccion, 'Revisar el flujo de refrigerante por el núcleo de calefacción').
prueba(revisar_nivel_estado_refrigerante, 'Revisar el nivel y estado del refrigerante').
prueba(revisar_nivel_refrigerante_deposito, 'Revisar el nivel de refrigerante en el depósito').
prueba(revisar_desgaste_rotor_distribuidor, 'Revisar el desgaste del rotor del distribuidor').
prueba(revisar_alineacion_tren_motriz, 'Revisar la alineación del tren motriz').
prueba(revisar_nivel_estado_aceite_motor, 'Revisar el nivel y estado del aceite del motor').
prueba(revisar_apriete_pernos_multiple_escape, 'Revisar el apriete de los pernos del múltiple de escape').
prueba(revisar_fugas_junta_multiple_escape, 'Revisar fugas en la junta del múltiple de escape').
prueba(revisar_residuos_toma_aire_cabina, 'Revisar si hay residuos en la toma de aire de la cabina').
prueba(revisar_desgaste_baleros_diferencial, 'Revisar el desgaste de los baleros del diferencial').
prueba(revisar_diferencial_central_tiene_juego, 'Revisar si el diferencial central tiene juego excesivo').
prueba(revisar_fugas_condensador_c, 'Revisar fugas en el condensador del A/C').
prueba(revisar_fugas_mangueras_valvula_purga, 'Revisar fugas en las mangueras de la válvula de purga').
prueba(revisar_sello_tapon_tanque_combustible, 'Revisar el sello del tapón del tanque de combustible').
prueba(medir_presion_combustible_regulador, 'Medir la presión de combustible en el regulador').
prueba(revisar_nivel_estado_aceite_engranes, 'Revisar el nivel y estado del aceite de engranes').
prueba(revisar_corrosion_socket_faro, 'Revisar corrosión en el socket del faro').
prueba(revisar_fusible_claxon, 'Revisar el fusible del claxon').
prueba(revisar_fugas_conexiones_mangueras, 'Revisar fugas en las conexiones de las mangueras').
prueba(revisar_apriete_pernos_montaje, 'Revisar el apriete de los pernos de montaje').
prueba(revisar_nivel_liquido_direccion, 'Revisar el nivel del líquido de la dirección').
prueba(revisar_fugas_bomba_mangueras_direccion, 'Revisar fugas en la bomba y mangueras de la dirección').
prueba(revisar_sello_tapon_radiador, 'Revisar el sello del tapón del radiador').
prueba(revisar_obstruccion_dano_radiador, 'Revisar obstrucción o daño en el radiador').
prueba(revisar_sensores_relacionados_codigos_dtc, 'Revisar los sensores relacionados con los códigos DTC').
prueba(revisar_alineacion_marcas_tiempo, 'Revisar la alineación de las marcas de tiempo').
prueba(medir_presion_llantas_manometro_revisar_su, 'Medir la presión de las llantas con manómetro y revisar su estado').
prueba(revisar_nivel_estado_fluido_transmision, 'Revisar el nivel y estado del fluido de la transmisión').
prueba(revisar_holgura_valvulas, 'Revisar la holgura de las válvulas').
prueba(revisar_apriete_pernos_tapa_valvulas, 'Revisar el apriete de los pernos de la tapa de válvulas').
prueba(revisar_nivel_liquido_limpiaparabrisas, 'Revisar el nivel de líquido limpiaparabrisas').
prueba(revisar_juego_desgaste_baleros_rueda, 'Revisar el juego y desgaste de los baleros de rueda').
prueba(revisar_sensor_velocidad_rueda_tiene_suciedad, 'Revisar si el sensor de velocidad de rueda tiene suciedad o daño').
prueba(revisar_alineacion_vidrio_guias, 'Revisar la alineación del vidrio en las guías').
prueba(limpiar_cuerpo_aceleracion_valvula_iac, 'Limpiar el cuerpo de aceleración y la válvula IAC').
prueba(inspeccionar_compresor_c_fugas_danos, 'Inspeccionar el compresor del A/C en busca de fugas o daños').
prueba(inspeccionar_condensador_c_residuos_u, 'Inspeccionar el condensador del A/C en busca de residuos u obstrucción').
prueba(inspeccionar_evaporador_c_moho, 'Inspeccionar el evaporador del A/C en busca de moho').
prueba(inspeccionar_arnes_cables_ecu, 'Inspeccionar el arnés de cables de la ECU').
prueba(inspeccionar_manguera_vacio_sensor_map, 'Inspeccionar la manguera de vacío del sensor MAP').
prueba(inspeccionar_valvula_pcv_obstrucciones, 'Inspeccionar la válvula PCV en busca de obstrucciones').
prueba(inspeccionar_sensores_tpms_dano_corrosion, 'Inspeccionar los sensores TPMS en busca de daño o corrosión').
prueba(inspeccionar_cableado_tps, 'Inspeccionar el cableado del TPS').
prueba(inspeccionar_mecanismo_actuador_obstrucciones, 'Inspeccionar el mecanismo del actuador en busca de obstrucciones').
prueba(inspeccionar_filtro_aire_motor_reemplazar_esta, 'Inspeccionar el filtro de aire del motor (reemplazar si está sucio)').
prueba(inspeccionar_funcionamiento_alternador, 'Inspeccionar el funcionamiento del alternador').
prueba(inspeccionar_filtro_cabina_reemplazar_esta, 'Inspeccionar el filtro de la cabina (reemplazar si está sucio)').
prueba(inspeccionar_desgaste_eje_balanceo, 'Inspeccionar el desgaste del eje de balanceo').
prueba(inspeccionar_corrosion_terminales_bateria, 'Inspeccionar la corrosión en los terminales de la batería').
prueba(inspeccionar_balero_dano_corrosion, 'Inspeccionar el balero en busca de daño o corrosión').
prueba(inspeccionar_desgaste_engranes_conicos, 'Inspeccionar el desgaste de los engranes cónicos').
prueba(inspeccionar_motor_ventilador_residuos_dano, 'Inspeccionar el motor del ventilador en busca de residuos o daño').
prueba(inspeccionar_fugas_caliper, 'Inspeccionar fugas en el caliper').
prueba(inspeccionar_manguera_freno_grietas_fugas, 'Inspeccionar la manguera de freno en busca de grietas o fugas').
prueba(inspeccionar_fugas_lineas_freno, 'Inspeccionar fugas en las líneas de freno').
prueba(inspeccionar_estado_pastillas_freno, 'Inspeccionar el estado de las pastillas de freno').
prueba(inspeccionar_disco_rayaduras_alabeo, 'Inspeccionar el disco en busca de rayaduras o alabeo').
prueba(inspeccionar_desgaste_zapatas_freno, 'Inspeccionar el desgaste de las zapatas de freno').
prueba(inspeccionar_canister_grietas_dano, 'Inspeccionar el canister en busca de grietas o daño').
prueba(inspeccionar_convertidor_catalitico_dano, 'Inspeccionar el convertidor catalítico en busca de daño físico').
prueba(inspeccionar_fluido_diferencial_central, 'Inspeccionar el fluido del diferencial central').
prueba(inspeccionar_cable_embrague_desgaste, 'Inspeccionar el cable del embrague en busca de desgaste o estiramiento').
prueba(inspeccionar_nivel_estado_liquido_embrague, 'Inspeccionar el nivel y estado del líquido del embrague').
prueba(inspeccionar_inyectores_diesel_fugas_u, 'Inspeccionar los inyectores diésel en busca de fugas u obstrucción').
prueba(inspeccionar_nivel_estado_fluido_diferencial, 'Inspeccionar el nivel y estado del fluido del diferencial').
prueba(inspeccionar_tapa_distribuidor_grietas, 'Inspeccionar la tapa del distribuidor en busca de grietas o carbonilla').
prueba(inspeccionar_banda_cortes_desgaste, 'Inspeccionar la banda en busca de cortes o desgaste').
prueba(inspeccionar_soportes_motor, 'Inspeccionar los soportes del motor').
prueba(inspeccionar_multiple_escape_grietas_fugas, 'Inspeccionar el múltiple de escape en busca de grietas o fugas').
prueba(inspeccionar_valvula_escape_carbonilla, 'Inspeccionar la válvula de escape en busca de carbonilla').
prueba(revisar_codigos_fallo_encendido, 'Revisar códigos de fallo de encendido').
prueba(inspeccionar_fugas_sistema_c, 'Inspeccionar fugas en el sistema de A/C').
prueba(inspeccionar_fugas_aceite, 'Inspeccionar fugas de aceite').
prueba(inspeccionar_filtro_combustible_reemplazar, 'Inspeccionar el filtro de combustible (reemplazar si está obstruido)').
prueba(inspeccionar_bomba_combustible_fugas_dano, 'Inspeccionar la bomba de combustible en busca de fugas o daño').
prueba(inspeccionar_tanque_combustible_fugas_dano, 'Inspeccionar el tanque de combustible en busca de fugas o daño').
prueba(inspeccionar_bujia_incandescente_carbonilla, 'Inspeccionar la bujía incandescente en busca de carbonilla').
prueba(inspeccionar_filamento_foco_faro, 'Inspeccionar el filamento del foco del faro').
prueba(inspeccionar_fugas_nucleo_calefaccion, 'Inspeccionar fugas en el núcleo de calefacción').
prueba(inspeccionar_conexiones_mangueras_calefaccion, 'Inspeccionar las conexiones de las mangueras de calefacción').
prueba(inspeccionar_inyector_fugas_u_obstruccion, 'Inspeccionar el inyector en busca de fugas u obstrucción').
prueba(inspeccionar_valvula_admision_carbonilla, 'Inspeccionar la válvula de admisión en busca de carbonilla').
prueba(inspeccionar_intercooler_fugas_dano, 'Inspeccionar el intercooler en busca de fugas o daño').
prueba(inspeccionar_eje_motriz_grietas_deformacion, 'Inspeccionar el eje motriz en busca de grietas o deformación').
prueba(inspeccionar_fugas_cilindro_maestro, 'Inspeccionar fugas en el cilindro maestro').
prueba(inspeccionar_bomba_aceite_desgaste_dano, 'Inspeccionar la bomba de aceite en busca de desgaste o daño').
prueba(inspeccionar_cableado_sensor_oxigeno, 'Inspeccionar el cableado del sensor de oxígeno').
prueba(inspeccionar_anillos_piston, 'Inspeccionar los anillos de pistón').
prueba(inspeccionar_fugas_mangueras_direccion, 'Inspeccionar fugas en las mangueras de la dirección').
prueba(inspeccionar_fugas_radiador_mangueras, 'Inspeccionar fugas en el radiador y las mangueras').
prueba(inspeccionar_motor_rele_ventilador_radiador, 'Inspeccionar el motor y relé del ventilador del radiador').
prueba(inspeccionar_radiador_fugas_dano, 'Inspeccionar el radiador en busca de fugas o daño').
prueba(inspeccionar_danos_mangueras_radiador, 'Inspeccionar daños en las mangueras del radiador').
prueba(inspeccionar_fugas_radiador_mangueras_bomba, 'Inspeccionar fugas en radiador, mangueras y bomba de agua').
prueba(inspeccionar_deposito_grietas_fugas, 'Inspeccionar el depósito en busca de grietas o fugas').
prueba(inspeccionar_resistencia_sobrecalentamiento, 'Inspeccionar la resistencia en busca de sobrecalentamiento').
prueba(inspeccionar_eje_rigido_grietas_dano, 'Inspeccionar el eje rígido en busca de grietas o daño').
prueba(inspeccionar_balanceo_alineacion_eje, 'Inspeccionar el balanceo y alineación del eje').
prueba(inspeccionar_botas_bujias, 'Inspeccionar las botas de las bujías').
prueba(inspeccionar_desgaste_escobillas_motor, 'Inspeccionar el desgaste de las escobillas del motor de arranque').
prueba(inspeccionar_carbonilla_cuerpo_aceleracion, 'Inspeccionar carbonilla en el cuerpo de aceleración').
prueba(inspeccionar_banda_distribucion, 'Inspeccionar la banda de distribución').
prueba(inspeccionar_fugas_dano_convertidor_par, 'Inspeccionar fugas o daño del convertidor de par').
prueba(inspeccionar_filtro_transmision_reemplazar, 'Inspeccionar el filtro de la transmisión (reemplazar si está obstruido)').
prueba(inspeccionar_fugas_transmision, 'Inspeccionar fugas en la transmisión').
prueba(inspeccionar_fugas_carter_sellos_transmision, 'Inspeccionar fugas en el cárter y sellos de la transmisión').
prueba(inspeccionar_desgaste_juego_junta_universal, 'Inspeccionar desgaste o juego de la junta universal').
prueba(inspeccionar_fugas_junta_tapa_valvulas, 'Inspeccionar fugas en la junta de la tapa de válvulas').
prueba(inspeccionar_fluido_acoplamiento_viscoso, 'Inspeccionar el fluido del acoplamiento viscoso').
prueba(probar_funcionamiento_bomba_liquido, 'Probar el funcionamiento de la bomba de líquido limpiaparabrisas').
prueba(inspeccionar_obstruccion_dano_bomba, 'Inspeccionar obstrucción o daño en la bomba del limpiaparabrisas').
prueba(inspeccionar_fugas_bomba_agua, 'Inspeccionar fugas en la bomba de agua').
prueba(inspeccionar_juego_ruido_balero_maza, 'Inspeccionar juego o ruido de balero en la maza').
prueba(inspeccionar_conexiones_sensor_velocidad_rueda, 'Inspeccionar las conexiones del sensor de velocidad de rueda').
prueba(inspeccionar_regulador_vidrio_electrico, 'Inspeccionar el regulador del vidrio eléctrico').
prueba(inspeccionar_desgaste_articulacion, 'Inspeccionar el desgaste de la articulación del limpiaparabrisas').
prueba(inspeccionar_arnes_cables_dano_corrosion, 'Inspeccionar el arnés de cables en busca de daño o corrosión').
prueba(inspeccionar_cableado_modulo_abs, 'Inspeccionar el cableado del módulo ABS').
prueba(medir_espesor_disco_freno, 'Medir el espesor del disco de freno').
prueba(ejecutar_escaneo_diagnostico_sistema_c, 'Ejecutar un escaneo diagnóstico del sistema de A/C').
prueba(realizar_prueba_compresion, 'Realizar una prueba de compresión').
prueba(probar_presion_manguera_freno, 'Probar a presión la manguera de freno').
prueba(probar_presion_sistema_enfriamiento, 'Probar a presión el sistema de enfriamiento').
prueba(probar_presion_mangueras_calefaccion, 'Probar a presión las mangueras de calefacción').
prueba(escanear_codigos_falla_dtc, 'Escanear códigos de falla (DTC)').
prueba(probar_funcionamiento_valvula_iac, 'Probar el funcionamiento de la válvula IAC').
prueba(medir_voltaje_sensor_map, 'Medir el voltaje del sensor MAP').
prueba(medir_salida_alternador, 'Medir la salida del alternador').
prueba(medir_voltaje_bateria, 'Medir el voltaje de la batería').
prueba(probar_funcionamiento_motor_ventilador, 'Probar el funcionamiento del motor del ventilador').
prueba(probar_continuidad_resistencia_ventilador, 'Probar la continuidad de la resistencia del ventilador').
prueba(medir_presion_vacio_servofreno, 'Medir la presión de vacío del servofreno').
prueba(probar_funcionamiento_valvula_purga, 'Probar el funcionamiento de la válvula de purga').
prueba(medir_presion_bomba_inyeccion_diesel, 'Medir la presión de la bomba de inyección diésel').
prueba(probar_patron_rocio_inyector, 'Probar el patrón de rocío del inyector').
prueba(probar_funcionamiento_regulador_presion, 'Probar el funcionamiento del regulador de presión de combustible').
prueba(medir_presion_bomba_combustible, 'Medir la presión de la bomba de combustible').
prueba(probar_sensor_presion_tanque_combustible, 'Probar el sensor de presión del tanque de combustible').
prueba(medir_resistencia_bujia_incandescente, 'Medir la resistencia de la bujía incandescente').
prueba(probar_rele_claxon, 'Probar el relé del claxon').
prueba(probar_continuidad_cables_bujias, 'Probar la continuidad de los cables de bujías').
prueba(probar_sensor_detonacion, 'Probar el sensor de detonación').
prueba(medir_presion_aceite_manometro, 'Medir la presión de aceite con manómetro').
prueba(medir_voltaje_sensor_oxigeno, 'Medir el voltaje del sensor de oxígeno').
prueba(verificar_alimentacion_electrica_actuador, 'Verificar la alimentación eléctrica del actuador del seguro').
prueba(verificar_alimentacion_electrica_bomba, 'Verificar la alimentación eléctrica de la bomba del limpiaparabrisas').
prueba(verificar_alimentacion_electrica_motor_vidrio, 'Verificar la alimentación eléctrica del motor del vidrio').
prueba(verificar_alimentacion_electrica_motor, 'Verificar la alimentación eléctrica del motor del limpiaparabrisas').
prueba(probar_funcionamiento_ventilador_radiador, 'Probar el funcionamiento del ventilador del radiador').
prueba(probar_solenoide_motor_arranque, 'Probar el solenoide del motor de arranque').
prueba(probar_funcionamiento_termostato, 'Probar el funcionamiento del termostato').
prueba(probar_sensor_posicion_acelerador_tps, 'Probar el sensor de posición del acelerador (TPS)').
prueba(probar_continuidad_solenoides_transmision, 'Probar la continuidad de los solenoides de la transmisión').
prueba(probar_funcionamiento_acoplamiento_viscoso, 'Probar el funcionamiento del acoplamiento viscoso').
prueba(probar_funcionamiento_bomba_agua, 'Probar el funcionamiento de la bomba de agua').

prueba_componente(ajustar_tension_cable_embrague, cable_embrague).
prueba_componente(revisar_fusible_abs, modulo_abs).
prueba_componente(revisar_funcionamiento_embrague_compresor_c, compresor_ac).
prueba_componente(revisar_sensor_temperatura_evaporador_c, evaporador_ac).
prueba_componente(revisar_funcionamiento_componentes_sistema_c, compresor_ac).
prueba_componente(revisar_funcionamiento_componentes_sistema_c, condensador_ac).
prueba_componente(revisar_funcionamiento_componentes_sistema_c, evaporador_ac).
prueba_componente(medir_presion_sistema_c_manometro, carga_refrigerante_ac).
prueba_componente(revisar_codigos_falla_ecu, ecu).
prueba_componente(revisar_manguera_valvula_pcv_tiene_grietas, valvula_pcv).
prueba_componente(revisar_tension_banda_alternador, sistema_carga).
prueba_componente(revisar_desgaste_baleros_eje, eje_motriz).
prueba_componente(revisar_desgaste_baleros_eje, eje_rigido).
prueba_componente(revisar_alineacion_eje_balanceo, eje_balanceo).
prueba_componente(revisar_tension_alineacion_banda, banda_accesorios).
prueba_componente(medir_presion_sobrealimentacion_manometro, presion_turbo).
prueba_componente(revisar_manguera_vacio_servofreno, servofreno).
prueba_componente(revisar_funcionamiento_piston_caliper, caliper_freno).
prueba_componente(revisar_rayaduras_grietas_tambor_freno, zapatas_tambor).
prueba_componente(revisar_nivel_estado_liquido_frenos, liquido_frenos).
prueba_componente(revisar_nivel_liquido_frenos_cilindro_maestro, cilindro_maestro_freno).
prueba_componente(medir_espesor_pastillas_freno, pastillas_freno).
prueba_componente(revisar_eficiencia_convertidor_catalitico, catalizador).
prueba_componente(revisar_nivel_liquido_embrague, cilindro_maestro_embrague).
prueba_componente(revisar_fugas_cilindro_esclavo_embrague, cilindro_esclavo_embrague).
prueba_componente(revisar_flujo_refrigerante_nucleo_calefaccion, nucleo_calefaccion).
prueba_componente(revisar_nivel_estado_refrigerante, refrigerante).
prueba_componente(revisar_nivel_refrigerante_deposito, deposito_refrigerante).
prueba_componente(revisar_desgaste_rotor_distribuidor, tapa_distribuidor).
prueba_componente(revisar_alineacion_tren_motriz, junta_universal).
prueba_componente(revisar_nivel_estado_aceite_motor, aceite_motor).
prueba_componente(revisar_apriete_pernos_multiple_escape, junta_multiple_escape).
prueba_componente(revisar_fugas_junta_multiple_escape, junta_multiple_escape).
prueba_componente(revisar_fugas_junta_multiple_escape, multiple_escape).
prueba_componente(revisar_residuos_toma_aire_cabina, filtro_cabina).
prueba_componente(revisar_desgaste_baleros_diferencial, diferencial).
prueba_componente(revisar_diferencial_central_tiene_juego, diferencial_central).
prueba_componente(revisar_fugas_condensador_c, condensador_ac).
prueba_componente(revisar_fugas_mangueras_valvula_purga, valvula_purga_canister).
prueba_componente(revisar_sello_tapon_tanque_combustible, sensor_presion_tanque).
prueba_componente(revisar_sello_tapon_tanque_combustible, tanque_combustible).
prueba_componente(medir_presion_combustible_regulador, regulador_presion_combustible).
prueba_componente(revisar_nivel_estado_aceite_engranes, engranes_conicos).
prueba_componente(revisar_corrosion_socket_faro, foco_faro).
prueba_componente(revisar_fusible_claxon, claxon).
prueba_componente(revisar_fugas_conexiones_mangueras, manguera_radiador).
prueba_componente(revisar_apriete_pernos_montaje, soportes_motor).
prueba_componente(revisar_nivel_liquido_direccion, liquido_direccion).
prueba_componente(revisar_fugas_bomba_mangueras_direccion, liquido_direccion).
prueba_componente(revisar_sello_tapon_radiador, radiador).
prueba_componente(revisar_obstruccion_dano_radiador, termostato).
prueba_componente(revisar_sensores_relacionados_codigos_dtc, sensor_detonacion).
prueba_componente(revisar_sensores_relacionados_codigos_dtc, sensor_map).
prueba_componente(revisar_sensores_relacionados_codigos_dtc, sensor_oxigeno).
prueba_componente(revisar_sensores_relacionados_codigos_dtc, sensor_tps).
prueba_componente(revisar_alineacion_marcas_tiempo, banda_distribucion).
prueba_componente(medir_presion_llantas_manometro_revisar_su, eje_y_llantas).
prueba_componente(medir_presion_llantas_manometro_revisar_su, sensor_tpms).
prueba_componente(revisar_nivel_estado_fluido_transmision, convertidor_par).
prueba_componente(revisar_nivel_estado_fluido_transmision, fluido_transmision).
prueba_componente(revisar_nivel_estado_fluido_transmision, transmision_automatica).
prueba_componente(revisar_holgura_valvulas, valvula_admision).
prueba_componente(revisar_holgura_valvulas, valvula_escape).
prueba_componente(revisar_apriete_pernos_tapa_valvulas, junta_tapa_valvulas).
prueba_componente(revisar_nivel_liquido_limpiaparabrisas, liquido_limpiaparabrisas).
prueba_componente(revisar_juego_desgaste_baleros_rueda, balero_rueda).
prueba_componente(revisar_juego_desgaste_baleros_rueda, maza_rueda).
prueba_componente(revisar_sensor_velocidad_rueda_tiene_suciedad, sensor_velocidad_rueda).
prueba_componente(revisar_alineacion_vidrio_guias, regulador_vidrio_puerta).
prueba_componente(limpiar_cuerpo_aceleracion_valvula_iac, valvula_iac).
prueba_componente(inspeccionar_compresor_c_fugas_danos, compresor_ac).
prueba_componente(inspeccionar_condensador_c_residuos_u, condensador_ac).
prueba_componente(inspeccionar_evaporador_c_moho, evaporador_ac).
prueba_componente(inspeccionar_arnes_cables_ecu, ecu).
prueba_componente(inspeccionar_manguera_vacio_sensor_map, sensor_map).
prueba_componente(inspeccionar_valvula_pcv_obstrucciones, valvula_pcv).
prueba_componente(inspeccionar_sensores_tpms_dano_corrosion, sensor_tpms).
prueba_componente(inspeccionar_cableado_tps, sensor_tps).
prueba_componente(inspeccionar_mecanismo_actuador_obstrucciones, actuador_seguro_puerta).
prueba_componente(inspeccionar_filtro_aire_motor_reemplazar_esta, filtro_aire).
prueba_componente(inspeccionar_funcionamiento_alternador, sistema_carga).
prueba_componente(inspeccionar_filtro_cabina_reemplazar_esta, filtro_cabina).
prueba_componente(inspeccionar_desgaste_eje_balanceo, eje_balanceo).
prueba_componente(inspeccionar_corrosion_terminales_bateria, bateria).
prueba_componente(inspeccionar_balero_dano_corrosion, balero_rueda).
prueba_componente(inspeccionar_desgaste_engranes_conicos, engranes_conicos).
prueba_componente(inspeccionar_motor_ventilador_residuos_dano, motor_ventilador_hvac).
prueba_componente(inspeccionar_fugas_caliper, caliper_freno).
prueba_componente(inspeccionar_manguera_freno_grietas_fugas, manguera_freno).
prueba_componente(inspeccionar_fugas_lineas_freno, liquido_frenos).
prueba_componente(inspeccionar_estado_pastillas_freno, pastillas_freno).
prueba_componente(inspeccionar_disco_rayaduras_alabeo, discos_freno).
prueba_componente(inspeccionar_desgaste_zapatas_freno, zapatas_tambor).
prueba_componente(inspeccionar_canister_grietas_dano, canister_carbon).
prueba_componente(inspeccionar_convertidor_catalitico_dano, catalizador).
prueba_componente(inspeccionar_fluido_diferencial_central, diferencial_central).
prueba_componente(inspeccionar_cable_embrague_desgaste, cable_embrague).
prueba_componente(inspeccionar_nivel_estado_liquido_embrague, cilindro_esclavo_embrague).
prueba_componente(inspeccionar_inyectores_diesel_fugas_u, bomba_inyeccion_diesel).
prueba_componente(inspeccionar_nivel_estado_fluido_diferencial, diferencial).
prueba_componente(inspeccionar_tapa_distribuidor_grietas, tapa_distribuidor).
prueba_componente(inspeccionar_banda_cortes_desgaste, banda_accesorios).
prueba_componente(inspeccionar_soportes_motor, soportes_motor).
prueba_componente(inspeccionar_multiple_escape_grietas_fugas, multiple_escape).
prueba_componente(inspeccionar_valvula_escape_carbonilla, valvula_escape).
prueba_componente(revisar_codigos_fallo_encendido, sensor_detonacion).
prueba_componente(inspeccionar_fugas_sistema_c, carga_refrigerante_ac).
prueba_componente(inspeccionar_fugas_aceite, aceite_motor).
prueba_componente(inspeccionar_filtro_combustible_reemplazar, filtro_combustible).
prueba_componente(inspeccionar_bomba_combustible_fugas_dano, bomba_combustible).
prueba_componente(inspeccionar_tanque_combustible_fugas_dano, tanque_combustible).
prueba_componente(inspeccionar_bujia_incandescente_carbonilla, bujia_incandescente).
prueba_componente(inspeccionar_filamento_foco_faro, foco_faro).
prueba_componente(inspeccionar_fugas_nucleo_calefaccion, nucleo_calefaccion).
prueba_componente(inspeccionar_conexiones_mangueras_calefaccion, manguera_calefaccion).
prueba_componente(inspeccionar_inyector_fugas_u_obstruccion, inyector_combustible).
prueba_componente(inspeccionar_valvula_admision_carbonilla, valvula_admision).
prueba_componente(inspeccionar_intercooler_fugas_dano, presion_turbo).
prueba_componente(inspeccionar_eje_motriz_grietas_deformacion, eje_motriz).
prueba_componente(inspeccionar_fugas_cilindro_maestro, cilindro_maestro_embrague).
prueba_componente(inspeccionar_fugas_cilindro_maestro, cilindro_maestro_freno).
prueba_componente(inspeccionar_bomba_aceite_desgaste_dano, bomba_aceite).
prueba_componente(inspeccionar_cableado_sensor_oxigeno, sensor_oxigeno).
prueba_componente(inspeccionar_anillos_piston, anillos_piston).
prueba_componente(inspeccionar_fugas_mangueras_direccion, liquido_direccion).
prueba_componente(inspeccionar_fugas_radiador_mangueras, refrigerante).
prueba_componente(inspeccionar_motor_rele_ventilador_radiador, ventilador_radiador).
prueba_componente(inspeccionar_radiador_fugas_dano, radiador).
prueba_componente(inspeccionar_danos_mangueras_radiador, manguera_radiador).
prueba_componente(inspeccionar_fugas_radiador_mangueras_bomba, bomba_agua).
prueba_componente(inspeccionar_fugas_radiador_mangueras_bomba, manguera_radiador).
prueba_componente(inspeccionar_fugas_radiador_mangueras_bomba, radiador).
prueba_componente(inspeccionar_deposito_grietas_fugas, deposito_refrigerante).
prueba_componente(inspeccionar_resistencia_sobrecalentamiento, resistencia_ventilador_hvac).
prueba_componente(inspeccionar_eje_rigido_grietas_dano, eje_rigido).
prueba_componente(inspeccionar_balanceo_alineacion_eje, eje_y_llantas).
prueba_componente(inspeccionar_botas_bujias, cables_bujias).
prueba_componente(inspeccionar_desgaste_escobillas_motor, motor_arranque).
prueba_componente(inspeccionar_carbonilla_cuerpo_aceleracion, cuerpo_aceleracion).
prueba_componente(inspeccionar_banda_distribucion, banda_distribucion).
prueba_componente(inspeccionar_fugas_dano_convertidor_par, convertidor_par).
prueba_componente(inspeccionar_filtro_transmision_reemplazar, filtro_transmision).
prueba_componente(inspeccionar_fugas_transmision, transmision_automatica).
prueba_componente(inspeccionar_fugas_carter_sellos_transmision, fluido_transmision).
prueba_componente(inspeccionar_desgaste_juego_junta_universal, junta_universal).
prueba_componente(inspeccionar_fugas_junta_tapa_valvulas, junta_tapa_valvulas).
prueba_componente(inspeccionar_fluido_acoplamiento_viscoso, acoplamiento_viscoso).
prueba_componente(probar_funcionamiento_bomba_liquido, liquido_limpiaparabrisas).
prueba_componente(inspeccionar_obstruccion_dano_bomba, bomba_limpiaparabrisas).
prueba_componente(inspeccionar_fugas_bomba_agua, bomba_agua).
prueba_componente(inspeccionar_juego_ruido_balero_maza, maza_rueda).
prueba_componente(inspeccionar_conexiones_sensor_velocidad_rueda, sensor_velocidad_rueda).
prueba_componente(inspeccionar_regulador_vidrio_electrico, motor_vidrio_puerta).
prueba_componente(inspeccionar_regulador_vidrio_electrico, regulador_vidrio_puerta).
prueba_componente(inspeccionar_desgaste_articulacion, motor_limpiaparabrisas).
prueba_componente(inspeccionar_arnes_cables_dano_corrosion, solenoide_transmision).
prueba_componente(inspeccionar_cableado_modulo_abs, modulo_abs).
prueba_componente(medir_espesor_disco_freno, discos_freno).
prueba_componente(ejecutar_escaneo_diagnostico_sistema_c, compresor_ac).
prueba_componente(realizar_prueba_compresion, anillos_piston).
prueba_componente(probar_presion_manguera_freno, manguera_freno).
prueba_componente(probar_presion_sistema_enfriamiento, bomba_agua).
prueba_componente(probar_presion_sistema_enfriamiento, manguera_calefaccion).
prueba_componente(probar_presion_sistema_enfriamiento, manguera_radiador).
prueba_componente(probar_presion_sistema_enfriamiento, radiador).
prueba_componente(probar_presion_mangueras_calefaccion, manguera_calefaccion).
prueba_componente(escanear_codigos_falla_dtc, ecu).
prueba_componente(probar_funcionamiento_valvula_iac, valvula_iac).
prueba_componente(medir_voltaje_sensor_map, sensor_map).
prueba_componente(medir_salida_alternador, sistema_carga).
prueba_componente(medir_voltaje_bateria, bateria).
prueba_componente(medir_voltaje_bateria, sistema_carga).
prueba_componente(probar_funcionamiento_motor_ventilador, motor_ventilador_hvac).
prueba_componente(probar_continuidad_resistencia_ventilador, resistencia_ventilador_hvac).
prueba_componente(medir_presion_vacio_servofreno, servofreno).
prueba_componente(probar_funcionamiento_valvula_purga, canister_carbon).
prueba_componente(probar_funcionamiento_valvula_purga, valvula_purga_canister).
prueba_componente(medir_presion_bomba_inyeccion_diesel, bomba_inyeccion_diesel).
prueba_componente(probar_patron_rocio_inyector, inyector_combustible).
prueba_componente(probar_funcionamiento_regulador_presion, regulador_presion_combustible).
prueba_componente(medir_presion_bomba_combustible, bomba_combustible).
prueba_componente(probar_sensor_presion_tanque_combustible, sensor_presion_tanque).
prueba_componente(medir_resistencia_bujia_incandescente, bujia_incandescente).
prueba_componente(probar_rele_claxon, claxon).
prueba_componente(probar_continuidad_cables_bujias, cables_bujias).
prueba_componente(probar_sensor_detonacion, sensor_detonacion).
prueba_componente(medir_presion_aceite_manometro, bomba_aceite).
prueba_componente(medir_voltaje_sensor_oxigeno, sensor_oxigeno).
prueba_componente(verificar_alimentacion_electrica_actuador, actuador_seguro_puerta).
prueba_componente(verificar_alimentacion_electrica_bomba, bomba_limpiaparabrisas).
prueba_componente(verificar_alimentacion_electrica_motor_vidrio, motor_vidrio_puerta).
prueba_componente(verificar_alimentacion_electrica_motor, motor_limpiaparabrisas).
prueba_componente(probar_funcionamiento_ventilador_radiador, ventilador_radiador).
prueba_componente(probar_solenoide_motor_arranque, motor_arranque).
prueba_componente(probar_funcionamiento_termostato, termostato).
prueba_componente(probar_sensor_posicion_acelerador_tps, cuerpo_aceleracion).
prueba_componente(probar_sensor_posicion_acelerador_tps, sensor_tps).
prueba_componente(probar_continuidad_solenoides_transmision, solenoide_transmision).
prueba_componente(probar_funcionamiento_acoplamiento_viscoso, acoplamiento_viscoso).
prueba_componente(probar_funcionamiento_bomba_agua, bomba_agua).

prueba_sintoma(ajustar_tension_cable_embrague, dificultad_meter_cambios, 0.50).
prueba_sintoma(ajustar_tension_cable_embrague, pedal_embrague_flojo, 0.50).
prueba_sintoma(revisar_fusible_abs, luz_abs_encendida, 0.70).
prueba_sintoma(revisar_fusible_abs, pedal_freno_pulsa, 0.70).
prueba_sintoma(revisar_funcionamiento_embrague_compresor_c, ac_no_enfria, 0.70).
prueba_sintoma(revisar_funcionamiento_embrague_compresor_c, ac_no_funciona, 0.70).
prueba_sintoma(revisar_funcionamiento_embrague_compresor_c, ac_ruido_anormal, 0.70).
prueba_sintoma(revisar_sensor_temperatura_evaporador_c, flujo_aire_reducido, 0.50).
prueba_sintoma(revisar_sensor_temperatura_evaporador_c, olor_humedo_ventilas, 0.50).
prueba_sintoma(revisar_funcionamiento_componentes_sistema_c, ac_no_enfria, 0.60).
prueba_sintoma(revisar_funcionamiento_componentes_sistema_c, ac_no_funciona, 0.60).
prueba_sintoma(revisar_funcionamiento_componentes_sistema_c, ac_ruido_anormal, 0.60).
prueba_sintoma(revisar_funcionamiento_componentes_sistema_c, flujo_aire_reducido, 0.60).
prueba_sintoma(revisar_funcionamiento_componentes_sistema_c, olor_humedo_ventilas, 0.60).
prueba_sintoma(medir_presion_sistema_c_manometro, ac_no_enfria, 0.70).
prueba_sintoma(medir_presion_sistema_c_manometro, ac_presion_baja, 0.70).
prueba_sintoma(revisar_codigos_falla_ecu, mal_consumo_combustible, 0.70).
prueba_sintoma(revisar_codigos_falla_ecu, motor_fallos_encendido, 0.70).
prueba_sintoma(revisar_manguera_valvula_pcv_tiene_grietas, fuga_aceite, 0.50).
prueba_sintoma(revisar_manguera_valvula_pcv_tiene_grietas, ralenti_inestable, 0.50).
prueba_sintoma(revisar_tension_banda_alternador, faros_tenues, 0.50).
prueba_sintoma(revisar_tension_banda_alternador, luz_bateria_encendida, 0.50).
prueba_sintoma(revisar_desgaste_baleros_eje, ruido_eje_al_girar, 0.50).
prueba_sintoma(revisar_desgaste_baleros_eje, ruido_eje_trasero, 0.50).
prueba_sintoma(revisar_desgaste_baleros_eje, vehiculo_rebota, 0.50).
prueba_sintoma(revisar_desgaste_baleros_eje, vehiculo_se_inclina, 0.50).
prueba_sintoma(revisar_alineacion_eje_balanceo, ralenti_inestable, 0.50).
prueba_sintoma(revisar_alineacion_eje_balanceo, vibracion_motor, 0.50).
prueba_sintoma(revisar_tension_alineacion_banda, chirrido_correa, 0.50).
prueba_sintoma(revisar_tension_alineacion_banda, motor_sobrecalienta, 0.50).
prueba_sintoma(revisar_tension_alineacion_banda, rendimiento_motor_deficiente, 0.50).
prueba_sintoma(medir_presion_sobrealimentacion_manometro, perdida_potencia, 0.70).
prueba_sintoma(medir_presion_sobrealimentacion_manometro, turbo_lag, 0.70).
prueba_sintoma(revisar_manguera_vacio_servofreno, pedal_freno_duro, 0.70).
prueba_sintoma(revisar_manguera_vacio_servofreno, pedal_freno_esponjoso, 0.70).
prueba_sintoma(revisar_funcionamiento_piston_caliper, freno_arrastra, 0.50).
prueba_sintoma(revisar_funcionamiento_piston_caliper, freno_jala_a_un_lado, 0.50).
prueba_sintoma(revisar_rayaduras_grietas_tambor_freno, freno_arrastra, 0.50).
prueba_sintoma(revisar_rayaduras_grietas_tambor_freno, pedal_freno_esponjoso, 0.50).
prueba_sintoma(revisar_nivel_estado_liquido_frenos, luz_freno_encendida, 0.70).
prueba_sintoma(revisar_nivel_estado_liquido_frenos, pedal_freno_esponjoso, 0.70).
prueba_sintoma(revisar_nivel_liquido_frenos_cilindro_maestro, fuga_liquido_frenos, 0.70).
prueba_sintoma(revisar_nivel_liquido_frenos_cilindro_maestro, pedal_freno_esponjoso, 0.70).
prueba_sintoma(medir_espesor_pastillas_freno, chirrido_frenos, 0.70).
prueba_sintoma(medir_espesor_pastillas_freno, pedal_freno_pulsa, 0.70).
prueba_sintoma(revisar_eficiencia_convertidor_catalitico, luz_check_engine, 0.50).
prueba_sintoma(revisar_eficiencia_convertidor_catalitico, olor_huevo_podrido, 0.50).
prueba_sintoma(revisar_nivel_liquido_embrague, embrague_patina, 0.70).
prueba_sintoma(revisar_nivel_liquido_embrague, pedal_embrague_esponjoso, 0.70).
prueba_sintoma(revisar_fugas_cilindro_esclavo_embrague, fuga_fluido_embrague, 0.70).
prueba_sintoma(revisar_fugas_cilindro_esclavo_embrague, pedal_embrague_esponjoso, 0.70).
prueba_sintoma(revisar_flujo_refrigerante_nucleo_calefaccion, olor_refrigerante_cabina, 0.50).
prueba_sintoma(revisar_flujo_refrigerante_nucleo_calefaccion, sin_calefaccion, 0.50).
prueba_sintoma(revisar_nivel_estado_refrigerante, fuga_refrigerante, 0.70).
prueba_sintoma(revisar_nivel_estado_refrigerante, motor_sobrecalienta, 0.70).
prueba_sintoma(revisar_nivel_refrigerante_deposito, luz_refrigerante_bajo, 0.70).
prueba_sintoma(revisar_nivel_refrigerante_deposito, motor_sobrecalienta, 0.70).
prueba_sintoma(revisar_desgaste_rotor_distribuidor, dificultad_arrancar, 0.50).
prueba_sintoma(revisar_desgaste_rotor_distribuidor, motor_fallos_encendido, 0.50).
prueba_sintoma(revisar_alineacion_tren_motriz, golpeteo_al_cambiar, 0.50).
prueba_sintoma(revisar_alineacion_tren_motriz, vibracion_eje_transmision, 0.50).
prueba_sintoma(revisar_nivel_estado_aceite_motor, luz_presion_aceite, 0.70).
prueba_sintoma(revisar_nivel_estado_aceite_motor, ruido_motor_fuerte, 0.70).
prueba_sintoma(revisar_apriete_pernos_multiple_escape, fugas_escape_visibles, 0.50).
prueba_sintoma(revisar_apriete_pernos_multiple_escape, ruido_escape_fuerte, 0.50).
prueba_sintoma(revisar_fugas_junta_multiple_escape, fugas_escape_visibles, 0.70).
prueba_sintoma(revisar_fugas_junta_multiple_escape, olor_escape_cabina, 0.50).
prueba_sintoma(revisar_fugas_junta_multiple_escape, ruido_escape_fuerte, 0.70).
prueba_sintoma(revisar_residuos_toma_aire_cabina, flujo_aire_reducido, 0.50).
prueba_sintoma(revisar_residuos_toma_aire_cabina, olor_humedo_ventilas, 0.50).
prueba_sintoma(revisar_desgaste_baleros_diferencial, vibracion_alta_velocidad, 0.50).
prueba_sintoma(revisar_desgaste_baleros_diferencial, zumbido_diferencial, 0.50).
prueba_sintoma(revisar_diferencial_central_tiene_juego, ruido_tren_motriz_giros, 0.50).
prueba_sintoma(revisar_diferencial_central_tiene_juego, vehiculo_se_traba_giros, 0.50).
prueba_sintoma(revisar_fugas_condensador_c, ac_no_enfria, 0.50).
prueba_sintoma(revisar_fugas_mangueras_valvula_purga, luz_check_engine, 0.50).
prueba_sintoma(revisar_fugas_mangueras_valvula_purga, ralenti_inestable, 0.50).
prueba_sintoma(revisar_sello_tapon_tanque_combustible, fuga_combustible, 0.50).
prueba_sintoma(revisar_sello_tapon_tanque_combustible, luz_check_engine, 0.50).
prueba_sintoma(revisar_sello_tapon_tanque_combustible, luz_tapon_gasolina, 0.50).
prueba_sintoma(revisar_sello_tapon_tanque_combustible, olor_combustible, 0.50).
prueba_sintoma(medir_presion_combustible_regulador, humo_negro_escape, 0.50).
prueba_sintoma(medir_presion_combustible_regulador, motor_se_apaga, 0.50).
prueba_sintoma(revisar_nivel_estado_aceite_engranes, dificultad_meter_cambios, 0.50).
prueba_sintoma(revisar_nivel_estado_aceite_engranes, zumbido_tren_motriz, 0.50).
prueba_sintoma(revisar_corrosion_socket_faro, faro_no_funciona, 0.50).
prueba_sintoma(revisar_corrosion_socket_faro, faros_tenues, 0.50).
prueba_sintoma(revisar_fusible_claxon, claxon_no_suena, 0.70).
prueba_sintoma(revisar_fugas_conexiones_mangueras, fuga_refrigerante, 0.50).
prueba_sintoma(revisar_fugas_conexiones_mangueras, mangueras_desgastadas, 0.50).
prueba_sintoma(revisar_apriete_pernos_montaje, golpeteo_al_acelerar, 0.50).
prueba_sintoma(revisar_apriete_pernos_montaje, motor_se_mueve_excesivo, 0.50).
prueba_sintoma(revisar_nivel_liquido_direccion, ruido_al_girar_volante, 0.70).
prueba_sintoma(revisar_nivel_liquido_direccion, volante_duro, 0.70).
prueba_sintoma(revisar_fugas_bomba_mangueras_direccion, ruido_al_girar_volante, 0.50).
prueba_sintoma(revisar_sello_tapon_radiador, fuga_refrigerante, 0.50).
prueba_sintoma(revisar_sello_tapon_radiador, motor_sobrecalienta, 0.50).
prueba_sintoma(revisar_obstruccion_dano_radiador, motor_sobrecalienta, 0.70).
prueba_sintoma(revisar_obstruccion_dano_radiador, temperatura_zona_roja, 0.70).
prueba_sintoma(revisar_sensores_relacionados_codigos_dtc, luz_check_engine, 0.60).
prueba_sintoma(revisar_sensores_relacionados_codigos_dtc, mal_consumo_combustible, 0.60).
prueba_sintoma(revisar_sensores_relacionados_codigos_dtc, motor_golpetea, 0.60).
prueba_sintoma(revisar_sensores_relacionados_codigos_dtc, motor_titubea, 0.60).
prueba_sintoma(revisar_sensores_relacionados_codigos_dtc, ralenti_inestable, 0.60).
prueba_sintoma(revisar_sensores_relacionados_codigos_dtc, se_apaga_ralenti, 0.60).
prueba_sintoma(revisar_alineacion_marcas_tiempo, motor_fallos_encendido, 0.50).
prueba_sintoma(revisar_alineacion_marcas_tiempo, no_arranca, 0.50).
prueba_sintoma(medir_presion_llantas_manometro_revisar_su, desgaste_irregular_llantas, 0.50).
prueba_sintoma(medir_presion_llantas_manometro_revisar_su, luz_tpms, 0.70).
prueba_sintoma(medir_presion_llantas_manometro_revisar_su, presion_llantas_baja, 0.70).
prueba_sintoma(medir_presion_llantas_manometro_revisar_su, vibracion_al_conducir, 0.50).
prueba_sintoma(revisar_nivel_estado_fluido_transmision, retraso_cambios, 0.70).
prueba_sintoma(revisar_nivel_estado_fluido_transmision, temblor_al_acelerar, 0.50).
prueba_sintoma(revisar_nivel_estado_fluido_transmision, transmision_patina, 0.70).
prueba_sintoma(revisar_nivel_estado_fluido_transmision, transmision_sobrecalienta, 0.70).
prueba_sintoma(revisar_holgura_valvulas, motor_fallos_encendido, 0.50).
prueba_sintoma(revisar_holgura_valvulas, ralenti_inestable, 0.50).
prueba_sintoma(revisar_apriete_pernos_tapa_valvulas, fuga_aceite_tapa_valvulas, 0.50).
prueba_sintoma(revisar_apriete_pernos_tapa_valvulas, olor_aceite_quemado, 0.50).
prueba_sintoma(revisar_nivel_liquido_limpiaparabrisas, chorro_debil_limpiaparabrisas, 0.70).
prueba_sintoma(revisar_nivel_liquido_limpiaparabrisas, sin_chorro_limpiaparabrisas, 0.70).
prueba_sintoma(revisar_juego_desgaste_baleros_rueda, chasquidos_al_girar, 0.50).
prueba_sintoma(revisar_juego_desgaste_baleros_rueda, desgaste_irregular_llantas, 0.70).
prueba_sintoma(revisar_juego_desgaste_baleros_rueda, rechinido_ruedas, 0.70).
prueba_sintoma(revisar_juego_desgaste_baleros_rueda, rueda_bambolea, 0.50).
prueba_sintoma(revisar_sensor_velocidad_rueda_tiene_suciedad, luz_abs_encendida, 0.50).
prueba_sintoma(revisar_sensor_velocidad_rueda_tiene_suciedad, velocimetro_erratico, 0.50).
prueba_sintoma(revisar_alineacion_vidrio_guias, ventana_atascada, 0.50).
prueba_sintoma(revisar_alineacion_vidrio_guias, ventana_descarrilada, 0.50).
prueba_sintoma(limpiar_cuerpo_aceleracion_valvula_iac, ralenti_inestable, 0.50).
prueba_sintoma(limpiar_cuerpo_aceleracion_valvula_iac, se_apaga_ralenti, 0.50).
prueba_sintoma(inspeccionar_compresor_c_fugas_danos, ac_no_enfria, 0.50).
prueba_sintoma(inspeccionar_compresor_c_fugas_danos, ac_no_funciona, 0.50).
prueba_sintoma(inspeccionar_compresor_c_fugas_danos, ac_ruido_anormal, 0.50).
prueba_sintoma(inspeccionar_condensador_c_residuos_u, ac_no_enfria, 0.70).
prueba_sintoma(inspeccionar_evaporador_c_moho, flujo_aire_reducido, 0.70).
prueba_sintoma(inspeccionar_evaporador_c_moho, olor_humedo_ventilas, 0.70).
prueba_sintoma(inspeccionar_arnes_cables_ecu, mal_consumo_combustible, 0.50).
prueba_sintoma(inspeccionar_arnes_cables_ecu, motor_fallos_encendido, 0.50).
prueba_sintoma(inspeccionar_manguera_vacio_sensor_map, luz_check_engine, 0.50).
prueba_sintoma(inspeccionar_manguera_vacio_sensor_map, ralenti_inestable, 0.50).
prueba_sintoma(inspeccionar_valvula_pcv_obstrucciones, fuga_aceite, 0.70).
prueba_sintoma(inspeccionar_valvula_pcv_obstrucciones, ralenti_inestable, 0.70).
prueba_sintoma(inspeccionar_sensores_tpms_dano_corrosion, luz_tpms, 0.50).
prueba_sintoma(inspeccionar_sensores_tpms_dano_corrosion, presion_llantas_baja, 0.50).
prueba_sintoma(inspeccionar_cableado_tps, motor_titubea, 0.50).
prueba_sintoma(inspeccionar_cableado_tps, se_apaga_ralenti, 0.50).
prueba_sintoma(inspeccionar_mecanismo_actuador_obstrucciones, cerradura_no_responde, 0.50).
prueba_sintoma(inspeccionar_mecanismo_actuador_obstrucciones, clic_puerta, 0.50).
prueba_sintoma(inspeccionar_filtro_aire_motor_reemplazar_esta, humo_negro_escape, 0.70).
prueba_sintoma(inspeccionar_filtro_aire_motor_reemplazar_esta, rendimiento_motor_deficiente, 0.70).
prueba_sintoma(inspeccionar_funcionamiento_alternador, luz_bateria_encendida, 0.50).
prueba_sintoma(inspeccionar_funcionamiento_alternador, voltaje_bajo, 0.50).
prueba_sintoma(inspeccionar_filtro_cabina_reemplazar_esta, flujo_aire_reducido, 0.70).
prueba_sintoma(inspeccionar_filtro_cabina_reemplazar_esta, olor_humedo_ventilas, 0.70).
prueba_sintoma(inspeccionar_desgaste_eje_balanceo, ralenti_inestable, 0.70).
prueba_sintoma(inspeccionar_desgaste_eje_balanceo, vibracion_motor, 0.70).
prueba_sintoma(inspeccionar_corrosion_terminales_bateria, arranque_lento, 0.50).
prueba_sintoma(inspeccionar_corrosion_terminales_bateria, clic_al_arrancar, 0.50).
prueba_sintoma(inspeccionar_balero_dano_corrosion, desgaste_irregular_llantas, 0.50).
prueba_sintoma(inspeccionar_balero_dano_corrosion, rechinido_ruedas, 0.50).
prueba_sintoma(inspeccionar_desgaste_engranes_conicos, dificultad_meter_cambios, 0.70).
prueba_sintoma(inspeccionar_desgaste_engranes_conicos, zumbido_tren_motriz, 0.70).
prueba_sintoma(inspeccionar_motor_ventilador_residuos_dano, ruido_hvac, 0.50).
prueba_sintoma(inspeccionar_motor_ventilador_residuos_dano, sin_aire_ventilas, 0.50).
prueba_sintoma(inspeccionar_fugas_caliper, freno_arrastra, 0.70).
prueba_sintoma(inspeccionar_fugas_caliper, freno_jala_a_un_lado, 0.70).
prueba_sintoma(inspeccionar_manguera_freno_grietas_fugas, fuga_liquido_frenos, 0.70).
prueba_sintoma(inspeccionar_manguera_freno_grietas_fugas, pedal_freno_esponjoso, 0.70).
prueba_sintoma(inspeccionar_fugas_lineas_freno, luz_freno_encendida, 0.50).
prueba_sintoma(inspeccionar_fugas_lineas_freno, pedal_freno_esponjoso, 0.50).
prueba_sintoma(inspeccionar_estado_pastillas_freno, chirrido_frenos, 0.50).
prueba_sintoma(inspeccionar_estado_pastillas_freno, pedal_freno_pulsa, 0.50).
prueba_sintoma(inspeccionar_disco_rayaduras_alabeo, pedal_freno_pulsa, 0.50).
prueba_sintoma(inspeccionar_disco_rayaduras_alabeo, vibracion_volante, 0.50).
prueba_sintoma(inspeccionar_desgaste_zapatas_freno, freno_arrastra, 0.70).
prueba_sintoma(inspeccionar_desgaste_zapatas_freno, pedal_freno_esponjoso, 0.70).
prueba_sintoma(inspeccionar_canister_grietas_dano, luz_check_engine, 0.50).
prueba_sintoma(inspeccionar_canister_grietas_dano, olor_combustible, 0.50).
prueba_sintoma(inspeccionar_convertidor_catalitico_dano, luz_check_engine, 0.70).
prueba_sintoma(inspeccionar_convertidor_catalitico_dano, olor_huevo_podrido, 0.70).
prueba_sintoma(inspeccionar_fluido_diferencial_central, ruido_tren_motriz_giros, 0.70).
prueba_sintoma(inspeccionar_fluido_diferencial_central, vehiculo_se_traba_giros, 0.70).
prueba_sintoma(inspeccionar_cable_embrague_desgaste, dificultad_meter_cambios, 0.70).
prueba_sintoma(inspeccionar_cable_embrague_desgaste, pedal_embrague_flojo, 0.70).
prueba_sintoma(inspeccionar_nivel_estado_liquido_embrague, fuga_fluido_embrague, 0.50).
prueba_sintoma(inspeccionar_nivel_estado_liquido_embrague, pedal_embrague_esponjoso, 0.50).
prueba_sintoma(inspeccionar_inyectores_diesel_fugas_u, humo_negro_escape, 0.50).
prueba_sintoma(inspeccionar_inyectores_diesel_fugas_u, motor_fallos_encendido, 0.50).
prueba_sintoma(inspeccionar_nivel_estado_fluido_diferencial, vibracion_alta_velocidad, 0.70).
prueba_sintoma(inspeccionar_nivel_estado_fluido_diferencial, zumbido_diferencial, 0.70).
prueba_sintoma(inspeccionar_tapa_distribuidor_grietas, dificultad_arrancar, 0.70).
prueba_sintoma(inspeccionar_tapa_distribuidor_grietas, motor_fallos_encendido, 0.70).
prueba_sintoma(inspeccionar_banda_cortes_desgaste, chirrido_correa, 0.70).
prueba_sintoma(inspeccionar_banda_cortes_desgaste, motor_sobrecalienta, 0.70).
prueba_sintoma(inspeccionar_banda_cortes_desgaste, rendimiento_motor_deficiente, 0.70).
prueba_sintoma(inspeccionar_soportes_motor, golpeteo_al_acelerar, 0.70).
prueba_sintoma(inspeccionar_soportes_motor, motor_se_mueve_excesivo, 0.70).
prueba_sintoma(inspeccionar_multiple_escape_grietas_fugas, olor_escape_cabina, 0.70).
prueba_sintoma(inspeccionar_multiple_escape_grietas_fugas, ruido_escape_fuerte, 0.70).
prueba_sintoma(inspeccionar_valvula_escape_carbonilla, motor_fallos_encendido, 0.70).
prueba_sintoma(inspeccionar_valvula_escape_carbonilla, ralenti_inestable, 0.70).
prueba_sintoma(revisar_codigos_fallo_encendido, mal_consumo_combustible, 0.50).
prueba_sintoma(revisar_codigos_fallo_encendido, motor_golpetea, 0.50).
prueba_sintoma(inspeccionar_fugas_sistema_c, ac_no_enfria, 0.50).
prueba_sintoma(inspeccionar_fugas_sistema_c, ac_presion_baja, 0.50).
prueba_sintoma(inspeccionar_fugas_aceite, luz_presion_aceite, 0.50).
prueba_sintoma(inspeccionar_fugas_aceite, ruido_motor_fuerte, 0.50).
prueba_sintoma(inspeccionar_filtro_combustible_reemplazar, mala_aceleracion, 0.70).
prueba_sintoma(inspeccionar_filtro_combustible_reemplazar, motor_se_apaga, 0.70).
prueba_sintoma(inspeccionar_bomba_combustible_fugas_dano, motor_tose_alta_velocidad, 0.50).
prueba_sintoma(inspeccionar_bomba_combustible_fugas_dano, perdida_potencia, 0.50).
prueba_sintoma(inspeccionar_tanque_combustible_fugas_dano, fuga_combustible, 0.70).
prueba_sintoma(inspeccionar_tanque_combustible_fugas_dano, olor_combustible, 0.70).
prueba_sintoma(inspeccionar_bujia_incandescente_carbonilla, arranque_dificil_frio, 0.50).
prueba_sintoma(inspeccionar_bujia_incandescente_carbonilla, luz_bujias_incandescentes, 0.50).
prueba_sintoma(inspeccionar_filamento_foco_faro, faro_no_funciona, 0.70).
prueba_sintoma(inspeccionar_filamento_foco_faro, faros_tenues, 0.70).
prueba_sintoma(inspeccionar_fugas_nucleo_calefaccion, olor_refrigerante_cabina, 0.70).
prueba_sintoma(inspeccionar_fugas_nucleo_calefaccion, sin_calefaccion, 0.70).
prueba_sintoma(inspeccionar_conexiones_mangueras_calefaccion, fuga_refrigerante, 0.70).
prueba_sintoma(inspeccionar_conexiones_mangueras_calefaccion, olor_refrigerante_cabina, 0.70).
prueba_sintoma(inspeccionar_inyector_fugas_u_obstruccion, mal_consumo_combustible, 0.50).
prueba_sintoma(inspeccionar_inyector_fugas_u_obstruccion, motor_fallos_encendido, 0.50).
prueba_sintoma(inspeccionar_valvula_admision_carbonilla, motor_fallos_encendido, 0.70).
prueba_sintoma(inspeccionar_valvula_admision_carbonilla, ralenti_inestable, 0.70).
prueba_sintoma(inspeccionar_intercooler_fugas_dano, perdida_potencia, 0.50).
prueba_sintoma(inspeccionar_intercooler_fugas_dano, turbo_lag, 0.50).
prueba_sintoma(inspeccionar_eje_motriz_grietas_deformacion, ruido_eje_al_girar, 0.70).
prueba_sintoma(inspeccionar_eje_motriz_grietas_deformacion, vehiculo_se_inclina, 0.70).
prueba_sintoma(inspeccionar_fugas_cilindro_maestro, embrague_patina, 0.50).
prueba_sintoma(inspeccionar_fugas_cilindro_maestro, fuga_liquido_frenos, 0.50).
prueba_sintoma(inspeccionar_fugas_cilindro_maestro, pedal_embrague_esponjoso, 0.50).
prueba_sintoma(inspeccionar_fugas_cilindro_maestro, pedal_freno_esponjoso, 0.50).
prueba_sintoma(inspeccionar_bomba_aceite_desgaste_dano, luz_presion_aceite, 0.50).
prueba_sintoma(inspeccionar_bomba_aceite_desgaste_dano, motor_golpetea, 0.50).
prueba_sintoma(inspeccionar_cableado_sensor_oxigeno, luz_check_engine, 0.50).
prueba_sintoma(inspeccionar_cableado_sensor_oxigeno, mal_consumo_combustible, 0.50).
prueba_sintoma(inspeccionar_anillos_piston, humo_azul_escape, 0.50).
prueba_sintoma(inspeccionar_anillos_piston, perdida_potencia, 0.50).
prueba_sintoma(inspeccionar_fugas_mangueras_direccion, ruido_al_girar_volante, 0.50).
prueba_sintoma(inspeccionar_fugas_mangueras_direccion, volante_duro, 0.50).
prueba_sintoma(inspeccionar_fugas_radiador_mangueras, fuga_refrigerante, 0.50).
prueba_sintoma(inspeccionar_fugas_radiador_mangueras, motor_sobrecalienta, 0.50).
prueba_sintoma(inspeccionar_motor_rele_ventilador_radiador, ac_no_enfria_ralenti, 0.50).
prueba_sintoma(inspeccionar_motor_rele_ventilador_radiador, motor_sobrecalienta, 0.50).
prueba_sintoma(inspeccionar_radiador_fugas_dano, fuga_refrigerante, 0.70).
prueba_sintoma(inspeccionar_radiador_fugas_dano, motor_sobrecalienta, 0.70).
prueba_sintoma(inspeccionar_danos_mangueras_radiador, fuga_refrigerante, 0.70).
prueba_sintoma(inspeccionar_danos_mangueras_radiador, mangueras_desgastadas, 0.70).
prueba_sintoma(inspeccionar_fugas_radiador_mangueras_bomba, fuga_refrigerante, 0.60).
prueba_sintoma(inspeccionar_fugas_radiador_mangueras_bomba, fuga_refrigerante_frente_motor, 0.60).
prueba_sintoma(inspeccionar_fugas_radiador_mangueras_bomba, mangueras_desgastadas, 0.60).
prueba_sintoma(inspeccionar_fugas_radiador_mangueras_bomba, motor_sobrecalienta, 0.60).
prueba_sintoma(inspeccionar_deposito_grietas_fugas, luz_refrigerante_bajo, 0.50).
prueba_sintoma(inspeccionar_deposito_grietas_fugas, motor_sobrecalienta, 0.50).
prueba_sintoma(inspeccionar_resistencia_sobrecalentamiento, ventilador_hvac_erratico, 0.50).
prueba_sintoma(inspeccionar_eje_rigido_grietas_dano, ruido_eje_trasero, 0.70).
prueba_sintoma(inspeccionar_eje_rigido_grietas_dano, vehiculo_rebota, 0.70).
prueba_sintoma(inspeccionar_balanceo_alineacion_eje, desgaste_irregular_llantas, 0.70).
prueba_sintoma(inspeccionar_balanceo_alineacion_eje, vibracion_al_conducir, 0.70).
prueba_sintoma(inspeccionar_botas_bujias, mal_consumo_combustible, 0.50).
prueba_sintoma(inspeccionar_botas_bujias, motor_fallos_encendido, 0.50).
prueba_sintoma(inspeccionar_desgaste_escobillas_motor, clic_al_arrancar, 0.50).
prueba_sintoma(inspeccionar_desgaste_escobillas_motor, motor_no_gira, 0.50).
prueba_sintoma(inspeccionar_carbonilla_cuerpo_aceleracion, mala_aceleracion, 0.70).
prueba_sintoma(inspeccionar_carbonilla_cuerpo_aceleracion, se_apaga_ralenti, 0.70).
prueba_sintoma(inspeccionar_banda_distribucion, motor_fallos_encendido, 0.70).
prueba_sintoma(inspeccionar_banda_distribucion, no_arranca, 0.70).
prueba_sintoma(inspeccionar_fugas_dano_convertidor_par, temblor_al_acelerar, 0.70).
prueba_sintoma(inspeccionar_fugas_dano_convertidor_par, transmision_patina, 0.70).
prueba_sintoma(inspeccionar_filtro_transmision_reemplazar, retraso_cambios, 0.70).
prueba_sintoma(inspeccionar_filtro_transmision_reemplazar, transmision_patina, 0.70).
prueba_sintoma(inspeccionar_fugas_transmision, retraso_cambios, 0.50).
prueba_sintoma(inspeccionar_fugas_transmision, transmision_patina, 0.50).
prueba_sintoma(inspeccionar_fugas_carter_sellos_transmision, transmision_patina, 0.50).
prueba_sintoma(inspeccionar_fugas_carter_sellos_transmision, transmision_sobrecalienta, 0.50).
prueba_sintoma(inspeccionar_desgaste_juego_junta_universal, golpeteo_al_cambiar, 0.70).
prueba_sintoma(inspeccionar_desgaste_juego_junta_universal, vibracion_eje_transmision, 0.70).
prueba_sintoma(inspeccionar_fugas_junta_tapa_valvulas, fuga_aceite_tapa_valvulas, 0.70).
prueba_sintoma(inspeccionar_fugas_junta_tapa_valvulas, olor_aceite_quemado, 0.70).
prueba_sintoma(inspeccionar_fluido_acoplamiento_viscoso, ruido_tren_motriz_giros, 0.50).
prueba_sintoma(inspeccionar_fluido_acoplamiento_viscoso, vehiculo_se_traba_giros, 0.50).
prueba_sintoma(probar_funcionamiento_bomba_liquido, chorro_debil_limpiaparabrisas, 0.50).
prueba_sintoma(probar_funcionamiento_bomba_liquido, sin_chorro_limpiaparabrisas, 0.50).
prueba_sintoma(inspeccionar_obstruccion_dano_bomba, chorro_debil_limpiaparabrisas, 0.50).
prueba_sintoma(inspeccionar_obstruccion_dano_bomba, sin_chorro_limpiaparabrisas, 0.50).
prueba_sintoma(inspeccionar_fugas_bomba_agua, fuga_refrigerante_frente_motor, 0.70).
prueba_sintoma(inspeccionar_fugas_bomba_agua, motor_sobrecalienta, 0.70).
prueba_sintoma(inspeccionar_juego_ruido_balero_maza, chasquidos_al_girar, 0.70).
prueba_sintoma(inspeccionar_juego_ruido_balero_maza, rueda_bambolea, 0.70).
prueba_sintoma(inspeccionar_conexiones_sensor_velocidad_rueda, luz_abs_encendida, 0.70).
prueba_sintoma(inspeccionar_conexiones_sensor_velocidad_rueda, velocimetro_erratico, 0.70).
prueba_sintoma(inspeccionar_regulador_vidrio_electrico, ventana_atascada, 0.70).
prueba_sintoma(inspeccionar_regulador_vidrio_electrico, ventana_descarrilada, 0.70).
prueba_sintoma(inspeccionar_regulador_vidrio_electrico, ventana_intermitente, 0.50).
prueba_sintoma(inspeccionar_regulador_vidrio_electrico, ventana_no_se_mueve, 0.50).
prueba_sintoma(inspeccionar_desgaste_articulacion, limpiaparabrisas_intermitente, 0.50).
prueba_sintoma(inspeccionar_desgaste_articulacion, limpiaparabrisas_no_funciona, 0.50).
prueba_sintoma(inspeccionar_arnes_cables_dano_corrosion, cambios_erraticos, 0.50).
prueba_sintoma(inspeccionar_arnes_cables_dano_corrosion, transmision_no_cambia, 0.50).
prueba_sintoma(inspeccionar_cableado_modulo_abs, luz_abs_encendida, 0.50).
prueba_sintoma(inspeccionar_cableado_modulo_abs, pedal_freno_pulsa, 0.50).
prueba_sintoma(medir_espesor_disco_freno, pedal_freno_pulsa, 0.70).
prueba_sintoma(medir_espesor_disco_freno, vibracion_volante, 0.70).
prueba_sintoma(ejecutar_escaneo_diagnostico_sistema_c, ac_no_enfria, 0.60).
prueba_sintoma(ejecutar_escaneo_diagnostico_sistema_c, ac_no_funciona, 0.60).
prueba_sintoma(ejecutar_escaneo_diagnostico_sistema_c, ac_ruido_anormal, 0.60).
prueba_sintoma(realizar_prueba_compresion, humo_azul_escape, 0.70).
prueba_sintoma(realizar_prueba_compresion, perdida_potencia, 0.70).
prueba_sintoma(probar_presion_manguera_freno, fuga_liquido_frenos, 0.50).
prueba_sintoma(probar_presion_manguera_freno, pedal_freno_esponjoso, 0.50).
prueba_sintoma(probar_presion_sistema_enfriamiento, fuga_refrigerante, 0.60).
prueba_sintoma(probar_presion_sistema_enfriamiento, fuga_refrigerante_frente_motor, 0.60).
prueba_sintoma(probar_presion_sistema_enfriamiento, mangueras_desgastadas, 0.60).
prueba_sintoma(probar_presion_sistema_enfriamiento, motor_sobrecalienta, 0.60).
prueba_sintoma(probar_presion_sistema_enfriamiento, olor_refrigerante_cabina, 0.60).
prueba_sintoma(probar_presion_mangueras_calefaccion, fuga_refrigerante, 0.50).
prueba_sintoma(probar_presion_mangueras_calefaccion, olor_refrigerante_cabina, 0.50).
prueba_sintoma(escanear_codigos_falla_dtc, mal_consumo_combustible, 0.60).
prueba_sintoma(escanear_codigos_falla_dtc, motor_fallos_encendido, 0.60).
prueba_sintoma(probar_funcionamiento_valvula_iac, ralenti_inestable, 0.70).
prueba_sintoma(probar_funcionamiento_valvula_iac, se_apaga_ralenti, 0.70).
prueba_sintoma(medir_voltaje_sensor_map, luz_check_engine, 0.70).
prueba_sintoma(medir_voltaje_sensor_map, ralenti_inestable, 0.70).
prueba_sintoma(medir_salida_alternador, faros_tenues, 0.70).
prueba_sintoma(medir_salida_alternador, luz_bateria_encendida, 0.70).
prueba_sintoma(medir_voltaje_bateria, arranque_lento, 0.70).
prueba_sintoma(medir_voltaje_bateria, clic_al_arrancar, 0.70).
prueba_sintoma(medir_voltaje_bateria, luz_bateria_encendida, 0.70).
prueba_sintoma(medir_voltaje_bateria, voltaje_bajo, 0.70).
prueba_sintoma(probar_funcionamiento_motor_ventilador, ruido_hvac, 0.70).
prueba_sintoma(probar_funcionamiento_motor_ventilador, sin_aire_ventilas, 0.70).
prueba_sintoma(probar_continuidad_resistencia_ventilador, ventilador_hvac_erratico, 0.70).
prueba_sintoma(medir_presion_vacio_servofreno, pedal_freno_duro, 0.50).
prueba_sintoma(medir_presion_vacio_servofreno, pedal_freno_esponjoso, 0.50).
prueba_sintoma(probar_funcionamiento_valvula_purga, luz_check_engine, 0.70).
prueba_sintoma(probar_funcionamiento_valvula_purga, olor_combustible, 0.70).
prueba_sintoma(probar_funcionamiento_valvula_purga, ralenti_inestable, 0.70).
prueba_sintoma(medir_presion_bomba_inyeccion_diesel, humo_negro_escape, 0.70).
prueba_sintoma(medir_presion_bomba_inyeccion_diesel, motor_fallos_encendido, 0.70).
prueba_sintoma(probar_patron_rocio_inyector, mal_consumo_combustible, 0.70).
prueba_sintoma(probar_patron_rocio_inyector, motor_fallos_encendido, 0.70).
prueba_sintoma(probar_funcionamiento_regulador_presion, humo_negro_escape, 0.70).
prueba_sintoma(probar_funcionamiento_regulador_presion, motor_se_apaga, 0.70).
prueba_sintoma(medir_presion_bomba_combustible, motor_tose_alta_velocidad, 0.70).
prueba_sintoma(medir_presion_bomba_combustible, perdida_potencia, 0.70).
prueba_sintoma(probar_sensor_presion_tanque_combustible, luz_check_engine, 0.70).
prueba_sintoma(probar_sensor_presion_tanque_combustible, luz_tapon_gasolina, 0.70).
prueba_sintoma(medir_resistencia_bujia_incandescente, arranque_dificil_frio, 0.70).
prueba_sintoma(medir_resistencia_bujia_incandescente, luz_bujias_incandescentes, 0.70).
prueba_sintoma(probar_rele_claxon, claxon_no_suena, 0.50).
prueba_sintoma(probar_continuidad_cables_bujias, mal_consumo_combustible, 0.70).
prueba_sintoma(probar_continuidad_cables_bujias, motor_fallos_encendido, 0.70).
prueba_sintoma(probar_sensor_detonacion, mal_consumo_combustible, 0.70).
prueba_sintoma(probar_sensor_detonacion, motor_golpetea, 0.70).
prueba_sintoma(medir_presion_aceite_manometro, luz_presion_aceite, 0.70).
prueba_sintoma(medir_presion_aceite_manometro, motor_golpetea, 0.70).
prueba_sintoma(medir_voltaje_sensor_oxigeno, luz_check_engine, 0.70).
prueba_sintoma(medir_voltaje_sensor_oxigeno, mal_consumo_combustible, 0.70).
prueba_sintoma(verificar_alimentacion_electrica_actuador, cerradura_no_responde, 0.70).
prueba_sintoma(verificar_alimentacion_electrica_actuador, clic_puerta, 0.70).
prueba_sintoma(verificar_alimentacion_electrica_bomba, chorro_debil_limpiaparabrisas, 0.70).
prueba_sintoma(verificar_alimentacion_electrica_bomba, sin_chorro_limpiaparabrisas, 0.70).
prueba_sintoma(verificar_alimentacion_electrica_motor_vidrio, ventana_intermitente, 0.70).
prueba_sintoma(verificar_alimentacion_electrica_motor_vidrio, ventana_no_se_mueve, 0.70).
prueba_sintoma(verificar_alimentacion_electrica_motor, limpiaparabrisas_intermitente, 0.70).
prueba_sintoma(verificar_alimentacion_electrica_motor, limpiaparabrisas_no_funciona, 0.70).
prueba_sintoma(probar_funcionamiento_ventilador_radiador, ac_no_enfria_ralenti, 0.70).
prueba_sintoma(probar_funcionamiento_ventilador_radiador, motor_sobrecalienta, 0.70).
prueba_sintoma(probar_solenoide_motor_arranque, clic_al_arrancar, 0.70).
prueba_sintoma(probar_solenoide_motor_arranque, motor_no_gira, 0.70).
prueba_sintoma(probar_funcionamiento_termostato, motor_sobrecalienta, 0.50).
prueba_sintoma(probar_funcionamiento_termostato, temperatura_zona_roja, 0.50).
prueba_sintoma(probar_sensor_posicion_acelerador_tps, mala_aceleracion, 0.50).
prueba_sintoma(probar_sensor_posicion_acelerador_tps, motor_titubea, 0.70).
prueba_sintoma(probar_sensor_posicion_acelerador_tps, se_apaga_ralenti, 0.70).
prueba_sintoma(probar_continuidad_solenoides_transmision, cambios_erraticos, 0.70).
prueba_sintoma(probar_continuidad_solenoides_transmision, transmision_no_cambia, 0.70).
prueba_sintoma(probar_funcionamiento_acoplamiento_viscoso, ruido_tren_motriz_giros, 0.70).
prueba_sintoma(probar_funcionamiento_acoplamiento_viscoso, vehiculo_se_traba_giros, 0.70).
prueba_sintoma(probar_funcionamiento_bomba_agua, fuga_refrigerante_frente_motor, 0.50).
prueba_sintoma(probar_funcionamiento_bomba_agua, motor_sobrecalienta, 0.50).

% ---------- Hallazgos (resultado de cada prueba) ----------
% Cada prueba produce un hallazgo con 3 estados (normal | leve | severo), |Vi| = 3.
% Sus filas en componente_sintoma/5 cumplen NPos(normal)+NPos(leve)+NPos(severo) = N+ (y análogo con N-);
% P(estado | C) = (n + 1) / (N + 3).

sintoma(hall_ajustar_tension_cable_embrague, 'Resultado: Ajustar la tensión del cable del embrague', hallazgo).
sintoma(hall_revisar_fusible_abs, 'Resultado: Revisar el fusible del ABS', hallazgo).
sintoma(hall_revisar_funcionamiento_embrague_compresor_c, 'Resultado: Revisar el funcionamiento del embrague del compresor del A/C', hallazgo).
sintoma(hall_revisar_sensor_temperatura_evaporador_c, 'Resultado: Revisar el sensor de temperatura del evaporador del A/C', hallazgo).
sintoma(hall_revisar_funcionamiento_componentes_sistema_c, 'Resultado: Revisar el funcionamiento de los componentes del sistema de A/C', hallazgo).
sintoma(hall_medir_presion_sistema_c_manometro, 'Resultado: Medir la presión del sistema de A/C con manómetro', hallazgo).
sintoma(hall_revisar_codigos_falla_ecu, 'Resultado: Revisar los códigos de falla de la ECU', hallazgo).
sintoma(hall_revisar_manguera_valvula_pcv_tiene_grietas, 'Resultado: Revisar si la manguera de la válvula PCV tiene grietas', hallazgo).
sintoma(hall_revisar_tension_banda_alternador, 'Resultado: Revisar la tensión de la banda del alternador', hallazgo).
sintoma(hall_revisar_desgaste_baleros_eje, 'Resultado: Revisar el desgaste de los baleros del eje', hallazgo).
sintoma(hall_revisar_alineacion_eje_balanceo, 'Resultado: Revisar la alineación del eje de balanceo', hallazgo).
sintoma(hall_revisar_tension_alineacion_banda, 'Resultado: Revisar la tensión y alineación de la banda', hallazgo).
sintoma(hall_medir_presion_sobrealimentacion_manometro, 'Resultado: Medir la presión de sobrealimentación con manómetro', hallazgo).
sintoma(hall_revisar_manguera_vacio_servofreno, 'Resultado: Revisar la manguera de vacío del servofreno', hallazgo).
sintoma(hall_revisar_funcionamiento_piston_caliper, 'Resultado: Revisar el funcionamiento del pistón del caliper', hallazgo).
sintoma(hall_revisar_rayaduras_grietas_tambor_freno, 'Resultado: Revisar rayaduras o grietas en el tambor de freno', hallazgo).
sintoma(hall_revisar_nivel_estado_liquido_frenos, 'Resultado: Revisar el nivel y estado del líquido de frenos', hallazgo).
sintoma(hall_revisar_nivel_liquido_frenos_cilindro_maestro, 'Resultado: Revisar el nivel de líquido de frenos en el cilindro maestro', hallazgo).
sintoma(hall_medir_espesor_pastillas_freno, 'Resultado: Medir el espesor de las pastillas de freno', hallazgo).
sintoma(hall_revisar_eficiencia_convertidor_catalitico, 'Resultado: Revisar la eficiencia del convertidor catalítico', hallazgo).
sintoma(hall_revisar_nivel_liquido_embrague, 'Resultado: Revisar el nivel del líquido del embrague', hallazgo).
sintoma(hall_revisar_fugas_cilindro_esclavo_embrague, 'Resultado: Revisar fugas en el cilindro esclavo del embrague', hallazgo).
sintoma(hall_revisar_flujo_refrigerante_nucleo_calefaccion, 'Resultado: Revisar el flujo de refrigerante por el núcleo de calefacción', hallazgo).
sintoma(hall_revisar_nivel_estado_refrigerante, 'Resultado: Revisar el nivel y estado del refrigerante', hallazgo).
sintoma(hall_revisar_nivel_refrigerante_deposito, 'Resultado: Revisar el nivel de refrigerante en el depósito', hallazgo).
sintoma(hall_revisar_desgaste_rotor_distribuidor, 'Resultado: Revisar el desgaste del rotor del distribuidor', hallazgo).
sintoma(hall_revisar_alineacion_tren_motriz, 'Resultado: Revisar la alineación del tren motriz', hallazgo).
sintoma(hall_revisar_nivel_estado_aceite_motor, 'Resultado: Revisar el nivel y estado del aceite del motor', hallazgo).
sintoma(hall_revisar_apriete_pernos_multiple_escape, 'Resultado: Revisar el apriete de los pernos del múltiple de escape', hallazgo).
sintoma(hall_revisar_fugas_junta_multiple_escape, 'Resultado: Revisar fugas en la junta del múltiple de escape', hallazgo).
sintoma(hall_revisar_residuos_toma_aire_cabina, 'Resultado: Revisar si hay residuos en la toma de aire de la cabina', hallazgo).
sintoma(hall_revisar_desgaste_baleros_diferencial, 'Resultado: Revisar el desgaste de los baleros del diferencial', hallazgo).
sintoma(hall_revisar_diferencial_central_tiene_juego, 'Resultado: Revisar si el diferencial central tiene juego excesivo', hallazgo).
sintoma(hall_revisar_fugas_condensador_c, 'Resultado: Revisar fugas en el condensador del A/C', hallazgo).
sintoma(hall_revisar_fugas_mangueras_valvula_purga, 'Resultado: Revisar fugas en las mangueras de la válvula de purga', hallazgo).
sintoma(hall_revisar_sello_tapon_tanque_combustible, 'Resultado: Revisar el sello del tapón del tanque de combustible', hallazgo).
sintoma(hall_medir_presion_combustible_regulador, 'Resultado: Medir la presión de combustible en el regulador', hallazgo).
sintoma(hall_revisar_nivel_estado_aceite_engranes, 'Resultado: Revisar el nivel y estado del aceite de engranes', hallazgo).
sintoma(hall_revisar_corrosion_socket_faro, 'Resultado: Revisar corrosión en el socket del faro', hallazgo).
sintoma(hall_revisar_fusible_claxon, 'Resultado: Revisar el fusible del claxon', hallazgo).
sintoma(hall_revisar_fugas_conexiones_mangueras, 'Resultado: Revisar fugas en las conexiones de las mangueras', hallazgo).
sintoma(hall_revisar_apriete_pernos_montaje, 'Resultado: Revisar el apriete de los pernos de montaje', hallazgo).
sintoma(hall_revisar_nivel_liquido_direccion, 'Resultado: Revisar el nivel del líquido de la dirección', hallazgo).
sintoma(hall_revisar_fugas_bomba_mangueras_direccion, 'Resultado: Revisar fugas en la bomba y mangueras de la dirección', hallazgo).
sintoma(hall_revisar_sello_tapon_radiador, 'Resultado: Revisar el sello del tapón del radiador', hallazgo).
sintoma(hall_revisar_obstruccion_dano_radiador, 'Resultado: Revisar obstrucción o daño en el radiador', hallazgo).
sintoma(hall_revisar_sensores_relacionados_codigos_dtc, 'Resultado: Revisar los sensores relacionados con los códigos DTC', hallazgo).
sintoma(hall_revisar_alineacion_marcas_tiempo, 'Resultado: Revisar la alineación de las marcas de tiempo', hallazgo).
sintoma(hall_medir_presion_llantas_manometro_revisar_su, 'Resultado: Medir la presión de las llantas con manómetro y revisar su estado', hallazgo).
sintoma(hall_revisar_nivel_estado_fluido_transmision, 'Resultado: Revisar el nivel y estado del fluido de la transmisión', hallazgo).
sintoma(hall_revisar_holgura_valvulas, 'Resultado: Revisar la holgura de las válvulas', hallazgo).
sintoma(hall_revisar_apriete_pernos_tapa_valvulas, 'Resultado: Revisar el apriete de los pernos de la tapa de válvulas', hallazgo).
sintoma(hall_revisar_nivel_liquido_limpiaparabrisas, 'Resultado: Revisar el nivel de líquido limpiaparabrisas', hallazgo).
sintoma(hall_revisar_juego_desgaste_baleros_rueda, 'Resultado: Revisar el juego y desgaste de los baleros de rueda', hallazgo).
sintoma(hall_revisar_sensor_velocidad_rueda_tiene_suciedad, 'Resultado: Revisar si el sensor de velocidad de rueda tiene suciedad o daño', hallazgo).
sintoma(hall_revisar_alineacion_vidrio_guias, 'Resultado: Revisar la alineación del vidrio en las guías', hallazgo).
sintoma(hall_limpiar_cuerpo_aceleracion_valvula_iac, 'Resultado: Limpiar el cuerpo de aceleración y la válvula IAC', hallazgo).
sintoma(hall_inspeccionar_compresor_c_fugas_danos, 'Resultado: Inspeccionar el compresor del A/C en busca de fugas o daños', hallazgo).
sintoma(hall_inspeccionar_condensador_c_residuos_u, 'Resultado: Inspeccionar el condensador del A/C en busca de residuos u obstrucción', hallazgo).
sintoma(hall_inspeccionar_evaporador_c_moho, 'Resultado: Inspeccionar el evaporador del A/C en busca de moho', hallazgo).
sintoma(hall_inspeccionar_arnes_cables_ecu, 'Resultado: Inspeccionar el arnés de cables de la ECU', hallazgo).
sintoma(hall_inspeccionar_manguera_vacio_sensor_map, 'Resultado: Inspeccionar la manguera de vacío del sensor MAP', hallazgo).
sintoma(hall_inspeccionar_valvula_pcv_obstrucciones, 'Resultado: Inspeccionar la válvula PCV en busca de obstrucciones', hallazgo).
sintoma(hall_inspeccionar_sensores_tpms_dano_corrosion, 'Resultado: Inspeccionar los sensores TPMS en busca de daño o corrosión', hallazgo).
sintoma(hall_inspeccionar_cableado_tps, 'Resultado: Inspeccionar el cableado del TPS', hallazgo).
sintoma(hall_inspeccionar_mecanismo_actuador_obstrucciones, 'Resultado: Inspeccionar el mecanismo del actuador en busca de obstrucciones', hallazgo).
sintoma(hall_inspeccionar_filtro_aire_motor_reemplazar_esta, 'Resultado: Inspeccionar el filtro de aire del motor (reemplazar si está sucio)', hallazgo).
sintoma(hall_inspeccionar_funcionamiento_alternador, 'Resultado: Inspeccionar el funcionamiento del alternador', hallazgo).
sintoma(hall_inspeccionar_filtro_cabina_reemplazar_esta, 'Resultado: Inspeccionar el filtro de la cabina (reemplazar si está sucio)', hallazgo).
sintoma(hall_inspeccionar_desgaste_eje_balanceo, 'Resultado: Inspeccionar el desgaste del eje de balanceo', hallazgo).
sintoma(hall_inspeccionar_corrosion_terminales_bateria, 'Resultado: Inspeccionar la corrosión en los terminales de la batería', hallazgo).
sintoma(hall_inspeccionar_balero_dano_corrosion, 'Resultado: Inspeccionar el balero en busca de daño o corrosión', hallazgo).
sintoma(hall_inspeccionar_desgaste_engranes_conicos, 'Resultado: Inspeccionar el desgaste de los engranes cónicos', hallazgo).
sintoma(hall_inspeccionar_motor_ventilador_residuos_dano, 'Resultado: Inspeccionar el motor del ventilador en busca de residuos o daño', hallazgo).
sintoma(hall_inspeccionar_fugas_caliper, 'Resultado: Inspeccionar fugas en el caliper', hallazgo).
sintoma(hall_inspeccionar_manguera_freno_grietas_fugas, 'Resultado: Inspeccionar la manguera de freno en busca de grietas o fugas', hallazgo).
sintoma(hall_inspeccionar_fugas_lineas_freno, 'Resultado: Inspeccionar fugas en las líneas de freno', hallazgo).
sintoma(hall_inspeccionar_estado_pastillas_freno, 'Resultado: Inspeccionar el estado de las pastillas de freno', hallazgo).
sintoma(hall_inspeccionar_disco_rayaduras_alabeo, 'Resultado: Inspeccionar el disco en busca de rayaduras o alabeo', hallazgo).
sintoma(hall_inspeccionar_desgaste_zapatas_freno, 'Resultado: Inspeccionar el desgaste de las zapatas de freno', hallazgo).
sintoma(hall_inspeccionar_canister_grietas_dano, 'Resultado: Inspeccionar el canister en busca de grietas o daño', hallazgo).
sintoma(hall_inspeccionar_convertidor_catalitico_dano, 'Resultado: Inspeccionar el convertidor catalítico en busca de daño físico', hallazgo).
sintoma(hall_inspeccionar_fluido_diferencial_central, 'Resultado: Inspeccionar el fluido del diferencial central', hallazgo).
sintoma(hall_inspeccionar_cable_embrague_desgaste, 'Resultado: Inspeccionar el cable del embrague en busca de desgaste o estiramiento', hallazgo).
sintoma(hall_inspeccionar_nivel_estado_liquido_embrague, 'Resultado: Inspeccionar el nivel y estado del líquido del embrague', hallazgo).
sintoma(hall_inspeccionar_inyectores_diesel_fugas_u, 'Resultado: Inspeccionar los inyectores diésel en busca de fugas u obstrucción', hallazgo).
sintoma(hall_inspeccionar_nivel_estado_fluido_diferencial, 'Resultado: Inspeccionar el nivel y estado del fluido del diferencial', hallazgo).
sintoma(hall_inspeccionar_tapa_distribuidor_grietas, 'Resultado: Inspeccionar la tapa del distribuidor en busca de grietas o carbonilla', hallazgo).
sintoma(hall_inspeccionar_banda_cortes_desgaste, 'Resultado: Inspeccionar la banda en busca de cortes o desgaste', hallazgo).
sintoma(hall_inspeccionar_soportes_motor, 'Resultado: Inspeccionar los soportes del motor', hallazgo).
sintoma(hall_inspeccionar_multiple_escape_grietas_fugas, 'Resultado: Inspeccionar el múltiple de escape en busca de grietas o fugas', hallazgo).
sintoma(hall_inspeccionar_valvula_escape_carbonilla, 'Resultado: Inspeccionar la válvula de escape en busca de carbonilla', hallazgo).
sintoma(hall_revisar_codigos_fallo_encendido, 'Resultado: Revisar códigos de fallo de encendido', hallazgo).
sintoma(hall_inspeccionar_fugas_sistema_c, 'Resultado: Inspeccionar fugas en el sistema de A/C', hallazgo).
sintoma(hall_inspeccionar_fugas_aceite, 'Resultado: Inspeccionar fugas de aceite', hallazgo).
sintoma(hall_inspeccionar_filtro_combustible_reemplazar, 'Resultado: Inspeccionar el filtro de combustible (reemplazar si está obstruido)', hallazgo).
sintoma(hall_inspeccionar_bomba_combustible_fugas_dano, 'Resultado: Inspeccionar la bomba de combustible en busca de fugas o daño', hallazgo).
sintoma(hall_inspeccionar_tanque_combustible_fugas_dano, 'Resultado: Inspeccionar el tanque de combustible en busca de fugas o daño', hallazgo).
sintoma(hall_inspeccionar_bujia_incandescente_carbonilla, 'Resultado: Inspeccionar la bujía incandescente en busca de carbonilla', hallazgo).
sintoma(hall_inspeccionar_filamento_foco_faro, 'Resultado: Inspeccionar el filamento del foco del faro', hallazgo).
sintoma(hall_inspeccionar_fugas_nucleo_calefaccion, 'Resultado: Inspeccionar fugas en el núcleo de calefacción', hallazgo).
sintoma(hall_inspeccionar_conexiones_mangueras_calefaccion, 'Resultado: Inspeccionar las conexiones de las mangueras de calefacción', hallazgo).
sintoma(hall_inspeccionar_inyector_fugas_u_obstruccion, 'Resultado: Inspeccionar el inyector en busca de fugas u obstrucción', hallazgo).
sintoma(hall_inspeccionar_valvula_admision_carbonilla, 'Resultado: Inspeccionar la válvula de admisión en busca de carbonilla', hallazgo).
sintoma(hall_inspeccionar_intercooler_fugas_dano, 'Resultado: Inspeccionar el intercooler en busca de fugas o daño', hallazgo).
sintoma(hall_inspeccionar_eje_motriz_grietas_deformacion, 'Resultado: Inspeccionar el eje motriz en busca de grietas o deformación', hallazgo).
sintoma(hall_inspeccionar_fugas_cilindro_maestro, 'Resultado: Inspeccionar fugas en el cilindro maestro', hallazgo).
sintoma(hall_inspeccionar_bomba_aceite_desgaste_dano, 'Resultado: Inspeccionar la bomba de aceite en busca de desgaste o daño', hallazgo).
sintoma(hall_inspeccionar_cableado_sensor_oxigeno, 'Resultado: Inspeccionar el cableado del sensor de oxígeno', hallazgo).
sintoma(hall_inspeccionar_anillos_piston, 'Resultado: Inspeccionar los anillos de pistón', hallazgo).
sintoma(hall_inspeccionar_fugas_mangueras_direccion, 'Resultado: Inspeccionar fugas en las mangueras de la dirección', hallazgo).
sintoma(hall_inspeccionar_fugas_radiador_mangueras, 'Resultado: Inspeccionar fugas en el radiador y las mangueras', hallazgo).
sintoma(hall_inspeccionar_motor_rele_ventilador_radiador, 'Resultado: Inspeccionar el motor y relé del ventilador del radiador', hallazgo).
sintoma(hall_inspeccionar_radiador_fugas_dano, 'Resultado: Inspeccionar el radiador en busca de fugas o daño', hallazgo).
sintoma(hall_inspeccionar_danos_mangueras_radiador, 'Resultado: Inspeccionar daños en las mangueras del radiador', hallazgo).
sintoma(hall_inspeccionar_fugas_radiador_mangueras_bomba, 'Resultado: Inspeccionar fugas en radiador, mangueras y bomba de agua', hallazgo).
sintoma(hall_inspeccionar_deposito_grietas_fugas, 'Resultado: Inspeccionar el depósito en busca de grietas o fugas', hallazgo).
sintoma(hall_inspeccionar_resistencia_sobrecalentamiento, 'Resultado: Inspeccionar la resistencia en busca de sobrecalentamiento', hallazgo).
sintoma(hall_inspeccionar_eje_rigido_grietas_dano, 'Resultado: Inspeccionar el eje rígido en busca de grietas o daño', hallazgo).
sintoma(hall_inspeccionar_balanceo_alineacion_eje, 'Resultado: Inspeccionar el balanceo y alineación del eje', hallazgo).
sintoma(hall_inspeccionar_botas_bujias, 'Resultado: Inspeccionar las botas de las bujías', hallazgo).
sintoma(hall_inspeccionar_desgaste_escobillas_motor, 'Resultado: Inspeccionar el desgaste de las escobillas del motor de arranque', hallazgo).
sintoma(hall_inspeccionar_carbonilla_cuerpo_aceleracion, 'Resultado: Inspeccionar carbonilla en el cuerpo de aceleración', hallazgo).
sintoma(hall_inspeccionar_banda_distribucion, 'Resultado: Inspeccionar la banda de distribución', hallazgo).
sintoma(hall_inspeccionar_fugas_dano_convertidor_par, 'Resultado: Inspeccionar fugas o daño del convertidor de par', hallazgo).
sintoma(hall_inspeccionar_filtro_transmision_reemplazar, 'Resultado: Inspeccionar el filtro de la transmisión (reemplazar si está obstruido)', hallazgo).
sintoma(hall_inspeccionar_fugas_transmision, 'Resultado: Inspeccionar fugas en la transmisión', hallazgo).
sintoma(hall_inspeccionar_fugas_carter_sellos_transmision, 'Resultado: Inspeccionar fugas en el cárter y sellos de la transmisión', hallazgo).
sintoma(hall_inspeccionar_desgaste_juego_junta_universal, 'Resultado: Inspeccionar desgaste o juego de la junta universal', hallazgo).
sintoma(hall_inspeccionar_fugas_junta_tapa_valvulas, 'Resultado: Inspeccionar fugas en la junta de la tapa de válvulas', hallazgo).
sintoma(hall_inspeccionar_fluido_acoplamiento_viscoso, 'Resultado: Inspeccionar el fluido del acoplamiento viscoso', hallazgo).
sintoma(hall_probar_funcionamiento_bomba_liquido, 'Resultado: Probar el funcionamiento de la bomba de líquido limpiaparabrisas', hallazgo).
sintoma(hall_inspeccionar_obstruccion_dano_bomba, 'Resultado: Inspeccionar obstrucción o daño en la bomba del limpiaparabrisas', hallazgo).
sintoma(hall_inspeccionar_fugas_bomba_agua, 'Resultado: Inspeccionar fugas en la bomba de agua', hallazgo).
sintoma(hall_inspeccionar_juego_ruido_balero_maza, 'Resultado: Inspeccionar juego o ruido de balero en la maza', hallazgo).
sintoma(hall_inspeccionar_conexiones_sensor_velocidad_rueda, 'Resultado: Inspeccionar las conexiones del sensor de velocidad de rueda', hallazgo).
sintoma(hall_inspeccionar_regulador_vidrio_electrico, 'Resultado: Inspeccionar el regulador del vidrio eléctrico', hallazgo).
sintoma(hall_inspeccionar_desgaste_articulacion, 'Resultado: Inspeccionar el desgaste de la articulación del limpiaparabrisas', hallazgo).
sintoma(hall_inspeccionar_arnes_cables_dano_corrosion, 'Resultado: Inspeccionar el arnés de cables en busca de daño o corrosión', hallazgo).
sintoma(hall_inspeccionar_cableado_modulo_abs, 'Resultado: Inspeccionar el cableado del módulo ABS', hallazgo).
sintoma(hall_medir_espesor_disco_freno, 'Resultado: Medir el espesor del disco de freno', hallazgo).
sintoma(hall_ejecutar_escaneo_diagnostico_sistema_c, 'Resultado: Ejecutar un escaneo diagnóstico del sistema de A/C', hallazgo).
sintoma(hall_realizar_prueba_compresion, 'Resultado: Realizar una prueba de compresión', hallazgo).
sintoma(hall_probar_presion_manguera_freno, 'Resultado: Probar a presión la manguera de freno', hallazgo).
sintoma(hall_probar_presion_sistema_enfriamiento, 'Resultado: Probar a presión el sistema de enfriamiento', hallazgo).
sintoma(hall_probar_presion_mangueras_calefaccion, 'Resultado: Probar a presión las mangueras de calefacción', hallazgo).
sintoma(hall_escanear_codigos_falla_dtc, 'Resultado: Escanear códigos de falla (DTC)', hallazgo).
sintoma(hall_probar_funcionamiento_valvula_iac, 'Resultado: Probar el funcionamiento de la válvula IAC', hallazgo).
sintoma(hall_medir_voltaje_sensor_map, 'Resultado: Medir el voltaje del sensor MAP', hallazgo).
sintoma(hall_medir_salida_alternador, 'Resultado: Medir la salida del alternador', hallazgo).
sintoma(hall_medir_voltaje_bateria, 'Resultado: Medir el voltaje de la batería', hallazgo).
sintoma(hall_probar_funcionamiento_motor_ventilador, 'Resultado: Probar el funcionamiento del motor del ventilador', hallazgo).
sintoma(hall_probar_continuidad_resistencia_ventilador, 'Resultado: Probar la continuidad de la resistencia del ventilador', hallazgo).
sintoma(hall_medir_presion_vacio_servofreno, 'Resultado: Medir la presión de vacío del servofreno', hallazgo).
sintoma(hall_probar_funcionamiento_valvula_purga, 'Resultado: Probar el funcionamiento de la válvula de purga', hallazgo).
sintoma(hall_medir_presion_bomba_inyeccion_diesel, 'Resultado: Medir la presión de la bomba de inyección diésel', hallazgo).
sintoma(hall_probar_patron_rocio_inyector, 'Resultado: Probar el patrón de rocío del inyector', hallazgo).
sintoma(hall_probar_funcionamiento_regulador_presion, 'Resultado: Probar el funcionamiento del regulador de presión de combustible', hallazgo).
sintoma(hall_medir_presion_bomba_combustible, 'Resultado: Medir la presión de la bomba de combustible', hallazgo).
sintoma(hall_probar_sensor_presion_tanque_combustible, 'Resultado: Probar el sensor de presión del tanque de combustible', hallazgo).
sintoma(hall_medir_resistencia_bujia_incandescente, 'Resultado: Medir la resistencia de la bujía incandescente', hallazgo).
sintoma(hall_probar_rele_claxon, 'Resultado: Probar el relé del claxon', hallazgo).
sintoma(hall_probar_continuidad_cables_bujias, 'Resultado: Probar la continuidad de los cables de bujías', hallazgo).
sintoma(hall_probar_sensor_detonacion, 'Resultado: Probar el sensor de detonación', hallazgo).
sintoma(hall_medir_presion_aceite_manometro, 'Resultado: Medir la presión de aceite con manómetro', hallazgo).
sintoma(hall_medir_voltaje_sensor_oxigeno, 'Resultado: Medir el voltaje del sensor de oxígeno', hallazgo).
sintoma(hall_verificar_alimentacion_electrica_actuador, 'Resultado: Verificar la alimentación eléctrica del actuador del seguro', hallazgo).
sintoma(hall_verificar_alimentacion_electrica_bomba, 'Resultado: Verificar la alimentación eléctrica de la bomba del limpiaparabrisas', hallazgo).
sintoma(hall_verificar_alimentacion_electrica_motor_vidrio, 'Resultado: Verificar la alimentación eléctrica del motor del vidrio', hallazgo).
sintoma(hall_verificar_alimentacion_electrica_motor, 'Resultado: Verificar la alimentación eléctrica del motor del limpiaparabrisas', hallazgo).
sintoma(hall_probar_funcionamiento_ventilador_radiador, 'Resultado: Probar el funcionamiento del ventilador del radiador', hallazgo).
sintoma(hall_probar_solenoide_motor_arranque, 'Resultado: Probar el solenoide del motor de arranque', hallazgo).
sintoma(hall_probar_funcionamiento_termostato, 'Resultado: Probar el funcionamiento del termostato', hallazgo).
sintoma(hall_probar_sensor_posicion_acelerador_tps, 'Resultado: Probar el sensor de posición del acelerador (TPS)', hallazgo).
sintoma(hall_probar_continuidad_solenoides_transmision, 'Resultado: Probar la continuidad de los solenoides de la transmisión', hallazgo).
sintoma(hall_probar_funcionamiento_acoplamiento_viscoso, 'Resultado: Probar el funcionamiento del acoplamiento viscoso', hallazgo).
sintoma(hall_probar_funcionamiento_bomba_agua, 'Resultado: Probar el funcionamiento de la bomba de agua', hallazgo).

componente_sintoma(cable_embrague, hall_ajustar_tension_cable_embrague, normal, 1, 818).
componente_sintoma(cable_embrague, hall_ajustar_tension_cable_embrague, leve, 3, 95).
componente_sintoma(cable_embrague, hall_ajustar_tension_cable_embrague, severo, 36, 47).
componente_sintoma(modulo_abs, hall_revisar_fusible_abs, normal, 1, 818).
componente_sintoma(modulo_abs, hall_revisar_fusible_abs, leve, 3, 95).
componente_sintoma(modulo_abs, hall_revisar_fusible_abs, severo, 36, 47).
componente_sintoma(compresor_ac, hall_revisar_funcionamiento_embrague_compresor_c, normal, 1, 818).
componente_sintoma(compresor_ac, hall_revisar_funcionamiento_embrague_compresor_c, leve, 3, 95).
componente_sintoma(compresor_ac, hall_revisar_funcionamiento_embrague_compresor_c, severo, 36, 47).
componente_sintoma(evaporador_ac, hall_revisar_sensor_temperatura_evaporador_c, normal, 1, 818).
componente_sintoma(evaporador_ac, hall_revisar_sensor_temperatura_evaporador_c, leve, 3, 95).
componente_sintoma(evaporador_ac, hall_revisar_sensor_temperatura_evaporador_c, severo, 36, 47).
componente_sintoma(compresor_ac, hall_revisar_funcionamiento_componentes_sistema_c, normal, 3, 722).
componente_sintoma(compresor_ac, hall_revisar_funcionamiento_componentes_sistema_c, leve, 8, 143).
componente_sintoma(compresor_ac, hall_revisar_funcionamiento_componentes_sistema_c, severo, 29, 95).
componente_sintoma(condensador_ac, hall_revisar_funcionamiento_componentes_sistema_c, normal, 3, 722).
componente_sintoma(condensador_ac, hall_revisar_funcionamiento_componentes_sistema_c, leve, 8, 143).
componente_sintoma(condensador_ac, hall_revisar_funcionamiento_componentes_sistema_c, severo, 29, 95).
componente_sintoma(evaporador_ac, hall_revisar_funcionamiento_componentes_sistema_c, normal, 3, 722).
componente_sintoma(evaporador_ac, hall_revisar_funcionamiento_componentes_sistema_c, leve, 8, 143).
componente_sintoma(evaporador_ac, hall_revisar_funcionamiento_componentes_sistema_c, severo, 29, 95).
componente_sintoma(carga_refrigerante_ac, hall_medir_presion_sistema_c_manometro, normal, 1, 818).
componente_sintoma(carga_refrigerante_ac, hall_medir_presion_sistema_c_manometro, leve, 3, 95).
componente_sintoma(carga_refrigerante_ac, hall_medir_presion_sistema_c_manometro, severo, 36, 47).
componente_sintoma(ecu, hall_revisar_codigos_falla_ecu, normal, 1, 818).
componente_sintoma(ecu, hall_revisar_codigos_falla_ecu, leve, 3, 95).
componente_sintoma(ecu, hall_revisar_codigos_falla_ecu, severo, 36, 47).
componente_sintoma(valvula_pcv, hall_revisar_manguera_valvula_pcv_tiene_grietas, normal, 1, 818).
componente_sintoma(valvula_pcv, hall_revisar_manguera_valvula_pcv_tiene_grietas, leve, 3, 95).
componente_sintoma(valvula_pcv, hall_revisar_manguera_valvula_pcv_tiene_grietas, severo, 36, 47).
componente_sintoma(sistema_carga, hall_revisar_tension_banda_alternador, normal, 1, 818).
componente_sintoma(sistema_carga, hall_revisar_tension_banda_alternador, leve, 3, 95).
componente_sintoma(sistema_carga, hall_revisar_tension_banda_alternador, severo, 36, 47).
componente_sintoma(eje_motriz, hall_revisar_desgaste_baleros_eje, normal, 3, 722).
componente_sintoma(eje_motriz, hall_revisar_desgaste_baleros_eje, leve, 8, 143).
componente_sintoma(eje_motriz, hall_revisar_desgaste_baleros_eje, severo, 29, 95).
componente_sintoma(eje_rigido, hall_revisar_desgaste_baleros_eje, normal, 3, 722).
componente_sintoma(eje_rigido, hall_revisar_desgaste_baleros_eje, leve, 8, 143).
componente_sintoma(eje_rigido, hall_revisar_desgaste_baleros_eje, severo, 29, 95).
componente_sintoma(eje_balanceo, hall_revisar_alineacion_eje_balanceo, normal, 1, 818).
componente_sintoma(eje_balanceo, hall_revisar_alineacion_eje_balanceo, leve, 3, 95).
componente_sintoma(eje_balanceo, hall_revisar_alineacion_eje_balanceo, severo, 36, 47).
componente_sintoma(banda_accesorios, hall_revisar_tension_alineacion_banda, normal, 1, 818).
componente_sintoma(banda_accesorios, hall_revisar_tension_alineacion_banda, leve, 3, 95).
componente_sintoma(banda_accesorios, hall_revisar_tension_alineacion_banda, severo, 36, 47).
componente_sintoma(presion_turbo, hall_medir_presion_sobrealimentacion_manometro, normal, 1, 818).
componente_sintoma(presion_turbo, hall_medir_presion_sobrealimentacion_manometro, leve, 3, 95).
componente_sintoma(presion_turbo, hall_medir_presion_sobrealimentacion_manometro, severo, 36, 47).
componente_sintoma(servofreno, hall_revisar_manguera_vacio_servofreno, normal, 1, 818).
componente_sintoma(servofreno, hall_revisar_manguera_vacio_servofreno, leve, 3, 95).
componente_sintoma(servofreno, hall_revisar_manguera_vacio_servofreno, severo, 36, 47).
componente_sintoma(caliper_freno, hall_revisar_funcionamiento_piston_caliper, normal, 1, 818).
componente_sintoma(caliper_freno, hall_revisar_funcionamiento_piston_caliper, leve, 3, 95).
componente_sintoma(caliper_freno, hall_revisar_funcionamiento_piston_caliper, severo, 36, 47).
componente_sintoma(zapatas_tambor, hall_revisar_rayaduras_grietas_tambor_freno, normal, 1, 818).
componente_sintoma(zapatas_tambor, hall_revisar_rayaduras_grietas_tambor_freno, leve, 3, 95).
componente_sintoma(zapatas_tambor, hall_revisar_rayaduras_grietas_tambor_freno, severo, 36, 47).
componente_sintoma(liquido_frenos, hall_revisar_nivel_estado_liquido_frenos, normal, 4, 768).
componente_sintoma(liquido_frenos, hall_revisar_nivel_estado_liquido_frenos, leve, 9, 89).
componente_sintoma(liquido_frenos, hall_revisar_nivel_estado_liquido_frenos, severo, 86, 44).
componente_sintoma(cilindro_maestro_freno, hall_revisar_nivel_liquido_frenos_cilindro_maestro, normal, 1, 818).
componente_sintoma(cilindro_maestro_freno, hall_revisar_nivel_liquido_frenos_cilindro_maestro, leve, 3, 95).
componente_sintoma(cilindro_maestro_freno, hall_revisar_nivel_liquido_frenos_cilindro_maestro, severo, 36, 47).
componente_sintoma(pastillas_freno, hall_medir_espesor_pastillas_freno, normal, 7, 513).
componente_sintoma(pastillas_freno, hall_medir_espesor_pastillas_freno, leve, 51, 59).
componente_sintoma(pastillas_freno, hall_medir_espesor_pastillas_freno, severo, 341, 29).
componente_sintoma(catalizador, hall_revisar_eficiencia_convertidor_catalitico, normal, 1, 818).
componente_sintoma(catalizador, hall_revisar_eficiencia_convertidor_catalitico, leve, 3, 95).
componente_sintoma(catalizador, hall_revisar_eficiencia_convertidor_catalitico, severo, 36, 47).
componente_sintoma(cilindro_maestro_embrague, hall_revisar_nivel_liquido_embrague, normal, 1, 818).
componente_sintoma(cilindro_maestro_embrague, hall_revisar_nivel_liquido_embrague, leve, 3, 95).
componente_sintoma(cilindro_maestro_embrague, hall_revisar_nivel_liquido_embrague, severo, 36, 47).
componente_sintoma(cilindro_esclavo_embrague, hall_revisar_fugas_cilindro_esclavo_embrague, normal, 1, 818).
componente_sintoma(cilindro_esclavo_embrague, hall_revisar_fugas_cilindro_esclavo_embrague, leve, 3, 95).
componente_sintoma(cilindro_esclavo_embrague, hall_revisar_fugas_cilindro_esclavo_embrague, severo, 36, 47).
componente_sintoma(nucleo_calefaccion, hall_revisar_flujo_refrigerante_nucleo_calefaccion, normal, 1, 818).
componente_sintoma(nucleo_calefaccion, hall_revisar_flujo_refrigerante_nucleo_calefaccion, leve, 3, 95).
componente_sintoma(nucleo_calefaccion, hall_revisar_flujo_refrigerante_nucleo_calefaccion, severo, 36, 47).
componente_sintoma(refrigerante, hall_revisar_nivel_estado_refrigerante, normal, 1, 818).
componente_sintoma(refrigerante, hall_revisar_nivel_estado_refrigerante, leve, 3, 95).
componente_sintoma(refrigerante, hall_revisar_nivel_estado_refrigerante, severo, 36, 47).
componente_sintoma(deposito_refrigerante, hall_revisar_nivel_refrigerante_deposito, normal, 1, 818).
componente_sintoma(deposito_refrigerante, hall_revisar_nivel_refrigerante_deposito, leve, 3, 95).
componente_sintoma(deposito_refrigerante, hall_revisar_nivel_refrigerante_deposito, severo, 36, 47).
componente_sintoma(tapa_distribuidor, hall_revisar_desgaste_rotor_distribuidor, normal, 1, 818).
componente_sintoma(tapa_distribuidor, hall_revisar_desgaste_rotor_distribuidor, leve, 3, 95).
componente_sintoma(tapa_distribuidor, hall_revisar_desgaste_rotor_distribuidor, severo, 36, 47).
componente_sintoma(junta_universal, hall_revisar_alineacion_tren_motriz, normal, 1, 818).
componente_sintoma(junta_universal, hall_revisar_alineacion_tren_motriz, leve, 3, 95).
componente_sintoma(junta_universal, hall_revisar_alineacion_tren_motriz, severo, 36, 47).
componente_sintoma(aceite_motor, hall_revisar_nivel_estado_aceite_motor, normal, 1, 818).
componente_sintoma(aceite_motor, hall_revisar_nivel_estado_aceite_motor, leve, 3, 95).
componente_sintoma(aceite_motor, hall_revisar_nivel_estado_aceite_motor, severo, 36, 47).
componente_sintoma(junta_multiple_escape, hall_revisar_apriete_pernos_multiple_escape, normal, 1, 818).
componente_sintoma(junta_multiple_escape, hall_revisar_apriete_pernos_multiple_escape, leve, 3, 95).
componente_sintoma(junta_multiple_escape, hall_revisar_apriete_pernos_multiple_escape, severo, 36, 47).
componente_sintoma(junta_multiple_escape, hall_revisar_fugas_junta_multiple_escape, normal, 3, 722).
componente_sintoma(junta_multiple_escape, hall_revisar_fugas_junta_multiple_escape, leve, 8, 143).
componente_sintoma(junta_multiple_escape, hall_revisar_fugas_junta_multiple_escape, severo, 29, 95).
componente_sintoma(multiple_escape, hall_revisar_fugas_junta_multiple_escape, normal, 3, 722).
componente_sintoma(multiple_escape, hall_revisar_fugas_junta_multiple_escape, leve, 8, 143).
componente_sintoma(multiple_escape, hall_revisar_fugas_junta_multiple_escape, severo, 29, 95).
componente_sintoma(filtro_cabina, hall_revisar_residuos_toma_aire_cabina, normal, 1, 818).
componente_sintoma(filtro_cabina, hall_revisar_residuos_toma_aire_cabina, leve, 3, 95).
componente_sintoma(filtro_cabina, hall_revisar_residuos_toma_aire_cabina, severo, 36, 47).
componente_sintoma(diferencial, hall_revisar_desgaste_baleros_diferencial, normal, 1, 818).
componente_sintoma(diferencial, hall_revisar_desgaste_baleros_diferencial, leve, 3, 95).
componente_sintoma(diferencial, hall_revisar_desgaste_baleros_diferencial, severo, 36, 47).
componente_sintoma(diferencial_central, hall_revisar_diferencial_central_tiene_juego, normal, 1, 818).
componente_sintoma(diferencial_central, hall_revisar_diferencial_central_tiene_juego, leve, 3, 95).
componente_sintoma(diferencial_central, hall_revisar_diferencial_central_tiene_juego, severo, 36, 47).
componente_sintoma(condensador_ac, hall_revisar_fugas_condensador_c, normal, 1, 818).
componente_sintoma(condensador_ac, hall_revisar_fugas_condensador_c, leve, 3, 95).
componente_sintoma(condensador_ac, hall_revisar_fugas_condensador_c, severo, 36, 47).
componente_sintoma(valvula_purga_canister, hall_revisar_fugas_mangueras_valvula_purga, normal, 1, 818).
componente_sintoma(valvula_purga_canister, hall_revisar_fugas_mangueras_valvula_purga, leve, 3, 95).
componente_sintoma(valvula_purga_canister, hall_revisar_fugas_mangueras_valvula_purga, severo, 36, 47).
componente_sintoma(sensor_presion_tanque, hall_revisar_sello_tapon_tanque_combustible, normal, 3, 722).
componente_sintoma(sensor_presion_tanque, hall_revisar_sello_tapon_tanque_combustible, leve, 8, 143).
componente_sintoma(sensor_presion_tanque, hall_revisar_sello_tapon_tanque_combustible, severo, 29, 95).
componente_sintoma(tanque_combustible, hall_revisar_sello_tapon_tanque_combustible, normal, 3, 722).
componente_sintoma(tanque_combustible, hall_revisar_sello_tapon_tanque_combustible, leve, 8, 143).
componente_sintoma(tanque_combustible, hall_revisar_sello_tapon_tanque_combustible, severo, 29, 95).
componente_sintoma(regulador_presion_combustible, hall_medir_presion_combustible_regulador, normal, 1, 818).
componente_sintoma(regulador_presion_combustible, hall_medir_presion_combustible_regulador, leve, 3, 95).
componente_sintoma(regulador_presion_combustible, hall_medir_presion_combustible_regulador, severo, 36, 47).
componente_sintoma(engranes_conicos, hall_revisar_nivel_estado_aceite_engranes, normal, 1, 818).
componente_sintoma(engranes_conicos, hall_revisar_nivel_estado_aceite_engranes, leve, 3, 95).
componente_sintoma(engranes_conicos, hall_revisar_nivel_estado_aceite_engranes, severo, 36, 47).
componente_sintoma(foco_faro, hall_revisar_corrosion_socket_faro, normal, 1, 818).
componente_sintoma(foco_faro, hall_revisar_corrosion_socket_faro, leve, 3, 95).
componente_sintoma(foco_faro, hall_revisar_corrosion_socket_faro, severo, 36, 47).
componente_sintoma(claxon, hall_revisar_fusible_claxon, normal, 1, 818).
componente_sintoma(claxon, hall_revisar_fusible_claxon, leve, 3, 95).
componente_sintoma(claxon, hall_revisar_fusible_claxon, severo, 36, 47).
componente_sintoma(manguera_radiador, hall_revisar_fugas_conexiones_mangueras, normal, 1, 818).
componente_sintoma(manguera_radiador, hall_revisar_fugas_conexiones_mangueras, leve, 3, 95).
componente_sintoma(manguera_radiador, hall_revisar_fugas_conexiones_mangueras, severo, 36, 47).
componente_sintoma(soportes_motor, hall_revisar_apriete_pernos_montaje, normal, 1, 818).
componente_sintoma(soportes_motor, hall_revisar_apriete_pernos_montaje, leve, 3, 95).
componente_sintoma(soportes_motor, hall_revisar_apriete_pernos_montaje, severo, 36, 47).
componente_sintoma(liquido_direccion, hall_revisar_nivel_liquido_direccion, normal, 1, 818).
componente_sintoma(liquido_direccion, hall_revisar_nivel_liquido_direccion, leve, 3, 95).
componente_sintoma(liquido_direccion, hall_revisar_nivel_liquido_direccion, severo, 36, 47).
componente_sintoma(liquido_direccion, hall_revisar_fugas_bomba_mangueras_direccion, normal, 1, 818).
componente_sintoma(liquido_direccion, hall_revisar_fugas_bomba_mangueras_direccion, leve, 3, 95).
componente_sintoma(liquido_direccion, hall_revisar_fugas_bomba_mangueras_direccion, severo, 36, 47).
componente_sintoma(radiador, hall_revisar_sello_tapon_radiador, normal, 1, 818).
componente_sintoma(radiador, hall_revisar_sello_tapon_radiador, leve, 3, 95).
componente_sintoma(radiador, hall_revisar_sello_tapon_radiador, severo, 36, 47).
componente_sintoma(termostato, hall_revisar_obstruccion_dano_radiador, normal, 1, 818).
componente_sintoma(termostato, hall_revisar_obstruccion_dano_radiador, leve, 3, 95).
componente_sintoma(termostato, hall_revisar_obstruccion_dano_radiador, severo, 36, 47).
componente_sintoma(sensor_detonacion, hall_revisar_sensores_relacionados_codigos_dtc, normal, 3, 722).
componente_sintoma(sensor_detonacion, hall_revisar_sensores_relacionados_codigos_dtc, leve, 8, 143).
componente_sintoma(sensor_detonacion, hall_revisar_sensores_relacionados_codigos_dtc, severo, 29, 95).
componente_sintoma(sensor_map, hall_revisar_sensores_relacionados_codigos_dtc, normal, 3, 722).
componente_sintoma(sensor_map, hall_revisar_sensores_relacionados_codigos_dtc, leve, 8, 143).
componente_sintoma(sensor_map, hall_revisar_sensores_relacionados_codigos_dtc, severo, 29, 95).
componente_sintoma(sensor_oxigeno, hall_revisar_sensores_relacionados_codigos_dtc, normal, 3, 722).
componente_sintoma(sensor_oxigeno, hall_revisar_sensores_relacionados_codigos_dtc, leve, 8, 143).
componente_sintoma(sensor_oxigeno, hall_revisar_sensores_relacionados_codigos_dtc, severo, 29, 95).
componente_sintoma(sensor_tps, hall_revisar_sensores_relacionados_codigos_dtc, normal, 3, 722).
componente_sintoma(sensor_tps, hall_revisar_sensores_relacionados_codigos_dtc, leve, 8, 143).
componente_sintoma(sensor_tps, hall_revisar_sensores_relacionados_codigos_dtc, severo, 29, 95).
componente_sintoma(banda_distribucion, hall_revisar_alineacion_marcas_tiempo, normal, 1, 818).
componente_sintoma(banda_distribucion, hall_revisar_alineacion_marcas_tiempo, leve, 3, 95).
componente_sintoma(banda_distribucion, hall_revisar_alineacion_marcas_tiempo, severo, 36, 47).
componente_sintoma(eje_y_llantas, hall_medir_presion_llantas_manometro_revisar_su, normal, 3, 722).
componente_sintoma(eje_y_llantas, hall_medir_presion_llantas_manometro_revisar_su, leve, 8, 143).
componente_sintoma(eje_y_llantas, hall_medir_presion_llantas_manometro_revisar_su, severo, 29, 95).
componente_sintoma(sensor_tpms, hall_medir_presion_llantas_manometro_revisar_su, normal, 3, 722).
componente_sintoma(sensor_tpms, hall_medir_presion_llantas_manometro_revisar_su, leve, 8, 143).
componente_sintoma(sensor_tpms, hall_medir_presion_llantas_manometro_revisar_su, severo, 29, 95).
componente_sintoma(convertidor_par, hall_revisar_nivel_estado_fluido_transmision, normal, 3, 722).
componente_sintoma(convertidor_par, hall_revisar_nivel_estado_fluido_transmision, leve, 8, 143).
componente_sintoma(convertidor_par, hall_revisar_nivel_estado_fluido_transmision, severo, 29, 95).
componente_sintoma(fluido_transmision, hall_revisar_nivel_estado_fluido_transmision, normal, 3, 722).
componente_sintoma(fluido_transmision, hall_revisar_nivel_estado_fluido_transmision, leve, 8, 143).
componente_sintoma(fluido_transmision, hall_revisar_nivel_estado_fluido_transmision, severo, 29, 95).
componente_sintoma(transmision_automatica, hall_revisar_nivel_estado_fluido_transmision, normal, 3, 722).
componente_sintoma(transmision_automatica, hall_revisar_nivel_estado_fluido_transmision, leve, 8, 143).
componente_sintoma(transmision_automatica, hall_revisar_nivel_estado_fluido_transmision, severo, 29, 95).
componente_sintoma(valvula_admision, hall_revisar_holgura_valvulas, normal, 3, 722).
componente_sintoma(valvula_admision, hall_revisar_holgura_valvulas, leve, 8, 143).
componente_sintoma(valvula_admision, hall_revisar_holgura_valvulas, severo, 29, 95).
componente_sintoma(valvula_escape, hall_revisar_holgura_valvulas, normal, 3, 722).
componente_sintoma(valvula_escape, hall_revisar_holgura_valvulas, leve, 8, 143).
componente_sintoma(valvula_escape, hall_revisar_holgura_valvulas, severo, 29, 95).
componente_sintoma(junta_tapa_valvulas, hall_revisar_apriete_pernos_tapa_valvulas, normal, 1, 818).
componente_sintoma(junta_tapa_valvulas, hall_revisar_apriete_pernos_tapa_valvulas, leve, 3, 95).
componente_sintoma(junta_tapa_valvulas, hall_revisar_apriete_pernos_tapa_valvulas, severo, 36, 47).
componente_sintoma(liquido_limpiaparabrisas, hall_revisar_nivel_liquido_limpiaparabrisas, normal, 1, 818).
componente_sintoma(liquido_limpiaparabrisas, hall_revisar_nivel_liquido_limpiaparabrisas, leve, 3, 95).
componente_sintoma(liquido_limpiaparabrisas, hall_revisar_nivel_liquido_limpiaparabrisas, severo, 36, 47).
componente_sintoma(balero_rueda, hall_revisar_juego_desgaste_baleros_rueda, normal, 3, 722).
componente_sintoma(balero_rueda, hall_revisar_juego_desgaste_baleros_rueda, leve, 8, 143).
componente_sintoma(balero_rueda, hall_revisar_juego_desgaste_baleros_rueda, severo, 29, 95).
componente_sintoma(maza_rueda, hall_revisar_juego_desgaste_baleros_rueda, normal, 3, 722).
componente_sintoma(maza_rueda, hall_revisar_juego_desgaste_baleros_rueda, leve, 8, 143).
componente_sintoma(maza_rueda, hall_revisar_juego_desgaste_baleros_rueda, severo, 29, 95).
componente_sintoma(sensor_velocidad_rueda, hall_revisar_sensor_velocidad_rueda_tiene_suciedad, normal, 1, 818).
componente_sintoma(sensor_velocidad_rueda, hall_revisar_sensor_velocidad_rueda_tiene_suciedad, leve, 3, 95).
componente_sintoma(sensor_velocidad_rueda, hall_revisar_sensor_velocidad_rueda_tiene_suciedad, severo, 36, 47).
componente_sintoma(regulador_vidrio_puerta, hall_revisar_alineacion_vidrio_guias, normal, 1, 818).
componente_sintoma(regulador_vidrio_puerta, hall_revisar_alineacion_vidrio_guias, leve, 3, 95).
componente_sintoma(regulador_vidrio_puerta, hall_revisar_alineacion_vidrio_guias, severo, 36, 47).
componente_sintoma(valvula_iac, hall_limpiar_cuerpo_aceleracion_valvula_iac, normal, 1, 818).
componente_sintoma(valvula_iac, hall_limpiar_cuerpo_aceleracion_valvula_iac, leve, 3, 95).
componente_sintoma(valvula_iac, hall_limpiar_cuerpo_aceleracion_valvula_iac, severo, 36, 47).
componente_sintoma(compresor_ac, hall_inspeccionar_compresor_c_fugas_danos, normal, 1, 818).
componente_sintoma(compresor_ac, hall_inspeccionar_compresor_c_fugas_danos, leve, 3, 95).
componente_sintoma(compresor_ac, hall_inspeccionar_compresor_c_fugas_danos, severo, 36, 47).
componente_sintoma(condensador_ac, hall_inspeccionar_condensador_c_residuos_u, normal, 1, 818).
componente_sintoma(condensador_ac, hall_inspeccionar_condensador_c_residuos_u, leve, 3, 95).
componente_sintoma(condensador_ac, hall_inspeccionar_condensador_c_residuos_u, severo, 36, 47).
componente_sintoma(evaporador_ac, hall_inspeccionar_evaporador_c_moho, normal, 1, 818).
componente_sintoma(evaporador_ac, hall_inspeccionar_evaporador_c_moho, leve, 3, 95).
componente_sintoma(evaporador_ac, hall_inspeccionar_evaporador_c_moho, severo, 36, 47).
componente_sintoma(ecu, hall_inspeccionar_arnes_cables_ecu, normal, 1, 818).
componente_sintoma(ecu, hall_inspeccionar_arnes_cables_ecu, leve, 3, 95).
componente_sintoma(ecu, hall_inspeccionar_arnes_cables_ecu, severo, 36, 47).
componente_sintoma(sensor_map, hall_inspeccionar_manguera_vacio_sensor_map, normal, 1, 818).
componente_sintoma(sensor_map, hall_inspeccionar_manguera_vacio_sensor_map, leve, 3, 95).
componente_sintoma(sensor_map, hall_inspeccionar_manguera_vacio_sensor_map, severo, 36, 47).
componente_sintoma(valvula_pcv, hall_inspeccionar_valvula_pcv_obstrucciones, normal, 1, 818).
componente_sintoma(valvula_pcv, hall_inspeccionar_valvula_pcv_obstrucciones, leve, 3, 95).
componente_sintoma(valvula_pcv, hall_inspeccionar_valvula_pcv_obstrucciones, severo, 36, 47).
componente_sintoma(sensor_tpms, hall_inspeccionar_sensores_tpms_dano_corrosion, normal, 1, 818).
componente_sintoma(sensor_tpms, hall_inspeccionar_sensores_tpms_dano_corrosion, leve, 3, 95).
componente_sintoma(sensor_tpms, hall_inspeccionar_sensores_tpms_dano_corrosion, severo, 36, 47).
componente_sintoma(sensor_tps, hall_inspeccionar_cableado_tps, normal, 1, 818).
componente_sintoma(sensor_tps, hall_inspeccionar_cableado_tps, leve, 3, 95).
componente_sintoma(sensor_tps, hall_inspeccionar_cableado_tps, severo, 36, 47).
componente_sintoma(actuador_seguro_puerta, hall_inspeccionar_mecanismo_actuador_obstrucciones, normal, 1, 818).
componente_sintoma(actuador_seguro_puerta, hall_inspeccionar_mecanismo_actuador_obstrucciones, leve, 3, 95).
componente_sintoma(actuador_seguro_puerta, hall_inspeccionar_mecanismo_actuador_obstrucciones, severo, 36, 47).
componente_sintoma(filtro_aire, hall_inspeccionar_filtro_aire_motor_reemplazar_esta, normal, 1, 818).
componente_sintoma(filtro_aire, hall_inspeccionar_filtro_aire_motor_reemplazar_esta, leve, 3, 95).
componente_sintoma(filtro_aire, hall_inspeccionar_filtro_aire_motor_reemplazar_esta, severo, 36, 47).
componente_sintoma(sistema_carga, hall_inspeccionar_funcionamiento_alternador, normal, 1, 818).
componente_sintoma(sistema_carga, hall_inspeccionar_funcionamiento_alternador, leve, 3, 95).
componente_sintoma(sistema_carga, hall_inspeccionar_funcionamiento_alternador, severo, 36, 47).
componente_sintoma(filtro_cabina, hall_inspeccionar_filtro_cabina_reemplazar_esta, normal, 1, 818).
componente_sintoma(filtro_cabina, hall_inspeccionar_filtro_cabina_reemplazar_esta, leve, 3, 95).
componente_sintoma(filtro_cabina, hall_inspeccionar_filtro_cabina_reemplazar_esta, severo, 36, 47).
componente_sintoma(eje_balanceo, hall_inspeccionar_desgaste_eje_balanceo, normal, 1, 818).
componente_sintoma(eje_balanceo, hall_inspeccionar_desgaste_eje_balanceo, leve, 3, 95).
componente_sintoma(eje_balanceo, hall_inspeccionar_desgaste_eje_balanceo, severo, 36, 47).
componente_sintoma(bateria, hall_inspeccionar_corrosion_terminales_bateria, normal, 1, 818).
componente_sintoma(bateria, hall_inspeccionar_corrosion_terminales_bateria, leve, 3, 95).
componente_sintoma(bateria, hall_inspeccionar_corrosion_terminales_bateria, severo, 36, 47).
componente_sintoma(balero_rueda, hall_inspeccionar_balero_dano_corrosion, normal, 1, 818).
componente_sintoma(balero_rueda, hall_inspeccionar_balero_dano_corrosion, leve, 3, 95).
componente_sintoma(balero_rueda, hall_inspeccionar_balero_dano_corrosion, severo, 36, 47).
componente_sintoma(engranes_conicos, hall_inspeccionar_desgaste_engranes_conicos, normal, 1, 818).
componente_sintoma(engranes_conicos, hall_inspeccionar_desgaste_engranes_conicos, leve, 3, 95).
componente_sintoma(engranes_conicos, hall_inspeccionar_desgaste_engranes_conicos, severo, 36, 47).
componente_sintoma(motor_ventilador_hvac, hall_inspeccionar_motor_ventilador_residuos_dano, normal, 1, 818).
componente_sintoma(motor_ventilador_hvac, hall_inspeccionar_motor_ventilador_residuos_dano, leve, 3, 95).
componente_sintoma(motor_ventilador_hvac, hall_inspeccionar_motor_ventilador_residuos_dano, severo, 36, 47).
componente_sintoma(caliper_freno, hall_inspeccionar_fugas_caliper, normal, 1, 818).
componente_sintoma(caliper_freno, hall_inspeccionar_fugas_caliper, leve, 3, 95).
componente_sintoma(caliper_freno, hall_inspeccionar_fugas_caliper, severo, 36, 47).
componente_sintoma(manguera_freno, hall_inspeccionar_manguera_freno_grietas_fugas, normal, 1, 818).
componente_sintoma(manguera_freno, hall_inspeccionar_manguera_freno_grietas_fugas, leve, 3, 95).
componente_sintoma(manguera_freno, hall_inspeccionar_manguera_freno_grietas_fugas, severo, 36, 47).
componente_sintoma(liquido_frenos, hall_inspeccionar_fugas_lineas_freno, normal, 4, 768).
componente_sintoma(liquido_frenos, hall_inspeccionar_fugas_lineas_freno, leve, 9, 89).
componente_sintoma(liquido_frenos, hall_inspeccionar_fugas_lineas_freno, severo, 86, 44).
componente_sintoma(pastillas_freno, hall_inspeccionar_estado_pastillas_freno, normal, 19, 513).
componente_sintoma(pastillas_freno, hall_inspeccionar_estado_pastillas_freno, leve, 39, 59).
componente_sintoma(pastillas_freno, hall_inspeccionar_estado_pastillas_freno, severo, 341, 29).
componente_sintoma(discos_freno, hall_inspeccionar_disco_rayaduras_alabeo, normal, 9, 683).
componente_sintoma(discos_freno, hall_inspeccionar_disco_rayaduras_alabeo, leve, 19, 79).
componente_sintoma(discos_freno, hall_inspeccionar_disco_rayaduras_alabeo, severo, 171, 39).
componente_sintoma(zapatas_tambor, hall_inspeccionar_desgaste_zapatas_freno, normal, 1, 818).
componente_sintoma(zapatas_tambor, hall_inspeccionar_desgaste_zapatas_freno, leve, 3, 95).
componente_sintoma(zapatas_tambor, hall_inspeccionar_desgaste_zapatas_freno, severo, 36, 47).
componente_sintoma(canister_carbon, hall_inspeccionar_canister_grietas_dano, normal, 1, 818).
componente_sintoma(canister_carbon, hall_inspeccionar_canister_grietas_dano, leve, 3, 95).
componente_sintoma(canister_carbon, hall_inspeccionar_canister_grietas_dano, severo, 36, 47).
componente_sintoma(catalizador, hall_inspeccionar_convertidor_catalitico_dano, normal, 1, 818).
componente_sintoma(catalizador, hall_inspeccionar_convertidor_catalitico_dano, leve, 3, 95).
componente_sintoma(catalizador, hall_inspeccionar_convertidor_catalitico_dano, severo, 36, 47).
componente_sintoma(diferencial_central, hall_inspeccionar_fluido_diferencial_central, normal, 1, 818).
componente_sintoma(diferencial_central, hall_inspeccionar_fluido_diferencial_central, leve, 3, 95).
componente_sintoma(diferencial_central, hall_inspeccionar_fluido_diferencial_central, severo, 36, 47).
componente_sintoma(cable_embrague, hall_inspeccionar_cable_embrague_desgaste, normal, 1, 818).
componente_sintoma(cable_embrague, hall_inspeccionar_cable_embrague_desgaste, leve, 3, 95).
componente_sintoma(cable_embrague, hall_inspeccionar_cable_embrague_desgaste, severo, 36, 47).
componente_sintoma(cilindro_esclavo_embrague, hall_inspeccionar_nivel_estado_liquido_embrague, normal, 1, 818).
componente_sintoma(cilindro_esclavo_embrague, hall_inspeccionar_nivel_estado_liquido_embrague, leve, 3, 95).
componente_sintoma(cilindro_esclavo_embrague, hall_inspeccionar_nivel_estado_liquido_embrague, severo, 36, 47).
componente_sintoma(bomba_inyeccion_diesel, hall_inspeccionar_inyectores_diesel_fugas_u, normal, 1, 818).
componente_sintoma(bomba_inyeccion_diesel, hall_inspeccionar_inyectores_diesel_fugas_u, leve, 3, 95).
componente_sintoma(bomba_inyeccion_diesel, hall_inspeccionar_inyectores_diesel_fugas_u, severo, 36, 47).
componente_sintoma(diferencial, hall_inspeccionar_nivel_estado_fluido_diferencial, normal, 1, 818).
componente_sintoma(diferencial, hall_inspeccionar_nivel_estado_fluido_diferencial, leve, 3, 95).
componente_sintoma(diferencial, hall_inspeccionar_nivel_estado_fluido_diferencial, severo, 36, 47).
componente_sintoma(tapa_distribuidor, hall_inspeccionar_tapa_distribuidor_grietas, normal, 1, 818).
componente_sintoma(tapa_distribuidor, hall_inspeccionar_tapa_distribuidor_grietas, leve, 3, 95).
componente_sintoma(tapa_distribuidor, hall_inspeccionar_tapa_distribuidor_grietas, severo, 36, 47).
componente_sintoma(banda_accesorios, hall_inspeccionar_banda_cortes_desgaste, normal, 1, 818).
componente_sintoma(banda_accesorios, hall_inspeccionar_banda_cortes_desgaste, leve, 3, 95).
componente_sintoma(banda_accesorios, hall_inspeccionar_banda_cortes_desgaste, severo, 36, 47).
componente_sintoma(soportes_motor, hall_inspeccionar_soportes_motor, normal, 1, 818).
componente_sintoma(soportes_motor, hall_inspeccionar_soportes_motor, leve, 3, 95).
componente_sintoma(soportes_motor, hall_inspeccionar_soportes_motor, severo, 36, 47).
componente_sintoma(multiple_escape, hall_inspeccionar_multiple_escape_grietas_fugas, normal, 1, 818).
componente_sintoma(multiple_escape, hall_inspeccionar_multiple_escape_grietas_fugas, leve, 3, 95).
componente_sintoma(multiple_escape, hall_inspeccionar_multiple_escape_grietas_fugas, severo, 36, 47).
componente_sintoma(valvula_escape, hall_inspeccionar_valvula_escape_carbonilla, normal, 1, 818).
componente_sintoma(valvula_escape, hall_inspeccionar_valvula_escape_carbonilla, leve, 3, 95).
componente_sintoma(valvula_escape, hall_inspeccionar_valvula_escape_carbonilla, severo, 36, 47).
componente_sintoma(sensor_detonacion, hall_revisar_codigos_fallo_encendido, normal, 1, 818).
componente_sintoma(sensor_detonacion, hall_revisar_codigos_fallo_encendido, leve, 3, 95).
componente_sintoma(sensor_detonacion, hall_revisar_codigos_fallo_encendido, severo, 36, 47).
componente_sintoma(carga_refrigerante_ac, hall_inspeccionar_fugas_sistema_c, normal, 1, 818).
componente_sintoma(carga_refrigerante_ac, hall_inspeccionar_fugas_sistema_c, leve, 3, 95).
componente_sintoma(carga_refrigerante_ac, hall_inspeccionar_fugas_sistema_c, severo, 36, 47).
componente_sintoma(aceite_motor, hall_inspeccionar_fugas_aceite, normal, 1, 818).
componente_sintoma(aceite_motor, hall_inspeccionar_fugas_aceite, leve, 3, 95).
componente_sintoma(aceite_motor, hall_inspeccionar_fugas_aceite, severo, 36, 47).
componente_sintoma(filtro_combustible, hall_inspeccionar_filtro_combustible_reemplazar, normal, 1, 818).
componente_sintoma(filtro_combustible, hall_inspeccionar_filtro_combustible_reemplazar, leve, 3, 95).
componente_sintoma(filtro_combustible, hall_inspeccionar_filtro_combustible_reemplazar, severo, 36, 47).
componente_sintoma(bomba_combustible, hall_inspeccionar_bomba_combustible_fugas_dano, normal, 1, 818).
componente_sintoma(bomba_combustible, hall_inspeccionar_bomba_combustible_fugas_dano, leve, 3, 95).
componente_sintoma(bomba_combustible, hall_inspeccionar_bomba_combustible_fugas_dano, severo, 36, 47).
componente_sintoma(tanque_combustible, hall_inspeccionar_tanque_combustible_fugas_dano, normal, 1, 818).
componente_sintoma(tanque_combustible, hall_inspeccionar_tanque_combustible_fugas_dano, leve, 3, 95).
componente_sintoma(tanque_combustible, hall_inspeccionar_tanque_combustible_fugas_dano, severo, 36, 47).
componente_sintoma(bujia_incandescente, hall_inspeccionar_bujia_incandescente_carbonilla, normal, 1, 818).
componente_sintoma(bujia_incandescente, hall_inspeccionar_bujia_incandescente_carbonilla, leve, 3, 95).
componente_sintoma(bujia_incandescente, hall_inspeccionar_bujia_incandescente_carbonilla, severo, 36, 47).
componente_sintoma(foco_faro, hall_inspeccionar_filamento_foco_faro, normal, 1, 818).
componente_sintoma(foco_faro, hall_inspeccionar_filamento_foco_faro, leve, 3, 95).
componente_sintoma(foco_faro, hall_inspeccionar_filamento_foco_faro, severo, 36, 47).
componente_sintoma(nucleo_calefaccion, hall_inspeccionar_fugas_nucleo_calefaccion, normal, 1, 818).
componente_sintoma(nucleo_calefaccion, hall_inspeccionar_fugas_nucleo_calefaccion, leve, 3, 95).
componente_sintoma(nucleo_calefaccion, hall_inspeccionar_fugas_nucleo_calefaccion, severo, 36, 47).
componente_sintoma(manguera_calefaccion, hall_inspeccionar_conexiones_mangueras_calefaccion, normal, 1, 818).
componente_sintoma(manguera_calefaccion, hall_inspeccionar_conexiones_mangueras_calefaccion, leve, 3, 95).
componente_sintoma(manguera_calefaccion, hall_inspeccionar_conexiones_mangueras_calefaccion, severo, 36, 47).
componente_sintoma(inyector_combustible, hall_inspeccionar_inyector_fugas_u_obstruccion, normal, 1, 818).
componente_sintoma(inyector_combustible, hall_inspeccionar_inyector_fugas_u_obstruccion, leve, 3, 95).
componente_sintoma(inyector_combustible, hall_inspeccionar_inyector_fugas_u_obstruccion, severo, 36, 47).
componente_sintoma(valvula_admision, hall_inspeccionar_valvula_admision_carbonilla, normal, 1, 818).
componente_sintoma(valvula_admision, hall_inspeccionar_valvula_admision_carbonilla, leve, 3, 95).
componente_sintoma(valvula_admision, hall_inspeccionar_valvula_admision_carbonilla, severo, 36, 47).
componente_sintoma(presion_turbo, hall_inspeccionar_intercooler_fugas_dano, normal, 1, 818).
componente_sintoma(presion_turbo, hall_inspeccionar_intercooler_fugas_dano, leve, 3, 95).
componente_sintoma(presion_turbo, hall_inspeccionar_intercooler_fugas_dano, severo, 36, 47).
componente_sintoma(eje_motriz, hall_inspeccionar_eje_motriz_grietas_deformacion, normal, 1, 818).
componente_sintoma(eje_motriz, hall_inspeccionar_eje_motriz_grietas_deformacion, leve, 3, 95).
componente_sintoma(eje_motriz, hall_inspeccionar_eje_motriz_grietas_deformacion, severo, 36, 47).
componente_sintoma(cilindro_maestro_embrague, hall_inspeccionar_fugas_cilindro_maestro, normal, 3, 722).
componente_sintoma(cilindro_maestro_embrague, hall_inspeccionar_fugas_cilindro_maestro, leve, 8, 143).
componente_sintoma(cilindro_maestro_embrague, hall_inspeccionar_fugas_cilindro_maestro, severo, 29, 95).
componente_sintoma(cilindro_maestro_freno, hall_inspeccionar_fugas_cilindro_maestro, normal, 3, 722).
componente_sintoma(cilindro_maestro_freno, hall_inspeccionar_fugas_cilindro_maestro, leve, 8, 143).
componente_sintoma(cilindro_maestro_freno, hall_inspeccionar_fugas_cilindro_maestro, severo, 29, 95).
componente_sintoma(bomba_aceite, hall_inspeccionar_bomba_aceite_desgaste_dano, normal, 1, 818).
componente_sintoma(bomba_aceite, hall_inspeccionar_bomba_aceite_desgaste_dano, leve, 3, 95).
componente_sintoma(bomba_aceite, hall_inspeccionar_bomba_aceite_desgaste_dano, severo, 36, 47).
componente_sintoma(sensor_oxigeno, hall_inspeccionar_cableado_sensor_oxigeno, normal, 1, 818).
componente_sintoma(sensor_oxigeno, hall_inspeccionar_cableado_sensor_oxigeno, leve, 3, 95).
componente_sintoma(sensor_oxigeno, hall_inspeccionar_cableado_sensor_oxigeno, severo, 36, 47).
componente_sintoma(anillos_piston, hall_inspeccionar_anillos_piston, normal, 1, 818).
componente_sintoma(anillos_piston, hall_inspeccionar_anillos_piston, leve, 3, 95).
componente_sintoma(anillos_piston, hall_inspeccionar_anillos_piston, severo, 36, 47).
componente_sintoma(liquido_direccion, hall_inspeccionar_fugas_mangueras_direccion, normal, 1, 818).
componente_sintoma(liquido_direccion, hall_inspeccionar_fugas_mangueras_direccion, leve, 3, 95).
componente_sintoma(liquido_direccion, hall_inspeccionar_fugas_mangueras_direccion, severo, 36, 47).
componente_sintoma(refrigerante, hall_inspeccionar_fugas_radiador_mangueras, normal, 1, 818).
componente_sintoma(refrigerante, hall_inspeccionar_fugas_radiador_mangueras, leve, 3, 95).
componente_sintoma(refrigerante, hall_inspeccionar_fugas_radiador_mangueras, severo, 36, 47).
componente_sintoma(ventilador_radiador, hall_inspeccionar_motor_rele_ventilador_radiador, normal, 1, 818).
componente_sintoma(ventilador_radiador, hall_inspeccionar_motor_rele_ventilador_radiador, leve, 3, 95).
componente_sintoma(ventilador_radiador, hall_inspeccionar_motor_rele_ventilador_radiador, severo, 36, 47).
componente_sintoma(radiador, hall_inspeccionar_radiador_fugas_dano, normal, 1, 818).
componente_sintoma(radiador, hall_inspeccionar_radiador_fugas_dano, leve, 3, 95).
componente_sintoma(radiador, hall_inspeccionar_radiador_fugas_dano, severo, 36, 47).
componente_sintoma(manguera_radiador, hall_inspeccionar_danos_mangueras_radiador, normal, 1, 818).
componente_sintoma(manguera_radiador, hall_inspeccionar_danos_mangueras_radiador, leve, 3, 95).
componente_sintoma(manguera_radiador, hall_inspeccionar_danos_mangueras_radiador, severo, 36, 47).
componente_sintoma(bomba_agua, hall_inspeccionar_fugas_radiador_mangueras_bomba, normal, 3, 722).
componente_sintoma(bomba_agua, hall_inspeccionar_fugas_radiador_mangueras_bomba, leve, 8, 143).
componente_sintoma(bomba_agua, hall_inspeccionar_fugas_radiador_mangueras_bomba, severo, 29, 95).
componente_sintoma(manguera_radiador, hall_inspeccionar_fugas_radiador_mangueras_bomba, normal, 3, 722).
componente_sintoma(manguera_radiador, hall_inspeccionar_fugas_radiador_mangueras_bomba, leve, 8, 143).
componente_sintoma(manguera_radiador, hall_inspeccionar_fugas_radiador_mangueras_bomba, severo, 29, 95).
componente_sintoma(radiador, hall_inspeccionar_fugas_radiador_mangueras_bomba, normal, 3, 722).
componente_sintoma(radiador, hall_inspeccionar_fugas_radiador_mangueras_bomba, leve, 8, 143).
componente_sintoma(radiador, hall_inspeccionar_fugas_radiador_mangueras_bomba, severo, 29, 95).
componente_sintoma(deposito_refrigerante, hall_inspeccionar_deposito_grietas_fugas, normal, 1, 818).
componente_sintoma(deposito_refrigerante, hall_inspeccionar_deposito_grietas_fugas, leve, 3, 95).
componente_sintoma(deposito_refrigerante, hall_inspeccionar_deposito_grietas_fugas, severo, 36, 47).
componente_sintoma(resistencia_ventilador_hvac, hall_inspeccionar_resistencia_sobrecalentamiento, normal, 1, 818).
componente_sintoma(resistencia_ventilador_hvac, hall_inspeccionar_resistencia_sobrecalentamiento, leve, 3, 95).
componente_sintoma(resistencia_ventilador_hvac, hall_inspeccionar_resistencia_sobrecalentamiento, severo, 36, 47).
componente_sintoma(eje_rigido, hall_inspeccionar_eje_rigido_grietas_dano, normal, 1, 818).
componente_sintoma(eje_rigido, hall_inspeccionar_eje_rigido_grietas_dano, leve, 3, 95).
componente_sintoma(eje_rigido, hall_inspeccionar_eje_rigido_grietas_dano, severo, 36, 47).
componente_sintoma(eje_y_llantas, hall_inspeccionar_balanceo_alineacion_eje, normal, 1, 818).
componente_sintoma(eje_y_llantas, hall_inspeccionar_balanceo_alineacion_eje, leve, 3, 95).
componente_sintoma(eje_y_llantas, hall_inspeccionar_balanceo_alineacion_eje, severo, 36, 47).
componente_sintoma(cables_bujias, hall_inspeccionar_botas_bujias, normal, 1, 818).
componente_sintoma(cables_bujias, hall_inspeccionar_botas_bujias, leve, 3, 95).
componente_sintoma(cables_bujias, hall_inspeccionar_botas_bujias, severo, 36, 47).
componente_sintoma(motor_arranque, hall_inspeccionar_desgaste_escobillas_motor, normal, 1, 818).
componente_sintoma(motor_arranque, hall_inspeccionar_desgaste_escobillas_motor, leve, 3, 95).
componente_sintoma(motor_arranque, hall_inspeccionar_desgaste_escobillas_motor, severo, 36, 47).
componente_sintoma(cuerpo_aceleracion, hall_inspeccionar_carbonilla_cuerpo_aceleracion, normal, 1, 818).
componente_sintoma(cuerpo_aceleracion, hall_inspeccionar_carbonilla_cuerpo_aceleracion, leve, 3, 95).
componente_sintoma(cuerpo_aceleracion, hall_inspeccionar_carbonilla_cuerpo_aceleracion, severo, 36, 47).
componente_sintoma(banda_distribucion, hall_inspeccionar_banda_distribucion, normal, 1, 818).
componente_sintoma(banda_distribucion, hall_inspeccionar_banda_distribucion, leve, 3, 95).
componente_sintoma(banda_distribucion, hall_inspeccionar_banda_distribucion, severo, 36, 47).
componente_sintoma(convertidor_par, hall_inspeccionar_fugas_dano_convertidor_par, normal, 1, 818).
componente_sintoma(convertidor_par, hall_inspeccionar_fugas_dano_convertidor_par, leve, 3, 95).
componente_sintoma(convertidor_par, hall_inspeccionar_fugas_dano_convertidor_par, severo, 36, 47).
componente_sintoma(filtro_transmision, hall_inspeccionar_filtro_transmision_reemplazar, normal, 1, 818).
componente_sintoma(filtro_transmision, hall_inspeccionar_filtro_transmision_reemplazar, leve, 3, 95).
componente_sintoma(filtro_transmision, hall_inspeccionar_filtro_transmision_reemplazar, severo, 36, 47).
componente_sintoma(transmision_automatica, hall_inspeccionar_fugas_transmision, normal, 1, 818).
componente_sintoma(transmision_automatica, hall_inspeccionar_fugas_transmision, leve, 3, 95).
componente_sintoma(transmision_automatica, hall_inspeccionar_fugas_transmision, severo, 36, 47).
componente_sintoma(fluido_transmision, hall_inspeccionar_fugas_carter_sellos_transmision, normal, 1, 818).
componente_sintoma(fluido_transmision, hall_inspeccionar_fugas_carter_sellos_transmision, leve, 3, 95).
componente_sintoma(fluido_transmision, hall_inspeccionar_fugas_carter_sellos_transmision, severo, 36, 47).
componente_sintoma(junta_universal, hall_inspeccionar_desgaste_juego_junta_universal, normal, 1, 818).
componente_sintoma(junta_universal, hall_inspeccionar_desgaste_juego_junta_universal, leve, 3, 95).
componente_sintoma(junta_universal, hall_inspeccionar_desgaste_juego_junta_universal, severo, 36, 47).
componente_sintoma(junta_tapa_valvulas, hall_inspeccionar_fugas_junta_tapa_valvulas, normal, 1, 818).
componente_sintoma(junta_tapa_valvulas, hall_inspeccionar_fugas_junta_tapa_valvulas, leve, 3, 95).
componente_sintoma(junta_tapa_valvulas, hall_inspeccionar_fugas_junta_tapa_valvulas, severo, 36, 47).
componente_sintoma(acoplamiento_viscoso, hall_inspeccionar_fluido_acoplamiento_viscoso, normal, 1, 818).
componente_sintoma(acoplamiento_viscoso, hall_inspeccionar_fluido_acoplamiento_viscoso, leve, 3, 95).
componente_sintoma(acoplamiento_viscoso, hall_inspeccionar_fluido_acoplamiento_viscoso, severo, 36, 47).
componente_sintoma(liquido_limpiaparabrisas, hall_probar_funcionamiento_bomba_liquido, normal, 1, 818).
componente_sintoma(liquido_limpiaparabrisas, hall_probar_funcionamiento_bomba_liquido, leve, 3, 95).
componente_sintoma(liquido_limpiaparabrisas, hall_probar_funcionamiento_bomba_liquido, severo, 36, 47).
componente_sintoma(bomba_limpiaparabrisas, hall_inspeccionar_obstruccion_dano_bomba, normal, 1, 818).
componente_sintoma(bomba_limpiaparabrisas, hall_inspeccionar_obstruccion_dano_bomba, leve, 3, 95).
componente_sintoma(bomba_limpiaparabrisas, hall_inspeccionar_obstruccion_dano_bomba, severo, 36, 47).
componente_sintoma(bomba_agua, hall_inspeccionar_fugas_bomba_agua, normal, 1, 818).
componente_sintoma(bomba_agua, hall_inspeccionar_fugas_bomba_agua, leve, 3, 95).
componente_sintoma(bomba_agua, hall_inspeccionar_fugas_bomba_agua, severo, 36, 47).
componente_sintoma(maza_rueda, hall_inspeccionar_juego_ruido_balero_maza, normal, 1, 818).
componente_sintoma(maza_rueda, hall_inspeccionar_juego_ruido_balero_maza, leve, 3, 95).
componente_sintoma(maza_rueda, hall_inspeccionar_juego_ruido_balero_maza, severo, 36, 47).
componente_sintoma(sensor_velocidad_rueda, hall_inspeccionar_conexiones_sensor_velocidad_rueda, normal, 1, 818).
componente_sintoma(sensor_velocidad_rueda, hall_inspeccionar_conexiones_sensor_velocidad_rueda, leve, 3, 95).
componente_sintoma(sensor_velocidad_rueda, hall_inspeccionar_conexiones_sensor_velocidad_rueda, severo, 36, 47).
componente_sintoma(motor_vidrio_puerta, hall_inspeccionar_regulador_vidrio_electrico, normal, 3, 722).
componente_sintoma(motor_vidrio_puerta, hall_inspeccionar_regulador_vidrio_electrico, leve, 8, 143).
componente_sintoma(motor_vidrio_puerta, hall_inspeccionar_regulador_vidrio_electrico, severo, 29, 95).
componente_sintoma(regulador_vidrio_puerta, hall_inspeccionar_regulador_vidrio_electrico, normal, 3, 722).
componente_sintoma(regulador_vidrio_puerta, hall_inspeccionar_regulador_vidrio_electrico, leve, 8, 143).
componente_sintoma(regulador_vidrio_puerta, hall_inspeccionar_regulador_vidrio_electrico, severo, 29, 95).
componente_sintoma(motor_limpiaparabrisas, hall_inspeccionar_desgaste_articulacion, normal, 1, 818).
componente_sintoma(motor_limpiaparabrisas, hall_inspeccionar_desgaste_articulacion, leve, 3, 95).
componente_sintoma(motor_limpiaparabrisas, hall_inspeccionar_desgaste_articulacion, severo, 36, 47).
componente_sintoma(solenoide_transmision, hall_inspeccionar_arnes_cables_dano_corrosion, normal, 1, 818).
componente_sintoma(solenoide_transmision, hall_inspeccionar_arnes_cables_dano_corrosion, leve, 3, 95).
componente_sintoma(solenoide_transmision, hall_inspeccionar_arnes_cables_dano_corrosion, severo, 36, 47).
componente_sintoma(modulo_abs, hall_inspeccionar_cableado_modulo_abs, normal, 1, 818).
componente_sintoma(modulo_abs, hall_inspeccionar_cableado_modulo_abs, leve, 3, 95).
componente_sintoma(modulo_abs, hall_inspeccionar_cableado_modulo_abs, severo, 36, 47).
componente_sintoma(discos_freno, hall_medir_espesor_disco_freno, normal, 9, 683).
componente_sintoma(discos_freno, hall_medir_espesor_disco_freno, leve, 19, 79).
componente_sintoma(discos_freno, hall_medir_espesor_disco_freno, severo, 171, 39).
componente_sintoma(compresor_ac, hall_ejecutar_escaneo_diagnostico_sistema_c, normal, 1, 818).
componente_sintoma(compresor_ac, hall_ejecutar_escaneo_diagnostico_sistema_c, leve, 3, 95).
componente_sintoma(compresor_ac, hall_ejecutar_escaneo_diagnostico_sistema_c, severo, 36, 47).
componente_sintoma(anillos_piston, hall_realizar_prueba_compresion, normal, 1, 818).
componente_sintoma(anillos_piston, hall_realizar_prueba_compresion, leve, 3, 95).
componente_sintoma(anillos_piston, hall_realizar_prueba_compresion, severo, 36, 47).
componente_sintoma(manguera_freno, hall_probar_presion_manguera_freno, normal, 1, 818).
componente_sintoma(manguera_freno, hall_probar_presion_manguera_freno, leve, 3, 95).
componente_sintoma(manguera_freno, hall_probar_presion_manguera_freno, severo, 36, 47).
componente_sintoma(bomba_agua, hall_probar_presion_sistema_enfriamiento, normal, 3, 722).
componente_sintoma(bomba_agua, hall_probar_presion_sistema_enfriamiento, leve, 8, 143).
componente_sintoma(bomba_agua, hall_probar_presion_sistema_enfriamiento, severo, 29, 95).
componente_sintoma(manguera_calefaccion, hall_probar_presion_sistema_enfriamiento, normal, 3, 722).
componente_sintoma(manguera_calefaccion, hall_probar_presion_sistema_enfriamiento, leve, 8, 143).
componente_sintoma(manguera_calefaccion, hall_probar_presion_sistema_enfriamiento, severo, 29, 95).
componente_sintoma(manguera_radiador, hall_probar_presion_sistema_enfriamiento, normal, 3, 722).
componente_sintoma(manguera_radiador, hall_probar_presion_sistema_enfriamiento, leve, 8, 143).
componente_sintoma(manguera_radiador, hall_probar_presion_sistema_enfriamiento, severo, 29, 95).
componente_sintoma(radiador, hall_probar_presion_sistema_enfriamiento, normal, 3, 722).
componente_sintoma(radiador, hall_probar_presion_sistema_enfriamiento, leve, 8, 143).
componente_sintoma(radiador, hall_probar_presion_sistema_enfriamiento, severo, 29, 95).
componente_sintoma(manguera_calefaccion, hall_probar_presion_mangueras_calefaccion, normal, 1, 818).
componente_sintoma(manguera_calefaccion, hall_probar_presion_mangueras_calefaccion, leve, 3, 95).
componente_sintoma(manguera_calefaccion, hall_probar_presion_mangueras_calefaccion, severo, 36, 47).
componente_sintoma(ecu, hall_escanear_codigos_falla_dtc, normal, 1, 818).
componente_sintoma(ecu, hall_escanear_codigos_falla_dtc, leve, 3, 95).
componente_sintoma(ecu, hall_escanear_codigos_falla_dtc, severo, 36, 47).
componente_sintoma(valvula_iac, hall_probar_funcionamiento_valvula_iac, normal, 1, 818).
componente_sintoma(valvula_iac, hall_probar_funcionamiento_valvula_iac, leve, 3, 95).
componente_sintoma(valvula_iac, hall_probar_funcionamiento_valvula_iac, severo, 36, 47).
componente_sintoma(sensor_map, hall_medir_voltaje_sensor_map, normal, 1, 818).
componente_sintoma(sensor_map, hall_medir_voltaje_sensor_map, leve, 3, 95).
componente_sintoma(sensor_map, hall_medir_voltaje_sensor_map, severo, 36, 47).
componente_sintoma(sistema_carga, hall_medir_salida_alternador, normal, 1, 818).
componente_sintoma(sistema_carga, hall_medir_salida_alternador, leve, 3, 95).
componente_sintoma(sistema_carga, hall_medir_salida_alternador, severo, 36, 47).
componente_sintoma(bateria, hall_medir_voltaje_bateria, normal, 3, 722).
componente_sintoma(bateria, hall_medir_voltaje_bateria, leve, 8, 143).
componente_sintoma(bateria, hall_medir_voltaje_bateria, severo, 29, 95).
componente_sintoma(sistema_carga, hall_medir_voltaje_bateria, normal, 3, 722).
componente_sintoma(sistema_carga, hall_medir_voltaje_bateria, leve, 8, 143).
componente_sintoma(sistema_carga, hall_medir_voltaje_bateria, severo, 29, 95).
componente_sintoma(motor_ventilador_hvac, hall_probar_funcionamiento_motor_ventilador, normal, 1, 818).
componente_sintoma(motor_ventilador_hvac, hall_probar_funcionamiento_motor_ventilador, leve, 3, 95).
componente_sintoma(motor_ventilador_hvac, hall_probar_funcionamiento_motor_ventilador, severo, 36, 47).
componente_sintoma(resistencia_ventilador_hvac, hall_probar_continuidad_resistencia_ventilador, normal, 1, 818).
componente_sintoma(resistencia_ventilador_hvac, hall_probar_continuidad_resistencia_ventilador, leve, 3, 95).
componente_sintoma(resistencia_ventilador_hvac, hall_probar_continuidad_resistencia_ventilador, severo, 36, 47).
componente_sintoma(servofreno, hall_medir_presion_vacio_servofreno, normal, 1, 818).
componente_sintoma(servofreno, hall_medir_presion_vacio_servofreno, leve, 3, 95).
componente_sintoma(servofreno, hall_medir_presion_vacio_servofreno, severo, 36, 47).
componente_sintoma(canister_carbon, hall_probar_funcionamiento_valvula_purga, normal, 3, 722).
componente_sintoma(canister_carbon, hall_probar_funcionamiento_valvula_purga, leve, 8, 143).
componente_sintoma(canister_carbon, hall_probar_funcionamiento_valvula_purga, severo, 29, 95).
componente_sintoma(valvula_purga_canister, hall_probar_funcionamiento_valvula_purga, normal, 3, 722).
componente_sintoma(valvula_purga_canister, hall_probar_funcionamiento_valvula_purga, leve, 8, 143).
componente_sintoma(valvula_purga_canister, hall_probar_funcionamiento_valvula_purga, severo, 29, 95).
componente_sintoma(bomba_inyeccion_diesel, hall_medir_presion_bomba_inyeccion_diesel, normal, 1, 818).
componente_sintoma(bomba_inyeccion_diesel, hall_medir_presion_bomba_inyeccion_diesel, leve, 3, 95).
componente_sintoma(bomba_inyeccion_diesel, hall_medir_presion_bomba_inyeccion_diesel, severo, 36, 47).
componente_sintoma(inyector_combustible, hall_probar_patron_rocio_inyector, normal, 1, 818).
componente_sintoma(inyector_combustible, hall_probar_patron_rocio_inyector, leve, 3, 95).
componente_sintoma(inyector_combustible, hall_probar_patron_rocio_inyector, severo, 36, 47).
componente_sintoma(regulador_presion_combustible, hall_probar_funcionamiento_regulador_presion, normal, 1, 818).
componente_sintoma(regulador_presion_combustible, hall_probar_funcionamiento_regulador_presion, leve, 3, 95).
componente_sintoma(regulador_presion_combustible, hall_probar_funcionamiento_regulador_presion, severo, 36, 47).
componente_sintoma(bomba_combustible, hall_medir_presion_bomba_combustible, normal, 1, 818).
componente_sintoma(bomba_combustible, hall_medir_presion_bomba_combustible, leve, 3, 95).
componente_sintoma(bomba_combustible, hall_medir_presion_bomba_combustible, severo, 36, 47).
componente_sintoma(sensor_presion_tanque, hall_probar_sensor_presion_tanque_combustible, normal, 1, 818).
componente_sintoma(sensor_presion_tanque, hall_probar_sensor_presion_tanque_combustible, leve, 3, 95).
componente_sintoma(sensor_presion_tanque, hall_probar_sensor_presion_tanque_combustible, severo, 36, 47).
componente_sintoma(bujia_incandescente, hall_medir_resistencia_bujia_incandescente, normal, 1, 818).
componente_sintoma(bujia_incandescente, hall_medir_resistencia_bujia_incandescente, leve, 3, 95).
componente_sintoma(bujia_incandescente, hall_medir_resistencia_bujia_incandescente, severo, 36, 47).
componente_sintoma(claxon, hall_probar_rele_claxon, normal, 1, 818).
componente_sintoma(claxon, hall_probar_rele_claxon, leve, 3, 95).
componente_sintoma(claxon, hall_probar_rele_claxon, severo, 36, 47).
componente_sintoma(cables_bujias, hall_probar_continuidad_cables_bujias, normal, 1, 818).
componente_sintoma(cables_bujias, hall_probar_continuidad_cables_bujias, leve, 3, 95).
componente_sintoma(cables_bujias, hall_probar_continuidad_cables_bujias, severo, 36, 47).
componente_sintoma(sensor_detonacion, hall_probar_sensor_detonacion, normal, 1, 818).
componente_sintoma(sensor_detonacion, hall_probar_sensor_detonacion, leve, 3, 95).
componente_sintoma(sensor_detonacion, hall_probar_sensor_detonacion, severo, 36, 47).
componente_sintoma(bomba_aceite, hall_medir_presion_aceite_manometro, normal, 1, 818).
componente_sintoma(bomba_aceite, hall_medir_presion_aceite_manometro, leve, 3, 95).
componente_sintoma(bomba_aceite, hall_medir_presion_aceite_manometro, severo, 36, 47).
componente_sintoma(sensor_oxigeno, hall_medir_voltaje_sensor_oxigeno, normal, 1, 818).
componente_sintoma(sensor_oxigeno, hall_medir_voltaje_sensor_oxigeno, leve, 3, 95).
componente_sintoma(sensor_oxigeno, hall_medir_voltaje_sensor_oxigeno, severo, 36, 47).
componente_sintoma(actuador_seguro_puerta, hall_verificar_alimentacion_electrica_actuador, normal, 1, 818).
componente_sintoma(actuador_seguro_puerta, hall_verificar_alimentacion_electrica_actuador, leve, 3, 95).
componente_sintoma(actuador_seguro_puerta, hall_verificar_alimentacion_electrica_actuador, severo, 36, 47).
componente_sintoma(bomba_limpiaparabrisas, hall_verificar_alimentacion_electrica_bomba, normal, 1, 818).
componente_sintoma(bomba_limpiaparabrisas, hall_verificar_alimentacion_electrica_bomba, leve, 3, 95).
componente_sintoma(bomba_limpiaparabrisas, hall_verificar_alimentacion_electrica_bomba, severo, 36, 47).
componente_sintoma(motor_vidrio_puerta, hall_verificar_alimentacion_electrica_motor_vidrio, normal, 1, 818).
componente_sintoma(motor_vidrio_puerta, hall_verificar_alimentacion_electrica_motor_vidrio, leve, 3, 95).
componente_sintoma(motor_vidrio_puerta, hall_verificar_alimentacion_electrica_motor_vidrio, severo, 36, 47).
componente_sintoma(motor_limpiaparabrisas, hall_verificar_alimentacion_electrica_motor, normal, 1, 818).
componente_sintoma(motor_limpiaparabrisas, hall_verificar_alimentacion_electrica_motor, leve, 3, 95).
componente_sintoma(motor_limpiaparabrisas, hall_verificar_alimentacion_electrica_motor, severo, 36, 47).
componente_sintoma(ventilador_radiador, hall_probar_funcionamiento_ventilador_radiador, normal, 1, 818).
componente_sintoma(ventilador_radiador, hall_probar_funcionamiento_ventilador_radiador, leve, 3, 95).
componente_sintoma(ventilador_radiador, hall_probar_funcionamiento_ventilador_radiador, severo, 36, 47).
componente_sintoma(motor_arranque, hall_probar_solenoide_motor_arranque, normal, 1, 818).
componente_sintoma(motor_arranque, hall_probar_solenoide_motor_arranque, leve, 3, 95).
componente_sintoma(motor_arranque, hall_probar_solenoide_motor_arranque, severo, 36, 47).
componente_sintoma(termostato, hall_probar_funcionamiento_termostato, normal, 1, 818).
componente_sintoma(termostato, hall_probar_funcionamiento_termostato, leve, 3, 95).
componente_sintoma(termostato, hall_probar_funcionamiento_termostato, severo, 36, 47).
componente_sintoma(cuerpo_aceleracion, hall_probar_sensor_posicion_acelerador_tps, normal, 3, 722).
componente_sintoma(cuerpo_aceleracion, hall_probar_sensor_posicion_acelerador_tps, leve, 8, 143).
componente_sintoma(cuerpo_aceleracion, hall_probar_sensor_posicion_acelerador_tps, severo, 29, 95).
componente_sintoma(sensor_tps, hall_probar_sensor_posicion_acelerador_tps, normal, 3, 722).
componente_sintoma(sensor_tps, hall_probar_sensor_posicion_acelerador_tps, leve, 8, 143).
componente_sintoma(sensor_tps, hall_probar_sensor_posicion_acelerador_tps, severo, 29, 95).
componente_sintoma(solenoide_transmision, hall_probar_continuidad_solenoides_transmision, normal, 1, 818).
componente_sintoma(solenoide_transmision, hall_probar_continuidad_solenoides_transmision, leve, 3, 95).
componente_sintoma(solenoide_transmision, hall_probar_continuidad_solenoides_transmision, severo, 36, 47).
componente_sintoma(acoplamiento_viscoso, hall_probar_funcionamiento_acoplamiento_viscoso, normal, 1, 818).
componente_sintoma(acoplamiento_viscoso, hall_probar_funcionamiento_acoplamiento_viscoso, leve, 3, 95).
componente_sintoma(acoplamiento_viscoso, hall_probar_funcionamiento_acoplamiento_viscoso, severo, 36, 47).
componente_sintoma(bomba_agua, hall_probar_funcionamiento_bomba_agua, normal, 1, 818).
componente_sintoma(bomba_agua, hall_probar_funcionamiento_bomba_agua, leve, 3, 95).
componente_sintoma(bomba_agua, hall_probar_funcionamiento_bomba_agua, severo, 36, 47).
