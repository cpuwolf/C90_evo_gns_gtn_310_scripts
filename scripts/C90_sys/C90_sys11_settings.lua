----- RESTORE SWITCH/DIAL SETTINGS
function restore_gns_settings()
    print("EVO: 18. Restoring GNS Switch and Dial Settings.")
    local running_start = C90_ternary(simDR_startup_running > 0, 16, 125)
    local LineVal = ""
	local load = io.open(C90.persistence, "r")
    if load then
		for i = 1, running_start do
			LineVal = load:read("*line")
            if i == 1 then
                if tonumber(LineVal) ~= C90.persistence_version then
                    print("EVO: 18a.  New persistence version detected, resetting preferences file.")
                    break
                end
            end
            if i == 2 then C90DR_ovh_flood = tonumber(LineVal) end
            if i == 3 then C90DR_ovh_indirect = tonumber(LineVal) end
            if i == 4 then C90DR_ovh_pilot_flt = tonumber(LineVal) end
            if i == 5 then C90DR_ovh_pilot_gyro = tonumber(LineVal) end
            if i == 6 then C90DR_ovh_eng_instru = tonumber(LineVal) end
            if i == 7 then C90DR_ovh_avion_pnl = tonumber(LineVal) end
            if i == 8 then C90DR_ovh_sub_pnl = tonumber(LineVal) end
            if i == 9 then C90DR_ovh_side_pnl = tonumber(LineVal) end
            if i == 10 then C90DR_ovh_copilot_gyro = tonumber(LineVal) end
            if i == 11 then C90DR_ovh_copilot_flt = tonumber(LineVal) end
	        if i == 12 then C90DR_pilot_shade_flip = tonumber(LineVal) end
	        if i == 13 then C90DR_copilot_shade_flip = tonumber(LineVal) end
            if i == 14 then C90DR_pilot_shade_slide = tonumber(LineVal) end
            if i == 15 then C90DR_copilot_shade_slide = tonumber(LineVal) end
            if i == 16 then simDR_avitab_enabled = tonumber(LineVal) end
            if i == 17 then simDR_avitab_power = tonumber(LineVal) end
            if i == 18 then C90DR_ovh_master = tonumber(LineVal) end
            if i == 19 then simDR_generic_lights_switch[4] = tonumber(LineVal) end                      --Bar light
            if i == 20 then C90DR_lighting_cabin_brt_dim_switch_pos = tonumber(LineVal) end             --Cabin light switch
            if i == 21 then simDR_generic_lights_switch[5] = tonumber(LineVal) end                      --Cabin lights
	        if i == 22 then C90DR_volt_bus_sel_dial = tonumber(LineVal) end
            if i == 23 then simDR_engine_antiice_left = tonumber(LineVal) end
	        if i == 24 then simDR_engine_antiice_right = tonumber(LineVal) end
            if i == 25 then C90DR_pneumatic_bleed_air_switch_pos_L = tonumber(LineVal) end
            if i == 26 then C90DR_pneumatic_bleed_air_switch_pos_R = tonumber(LineVal) end
            if i == 27 then simDR_pressure_cabin_alt_ft = tonumber(LineVal) end
            if i == 28 then C90DR_airCon_cabin_temp_dial = tonumber(LineVal) end
            if i == 29 then simDR_elevator_trim = tonumber(LineVal) end
            if i == 30 then simDR_fuel_quantity_l_wing = tonumber(LineVal) end
            if i == 31 then simDR_fuel_quantity_r_wing = tonumber(LineVal) end
            if i == 32 then simDR_fuel_quantity_l_nacelle = tonumber(LineVal) end
            if i == 33 then simDR_fuel_quantity_r_nacelle = tonumber(LineVal) end
            if i == 34 then simDR_fuel_firewall_vlv_L = tonumber(LineVal) end
            if i == 35 then simDR_fuel_firewall_vlv_R = tonumber(LineVal) end
            if i == 36 then C90DR_fuel_firewall_switch_guard_L = tonumber(LineVal) end
            if i == 37 then C90DR_fuel_firewall_switch_guard_R = tonumber(LineVal) end
            if i == 38 then C90DR_fltctrl_rudder_boost_switch_pos = tonumber(LineVal) end
            if i == 39 then C90DR_fltctrl_elev_trim_control_switch_pos = tonumber(LineVal) end
            if i == 40 then simDR_cabindoor = tonumber(LineVal) end
            if i == 41 then C90DR_imc_cockpit_divider_door = tonumber(LineVal) end  --all after 41 are model-specific
            if i == 42 then C90DR_avionics_auto_comm_switch_pos_pilot = tonumber(LineVal) end
            if i == 43 then C90DR_avionics_master_vol_ctrl_dial_pilot = tonumber(LineVal) end
            if i == 44 then C90DR_avionics_com1_audio_switch_pos_pilot = tonumber(LineVal) end
            if i == 45 then C90DR_avionics_com2_audio_switch_pos_pilot = tonumber(LineVal) end
            if i == 46 then simDR_audio_selection_nav1 = tonumber(LineVal) end
            if i == 47 then simDR_audio_selection_nav2 = tonumber(LineVal) end
            if i == 48 then C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot = tonumber(LineVal) end
            if i == 49 then C90DR_avionics_mkr_audio_bkn2_switch_pos_pilot = tonumber(LineVal) end
            if i == 50 then simDR_audio_dme_enabled = tonumber(LineVal) end
            if i == 51 then simDR_audio_selection_adf1 = tonumber(LineVal) end
            if i == 52 then C90DR_avionics_mic_sel_dial_pos_pilot = tonumber(LineVal) autocomm() end    --laminar/c90/avionics/dial/mic_sel_pos_pilot
            if i == 53 then C90DR_avionics_hot_intph_switch_pos = tonumber(LineVal) end
            if i == 54 then C90DR_avionics_dme_channel_sel_switch_pos = tonumber(LineVal) end
            if i == 55 then C90DR_avionics_encd_atim_sel_switch_pos = tonumber(LineVal) end
            if i == 56 then C90DR_avionics_mkr_bkn_sense_switch_pos = tonumber(LineVal) end
            if i == 57 then C90DR_avionics_gps_power_switch_pos = tonumber(LineVal) end
            if i == 58 then C90DR_avionics_paging_vol_dial = tonumber(LineVal) end
            if i == 59 then C90DR_avionics_interphone_vol_dial = tonumber(LineVal) end
            if i == 60 then C90DR_avionics_dme_vol_dial = tonumber(LineVal) end
            if i == 61 then C90DR_avionics_mkr_bkn_vol_dial = tonumber(LineVal) end
            if i == 62 then C90DR_avionics_nav_data_sel_dial_pos = tonumber(LineVal) end
            if i == 63 then C90DR_avionics_EFIS_map_mode_sel_dial_pos = tonumber(LineVal) end
            if i == 64 then C90DR_avionics_crs_sensor_sel_dial_pos = tonumber(LineVal) end
            if i == 65 then C90DR_autopilot_altSel100_switch_pos = tonumber(LineVal) end
            if i == 66 then C90DR_avionics_ind42_power_switch_pos = tonumber(LineVal) end
            if i == 67 then C90DR_avionics_ind42_mode = tonumber(LineVal) end
            if i == 68 then C90DR_avionics_ind42_channel = tonumber(LineVal) end
            if i == 69 then simDR_transponder_power = tonumber(LineVal) end
            if i == 70 then C90DR_avionics_adf1_vol_control_dial = tonumber(LineVal) end
            if i == 71 then C90DR_avionics_EFIS_eadi_brightness = tonumber(LineVal) end
            if i == 72 then C90DR_avionics_EFIS_ehsi_brightness = tonumber(LineVal) end
            if i == 73 then C90DR_avionics_EFIS_fd_switch_pos = tonumber(LineVal) end
            if i == 74 then C90DR_avionics_EFIS_power_switch_pos = tonumber(LineVal) end
            if i == 75 then simDR_RMI_left_use_adf = tonumber(LineVal) end
            if i == 76 then simDR_RMI_right_use_adf = tonumber(LineVal) end
            if i == 77 then simDR_barometer_setting_in_hg_pilot = tonumber(LineVal) end
            if i == 78 then simDR_barometer_setting_in_hg_copilot = tonumber(LineVal) end
            if i == 79 then simDR_autopilot_alt_dial_ft = tonumber(LineVal) end
            if i == 80 then simDR_ehsi_range = tonumber(LineVal) end
            if i == 81 then C90DR_avionics_EFIS_rev_mode_switch_pos = tonumber(LineVal) end
            if i == 82 then simDR_com1_power = tonumber(LineVal) end        --GNS and GTN part ways here
            if i == 83 then simDR_com2_power = tonumber(LineVal) end
            if i == 84 then simDR_nav1_power = tonumber(LineVal) end
            if i == 85 then simDR_nav2_power = tonumber(LineVal) end
            if i == 86 then simDR_adf1_power = tonumber(LineVal) end
            if i == 87 then C90DR_avionics_com1_vol_control_dial = tonumber(LineVal) end
            if i == 88 then C90DR_avionics_com2_vol_control_dial = tonumber(LineVal) end
            if i == 89 then C90DR_avionics_nav1_vol_control_dial = tonumber(LineVal) end
            if i == 90 then C90DR_avionics_nav2_vol_control_dial = tonumber(LineVal) end
            if i == 91 then simDR_com1_frequency = tonumber(LineVal) end
            if i == 92 then simDR_com1_stby_frequency = tonumber(LineVal) end
            if i == 93 then C90.avionics.ctl22_com1_sto_stack[1] = tonumber(LineVal) end
            if i == 94 then C90.avionics.ctl22_com1_sto_stack[2] = tonumber(LineVal) end
            if i == 95 then C90.avionics.ctl22_com1_sto_stack[3] = tonumber(LineVal) end
            if i == 96 then C90.avionics.ctl22_com1_sto_stack[4] = tonumber(LineVal) end
            if i == 97 then C90.avionics.ctl22_com1_sto_stack[5] = tonumber(LineVal) end
            if i == 98 then C90.avionics.ctl22_com1_sto_stack[6] = tonumber(LineVal) end
            if i == 99 then simDR_com2_frequency = tonumber(LineVal) end
            if i == 100 then simDR_com2_stby_frequency = tonumber(LineVal) end
            if i == 101 then C90.avionics.ctl22_com2_sto_stack[1] = tonumber(LineVal) end
            if i == 102 then C90.avionics.ctl22_com2_sto_stack[2] = tonumber(LineVal) end
            if i == 103 then C90.avionics.ctl22_com2_sto_stack[3] = tonumber(LineVal) end
            if i == 104 then C90.avionics.ctl22_com2_sto_stack[4] = tonumber(LineVal) end
            if i == 105 then C90.avionics.ctl22_com2_sto_stack[5] = tonumber(LineVal) end
            if i == 106 then C90.avionics.ctl22_com2_sto_stack[6] = tonumber(LineVal) end
            if i == 107 then simDR_nav1_frequency = tonumber(LineVal) end
            if i == 108 then simDR_nav1_stby_frequency = tonumber(LineVal) end
            if i == 109 then C90.avionics.ctl32_nav1_sto_stack[1] = tonumber(LineVal) end
            if i == 110 then C90.avionics.ctl32_nav1_sto_stack[2] = tonumber(LineVal) end
            if i == 111 then C90.avionics.ctl32_nav1_sto_stack[3] = tonumber(LineVal) end
            if i == 112 then C90.avionics.ctl32_nav1_sto_stack[4] = tonumber(LineVal) end
            if i == 113 then simDR_nav2_frequency = tonumber(LineVal) end
            if i == 114 then simDR_nav2_stby_frequency = tonumber(LineVal) end
            if i == 115 then C90.avionics.ctl32_nav2_sto_stack[1] = tonumber(LineVal) end
            if i == 116 then C90.avionics.ctl32_nav2_sto_stack[2] = tonumber(LineVal) end
            if i == 117 then C90.avionics.ctl32_nav2_sto_stack[3] = tonumber(LineVal) end
            if i == 118 then C90.avionics.ctl32_nav2_sto_stack[4] = tonumber(LineVal) end
            if i == 119 then simDR_adf_frequency = tonumber(LineVal) end
            if i == 120 then simDR_adf_stby_frequency = tonumber(LineVal) end
            if i == 121 then C90.avionics.ctl62_adf_sto_stack[1] = tonumber(LineVal) end
            if i == 122 then C90.avionics.ctl62_adf_sto_stack[2] = tonumber(LineVal) end
            if i == 123 then C90.avionics.ctl62_adf_sto_stack[3] = tonumber(LineVal) end
            if i == 124 then C90.avionics.ctl62_adf_sto_stack[4] = tonumber(LineVal) end
            if i == 125 then simDR_transponder_code = tonumber(LineVal) end
        end
    end
