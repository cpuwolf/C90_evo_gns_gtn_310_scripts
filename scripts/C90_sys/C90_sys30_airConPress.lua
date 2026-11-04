-- CABIN AIR TEMPERATURE
function C90_cabin_air_temp()               --IBAV8N, Jan10-22, New code
    local C90_power_avail = C90_ternary((math.max(simDR_bus_volts[0], simDR_bus_volts[1]) > 15), 1, 0)    -- POWER AVAILABILITY

    -- BLEEDS ON/OFF
    local C90_bleed_on_l = C90_ternary(C90DR_pneumatic_bleed_air_switch_pos_L == 1 and simDR_engine_running[0] == 1, 1, 0)
    local C90_bleed_on_r = C90_ternary(C90DR_pneumatic_bleed_air_switch_pos_R == 1 and simDR_engine_running[1] == 1, 1, 0)
    if C90_bleed_on_l == 1 then
        if simDR_bleed_air_mode < 1 or simDR_bleed_air_mode > 2 then
            simCMD_bleed_air_on_L:once()
        end
    elseif C90_bleed_on_l == 0 then
        if simDR_bleed_air_mode == 1 or simDR_bleed_air_mode == 2 then
            simCMD_bleed_air_off_L:once()
        end
    end
    if C90_bleed_on_r == 1 then
        if simDR_bleed_air_mode > 3 or simDR_bleed_air_mode < 2 then
            simCMD_bleed_air_on_R:once()
        end
    elseif C90_bleed_on_r == 0 then
        if simDR_bleed_air_mode == 3 or simDR_bleed_air_mode == 2 then
            simCMD_bleed_air_off_R:once()
        end
    end

    -- BLEED LEVEL AVAILABILITY
    if simDR_bleed_air_mode > 0 and simDR_bleed_air_mode < 4 then
        if simDR_bleed_air_mode == 2 then
            C90.airCon.bleed_avail = 1
        else C90.airCon.bleed_avail = 0.5
        end
    else C90.airCon.bleed_avail = 0
    end

    -- ELECTRIC HEAT SWITCH SOLENOID DROPS TO LOW WHEN WHEELS UP
    if simDR_pressure_heater_on > 1 and simDR_gear_handle_down == 0 then
        if is_timer_scheduled(elec_heat_liftoff) == false then run_at_interval(elec_heat_liftoff, 0.3) end
    end

    -- CABIN TEMP TARGET
    C90.airCon.cabin_temp_target = (36 * C90DR_airCon_cabin_temp_dial) + 50

    -- TEMP MODIFIERS
    local C90_ambient_change = C90_ternary(simDR_door_open_ratio[0] == 0, 1, 18) * (0.0005 * (simDR_oat_degf - C90.airCon.cabin_temp))
    local C90_bleed_change = C90.airCon.bleed_avail * (0.0009 * (150 - (C90.airCon.bypass_valve * 0.7 * (150 - simDR_oat_degf)) - C90.airCon.cabin_temp))
    local C90_elec_increase = 0.068 * simDR_pressure_heater_on * C90_ternary(simDR_fan_speed < 2, 1, 1.5)
    local C90_ac_reduce = 0.13 * simDR_air_cond_on  --40deg delta
    local C90_temp_delta = (C90_ambient_change + C90_bleed_change + C90_elec_increase - C90_ac_reduce) * SIM_PERIOD

    -- AUTO MODE THERMOSTAT
    local C90_delta = C90.airCon.cabin_temp - C90.airCon.cabin_temp_target  --neg if too cold, pos if too hot
	if C90DR_airCon_cabin_temp_mode_dial_pos == 1 and C90_power_avail == 1 then
        if C90_temp_delta < C90_delta * -0.003 then auto_bypass_up()                --INCREASE CABIN TEMP
        elseif C90_temp_delta > C90_delta * -0.003 then auto_bypass_down()          --REDUCE CABIN TEMP
        end
    end
    C90.airCon.cabin_temp = C90.airCon.cabin_temp + C90_temp_delta                  -- CABIN TEMP + MODIFIERS
	C90DR_airCon_cabin_air_temp_gauge_degF_needle_pos = C90.airCon.cabin_temp       -- SET NEEDLE POSITION
