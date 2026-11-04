local C90_warn_alt_alert_flash  = 0
local caution                   = 0
local warning                   = 0
local gear_warn_light           = 0     --IBAV8N, Aug30-23, make gear warning work correctly, this will light the handle

-- EXTENDED MASTER WARNING & MASTER CAUTION ANNUNCIATIONS
function master_warning()
    local warning_trigger = 0
    local warning_array_test_trigger = 0
    local warning_status_test_trigger = 0
    if C90DR_electrical_annun_test_on == 0 then
        if warning == 0 then
            for i = 0, 12 do
                warning_array_test_trigger = C90.warning.array[i]
                warning_status_test_trigger = C90.warning.status[i]
                if warning_status_test_trigger > warning_array_test_trigger then C90.warning.status[i] = 0
                elseif warning_array_test_trigger > warning_status_test_trigger then warning_trigger = 1 break end
            end
            warning = warning_trigger
            simDR_master_warning_plugin = warning
        elseif is_timer_scheduled(warningflash) == false then
            run_at_interval(warningflash, 0.125)
        end
    else stop_timer(warningflash)
        C90DR_lighting_annun_master_warning = 1
    end
end

function warningflash()
    local warning_array_test_reset = 0
    local warning_status_test_reset = 0
	if simDR_master_warning == 0 then
        C90.annunciator_warning = 0
        simDR_master_warning_plugin = 0
        for i = 0, 12 do
            warning_array_test_reset = C90.warning.array[i]
            warning_status_test_reset = C90.warning.status[i]
            if warning_status_test_reset ~= warning_array_test_reset then C90.warning.status[i] = warning_array_test_reset
            elseif warning_status_test_reset == warning_array_test_reset and i == 12 then break end
        end
        warning = 0
		stop_timer(warningflash)
    else C90.annunciator_warning = 1 - C90.annunciator_warning
	end
end

function master_caution()
    local caution_trigger = 0
    local caution_array_test_trigger = 0
    local caution_status_test_trigger = 0
    if C90DR_electrical_annun_test_on == 0 then
        if caution == 0 then
            for i = 0, 18 do
                caution_array_test_trigger = C90.caution.array[i]
                caution_status_test_trigger = C90.caution.status[i]
                if caution_status_test_trigger > caution_array_test_trigger then C90.caution.status[i] = 0
                elseif caution_array_test_trigger > caution_status_test_trigger then caution_trigger = 1 break end
            end
            caution = caution_trigger
            simDR_master_caution_plugin = caution
        elseif is_timer_scheduled(cautionflash) == false then
            run_at_interval(cautionflash, 0.125)
        end
    else stop_timer(cautionflash)
        C90DR_lighting_annun_master_caution = 1
    end
end

function cautionflash()
    local caution_array_test_reset = 0
    local caution_status_test_reset = 0
	if simDR_master_caution == 0 then
        C90DR_lighting_annun_master_caution = 0
        simDR_master_caution_plugin = 0
        for i = 0, 18 do
            caution_array_test_reset = C90.caution.array[i]
            caution_status_test_reset = C90.caution.status[i]
            if caution_status_test_reset ~= caution_array_test_reset then C90.caution.status[i] = caution_array_test_reset
            elseif caution_status_test_reset == caution_array_test_reset and i == 19 then break end
        end
        caution = 0
		stop_timer(cautionflash)
    else C90DR_lighting_annun_master_caution = 1 - C90DR_lighting_annun_master_caution
	end
end