end

function gns_overrides()
    print("EVO: 19. Executing GNS overrides")
    run_at_interval(crossfill, 3)
    C90_EFIS_map_mode()
end
--[[
function restore_gtn_settings()
    print("EVO: 18. Restoring GTN Switch and Dial Settings.")
    local running_start = C90_ternary(simDR_startup_running > 0, 16, 85)
    local LineVal = ""
	local load = io.open(C90.persistence, "r")
    if load then
		for i = 1, running_start do
			LineVal = load:read("*line")
            if i == 1 then
                if tonumber(LineVal) ~= C90.persistence_version then
                    print("EVO: 18a.  New persistence version detected, resetting preferences file.")
                    break
                end
            end
            if i == 2 then C90DR_ovh_flood = tonumber(LineVal) end
            if i == 3 then C90DR_ovh_indirect = tonumber(LineVal) end
            if i == 4 then C90DR_ovh_pilot_flt = tonumber(LineVal) end
            if i == 5 then C90DR_ovh_pilot_gyro = tonumber(LineVal) end
            if i == 6 then C90DR_ovh_eng_instru = tonumber(LineVal) end
            if i == 7 then C90DR_ovh_avion_pnl = tonumber(LineVal) end
            if i == 8 then C90DR_ovh_sub_pnl = tonumber(LineVal) end
            if i == 9 then C90DR_ovh_side_pnl = tonumber(LineVal) end
            if i == 10 then C90DR_ovh_copilot_gyro = tonumber(LineVal) end
            if i == 11 then C90DR_ovh_copilot_flt = tonumber(LineVal) end
	        if i == 12 then C90DR_pilot_shade_flip = tonumber(LineVal) end
	        if i == 13 then C90DR_copilot_shade_flip = tonumber(LineVal) end
            if i == 14 then C90DR_pilot_shade_slide = tonumber(LineVal) end
            if i == 15 then C90DR_copilot_shade_slide = tonumber(LineVal) end
            if i == 16 then simDR_avitab_enabled = tonumber(LineVal) end
            if i == 17 then simDR_avitab_power = tonumber(LineVal) end
            if i == 18 then C90DR_ovh_master = tonumber(LineVal) end
            if i == 19 then simDR_generic_lights_switch[4] = tonumber(LineVal) end                      --Bar light
            if i == 20 then C90DR_lighting_cabin_brt_dim_switch_pos = tonumber(LineVal) end             --Cabin light switch
            if i == 21 then simDR_generic_lights_switch[5] = tonumber(LineVal) end                      --Cabin lights
	        if i == 22 then C90DR_volt_bus_sel_dial = tonumber(LineVal) end
            if i == 23 then simDR_engine_antiice_left = tonumber(LineVal) end
	        if i == 24 then simDR_engine_antiice_right = tonumber(LineVal) end
            if i == 25 then C90DR_pneumatic_bleed_air_switch_pos_L = tonumber(LineVal) end
            if i == 26 then C90DR_pneumatic_bleed_air_switch_pos_R = tonumber(LineVal) end
            if i == 27 then simDR_pressure_cabin_alt_ft = tonumber(LineVal) end
            if i == 28 then C90DR_airCon_cabin_temp_dial = tonumber(LineVal) end
            if i == 29 then simDR_elevator_trim = tonumber(LineVal) end
            if i == 30 then simDR_fuel_quantity_l_wing = tonumber(LineVal) end
            if i == 31 then simDR_fuel_quantity_r_wing = tonumber(LineVal) end
            if i == 32 then simDR_fuel_quantity_l_nacelle = tonumber(LineVal) end
            if i == 33 then simDR_fuel_quantity_r_nacelle = tonumber(LineVal) end
            if i == 34 then simDR_fuel_firewall_vlv_L = tonumber(LineVal) end
            if i == 35 then simDR_fuel_firewall_vlv_R = tonumber(LineVal) end
            if i == 36 then C90DR_fuel_firewall_switch_guard_L = tonumber(LineVal) end
            if i == 37 then C90DR_fuel_firewall_switch_guard_R = tonumber(LineVal) end
            if i == 38 then C90DR_fltctrl_rudder_boost_switch_pos = tonumber(LineVal) end
            if i == 39 then C90DR_fltctrl_elev_trim_control_switch_pos = tonumber(LineVal) end
            if i == 40 then simDR_cabindoor = tonumber(LineVal) end
            if i == 41 then C90DR_imc_cockpit_divider_door = tonumber(LineVal) end  --all after 41 are model-specific
            if i == 42 then C90DR_avionics_auto_comm_switch_pos_pilot = tonumber(LineVal) end
            if i == 43 then C90DR_avionics_master_vol_ctrl_dial_pilot = tonumber(LineVal) end
            if i == 44 then C90DR_avionics_com1_audio_switch_pos_pilot = tonumber(LineVal) end
            if i == 45 then C90DR_avionics_com2_audio_switch_pos_pilot = tonumber(LineVal) end
            if i == 46 then simDR_audio_selection_nav1 = tonumber(LineVal) end
            if i == 47 then simDR_audio_selection_nav2 = tonumber(LineVal) end
            if i == 48 then C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot = tonumber(LineVal) end
            if i == 49 then C90DR_avionics_mkr_audio_bkn2_switch_pos_pilot = tonumber(LineVal) end
            if i == 50 then simDR_audio_dme_enabled = tonumber(LineVal) end
            if i == 51 then simDR_audio_selection_adf1 = tonumber(LineVal) end
            if i == 52 then C90DR_avionics_mic_sel_dial_pos_pilot = tonumber(LineVal) autocomm() end    --laminar/c90/avionics/dial/mic_sel_pos_pilot
            if i == 53 then C90DR_avionics_hot_intph_switch_pos = tonumber(LineVal) end
            if i == 54 then C90DR_avionics_dme_channel_sel_switch_pos = tonumber(LineVal) end
            if i == 55 then C90DR_avionics_encd_atim_sel_switch_pos = tonumber(LineVal) end
            if i == 56 then C90DR_avionics_mkr_bkn_sense_switch_pos = tonumber(LineVal) end
            if i == 57 then C90DR_avionics_gps_power_switch_pos = tonumber(LineVal) end
            if i == 58 then C90DR_avionics_paging_vol_dial = tonumber(LineVal) end
            if i == 59 then C90DR_avionics_interphone_vol_dial = tonumber(LineVal) end
            if i == 60 then C90DR_avionics_dme_vol_dial = tonumber(LineVal) end
            if i == 61 then C90DR_avionics_mkr_bkn_vol_dial = tonumber(LineVal) end
            if i == 62 then C90DR_avionics_nav_data_sel_dial_pos = tonumber(LineVal) end
            if i == 63 then C90DR_avionics_EFIS_map_mode_sel_dial_pos = tonumber(LineVal) end
            if i == 64 then C90DR_avionics_crs_sensor_sel_dial_pos = tonumber(LineVal) end
            if i == 65 then C90DR_autopilot_altSel100_switch_pos = tonumber(LineVal) end
            if i == 66 then C90DR_avionics_ind42_power_switch_pos = tonumber(LineVal) end
            if i == 67 then C90DR_avionics_ind42_mode = tonumber(LineVal) end
            if i == 68 then C90DR_avionics_ind42_channel = tonumber(LineVal) end
            if i == 69 then simDR_transponder_power = tonumber(LineVal) end
            if i == 70 then C90DR_avionics_adf1_vol_control_dial = tonumber(LineVal) end
            if i == 71 then C90DR_avionics_EFIS_eadi_brightness = tonumber(LineVal) end
            if i == 72 then C90DR_avionics_EFIS_ehsi_brightness = tonumber(LineVal) end
            if i == 73 then C90DR_avionics_EFIS_fd_switch_pos = tonumber(LineVal) end
            if i == 74 then C90DR_avionics_EFIS_power_switch_pos = tonumber(LineVal) end
            if i == 75 then simDR_RMI_left_use_adf = tonumber(LineVal) end
            if i == 76 then simDR_RMI_right_use_adf = tonumber(LineVal) end
            if i == 77 then simDR_barometer_setting_in_hg_pilot = tonumber(LineVal) end
            if i == 78 then simDR_barometer_setting_in_hg_copilot = tonumber(LineVal) end
            if i == 79 then simDR_autopilot_alt_dial_ft = tonumber(LineVal) end
            if i == 80 then simDR_ehsi_range = tonumber(LineVal) end
            if i == 81 then C90DR_avionics_EFIS_rev_mode_switch_pos = tonumber(LineVal) end
            if i == 82 then C90DR_avionics_gtn_volume[0] = tonumber(LineVal) end
            if i == 83 then C90DR_avionics_gtn_volume[1] = tonumber(LineVal) end
            if i == 84 then C90DR_avionics_gtn_sd_card_pos[0] = tonumber(LineVal) end
            if i == 85 then C90DR_avionics_gtn_sd_card_pos[1] = tonumber(LineVal) end
        end
    end
end

function gtn_overrides()
    print("EVO: 19. Executing GTN overrrides")
    simDR_com1_power = 1
    simDR_com2_power = 1
    simDR_nav1_power = 1
    simDR_nav2_power = 1
    simDR_adf1_power = 2
    simDR_adf2_power = 2
    simDR_gps530_power = 1
    simDR_gps430_power = 1
    run_at_interval(C90_gtn_brightness, 60)
    C90_EFIS_map_mode()
end
--]]
function restore_g1000_settings()
    print("EVO: 18. Restoring G1000 Switch and Dial Settings.")
    local running_start = C90_ternary(simDR_startup_running > 0, 16, 44)
    local LineVal = ""
	local load = io.open(C90.persistence, "r")
    if load then
		for i = 1, running_start do
			LineVal = load:read("*line")
            if i == 1 then
                if tonumber(LineVal) ~= C90.persistence_version then
                    print("EVO: 18a.  New persistence version detected, resetting preferences file.")
                    break
                end
            end
            if i == 2 then C90DR_ovh_flood = tonumber(LineVal) end
            if i == 3 then C90DR_ovh_indirect = tonumber(LineVal) end
            if i == 4 then C90DR_ovh_pilot_flt = tonumber(LineVal) end
            if i == 5 then C90DR_ovh_pilot_gyro = tonumber(LineVal) end
            if i == 6 then C90DR_ovh_eng_instru = tonumber(LineVal) end
            if i == 7 then C90DR_ovh_avion_pnl = tonumber(LineVal) end
            if i == 8 then C90DR_ovh_sub_pnl = tonumber(LineVal) end
            if i == 9 then C90DR_ovh_side_pnl = tonumber(LineVal) end
            if i == 10 then C90DR_ovh_copilot_gyro = tonumber(LineVal) end
            if i == 11 then C90DR_ovh_copilot_flt = tonumber(LineVal) end
	        if i == 12 then C90DR_pilot_shade_flip = tonumber(LineVal) end
	        if i == 13 then C90DR_copilot_shade_flip = tonumber(LineVal) end
            if i == 14 then C90DR_pilot_shade_slide = tonumber(LineVal) end
            if i == 15 then C90DR_copilot_shade_slide = tonumber(LineVal) end
            if i == 16 then simDR_avitab_enabled = tonumber(LineVal) end
            if i == 17 then simDR_avitab_power = tonumber(LineVal) end
            if i == 18 then C90DR_ovh_master = tonumber(LineVal) end
            if i == 19 then simDR_generic_lights_switch[4] = tonumber(LineVal) end                      --Bar light
            if i == 20 then C90DR_lighting_cabin_brt_dim_switch_pos = tonumber(LineVal) end             --Cabin light switch
            if i == 21 then simDR_generic_lights_switch[5] = tonumber(LineVal) end                      --Cabin lights
	        if i == 22 then C90DR_volt_bus_sel_dial = tonumber(LineVal) end
            if i == 23 then simDR_engine_antiice_left = tonumber(LineVal) end
	        if i == 24 then simDR_engine_antiice_right = tonumber(LineVal) end
            if i == 25 then C90DR_pneumatic_bleed_air_switch_pos_L = tonumber(LineVal) end
            if i == 26 then C90DR_pneumatic_bleed_air_switch_pos_R = tonumber(LineVal) end
            if i == 27 then simDR_pressure_cabin_alt_ft = tonumber(LineVal) end
            if i == 28 then C90DR_airCon_cabin_temp_dial = tonumber(LineVal) end
            if i == 29 then simDR_elevator_trim = tonumber(LineVal) end
            if i == 30 then simDR_fuel_quantity_l_wing = tonumber(LineVal) end
            if i == 31 then simDR_fuel_quantity_r_wing = tonumber(LineVal) end
            if i == 32 then simDR_fuel_quantity_l_nacelle = tonumber(LineVal) end
            if i == 33 then simDR_fuel_quantity_r_nacelle = tonumber(LineVal) end
            if i == 34 then simDR_fuel_firewall_vlv_L = tonumber(LineVal) end
            if i == 35 then simDR_fuel_firewall_vlv_R = tonumber(LineVal) end
            if i == 36 then C90DR_fuel_firewall_switch_guard_L = tonumber(LineVal) end
            if i == 37 then C90DR_fuel_firewall_switch_guard_R = tonumber(LineVal) end
            if i == 38 then C90DR_fltctrl_rudder_boost_switch_pos = tonumber(LineVal) end
            if i == 39 then C90DR_fltctrl_elev_trim_control_switch_pos = tonumber(LineVal) end
            if i == 40 then simDR_cabindoor = tonumber(LineVal) end
            if i == 41 then C90DR_imc_cockpit_divider_door = tonumber(LineVal) end  --all after 41 are model-specific
            if i == 42 then simDR_artificial_horizon_adjust_stby = tonumber(LineVal) end
            if i == 43 then simDR_barometer_setting_in_hg_stby = tonumber(LineVal) end
            if i == 44 then restore_levers = tonumber(LineVal) end
        end
    end
