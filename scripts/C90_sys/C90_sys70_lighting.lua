
----- ANNUNCIATORS ---------------------------------------

function C90_lighting_annun()
    local test_on_buspwr = C90DR_electrical_annun_test_on * C90.electrical.tpl_fed_hot
	local dimMode = C90_ternary(
		(C90.electrical.gen_bus_L_hot == 1 or C90.electrical.gen_bus_R_hot == 1)    -- ANY GEN ON LINE
		and simDR_generic_lights_switch[0] < 0.1                            -- OVHD FLOOD LIGHT OFF
		and C90DR_ovh_master == 1                                           -- MASTER PANEL LIGHTS SWITCH IS ON
        and simDR_instr_brightness_ratio_man[2] > 0.4                       -- PILOT FLIGHT LIGHTS ON
		and simDR_photo_auto_atten < 0.4                                    -- AMBIENT LIGHT IS LOW
		, 0.5, 1)                                                         -- SET LEVEL (DIM, BRIGHT)
	local wca_lightLevel = C90.electrical.tpl_fed_hot * dimMode
    local ap_lightLevel = simDR_instr_brightness_ratio_man[15] * C90.electrical.ac_power
	local ind_lightLevel = simDR_instr_brightness_ratio_man[10] * C90DR_avionics_ind42_power_switch_pos
    function annun_lights(condition)      --IMC
        if condition > 0 then return wca_lightLevel
        else return test_on_buspwr
        end
    end
    function ap_lights(condition)      --IMC
        if condition > 0 then return condition * ap_lightLevel
        else return C90.autopilot.lamp_test * C90.electrical.ac_power
        end
    end
    -- WARNING, CAUTION, AND ADVISORY ANNUNCIATORS
    C90DR_lighting_annun_blank              = test_on_buspwr                                                       --IBAV8N, MaY22-22
    C90DR_lighting_annun_fuel_press_L 		= annun_lights(C90.warning.array[0])
    C90DR_lighting_annun_oil_press_L		= annun_lights(C90.warning.array[1])
    C90DR_lighting_annun_engine_fire_L		= annun_lights(C90.warning.array[2])
    C90DR_lighting_annun_inverter			= annun_lights(C90.warning.array[3])
    C90DR_lighting_annun_ap_fail			= annun_lights(C90.warning.array[4])
    C90DR_lighting_annun_ap_trim_fail		= annun_lights(C90.warning.array[5])
    C90DR_lighting_annun_cabin_alt_hi		= annun_lights(C90.warning.array[6])
    C90DR_lighting_annun_cabin_door			= annun_lights(C90.warning.array[7])
    C90DR_lighting_annun_bleed_air		    = annun_lights(C90.warning.array[8])
    C90DR_lighting_annun_engine_fire_R		= annun_lights(C90.warning.array[9])
    C90DR_lighting_annun_oil_press_R		= annun_lights(C90.warning.array[10])
    C90DR_lighting_annun_fuel_press_R		= annun_lights(C90.warning.array[11])
    --C90.warning.array 12 autopilot disconn only triggers warning light, no annunciator
    C90DR_lighting_annun_ext_power			= annun_lights(C90.caution.ext_power) --12.08 gives us a deliverable GPU in ground services.
    C90DR_lighting_annun_dc_gen_L			= annun_lights(C90.caution.array[0])
    C90DR_lighting_annun_no_fuel_xfr_L		= annun_lights(C90.caution.array[1])
    C90DR_lighting_annun_rvs_not_ready		= annun_lights(C90.caution.array[2])
    C90DR_lighting_annun_chip_detect_L		= annun_lights(C90.caution.array[3])
    C90DR_lighting_annun_eng_ice_fail_L		= annun_lights(C90.caution.array[4])
    C90DR_lighting_annun_eng_ice_fail_R		= annun_lights(C90.caution.array[5])
    C90DR_lighting_annun_gen_tie_open_L		= annun_lights(C90.caution.array[6])
    C90DR_lighting_annun_gen_tie_open_R		= annun_lights(C90.caution.array[8])
    C90DR_lighting_annun_bat_tie_open		= annun_lights(C90.caution.array[7])
    C90DR_lighting_annun_pitch_trim_off		= annun_lights(C90.caution.array[9])
    C90DR_lighting_annun_chip_detect_R		= annun_lights(C90.caution.array[10])
    C90DR_lighting_annun_no_fuel_xfr_R		= annun_lights(C90.caution.array[11])
    C90DR_lighting_annun_dc_gen_R			= annun_lights(C90.caution.array[12])
    C90DR_lighting_annun_fuel_crossfeed		= math.max(C90_ternary(simDR_auto_crossfeed == 2, 1, 0), annun_lights(C90.caution.array[13])) --@Doug's abnormal procedures
    C90DR_lighting_annun_hyd_fluid_lo		= annun_lights(C90.caution.array[14])
    C90DR_lighting_annun_battery_charge		= annun_lights(C90.caution.array[15])
    --C90.caution.array 16-18 only triggers caution light, no annunciator
    C90DR_lighting_annun_ignition_on_L		= annun_lights(C90.advisory.status[0])
    C90DR_lighting_annun_ignition_on_R		= annun_lights(C90.advisory.status[1])
    C90DR_lighting_annun_autofeather_L		= annun_lights(C90.advisory.status[2])
    C90DR_lighting_annun_autofeather_R		= annun_lights(C90.advisory.status[3])
    C90DR_lighting_annun_engine_antiice_L	= annun_lights(C90.advisory.status[4])
    C90DR_lighting_annun_engine_antiice_R	= annun_lights(C90.advisory.status[5])
    C90DR_lighting_annun_man_ties_close		= annun_lights(C90.advisory.status[6])
    C90DR_lighting_annun_ldg_taxi_light		= annun_lights(C90.advisory.status[7])
    if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
        -- PRESET FREQUENCY DISPLAYS
	    simDR_switch_instr_brightness_ratio[13] = simDR_switch_instr_brightness_ratio[10]
	    simDR_switch_instr_brightness_ratio[30] = simDR_switch_instr_brightness_ratio[10]
	    simDR_switch_instr_brightness_ratio[31] = simDR_switch_instr_brightness_ratio[10]
        -- EFIS AUX POWER
        C90DR_lighting_annun_EFIS_aux_test      = C90_ternary(C90DR_electrical_annun_test_on > 0, C90.electrical.tpl_fed_hot, C90_ternary(C90DR_avionics_EFIS_aux_pwr_on_switch_pos == -1, 1, 0))
	    C90DR_lighting_annun_EFIS_aux_on        = C90_ternary(C90DR_electrical_annun_test_on > 0, C90.electrical.tpl_fed_hot, simDR_battery_3 * C90DR_avionics_EFIS_aux_pwr_on_switch_pos)
	    C90DR_lighting_annun_EFIS_aux_arm       = C90_ternary(C90DR_electrical_annun_test_on > 0, C90.electrical.tpl_fed_hot, C90_ternary(C90DR_avionics_EFIS_aux_pwr_on_switch_pos == 1 and simDR_battery_3 == 0, 1, 0))
	    -- AUTOPILOT CONTROL PANEL
	    C90DR_autopilot_autopilot_disco	        = C90.autopilot.acp.ap_disco * simDR_instr_brightness_ratio_man[11]
	    C90DR_lighting_annun_acp_yaw_eng		= ap_lights(C90.autopilot.acp.yaw_engaged)
	    C90DR_lighting_annun_acp_yaw_disc		= ap_lights(C90.autopilot.acp.yaw_disco)
	    C90DR_lighting_annun_acp_ap_eng			= ap_lights(C90.autopilot.acp.ap_engaged)
	    C90DR_lighting_annun_acp_ap_disc		= ap_lights(C90.autopilot.acp.ap_disco)
	    C90DR_lighting_annun_acp_t				= ap_lights(C90.autopilot.acp.trim_servo)
	    C90DR_lighting_annun_acp_ap_fail		= ap_lights(C90.autopilot.acp.ap_fail)
	    C90DR_lighting_annun_acp_a				= ap_lights(C90.autopilot.acp.aileron_servo)
	    C90DR_lighting_annun_acp_r				= ap_lights(C90.autopilot.acp.rudder_servo)
	    C90DR_lighting_annun_acp_e				= ap_lights(C90.autopilot.acp.elevator_servo)
	    C90DR_lighting_annun_acp_half			= ap_lights(C90.autopilot.acp.half_bank)
	    C90DR_lighting_annun_acp_sr				= ap_lights(C90.autopilot.acp.soft_ride)
	    C90DR_lighting_annun_acp_trim_fail		= ap_lights(C90.autopilot.acp.trim_fail)
	    C90DR_lighting_annun_acp_trim_op		= ap_lights(C90.autopilot.acp.trim_operating)
	    -- FLIGHT CONTROL PANEL
	    C90DR_lighting_annun_fcp_trim_fail		= ap_lights(C90.autopilot.fcp.trim_fail)
	    C90DR_lighting_annun_fcp_trim_operating	= ap_lights(C90.autopilot.fcp.trim_operating)
	    C90DR_lighting_annun_fcp_hdg			= ap_lights(C90.autopilot.fcp.hdg)
	    C90DR_lighting_annun_fcp_nav			= ap_lights(C90.autopilot.fcp.nav)
	    C90DR_lighting_annun_fcp_nav_armed		= ap_lights(C90.autopilot.fcp.nav_armed)
	    C90DR_lighting_annun_fcp_dr				= ap_lights(C90.autopilot.fcp.dr)
	    C90DR_lighting_annun_fcp_appr			= ap_lights(C90.autopilot.fcp.appr)
	    C90DR_lighting_annun_fcp_appr_armed		= ap_lights(C90.autopilot.fcp.appr_armed)
	    C90DR_lighting_annun_fcp_bc				= ap_lights(C90.autopilot.fcp.bc)
	    C90DR_lighting_annun_fcp_clm			= ap_lights(C90.autopilot.fcp.clm)
	    C90DR_lighting_annun_fcp_half_bank		= ap_lights(C90.autopilot.fcp.half_bank)
	    C90DR_lighting_annun_fcp_soft_ride		= ap_lights(C90.autopilot.fcp.soft_ride)
	    C90DR_lighting_annun_fcp_ap_fail		= ap_lights(C90.autopilot.fcp.ap_fail)
	    C90DR_lighting_annun_fcp_yaw_engaged	= ap_lights(C90.autopilot.fcp.yaw_engaged)
	    C90DR_lighting_annun_fcp_yaw_disco		= ap_lights(C90.autopilot.fcp.yaw_disco)
	    C90DR_lighting_annun_fcp_alt			= ap_lights(C90.autopilot.fcp.alt)
	    C90DR_lighting_annun_fcp_alt_sel		= ap_lights(C90.autopilot.fcp.alt_sel)
	    C90DR_lighting_annun_fcp_vs				= ap_lights(C90.autopilot.fcp.vs)
	    C90DR_lighting_annun_fcp_gs				= ap_lights(C90.autopilot.fcp.gs)
	    C90DR_lighting_annun_fcp_gs_armed		= ap_lights(C90.autopilot.fcp.gs_armed)
	    C90DR_lighting_annun_fcp_ias			= ap_lights(C90.autopilot.fcp.ias)
	    C90DR_lighting_annun_fcp_ga				= ap_lights(C90.autopilot.fcp.ga)
	    C90DR_lighting_annun_fcp_dsc			= ap_lights(C90.autopilot.fcp.dsc)
	    C90DR_lighting_annun_fcp_ap_engaged		= ap_lights(C90.autopilot.fcp.ap_engaged)
	    C90DR_lighting_annun_fcp_ap_disco		= ap_lights(C90.autopilot.fcp.ap_disco)
	    -- ALTITUDE ALERT
	    C90DR_lighting_annun_alt_alert			= C90_ternary(simDR_indicator_alt_alert_lit > 0, simDR_instr_brightness_ratio[16], 0)
        -- IND42 ANNUNCIATORS
	    C90DR_lighting_annun_ind42_channel_1	= C90_ternary(C90DR_avionics_ind42_channel == 1, ind_lightLevel, 0)
	    C90DR_lighting_annun_ind42_channel_2	= C90_ternary(C90DR_avionics_ind42_channel == 2, ind_lightLevel, 0)
	    C90DR_lighting_annun_ind42_channel_3	= C90_ternary(C90DR_avionics_ind42_channel == 3, ind_lightLevel, 0)
	    C90DR_lighting_annun_ind42_wpt			= 0
	    C90DR_lighting_annun_ind42_nm			= C90DR_avionics_ind42_power_switch_pos * ind_lightLevel
	    C90DR_lighting_annun_ind42_hld			= 0
	    C90DR_lighting_annun_ind42_kt			= C90_ternary(C90DR_avionics_ind42_mode == 1, ind_lightLevel, 0)
	    C90DR_lighting_annun_ind42_min			= C90_ternary(C90DR_avionics_ind42_mode == 2, ind_lightLevel, 0)
	    C90DR_lighting_annun_ind42_id			= C90_ternary(C90DR_avionics_ind42_mode == 0, ind_lightLevel, 0)
        -- ADF
	    C90DR_lighting_annun_clt62_adf_act		= simDR_adf1_tone
	    C90DR_lighting_annun_clt62_adf_mem		= C90.avionics.ctl62_adf_mem
	    C90DR_lighting_annun_clt62_adf_rmt		= 0
	    C90DR_lighting_annun_clt62_adf_tx		= 0
	    C90DR_lighting_annun_clt62_adf_hld		= 0
        -- COCKPIT SPILL LIGHTS
	    C90DR_lighting_inclinometer_spill_L[3]  = simDR_avionics_power_on * C90_rescale(0, 0, 0.75, 1, simDR_instr_brightness_ratio[11] * C90.electrical.tpl_fed_hot)
	    C90DR_lighting_inclinometer_spill_R[3]  = simDR_avionics_power_on * C90_rescale(0, 0, 0.75, 1, simDR_instr_brightness_ratio[11] * C90.electrical.tpl_fed_hot)
	    C90DR_lighting_alt_alert_spill[3] 		= simDR_indicator_alt_alert_lit * simDR_instr_brightness_ratio[16] * 0.75 * C90.electrical.tpl_fed_hot
    end
    if simDR_acf_descrip == "C90B EVO GNS" then
    -- COLLINS PLII RADIOS                              --IBAV8N, Aug24-23  add LR ATC ACT and TX 
	    C90DR_lighting_annun_clt22_com1_act		= C90_ternary(simDR_com1_fail ~= 6, 1, 0) * math.max(simDR_pilotedge_receive_com1, simDR_xpilot_com1_rx, simDR_com1_active) * simDR_avionics_power_on * simDR_com1_power
	    C90DR_lighting_annun_clt22_com1_mem		= C90.avionics.ctl22_com1_mem
	    C90DR_lighting_annun_clt22_com1_rmt		= math.max(((1 - simDR_g430n1_nav_com_sel) * g430n1_navcom_rmt), g430n1_ff_com_rmt) * simDR_avionics_power_on * simDR_com1_power * gps530_power
	    C90DR_lighting_annun_clt22_com1_tx		= C90_ternary(simDR_com1_fail ~= 6, 1, 0) * math.max(simDR_pilotedge_transmit_com1, simDR_xpilot_ptt * simDR_xpilot_status, simDR_com1_tx) * C90_ternary(C90DR_avionics_mic_sel_dial_pos_pilot == 0, 1, 0)
	    C90DR_lighting_annun_clt22_com1_hld		= simDR_pilotedge_connected
	    C90DR_lighting_annun_clt22_com2_act		= C90_ternary(simDR_com2_fail ~= 6, 1, 0) * math.max(simDR_pilotedge_receive_com2, simDR_xpilot_com2_rx, simDR_com2_active) * simDR_avionics_power_on * simDR_com2_power
	    C90DR_lighting_annun_clt22_com2_mem		= C90.avionics.ctl22_com2_mem
	    C90DR_lighting_annun_clt22_com2_rmt		= math.max(((1 - simDR_g430n2_nav_com_sel) * g430n2_navcom_rmt), g430n2_ff_com_rmt) * simDR_avionics_power_on * simDR_com2_power * gps430_power
	    C90DR_lighting_annun_clt22_com2_tx		= C90_ternary(simDR_com2_fail ~= 6, 1, 0) * math.max(simDR_pilotedge_transmit_com2, simDR_xpilot_ptt * simDR_xpilot_status, simDR_com2_tx) * C90_ternary(C90DR_avionics_mic_sel_dial_pos_pilot == 1, 1, 0)
	    C90DR_lighting_annun_clt22_com2_hld		= 0
	    C90DR_lighting_annun_clt32_nav1_act		= simDR_nav1_tone
	    C90DR_lighting_annun_clt32_nav1_mem		= C90.avionics.ctl32_nav1_mem
	    C90DR_lighting_annun_clt32_nav1_rmt		= math.max((simDR_g430n1_nav_com_sel * g430n1_navcom_rmt), g430n1_ff_nav_rmt) * simDR_avionics_power_on * simDR_com1_power * gps530_power
	    C90DR_lighting_annun_clt32_nav1_tx		= 0
	    C90DR_lighting_annun_clt32_nav1_hld		= 0
	    C90DR_lighting_annun_clt32_nav2_act		= simDR_nav2_tone
	    C90DR_lighting_annun_clt32_nav2_mem		= C90.avionics.ctl32_nav2_mem
	    C90DR_lighting_annun_clt32_nav2_rmt		= math.max((simDR_g430n2_nav_com_sel * g430n2_navcom_rmt), g430n2_ff_nav_rmt) * simDR_avionics_power_on * simDR_com2_power * gps430_power
	    C90DR_lighting_annun_clt32_nav2_tx		= 0
	    C90DR_lighting_annun_clt32_nav2_hld		= 0
	    C90DR_lighting_annun_clt92_atc_act		= 0
	    C90DR_lighting_annun_clt92_atc_mem		= 0
	    C90DR_lighting_annun_clt92_atc_rmt		= C90_ternary(simDR_fseconomy_finish == 1 and simDR_fseconomy_started == 1, 1, 0)
	    C90DR_lighting_annun_clt92_atc_tx		= C90_ternary(simDR_xpndr_fail == 0 and simDR_transponder_power > 1 and simDR_battery_on > 0 and simDR_avionics_power_on == 1, simDR_transponder_light, 0)
	    C90DR_lighting_annun_clt92_atc_hld		= C90_ternary(simDR_fseconomy_connected == 1 and simDR_fseconomy_started == 1, 1, simDR_fseconomy_connected * simDR_wigwag)
    end
    if simDR_acf_descrip == "C90B - G1000, Blackhawk" then
        -- G1000 prop-sync annunciator              --IMC
	    imcDR_annun_prop_sync_on = math.max(test_on_buspwr, C90DR_power * simDR_prop_sync_on * math.max(0.3, simDR_instr_brightness_ratio_man[3]))
        -- Standby battery annunciators
	    C90DR_lighting_annun_EFIS_aux_on = math.max(test_on_buspwr, simDR_battery_3)-- * C90DR_avionics_EFIS_aux_pwr_on_switch_pos)
	    C90DR_lighting_annun_EFIS_aux_arm = math.max(test_on_buspwr, C90_ternary(C90DR_avionics_EFIS_aux_pwr_on_switch_pos == 1 and simDR_battery_3 == 0, math.max(0.3, simDR_instr_brightness_ratio_man[3]), 0))
        function gfc710_lights(condition)      --IMC
            if condition then return wca_lightLevel * simDR_autopilot_powered
            elseif C90DR_electrical_annun_test_on > 0 then return C90.electrical.tpl_fed_hot
            else return 0
            end
        end
        --G1000 autopilot panel
        local ap_state = simDR_autopilot_state
        C90DR_imc_gfc710_indicator_alt  = gfc710_lights(bit.band(ap_state, 0x4000)>0)-- Altitude hold engage
        C90DR_imc_gfc710_indicator_ap   = gfc710_lights(simDR_autopilot_servos_on > 0)
        C90DR_imc_gfc710_indicator_ap_1 = gfc710_lights(simDR_autopilot_source == 0)  -- AP source 1
        C90DR_imc_gfc710_indicator_ap_2 = gfc710_lights(simDR_autopilot_source == 1) -- AP source 2
        C90DR_imc_gfc710_indicator_apr  = gfc710_lights(simDR_autopilot_approach_status > 0)
        C90DR_imc_gfc710_indicator_bank = gfc710_lights(simDR_autopilot_half_bank > 0) 
        C90DR_imc_gfc710_indicator_bc   = gfc710_lights(simDR_autopilot_backcrs_status > 0)
        C90DR_imc_gfc710_indicator_fd   = gfc710_lights(simDR_annun_flight_director > 0) 
        C90DR_imc_gfc710_indicator_flc  = gfc710_lights(bit.band(ap_state, 0x40) > 0)  -- Flight level change engage
        C90DR_imc_gfc710_indicator_hdg  = gfc710_lights(bit.band(ap_state, 0x2) > 0)  -- Heading Select Engage
        C90DR_imc_gfc710_indicator_nav  = gfc710_lights(bit.band(ap_state, 0x200) > 0)  -- Nav Engaged
        C90DR_imc_gfc710_indicator_vnv  = gfc710_lights((bit.band(ap_state, 0x40000) > 0) or (bit.band(ap_state, 0x20000)) > 0)  
        C90DR_imc_gfc710_indicator_vs   = gfc710_lights(bit.band(ap_state, 0x10) > 0)  -- V/S Engage
        C90DR_imc_gfc710_indicator_yd   = gfc710_lights(simDR_annun_yaw_damper > 0)
        -- bitfield see: https://developer.x-plane.com/article/accessing-the-x-plane-autopilot-from-datarefs/
    end
end