end

function cabin_temp_cold_and_dark()     --IBAV8N, Jan17-24, set the cabin temp to OAT if cold & dark load
    C90.airCon.cabin_temp = simDR_oat_degf
end

-- HEAT CABIN
function auto_bypass_up()
    C90.airCon.bypass_valve = C90.airCon.bypass_valve - (0.016667 * SIM_PERIOD)
    if C90.airCon.cabin_temp_target < simDR_oat_degf then
        if C90.airCon.bypass_valve < 0.66 then
            C90.airCon.bypass_valve = 0.66
        end
    end
    if C90.airCon.bypass_valve < 0 then
        C90.airCon.bypass_valve = 0
    end
end

-- COOL CABIN
function auto_bypass_down()
    C90.airCon.bypass_valve = C90.airCon.bypass_valve + (0.016667 * SIM_PERIOD)
    if C90.airCon.cabin_temp_target > (simDR_oat_degf + (C90.airCon.bleed_avail * 18)) then
        if C90.airCon.bypass_valve > 0.98 then
            C90.airCon.bypass_valve = 0.98
        end
    end
    if C90.airCon.bypass_valve > 1 then
        C90.airCon.bypass_valve = 1
    end
end

function man_bypass_down()                                                              --IBAV8N,Jan10-22  New system
    if C90DR_airCon_cabin_temp_mode_dial_pos > 1 and C90DR_power == 1 then
        if C90.airCon.bypass_valve < 1 then
            C90.airCon.bypass_valve = C90.airCon.bypass_valve + 0.016667 * SIM_PERIOD
        end
    end
    if C90.airCon.bypass_valve > 1 then
        C90.airCon.bypass_valve = 1
    end
    stop_timer(man_bypass_down)
end

function man_bypass_up()                                                                --IBAV8N,Jan10-22  New system
    if C90DR_airCon_cabin_temp_mode_dial_pos > 1 and C90DR_power == 1 then
        if C90.airCon.bypass_valve > 0 then
            C90.airCon.bypass_valve = C90.airCon.bypass_valve - 0.016667 * SIM_PERIOD
        end
    end
    if C90.airCon.bypass_valve < 0 then
        C90.airCon.bypass_valve = 0
    end
    stop_timer(man_bypass_up)
end

-- KNOCK ELEC HEAT DOWN TO LOW AFTER LIFTOFF
function elec_heat_liftoff()
    simDR_pressure_heater_on = 1
end

-- A/C COMPRESSOR
function ac_compressor()                                                                --IBAV8N,Jan10-22  New system
    local ac_available = C90_ternary((C90DR_airCon_cabin_temp_mode_dial_pos == 1 or C90DR_airCon_cabin_temp_mode_dial_pos == 2), 1, 0)
    if simDR_air_cond_on == 0 then
        if C90.airCon.bypass_valve > 0.99 and C90.airCon.cabin_temp > 50 and ac_available == 1 then
            simDR_air_cond_on = 1
        end
    elseif simDR_air_cond_on == 1 then
        if C90.airCon.bypass_valve < 0.67 or ac_available == 0 then --0.833
            simDR_air_cond_on = 0
        end
    end
end

----- CABIN PRESSURE --------------------------------------------------------------------
function C90_cabin_pressure()
    if simDR_gear_on_ground[1] == 1 then  --squat switch is on left main
        if math.abs(simDR_cabin_pressure_differential_psi) > 0.005 and simDR_pressure_dump_all_on == 0 then
            simCMD_dump_cabin_press_on:once()
        end
    elseif simDR_gear_on_ground[1] == 0 and simDR_gear_on_ground[2] == 0 and simDR_pressure_dump_all_on == 1 then
        simCMD_dump_cabin_press_off:once()
    end
    if simDR_groundspeed > 1 or math.abs(simDR_cabin_pressure_differential_psi) > 0.5 then        --IBAV8N, Apr8-22, close cabin door if plane is in motion or cabin psi delta temp
        simDR_cabindoor = 0
    end
	C90DR_pressure_cabin_alt_ind_ft = simDR_pressure_cabin_alt_ind_ft * 0.001
end