-- WARNING, CAUTION, AND ADVISORY ANNUNCIATORS ---------------------------------------
function C90_warning_annunciators()
	if math.max(C90DR_power, C90_ternary(C90DR_gen_bus_voltage_L > 0, 1, 0)) > 0 then --IBAV8N, Aug23-23, L gen can provide power
        master_caution()
        master_warning()
        --GEAR HANDLE WARNING                                                                           --IBAV8N, Aug30-23
        C90DR_warning_gear_handle = C90_ternary(
            (simDR_gear_deploy_ratio[0] ~= 0 and simDR_gear_deploy_ratio[0] ~= 1)
            or (simDR_gear_deploy_ratio[1] ~= 0 and simDR_gear_deploy_ratio[1] ~= 1)
            or (simDR_gear_deploy_ratio[2] ~= 0 and simDR_gear_deploy_ratio[2] ~= 1)
            or C90DR_landing_gear_handle_light_test == 1
            or simDR_gear1_fail == 6
            or simDR_gear2_fail == 6
            or simDR_gear3_fail == 6
            or gear_warn_light == 1, 1, 0)
        --GEAR HORN WARNING                                                                             --IBAV8N, Aug30-23
        C90_gear_horn()
		C90.warning.array[0] = C90_ternary(simDR_fuel_pressure_psi[0] < 10, 1, 0)                       --FUEL PRESS L
		C90.warning.array[1] = C90_ternary(simDR_oil_pressure_psi[0] < 40, 1, 0)                        --OIL PRESS L
		C90.warning.array[2] = simDR_annun_engine_fire[0]                                               --ENGINE FIRE L
	    C90.warning.array[3] = C90_ternary(C90.electrical.ac_power == 0 and simDR_acf_descrip ~= "C90B - G1000, Blackhawk", 1, 0) --INVERTER
		C90.warning.array[4] = C90_ternary(simDR_ap_computer_fail == 6, 1, 0)                           --AUTOPILOT FAIL
		C90.warning.array[5] = C90_ternary(simDR_ap_servo_fail > 0, 1, 0)                               --AUTOPILOT TRIM FAIL
		C90.warning.array[6] = simDR_annun_cabin_alt_hi                                                 --CABIN ALTITUDE HI
		C90.warning.array[7] = C90_ternary(simDR_door_open_ratio[0] > 0.1, 1, 0)                        --CABIN DOOR
		C90.warning.array[8] = C90_ternary(simDR_bleed_valve_left == 0 or simDR_bleed_valve_right == 0, 1, 0)   --L BLEED AIR (originally BAGGAGE DOOR)
		C90.warning.array[9] = simDR_annun_engine_fire[1]                                               --ENGINE FIRE R
		C90.warning.array[10] = C90_ternary(simDR_oil_pressure_psi[1] < 40, 1, 0)                       --OIL PRESS R
		C90.warning.array[11] = C90_ternary(simDR_fuel_pressure_psi[1] < 10, 1, 0)                      --FUEL PRES R
        C90.warning.array[12] = simDR_annun_ap_disco                                                    --AUTOPILOT DISCONNECT
		C90.caution.ext_power = C90.electrical.gpu_status                                               --EXT POWER, WILL NOT TRIGGER CAUTION
		C90.caution.array[0] = 1 - simDR_generator_on_L                                                 --DC GEN L
		C90.caution.array[1] = simDR_annun_fuel_transfer[0]                                             --NO FUEL XFR L
		C90.caution.array[2] = C90_ternary(                                                             --RVS NOT READY
            (simDR_prop_rot_speed_actuator[0] < 197 or simDR_prop_rot_speed_actuator[1] < 197)
            and simDR_gear_deploy_ratio[0] > 0.95 and simDR_gear_deploy_ratio[1] > 0.95 and simDR_gear_deploy_ratio[2] > 0.95
            , 1, 0)
		C90.caution.array[3] = simDR_annun_chip_detected[0]                                             --CHIP DETECT L
		C90.caution.array[4] = simDR_annun_ice_vane_fail[0]                                             --ENGINE ICE FAIL L
		C90.caution.array[5] = simDR_annun_ice_vane_fail[1]                                             --ENGINE ICE FAIL R
		C90.caution.array[6] = C90_ternary((simDR_cross_tie == 0 or C90DR_gen_tie_L == 0), 1, 0)        --GEN TIE OPEN L
		C90.caution.array[7] = C90_ternary((C90DR_battery_tie == 0 or simDR_battery_on == 0), 1, 0)	    --BAT TIE OPEN
		C90.caution.array[8] = C90_ternary((simDR_cross_tie == 0 or C90DR_gen_tie_R == 0), 1, 0)        --GEN TIE OPEN R
		C90.caution.array[9] = 1 - simDR_electric_trim                                                  --PITCH TRIM OFF
		C90.caution.array[10] = simDR_annun_chip_detected[1]                                            --CHIP DETECT R
		C90.caution.array[11] = simDR_annun_fuel_transfer[1]                                            --NO FUEL XFR R
		C90.caution.array[12] = 1 - simDR_generator_on_R                                                --DC GEN R
		C90.caution.array[13] = simDR_annun_fuel_crossfeed                                              --FUEL CROSSFEED
		C90.caution.array[14] = C90_ternary(simDR_hyd_fluid_ratio < 0.2 or C90DR_engine_hydraulic_fluid_test == 1, 1, 0) --HYD FLUID LO
        C90.caution.array[15] = 0                           -- BATTERY CHARGE (CHARGE RATE EXCEEDS 7 AMPS FOR > 6 SECONDS)
        C90.caution.array[16] = C90DR_avionics_mic_sel_switch_pos_pilot                                 --PILOT OXYGEN
        C90.caution.array[17] = C90DR_avionics_mic_sel_switch_pos_copilot                               --COPILOT OXYGEN
        --RADAR -IBAV8N, Jan15, only triggers master caution, no annunc. Radar is on on the ground.
        C90.caution.array[18] = C90_ternary((C90DR_avionics_EFIS_map_mode_sel_dial_pos > 2 and C90DR_gear_handle == 1) and simDR_efis1_fail == 0, 1, 0)
		C90.advisory.status[0] = math.max(C90_ternary(simDR_torque_L < 542 and simDR_auto_ignite_on[0] > 0, 1, 0), simDR_annun_igniter_on[0])       --IGNITION ON L, auto switches must be on when t<400ft-lbs
		C90.advisory.status[1] = math.max(C90_ternary(simDR_torque_R < 542 and simDR_auto_ignite_on[1] > 0, 1, 0), simDR_annun_igniter_on[1])       --IGNITION ON R
		C90.advisory.status[2] = C90_ternary(simDR_torque_R < 353, 0, 1) * C90_ternary(                 --LEFT AUTOFEATHER  IBAV8N, Aug9-24
            (simDR_prop_feather_mode_switch > 0 and simDR_torque_R < 271) or
            (simDR_prop_feather_mode_switch == 1 and simDR_engine_N1_pct[0] > 90) or
            (simDR_prop_feather_mode_switch == 2 and C90_ternary(simDR_torque_L < 353, C90_ternary(math.random(0, 3) == 0, 1, 0) == 1, C90_ternary(simDR_torque_R > 542, 1, 0) == 1))
            , 1, 0)
		C90.advisory.status[3] = C90_ternary(simDR_torque_L < 353, 0, 1) * C90_ternary(                 --RIGHT AUTOFEATHER  IBAV8N, Aug9-24
            (simDR_prop_feather_mode_switch > 0 and simDR_torque_L < 271) or
            (simDR_prop_feather_mode_switch == 1 and simDR_engine_N1_pct[1] > 90) or
            (simDR_prop_feather_mode_switch == 2 and C90_ternary(simDR_torque_R < 353, C90_ternary(math.random(0, 3) == 0, 1, 0) == 1, C90_ternary(simDR_torque_L > 542, 1, 0) == 1))
            , 1, 0)
		C90.advisory.status[4] = simDR_annun_ice_vane_extend[0]                                         --ENGINE ANTI-ICE L
		C90.advisory.status[5] = simDR_annun_ice_vane_extend[1]                                         --ENGINE ANTI-ICE R
		C90.advisory.status[6] = C90DR_man_close                                                        --MAN TIES CLOSE
		C90.advisory.status[7] = C90_ternary(((simDR_taxi_light_switch == 1 or simDR_landing_light_switch[0] == 1 or simDR_landing_light_switch[1] == 1)       -- LDG/TAXI LIGHT
            and (simDR_gear_deploy_ratio[0] < 0.05 and simDR_gear_deploy_ratio[1] < 0.05 and  simDR_gear_deploy_ratio[2] < 0.05))
            , 1, 0)
	else
        for i = 0, 12 do                        --IBAV8N, May5
            C90.warning.array[i] = 0
        end
        for i = 0, 18 do                        --IBAV8N, May5
            C90.caution.array[i] = 0
        end
        for i = 0, 7 do                        --IBAV8N, Jul11-24
            C90.advisory.status[i] = 0
        end
	end
