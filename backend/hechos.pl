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
