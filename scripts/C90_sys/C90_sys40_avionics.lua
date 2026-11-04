local is_ttg_running = 0

function C90_avionics_audio_vol()
----- AUDIO VOLUME ----------------------------------------------------------------------
    if simDR_acf_descrip == "C90B - G1000, Blackhawk" then  --IBAV8N, Sept30-23 - G1ks control Nav/Com volumes, master controls MKR, DME volumes, Avonics_on cycle resets master to 1.
	    simDR_mkr_audio_vol = C90DR_avionics_on_sw_pos
	    simDR_audio_volume_dme1 = C90DR_avionics_on_sw_pos
    else
        simDR_audio_selection_dme1 = (1 - C90DR_avionics_dme_channel_sel_switch_pos) * simDR_audio_dme_enabled
        simDR_audio_selection_dme2 = C90DR_avionics_dme_channel_sel_switch_pos * simDR_audio_dme_enabled
	    simDR_adf1_audio_vol = C90DR_avionics_adf1_vol_control_dial * C90DR_avionics_master_vol_ctrl_dial_pilot
	    simDR_audio_volume_dme1 = C90DR_avionics_dme_vol_dial * C90DR_avionics_master_vol_ctrl_dial_pilot
	    simDR_audio_volume_dme2 = simDR_audio_volume_dme1
	    simDR_mkr_audio_vol = C90DR_avionics_mkr_bkn_vol_dial * C90DR_avionics_master_vol_ctrl_dial_pilot
	    if simDR_acf_descrip == "C90B EVO GNS" then
	        simDR_com1_audio_vol = C90DR_avionics_com1_vol_control_dial * C90DR_avionics_master_vol_ctrl_dial_pilot
	        simDR_com2_audio_vol = C90DR_avionics_com2_vol_control_dial * C90DR_avionics_master_vol_ctrl_dial_pilot
	        simDR_nav1_audio_vol = C90DR_avionics_nav1_vol_control_dial * C90DR_avionics_master_vol_ctrl_dial_pilot
	        simDR_nav2_audio_vol = C90DR_avionics_nav2_vol_control_dial * C90DR_avionics_master_vol_ctrl_dial_pilot
	    end
    end
end

----- PILOT'S AUTOCOMM FUNCTION --------------------------------------------------------
function autocomm()
    if C90DR_avionics_auto_comm_switch_pos_pilot == 0 then
        simDR_com1_monitor = C90DR_avionics_com1_audio_switch_pos_pilot
        simDR_com2_monitor = C90DR_avionics_com2_audio_switch_pos_pilot
        if C90DR_avionics_mic_sel_dial_pos_pilot == 0 then
            simCMD_xmit_audio_com1_man:once()
        elseif C90DR_avionics_mic_sel_dial_pos_pilot == 1 then
            simCMD_xmit_audio_com2_man:once()
        end
    elseif C90DR_avionics_auto_comm_switch_pos_pilot == 1 then
        if C90DR_avionics_mic_sel_dial_pos_pilot == 0 then
            simCMD_xmit_audio_com1_man:once()
            simDR_com1_monitor = 1
            simDR_com2_monitor = C90DR_avionics_com2_audio_switch_pos_pilot
        elseif C90DR_avionics_mic_sel_dial_pos_pilot == 1 then
            simCMD_xmit_audio_com2_man:once()
            simDR_com2_monitor = 1
            simDR_com1_monitor = C90DR_avionics_com1_audio_switch_pos_pilot
        else
            simDR_com1_monitor = 0
            simDR_com2_monitor = 0
        end
    end
    stop_timer(autocomm)
end

----- LATERAL DEVIATION DISPLAY STATUS FOR EADI GENERIC INSTRUMENT ----------------------
function C90_radio_lat_dev_type()                               -- IBAV8N, May16-22, added GPS capability for lateral deviation bug on EADI.
	C90DR_avionics_lat_dev_display_status = 0
	if simDR_hsi_display_horizontal == 1 then                   -- HORIZONTAL SIGNAL IS BEING RECEIVED
		if simDR_hsi_source_sel_pilot == 0 then                 -- NAV 1
			if C90.avionics.vor_avail == 1 then                 -- VOR
				C90DR_avionics_lat_dev_display_status = 1
			elseif C90.avionics.loc_avail == 1 then             -- LOC
				C90DR_avionics_lat_dev_display_status = 2
			end
		elseif simDR_hsi_source_sel_pilot == 2 then             -- GPS
		    C90DR_avionics_lat_dev_display_status = 3
		end
	end
