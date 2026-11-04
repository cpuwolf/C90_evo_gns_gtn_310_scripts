function C90_electrics()
	math.randomseed(os.clock() * 0.001)
    gpu_live_volts = simDR_GPU_generator_volts * simDR_gpu_on
    C90.electrical.gpu_live = C90_ternary(gpu_live_volts > 0, 1, 0)
    C90DR_power = math.max(C90.electrical.gpu_live, simDR_battery_on)--best of is battery on or is gpu power available and gpu switch on?
    --ARE VIRTUAL BUSSES POWERED?
    C90.electrical.ctr_bus_hot = C90_ternary(C90DR_ctr_bus_voltage > 0, 1, 0)
    C90.electrical.gen_bus_L_hot = C90_ternary(C90DR_gen_bus_voltage_L > 0, 1, 0)
    C90.electrical.gen_bus_R_hot = C90_ternary(C90DR_gen_bus_voltage_R > 0, 1, 0)
    C90.electrical.tpl_fed_hot = C90_ternary(C90DR_tpl_fed_bus_voltage > 0, 1, 0)
    --BATTERY STATUS                                                                    --IBAV8N Dec2-23
    simDR_battery_1 = C90DR_ovh_emerg                                                   --EMERGENCY LTS
    --simDR_battery_2                                                                   --Belongs to the GNS/GTN, see avionics   
    --simDR_battery_3                                                                   --EFIS AUX, has its own battery
    simDR_battery_4 = math.max(simDR_fuel_pump_on_L, simDR_fuel_pump_on_R)              --IBAV8N, Aug24-23, BOOST PUMPS HOT BUS
    --BATTERY BUS VOLTAGE
    local battery_tie_volts = simDR_actual_volts[0] * C90DR_battery_tie
    --BUS VOLTAGE                                                                       --IBAV8N Dec2-23
    local gens_tied = C90DR_gen_tie_L * C90DR_gen_tie_R
    C90DR_gen_bus_voltage_L = math.max(
        simDR_generator_volts_L * simDR_generator_on_L,                                         --gen running and online
        (simDR_generator_on_R - simDR_generator_on_L) * gens_tied * C90DR_gen_bus_voltage_R,    --cross start
        C90DR_gen_tie_L * battery_tie_volts,                                                    --gen tie man close
        gpu_live_volts * C90DR_gen_tie_L)                                                       --GPU on
    C90DR_gen_bus_voltage_R = math.max(
        simDR_generator_volts_R * simDR_generator_on_R,
        (simDR_generator_on_L - simDR_generator_on_R) * gens_tied * C90DR_gen_bus_voltage_L,
        C90DR_gen_tie_R * battery_tie_volts,
        gpu_live_volts * C90DR_gen_tie_R)
    C90DR_ctr_bus_voltage = math.max(
        C90DR_gen_bus_voltage_L * C90DR_gen_tie_L,
        C90DR_gen_bus_voltage_R * C90DR_gen_tie_R,
        battery_tie_volts,
        gpu_live_volts)
    C90DR_tpl_fed_bus_voltage = math.max(
        C90DR_gen_bus_voltage_L,
        C90DR_gen_bus_voltage_R,
        simDR_actual_volts[0] * simDR_battery_on,
        gpu_live_volts)
    --OVERHEAD VOLTAGE METER                                                      
    if C90DR_volt_bus_sel_dial == 0 then                    --EXT PWR
        voltage_gauge_target = simDR_GPU_generator_volts
    elseif C90DR_volt_bus_sel_dial == 1 then                --CTR BUS
        voltage_gauge_target = C90DR_ctr_bus_voltage
    elseif C90DR_volt_bus_sel_dial == 2 then                --GENERATOR LEFT, GEN TIE CLOSED OR NOT
        voltage_gauge_target = C90DR_gen_bus_voltage_L
    elseif C90DR_volt_bus_sel_dial == 3 then                --GENERATOR RIGHT, GEN TIE CLOSED OR NOT
        voltage_gauge_target = C90DR_gen_bus_voltage_R
    elseif C90DR_volt_bus_sel_dial == 4 then                --TPL FED
        voltage_gauge_target = C90DR_tpl_fed_bus_voltage
    elseif C90DR_volt_bus_sel_dial == 5 then                --BAT
        voltage_gauge_target = simDR_actual_volts[0]
    end
    C90DR_electrical_voltage_gauge = C90_set_animation_position(C90DR_electrical_voltage_gauge, voltage_gauge_target, 0, 30, 9)
    --AC (INVERTER) VOLTAGE METER                                                                  --IBAV8N, Dec2-23
    local inverter_L_online = C90_ternary(simDR_inverter_0_fail ~= 6 and C90.electrical.gen_bus_L_hot > 0 and simDR_inverter_on[0] > 0, 1, 0)
    local inverter_R_online = C90_ternary(simDR_inverter_1_fail ~= 6 and C90.electrical.gen_bus_R_hot > 0 and simDR_inverter_on[1] > 0, 1, 0)
    C90.electrical.ac_power = math.max(inverter_L_online, inverter_R_online)
    local ac_voltage_gauge_target = C90.electrical.ac_power
    C90DR_electrical_ac_voltage_gauge = C90_set_animation_position(C90DR_electrical_ac_voltage_gauge, ac_voltage_gauge_target, 0, 1, 9)
    --FUEL, OIL DIAL GAUGES        --IBAV8N, May3-24, added to smooth fuel gauge, oil gauges needle drop                                       
    if math.max(C90DR_power, C90.electrical.tpl_fed_hot) > 0 then
        C90DR_fuel_needle_left = C90_set_animation_position(C90DR_fuel_needle_left, simDR_fuel_level_indicated_left, 0, 660, 5)
        C90DR_fuel_needle_right = C90_set_animation_position(C90DR_fuel_needle_right, simDR_fuel_level_indicated_right, 0, 660, 5)
        if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
            C90DR_powerplant_oil_temp_gauge_L = C90_set_animation_position(C90DR_powerplant_oil_temp_gauge_L, simDR_oil_temperature_deg_C[0], 0, 660, 4)
            C90DR_powerplant_oil_temp_gauge_R = C90_set_animation_position(C90DR_powerplant_oil_temp_gauge_R, simDR_oil_temperature_deg_C[1], 0, 660, 4)
        end
    else
        C90DR_fuel_needle_left = C90_set_animation_position(C90DR_fuel_needle_left, 0, 0, 660, 20)
        C90DR_fuel_needle_right = C90_set_animation_position(C90DR_fuel_needle_right, 0, 0, 660, 20)
        if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
            C90DR_powerplant_oil_temp_gauge_L = C90_set_animation_position(C90DR_powerplant_oil_temp_gauge_L, 0, 0, 660, 4)
            C90DR_powerplant_oil_temp_gauge_R = C90_set_animation_position(C90DR_powerplant_oil_temp_gauge_R, 0, 0, 660, 4)
        end
    end
    --STARTER AMPS
    start_relays_on = math.max(C90DR_starter_relay_L, C90DR_starter_relay_R)
    if start_relays_on == 1 then
        start_load_L = (180 / math.pow(0.06 * simDR_engine_N1_pct[0] + 0.33, 2)) * C90DR_starter_relay_L
        start_load_R = (180 / math.pow(0.06 * simDR_engine_N1_pct[1] + 0.33, 2)) * C90DR_starter_relay_R
        simDR_plugin_bus_load_amps[1] = (250 - simDR_generator1_amps) * simDR_generator_on_L * C90.electrical.gen_bus_L_hot --cross-start R
        simDR_plugin_bus_load_amps[2] = (250 - simDR_generator2_amps) * simDR_generator_on_R * C90.electrical.gen_bus_R_hot --cross-start L
        start_load_batt = (start_load_L - simDR_plugin_bus_load_amps[2]) + (start_load_R - simDR_plugin_bus_load_amps[1]) --batt only
    else
        simDR_plugin_bus_load_amps[1] = 0
        simDR_plugin_bus_load_amps[2] = 0
        start_load_batt = 0
    end
    --CURRENT SENSORS WILL OPEN IF (The below protects against something that will likely never happen, just eats a bit of CPU time):
    --if simDR_battery_amps[0] < -275 then C90DR_ctr_sense = start_relays_on end        --needs a look to keep max grd heat (<-300 at start) from tripping it
    if simDR_generator1_amps > 275 then C90DR_gen_sense_L = start_relays_on end
    if simDR_generator2_amps > 275 then C90DR_gen_sense_R = start_relays_on end
    --PROP AMPS, needs further review
	local ampLoad_L1 = C90_rescale(0, 19, 1, 23, simDR_prop_ice_per_engine[0])
	local ampLoad_R1 = C90_rescale(0, 19, 1, 23, simDR_prop_ice_per_engine[1])
	local ampLoad_prec = math.random()
	local ampLoad_L = ampLoad_L1 + ampLoad_prec
	local ampLoad_R = ampLoad_R1 + ampLoad_prec
	local prop_heat_fail_L = C90_ternary(simDR_prop_deice_heat_left_fail >= 6, 0, 1)
	local prop_heat_fail_R = C90_ternary(simDR_prop_deice_heat_right_fail >= 6, 0, 1)
	local prop_amps_L = C90_rescale(0, 0, 24, ampLoad_L, (C90DR_ctr_bus_voltage * simDR_prop_heat[0] * prop_heat_fail_L))
	local prop_amps_R = C90_rescale(0, 0, 24, ampLoad_R, (C90DR_ctr_bus_voltage * simDR_prop_heat[1] * prop_heat_fail_R))
	local C90_elec_prop_amps = prop_amps_L + prop_amps_R
	C90DR_electrical_prop_amps_gauge_needle_pos = C90_set_animation_position(C90DR_electrical_prop_amps_gauge_needle_pos, C90_elec_prop_amps, 0, 30, 1)
	simDR_plugin_bus_load_amps[0] = C90_elec_prop_amps + start_load_batt
    --ELECTRIC TRIM (for persistence)
    simDR_electric_trim = C90DR_fltctrl_elev_trim_control_switch_pos * C90.electrical.tpl_fed_hot