end

function g1000_overrides()
    print("EVO: 19. Executing G1000 overrides")
    simDR_kill_G1000_engine = 1
    simDR_audio_selection_adf2_copilot = 1
    if restore_levers == nil then restore_levers = 0 end
end

----- SAVE SWITCH/DIAL SETTINGS
function save_gns_settings()
    print("EVO: 21. Saving GNS Switch and Dial Settings.")
	local save = io.open(C90.persistence, "w")
	if save then
		save:write(C90.persistence_version.."\n")                           --LINE 1:   Lua version
		save:write(C90DR_ovh_flood.."\n")                                   --LINE 2:   Overhead flood
        save:write(C90DR_ovh_indirect.."\n")                                --LINE 3:   Panel indirect lights
        save:write(C90DR_ovh_pilot_flt.."\n")                               --LINE 4:   Pilot flight lights
        save:write(C90DR_ovh_pilot_gyro.."\n")                              --LINE 5:   Pilot gyro lights
        save:write(C90DR_ovh_eng_instru.."\n")                              --LINE 6:   Engine lights
        save:write(C90DR_ovh_avion_pnl.."\n")                               --LINE 7:   Avionics panel lights
        save:write(C90DR_ovh_sub_pnl.."\n")                                 --LINE 8:   Subpanel lights
        save:write(C90DR_ovh_side_pnl.."\n")                                --LINE 9:   Sidepanel lights
        save:write(C90DR_ovh_copilot_gyro.."\n")                            --LINE 10:  Copilot's gyro lights
        save:write(C90DR_ovh_copilot_flt.."\n")                             --LINE 11:  Copilot's flight lights
		save:write(C90DR_pilot_shade_flip.."\n")                            --LINE 12:  Pilot's shade
		save:write(C90DR_copilot_shade_flip.."\n")                          --LINE 13:  Copilot's shade
		save:write(C90DR_pilot_shade_slide.."\n")                           --LINE 14:  Horizontal sunshade position pilot
		save:write(C90DR_copilot_shade_slide.."\n")                         --LINE 15:  Horizontal sunshade position copilot
		save:write(C90.avitab_enable.."\n")                                 --LINE 16:  Avitab yoke-mounted
        save:write(C90.avitab_on.."\n")                                     --LINE 17:  Avitab power
        save:write(C90DR_ovh_master.."\n")                                  --LINE 18:  Overhead master lights
        save:write(simDR_generic_lights_switch[4].."\n")                    --LINE 19:  Bar light
        save:write(C90DR_lighting_cabin_brt_dim_switch_pos.."\n")           --LINE 20:  Cabin light switch
        save:write(simDR_generic_lights_switch[5].."\n")                    --LINE 21:  Cabin lights
        save:write(C90DR_volt_bus_sel_dial.."\n")                           --LINE 22:  Overhead voltage select dial
        save:write(simDR_engine_antiice_left.."\n")                         --LINE 23:  Left engine anti-ice
        save:write(simDR_engine_antiice_right.."\n")                        --LINE 24:  Right engine anti-ice
		save:write(C90DR_pneumatic_bleed_air_switch_pos_L.."\n")            --LINE 25:  Left bleed
		save:write(C90DR_pneumatic_bleed_air_switch_pos_R.."\n")            --LINE 26:  Right bleed
		save:write(simDR_pressure_cabin_alt_ft.."\n")                       --LINE 27:  Cabin pressure setting
        save:write(C90DR_airCon_cabin_temp_dial.."\n")                      --LINE 28:  Cabin temperature knob degree setting
        save:write(simDR_elevator_trim.."\n")                               --LINE 29:  Elevator trim
        save:write(simDR_fuel_quantity_l_wing.."\n")                        --LINE 30:  Fuel L wing
        save:write(simDR_fuel_quantity_r_wing.."\n")                        --LINE 31:  Fuel R wing
        save:write(simDR_fuel_quantity_l_nacelle.."\n")                     --LINE 32:  Fuel L nacelle
        save:write(simDR_fuel_quantity_r_nacelle.."\n")                     --LINE 33:  Fuel R nacelle
        save:write(simDR_fuel_firewall_vlv_L.."\n")                         --LINE 34:  Left firewall valve
        save:write(simDR_fuel_firewall_vlv_R.."\n")                         --LINE 35:  Right firewall valve
        save:write(C90DR_fuel_firewall_switch_guard_L.."\n")                --LINE 36:  Left firewall guard
        save:write(C90DR_fuel_firewall_switch_guard_R.."\n")                --LINE 37:  Right firewall guard
		save:write(C90DR_fltctrl_rudder_boost_switch_pos.."\n")             --LINE 38:  rudder boost
		save:write(C90DR_fltctrl_elev_trim_control_switch_pos.."\n")        --LINE 39:  elevator trim
		save:write(simDR_cabindoor.."\n")                                   --LINE 40:  Cabin door
		save:write(C90DR_imc_cockpit_divider_door.."\n")                    --LINE 41:  cockpit door
        save:write(C90DR_avionics_auto_comm_switch_pos_pilot.."\n")         --LINE 42:  Autocomm switch
        save:write(C90DR_avionics_master_vol_ctrl_dial_pilot.."\n")         --LINE 43:  Radio master volume control
        save:write(C90DR_avionics_com1_audio_switch_pos_pilot.."\n")        --LINE 44:  COM1 monitor
        save:write(C90DR_avionics_com2_audio_switch_pos_pilot.."\n")        --LINE 45:  COM2 monitor
        save:write(simDR_audio_selection_nav1.."\n")                        --LINE 46:  NAV1 monitor
        save:write(simDR_audio_selection_nav2.."\n")                        --LINE 47:  NAV2 monitor
        save:write(C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot.."\n")    --LINE 48:  Marker beacon 1 monitor
        save:write(C90DR_avionics_mkr_audio_bkn2_switch_pos_pilot.."\n")    --LINE 49:  Marker beacon 2 monitor
        save:write(simDR_audio_dme_enabled.."\n")                           --LINE 50:  DME monitor
        save:write(simDR_audio_selection_adf1.."\n")                        --LINE 51:  ADF monitor
        save:write(C90DR_avionics_mic_sel_dial_pos_pilot.."\n")             --LINE 52:  Comm1 mic select dial
        save:write(C90DR_avionics_hot_intph_switch_pos.."\n")               --LINE 53:  Hot interphone
        save:write(C90DR_avionics_dme_channel_sel_switch_pos.."\n")         --LINE 54:  DME channel select
        save:write(C90DR_avionics_encd_atim_sel_switch_pos.."\n")           --LINE 55:  Encoder select
        save:write(C90DR_avionics_mkr_bkn_sense_switch_pos.."\n")           --LINE 56:  Marker beacon Hi-Lo select
		save:write(C90DR_avionics_gps_power_switch_pos.."\n")               --LINE 57:  GPS power
        save:write(C90DR_avionics_paging_vol_dial.."\n")                    --LINE 58:  Paging volume
        save:write(C90DR_avionics_interphone_vol_dial.."\n")                --LINE 59:  Interphone volume
        save:write(C90DR_avionics_dme_vol_dial.."\n")                       --LINE 60:  DME volume
        save:write(C90DR_avionics_mkr_bkn_vol_dial.."\n")                   --LINE 61:  Marker beacon volume
        save:write(C90DR_avionics_nav_data_sel_dial_pos.."\n")              --LINE 62:  Nav Data Select: GSP, Wind...
        save:write(C90DR_avionics_EFIS_map_mode_sel_dial_pos.."\n")         --LINE 63:  EFIS map mode
        save:write(C90DR_avionics_crs_sensor_sel_dial_pos.."\n")            --LINE 64:  PRE/ACT/XFR dial
        save:write(C90DR_autopilot_altSel100_switch_pos.."\n")              --LINE 65:  Alt select 1k knob position
	    save:write(C90DR_avionics_ind42_power_switch_pos.."\n")             --LINE 66:  IND-42 power
	    save:write(C90DR_avionics_ind42_mode.."\n")                         --LINE 67:  IND-42 mode
		save:write(C90DR_avionics_ind42_channel.."\n")                      --LINE 68:  IND-42 channel
		save:write(simDR_transponder_power.."\n")                           --LINE 69:  XPNDR power
		save:write(C90DR_avionics_adf1_vol_control_dial.."\n")              --LINE 70:  ADF volume
		save:write(C90DR_avionics_EFIS_eadi_brightness.."\n")               --LINE 71:  EADI brightness dial
		save:write(C90DR_avionics_EFIS_ehsi_brightness.."\n")               --LINE 72:  EHSI brightness dial
		save:write(C90DR_avionics_EFIS_fd_switch_pos.."\n")                 --LINE 73:  flight director
		save:write(C90DR_avionics_EFIS_power_switch_pos.."\n")              --LINE 74:  EFIS power
		save:write(simDR_RMI_left_use_adf.."\n")                            --LINE 75:  RMI left ADF
		save:write(simDR_RMI_right_use_adf.."\n")                           --LINE 76:  RMI right ADF
		save:write(simDR_barometer_setting_in_hg_pilot.."\n")               --LINE 77:  Pilot's altimeter
		save:write(simDR_barometer_setting_in_hg_copilot.."\n")             --LINE 78:  Copilot's altimeter
		save:write(simDR_autopilot_alt_dial_ft.."\n")                       --LINE 79:  Autopilot altitude
		save:write(simDR_ehsi_range.."\n")                                  --LINE 80:  EHSI range
		save:write(C90DR_avionics_EFIS_rev_mode_switch_pos.."\n")           --LINE 81:  EFIS rev mode
		save:write(simDR_com1_power.."\n")                                  --LINE 82:  COM1 power
		save:write(simDR_com2_power.."\n")                                  --LINE 83:  COM2 power
		save:write(simDR_nav1_power.."\n")                                  --LINE 84:  NAV1 power
		save:write(simDR_nav2_power.."\n")                                  --LINE 85:  NAV2 power
		save:write(simDR_adf1_power.."\n")                                  --LINE 86:  ADF1 power
		save:write(C90DR_avionics_com1_vol_control_dial.."\n")              --LINE 87:  COM1 volume
		save:write(C90DR_avionics_com2_vol_control_dial.."\n")              --LINE 88:  COM2 volume
		save:write(C90DR_avionics_nav1_vol_control_dial.."\n")              --LINE 89:  NAV1 volume
		save:write(C90DR_avionics_nav2_vol_control_dial.."\n")              --LINE 90:  NAV2 volume
		save:write(simDR_com1_frequency.."\n")                              --LINE 91:  COM1 FREQ
		save:write(simDR_com1_stby_frequency.."\n")                         --LINE 92:  COM1 STBY
		save:write(C90.avionics.ctl22_com1_sto_stack[1].."\n")              --LINE 93:  COM1 SAVE 1
		save:write(C90.avionics.ctl22_com1_sto_stack[2].."\n")              --LINE 94:  COM1 SAVE 2
		save:write(C90.avionics.ctl22_com1_sto_stack[3].."\n")              --LINE 95:  COM1 SAVE 3 
		save:write(C90.avionics.ctl22_com1_sto_stack[4].."\n")              --LINE 96:  COM1 SAVE 4 
		save:write(C90.avionics.ctl22_com1_sto_stack[5].."\n")              --LINE 97:  COM1 SAVE 5
		save:write(C90.avionics.ctl22_com1_sto_stack[6].."\n")              --LINE 98:  COM1 SAVE 6 
		save:write(simDR_com2_frequency.."\n")                              --LINE 99:  COM2 FREQ
		save:write(simDR_com2_stby_frequency.."\n")                         --LINE 100:  COM2 STBY
		save:write(C90.avionics.ctl22_com2_sto_stack[1].."\n")              --LINE 101:  COM2 SAVE 1
		save:write(C90.avionics.ctl22_com2_sto_stack[2].."\n")              --LINE 102:  COM2 SAVE 2 
		save:write(C90.avionics.ctl22_com2_sto_stack[3].."\n")              --LINE 103:  COM2 SAVE 3 
		save:write(C90.avionics.ctl22_com2_sto_stack[4].."\n")              --LINE 104:  COM2 SAVE 4 
		save:write(C90.avionics.ctl22_com2_sto_stack[5].."\n")              --LINE 105:  COM2 SAVE 5 
		save:write(C90.avionics.ctl22_com2_sto_stack[6].."\n")              --LINE 106:  COM2 SAVE 6 
		save:write(simDR_nav1_frequency.."\n")                              --LINE 107:  NAV1 FREQ
		save:write(simDR_nav1_stby_frequency.."\n")                         --LINE 108:  NAV1 STBY
		save:write(C90.avionics.ctl32_nav1_sto_stack[1].."\n")              --LINE 109:  NAV1 SAVE 1
		save:write(C90.avionics.ctl32_nav1_sto_stack[2].."\n")              --LINE 110:  NAV1 SAVE 2 
		save:write(C90.avionics.ctl32_nav1_sto_stack[3].."\n")              --LINE 111:  NAV1 SAVE 3 
		save:write(C90.avionics.ctl32_nav1_sto_stack[4].."\n")              --LINE 112:  NAV1 SAVE 4 
		save:write(simDR_nav2_frequency.."\n")                              --LINE 113:  NAV2 FREQ
		save:write(simDR_nav2_stby_frequency.."\n")                         --LINE 114:  NAV2 STBY
		save:write(C90.avionics.ctl32_nav2_sto_stack[1].."\n")              --LINE 115:  NAV2 SAVE 1 
		save:write(C90.avionics.ctl32_nav2_sto_stack[2].."\n")              --LINE 116:  NAV2 SAVE 2 
		save:write(C90.avionics.ctl32_nav2_sto_stack[3].."\n")              --LINE 117:  NAV2 SAVE 3 
		save:write(C90.avionics.ctl32_nav2_sto_stack[4].."\n")              --LINE 118:  NAV2 SAVE 4 
		save:write(simDR_adf_frequency.."\n")                               --LINE 119:  ADF FREQ
		save:write(simDR_adf_stby_frequency.."\n")                          --LINE 120:  ADF STBY
		save:write(C90.avionics.ctl62_adf_sto_stack[1].."\n")               --LINE 121:  ADF SAVE 1
		save:write(C90.avionics.ctl62_adf_sto_stack[2].."\n")               --LINE 122:  ADF SAVE 2 
		save:write(C90.avionics.ctl62_adf_sto_stack[3].."\n")               --LINE 123:  ADF SAVE 3 
		save:write(C90.avionics.ctl62_adf_sto_stack[4].."\n")               --LINE 124:  ADF SAVE 4
		save:write(simDR_transponder_code.."\n")                            --LINE 125:  XPDR CODE
		save:close()	--@pilotmarcog 4-01-2022 - fix log error io.close statement
    end