end

----- RADIO ALTITUDE --------------------------------------------------------------------
function C90_radio_altitude()
	if simDR_radio_altitude_ft <= 1000 then
		C90DR_avionics_radio_altitude = C90_rndToIncr(simDR_radio_altitude_ft, 10)
	elseif simDR_radio_altitude_ft > 1000 then
		C90DR_avionics_radio_altitude = C90_rndToIncr(simDR_radio_altitude_ft, 50)
	end

end

----- EHSI COURSE SELECT ----------------------------------------------------------------       IBAV8N, May2-22, Continuously updates avail nav, radio CDI Sept5-23 polishing
function C90_EHSI_course_select()
    C90.avionics.vor_avail  = C90_ternary(simDR_radio_nav1_type == 4, 1, 0)
    C90.avionics.loc_avail = C90_ternary(simDR_radio_nav1_type == 8 or simDR_radio_nav1_type == 16 or simDR_radio_nav1_type == 40, 1, 0)
	if C90DR_avionics_crs_sel_cycle_active == 0 then                                                            -- DO NOT ALLOW IF A SOURCE SELECTION IS IN PROCESS
        if simDR_hsi_source_sel_pilot == 0 then                                                                 -- HSI SOURCE IS RADIO
            if C90DR_avionics_cur_crs_sel_index < 3 then                                                        -- RADIO SOURCE IS ACTIVELY RADIO AND NOT GPS
				if C90.avionics.vor_avail == 1 then                                                             -- IF AVAILABLE NAV TYPE IS VOR
					C90DR_avionics_cur_crs_sel_index = 1                                                        -- SET COURSE TO VOR
				elseif C90.avionics.loc_avail == 1 then                                                         -- IF AVAILABLE NAV TYPE IS LOC
					C90DR_avionics_cur_crs_sel_index = 2                                                        -- SET COURSE TO LOC
                    if C90DR_avionics_crs_sensor_sel_dial_pos == 1 then                                         -- IF NOT IN PRE MODE
                        if C90DR_avionics_EFIS_pre_loc_active == 1 then                                         -- BUT PRE LOC IS ACTIVE      
				            simDR_nav1_obs_degm = C90DR_avionics_EFIS_pre_loc_crs                               -- ACTIVE PILOTS OBS TAKES ON PRE LOC COURSE
				            simDR_hsi_source_sel_pilot = 0                                                      -- NAV SOURCE SET TO RADIO LOC
                            C90DR_avionics_EFIS_pre_loc_active = 0                                              -- PRE LOC NO LONGER ACTIVE
				            C90DR_avionics_EFIS_pre_loc_dsply = 0                                               -- PRE LOC NO LONGER VISIBLE
                        end
                    end
				elseif C90DR_avionics_cur_crs_sel_index > 0 then                                                -- IF TUNED RADIO FREQ HAS NO SIGNAL
                    C90DR_avionics_cur_crs_sel_index = 0                                                        -- REVERT TO NO RADIO SOURCE
				end
            end
        elseif simDR_hsi_source_sel_pilot == 2 then                                                             -- HSI SOURCE IS GPS
            if simDR_gps530_power ~= 1 then                                                                     -- IF GPS LOSES/HAS NO POWER
                simDR_hsi_source_sel_pilot = 0                                                                  -- RESET SOURCE TO RADIOS
                C90DR_avionics_cur_crs_sel_index = 0                                                            -- RESET THE SELECT AVAIL PROCESS
            end
		end
	end
    if simDR_hsi_source_sel_pilot == 2 then                                                                     -- IF IN GPS MODE AND PRE ARROW IS DISPLAYED, SIMULATE CDI FOR RADIO
        local compass
        if C90.avionics.gps_crs_sel == 0 then                                                                   -- IBAV8N, Sept3-23, SUSPEND IF THE CRS-SEL BUTTON IS BEING PRESSED, FOR CDI CENTERING
            if (C90DR_avionics_EFIS_pre_crs_cycle_index == 0 and C90DR_avionics_EFIS_pre_loc_dsply == 1) or     -- IF IN RADIO LOC AND PRE LOC DISPLAYED
                (C90DR_avionics_EFIS_pre_crs_cycle_index == 1 and C90DR_avionics_EFIS_pre_vor_dsply == 1) then  -- OR IN RADIO VOR AND PRE VOR DISPLAYED
                if C90.avionics.vor_avail == 1 then                                                             -- VOR FREQ IS TUNED
                    compass = C90_compass(simDR_radio_nav1_bearing_deg, simDR_radio_nav1_OBS_deg_co, 0)         -- DETERMINE DELTA OF NAV1 BRG AND OBS TO
                    if compass < 90 and compass > -90 then                                                      -- IF WITHIN 180 DEG OF TO
                        simDR_nav1_hdef_dot2 = C90_set_animation_position(simDR_nav1_hdef_dot2, 0.25 * compass, -2.5, 2.5, 1.5)
                    else                                                                                        -- IF FROM
                        compass = C90_compass(simDR_radio_nav1_bearing_deg, simDR_radio_nav1_OBS_deg_co, 180)   -- DETERMINE DELTA OF NAV1 BRG AND OBS FROM
                        simDR_nav1_hdef_dot2 = C90_set_animation_position(simDR_nav1_hdef_dot2, 0.25 * compass, -2.5, 2.5, 1.5)
                    end
                elseif C90.avionics.loc_avail == 1 then                                                         -- LOC FREQ IS TUNED
                    compass = C90_compass(simDR_radio_nav1_bearing_deg, simDR_nav1_course_deg_mag_pilot, 0)     -- ILS ONLY ALIGNS IF 'TO'
                    simDR_nav1_hdef_dot2 = C90_set_animation_position(simDR_nav1_hdef_dot2, compass, -2.5, 2.5, 1.5)
                end
            end
        end
    end