end

--EQUALIZE BATTERY LEVELS
local full = 1008
local bat1 = full
local bat2 = full
local bat3 = 250    --WIP
local bat4 = full

function one_battery()		--IBAV8N, Aug29-23
    local hot_bus_1 = (bat1 - simDR_battery_charge[1]) * C90DR_ovh_emerg
    local hot_bus_2 = (bat2 - simDR_battery_charge[2]) * C90DR_avionics_grd_pwr_comm_switch_pos
    --local hot_bus_3 DOESN'T EXIST, AS BATTERY 3 IS REAL AND CHARGES LIKE BATTERY 0
    local hot_bus_4 = (bat4 - simDR_battery_charge[4]) * (1 - C90DR_power) * math.max(simDR_fuel_pump_on_L, simDR_fuel_pump_on_R)
    local hot_bus_total = hot_bus_1 + hot_bus_2 + hot_bus_4

    if gpu_live_volts > 0 or C90.electrical.gen_bus_L_hot == 1 or C90.electrical.gen_bus_R_hot == 1 then
        simDR_battery_charge[1] = full      --Emergency lights
        simDR_battery_charge[2] = full      --Ground Comm
        simDR_battery_charge[4] = full      --Fuel boost pumps
    else
        simDR_battery_charge[0] = simDR_battery_charge[0] - hot_bus_total
    end
    bat1 = simDR_battery_charge[1]
    bat2 = simDR_battery_charge[2]
    bat4 = simDR_battery_charge[4] 