end
--[[
function save_gtn_settings()
    print("EVO: 21. Saving GTN Switch and Dial Settings.")
	local save = io.open(C90.persistence, "w")
	if save then
		save:write(C90.persistence_version.."\n")                           --LINE 1:   Lua version
		save:write(C90DR_ovh_flood.."\n")                                   --LINE 2:   Overhead flood
        save:write(C90DR_ovh_indirect.."\n")                                --LINE 3:   Panel indirect lights
        save:write(C90DR_ovh_pilot_flt.."\n")                               --LINE 4:   Pilot flight lights
        save:write(C90DR_ovh_pilot_gyro.."\n")                              --LINE 5:   Pilot gyro lights
        save:write(C90DR_ovh_eng_instru.."\n")                              --LINE 6:   Engine lights
        save:write(C90DR_ovh_avion_pnl.."\n")                               --LINE 7:   Avionics panel lights
        save:write(C90DR_ovh_sub_pnl.."\n")                                 --LINE 8:   Subpanel lights
        save:write(C90DR_ovh_side_pnl.."\n")                                --LINE 9:   Sidepanel lights
        save:write(C90DR_ovh_copilot_gyro.."\n")                            --LINE 10:   Copilot's gyro lights
        save:write(C90DR_ovh_copilot_flt.."\n")                             --LINE 11:  Copilot's flight lights
		save:write(C90DR_pilot_shade_flip.."\n")                            --LINE 12:  Pilot's shade
		save:write(C90DR_copilot_shade_flip.."\n")                          --LINE 13:  Copilot's shade
		save:write(C90DR_pilot_shade_slide.."\n")                           --LINE 14:  Horizontal sunshade position pilot
		save:write(C90DR_copilot_shade_slide.."\n")                         --LINE 15:  Horizontal sunshade position copilot
		save:write(C90.avitab_enable.."\n")                                 --LINE 16:  Avitab yoke-mounted
        save:write(C90.avitab_on.."\n")                                     --LINE 17:  Avitab power
        save:write(C90DR_ovh_master.."\n")                                  --LINE 18:  Overhead master lights
        save:write(simDR_generic_lights_switch[4].."\n")                    --LINE 19:  Bar light
        save:write(C90DR_lighting_cabin_brt_dim_switch_pos.."\n")           --LINE 20:  Cabin light switch
        save:write(simDR_generic_lights_switch[5].."\n")                    --LINE 21:  Cabin lights
        save:write(C90DR_volt_bus_sel_dial.."\n")                           --LINE 22:  Overhead voltage select dial
        save:write(simDR_engine_antiice_left.."\n")                         --LINE 23:  Left engine anti-ice
        save:write(simDR_engine_antiice_right.."\n")                        --LINE 24:  Right engine anti-ice
		save:write(C90DR_pneumatic_bleed_air_switch_pos_L.."\n")            --LINE 25:  Left bleed
		save:write(C90DR_pneumatic_bleed_air_switch_pos_R.."\n")            --LINE 26:  Right bleed
		save:write(simDR_pressure_cabin_alt_ft.."\n")                       --LINE 27:  Cabin pressure setting
        save:write(C90DR_airCon_cabin_temp_dial.."\n")                      --LINE 28:  Cabin temperature knob degree setting
        save:write(simDR_elevator_trim.."\n")                               --LINE 29:  Elevator trim
        save:write(simDR_fuel_quantity_l_wing.."\n")                        --LINE 30:  Fuel L wing
        save:write(simDR_fuel_quantity_r_wing.."\n")                        --LINE 31:  Fuel R wing
        save:write(simDR_fuel_quantity_l_nacelle.."\n")                     --LINE 32:  Fuel L nacelle
        save:write(simDR_fuel_quantity_r_nacelle.."\n")                     --LINE 33:  Fuel R nacelle
        save:write(simDR_fuel_firewall_vlv_L.."\n")                         --LINE 34:  Left firewall valve
        save:write(simDR_fuel_firewall_vlv_R.."\n")                         --LINE 35:  Right firewall valve
        save:write(C90DR_fuel_firewall_switch_guard_L.."\n")                --LINE 36:  Left firewall guard
        save:write(C90DR_fuel_firewall_switch_guard_R.."\n")                --LINE 37:  Right firewall guard
		save:write(C90DR_fltctrl_rudder_boost_switch_pos.."\n")             --LINE 38:  rudder boost
		save:write(C90DR_fltctrl_elev_trim_control_switch_pos.."\n")        --LINE 39:  elevator trim
		save:write(simDR_cabindoor.."\n")                                   --LINE 40:  Cabin door
		save:write(C90DR_imc_cockpit_divider_door.."\n")                    --LINE 41:  cockpit door
        save:write(C90DR_avionics_auto_comm_switch_pos_pilot.."\n")         --LINE 42:  Autocomm switch
        save:write(C90DR_avionics_master_vol_ctrl_dial_pilot.."\n")         --LINE 43:  Radio master volume control
        save:write(C90DR_avionics_com1_audio_switch_pos_pilot.."\n")        --LINE 44:  COM1 monitor
        save:write(C90DR_avionics_com2_audio_switch_pos_pilot.."\n")        --LINE 45:  COM2 monitor
        save:write(simDR_audio_selection_nav1.."\n")                        --LINE 46:  NAV1 monitor
        save:write(simDR_audio_selection_nav2.."\n")                        --LINE 47:  NAV2 monitor
        save:write(C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot.."\n")    --LINE 48:  Marker beacon 1 monitor
        save:write(C90DR_avionics_mkr_audio_bkn2_switch_pos_pilot.."\n")    --LINE 49:  Marker beacon 2 monitor
        save:write(simDR_audio_dme_enabled.."\n")                           --LINE 50:  DME monitor
        save:write(simDR_audio_selection_adf1.."\n")                        --LINE 51:  ADF monitor
        save:write(C90DR_avionics_mic_sel_dial_pos_pilot.."\n")             --LINE 52:  Comm1 mic select dial
        save:write(C90DR_avionics_hot_intph_switch_pos.."\n")               --LINE 53:  Hot interphone
        save:write(C90DR_avionics_dme_channel_sel_switch_pos.."\n")         --LINE 54:  DME channel select
        save:write(C90DR_avionics_encd_atim_sel_switch_pos.."\n")           --LINE 55:  Encoder select
        save:write(C90DR_avionics_mkr_bkn_sense_switch_pos.."\n")           --LINE 56:  Marker beacon Hi-Lo select
		save:write(C90DR_avionics_gps_power_switch_pos.."\n")               --LINE 57:  GPS power
        save:write(C90DR_avionics_paging_vol_dial.."\n")                    --LINE 58:  Paging volume
        save:write(C90DR_avionics_interphone_vol_dial.."\n")                --LINE 59:  Interphone volume
        save:write(C90DR_avionics_dme_vol_dial.."\n")                       --LINE 60:  DME volume
        save:write(C90DR_avionics_mkr_bkn_vol_dial.."\n")                   --LINE 61:  Marker beacon volume
        save:write(C90DR_avionics_nav_data_sel_dial_pos.."\n")              --LINE 62:  Nav Data Select: GSP, Wind...
        save:write(C90DR_avionics_EFIS_map_mode_sel_dial_pos.."\n")         --LINE 63:  EFIS map mode
        save:write(C90DR_avionics_crs_sensor_sel_dial_pos.."\n")            --LINE 64:  PRE/ACT/XFR dial
        save:write(C90DR_autopilot_altSel100_switch_pos.."\n")              --LINE 65:  Alt select 1k knob position
	    save:write(C90DR_avionics_ind42_power_switch_pos.."\n")             --LINE 66:  IND-42 power
	    save:write(C90DR_avionics_ind42_mode.."\n")                         --LINE 67:  IND-42 mode
		save:write(C90DR_avionics_ind42_channel.."\n")                      --LINE 68:  IND-42 channel
		save:write(simDR_transponder_power.."\n")                           --LINE 69:  XPNDR power
		save:write(C90DR_avionics_adf1_vol_control_dial.."\n")              --LINE 70:  ADF volume
		save:write(C90DR_avionics_EFIS_eadi_brightness.."\n")               --LINE 71:  EADI brightness dial
		save:write(C90DR_avionics_EFIS_ehsi_brightness.."\n")               --LINE 72:  EHSI brightness dial
		save:write(C90DR_avionics_EFIS_fd_switch_pos.."\n")                 --LINE 73:  flight director
		save:write(C90DR_avionics_EFIS_power_switch_pos.."\n")              --LINE 74:  EFIS power
		save:write(simDR_RMI_left_use_adf.."\n")                            --LINE 75:  RMI left ADF
		save:write(simDR_RMI_right_use_adf.."\n")                           --LINE 76:  RMI right ADF
		save:write(simDR_barometer_setting_in_hg_pilot.."\n")               --LINE 77:  Pilot's altimeter
		save:write(simDR_barometer_setting_in_hg_copilot.."\n")             --LINE 78:  Copilot's altimeter
		save:write(simDR_autopilot_alt_dial_ft.."\n")                       --LINE 79:  Autopilot altitude
		save:write(simDR_ehsi_range.."\n")                                  --LINE 80:  EHSI range
		save:write(C90DR_avionics_EFIS_rev_mode_switch_pos.."\n")           --LINE 81:  EFIS rev mode
        save:write(C90DR_avionics_gtn_volume[0].."\n")                      --LINE 82:  GTN left volume
        save:write(C90DR_avionics_gtn_volume[1].."\n")                      --LINE 83:  GTN right volume
        save:write(C90DR_avionics_gtn_sd_card_pos[0].."\n")                 --LINE 84:  ADF2 left SD
        save:write(C90DR_avionics_gtn_sd_card_pos[1].."\n")                 --LINE 85:  ADF2 right SD
		save:close()	--@pilotmarcog 4-01-2022 - fix log error io.close statement
    end
end
--]]
function save_g1000_settings()
    print("EVO: 21. Saving G1000 Switch and Dial Settings.")
	local save = io.open(C90.persistence, "w")
	if save then
		save:write(C90.persistence_version.."\n")                           --LINE 1:   Lua version
		save:write(C90DR_ovh_flood.."\n")                                   --LINE 2:   Overhead flood
        save:write(C90DR_ovh_indirect.."\n")                                --LINE 3:   Panel indirect lights
        save:write(C90DR_ovh_pilot_flt.."\n")                               --LINE 4:   Pilot flight lights
        save:write(C90DR_ovh_pilot_gyro.."\n")                              --LINE 5:   Pilot gyro lights
        save:write(C90DR_ovh_eng_instru.."\n")                              --LINE 6:   Engine lights
        save:write(C90DR_ovh_avion_pnl.."\n")                               --LINE 7:   Avionics panel lights
        save:write(C90DR_ovh_sub_pnl.."\n")                                 --LINE 8:   Subpanel lights
        save:write(C90DR_ovh_side_pnl.."\n")                                --LINE 9:   Sidepanel lights
        save:write(C90DR_ovh_copilot_gyro.."\n")                            --LINE 10:   Copilot's gyro lights
        save:write(C90DR_ovh_copilot_flt.."\n")                             --LINE 11:  Copilot's flight lights
		save:write(C90DR_pilot_shade_flip.."\n")                            --LINE 12:  Pilot's shade
		save:write(C90DR_copilot_shade_flip.."\n")                          --LINE 13:  Copilot's shade
		save:write(C90DR_pilot_shade_slide.."\n")                           --LINE 14:  Horizontal sunshade position pilot
		save:write(C90DR_copilot_shade_slide.."\n")                         --LINE 15:  Horizontal sunshade position copilot
		save:write(C90.avitab_enable.."\n")                                 --LINE 16:  Avitab yoke-mounted
        save:write(C90.avitab_on.."\n")                                     --LINE 17:  Avitab power
        save:write(C90DR_ovh_master.."\n")                                  --LINE 18:  Overhead master lights
        save:write(simDR_generic_lights_switch[4].."\n")                    --LINE 19:  Bar light
        save:write(C90DR_lighting_cabin_brt_dim_switch_pos.."\n")           --LINE 20:  Cabin light switch
        save:write(simDR_generic_lights_switch[5].."\n")                    --LINE 21:  Cabin lights
        save:write(C90DR_volt_bus_sel_dial.."\n")                           --LINE 22:  Overhead voltage select dial
        save:write(simDR_engine_antiice_left.."\n")                         --LINE 23:  Left engine anti-ice
        save:write(simDR_engine_antiice_right.."\n")                        --LINE 24:  Right engine anti-ice
		save:write(C90DR_pneumatic_bleed_air_switch_pos_L.."\n")            --LINE 25:  Left bleed
		save:write(C90DR_pneumatic_bleed_air_switch_pos_R.."\n")            --LINE 26:  Right bleed
		save:write(simDR_pressure_cabin_alt_ft.."\n")                       --LINE 27:  Cabin pressure setting
        save:write(C90DR_airCon_cabin_temp_dial.."\n")                      --LINE 28:  Cabin temperature knob degree setting
        save:write(simDR_elevator_trim.."\n")                               --LINE 29:  Elevator trim
        save:write(simDR_fuel_quantity_l_wing.."\n")                        --LINE 30:  Fuel L wing
        save:write(simDR_fuel_quantity_r_wing.."\n")                        --LINE 31:  Fuel R wing
        save:write(simDR_fuel_quantity_l_nacelle.."\n")                     --LINE 32:  Fuel L nacelle
        save:write(simDR_fuel_quantity_r_nacelle.."\n")                     --LINE 33:  Fuel R nacelle
        save:write(simDR_fuel_firewall_vlv_L.."\n")                         --LINE 34:  Left firewall valve
        save:write(simDR_fuel_firewall_vlv_R.."\n")                         --LINE 35:  Right firewall valve
        save:write(C90DR_fuel_firewall_switch_guard_L.."\n")                --LINE 36:  Left firewall guard
        save:write(C90DR_fuel_firewall_switch_guard_R.."\n")                --LINE 37:  Right firewall guard
		save:write(C90DR_fltctrl_rudder_boost_switch_pos.."\n")             --LINE 38:  rudder boost
		save:write(C90DR_fltctrl_elev_trim_control_switch_pos.."\n")        --LINE 39:  elevator trim
		save:write(simDR_cabindoor.."\n")                                   --LINE 40:  Cabin door
		save:write(C90DR_imc_cockpit_divider_door.."\n")                    --LINE 41:  cockpit door
        save:write(simDR_artificial_horizon_adjust_stby.."\n")              --LINE 42:  Standby horizon adjust
        save:write(simDR_barometer_setting_in_hg_stby.."\n")                --LINE 43:  Standby altimeter
        save:write(restore_levers.."\n")                                    --LINE 44:  return TQ levers setting
		save:close()	--@pilotmarcog 4-01-2022 - fix log error io.close statement
    end
end