end

----- EFIS AUX -----------------------------------------------------------------------------
function C90_warning_EFIS_aux()                             --IBAV8N, Aug28-22, all new code
    C90.electrical.efis_aux_trigger = simDR_battery_3 * math.max(0, C90DR_avionics_EFIS_aux_pwr_on_switch_pos)
    if C90.electrical.efis_aux_trigger > C90.electrical.efis_aux_silence then
        C90DR_warning_EFIS_aux_horn_on = 1
    elseif C90.electrical.efis_aux_silence > C90.electrical.efis_aux_trigger then
        C90.electrical.efis_aux_silence = C90.electrical.efis_aux_trigger
    else
        C90DR_warning_EFIS_aux_horn_on = 0
    end
end

----- ALTITUDE ALERT --------------------------------------------------------------------
function C90_warning_alt_alert_flash()
	C90_warn_alt_alert_flash = 1 - C90_warn_alt_alert_flash
end

function C90_warning_altitude_alert()
    local lastAlertMode = 0
    local alt_alert = 0
	if C90.pre80.alert == 0 then													-- OFF
		if is_timer_scheduled(C90_warning_alt_alert_flash) == true then
 			stop_timer(C90_warning_alt_alert_flash)
 		end
		alt_alert = 0	-- OFF
	elseif C90.pre80.alert == 1 then												-- ACQUISTION ARMED MODE
		if is_timer_scheduled(C90_warning_alt_alert_flash) == true then
 			stop_timer(C90_warning_alt_alert_flash)
 		end
		alt_alert = 1	-- SOLID LIGHT

	elseif C90.pre80.alert == 2 then												-- ACQUISTION MODE _OR_ DEVIATION ARMED MODE
		if is_timer_scheduled(C90_warning_alt_alert_flash) == false then
			run_timer(C90_warning_alt_alert_flash, 0, 0.5)
		end
		alt_alert = C90_warn_alt_alert_flash	-- FLASHING LIGHT
	end
	if alt_alert ~= lastAlertMode then
		lastAlertMode = alt_alert
	end
end

----- GEAR HORN ALERT --------------------------------------------------------------------
function C90_gear_horn()
    if C90DR_gear_handle < 1 then
        if simDR_engine_N1_pct[0] < 68 and simDR_engine_N1_pct[1] < 68 then
            gear_warn_light = 1
            C90DR_gear_horn = 1 - C90.gear_warn_muted
        else
            gear_warn_light = 0
            C90DR_gear_horn = 0
        end
        if simDR_flaprqst == 1 then
            gear_warn_light = 1 
            C90DR_gear_horn = 1
        end
    else
        C90.gear_warn_muted = 0
        gear_warn_light = 0
        C90DR_gear_horn = 0
    end
end