end

function ties_gens_status()
    if C90DR_ctr_bus_voltage == 0 then C90DR_man_close = 0 end                      --MAN GEN TIE
    C90DR_battery_tie = C90DR_ctr_sense * simDR_battery_on                          --BATTERY TIE
    simDR_cross_tie = C90_ternary(C90DR_electrical_cross_tie_switch_pos < 0, 0, 1)  --CROSS TIE
    --DC GENS WILL OPEN/WON'T CLOSE IF:
    if gen_check(simDR_generator_volts_L, C90DR_powerplant_ign_start_switch_pos_L) == 1 then simDR_generator_on_L = 0 end    --gen voltage is not enough to connect to bus, what if too high?
    if gen_check(simDR_generator_volts_R, C90DR_powerplant_ign_start_switch_pos_R) == 1 then simDR_generator_on_R = 0 end
    --GEN TIES WILL OPEN IF:
    if tie_check(C90DR_gen_sense_L) == 1 then C90DR_gen_tie_L = 0 end  --engine out, gen failure or sense test
    if tie_check(C90DR_gen_sense_R) == 1 then C90DR_gen_tie_R = 0 end
    simDR_bus_tie_selective = 1 + (2 * C90DR_gen_tie_L) + (4 * C90DR_gen_tie_R) --still in testing, letting battery tie in botches the garmin avionics
    --TURN OFF EXT PWR AFTER BOTH ENGINES IDLING:
    if simDR_override_GPU_volts ~= C90_ternary(simDR_engine_N1_pct[0] > 58 and simDR_engine_N1_pct[1] > 58, 1, 0) then
        simDR_override_GPU_volts = 1 - simDR_override_GPU_volts end
    if simDR_override_GPU_volts == 1 then simDR_GPU_generator_volts = 0 end --since 12.08RC2 requires this
    --EXT PWR ANNUNCIATOR:
    if simDR_GPU_generator_volts > 0 then
        if simDR_battery_on == 1 then
            C90.electrical.gpu_status = math.max(simDR_gpu_on, 1 - C90.electrical.gpu_status) --if gpu available but not used, flash, otherwise lit
        else
            C90.electrical.gpu_status = simDR_gpu_on
        end
    else
        C90.electrical.gpu_status = 0     --annun ext
    end
    stair_thresh_lights()
end

function gen_check(gen_volt, ign_start_switch_pos)
    if gen_volt < (C90DR_ctr_bus_voltage - 0.5 - start_relays_on) or    --off or not enough voltage to connect, XP drops gen volt for fraction of second when start relays active
        ign_start_switch_pos ~= 0 then              --starter motor circuit is engaged
        return 1
    end
end

function tie_check(sense)
    if sense == 0 or C90DR_electrical_cross_tie_switch_pos == -1 or C90DR_ctr_bus_voltage == 0 then   --sense test, gen tie open or (ctr bus == 0, testing)
        return 1
    else
        return 0  --need this for sys.lua
    end
end

function stair_thresh_lights()
    if simDR_door_open_ratio[0] > 0.2 then
        simDR_generic_lights_switch[6] = 1      --Stair lights
        simDR_generic_lights_switch[7] = 1      --Threshold light
    else
        simDR_generic_lights_switch[6] = 0
        if C90DR_lighting_cabin_brt_dim_switch_pos == -1 then
	        simDR_generic_lights_switch[7] = 0
        elseif C90DR_lighting_cabin_brt_dim_switch_pos == 0 then
		    simDR_generic_lights_switch[7] = 0.5
        else simDR_generic_lights_switch[7] = 1
        end
    end
end