end

function C90_ttg_time()                     --IBAV8N, Feb26-21
    if C90DR_avionics_nav_data_sel_dial_pos == 2 then
        if is_ttg_running == 1 then
            if is_timer_scheduled(ttg_time_calc) == false then
                run_at_interval(ttg_time_calc, 0.25)
            end
        elseif is_ttg_running == 0 then
            if is_timer_scheduled(ttg_time_calc) == false then
                run_at_interval(ttg_time_calc, 0.05)
            end
        end
    else
        C90DR_avionics_EFIS_ttg_minutes = 0
        C90DR_avionics_EFIS_ttg_seconds = 0
        stop_timer(ttg_time_calc)
        is_ttg_running = 0
    end
end

function ttg_time_calc()
    if C90DR_avionics_cur_crs_sel_index < 3 then
        C90DR_avionics_EFIS_ttg_minutes = math.floor(simDR_nav1_dme_time_min)
        C90DR_avionics_EFIS_ttg_seconds = math.floor(math.fmod(simDR_nav1_dme_time_min, 1) * 60)
    else
        C90DR_avionics_EFIS_ttg_minutes = math.floor(simDR_gps_dme_time_min)
        C90DR_avionics_EFIS_ttg_seconds = math.floor(math.fmod(simDR_gps_dme_time_min, 1) * 60)
    end
    is_ttg_running = 1
    stop_timer(ttg_time_calc)
end

--GNS/GTN AVIONICS POWER
function GNS_GTN_avionics_power()
    --BATTERIES/AVIONICS ON
    simDR_battery_2 = (1 - C90DR_power) * C90DR_avionics_grd_pwr_comm_switch_pos        --GROUND COMM PWR
    simDR_battery_3 = math.max(
        C90_ternary((C90DR_power == 0 or C90DR_tpl_fed_bus_voltage < 18) and C90DR_avionics_EFIS_aux_pwr_on_switch_pos == 1, 1, 0),
        C90_ternary(C90DR_avionics_EFIS_aux_pwr_on_switch_pos == -1, 1, 0)              --aux batt test
        )
    simDR_avionics_power_on = math.max(C90_ternary(C90DR_avionics_grd_pwr_comm_switch_pos == 1 and C90DR_power == 0, 1, 0), math.max(simDR_battery_3, C90DR_power, C90.electrical.tpl_fed_hot) * C90DR_avionics_on_sw_pos)
    --DUMMY ADF
    simDR_adf2_power = simDR_adf1_power                                     --IBAV8N, Aug 21-22, the plane needs 2 adfs for the EFIS brg_ptr2 function to work correctly.
    simDR_adf2_frequency = simDR_adf_frequency                              --IBAV8N, Aug 21-22 """"
    --FLIGHT DIRECTOR - Reset FD for persistence IBAV8N, Nov16-23
    simDR_autopilot_fd_mode = (C90DR_avionics_EFIS_fd_switch_pos * simDR_avionics_power_on) + simDR_autopilot_servos_on
    --OVERHEAD POWER LOGIC
    local ovhd_power = math.max(C90DR_power, C90.electrical.gen_bus_L_hot) * C90DR_ovh_master --IBAV8N, Aug23-23, L gen powers instr lts
    local gen_L_overhead = ovhd_power * C90DR_gen_tie_L
    local gen_R_overhead = ovhd_power * C90DR_gen_tie_R
    simDR_wiper_speed = C90DR_power * C90_ternary(C90DR_wiper_knob_pos > 0, 1 + C90DR_wiper_knob_pos, 0)
    simDR_generic_lights_switch[0] = math.max(C90DR_power, C90.electrical.tpl_fed_hot) * C90DR_ovh_flood
    simDR_switch_panel_brightness_ratio[1] = C90.electrical.tpl_fed_hot * C90DR_ovh_indirect --IBAV8N, Aug23-23, tpl-fed bus
    simDR_switch_instr_brightness_ratio[2] = math.max(C90DR_ovh_emerg, gen_L_overhead * C90DR_ovh_pilot_flt)
    simDR_switch_instr_brightness_ratio[3] = math.max(C90DR_ovh_emerg, ovhd_power * C90DR_ovh_pilot_gyro)
    simDR_switch_instr_brightness_ratio[4] = math.max(C90DR_ovh_emerg, gen_L_overhead * C90DR_ovh_eng_instru)
    simDR_switch_instr_brightness_ratio[14] = math.max(C90DR_ovh_emerg, gen_L_overhead * C90DR_ovh_avion_pnl)
    simDR_switch_instr_brightness_ratio[6] = math.max(C90DR_ovh_emerg, gen_R_overhead * C90DR_ovh_sub_pnl)
    simDR_switch_instr_brightness_ratio[7] = math.max(C90DR_ovh_emerg, gen_R_overhead * C90DR_ovh_side_pnl)
    simDR_switch_instr_brightness_ratio[8] = math.max(C90DR_ovh_emerg, ovhd_power * C90DR_ovh_copilot_gyro)
    simDR_switch_instr_brightness_ratio[9] = math.max(C90DR_ovh_emerg, gen_L_overhead * C90DR_ovh_copilot_flt)
    --EFIS
    local efis_state = C90_ternary(C90DR_power == 1 or C90DR_tpl_fed_bus_voltage > 17.9 or simDR_battery_3 == 1, 1, 0) * simDR_avionics_power_on * C90DR_avionics_EFIS_power_switch_pos
    local eadi = efis_state * C90DR_avionics_EFIS_eadi_brightness
    local ehsi = efis_state * C90DR_avionics_EFIS_ehsi_brightness
    C90DR_avionics_decision_height_dial_pos = C90DR_avionics_decision_height_dial_pos * efis_state
	simDR_radio_alt_bug_ft_pilot = C90DR_avionics_decision_height_dial_pos
	C90DR_avionics_EFIS_dh = C90DR_avionics_decision_height_dial_pos
    if eadi == 0 then
        simDR_switch_instr_brightness_ratio[11] = 0
    elseif simDR_switch_instr_brightness_ratio[11] == 0 then
        if is_timer_scheduled(startup_eadi) == false then
            run_after_time(startup_eadi, 1)
        end
    else simDR_switch_instr_brightness_ratio[11] = eadi
    end
    if ehsi == 0 then
        simDR_switch_instr_brightness_ratio[12] = 0
    elseif simDR_switch_instr_brightness_ratio[12] == 0 then
        if is_timer_scheduled(startup_ehsi) == false then
            run_after_time(startup_ehsi, 1.75)
        end
    else simDR_switch_instr_brightness_ratio[12] = ehsi
    end
    --GNS
    if simDR_acf_descrip == "C90B EVO GNS" then
        --local gps530_power
        --local gps430_power
        gps530_power = math.max(C90DR_power, C90.electrical.gen_bus_L_hot) * simDR_avionics_power_on-- * C90DR_avionics_gps_power_switch_pos --IBAV8N, Aug23-23, gens power GNS
        gps430_power = math.max(C90DR_power, C90.electrical.gen_bus_R_hot) * simDR_avionics_power_on * C90DR_avionics_gps_power_switch_pos
        if simDR_gps530_power < gps530_power then
            if is_timer_scheduled(gps530) == false then
                run_after_time(gps530, 1)
            end
        else simDR_gps530_power = gps530_power
        end
        if simDR_gps430_power < gps430_power then
            if is_timer_scheduled(gps430) == false then
                run_after_time(gps430, 1.3)
            end
        else simDR_gps430_power = gps430_power
        end
    end
end

--G1000 AVIONICS POWER
function G1000_avionics_power()          --IMC SEPT10-23
    --BATTERIES/AVIONICS ON
    simDR_battery_2 = 0     --this plane doesn't have a groundcomm circuit; relies on PFD1 instead
    simDR_battery_3 = C90_ternary(C90DR_tpl_fed_bus_voltage < 10 and C90DR_avionics_EFIS_aux_pwr_on_switch_pos == 1, 1, 0) --standby on
    simDR_avionics_power_on = math.max(C90DR_power, C90.electrical.tpl_fed_hot) * C90DR_avionics_on_sw_pos
    --OVERHEAD POWER LOGIC
    local ovhd_power = math.max(C90DR_power, C90.electrical.gen_bus_L_hot) * C90DR_ovh_master                                                          --IBAV8N, Aug23-23, L gen powers instr lts
    simDR_wiper_speed = C90DR_power * C90_ternary(C90DR_wiper_knob_pos > 0, 1 + C90DR_wiper_knob_pos, 0)
    simDR_generic_lights_switch[0] = math.max(C90DR_power, C90.electrical.tpl_fed_hot) * C90DR_ovh_flood
    simDR_switch_panel_brightness_ratio[1] = C90.electrical.tpl_fed_hot * C90DR_ovh_indirect                                                           --IBAV8N, Aug23-23, tpl-fed bus
    simDR_switch_instr_brightness_ratio[2] = C90DR_ovh_pilot_flt                                                                        --Pilot's PFD
    simDR_switch_instr_brightness_ratio[3] = math.max(ovhd_power * math.max(C90DR_ovh_emerg, C90DR_ovh_pilot_gyro), simDR_battery_3)    --Standby instruments, just want TS lighting on emerg - looks silly otherwise.
    simDR_switch_instr_brightness_ratio[4] = C90DR_ovh_eng_instru                                                                       --MFD
    simDR_switch_instr_brightness_ratio[14] = math.max(C90DR_ovh_emerg, ovhd_power * C90DR_ovh_avion_pnl)                               --INOP
    simDR_switch_instr_brightness_ratio[6] = math.max(C90DR_ovh_emerg, ovhd_power * C90DR_gen_tie_R * C90DR_ovh_sub_pnl)                --Overhead and subpanels
    simDR_switch_instr_brightness_ratio[7] = math.max(C90DR_ovh_emerg, ovhd_power * C90DR_gen_tie_R * C90DR_ovh_side_pnl)               --Sidepanels
    simDR_switch_instr_brightness_ratio[8] = math.max(C90DR_ovh_emerg, ovhd_power * C90DR_ovh_copilot_gyro)                             --Clock lighting
    simDR_switch_instr_brightness_ratio[9] = C90DR_ovh_copilot_flt                                                                      --Copilot's PFD
    --C90DR_ovh_eng_instru = C90DR_ovh_pilot_flt                                                                                        --Special Use

    --ANTI-ICE FOR STANDBY INSTRUMENTS
    simDR_pitot_heat_on_standby = simDR_pitot_heat_right                                --IBAV8N, Oct10-23, would make the right switch standby,  but that could affect future PFD changes from LR
    simDR_static_heat_on_standby = simDR_pitot_heat_right                               --IBAV8N, Oct17-23
    --G1000 DISPLAYS ON/OFF
    imc_pfd2_on = C90_ternary(C90DR_tpl_fed_bus_voltage > 10, 1, 0)                     --pfd2 is supplied by the triple-fed bus #3
    imc_mfd_on = imc_pfd2_on                                                            --mfd is supplied by triple fed bus #2, same as pfd2
    imc_pfd1_on = C90_ternary((C90DR_ctr_bus_voltage > 10) or (imc_pfd2_on == 1), 1, 0) --pfd1 is supplied by the center bus and the triple-fed bus #1
    --RADIO PANEL AUDIO CONTROLS
    if simDR_avionics_power_on == 0 then                   --IBAV8N, Sept23-23, disable com1 tx @ pwr off, avionics off
        simDR_audio_com_selection   = 6
        simDR_audio_marker_enabled  = 1
        simDR_radio_marker_sens     = 1
        simDR_audio_selection_nav1  = 0
        simDR_audio_selection_nav2  = 0
        simDR_audio_dme_enabled	    = 0
        simDR_audio_selection_adf1  = 0
    end
    --STANDBY ALTIMETER
    imcDR_altitude_ft_stby_thous    = alt_thous(simDR_altitude_ft_stby)
    imcDR_altitude_ft_stby_hunds    = alt_hunds(simDR_altitude_ft_stby)
    imcDR_altitude_ft_stby_tens     = alt_tens(simDR_altitude_ft_stby)

    --GARMIN LIGHTING
    local triple_on = C90DR_tpl_fed_bus_voltage > 10

    function powered_device_light_level(power_source, level)      --IMC
        if power_source then return level else return 0 end
    end
    -- GFC710 - No1 triple fed  AP Panel
    imcDR_light_level_GFC710 = powered_device_light_level(triple_on == true, simDR_switch_instr_brightness_ratio[4])
    -- GCU479 - No3 triple fed  Keyboard
    imcDR_light_level_GCU479 = powered_device_light_level(triple_on == true, simDR_switch_instr_brightness_ratio[4])
    -- GMA1347's - No1 Avionics L&R Radio Panels
    imcDR_light_level_GMA1347_L = powered_device_light_level(simDR_avionics_power_on == 1, simDR_switch_instr_brightness_ratio[2])
    imcDR_light_level_GMA1347_R = powered_device_light_level(simDR_avionics_power_on == 1, simDR_switch_instr_brightness_ratio[9])
    -- PFD/MFD bezels - PFD1 Triple 1/Center PFD2 Triple 3 MFD Triple No2
    imcDR_light_level_PFD1 = powered_device_light_level(imc_pfd1_on == 1, simDR_switch_instr_brightness_ratio[2])
    imcDR_light_level_PFD2 = powered_device_light_level(imc_pfd2_on == 1, simDR_switch_instr_brightness_ratio[9])
    imcDR_light_level_MFD = powered_device_light_level(imc_mfd_on == 1, simDR_switch_instr_brightness_ratio[4])
end

-- BOOT/STARTUP SEQUENCE EFIS POWER
function startup_eadi()
	simDR_switch_instr_brightness_ratio[11] = C90DR_avionics_EFIS_eadi_brightness
end

function startup_ehsi()
	simDR_switch_instr_brightness_ratio[12] = C90DR_avionics_EFIS_ehsi_brightness
    C90_EFIS_map_mode()
end

-- BOOT/STARTUP SEQUENCE GNS POWER
function gps530() simDR_gps530_power = 1 end
function gps430() simDR_gps430_power = 1 end

-- CUSTOM ALTIMETER
function alt_thous(altimeter_ft)
    local thou_dec = math.floor(altimeter_ft%1000)/1000
    local thou_int = math.floor(math.floor(altimeter_ft%100000)/1000)
    return C90_ternary(thou_dec < 0.98, thou_int, thou_int + (thou_dec - 0.98) * 50)
end

function alt_hunds(altimeter_ft)
    local hund_dec = math.floor(altimeter_ft%100)/100
    local hund_int = math.floor(math.floor(altimeter_ft%1000)/100)
    return C90_ternary(hund_dec < 0.8, hund_int, hund_int + (hund_dec - 0.8) * 5)
end

function alt_tens(altimeter_ft)
    return math.floor(altimeter_ft%100 * 100) / 2000 + math.modf(alt_hunds(altimeter_ft)) % 2 * 5
end

