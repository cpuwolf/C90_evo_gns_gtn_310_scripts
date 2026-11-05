jit.off()
--Headset-on sound settings
volume_engine       = 0.25          --0.4
volume_environment  = 0.5           --0.65
volume_interior     = 0.3           --0.5
--[[
*****************************************************************************************
* Program Script Name	:	C90_sys
*
* Author Name			:	Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2017-04-06	0.01a				Start of Dev
*
*
*
*
*****************************************************************************************
*        COPYRIGHT � 2017 JIM GREGORY / LAMINAR RESEARCH - ALL RIGHTS RESERVED			*
*****************************************************************************************
--]]



--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD - this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.

IN_REPLAY - evaluates to 0 if replay is off, 1 if replay mode is on

--]]

--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--

local STOP				= 0
local COUNTUP			= 1
local COUNTUP_PAUSE		= 2
local COUNTDOWN_SET 	= 3
local COUNTDOWN 		= 4
local COUNTDOWN_PAUSE 	= 5

--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--
print("EVO: 1. LOADING global variables") --@pilotmarcog - 4-01-2022 -- changed all log() to print() as per xlua r1.2 req.

raw_table("C90") --@pilotmarcog 4-01-2022 -- Added for compatibility with xlua r1.1+
C90	= {}
C90.persistence						= ""	--@pilotmarcog - 4-01-2022 -- changed 'persistence' to globally instanced
C90.persistence_version             = 101624
C90.test                            = 0
C90.start_running                   = 0
C90.avitab_on                       = 0     --IBAV8N, Apr7-22, to save avitab status after XP shutdown
C90.avitab_enable                   = 0
C90.gear_warn_muted                 = 0     --IBAV8N, Aug30-23
restore_levers                      = 0     --this might need to become a dref

C90.annunciator_warning             = 0
C90.annunciator_caution             = 0

C90.airCon = {}
C90.airCon.bleed_avail              = 0
C90.airCon.bypass_valve 		    = 0     --IBAV8N, Jan6-22
C90.airCon.cabin_temp 		        = 0
C90.airCon.cabin_temp_target 		= 0

C90.iceRain = {}
C90.iceRain.current_action          = 0
C90.iceRain.surface_deice_phase		= 0
C90.iceRain.surface_deice_psid      = 0
C90.iceRain.surface_psid_target     = 0
C90.iceRain.windshield_L            = 0
C90.iceRain.windshield_R            = 0

C90.avionics = {}
C90.avionics.crs_sel_hold_flag		= 0
C90.avionics.crs_sel_trigger        = 0
C90.avionics.gps_crs_sel            = 0     --IBAV8N, Sept3-23 for pre needle while in GPS mode, see C90_EHSI_course_select
C90.avionics.vor_avail              = 0     --IBAV8N, Jan25-22
C90.avionics.loc_avail              = 0     --IBAV8N, Jan25-22
C90.avionics.ctl22_com1_sto_stack	= {}    --IBAV8N, Apr25-22, These don't exit .lua and can be internal variable arrays
C90.avionics.ctl22_com1_sto_count   = 0
C90.avionics.ctl22_com1_mem         = 0     --don't change, this connects to lighting.lua
C90.avionics.ctl22_com2_sto_stack	= {}
C90.avionics.ctl22_com2_sto_count   = 0
C90.avionics.ctl22_com2_mem         = 0
C90.avionics.ctl32_nav1_sto_stack	= {}
C90.avionics.ctl32_nav1_sto_count   = 0
C90.avionics.ctl32_nav1_mem         = 0
C90.avionics.ctl32_nav2_sto_stack	= {}
C90.avionics.ctl32_nav2_sto_count   = 0
C90.avionics.ctl32_nav2_mem         = 0
C90.avionics.ctl62_adf_sto_stack    = {}
C90.avionics.ctl62_adf_sto_count    = 0
C90.avionics.ctl62_adf_mem          = 0
C90.avionics.ctl92_xpdr_ifr         = 0
C90.avionics.ctl92_xpdr_vfr         = 1200

C90.autopilot = {}
C90.autopilot.ground_test_mode		= 0
C90.autopilot.ground_test			= 0
C90.autopilot.airborne_test_mode	= 0
C90.autopilot.airborne_test			= 0
C90.autopilot.lamp_test				= 0
C90.autopilot.sys_diag_test			= 0
C90.autopilot.annun_test_status		= 0
C90.autopilot.acp = {}
C90.autopilot.acp.yaw_engaged		= 0
C90.autopilot.acp.yaw_disco			= 0
C90.autopilot.acp.ap_engaged		= 0
C90.autopilot.acp.ap_disco			= 0
C90.autopilot.acp.trim_servo		= 0
C90.autopilot.acp.ap_fail			= 0
C90.autopilot.acp.aileron_servo		= 0
C90.autopilot.acp.rudder_servo		= 0
C90.autopilot.acp.elevator_servo	= 0
C90.autopilot.acp.half_bank			= 0
C90.autopilot.acp.soft_ride			= 0
C90.autopilot.acp.trim_fail			= 0
C90.autopilot.acp.trim_operating	= 0
C90.autopilot.fcp = {}
C90.autopilot.fcp.trim_fail			= 0
C90.autopilot.fcp.trim_operating	= 0
C90.autopilot.fcp.hdg				= 0
C90.autopilot.fcp.nav				= 0
C90.autopilot.fcp.nav_armed			= 0
C90.autopilot.fcp.dr				= 0
C90.autopilot.fcp.appr				= 0
C90.autopilot.fcp.appr_armed		= 0
C90.autopilot.fcp.bc				= 0
C90.autopilot.fcp.clm				= 0
C90.autopilot.fcp.half_bank			= 0
C90.autopilot.fcp.soft_ride			= 0
C90.autopilot.fcp.ap_fail			= 0
C90.autopilot.fcp.yaw_engaged		= 0
C90.autopilot.fcp.yaw_disco			= 0
C90.autopilot.fcp.alt				= 0
C90.autopilot.fcp.alt_sel			= 0
C90.autopilot.fcp.vs				= 0
C90.autopilot.fcp.gs				= 0
C90.autopilot.fcp.gs_armed			= 0
C90.autopilot.fcp.ias				= 0
C90.autopilot.fcp.ga				= 0
C90.autopilot.fcp.dsc				= 0
C90.autopilot.fcp.ap_engaged		= 0
C90.autopilot.fcp.ap_disco			= 0
C90.autopilot.fd_saved              = {}
C90.autopilot.fd_test_timer	        = {}
C90.autopilot.fd_ref	            = {}

C90.pre80 = {}
C90.pre80.mode						= 0
C90.pre80.alert						= 0
C90.pre80.alert_canx				= 0

C90.warning = {}                            --ANNUNCIATOR WARNING LIGHTS
C90.warning.array			        = {}
C90.warning.status		            = {}

C90.caution = {}                            --ANNUNCIATOR CAUTION LIGHTS
C90.caution.ext_power				= 0
C90.caution.array			        = {}
C90.caution.status		            = {}

C90.advisory = {}                           --ANNUNCIATOR ADVISORY LIGHTS
C90.advisory.status		            = {}

C90.electrical = {}
C90.electrical.gen_fault_L          = 0
C90.electrical.gen_fault_R          = 0
C90.electrical.gpu_status           = 0
C90.electrical.gpu_live             = 0
C90.electrical.ctr_bus_hot          = 0
C90.electrical.gen_bus_L_hot        = 0
C90.electrical.gen_bus_R_hot        = 0
C90.electrical.tpl_fed_hot          = 0
C90.electrical.efis_aux_trigger     = 0     --IBAV8N, Aug28-22, EFIS AUX
C90.electrical.efis_aux_silence     = 0     --IBAV8N, Aug28-22, EFIS AUX
C90.electrical.ac_power             = 0
--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local C90_countdown_timer_total_seconds_set = 0
local C90_EFIS_timer_total_seconds = 0
local C90_brakes = 0
local C90_left_brake = 0
local C90_right_brake = 0
local C90_max_brake = 0
local C90_condition_adj = 0
local C90_beta_ctrl = 0
local C90_beta_alt = 0

--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS           			    	 **--
--*************************************************************************************--
print("EVO: 2. LOADING X-Plane DataRefs")
simDR_EFIS_weather_mode                 = find_dataref("sim/cockpit2/EFIS/EFIS_weather_mode")
simDR_EFIS_weather_sector_width         = find_dataref("sim/cockpit2/EFIS/EFIS_weather_sector_width")
simDR_EFIS_antenna_limit                = find_dataref("sim/cockpit2/EFIS/EFIS_weather_antenna_limit")
simDR_EFIS_weather_auto_tilt            = find_dataref("sim/cockpit2/EFIS/EFIS_weather_auto_tilt")
simDR_wind_speed_kts			        = find_dataref("sim/cockpit2/gauges/indicators/wind_speed_kts")
simDR_RMI_left_use_adf			        = find_dataref("sim/cockpit2/radios/actuators/RMI_left_use_adf_pilot")
simDR_RMI_right_use_adf			        = find_dataref("sim/cockpit2/radios/actuators/RMI_right_use_adf_pilot")
simDR_demand_flow_setting			    = find_dataref("sim/cockpit2/oxygen/actuators/demand_flow_setting")
simDR_num_plugged_in_o2			        = find_dataref("sim/cockpit2/oxygen/actuators/num_plugged_in_o2")
simDR_o2_valve_on			            = find_dataref("sim/cockpit2/oxygen/actuators/o2_valve_on")
simDR_m_stations			            = find_dataref("sim/flightmodel/weight/m_stations")
simDR_window_heat_running	            = find_dataref("sim/cockpit2/ice/ice_window_heat_running")
simDR_oil_temperature_deg_C		        = find_dataref("sim/cockpit2/engine/indicators/oil_temperature_deg_C")
simDR_acf_tailnum		                = find_dataref("sim/aircraft/view/acf_tailnum")
simDR_alpha_el			                = find_dataref("sim/flightmodel/parts/alpha_el")    --use 29 and 69
simDR_act_prop_rotation_speed_rad_sec   = find_dataref("sim/flightmodel2/engines/prop_rotation_speed_rad_sec")
simDR_act_tire_rotation_speed_rad_sec   = find_dataref("sim/flightmodel2/gear/tire_rotation_speed_rad_sec")
simDR_tire_part_brake	                = find_dataref("sim/flightmodel2/gear/tire_part_brake")
simDR_prop_angle_degrees	            = find_dataref("sim/cockpit2/engine/actuators/prop_angle_degrees")
simDR_low_idle_ratio		            = find_dataref("sim/aircraft2/engine/low_idle_ratio")
simDR_high_idle_ratio		            = find_dataref("sim/aircraft2/engine/high_idle_ratio")
simDR_AOA_heat		                    = find_dataref("sim/cockpit/switches/anti_ice_AOA_heat")
simDR_AOA_heat2		                    = find_dataref("sim/cockpit/switches/anti_ice_AOA_heat2")
simDR_prop_pitch_deg 		            = find_dataref("sim/flightmodel2/engines/prop_pitch_deg")
simDR_override_prop_pitch 		        = find_dataref("sim/operation/override/override_prop_pitch")
simDR_POINT_pitch_deg_use 		        = find_dataref("sim/flightmodel/engine/POINT_pitch_deg_use")
simDR_bus_tie_selective 		        = find_dataref("sim/aircraft/electrical/bus_tie_selective")
simDR_override_GPU_volts 		        = find_dataref("sim/operation/override/override_GPU_volts")
simDR_GPU_can_be_called_for 		    = find_dataref("sim/cockpit2/electrical/GPU_can_be_called_for")
simDR_GPU_generator_volts 			    = find_dataref("sim/cockpit2/electrical/GPU_generator_volts")
simDR_generator_on_L 			        = find_dataref("sim/cockpit/electrical/generator_on[0]")
simDR_generator_on_R 			        = find_dataref("sim/cockpit/electrical/generator_on[1]")
simDR_generator_volts_L 			    = find_dataref("sim/cockpit2/electrical/generator_volts[0]")
simDR_generator_volts_R 			    = find_dataref("sim/cockpit2/electrical/generator_volts[1]")
simDR_prop_is_disc 					    = find_dataref("sim/flightmodel2/engines/prop_is_disc")                         -- imc - prop is being drawn as billboard images rather than 3D?
simDR_winshield_deice_effectiveness     = find_dataref("sim/aircraft/specialcontrols/acf_winshield_deice_effectiveness")
simDR_fuselage_ice                      = find_dataref("sim/flightmodel/failures/window_ice_unheated")
simDR_tail_boots_inflation              = find_dataref("sim/cockpit2/ice/ice_tail_boots_inflation")
simDR_wing_boots_inflation              = find_dataref("sim/cockpit2/ice/ice_wing_boots_inflation")
simDR_wing_ice_L                        = find_dataref("sim/flightmodel/failures/frm_ice")
simDR_wing_ice_R                        = find_dataref("sim/flightmodel/failures/frm_ice2")
simDR_tail_ice_L                        = find_dataref("sim/flightmodel/failures/tail_ice")
simDR_tail_ice_R                        = find_dataref("sim/flightmodel/failures/tail_ice2")
simDR_pitot_heat_on_standby             = find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_standby")                    --IBAV8N, G1000 needs this
simDR_static_heat_on_standby            = find_dataref("sim/cockpit2/ice/ice_static_heat_on_standby")
simDR_audio_selection_adf2_copilot      = find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf2_copilot")    --IBAV8N, for G1000 copilot's audio panel
simDR_vnav_status                       = find_dataref("sim/cockpit2/autopilot/vnav_status")
simDR_artificial_horizon_adjust_stby    = find_dataref("sim/cockpit2/gauges/actuators/artificial_horizon_adjust_deg_copilot")
simDR_barometer_setting_in_hg_pilot     = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot")
simDR_barometer_setting_in_hg_copilot   = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot")
simDR_barometer_setting_in_hg_stby      = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_stby")
simDR_autopilot_source			        = find_dataref("sim/cockpit2/autopilot/autopilot_source")
simDR_autopilot_servos_on			    = find_dataref("sim/cockpit2/autopilot/servos_on")
simDR_annun_flight_director			    = find_dataref("sim/cockpit2/annunciators/flight_director")
simDR_annun_yaw_damper                  = find_dataref("sim/cockpit2/annunciators/yaw_damper")
simDR_autopilot_state                   = find_dataref("sim/cockpit/autopilot/autopilot_state")
simDR_autopilot_powered                 = find_dataref("sim/cockpit2/autopilot/autopilot_has_power")                    -- does the ap computer have power
simDR_audio_com_selection		        = find_dataref("sim/cockpit2/radios/actuators/audio_com_selection")             --IBAV8N, Sept21-23, enable com1 tx @ pwr on, avionics off com1=6 com2=7
simDR_audio_marker_enabled		        = find_dataref("sim/cockpit2/radios/actuators/audio_marker_enabled")
simDR_audio_selection_nav1		        = find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav1")
simDR_audio_selection_nav2	            = find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav2")
simDR_audio_dme_enabled		            = find_dataref("sim/cockpit2/radios/actuators/audio_dme_enabled")
simDR_audio_selection_adf1		        = find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf1")
simDR_transponder_light			        = find_dataref("sim/cockpit/radios/transponder_light")                          --IBAV8N, Sept20-23 
simDR_kill_G1000_engine			        = find_dataref("sim/graphics/misc/kill_g1000_engine")                           --IMC SEPT10-23
simDR_prop_sync_on 				        = find_dataref("sim/cockpit2/switches/prop_sync_on")                            --IMC
simDR_override_nav1_needles             = find_dataref("sim/operation/override/override_nav1_needles")
simDR_HSI_is_arc_copilot                = find_dataref("sim/cockpit2/switches/HSI_is_arc_copilot")                      --IBAV8N, Aug9-23, set to 0 to fix PRE HSI
simDR_g430n1_nav_com_sel                = find_dataref("sim/cockpit/g430/g430_nav_com_sel[0]")                          --IBAV8N, May27-22, GNS530 PUSH C/V button status, 0=COM 1=NAV
simDR_g430n2_nav_com_sel                = find_dataref("sim/cockpit/g430/g430_nav_com_sel[1]")                          --IBAV8N, May27-22, GNS430 PUSH C/V button status, 0=COM 1=NAV
simDR_com1_monitor			            = find_dataref("sim/cockpit2/radios/actuators/audio_selection_com1")
simDR_com2_monitor			            = find_dataref("sim/cockpit2/radios/actuators/audio_selection_com2")
simDR_audio_selected_mkr		        = find_dataref("sim/cockpit2/radios/actuators/audio_marker_enabled")
simDR_audio_selection_dme1		        = find_dataref("sim/cockpit2/radios/actuators/audio_selection_dme1")
simDR_audio_selection_dme2		        = find_dataref("sim/cockpit2/radios/actuators/audio_selection_dme2")
simDR_radio_marker_sens			        = find_dataref("sim/cockpit2/radios/actuators/marker_sens")
simDR_dh_lit_pilot                      = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_dh_lit_pilot")   --IBAV8N, Apr26-22, for making DH light flash, per POH
simDR_fuel_quantity_l_wing              = find_dataref("sim/flightmodel/weight/m_fuel[0]")                              --IBAV8N, Apr10-22, save fuel quants for persistence
simDR_fuel_quantity_r_wing              = find_dataref("sim/flightmodel/weight/m_fuel[1]")                              --IBAV8N, Apr10-22, save fuel quants for persistence
simDR_fuel_quantity_l_nacelle           = find_dataref("sim/flightmodel/weight/m_fuel[2]")                              --IBAV8N, Apr10-22, save fuel quants for persistence
simDR_fuel_quantity_r_nacelle           = find_dataref("sim/flightmodel/weight/m_fuel[3]")                              --IBAV8N, Apr10-22, save fuel quants for persistence
--simDR_payload weight                    = find_dataref("sim/flightmodel/weight/m_fixed")                              --IBAV8N, Apr11-22, even finding this dref crashes xp, just a note
simDR_l_brake_add                       = find_dataref("sim/flightmodel/controls/l_brake_add")                          --IBAV8N, Apr8-22, Smooth braking for button-users
simDR_r_brake_add                       = find_dataref("sim/flightmodel/controls/r_brake_add")                          --IBAV8N, Apr8-22, Smooth braking for button-users
simDR_inverter_0_fail                   = find_dataref("sim/operation/failures/rel_invert0")                            --IBAV8N, Mar1-22, allow inverter 0 fail to affect the ac voltage gauge
simDR_inverter_1_fail                   = find_dataref("sim/operation/failures/rel_invert1")                            --IBAV8N, Mar1-22, allow inverter 1 fail to affect the ac voltage gauge
simDR_nav1_course_deg_mag_pilot         = find_dataref("sim/cockpit2/radios/actuators/nav1_course_deg_mag_pilot")       --IBAV8N, Jan31-22, for CDI on LOC in ILS when in GPS mode
simDR_nav1_hdef_dot2                    = find_dataref("sim/cockpit/radios/nav1_hdef_dot2")                             --IBAV8N, Jan25-22 allow PRE needle CDI when in GPS mode
simDR_fuel_pump_on_L                    = find_dataref("sim/cockpit/engine/fuel_pump_on[0]")                            --IBAV8N Aug24-23 hot bus boost pumps
simDR_fuel_pump_on_R                    = find_dataref("sim/cockpit/engine/fuel_pump_on[1]")                            --IBAV8N Aug24-23 hot bus boost pump
simDR_transfer_pump_L                   = find_dataref("sim/cockpit2/fuel/transfer_pump_left")                          --IBAV8N, Jan24-22 to set L transfer pump on engines running
simDR_transfer_pump_R                   = find_dataref("sim/cockpit2/fuel/transfer_pump_right")                         --IBAV8N, Jan24-22 to set R transfer pump on engines running
simDR_auto_crossfeed                    = find_dataref("sim/cockpit2/fuel/auto_crossfeed")                              --IBAV8N, Jan24-22 to set crossfeed on engines running
simDR_fuel_level_indicated_left         = find_dataref("sim/cockpit2/fuel/fuel_level_indicated_left")                   --IBAV8N, Dec20-21, added to smooth fuel gauge needle drop
simDR_fuel_level_indicated_right        = find_dataref("sim/cockpit2/fuel/fuel_level_indicated_right")                  --IBAV8N, Dec20-21, added to smooth fuel gauge needle drop
simDR_ap_computer_fail                  = find_dataref("sim/operation/failures/rel_adc_comp")
simDR_adf1_fail                         = find_dataref("sim/operation/failures/rel_adf1")
simDR_com1_fail                         = find_dataref("sim/operation/failures/rel_com1")
simDR_com2_fail                         = find_dataref("sim/operation/failures/rel_com2")
simDR_copilot_ahz_fail	                = find_dataref("sim/operation/failures/rel_cop_ahz")
simDR_copilot_dg_fail	                = find_dataref("sim/operation/failures/rel_cop_dgy")
simDR_efis1_fail	                    = find_dataref("sim/operation/failures/rel_efis_1")
simDR_efis2_fail	                    = find_dataref("sim/operation/failures/rel_efis_2")
simDR_engine0_fail                      = find_dataref("sim/operation/failures/rel_engfai0")
simDR_engine1_fail                      = find_dataref("sim/operation/failures/rel_engfai1")
simDR_engfir0_fail                      = find_dataref("sim/operation/failures/rel_engfir0")
simDR_engfir1_fail                      = find_dataref("sim/operation/failures/rel_engfir1")
simDR_flaps_left_bind_fail              = find_dataref("sim/operation/failures/rel_fc_L_flp")
simDR_flaps_right_bind_fail             = find_dataref("sim/operation/failures/rel_fc_R_flp")
simDR_flap_actuator_fail                = find_dataref("sim/operation/failures/rel_flap_act")
simDR_gps530_fail                       = find_dataref("sim/operation/failures/rel_g430_gps1")
simDR_gps430_fail                       = find_dataref("sim/operation/failures/rel_g430_gps2")
simDR_hungstart0_fail                   = find_dataref("sim/operation/failures/rel_hunsta0")
simDR_hungstart1_fail                   = find_dataref("sim/operation/failures/rel_hunsta1")
simDR_eng0_alt_air_fail                 = find_dataref("sim/operation/failures/rel_ice_alt_air1")
simDR_eng1_alt_air_fail                 = find_dataref("sim/operation/failures/rel_ice_alt_air2")
simDR_prop_deice_heat_left_fail         = find_dataref("sim/operation/failures/rel_ice_prop_heat")
simDR_prop_deice_heat_right_fail        = find_dataref("sim/operation/failures/rel_ice_prop_heat2")
simDR_windshield_heat_fail              = find_dataref("sim/operation/failures/rel_ice_window_heat")
simDR_windshield_heat_fail_hi           = find_dataref("sim/operation/failures/rel_ice_window_heat_l_side")
simDR_windshield_heat_fail_cop          = find_dataref("sim/operation/failures/rel_ice_window_heat_cop") --IBAV8N Aug23-23 new XP12 dref
simDR_windshield_heat_fail_cop_hi       = find_dataref("sim/operation/failures/rel_ice_window_heat_r_side")
simDR_flaps_left_gone_fail              = find_dataref("sim/operation/failures/rel_L_flp_off")
simDR_flaps_right_gone_fail             = find_dataref("sim/operation/failures/rel_R_flp_off")
simDR_gear1_fail                        = find_dataref("sim/operation/failures/rel_lagear1")
simDR_gear2_fail                        = find_dataref("sim/operation/failures/rel_lagear2")
simDR_gear3_fail                        = find_dataref("sim/operation/failures/rel_lagear3")
simDR_left_brake_fail                   = find_dataref("sim/operation/failures/rel_lbrakes")
simDR_right_brake_fail                  = find_dataref("sim/operation/failures/rel_rbrakes")
simDR_nav1_fail                         = find_dataref("sim/operation/failures/rel_nav1")
simDR_nav2_fail                         = find_dataref("sim/operation/failures/rel_nav2")
simDR_op_autopilot_fail			        = find_dataref("sim/operation/failures/rel_otto")
simDR_pitot_heat_left_fail              = find_dataref("sim/operation/failures/rel_pitot")
simDR_pitot_heat_right_fail             = find_dataref("sim/operation/failures/rel_pitot2")
simDR_propshaft0_fail                   = find_dataref("sim/operation/failures/rel_pshaft0")
simDR_propshaft1_fail                   = find_dataref("sim/operation/failures/rel_pshaft1")
simDR_ap_servo_fail                     = find_dataref("sim/operation/failures/rel_auto_servos")
simDR_rud_servo_fail			        = find_dataref("sim/operation/failures/rel_servo_rudd")
simDR_ail_servo_fail			        = find_dataref("sim/operation/failures/rel_servo_ailn")
simDR_elv_servo_fail			        = find_dataref("sim/operation/failures/rel_servo_elev")
simDR_smoke_cpit_fail                   = find_dataref("sim/operation/failures/rel_smoke_cpit")
simDR_pilot_dg_fail	                    = find_dataref("sim/operation/failures/rel_ss_dgy")
simDR_pilot_ahz_fail	                = find_dataref("sim/operation/failures/rel_ss_ahz")
simDR_starter0_fail                     = find_dataref("sim/operation/failures/rel_startr0")
simDR_starter1_fail                     = find_dataref("sim/operation/failures/rel_startr1")
simDR_xpndr_fail                        = find_dataref("sim/operation/failures/rel_xpndr")
simDR_pressure_cabin_alt_ind_ft	        = find_dataref("sim/cockpit2/pressurization/indicators/cabin_altitude_ft")
simDR_nav1_tone						    = find_dataref("sim/cockpit2/radios/indicators/morse_id_tone_nav1")
simDR_nav2_tone						    = find_dataref("sim/cockpit2/radios/indicators/morse_id_tone_nav2")
simDR_adf1_tone						    = find_dataref("sim/cockpit2/radios/indicators/morse_id_tone_adf1")
simDR_flighttime					    = find_dataref("sim/time/local_time_sec")
simDR_transponder_power				    = find_dataref("sim/cockpit/radios/transponder_mode")
simDR_wigwag						    = find_dataref("sim/graphics/animation/obj_wigwag_brightness")
simDR_starter_torque_ratio              = find_dataref("sim/aircraft/engine/acf_starter_torque_ratio")
simDR_master_caution_plugin		        = find_dataref("sim/cockpit2/annunciators/plugin_master_caution")
simDR_master_caution			        = find_dataref("sim/cockpit/warnings/master_caution_on")
simDR_master_warning_plugin             = find_dataref("sim/cockpit2/annunciators/plugin_master_warning")
simDR_master_warning                    = find_dataref("sim/cockpit/warnings/master_warning_on")
simDR_com1_active                       = find_dataref("sim/atc/com1_active")                   --IBAV8N Aug24-23 for proline radios
simDR_com2_active                       = find_dataref("sim/atc/com2_active")
simDR_com1_tx                           = find_dataref("sim/atc/com1_tx")
simDR_com2_tx                           = find_dataref("sim/atc/com2_tx")
simDR_com1_frequency                  	= find_dataref("sim/cockpit/radios/com1_freq_hz")
simDR_com2_frequency                  	= find_dataref("sim/cockpit/radios/com2_freq_hz")
simDR_nav1_frequency                  	= find_dataref("sim/cockpit/radios/nav1_freq_hz")
simDR_nav2_frequency                  	= find_dataref("sim/cockpit/radios/nav2_freq_hz")
simDR_adf_frequency                  	= find_dataref("sim/cockpit/radios/adf1_freq_hz")
simDR_adf2_frequency                  	= find_dataref("sim/cockpit/radios/adf2_freq_hz")       --IBAV8N, Apr22-21, RMI ADF2 will use ADF1 freq
simDR_com1_stby_frequency            	= find_dataref("sim/cockpit/radios/com1_stdby_freq_hz")
simDR_com2_stby_frequency            	= find_dataref("sim/cockpit/radios/com2_stdby_freq_hz")
simDR_nav1_stby_frequency            	= find_dataref("sim/cockpit/radios/nav1_stdby_freq_hz")
simDR_nav2_stby_frequency            	= find_dataref("sim/cockpit/radios/nav2_stdby_freq_hz")
simDR_adf_stby_frequency            	= find_dataref("sim/cockpit/radios/adf1_stdby_freq_hz")
simDR_electric_trim                     = find_dataref("sim/cockpit2/autopilot/electric_trim_on")
simDR_pitot_heat_left                   = find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_pilot")
simDR_pitot_heat_right                  = find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_copilot")
simDR_acf_descrip                       = find_dataref("sim/aircraft/view/acf_descrip")
simDR_hsi_course_copilot                = find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_copilot")
simDR_elevator_trim                     = find_dataref("sim/cockpit2/controls/elevator_trim")
simDR_gps530_power                      = find_dataref("sim/cockpit2/radios/actuators/gps_power")
simDR_gps430_power                      = find_dataref("sim/cockpit2/radios/actuators/gps2_power")
simDR_fan			                    = find_dataref("sim/operation/sound/fan_volume_ratio")
simDR_all_gear_on_ground		        = find_dataref("sim/flightmodel/failures/onground_all")
simDR_prop_ice_per_engine		        = find_dataref("sim/flightmodel/failures/prop_ice_per_engine")
simDR_gear_on_ground			        = find_dataref("sim/flightmodel2/gear/on_ground")
simDR_groundspeed                       = find_dataref("sim/flightmodel/position/groundspeed") --1 Meter/second = 1.94384449 Knot 
simDR_cabindoor                         = find_dataref("sim/cockpit2/switches/door_open[0]")
simDR_generator1_amps                   = find_dataref("sim/cockpit2/electrical/generator_amps[0]")
simDR_generator2_amps                   = find_dataref("sim/cockpit2/electrical/generator_amps[1]") -- @pilotmarcog corrected generator instance
simDR_weather_alpha                     = find_dataref("sim/cockpit/switches/EFIS_weather_alpha")
simDR_pulse                             = find_dataref("sim/graphics/animation/airport_beacon_rotation")
simDR_starter1_running                  = find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
simDR_starter2_running                  = find_dataref("sim/flightmodel2/engines/starter_is_running[1]")
simDR_gear_deploy_ratio   		        = find_dataref("sim/flightmodel2/gear/deploy_ratio")
simDR_head_pos_z 		                = find_dataref("sim/aircraft/view/acf_peZ")                 --IBAV8N, fore/aft head position
simDR_view_is_external                  = find_dataref("sim/graphics/view/view_is_external")
simDR_volume_engine                     = find_dataref("sim/operation/sound/engine_volume_ratio")
simDR_volume_environment                = find_dataref("sim/operation/sound/enviro_volume_ratio")
simDR_volume_interior                   = find_dataref("sim/operation/sound/interior_volume_ratio")
simDR_heat_on_window_pilot_norm         = find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[0]")     --IBAV8N May30-24
simDR_heat_on_window_copilot_norm       = find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[1]")     --IBAV8N May30-24
simDR_heat_on_window_pilot_hi           = find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[2]")     --IBAV8N May30-24
simDR_heat_on_window_copilot_hi         = find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[3]")     --IBAV8N May30-24
simDR_prop_rpm_left                     = find_dataref("sim/cockpit2/engine/indicators/prop_speed_rpm[0]")
simDR_prop_rpm_right                    = find_dataref("sim/cockpit2/engine/indicators/prop_speed_rpm[1]")
simDR_flaps1                            = find_dataref("sim/flightmodel2/wing/flap1_deg[0]")
simDR_flaps2                            = find_dataref("sim/flightmodel2/wing/flap1_deg[1]")
simDR_flaprqst                          = find_dataref("sim/flightmodel/controls/flaprqst")         --IBAV8N Aug23-23, added for gear horn
simDR_left_brake_ratio                  = find_dataref("sim/cockpit2/controls/left_brake_ratio")    --left brake if pedals available
simDR_right_brake_ratio                 = find_dataref("sim/cockpit2/controls/right_brake_ratio")   --right brake if pedals available
simDR_parking_brake                     = find_dataref("sim/flightmodel/controls/parkbrake")	    --both brakes medium is 0.316 parking is 1
simDR_rvs_not_ready                     = find_dataref("sim/cockpit2/annunciators/reverser_not_ready[1]")
simDR_reversed_pitch                    = find_dataref("sim/aircraft/prop/acf_reversed_pitch")
simDR_torque_L                          = find_dataref("sim/flightmodel/engine/ENGN_TRQ[0]")
simDR_torque_R                          = find_dataref("sim/flightmodel/engine/ENGN_TRQ[1]")
simDR_engine_itt_L                      = find_dataref("sim/cockpit2/engine/indicators/ITT_deg_cel[0]")
simDR_engine_itt_R                      = find_dataref("sim/cockpit2/engine/indicators/ITT_deg_cel[1]")
simDR_mixture_ratio_L                   = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[0]")
simDR_mixture_ratio_R                   = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[1]")
simDR_fan_setting                       = find_dataref("sim/cockpit2/pressurization/actuators/fan_setting")
simDR_fan_speed                         = find_dataref("sim/cockpit2/pressurization/indicators/fan_speed")
simDR_ongrass_left                      = find_dataref("sim/flightmodel2/gear/on_grass[1]")         --IBAV8N, May16-21, wheel 0 is the nose gear
simDR_ongrass_right                     = find_dataref("sim/flightmodel2/gear/on_grass[2]")
simDR_onnoisy_left                      = find_dataref("sim/flightmodel2/gear/on_noisy[1]")
simDR_onnoisy_right                     = find_dataref("sim/flightmodel2/gear/on_noisy[2]")
simDR_engine_antiice_left               = find_dataref("sim/cockpit2/ice/anti_ice_engine_air[0]")
simDR_engine_antiice_right              = find_dataref("sim/cockpit2/ice/anti_ice_engine_air[1]")
simDR_wiper_speed                       = find_dataref("sim/cockpit2/switches/wiper_speed")     --IBAV8N, Apr18-21
simDR_transponder_code                  = find_dataref("sim/cockpit/radios/transponder_code")   --IBAV8N, Mar7-21
simDR_nav1_dme_time_min                 = find_dataref("sim/cockpit2/radios/indicators/nav1_dme_time_min")  --IBAV8N, Feb26
simDR_gps_dme_time_min                  = find_dataref("sim/cockpit2/radios/indicators/gps_dme_time_min")   --IBAV8N, Feb26
simDR_itt_max                           = find_dataref("sim/aircraft/engine/acf_max_ITT")
simDR_battery_charge                    = find_dataref("sim/cockpit/electrical/battery_charge_watt_hr") --IBAV8N, Jan25-21
simDR_battery_0                         = find_dataref("sim/cockpit2/electrical/battery_on[0]")     --IBAV8N, setting main battery switch to index 0
simDR_battery_1                         = find_dataref("sim/cockpit2/electrical/battery_on[1]")     --IBAV8N, hot battery bus for ovhd emerg lights
simDR_battery_2                         = find_dataref("sim/cockpit2/electrical/battery_on[2]")     --IBAV8N, hot battery bus for ground comm
simDR_battery_3                         = find_dataref("sim/cockpit2/electrical/battery_on[3]")     --IBAV8N Aug28-22, battery for EFIS AUX
simDR_battery_4                         = find_dataref("sim/cockpit2/electrical/battery_on[4]")     --IBAV8N Aug24-23, hot bus for fuel pumps
simDR_ice_inlet_heat_L	                = find_dataref("sim/cockpit2/ice/ice_inlet_heat_on_per_engine[0]") --IBAV8N, Jan19-21
simDR_ice_inlet_heat_R	                = find_dataref("sim/cockpit2/ice/ice_inlet_heat_on_per_engine[1]") --IBAV8N, Jan19-21
simDR_battery_on	                    = find_dataref("sim/cockpit/electrical/battery_on") --IBAV8N, Jan27 this indicates panel battery switch is on
simDR_compass                           = find_dataref("sim/cockpit/misc/compass_indicated")
simDR_actual_volts	                    = find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts") --IBAV8N, Apr24-21
simDR_com1_power	                    = find_dataref("sim/cockpit2/radios/actuators/com1_power") --IBAV8N, Jan4-21
simDR_com2_power	                    = find_dataref("sim/cockpit2/radios/actuators/com2_power") --IBAV8N
simDR_nav1_power	                    = find_dataref("sim/cockpit2/radios/actuators/nav1_power") --IBAV8N
simDR_nav2_power	                    = find_dataref("sim/cockpit2/radios/actuators/nav2_power") --IBAV8N
simDR_adf1_power	                    = find_dataref("sim/cockpit2/radios/actuators/adf1_power") --IBAV8N
simDR_adf2_power	                    = find_dataref("sim/cockpit2/radios/actuators/adf2_power") --IBAV8N, Apr22-21
simDR_beta_rev_ratio_L	                = find_dataref("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio[0]")
simDR_beta_rev_ratio_R	                = find_dataref("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio[1]")
simDR_beta_rev_ratio_all	            = find_dataref("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio_all") --IBAV8N, metric to provide lockout to beta function
simDR_artstab_heading	                = find_dataref("sim/joystick/artstab_heading_ratio")  --IBAV8N, for rudder boost function, will alter rudder center left or right
simDR_prop_mode_L			            = find_dataref("sim/cockpit2/engine/actuators/prop_mode[0]")    --IBAV8N Read whether prop is norm/beta/reverse
simDR_prop_mode_R			            = find_dataref("sim/cockpit2/engine/actuators/prop_mode[1]")    --IBAV8N
simDR_override_artstab                  = find_dataref("sim/operation/override/override_artstab") --IBAV8N Set to 1 to override artstab, for rudder boost function
simDR_ehsi_range 				        = find_dataref("sim/cockpit/switches/EFIS_map_range_selector")
simDR_startup_running			        = find_dataref("sim/operation/prefs/startup_running")
simDR_time_paused  				        = find_dataref("sim/time/paused")
simDR_indicator_alt_alert_lit	        = find_dataref("sim/cockpit2/gauges/indicators/baro_altimeter_alert_lit_pilot")
simDR_oat_degf					        = find_dataref("sim/cockpit2/temperature/outside_air_temp_degf")
simDR_bleed_air_mode			        = find_dataref("sim/cockpit2/pressurization/actuators/bleed_air_mode")    		-- 0=off, 1=left, 2=both, 3=right, 4=apu, 5=auto
simDR_bus_volts 				        = find_dataref("sim/cockpit2/electrical/bus_volts")
simDR_plugin_bus_load_amps		        = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps")
simDR_prop_heat					        = find_dataref("sim/cockpit2/ice/ice_prop_heat_on_per_engine")
simDR_engine_N1_pct				        = find_dataref("sim/cockpit2/engine/indicators/N1_percent")
simDR_altitude_ft_pilot				    = find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
simDR_altitude_ft_copilot			    = find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_copilot")
simDR_altitude_ft_stby		            = find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_stby")
simDR_airspeed					        = find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
simDR_inverter_on				        = find_dataref("sim/cockpit2/electrical/inverter_on")
simDR_auto_ignite_on			        = find_dataref("sim/cockpit2/engine/actuators/auto_ignite_on")
simDR_ice_surfce_heat_on			    = find_dataref("sim/cockpit2/ice/ice_surfce_heat_on")                           --IBAV8N, Mar11-22, status of wing heat
simDR_no_smoking_switch			        = find_dataref("sim/cockpit2/switches/no_smoking")
simDR_seat_belts_switch			        = find_dataref("sim/cockpit2/switches/fasten_seat_belts")
simDR_com1_audio_vol			        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_com1")
simDR_com2_audio_vol			        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_com2")
simDR_nav1_audio_vol			        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav1")
simDR_nav2_audio_vol			        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav2")
simDR_adf1_audio_vol			        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf1")
simDR_dme_audio_vol				        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme")
simDR_mkr_audio_vol				        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_mark")
simDR_audio_volume_dme1			        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme1")
simDR_audio_volume_dme2			        = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme2")
simDR_fuel_pressure_psi			        = find_dataref("sim/cockpit2/engine/indicators/fuel_pressure_psi")
simDR_oil_pressure_psi			        = find_dataref("sim/cockpit2/engine/indicators/oil_pressure_psi")
simDR_annun_engine_fire			        = find_dataref("sim/cockpit2/annunciators/engine_fires")
simDR_annun_cabin_alt_hi		        = find_dataref("sim/cockpit2/annunciators/cabin_altitude_12500")
simDR_annun_fuel_transfer		        = find_dataref("sim/cockpit/warnings/annunciators/fuel_transfer")
simDR_annun_fuel_crossfeed		        = find_dataref("sim/cockpit2/annunciators/crossfeed_on")
simDR_door_open_ratio			        = find_dataref("sim/flightmodel2/misc/door_open_ratio")
simDR_annun_generator_off		        = find_dataref("sim/cockpit2/annunciators/generator_off")
simDR_prop_rot_speed_actuator 	        = find_dataref("sim/cockpit2/engine/actuators/prop_rotation_speed_rad_sec")
simDR_annun_chip_detected		        = find_dataref("sim/cockpit2/annunciators/chip_detected")
simDR_annun_ice_vane_extend		        = find_dataref("sim/cockpit2/annunciators/ice_vane_extend")
simDR_annun_ice_vane_fail		        = find_dataref("sim/cockpit2/annunciators/ice_vane_fail")
simDR_cross_tie					        = find_dataref("sim/cockpit2/electrical/cross_tie")
simDR_annun_igniter_on			        = find_dataref("sim/cockpit2/annunciators/igniter_on")
simDR_annun_autofeather_arm		        = find_dataref("sim/cockpit2/annunciators/auto_feather_arm")
simDR_prop_feather_mode_switch	        = find_dataref("sim/cockpit2/switches/prop_feather_mode")
simDR_hyd_fluid_ratio			        = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_1")
simDR_battery_amps				        = find_dataref("sim/cockpit2/electrical/battery_amps")
simDR_gpu_on					        = find_dataref("sim/cockpit/electrical/gpu_on")
simDR_taxi_light_switch		            = find_dataref("sim/cockpit2/switches/taxi_light_on")
simDR_landing_light_switch		        = find_dataref("sim/cockpit2/switches/landing_lights_switch")
simDR_photo_auto_atten			        = find_dataref("sim/graphics/misc/photo_auto_atten")                            --used in lighting.lua
simDR_switch_panel_brightness_ratio	    = find_dataref("sim/cockpit2/switches/panel_brightness_ratio")
simDR_switch_instr_brightness_ratio     = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio")
simDR_generic_lights_switch		        = find_dataref("sim/cockpit2/switches/generic_lights_switch")
simDR_instr_brightness_ratio		    = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio")           --used in lighting.lua
simDR_instr_brightness_ratio_man	    = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual")    --used in lighting.lua
simDR_engine_running			        = find_dataref("sim/flightmodel/engine/ENGN_running")
simDR_radio_nav1_type   			    = find_dataref("sim/cockpit2/radios/indicators/nav1_type")
simDR_hsi_source_sel_pilot		        = find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_pilot")
simDR_hsi_display_horizontal 	        = find_dataref("sim/cockpit2/radios/indicators/hsi_display_horizontal_pilot")
simDR_radio_alt_bug_ft_pilot	        = find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_pilot")
simDR_radio_altitude_ft			        = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
simDR_EFIS_1_sel_pilot			        = find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_pilot")
simDR_EFIS_2_sel_pilot			        = find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_pilot")
simDR_EFIS_map_mode				        = find_dataref("sim/cockpit2/EFIS/map_mode")
simDR_EFIS_is_HSI				        = find_dataref("sim/cockpit2/EFIS/map_mode_is_HSI")
simDR_EFIS_map_range			        = find_dataref("sim/cockpit2/EFIS/map_range")
simDR_EFIS_weather_on			        = find_dataref("sim/cockpit2/EFIS/EFIS_weather_on")
simDR_EFIS_tcas_on				        = find_dataref("sim/cockpit2/EFIS/EFIS_tcas_on")
simDR_EFIS_airport_on			        = find_dataref("sim/cockpit2/EFIS/EFIS_airport_on")
simDR_EFIS_fix_on				        = find_dataref("sim/cockpit2/EFIS/EFIS_fix_on")
simDR_EFIS_vor_on				        = find_dataref("sim/cockpit2/EFIS/EFIS_vor_on")
simDR_EFIS_ndb_on				        = find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on")
simDR_fuel_firewall_vlv_L		        = find_dataref("sim/cockpit2/fuel/firewall_closed_left")
simDR_fuel_firewall_vlv_R		        = find_dataref("sim/cockpit2/fuel/firewall_closed_right")
simDR_autopilot_heading_status	        = find_dataref("sim/cockpit2/autopilot/heading_status")
simDR_autopilot_nav_status		        = find_dataref("sim/cockpit2/autopilot/nav_status")
simDR_autopilot_approach_status	        = find_dataref("sim/cockpit2/autopilot/approach_status")
simDR_autopilot_glideslope_status       = find_dataref("sim/cockpit2/autopilot/glideslope_status")
simDR_autopilot_backcrs_status	        = find_dataref("sim/cockpit2/autopilot/backcourse_status")
simDR_autopilot_speed_status	        = find_dataref("sim/cockpit2/autopilot/speed_status")
simDR_autopilot_vvi_status		        = find_dataref("sim/cockpit2/autopilot/vvi_status")
simDR_autopilot_alt_hold_status	        = find_dataref("sim/cockpit2/autopilot/altitude_hold_status")
simDR_autopilot_alt_dial_ft		        = find_dataref("sim/cockpit2/autopilot/altitude_dial_ft")
simDR_autopilot_airspeed_dial_kts       = find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts")
simDR_autopilot_vvi_dial_fpm	        = find_dataref("sim/cockpit2/autopilot/vvi_dial_fpm")
simDR_autopilot_TOGA_lat_status	        = find_dataref("sim/cockpit2/autopilot/TOGA_lateral_status")
simDR_autopilot_TOGA_vert_status        = find_dataref("sim/cockpit2/autopilot/TOGA_status")
simDR_autopilot_DR_status 		        = find_dataref("sim/cockpit2/autopilot/dead_reckoning")
simDR_autopilot_yaw_damper_on	        = find_dataref("sim/cockpit2/switches/yaw_damper_on")
simDR_autopilot_ready 			        = find_dataref("sim/cockpit2/autopilot/otto_ready")
simDR_autopilot_climb_adjust	        = find_dataref("sim/cockpit2/autopilot/climb_adjust")
simDR_autopilot_des_adjust		        = find_dataref("sim/cockpit2/autopilot/des_adjust")
simDR_autopilot_on_or_cws		        = find_dataref("sim/cockpit2/autopilot/autopilot_on_or_cws")
simDR_autopilot_on				        = find_dataref("sim/cockpit2/autopilot/autopilot_on")
simDR_autopilot_fd_mode			        = find_dataref("sim/cockpit2/autopilot/flight_director_mode")
simDR_autopilot_test_ap_lit 	        = find_dataref("sim/cockpit/warnings/autopilot_test_ap_lit")
simDR_autopilot_trim_down		        = find_dataref("sim/cockpit2/annunciators/autopilot_trim_down")
simDR_autopilot_trim_up			        = find_dataref("sim/cockpit2/annunciators/autopilot_trim_up")
simDR_autopilot_trim_fail		        = find_dataref("sim/cockpit2/annunciators/autopilot_trim_fail")
simDR_autopilot_half_bank		        = find_dataref("sim/cockpit2/annunciators/autopilot_bank_limit")
simDR_autopilot_soft_ride		        = find_dataref("sim/cockpit2/annunciators/autopilot_soft_ride")
simDR_gauges_ind_vvi_fpm		        = find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
simDR_pressure_cabin_alt_ft		        = find_dataref("sim/cockpit2/pressurization/actuators/cabin_altitude_ft")
simDR_pressure_cabin_vvi_fpm	        = find_dataref("sim/cockpit2/pressurization/actuators/cabin_vvi_fpm")
simDR_cabin_pressure_differential_psi   = find_dataref("sim/cockpit/pressure/cabin_pressure_differential_psi")
simDR_pressure_dump_all_on		        = find_dataref("sim/cockpit2/pressurization/actuators/dump_all_on")
simDR_air_cond_on				        = find_dataref("sim/cockpit2/pressurization/actuators/air_cond_on")
simDR_pressure_heater_on		        = find_dataref("sim/cockpit2/pressurization/actuators/heater_on")
simDR_kill_EFIS_map_line		        = find_dataref("sim/graphics/misc/kill_map_fms_line")
simDR_radio_nav1_bearing_deg	        = find_dataref("sim/cockpit2/radios/indicators/nav1_bearing_deg_mag")
simDR_radio_nav2_bearing_deg	        = find_dataref("sim/cockpit2/radios/indicators/nav2_bearing_deg_mag")       --IBAV8N, Sept24-23, for G1000 CRS2 sync
simDR_gps_bearing_deg	                = find_dataref("sim/cockpit2/radios/indicators/gps_bearing_deg_mag")
simDR_nav1_obs_degm		                = find_dataref("sim/cockpit/radios/nav1_obs_degm")
simDR_gps_obs_degm		                = find_dataref("sim/cockpit/radios/gps_obs_degm")
simDR_radio_nav1_OBS_deg_co		        = find_dataref("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_copilot")    --IBAV8N, Apr23-21
simDR_radio_nav2_OBS_deg		        = find_dataref("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot")
simDR_radio_nav2_OBS_deg_co		        = find_dataref("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_copilot")    --IBAV8N, Apr24-21
simDR_annun_ap_disco			        = find_dataref("sim/cockpit2/annunciators/autopilot_disconnect")
simDR_avionics_power_on                 = find_dataref("sim/cockpit/electrical/avionics_on")
simDR_gear_handle_down			        = find_dataref("sim/cockpit2/controls/gear_handle_down")
simDR_transponder_mode			        = find_dataref("sim/cockpit2/radios/actuators/transponder_mode")		    -- off=0, stdby=1, on=2, alt=3, test=4, 5=ground
simDR_gyro_free_slaved			        = find_dataref("sim/cockpit/gyros/gyr_free_slaved")
simDR_radio_dme_freq_hz			        = find_dataref("sim/cockpit2/radios/actuators/dme_frequency_hz")
simDR_radio_nav1_stby_freq_hz	        = find_dataref("sim/cockpit2/radios/actuators/nav1_standby_frequency_hz")
simDR_vvi_step_ft				        = find_dataref("sim/aircraft/autopilot/vvi_step_ft")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
print("EVO: 3. LOADING 3rd Party DataRefs")
simDR_avitab_enabled			        = find_dataref("avitab/panel_enabled")
simDR_avitab_power				        = find_dataref("avitab/panel_powered")
simDR_fseconomy_connected			    = find_dataref("fse/status/connected")
simDR_fseconomy_started				    = find_dataref("fse/status/flying")
simDR_fseconomy_finish				    = find_dataref("fse/status/canendflight")
simDR_pilotedge_transmit_com1		    = find_dataref("pilotedge/radio/tx_status_com1")
simDR_pilotedge_transmit_com2		    = find_dataref("pilotedge/radio/tx_status_com2")
simDR_pilotedge_receive_com1		    = find_dataref("pilotedge/radio/rx_status_com1")
simDR_pilotedge_receive_com2		    = find_dataref("pilotedge/radio/rx_status_com2")
simDR_pilotedge_connected			    = find_dataref("pilotedge/status/connected")
simDR_xpilot_com1_rx			        = find_dataref("xpilot/audio/com1_rx")
simDR_xpilot_com2_rx			        = find_dataref("xpilot/audio/com2_rx")
simDR_xpilot_status			            = find_dataref("xpilot/login/status")                                       --1 if connected
simDR_xpilot_ptt			            = find_dataref("xpilot/ptt")
simDR_xpilot_callsign			        = find_dataref("xpilot/login/callsign")

if simDR_acf_descrip == "C90B - G1000, Blackhawk" then                                                              --IMC SEPT10-23
-- IMC g1000 PFD/MFD power on/off
    imc_pfd1_on                         = find_dataref("imc/g1000/pfd1_on")
    imc_pfd2_on                         = find_dataref("imc/g1000/pfd2_on")
    imc_mfd_on                          = find_dataref("imc/g1000/mfd_on")
end
--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--
print("EVO: 4. LOADING X-Plane Commands")
simCMD_left_xfer_dn			            = find_command("sim/fuel/left_xfer_dn")
simCMD_right_xfer_dn			        = find_command("sim/fuel/right_xfer_dn")
simCMD_flightplan                       = find_command("sim/GPS/g430n1_fpl")
simCMD_menu                             = find_command("sim/GPS/g430n1_menu")
simCMD_down                             = find_command("sim/GPS/g430n1_chapter_up")
simCMD_enter                            = find_command("sim/GPS/g430n1_ent")
simCMD_generator_L_off				    = find_command("sim/electrical/generator_1_off")
simCMD_generator_R_off				    = find_command("sim/electrical/generator_2_off")
simCMD_generator_L_on				    = find_command("sim/electrical/generator_1_on")
simCMD_generator_R_on				    = find_command("sim/electrical/generator_2_on")
simCMD_generator_L_reset			    = find_command("sim/electrical/generator_1_reset")
simCMD_generator_R_reset			    = find_command("sim/electrical/generator_2_reset")
simCMD_engage_starter_L				    = find_command("sim/starters/engage_starter_1")
simCMD_engage_starter_R				    = find_command("sim/starters/engage_starter_2")
simCMD_igniter_off_L				    = find_command("sim/igniters/igniter_contin_off_1")
simCMD_igniter_off_R				    = find_command("sim/igniters/igniter_contin_off_2")
simCMD_igniter_on_L					    = find_command("sim/igniters/igniter_contin_on_1")
simCMD_igniter_on_R					    = find_command("sim/igniters/igniter_contin_on_2")
simCMD_window_heat_tog		            = find_command("sim/ice/window_heat_tog")
simCMD_window2_heat_tog		            = find_command("sim/ice/window2_heat_tog")
simCMD_seatbelt_sign_toggle			    = find_command("sim/systems/seatbelt_sign_toggle")
simCMD_no_smoking_toggle			    = find_command("sim/systems/no_smoking_toggle")
simCMD_bleed_air_on_L				    = find_command("sim/bleed_air/bleed_air_left_on")
simCMD_bleed_air_off_L				    = find_command("sim/bleed_air/bleed_air_left_off")
simCMD_bleed_air_on_R				    = find_command("sim/bleed_air/bleed_air_right_on")
simCMD_bleed_air_off_R				    = find_command("sim/bleed_air/bleed_air_right_off")
simCMD_autopilot_fdir_on			    = find_command("sim/autopilot/fdir_on")
simCMD_autopilot_fdir_off	            = find_command("sim/autopilot/servos_fdir_off")     --IBAV8N, Apr2-22, disco FD
simCMD_pressurization_test			    = find_command("sim/pressurization/test")
simCMD_pressurization_aircon_on		    = find_command("sim/pressurization/aircond_on")
simCMD_pressurization_aircon_off	    = find_command("sim/pressurization/aircond_off")
simCMD_dump_cabin_press_on			    = find_command("sim/pressurization/dump_on")
simCMD_dump_cabin_press_off			    = find_command("sim/pressurization/dump_off")
simCMD_com1_freq_flip				    = find_command("sim/radios/com1_standy_flip")
simCMD_com2_freq_flip				    = find_command("sim/radios/com2_standy_flip")
simCMD_nav1_freq_flip				    = find_command("sim/radios/nav1_standy_flip")
simCMD_nav2_freq_flip				    = find_command("sim/radios/nav2_standy_flip")
simCMD_adf_freq_flip				    = find_command("sim/radios/adf1_standy_flip")
simCMD_sys_overspd_test				    = find_command("sim/systems/overspeed_test")
simCMD_xmit_audio_com1_man			    = find_command("sim/audio_panel/transmit_audio_com1_man")
simCMD_xmit_audio_com2_man			    = find_command("sim/audio_panel/transmit_audio_com2_man")

--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS             			    	 **--
--*************************************************************************************--
print("EVO: 5. LOADING 3rd Party Commands")
simCMD_fseconomy_connect                = find_command("fse/server/connect")
simCMD_fseconomy_start                  = find_command("fse/flight/start")
simCMD_fseconomy_finish                 = find_command("fse/flight/finish")
simCMD_pilotedge_connect	            = find_command("PilotEdge/Connect")
simCMD_pilotedge_disconnect	            = find_command("PilotEdge/Disconnect")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
print("EVO: 6. LOADING Read-Only Custom DataRefs")
C90DR_avionics_EFIS_show_wind				        = create_dataref("laminar/c90/avionics/display/show_wind", "number")
C90DR_switch_pos_master_warning				        = create_dataref("laminar/c90/warning/switch_pos/master_warning", "number")
C90DR_switch_pos_master_caution				        = create_dataref("laminar/c90/warning/switch_pos/master_caution", "number")
C90DR_switch_pos_annun_test_on				        = create_dataref("laminar/c90/electrical/switch_pos/annun_test_on", "number")
C90DR_tailnum                           			= create_dataref("c90_evo/callsign", "string")
C90DR_quadrant_levers_hidden                        = create_dataref("c90_evo/quadrant_levers_hidden", "number")                        --IMC JAN16-24
C90DR_stall_warn_heat_pos                           = create_dataref("c90_evo/iceRain/switch/stall_warn_heat_pos", "number")
C90DR_power                                         = create_dataref("laminar/c90/electrical/power", "number")
C90DR_icing_not_present				                = create_dataref("imc/icing_not_present", "number")
C90DR_avionics_mic_sel_switch_pos_pilot				= create_dataref("laminar/c90/avionics/switch/mic_sel_pos_pilot", "number")
C90DR_avionics_mic_sel_switch_pos_copilot			= create_dataref("laminar/c90/avionics/switch/mic_sel_pos_copilot", "number")
C90DR_avionics_com1_audio_switch_pos_pilot		    = create_dataref("laminar/c90/avionics/switch/com1_audio_pos_pilot", "number")      --IBAV8N,Jun17-21 makes these programmable
C90DR_avionics_com2_audio_switch_pos_pilot		    = create_dataref("laminar/c90/avionics/switch/com2_audio_pos_pilot", "number")
C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot		= create_dataref("laminar/c90/avionics/switch/mkr_bkn1_audio_pos_pilot", "number")
C90DR_avionics_mkr_audio_bkn2_switch_pos_pilot		= create_dataref("laminar/c90/avionics/switch/mkr_bkn2_audio_pos_pilot", "number")
C90DR_avionics_mic_sel_dial_pos_pilot				= create_dataref("laminar/c90/avionics/dial/mic_sel_pos_pilot", "number")
C90DR_avionics_auto_comm_switch_pos_pilot			= create_dataref("laminar/c90/avionics/switch/autocom_switch_pos_pilot", "number")
C90DR_avionics_audio_spkr_switch_pos_pilot			= create_dataref("laminar/c90/avionics/switch/audio_spkr_pos_pilot", "number")
C90DR_avionics_audio_emer_norm_switch_pos			= create_dataref("laminar/c90/avionics/switch/audio_emer_norm_pos", "number")
C90DR_avionics_voice_range_switch_pos_pilot			= create_dataref("laminar/c90/avionics/switch/voice_range_pos_pilot", "number")
C90DR_avionics_dme_channel_sel_switch_pos			= create_dataref("laminar/c90/avionics/switch/dme_channel_sel_pos", "number")
C90DR_avionics_encd_atim_sel_switch_pos				= create_dataref("laminar/c90/avionics/switch/encd_atim_sel_pos", "number")
C90DR_avionics_grd_pwr_comm_switch_pos				= create_dataref("laminar/c90/avionics/switch/grd_pwr_comm_pos", "number")
C90DR_autopilot_altAlert_canx_switch_pos			= create_dataref("laminar/c90/autopilot/switch/altAlert_canx_pos", "number")
C90DR_autopilot_altSel100_switch_pos				= create_dataref("laminar/c90/autopilot/switch/altSel100_pos", "number")
C90DR_avionics_com1_audio_switch_pos_copilot		= create_dataref("laminar/c90/avionics/switch/com1_audio_pos_copilot", "number")
C90DR_avionics_com2_audio_switch_pos_copilot		= create_dataref("laminar/c90/avionics/switch/com2_audio_pos_copilot", "number")
C90DR_avionics_nav1_audio_switch_pos_copilot		= create_dataref("laminar/c90/avionics/switch/nav1_audio_pos_copilot", "number")
C90DR_avionics_nav2_audio_switch_pos_copilot		= create_dataref("laminar/c90/avionics/switch/nav2_audio_pos_copilot", "number")
C90DR_avionics_mkr_audio_bkn1_switch_pos_copilot	= create_dataref("laminar/c90/avionics/switch/mkr_bkn1_audio_pos_copilot", "number")
C90DR_avionics_mkr_audio_bkn2_switch_pos_copilot	= create_dataref("laminar/c90/avionics/switch/mkr_bkn2_audio_pos_copilot", "number")
C90DR_avionics_dme_audio_switch_pos_copilot			= create_dataref("laminar/c90/avionics/switch/dme_audio_pos_copilot", "number")
C90DR_avionics_adf1_audio_switch_pos_copilot		= create_dataref("laminar/c90/avionics/switch/adf1_audio_pos_copilot", "number")
C90DR_avionics_auto_comm_switch_pos_copilot			= create_dataref("laminar/c90/avionics/switch/autocom_switch_pos_copilot", "number")
C90DR_avionics_voice_range_switch_pos_copilot		= create_dataref("laminar/c90/avionics/switch/voice_range_pos_copilot", "number")
C90DR_avionics_hot_intph_switch_pos					= create_dataref("laminar/c90/avionics/switch/hot_intph_pos", "number")
C90DR_avionics_gps_power_switch_pos		            = create_dataref("laminar/c90/avionics/switch/audio_spkr_pos_copilot", "number") --IBAV8N,Jan19-21
C90DR_avionics_mic_sel_dial_pos_copilot				= create_dataref("laminar/c90/avionics/dial/mic_sel_pos_copilot", "number")
C90DR_avionics_mkr_bkn_sense_switch_pos				= create_dataref("laminar/c90/avionics/switch/mkr_bkn_sense_pos", "number")
C90DR_avionics_annun_brt_switch_pos					= create_dataref("laminar/c90/avionics/switch/annun_brt_pos", "number")
C90DR_dh_lit_pilot                                  = create_dataref("laminar/c90/lighting/annun/dh_lit_pilot", "number")--IBAV8N, Apr26-22, for making DH light flash, per POH
C90DR_battery_tie		                            = create_dataref("laminar/c90/electrical/battery_tie", "number")
C90DR_gen_tie_L		                                = create_dataref("laminar/c90/electrical/gen_tie_L", "number")
C90DR_gen_tie_R		                                = create_dataref("laminar/c90/electrical/gen_tie_R", "number")
C90DR_man_close		                                = create_dataref("laminar/c90/electrical/man_close", "number")
C90DR_starter_relay_L                               = create_dataref("laminar/c90/electrical/starter_relay_L", "number")
C90DR_starter_relay_R                               = create_dataref("laminar/c90/electrical/starter_relay_R", "number")
C90DR_ctr_sense                                     = create_dataref("laminar/c90/electrical/ctr_sense", "number")
C90DR_gen_sense_L                                   = create_dataref("laminar/c90/electrical/gen_sense_L", "number")
C90DR_gen_sense_R                                   = create_dataref("laminar/c90/electrical/gen_sense_R", "number")
C90DR_gen_bus_voltage_L	                            = create_dataref("laminar/c90/electrical/gen_bus_voltage_L", "number")
C90DR_gen_bus_voltage_R	                            = create_dataref("laminar/c90/electrical/gen_bus_voltage_R", "number")
C90DR_ctr_bus_voltage	                            = create_dataref("laminar/c90/electrical/ctr_bus_voltage", "number")
C90DR_tpl_fed_bus_voltage	                        = create_dataref("laminar/c90/electrical/tpl_fed_bus_voltage", "number")
C90DR_electrical_annun_test_on		                = create_dataref("laminar/c90/electrical/switch/annun_test_on", "number")
C90DR_lighting_annun_master_warning				    = create_dataref("laminar/c90/lighting/annun/master_warning", "number") --IBAV8N, new master caut/warn panel lights
C90DR_lighting_annun_master_caution				    = create_dataref("laminar/c90/lighting/annun/master_caution", "number")
C90DR_avionics_ctl62_adf_act	                    = create_dataref("laminar/c90/avionics/ctl62/adf/act", "number")
C90DR_avionics_ctl62_adf_sto_index	                = create_dataref("laminar/c90/avionics/ctl62/adf/store_index", "number")
C90DR_avionics_ctl62_adf_act_stby	                = create_dataref("laminar/c90/avionics/ctl62/adf/act_stdby_freq_hz", "number")
C90DR_avionics_cur_crs_sel_index 		            = create_dataref("laminar/c90/avionics/display/cur_crs_sel_index", "number")
C90DR_avionics_crs_sel_cycle_index 	                = create_dataref("laminar/c90/avionics/display/crs_sel_cycle_index", "number")
C90DR_avionics_crs_sel_cycle_active 	            = create_dataref("laminar/c90/avionics/display/crs_sel_active", "number")
C90DR_warning_gear_handle		                    = create_dataref("laminar/c90/warning/gear_handle", "number") --IBAV8N, May25-21
C90DR_avionics_EFIS_pre_crs_sel_index		        = create_dataref("laminar/c90/avionics/display/pre_crs_sel_index", "number") --IBAV8N, Mar31-21
C90DR_avionics_EFIS_pre_crs_cycle_index	            = create_dataref("laminar/c90/avionics/display/pre_crs_cycle_index", "number") --IBAV8N, Mar31-21
C90DR_avionics_EFIS_pre_sel_cycle_active 	        = create_dataref("laminar/c90/avionics/display/pre_sel_active", "number")	--IBAV8N, Mar31-21
C90DR_avionics_EFIS_pre_loc_active                  = create_dataref("laminar/c90/avionics/display/pre_loc_active", "number") --IBAV8N,Apr12-21
C90DR_avionics_EFIS_pre_loc_dsply                   = create_dataref("laminar/c90/avionics/display/pre_loc_dsply", "number") --IBAV8N,Apr12-21
C90DR_avionics_EFIS_pre_vor_active                  = create_dataref("laminar/c90/avionics/display/pre_vor_active", "number") --IBAV8N,Apr12-21
C90DR_avionics_EFIS_pre_vor_dsply                   = create_dataref("laminar/c90/avionics/display/pre_vor_dsply", "number") --IBAV8N,Apr12-21
C90DR_avionics_EFIS_pre_loc_crs					 	= create_dataref("laminar/c90/avionics/EFIS/pre_loc_crs", "number") --IBAV8N,Apr2-21
C90DR_avionics_EFIS_pre_vor_crs					  	= create_dataref("laminar/c90/avionics/EFIS/pre_vor_crs", "number") --IBAV8N,Apr2-21
C90DR_avionics_EFIS_ttg_minutes						= create_dataref("laminar/c90/avionics/EFIS/ttg_minutes", "number")         --IBAV8N, Feb26-21
C90DR_avionics_EFIS_ttg_seconds						= create_dataref("laminar/c90/avionics/EFIS/ttg_seconds", "number")         --IBAV8N, Feb26-21
C90DR_no_animation									= create_dataref("laminar/no_anm", "number")
C90DR_no_ref										= create_dataref("laminar/no_ref", "number")
C90DR_electrical_prop_amps_gauge_needle_pos			= create_dataref("laminar/c90/electrical/gauge/prop_amps_pos", "number")
C90DR_electrical_inverter_switch_pos				= create_dataref("laminar/c90/electrical/switch/inverter_pos", "number")
C90DR_electrical_auto_ignition_switch_pos_L			= create_dataref("laminar/c90/electrical/switch/autoignition_pos_L", "number")
C90DR_electrical_auto_ignition_switch_pos_R			= create_dataref("laminar/c90/electrical/switch/autoignition_pos_R", "number")
C90DR_electrical_gen_L_switch_pos					= create_dataref("laminar/c90/electrical/switch/gen1_switch_pos", "number")
C90DR_electrical_gen_R_switch_pos					= create_dataref("laminar/c90/electrical/switch/gen2_switch_pos", "number")
C90DR_electrical_bus_sense_switch_pos				= create_dataref("laminar/c90/electrical/switch/bus_sense_switch_pos", "number")
C90DR_electrical_cross_tie_switch_pos				= create_dataref("laminar/c90/electrical/switch/cross_tie_switch_pos","number") --IBAV8N, Jan23-21
C90DR_electrical_voltage_gauge				        = create_dataref("laminar/c90/electrical/gauge/voltage_gauge", "number")--+++ IBAV8N
C90DR_electrical_ac_voltage_gauge                   = create_dataref("laminar/c90/electrical/gauge/ac_voltage_gauge", "number")     --IBAV8N, Feb28-22
C90DR_fuel_firewall_switch_guard_L					= create_dataref("laminar/c90/fuel/firewall_switch_guard_L", "number")
C90DR_fuel_firewall_switch_guard_R					= create_dataref("laminar/c90/fuel/firewall_switch_guard_R", "number")
C90DR_pilots_onboard                                = create_dataref("laminar/c90/pilots_onboard", "number")    --IBAV8N Aug23-23 Pilots won't disappear if battery off and engines running
C90DR_powerplant_ign_start_switch_pos_L				= create_dataref("laminar/c90/powerplant/switch/ign_start_pos_L", "number")
C90DR_powerplant_ign_start_switch_pos_R				= create_dataref("laminar/c90/powerplant/switch/ign_start_pos_R", "number")
C90DR_powerplant_prop_gov_switch_pos				= create_dataref("laminar/c90/powerplant/switch/prop_gov_pos", "number")
C90DR_pneumatic_pressure_gauge_psi_needle_pos		= create_dataref("laminar/c90/pneumatics/gauge/pressure_psi_needle_pos", "number")
C90DR_pneumatic_gyro_suction_gauge_inHg_needle_pos	= create_dataref("laminar/c90/pneumatics/gauge/gyro_suction_needle_pos", "number")
C90DR_pneumatic_bleed_air_switch_pos_L				= create_dataref("laminar/c90/pneumatics/switch/bleed_air_pos_L", "number")
C90DR_pneumatic_bleed_air_switch_pos_R				= create_dataref("laminar/c90/pneumatics/switch/bleed_air_pos_R", "number")
C90DR_airCon_cabin_air_temp_gauge_degF_needle_pos	= create_dataref("laminar/c90/airCon/gauge/cabin_temp_needle_pos", "number")
C90DR_airCon_manual_temp_control_switch_pos			= create_dataref("laminar/c90/airCon/switch/manual_temp_control_pos", "number")
C90DR_airCon_cabin_temp_mode_dial_pos				= create_dataref("laminar/c90/airCon/dial/cabin_temp_mode_pos", "number")
C90DR_iceRain_engine_act_motor_sel_switch_pos_L		= create_dataref("laminar/c90/iceRain/switch/engine_actmotor_pos_L", "number")
C90DR_iceRain_engine_act_motor_sel_switch_pos_R		= create_dataref("laminar/c90/iceRain/switch/engine_actmotor_pos_R", "number")
C90DR_iceRain_windshield_antiice_switch_pos_L	    = create_dataref("laminar/c90/iceRain/switch/windshield_antiice_pos_L", "number")
C90DR_iceRain_windshield_antiice_switch_pos_R	    = create_dataref("laminar/c90/iceRain/switch/windshield_antiice_pos_R", "number")
C90DR_iceRain_fuel_vent_deice_switch_pos_L			= create_dataref("laminar/c90/iceRain/switch/fuelvent_deice_pos_L", "number")
C90DR_iceRain_fuel_vent_deice_switch_pos_R			= create_dataref("laminar/c90/iceRain/switch/fuelvent_deice_pos_R", "number")
C90DR_iceRain_surface_deice_switch_pos				= create_dataref("laminar/c90/iceRain/switch/surface_deice_pos", "number")
C90DR_iceRain_prop_deice_switch_pos					= create_dataref("laminar/c90/iceRain/switch/prop_deice_pos", "number")
C90DR_avionics_on_sw_pos					        = create_dataref("laminar/c90/avionics/switch/avionics_switch_pos", "number") --IBAV8N,Jan25-21 new avionics on switch
C90DR_avionics_lat_dev_display_status				= create_dataref("laminar/c90/avionics/display/lateral_deviation", "number")
C90DR_avionics_decision_height_dial_pos				= create_dataref("laminar/c90/avionics/dial/dec_ht_dial_pos", "number")
C90DR_avionics_radio_altitude						= create_dataref("laminar/c90/avionics/indicator/radio_altitude", "number")
C90DR_avionics_nav_data_sel_dial_pos			    = create_dataref("laminar/c90/avionics/dial/nav_data_sel_pos", "number")
C90DR_avionics_crs_sel_switch_pos			    	= create_dataref("laminar/c90/avionics/dial/crs_sel_pos", "number")
C90DR_avionics_brg_ptr1_sel_switch_pos				= create_dataref("laminar/c90/avionics/switch/brg_ptr1_sel_pos", "number")
C90DR_avionics_brg_ptr2_sel_switch_pos				= create_dataref("laminar/c90/avionics/switch/brg_ptr2_sel_pos", "number")
C90DR_avionics_crs_sensor_sel_dial_pos			    = create_dataref("laminar/c90/avionics/dial/crs_sensor_sel_pos", "number")
C90DR_avionics_EFIS_map_mode_sel_dial_pos			= create_dataref("laminar/c90/avionics/dial/map_mode_sel_pos", "number")
C90DR_avionics_EFIS_power_switch_pos				= create_dataref("laminar/c90/avionics/switch_pos/EFIS_power", "number")
C90DR_avionics_EFIS_rev_mode_switch_pos				= create_dataref("laminar/c90/avionics/switch_pos/EFIS_rev_mode", "number")
C90DR_avionics_EFIS_test_switch_pos					= create_dataref("laminar/c90/avionics/switch_pos/EFIS_test", "number")
C90DR_avionics_EFIS_dh								= create_dataref("laminar/c90/avionics/data/dh", "number")
C90DR_avionics_EFIS_dh_test_switch_pos				= create_dataref("laminar/c90/avionics/switch_pos/dh_test", "number")
C90DR_avionics_EFIS_timer_dial_pos					= create_dataref("laminar/c90/avionics/dial_pos/EFIS_timer", "number")
C90DR_avionics_EFIS_timer_ss_switch_pos				= create_dataref("laminar/c90/avionics/switch_pos/EFIS_timer_ss", "number")
C90DR_avionics_EFIS_et_timer						= create_dataref("laminar/c90/avionics/EFIS/et_timer", "number")
C90DR_avionics_EFIS_et_timer_mode					= create_dataref("laminar/c90/avionics/EFIS/et_timer_mode", "number")
C90DR_avionics_EFIS_et_timer_status					= create_dataref("laminar/c90/avionics/EFIS/et_timer_status", "number")
C90DR_avionics_EFIS_et_timer_seconds				= create_dataref("laminar/c90/avionics/EFIS/et_timer_seconds", "number")
C90DR_avionics_EFIS_et_timer_minutes				= create_dataref("laminar/c90/avionics/EFIS/et_timer_minutes", "number")
C90DR_avionics_EFIS_et_timer_hours					= create_dataref("laminar/c90/avionics/EFIS/et_timer_hours", "number")
C90DR_avionics_EFIS_aux_pwr_on_switch_pos			= create_dataref("laminar/c90/avionics/EFIS/switch_pos/aux_pwr_on", "number")
C90DR_avionics_EFIS_aux_horn_silence_switch_pos		= create_dataref("laminar/c90/avionics/EFIS/switch_pos/aux_horn_silence", "number")
C90DR_avionics_EFIS_aux_timer_ss_switch_pos			= create_dataref("laminar/c90/avionics/EFIS/switch_pos/EFIS_aux_timer_ss", "number")
C90DR_avionics_EFIS_fd_switch_pos					= create_dataref("laminar/c90/avionics/EFIS/switch_pos/fd", "number")
C90DR_avionics_xpdr_mode_switch_pos					= create_dataref("laminar/c90/avionics/xpdr/switch_pos/mode", "number")
C90DR_avionics_ctl62_adf_xfr_mem_switch_pos			= create_dataref("laminar/c90/avionics/ctl62/adf/switch_pos/xfr_mem", "number")
C90DR_avionics_ctl62_adf_sto_switch_pos				= create_dataref("laminar/c90/avionics/ctl62/adf/switch_pos/sto", "number")
C90DR_avionics_ctl62_adf_test_switch_pos			= create_dataref("laminar/c90/avionics/ctl62/adf/switch_pos/test", "number")
C90DR_avionics_ctl62_adf_ones_tens_dial_pos			= create_dataref("laminar/c90/avionics/ctl62/adf/dial_pos/ones_tens", "number")
C90DR_avionics_ctl62_adf_hund_thous_dial_pos		= create_dataref("laminar/c90/avionics/ctl62/adf/dial_pos/hund_thous", "number")
C90DR_avionics_ind42_power_switch_pos				= create_dataref("laminar/c90/avionics/ind42/switch_pos/power", "number")
C90DR_avionics_ind42_mode_switch_pos				= create_dataref("laminar/c90/avionics/ind42/switch_pos/mode", "number")
C90DR_avionics_ind42_channel_switch_pos				= create_dataref("laminar/c90/avionics/ind42/switch_pos/channel", "number")
C90DR_avionics_ind42_mode							= create_dataref("laminar/c90/avionics/ind42/mode", "number")
C90DR_avionics_ind42_channel						= create_dataref("laminar/c90/avionics/ind42/channel", "number")
C90DR_avionics_ind42_dash							= create_dataref("laminar/c90/avionics/ind42/dash", "string")
C90DR_fltInst_ccu65_mode_switch_pos					= create_dataref("laminar/c90/fltInst/ccu65/switch_pos/mode", "number")
C90DR_fltInst_ccu65_slew_switch_pos_up				= create_dataref("laminar/c90/fltInst/ccu65/switch_pos/slew_up", "number")
C90DR_fltInst_ccu65_slew_switch_pos_dn				= create_dataref("laminar/c90/fltInst/ccu65/switch_pos/slew_down", "number")
C90DR_autopilot_nav_status							= create_dataref("laminar/c90/autopilot/indicator/nav_status", "number")
C90DR_autopilot_heading_status					    = create_dataref("laminar/c90/autopilot/indicator/heading_status", "number")        --IBAV8N, Apr20-22, EADI flashing FD annun.
C90DR_autopilot_speed_status					    = create_dataref("laminar/c90/autopilot/indicator/speed_status", "number")          --IBAV8N, Apr20-22, EADI flashing FD annun.
C90DR_autopilot_vvi_status					        = create_dataref("laminar/c90/autopilot/indicator/vvi_status", "number")            --IBAV8N, Apr20-22, EADI flashing FD annun.
C90DR_autopilot_glideslope_status				    = create_dataref("laminar/c90/autopilot/indicator/glideslope_status", "number")     --IBAV8N, Apr20-22, EADI flashing FD annun.
C90DR_autopilot_alt_hold_status			            = create_dataref("laminar/c90/autopilot/indicator/altitude_hold_status", "number")  --IBAV8N, Apr20-22, EADI flashing FD annun.
C90DR_autopilot_DR_status			                = create_dataref("laminar/c90/autopilot/indicator/dead_reck_status", "number")  --IBAV8N, Aug3-25
C90DR_autopilot_HDG_switch_pos 						= create_dataref("laminar/c90/autopilot/switch/HDG_pos", "number")
C90DR_autopilot_NAV_switch_pos 						= create_dataref("laminar/c90/autopilot/switch/NAV_pos", "number")
C90DR_autopilot_APPR_switch_pos 					= create_dataref("laminar/c90/autopilot/switch/APPR_pos", "number")
C90DR_autopilot_BC_switch_pos  						= create_dataref("laminar/c90/autopilot/switch/BC_pos", "number")
C90DR_autopilot_CLM_switch_pos  					= create_dataref("laminar/c90/autopilot/switch/CLM_pos", "number")
C90DR_autopilot_ALT_switch_pos 						= create_dataref("laminar/c90/autopilot/switch/ALT_pos", "number")
C90DR_autopilot_ALTSEL_switch_pos					= create_dataref("laminar/c90/autopilot/switch/ALTSEL_pos", "number")
C90DR_autopilot_VS_switch_pos 						= create_dataref("laminar/c90/autopilot/switch/VS_pos", "number")
C90DR_autopilot_IAS_switch_pos 						= create_dataref("laminar/c90/autopilot/switch/IAS_pos", "number")
C90DR_autopilot_DSC_switch_pos 						= create_dataref("laminar/c90/autopilot/switch/DSC_pos", "number")
C90DR_autopilot_yaw_damper_switch_pos 				= create_dataref("laminar/c90/autopilot/switch/yaw_damper_pos", "number")
C90DR_autopilot_engage_switch_pos 					= create_dataref("laminar/c90/autopilot/switch/engage_pos", "number")
C90DR_autopilot_soft_ride_switch_pos 				= create_dataref("laminar/c90/autopilot/switch/soft_ride_pos", "number")
C90DR_autopilot_half_bank_switch_pos 				= create_dataref("laminar/c90/autopilot/switch/half_bank_pos", "number")
C90DR_autopilot_vert_control_switch_pos 			= create_dataref("laminar/c90/autopilot/switch/vert_control_pos", "number")
C90DR_autopilot_turn_knob_pos						= create_dataref("laminar/c90/autopilot/knob/turn_pos", "number")
C90DR_autopilot_annun_test_switch_pos				= create_dataref("laminar/c90/autopilot/switch_pos/annun_test", "number")
C90DR_autopilot_autopilot_disco						= create_dataref("laminar/c90/autopilot/data/autopilot_disco", "number")
C90DR_pressure_control_switch_pos					= create_dataref("laminar/c90/pressure/switch_pos/control", "number")
C90DR_pressure_cabin_alt_ind_ft						= create_dataref("laminar/c90/pressure/data/cabiin_alt", "number") --incomplete laminar function
C90DR_fltctrl_rudder_boost_switch_pos		 		= create_dataref("laminar/c90/fltctrl/switch_pos/rudder_boost", "number")
C90DR_fltctrl_elev_trim_control_switch_pos		 	= create_dataref("laminar/c90/fltctrl/switch_pos/elev_trim_control", "number")
C90DR_warning_EFIS_aux_horn_on						= create_dataref("laminar/c90/warning/EFIS/data/aux_horn_on", "number")
C90DR_lighting_cabin_brt_dim_switch_pos				= create_dataref("laminar/c90/lighting/switch/cabin_brt_dim_pos", "number")
C90DR_lighting_no_smoke_fsb_switch_pos				= create_dataref("laminar/c90/lighting/switch/no_smoke_fsb_pos", "number")
C90DR_lighting_annun_fuel_press_L					= create_dataref("laminar/c90/lighting/annun/fuel_press_L", "number")
C90DR_lighting_annun_fuel_press_R					= create_dataref("laminar/c90/lighting/annun/fuel_press_R", "number")
C90DR_lighting_annun_oil_press_L					= create_dataref("laminar/c90/lighting/annun/oil_press_L", "number")
C90DR_lighting_annun_oil_press_R					= create_dataref("laminar/c90/lighting/annun/oil_press_R", "number")
C90DR_lighting_annun_inverter						= create_dataref("laminar/c90/lighting/annun/inverter", "number")
C90DR_lighting_annun_ap_fail						= create_dataref("laminar/c90/lighting/annun/ap_fail", "number")
C90DR_lighting_annun_ap_test						= create_dataref("laminar/c90/lighting/annun/ap_test", "number")
C90DR_lighting_annun_blank					        = create_dataref("laminar/c90/lighting/annun/blank", "number")      --IBAV8N, Jul29-21, to light blank spaces on annun panel
C90DR_lighting_annun_ap_trim_fail					= create_dataref("laminar/c90/lighting/annun/ap_trim_fail", "number")
C90DR_lighting_annun_cabin_alt_hi					= create_dataref("laminar/c90/lighting/annun/cabin_alt_hi", "number")
C90DR_lighting_annun_cabin_door						= create_dataref("laminar/c90/lighting/annun/cabin_door", "number")
C90DR_lighting_annun_bleed_air					    = create_dataref("laminar/c90/lighting/annun/baggage_door", "number")
C90DR_lighting_annun_engine_fire_L					= create_dataref("laminar/c90/lighting/annun/engine_fire_L", "number")
C90DR_lighting_annun_engine_fire_R					= create_dataref("laminar/c90/lighting/annun/engine_fire_R", "number")
C90DR_lighting_annun_dc_gen_L						= create_dataref("laminar/c90/lighting/annun/dc_gen_L", "number")
C90DR_lighting_annun_dc_gen_R						= create_dataref("laminar/c90/lighting/annun/dc_gen_R", "number")
C90DR_lighting_annun_no_fuel_xfr_L					= create_dataref("laminar/c90/lighting/annun/no_fuel_xfr_L", "number")
C90DR_lighting_annun_no_fuel_xfr_R					= create_dataref("laminar/c90/lighting/annun/no_fuel_xfr_R", "number")
C90DR_lighting_annun_rvs_not_ready					= create_dataref("laminar/c90/lighting/annun/rvs_not_ready", "number")
C90DR_lighting_annun_chip_detect_L					= create_dataref("laminar/c90/lighting/annun/chip_detect_L", "number")
C90DR_lighting_annun_chip_detect_R					= create_dataref("laminar/c90/lighting/annun/chip_detect_R", "number")
C90DR_lighting_annun_eng_ice_fail_L					= create_dataref("laminar/c90/lighting/annun/eng_ice_fail_L", "number")
C90DR_lighting_annun_eng_ice_fail_R					= create_dataref("laminar/c90/lighting/annun/eng_ice_fail_R", "number")
C90DR_lighting_annun_gen_tie_open_L					= create_dataref("laminar/c90/lighting/annun/gen_tie_open_L", "number")
C90DR_lighting_annun_gen_tie_open_R					= create_dataref("laminar/c90/lighting/annun/gen_tie_open_R", "number")
C90DR_lighting_annun_bat_tie_open					= create_dataref("laminar/c90/lighting/annun/bat_tie_open", "number")
C90DR_lighting_annun_pitch_trim_off					= create_dataref("laminar/c90/lighting/annun/pitch_trim_off", "number")
C90DR_lighting_annun_ignition_on_L					= create_dataref("laminar/c90/lighting/annun/ignition_on_L", "number")
C90DR_lighting_annun_ignition_on_R					= create_dataref("laminar/c90/lighting/annun/ignition_on_R", "number")
C90DR_lighting_annun_autofeather_L					= create_dataref("laminar/c90/lighting/annun/autofeather_L", "number")
C90DR_lighting_annun_autofeather_R					= create_dataref("laminar/c90/lighting/annun/autofeather_R", "number")
C90DR_lighting_annun_engine_antiice_L				= create_dataref("laminar/c90/lighting/annun/engine_antiice_L", "number")
C90DR_lighting_annun_engine_antiice_R				= create_dataref("laminar/c90/lighting/annun/engine_antiice_R", "number")
C90DR_lighting_annun_man_ties_close					= create_dataref("laminar/c90/lighting/annun/man_ties_close", "number")
C90DR_lighting_annun_fuel_crossfeed					= create_dataref("laminar/c90/lighting/annun/fuel_crossfeed", "number")
C90DR_lighting_annun_hyd_fluid_lo					= create_dataref("laminar/c90/lighting/annun/hyd_fluid_lo", "number")
C90DR_lighting_annun_battery_charge					= create_dataref("laminar/c90/lighting/annun/battery_charge", "number")
C90DR_lighting_annun_ext_power						= create_dataref("laminar/c90/lighting/annun/ext_power", "number")
C90DR_lighting_annun_ldg_taxi_light					= create_dataref("laminar/c90/lighting/annun/ldg_taxi_light", "number")
C90DR_lighting_annun_acp_yaw_eng					= create_dataref("laminar/c90/lighting/annun/acp_yaw_eng", "number")
C90DR_lighting_annun_acp_yaw_disc					= create_dataref("laminar/c90/lighting/annun/acp_yaw_disc", "number")
C90DR_lighting_annun_acp_ap_eng						= create_dataref("laminar/c90/lighting/annun/acp_ap_eng", "number")
C90DR_lighting_annun_acp_ap_disc					= create_dataref("laminar/c90/lighting/annun/acp_ap_disc", "number")
C90DR_lighting_annun_acp_t							= create_dataref("laminar/c90/lighting/annun/acp_t", "number")
C90DR_lighting_annun_acp_ap_fail					= create_dataref("laminar/c90/lighting/annun/acp_ap_fail", "number")
C90DR_lighting_annun_acp_a							= create_dataref("laminar/c90/lighting/annun/acp_a", "number")
C90DR_lighting_annun_acp_r							= create_dataref("laminar/c90/lighting/annun/acp_r", "number")
C90DR_lighting_annun_acp_e							= create_dataref("laminar/c90/lighting/annun/acp_e", "number")
C90DR_lighting_annun_acp_half						= create_dataref("laminar/c90/lighting/annun/acp_half", "number")
C90DR_lighting_annun_acp_sr							= create_dataref("laminar/c90/lighting/annun/acp_sr", "number")
C90DR_lighting_annun_acp_trim_fail					= create_dataref("laminar/c90/lighting/annun/acp_trim_fail", "number")
C90DR_lighting_annun_acp_trim_op					= create_dataref("laminar/c90/lighting/annun/acp_trim_op", "number")
C90DR_lighting_annun_fcp_trim_fail					= create_dataref("laminar/c90/lighting/annun/fcp_trim_fail", "number")
C90DR_lighting_annun_fcp_trim_operating				= create_dataref("laminar/c90/lighting/annun/fcp_trim_operating", "number")
C90DR_lighting_annun_fcp_hdg						= create_dataref("laminar/c90/lighting/annun/fcp_hdg", "number")
C90DR_lighting_annun_fcp_nav						= create_dataref("laminar/c90/lighting/annun/fcp_nav", "number")
C90DR_lighting_annun_fcp_nav_armed					= create_dataref("laminar/c90/lighting/annun/fcp_nav_armed", "number")
C90DR_lighting_annun_fcp_dr							= create_dataref("laminar/c90/lighting/annun/fcp_dr", "number")
C90DR_lighting_annun_fcp_appr						= create_dataref("laminar/c90/lighting/annun/fcp_appr", "number")
C90DR_lighting_annun_fcp_appr_armed					= create_dataref("laminar/c90/lighting/annun/fcp_appr_armed", "number")
C90DR_lighting_annun_fcp_bc							= create_dataref("laminar/c90/lighting/annun/fcp_bc", "number")
C90DR_lighting_annun_fcp_clm						= create_dataref("laminar/c90/lighting/annun/fcp_clm", "number")
C90DR_lighting_annun_fcp_half_bank					= create_dataref("laminar/c90/lighting/annun/fcp_half_bank", "number")
C90DR_lighting_annun_fcp_soft_ride					= create_dataref("laminar/c90/lighting/annun/fcp_soft_ride", "number")
C90DR_lighting_annun_fcp_ap_fail					= create_dataref("laminar/c90/lighting/annun/fcp_ap_fail", "number")
C90DR_lighting_annun_fcp_yaw_engaged				= create_dataref("laminar/c90/lighting/annun/fcp_yaw_engaged", "number")
C90DR_lighting_annun_fcp_yaw_disco					= create_dataref("laminar/c90/lighting/annun/fcp_yaw_disco", "number")
C90DR_lighting_annun_fcp_alt						= create_dataref("laminar/c90/lighting/annun/fcp_alt", "number")
C90DR_lighting_annun_fcp_alt_sel					= create_dataref("laminar/c90/lighting/annun/fcp_alt_sel", "number")
C90DR_lighting_annun_fcp_vs							= create_dataref("laminar/c90/lighting/annun/fcp_vs", "number")
C90DR_lighting_annun_fcp_gs							= create_dataref("laminar/c90/lighting/annun/fcp_gs", "number")
C90DR_lighting_annun_fcp_gs_armed					= create_dataref("laminar/c90/lighting/annun/fcp_gs_armed", "number")
C90DR_lighting_annun_fcp_ias						= create_dataref("laminar/c90/lighting/annun/fcp_ias", "number")
C90DR_lighting_annun_fcp_ga							= create_dataref("laminar/c90/lighting/annun/fcp_ga", "number")
C90DR_lighting_annun_fcp_dsc						= create_dataref("laminar/c90/lighting/annun/fcp_dsc", "number")
C90DR_lighting_annun_fcp_ap_engaged					= create_dataref("laminar/c90/lighting/annun/fcp_ap_engaged", "number")
C90DR_lighting_annun_fcp_ap_disco					= create_dataref("laminar/c90/lighting/annun/fcp_ap_disco", "number")
C90DR_lighting_annun_EFIS_aux_on					= create_dataref("laminar/c90/lighting/annun/EFIS_aux_on", "number")
C90DR_lighting_annun_EFIS_aux_arm					= create_dataref("laminar/c90/lighting/annun/EFIS_aux_arm", "number")
C90DR_lighting_annun_EFIS_aux_test					= create_dataref("laminar/c90/lighting/annun/EFIS_aux_test", "number")
C90DR_lighting_inclinometer_spill_L				    = create_dataref("laminar/c90/lighting/spill/inclinometer_L", "array[9]")
C90DR_lighting_inclinometer_spill_R				    = create_dataref("laminar/c90/lighting/spill/inclinometer_R", "array[9]")
C90DR_lighting_annun_alt_alert						= create_dataref("laminar/c90/lighting/annun/alt_alert", "number")
C90DR_lighting_alt_alert_spill				    	= create_dataref("laminar/c90/lighting/spill/alt_alert", "array[9]")
C90DR_lighting_annun_ind42_channel_1				= create_dataref("laminar/c90/lighting/annun/ind42/channel_1", "number")
C90DR_lighting_annun_ind42_channel_2				= create_dataref("laminar/c90/lighting/annun/ind42/channel_2", "number")
C90DR_lighting_annun_ind42_channel_3				= create_dataref("laminar/c90/lighting/annun/ind42/channel_3", "number")
C90DR_lighting_annun_ind42_wpt						= create_dataref("laminar/c90/lighting/annun/ind42/wpt", "number")
C90DR_lighting_annun_ind42_nm						= create_dataref("laminar/c90/lighting/annun/ind42/nm", "number")
C90DR_lighting_annun_ind42_hld						= create_dataref("laminar/c90/lighting/annun/ind42/hld", "number")
C90DR_lighting_annun_ind42_kt						= create_dataref("laminar/c90/lighting/annun/ind42/kt", "number")
C90DR_lighting_annun_ind42_min						= create_dataref("laminar/c90/lighting/annun/ind42/min", "number")
C90DR_lighting_annun_ind42_id						= create_dataref("laminar/c90/lighting/annun/ind42/id", "number")
C90DR_lighting_annun_clt62_adf_act					= create_dataref("laminar/c90/lighting/annun/ctl62_adf/act", "number")
C90DR_lighting_annun_clt62_adf_mem					= create_dataref("laminar/c90/lighting/annun/ctl62_adf/mem", "number")
C90DR_lighting_annun_clt62_adf_rmt					= create_dataref("laminar/c90/lighting/annun/ctl62_adf/rmt", "number")
C90DR_lighting_annun_clt62_adf_tx					= create_dataref("laminar/c90/lighting/annun/ctl62_adf/tx", "number")
C90DR_lighting_annun_clt62_adf_hld					= create_dataref("laminar/c90/lighting/annun/ctl62_adf/hld", "number")
if simDR_acf_descrip == "C90B EVO GNS" then
    print("EVO: 7. LOADING GNS version")
    g430n1_navcom_rmt                                   = 0 --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n1_ff_com_rmt                                   = 0 --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n1_ff_nav_rmt                                   = 0 --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n2_navcom_rmt                                   = 0 --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n2_ff_com_rmt                                   = 0 --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n2_ff_nav_rmt                                   = 0 --IBAV8N, Sep27-22, employs RMT led in radio head
    C90DR_avionics_ctl22_com1_sto_index	                = create_dataref("laminar/c90/avionics/ctl22/com1/store_index", "number")
    C90DR_avionics_ctl22_com2_sto_index	                = create_dataref("laminar/c90/avionics/ctl22/com2/store_index", "number")
    C90DR_avionics_ctl32_nav1_sto_index	                = create_dataref("laminar/c90/avionics/ctl32/nav1/store_index", "number")
    C90DR_avionics_ctl32_nav2_sto_index	                = create_dataref("laminar/c90/avionics/ctl32/nav2/store_index", "number")
    C90DR_avionics_ctl22_com1_act	                    = create_dataref("laminar/c90/avionics/ctl22/com1/act", "number")
    C90DR_avionics_ctl22_com2_act	                    = create_dataref("laminar/c90/avionics/ctl22/com2/act", "number")
    C90DR_avionics_ctl32_nav1_act	                    = create_dataref("laminar/c90/avionics/ctl32/nav1/act", "number")
    C90DR_avionics_ctl32_nav2_act	                    = create_dataref("laminar/c90/avionics/ctl32/nav2/act", "number")
    C90DR_avionics_ctl22_com1_xfr_mem_switch_pos		= create_dataref("laminar/c90/avionics/ctl22/com1/switch_pos/xfr_mem", "number")
    C90DR_avionics_ctl22_com2_xfr_mem_switch_pos		= create_dataref("laminar/c90/avionics/ctl22/com2/switch_pos/xfr_mem", "number")
    C90DR_avionics_ctl32_nav1_xfr_mem_switch_pos		= create_dataref("laminar/c90/avionics/ctl32/nav1/switch_pos/xfr_mem", "number")
    C90DR_avionics_ctl32_nav1_sto_switch_pos			= create_dataref("laminar/c90/avionics/ctl32/nav1/switch_pos/sto", "number")
    C90DR_avionics_ctl32_nav1_test_switch_pos			= create_dataref("laminar/c90/avionics/ctl32/nav1/switch_pos/test", "number")
    C90DR_avionics_ctl32_nav2_xfr_mem_switch_pos		= create_dataref("laminar/c90/avionics/ctl32/nav2/switch_pos/xfr_mem", "number")
    C90DR_avionics_ctl32_nav2_sto_switch_pos			= create_dataref("laminar/c90/avionics/ctl32/nav2/switch_pos/sto", "number")
    C90DR_avionics_ctl32_nav2_test_switch_pos			= create_dataref("laminar/c90/avionics/ctl32/nav2/switch_pos/test", "number")
    C90DR_avionics_ctl92_xpdr_ident_switch_pos			= create_dataref("laminar/c90/avionics/ctl92/xpdr/switch_pos/ident", "number")
    C90DR_avionics_ctl92_xpdr_test_switch_pos			= create_dataref("laminar/c90/avionics/ctl92/xpdr/switch_pos/test", "number")
    C90DR_avionics_ctl92_xpdr_pre_switch_pos			= create_dataref("laminar/c90/avionics/ctl92/xpdr/switch_pos/pre", "number")
    C90DR_avionics_ctl92_xpdr_12_dial_pos				= create_dataref("laminar/c90/avionics/ctl92/xpdr/dial_pos/12", "number")
    C90DR_avionics_ctl92_xpdr_34_dial_pos				= create_dataref("laminar/c90/avionics/ctl92/xpdr/dial_pos/34", "number")
    C90DR_lighting_annun_clt22_com1_act					= create_dataref("laminar/c90/lighting/annun/ctl22_com1/act", "number")
    C90DR_lighting_annun_clt22_com1_mem					= create_dataref("laminar/c90/lighting/annun/ctl22_com1/mem", "number")
    C90DR_lighting_annun_clt22_com1_rmt					= create_dataref("laminar/c90/lighting/annun/ctl22_com1/rmt", "number")
    C90DR_lighting_annun_clt22_com1_tx					= create_dataref("laminar/c90/lighting/annun/ctl22_com1/tx", "number")
    C90DR_lighting_annun_clt22_com1_hld					= create_dataref("laminar/c90/lighting/annun/ctl22_com1/hld", "number")
    C90DR_lighting_annun_clt22_com2_act					= create_dataref("laminar/c90/lighting/annun/ctl22_com2/act", "number")
    C90DR_lighting_annun_clt22_com2_mem					= create_dataref("laminar/c90/lighting/annun/ctl22_com2/mem", "number")
    C90DR_lighting_annun_clt22_com2_rmt					= create_dataref("laminar/c90/lighting/annun/ctl22_com2/rmt", "number")
    C90DR_lighting_annun_clt22_com2_tx					= create_dataref("laminar/c90/lighting/annun/ctl22_com2/tx", "number")
    C90DR_lighting_annun_clt22_com2_hld					= create_dataref("laminar/c90/lighting/annun/ctl22_com2/hld", "number")
    C90DR_lighting_annun_clt32_nav1_act					= create_dataref("laminar/c90/lighting/annun/ctl32_nav1/act", "number")
    C90DR_lighting_annun_clt32_nav1_mem					= create_dataref("laminar/c90/lighting/annun/ctl32_nav1/mem", "number")
    C90DR_lighting_annun_clt32_nav1_rmt					= create_dataref("laminar/c90/lighting/annun/ctl32_nav1/rmt", "number")
    C90DR_lighting_annun_clt32_nav1_tx					= create_dataref("laminar/c90/lighting/annun/ctl32_nav1/tx", "number")
    C90DR_lighting_annun_clt32_nav1_hld					= create_dataref("laminar/c90/lighting/annun/ctl32_nav1/hld", "number")
    C90DR_lighting_annun_clt32_nav2_act					= create_dataref("laminar/c90/lighting/annun/ctl32_nav2/act", "number")
    C90DR_lighting_annun_clt32_nav2_mem					= create_dataref("laminar/c90/lighting/annun/ctl32_nav2/mem", "number")
    C90DR_lighting_annun_clt32_nav2_rmt					= create_dataref("laminar/c90/lighting/annun/ctl32_nav2/rmt", "number")
    C90DR_lighting_annun_clt32_nav2_tx					= create_dataref("laminar/c90/lighting/annun/ctl32_nav2/tx", "number")
    C90DR_lighting_annun_clt32_nav2_hld					= create_dataref("laminar/c90/lighting/annun/ctl32_nav2/hld", "number")
    C90DR_lighting_annun_clt92_atc_act					= create_dataref("laminar/c90/lighting/annun/ctl92_atc/act", "number")
    C90DR_lighting_annun_clt92_atc_mem					= create_dataref("laminar/c90/lighting/annun/ctl92_atc/mem", "number")
    C90DR_lighting_annun_clt92_atc_rmt					= create_dataref("laminar/c90/lighting/annun/ctl92_atc/rmt", "number")
    C90DR_lighting_annun_clt92_atc_tx					= create_dataref("laminar/c90/lighting/annun/ctl92_atc/tx", "number")
    C90DR_lighting_annun_clt92_atc_hld					= create_dataref("laminar/c90/lighting/annun/ctl92_atc/hld", "number")
    C90DR_avionics_g430n1_dial_com_vol				    = create_dataref("laminar/c90/avionics/g430n1/dial/com_vol", "number")          --IBAV8N, May15-22, new switch animations
    C90DR_avionics_g430n1_power				            = create_dataref("laminar/c90/avionics/g430n1/power", "number")
    C90DR_avionics_g430n1_dial_vloc_vol				    = create_dataref("laminar/c90/avionics/g430n1/dial/vloc_vol", "number")
    C90DR_avionics_g430n1_dial_com_mega				    = create_dataref("laminar/c90/avionics/g430n1/dial/com_mega", "number")
    C90DR_avionics_g430n1_dial_com_kilo				    = create_dataref("laminar/c90/avionics/g430n1/dial/com_kilo", "number")
    C90DR_avionics_g430n1_dial_chapter				    = create_dataref("laminar/c90/avionics/g430n1/dial/chapter", "number")			-- @pilotmarcog, 5/16/2022 changed nomemclature for clarity
    C90DR_avionics_g430n1_dial_page					    = create_dataref("laminar/c90/avionics/g430n1/dial/page", "number")
    C90DR_avionics_g430n1_switch_pos_com_push		    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/com_push", "number")   --IBAV8N, May15-22, new switch animations
    C90DR_avionics_g430n1_switch_pos_gps_push		    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/gps_push", "number")
    C90DR_avionics_g430n1_switch_pos_com_toggle		    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/com_toggle", "number")
    C90DR_avionics_g430n1_switch_pos_vloc_toggle	    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/vloc_toggle", "number")
    C90DR_avionics_g430n1_switch_pos_cdi			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/cdi", "number")
    C90DR_avionics_g430n1_switch_pos_obs			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/obs", "number")
    C90DR_avionics_g430n1_switch_pos_msg			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/msg", "number")
    C90DR_avionics_g430n1_switch_pos_fpl			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/fpl", "number")
    C90DR_avionics_g430n1_switch_pos_vnav			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/vnav", "number")
    C90DR_avionics_g430n1_switch_pos_proc			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/proc", "number")
    C90DR_avionics_g430n1_switch_pos_rng_up			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/rng_up", "number")
    C90DR_avionics_g430n1_switch_pos_rng_down		    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/rng_down", "number")
    C90DR_avionics_g430n1_switch_pos_dir			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/dir", "number")
    C90DR_avionics_g430n1_switch_pos_menu			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/menu", "number")
    C90DR_avionics_g430n1_switch_pos_clr			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/clr", "number")
    C90DR_avionics_g430n1_switch_pos_ent			    = create_dataref("laminar/c90/avionics/g430n1/switch_pos/ent", "number")
    C90DR_avionics_g430n2_dial_com_vol				    = create_dataref("laminar/c90/avionics/g430n2/dial/com_vol", "number")          --IBAV8N, May15-22, new switch animations
    C90DR_avionics_g430n2_power				            = create_dataref("laminar/c90/avionics/g430n2/power", "number")
    C90DR_avionics_g430n2_dial_vloc_vol				    = create_dataref("laminar/c90/avionics/g430n2/dial/vloc_vol", "number")
    C90DR_avionics_g430n2_dial_com_mega				    = create_dataref("laminar/c90/avionics/g430n2/dial/com_mega", "number")
    C90DR_avionics_g430n2_dial_com_kilo				    = create_dataref("laminar/c90/avionics/g430n2/dial/com_kilo", "number")
    C90DR_avionics_g430n2_dial_chapter				    = create_dataref("laminar/c90/avionics/g430n2/dial/chapter", "number")			-- @pilotmarcog, 5/16/2022 changed nomenclature for clarity
    C90DR_avionics_g430n2_dial_page					    = create_dataref("laminar/c90/avionics/g430n2/dial/page", "number")
	C90DR_avionics_g430n2_switch_pos_com_push		    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/com_push", "number")   --IBAV8N, May15-22, new switch animations
    C90DR_avionics_g430n2_switch_pos_gps_push		    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/gps_push", "number")
    C90DR_avionics_g430n2_switch_pos_com_toggle		    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/com_toggle", "number")
    C90DR_avionics_g430n2_switch_pos_vloc_toggle	    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/vloc_toggle", "number")
    C90DR_avionics_g430n2_switch_pos_cdi			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/cdi", "number")
    C90DR_avionics_g430n2_switch_pos_obs			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/obs", "number")
    C90DR_avionics_g430n2_switch_pos_msg			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/msg", "number")
    C90DR_avionics_g430n2_switch_pos_fpl			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/fpl", "number")
    C90DR_avionics_g430n2_switch_pos_proc			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/proc", "number")
    C90DR_avionics_g430n2_switch_pos_rng_up			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/rng_up", "number")
    C90DR_avionics_g430n2_switch_pos_rng_down		    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/rng_down", "number")
    C90DR_avionics_g430n2_switch_pos_dir			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/dir", "number")
    C90DR_avionics_g430n2_switch_pos_menu			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/menu", "number")
    C90DR_avionics_g430n2_switch_pos_clr			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/clr", "number")
    C90DR_avionics_g430n2_switch_pos_ent			    = create_dataref("laminar/c90/avionics/g430n2/switch_pos/ent", "number")
    C90DR_gps530_crossfill_iterate						= create_dataref("laminar/c90/avionics/gps530/crossfill_iterate","number") --	@pilotmarcog	create DataRef to keep count of GPS crossfill iterations
    C90DR_crossfill                                     = create_dataref("laminar/c90/avionics/crossfill", "number")
end
--[[
if simDR_acf_descrip == "C90B EVO GTN" then
    print("EVO: 7. LOADING GTN version")
    C90DR_avionics_gtn_dto                              = create_dataref("jp_evo/gtn/dto", "array[2]") -- @pilotmarcog 2-22-2021 - drefs to animate GTN controls
    C90DR_avionics_gtn_home                             = create_dataref("jp_evo/gtn/home_button", "array[2]")
    C90DR_avionics_gtn_vol_push                         = create_dataref("jp_evo/gtn/vol_push", "array[2]")
    C90DR_avionics_gtn_volume                           = create_dataref("jp_evo/gtn/volume", "array[2]")
    C90DR_avionics_gtn_fms_push                         = create_dataref("jp_evo/gtn/fms_push", "array[2]")
    C90DR_avionics_gtn_fms_inner                        = create_dataref("jp_evo/gtn/fms_inner", "array[2]")
    C90DR_avionics_gtn_fms_outer                        = create_dataref("jp_evo/gtn/fms_outer", "array[2]")
    C90DR_avionics_gtn_sd_card_pos                      = create_dataref("jp_evo/gtn/sd_card_pos", "array[2]")
end
--]]
if simDR_acf_descrip == "C90B - G1000, Blackhawk" then
    print("EVO: 7. LOADING G1000 version")
    imcDR_light_level_GFC710	                        = create_dataref("imc/g1000/lighting/light_level_GFC710", "number")
    imcDR_light_level_GCU479	                        = create_dataref("imc/g1000/lighting/light_level_GCU479", "number")
    imcDR_light_level_GMA1347_L	                        = create_dataref("imc/g1000/lighting/light_level_GMA1347_L", "number")
    imcDR_light_level_GMA1347_R	                        = create_dataref("imc/g1000/lighting/light_level_GMA1347_R", "number")
    imcDR_light_level_PFD1		                        = create_dataref("imc/g1000/lighting/light_level_PFD1", "number")
    imcDR_light_level_PFD2		                        = create_dataref("imc/g1000/lighting/light_level_PFD2", "number")
    imcDR_light_level_MFD		                        = create_dataref("imc/g1000/lighting/light_level_MFD", "number")
    imcDR_altitude_ft_stby_thous		                = create_dataref("imc/altitude_ft_stby_thous", "number") --IBAV8N, Sept25-23, for g1000 stby altimeter
    imcDR_altitude_ft_stby_hunds		                = create_dataref("imc/altitude_ft_stby_hunds", "number") --IBAV8N, Sept25-23, for g1000 stby altimeter
    imcDR_altitude_ft_stby_tens		                    = create_dataref("imc/altitude_ft_stby_tens", "number") --IBAV8N, Sept25-23, for g1000 stby altimeter
    imcDR_annun_prop_sync_on                            = create_dataref("imc/annunciators/prop_sync_on", "number")      --IMC
    C90DR_imc_gfc710_indicator_alt                      = create_dataref("imc/GFC710/indicator/ALT", "number") -- ALT mode
    C90DR_imc_gfc710_indicator_ap                       = create_dataref("imc/GFC710/indicator/AP", "number") -- AP enabled
    C90DR_imc_gfc710_indicator_ap_1                     = create_dataref("imc/GFC710/indicator/AP-1", "number") -- AP source 1
    C90DR_imc_gfc710_indicator_ap_2                     = create_dataref("imc/GFC710/indicator/AP-2", "number") -- AP source 2
    C90DR_imc_gfc710_indicator_apr                      = create_dataref("imc/GFC710/indicator/APR", "number") -- APR mode enabled
    C90DR_imc_gfc710_indicator_bank                     = create_dataref("imc/GFC710/indicator/BANK", "number") -- BANK mode enabled
    C90DR_imc_gfc710_indicator_bc                       = create_dataref("imc/GFC710/indicator/BC", "number") -- BC mode enabled
    C90DR_imc_gfc710_indicator_fd                       = create_dataref("imc/GFC710/indicator/FD", "number") -- FD enabled
    C90DR_imc_gfc710_indicator_flc                      = create_dataref("imc/GFC710/indicator/FLC", "number") -- FLC mode enabled
    C90DR_imc_gfc710_indicator_hdg                      = create_dataref("imc/GFC710/indicator/HDG", "number") -- HDG mode enabled
    C90DR_imc_gfc710_indicator_nav                      = create_dataref("imc/GFC710/indicator/NAV", "number") -- NAV mode enabled
    C90DR_imc_gfc710_indicator_vnv                      = create_dataref("imc/GFC710/indicator/VNV", "number") -- VNV mode enabled
    C90DR_imc_gfc710_indicator_vs                       = create_dataref("imc/GFC710/indicator/VS", "number") -- VS mode enabled
    C90DR_imc_gfc710_indicator_yd                       = create_dataref("imc/GFC710/indicator/YD", "number") -- YD enabled
end
if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
    C90DR_powerplant_oil_temp_gauge_L				    = create_dataref("laminar/c90/powerplant/oil_temp_gauge_L", "number")
    C90DR_powerplant_oil_temp_gauge_R				    = create_dataref("laminar/c90/powerplant/oil_temp_gauge_R", "number")
end
--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--
function C90_avionics_EFIS_eadi_brightness_DRhandler()
    if C90DR_avionics_EFIS_eadi_brightness < 0.25 then
        C90DR_avionics_EFIS_eadi_brightness = 0.25
    end
end

function C90_avionics_EFIS_ehsi_brightness_DRhandler()
    if C90DR_avionics_EFIS_ehsi_brightness < 0.25 then
        C90DR_avionics_EFIS_ehsi_brightness = 0.25
    end
end

function C90_engine_throttle_detent_DRhandler()                             --IBAV8N, Apr26-22, to control cockpit animations
    if simDR_prop_mode_L < 2 then
        C90DR_engine_throttle_detent[0] = 0
    elseif simDR_prop_mode_L == 2 then
        C90DR_engine_throttle_detent[0] = 0.0125
    else C90DR_engine_throttle_detent[0] = 0.025
    end
    if simDR_prop_mode_R < 2 then
        C90DR_engine_throttle_detent[1] = 0
    elseif simDR_prop_mode_R == 2 then
        C90DR_engine_throttle_detent[1] = 0.0125
    else C90DR_engine_throttle_detent[1] = 0.025
    end
end

function C90_gear_handle_DRhandler()                                        --IBAV8N, May25-21, only main gear have squat switches
	if simDR_gear_on_ground[1] == 1
		or simDR_gear_on_ground[2] == 1
	then
		C90DR_gear_handle = 1
	else
		simDR_gear_handle_down = C90DR_gear_handle
	end
    if C90DR_gear_handle == 0 and simDR_airspeed > 167 then                 --IBAV8N, May26-21, 1. test too fast to retract, check once
        if is_timer_scheduled(nose_gear_fail_retract) == false and simDR_gear1_fail ~= 6 then run_at_interval(nose_gear_fail_retract, 1) end
        if is_timer_scheduled(left_main_gear_fail_retract) == false and simDR_gear2_fail ~= 6 then run_at_interval(left_main_gear_fail_retract, 1) end
        if is_timer_scheduled(right_main_gear_fail_retract) == false and simDR_gear3_fail ~= 6 then run_at_interval(right_main_gear_fail_retract, 1) end
    end
    gear_check_down()                                                       --IBAV8N, May26-21, 2. test too fast to extend, check continuously
end

function empty_handler() end

function C90_pilot_shade_flip_DRhandler()                                                                                   -- @pilotmarcog DR Handler to animate pilot shade
    shade_left()
end

function C90_pilot_shade_slide_DRhandler()                                                                                  -- @imc DR Handler to animate pilot shade sliding
    if C90DR_pilot_shade_flip > 0.4 then C90DR_pilot_shade_slide = math.min(C90DR_pilot_shade_slide, 0.77)end
    C90DR_pilot_shade_slide = math.min(C90DR_pilot_shade_slide, 0.978)
    shade_left()
end

function shade_left()
    C90DR_pilot_shade_flip = math.min(C90DR_pilot_shade_flip - 0.04 * C90DR_pilot_shade_slide, 1)
    if C90DR_pilot_shade_slide > 0.77 then C90DR_pilot_shade_flip = math.min(C90DR_pilot_shade_flip, 0.4)end
end

function C90_copilot_shade_flip_DRhandler()                                                                                 -- @copilotmarcog DR Handler to animate copilot shade
    shade_right()
end

function C90_copilot_shade_slide_DRhandler()                                                                                -- @imc DR Handler to animate copilot shade sliding
    if C90DR_copilot_shade_flip > 0.4 then C90DR_copilot_shade_slide = math.min(C90DR_copilot_shade_slide, 0.77)end
    C90DR_copilot_shade_slide = math.min(C90DR_copilot_shade_slide, 0.978)
    shade_right()
end

function shade_right()
    C90DR_copilot_shade_flip = math.min(C90DR_copilot_shade_flip - 0.04 * C90DR_copilot_shade_slide, 1)
    if C90DR_copilot_shade_slide > 0.77 then C90DR_copilot_shade_flip = math.min(C90DR_copilot_shade_flip, 0.4)end
end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--
print("EVO: 8. LOADING Read-Write Custom DataRefs")
C90DR_wiper_knob_pos		                    = create_dataref("laminar/c90/wiper_knob_pos", "number", empty_handler) --IBAV8N, Apr18
C90DR_imc_cockpit_divider_door                  = create_dataref("imc/cockpit_divider/door", "number", empty_handler)
C90DR_fuselage_icing_level					    = create_dataref("imc/icing/fuselage/level", "number", empty_handler)-- fuselage icing (4 levels, 0: none -> 3: max)
C90DR_spinner_dynamic_icing_level			    = create_dataref("imc/icing/spinner/dynamic/level", "array[2]", empty_handler)  -- imc - spinner icing (4 levels, 0: none -> 3: max) left:[0] right:[1]
C90DR_spinner_static_icing_level			    = create_dataref("imc/icing/spinner/static/level", "array[2]", empty_handler)   -- imc - static prop_is_disc, dynamic = prop not prop_is_disc
C90DR_aero_icing_wing_level					    = create_dataref("imc/icing/aero_wing/level", "number", empty_handler)          -- imc - aero surface icing (6 levels, 0: none -> 5: max)
C90DR_aero_icing_empennage_level			    = create_dataref("imc/icing/aero_empennage/level", "number", empty_handler)     -- imc - aero surface icing (6 levels, 0: none -> 5: max)
C90DR_boot_inflation_tailplane					= create_dataref("imc/icing/boot-inflation/tailplane", "array[2]", empty_handler)
C90DR_boot_inflation_tailfin					= create_dataref("imc/icing/boot-inflation/tailfin", "number", empty_handler)
C90DR_boot_inflation_wing   					= create_dataref("imc/icing/boot-inflation/wing", "array[2]", empty_handler)
C90DR_fuel_needle_left                          = create_dataref("laminar/c90/fuel/gauge/needle_left", "number", empty_handler)    --IBAV8N, Dec20-21, added to smooth fuel gauge needle drop
C90DR_fuel_needle_right                         = create_dataref("laminar/c90/fuel/gauge/needle_right", "number", empty_handler)  --IBAV8N, Dec20-21, added to smooth fuel gauge needle drop
C90DR_ovh_flood						            = create_dataref("laminar/c90/lighting/rheostat/ovh_flood", "number", empty_handler)
C90DR_ovh_indirect					            = create_dataref("laminar/c90/lighting/rheostat/ovh_indirect", "number", empty_handler)
C90DR_ovh_pilot_flt				                = create_dataref("laminar/c90/lighting/rheostat/ovh_pilot_flt", "number", empty_handler)
C90DR_ovh_pilot_gyro			                = create_dataref("laminar/c90/lighting/rheostat/ovh_pilot_gyro", "number", empty_handler)
C90DR_ovh_eng_instru			                = create_dataref("laminar/c90/lighting/rheostat/ovh_eng_instru", "number", empty_handler)
C90DR_ovh_avion_pnl				                = create_dataref("laminar/c90/lighting/rheostat/ovh_avion_pnl", "number", empty_handler)
C90DR_ovh_sub_pnl				                = create_dataref("laminar/c90/lighting/rheostat/ovh_sub_pnl", "number", empty_handler)
C90DR_ovh_side_pnl				                = create_dataref("laminar/c90/lighting/rheostat/ovh_side_pnl", "number", empty_handler)
C90DR_ovh_copilot_gyro			                = create_dataref("laminar/c90/lighting/rheostat/ovh_copilot_gyro", "number", empty_handler)
C90DR_ovh_copilot_flt			                = create_dataref("laminar/c90/lighting/rheostat/ovh_copilot_flt", "number", empty_handler)
C90DR_ovh_emerg			                        = create_dataref("laminar/c90/lighting/switch/ovh_emerg","number",empty_handler)
C90DR_ovh_master			                    = create_dataref("laminar/c90/lighting/switch/ovh_master","number",empty_handler) -- @pilotmarcog
C90DR_pilot_shade_flip							= create_dataref("laminar/c90/misc/pilot_shade_flip","number",C90_pilot_shade_flip_DRhandler)  --@pilotmarcog
C90DR_pilot_shade_slide							= create_dataref("laminar/c90/misc/pilot_shade_slide","number",C90_pilot_shade_slide_DRhandler)  --@imc
C90DR_copilot_shade_flip						= create_dataref("laminar/c90/misc/copilot_shade_flip","number",C90_copilot_shade_flip_DRhandler)  --@pilotmarcog
C90DR_copilot_shade_slide                       = create_dataref("laminar/c90/misc/copilot_shade_slide","number",C90_copilot_shade_slide_DRhandler) --@imc
C90DR_engine_hydraulic_fluid_test				= create_dataref("laminar/c90/warning/hydraulic_fluid_test","number", empty_handler) -- @pilotmarcog/jeffory create DataRef to activate Hydraulic Fluid Test
C90DR_landing_gear_handle_light_test			= create_dataref("laminar/c90/warning/landing_gear_test","number", empty_handler) --@pilotmarcog Dref for landing gear handle light test
C90DR_volt_bus_sel_dial							= create_dataref("laminar/c90/electrical/switch/switchVoltBusSelect","number", empty_handler) -- @pilotmarcog create DataRef for Volt Bus Selector
C90DR_airCon_air_control_knob_pilot				= create_dataref("laminar/c90/airCon/knob/air_control_pilot", "number", empty_handler)
C90DR_airCon_air_control_knob_copilot			= create_dataref("laminar/c90/airCon/knob/air_control_copilot", "number", empty_handler)
C90DR_airCon_defrost_air_control_knob			= create_dataref("laminar/c90/airCon/knob/defrost_air_control", "number", empty_handler)
C90DR_airCon_cabin_air_control_knob				= create_dataref("laminar/c90/airCon/knob/cabin_air_control", "number", empty_handler)
C90DR_airCon_cabin_temp_dial					= create_dataref("laminar/c90/airCon/dial/cabin_temp", "number", empty_handler)
C90DR_avionics_EFIS_eadi_brightness			    = create_dataref("laminar/c90/avionics/EFIS/eadi_brightness", "number", C90_avionics_EFIS_eadi_brightness_DRhandler) --IBAV8N,May20-22 handles simDR_switch_instr_brightness_ratio[11]
C90DR_avionics_EFIS_ehsi_brightness			    = create_dataref("laminar/c90/avionics/EFIS/ehsi_brightness", "number", C90_avionics_EFIS_ehsi_brightness_DRhandler) --IBAV8N,May20-22 handles simDR_switch_instr_brightness_ratio[12
C90DR_avionics_paging_vol_dial					= create_dataref("laminar/c90/avionics/dial/paging_vol", "number", empty_handler)
C90DR_avionics_interphone_vol_dial				= create_dataref("laminar/c90/avionics/dial/interphone_vol", "number", empty_handler)
C90DR_avionics_dme_vol_dial						= create_dataref("laminar/c90/avionics/dial/dme_vol", "number", empty_handler)
C90DR_avionics_mkr_bkn_vol_dial					= create_dataref("laminar/c90/avionics/dial/mkr_bkn_vol", "number", empty_handler)
C90DR_avionics_master_vol_ctrl_dial_pilot		= create_dataref("laminar/c90/avionics/dial/master_vol_pilot", "number", empty_handler)
C90DR_avionics_master_vol_ctrl_dial_copilot		= create_dataref("laminar/c90/avionics/dial/master_vol_copilot", "number", empty_handler)
C90DR_avionics_com1_vol_control_dial			= create_dataref("laminar/c90/avionics/dial/com1_vol_control", "number", empty_handler)
C90DR_avionics_com2_vol_control_dial			= create_dataref("laminar/c90/avionics/dial/com2_vol_control", "number", empty_handler)
C90DR_avionics_nav1_vol_control_dial			= create_dataref("laminar/c90/avionics/dial/nav1_vol_control", "number", empty_handler)
C90DR_avionics_nav2_vol_control_dial			= create_dataref("laminar/c90/avionics/dial/nav2_vol_control", "number", empty_handler)
C90DR_avionics_adf1_vol_control_dial			= create_dataref("laminar/c90/avionics/dial/adf1_vol_control", "number", empty_handler)
C90DR_engine_throttle_detent					= create_dataref("laminar/c90/engine/throttle_detent", "array[2]", C90_engine_throttle_detent_DRhandler)
C90DR_gear_handle								= create_dataref("laminar/c90/gear/handle", "number", C90_gear_handle_DRhandler)
C90DR_gear_handle_detent						= create_dataref("laminar/c90/gear/handle_detent", "number", empty_handler)
C90DR_gear_horn						            = create_dataref("laminar/c90/gear/gear_horn", "number", empty_handler)--IBAV8N, Aug30-23, dref for fmod to use
C90DR_trim_switch                               = create_dataref("cpuwolf/c90/switches/anim/trim", "number", empty_handler)     --yoke trim switch animation 1: down 0: natural -1: up
C90DR_yoke_ident_switch_pos                     = create_dataref("cpuwolf/c90/switches/anim/atc", "number", empty_handler) -- @cpuwolf c90 yoke ident switch position
--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--
function C90_g1000_backup_battery_CMDhandler(phase, duration)   --IMC
	if phase == 0 then
		C90DR_avionics_EFIS_aux_pwr_on_switch_pos = 1 - C90DR_avionics_EFIS_aux_pwr_on_switch_pos
	end
end

----- CENTER CONSOLE ------------------------------------------------------------------------
function C90CMD_quadrant_lever_toggle_CMDhandler(phase, duration)   --IMC JAN16-24
    if phase == 0 then
        C90DR_quadrant_levers_hidden = 1 - C90DR_quadrant_levers_hidden
    end
    if C90DR_quadrant_levers_hidden == 1 and restore_levers == 1 then run_after_time(return_levers, 120) end
end

function return_levers()
    C90DR_quadrant_levers_hidden = 0
end

function C90_condition_toggle_CMDhandler(phase, duration)
    if phase == 0 then
        if simDR_mixture_ratio_L < 0.66 or simDR_mixture_ratio_R < 0.66 then
            C90_condition_adj = 2
        else
            C90_condition_adj = 1
        end
    end
end

function C90_condition_low_CMDhandler(phase, duration)
    if phase == 0 then
        if simDR_mixture_ratio_L ~= 0.5 or simDR_mixture_ratio_R ~= 0.5 then
            C90_condition_adj = 1
        end
    end
end

----- OVERHEAD PANEL ------------------------------------------------------------------------
function C90_electrical_ovh_flood_toggle_CMDhandler(phase, duration)
    if phase == 0 then
        if C90DR_ovh_flood < 1 then
            flood_set_save = C90DR_ovh_flood
            C90DR_ovh_flood = 1
        elseif C90DR_ovh_flood == 1 then
            if flood_set_save ~= nil then
                C90DR_ovh_flood = flood_set_save
            else C90DR_ovh_flood = 0
            end
        end
    end
end

function C90_electrical_ovh_master_toggle_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_ovh_master = 1 - C90DR_ovh_master
    end
end

function C90_electrical_electrical_ovh_master_up_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_ovh_master = 1
    end
end

function C90_electrical_electrical_ovh_master_dn_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_ovh_master = 0
    end
end

function C90_electrical_ovh_emerg_toggle_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_ovh_emerg = 1 - C90DR_ovh_emerg
    end
end

function C90_electrical_ovh_emerg_up_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_ovh_emerg = 1
    end
end

function C90_electrical_ovh_emerg_dn_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_ovh_emerg = 0
    end
end

function C90_electrical_voltmeter_knob_up_CMDhandler(phase, duration)           --IBAV8N, Jul1-21
    if phase == 0 then
        C90DR_volt_bus_sel_dial = math.min(5, C90DR_volt_bus_sel_dial + 1)
    elseif phase == 2 then
        if C90DR_volt_bus_sel_dial == 5 then
            C90DR_volt_bus_sel_dial = 4
        end
    end
end

function C90_electrical_voltmeter_knob_dn_CMDhandler(phase, duration)           --IBAV8N, Jan16-21
    if phase == 0 then
        C90DR_volt_bus_sel_dial = math.max(0, C90DR_volt_bus_sel_dial - 1)
    end
end

-- INVERTERS
function C90_electrical_inverter_sel_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_inverter_switch_pos = math.min(1, C90DR_electrical_inverter_switch_pos + 1)
	end
    if C90DR_electrical_inverter_switch_pos == 0 then
        simDR_inverter_on[0] = 0
        simDR_inverter_on[1] = 0
    else simDR_inverter_on[0] = 1
    end
end

function C90_electrical_inverter_sel_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_inverter_switch_pos = math.max(-1, C90DR_electrical_inverter_switch_pos - 1)
    end
    if C90DR_electrical_inverter_switch_pos == 0 then
        simDR_inverter_on[0] = 0
        simDR_inverter_on[1] = 0
    else simDR_inverter_on[1] = 1
    end
end

-- AUTO IGNITION
function C90_electrical_auto_ignition_switch_L_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_auto_ignition_switch_pos_L = 1 - C90DR_electrical_auto_ignition_switch_pos_L
		simDR_auto_ignite_on[0] = C90DR_electrical_auto_ignition_switch_pos_L
	end
end

function C90_electrical_auto_ignition_switch_L_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_auto_ignition_switch_pos_L = 1
		simDR_auto_ignite_on[0] = C90DR_electrical_auto_ignition_switch_pos_L
	end
end

function C90_electrical_auto_ignition_switch_L_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_auto_ignition_switch_pos_L = 0
		simDR_auto_ignite_on[0] = C90DR_electrical_auto_ignition_switch_pos_L
	end
end

function C90_electrical_auto_ignition_switch_R_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_auto_ignition_switch_pos_R = 1 - C90DR_electrical_auto_ignition_switch_pos_R
		simDR_auto_ignite_on[1] = C90DR_electrical_auto_ignition_switch_pos_R
	end
end

function C90_electrical_auto_ignition_switch_R_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_auto_ignition_switch_pos_R = 1
		simDR_auto_ignite_on[1] = C90DR_electrical_auto_ignition_switch_pos_R
	end
end

function C90_electrical_auto_ignition_switch_R_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_auto_ignition_switch_pos_R = 0
		simDR_auto_ignite_on[1] = C90DR_electrical_auto_ignition_switch_pos_R
	end
end

-- GENERATORS
function C90_electrical_generator_L_switch_up_CMDhandler(phase, duration)        --IBAV8N, Jun12-21,Gens must be reset for 1 sec to (re)activate
	if phase == 0 then
		C90DR_electrical_gen_L_switch_pos = math.min(1, C90DR_electrical_gen_L_switch_pos + 1)
		starter_torque()
	elseif phase == 1 and C90DR_electrical_gen_L_switch_pos == 1 then
		simCMD_generator_L_reset:once()
	elseif phase == 2 then
		if C90DR_electrical_gen_L_switch_pos == 1 then
		    C90DR_electrical_gen_L_switch_pos = 0
		    C90DR_man_close = 0
			if gen_check(simDR_generator_volts_L, C90DR_powerplant_ign_start_switch_pos_L) ~= 1 then
                if duration > 0.7 then
                    simCMD_generator_L_on:once()
                    C90DR_gen_tie_L = 1
                end
            end
        end
	end
end

function C90_electrical_generator_L_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_gen_L_switch_pos = math.max(-1, C90DR_electrical_gen_L_switch_pos - 1)
		simCMD_generator_L_off:once()
        C90.electrical.gen_fault_L = 0
		starter_torque()
	end
end

function C90_electrical_generator_R_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_gen_R_switch_pos = math.min(1, C90DR_electrical_gen_R_switch_pos + 1)
		starter_torque()
	elseif phase == 1 and C90DR_electrical_gen_R_switch_pos == 1 then
	    simCMD_generator_R_reset:once()
	elseif phase == 2 then
		if C90DR_electrical_gen_R_switch_pos == 1 then
		    C90DR_electrical_gen_R_switch_pos = 0
		    C90DR_man_close = 0
			if gen_check(simDR_generator_volts_R, C90DR_powerplant_ign_start_switch_pos_R) ~= 1 then
                if duration > 0.7 then
                    simCMD_generator_R_on:once()
                    C90DR_gen_tie_R = 1
			    end
	        end
        end
	end
end

function C90_electrical_generator_R_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_electrical_gen_R_switch_pos = math.max(-1, C90DR_electrical_gen_R_switch_pos - 1)
		simCMD_generator_R_off:once()
        C90.electrical.gen_fault_R = 0
		starter_torque()
	end
end

-- BUS SENSE
function C90_electrical_bus_sense_switch_up_CMDhandler(phase, duration) --RESET
    C90DR_electrical_bus_sense_switch_pos = C90_ternary(phase == 2, 0, 1)
	if phase == 0 then
        C90DR_ctr_sense = 1
        C90DR_gen_sense_L = 1
        C90DR_gen_sense_R = 1
        C90.electrical.gen_fault_L = 0
        C90.electrical.gen_fault_R = 0
	elseif phase == 1 then
        C90DR_gen_tie_L = 1 - tie_check(C90DR_gen_sense_L)
        C90DR_gen_tie_R = 1 - tie_check(C90DR_gen_sense_R)
	end
end

function C90_electrical_bus_sense_switch_dn_CMDhandler(phase, duration) --TEST
    C90DR_electrical_bus_sense_switch_pos = C90_ternary(phase == 2, 0, -1)
	if phase == 0 then
        C90DR_ctr_sense = 0
        C90DR_gen_sense_L = 0
        C90DR_gen_sense_R = 0
        C90DR_man_close = 0
	end
end

-- GEN TIES
function C90_electrical_cross_tie_switch_up_CMDhandler(phase, duration)		--GEN TIES MAN CLOSE
	if phase == 0 then
		C90DR_electrical_cross_tie_switch_pos = math.min(1, C90DR_electrical_cross_tie_switch_pos + 1)
        if C90DR_electrical_cross_tie_switch_pos == 1 then
            C90DR_man_close = 1
            C90DR_gen_tie_L = 1
            C90DR_gen_tie_R = 1
        end
    elseif phase == 2 then
        C90DR_electrical_cross_tie_switch_pos = 0
        C90DR_gen_tie_L = 1 - tie_check(C90DR_gen_sense_L)
        C90DR_gen_tie_R = 1 - tie_check(C90DR_gen_sense_R)
	end
end

function C90_electrical_cross_tie_switch_dn_CMDhandler(phase, duration)		--GEN TIES OPEN
	if phase == 0 then
		C90DR_electrical_cross_tie_switch_pos = math.max(-1, C90DR_electrical_cross_tie_switch_pos - 1)
        if C90DR_electrical_cross_tie_switch_pos == -1 then
            C90DR_man_close = 0
        end
	end
end

-- FUEL FIREWALL SWITCHES
function C90_fuel_firewall_switch_guard_toggle_L_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fuel_firewall_switch_guard_L = 1 - C90DR_fuel_firewall_switch_guard_L
        C90_firewall_guards()
	end
end

function C90_fuel_firewall_switch_guard_toggle_R_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fuel_firewall_switch_guard_R = 1 - C90DR_fuel_firewall_switch_guard_R
        C90_firewall_guards()
	end
end

function C90_firewall_guards()
    if C90DR_fuel_firewall_switch_guard_L == 0 and
        simDR_fuel_firewall_vlv_L == 1 then
        simCMD_fuel_firewall_vlv_open_L:once()
    end
    if C90DR_fuel_firewall_switch_guard_R == 0 and
        simDR_fuel_firewall_vlv_R == 1 then
	    simCMD_fuel_firewall_vlv_open_R:once()
    end
end

-- STARTER 1 LOGIC                                           --IBAV8N, Jun2-21
function C90_powerplant_ign_start_switch_up_L_CMDhandler(phase, duration) --IBAV8N, cleaned up
	if phase == 0 then
        if C90DR_powerplant_ign_start_switch_pos_L == 0 then
			C90DR_powerplant_ign_start_switch_pos_L = 1
            C90DR_gen_tie_L = C90_ternary(C90DR_gen_sense_L == 0 or C90DR_electrical_cross_tie_switch_pos == -1, 0, 1)
            C90DR_gen_tie_R = C90_ternary(C90DR_gen_sense_R == 0 or C90DR_electrical_cross_tie_switch_pos == -1, 0, 1)
            simCMD_generator_L_off:once()
		    C90DR_starter_relay_L = 1
		    simCMD_engage_starter_L:start()
		    simCMD_igniter_on_L:once()
		    avionics_surge()
	        run_at_interval(starter1_active, 1)
        end
        starter_torque()
    end
end

function C90_powerplant_ign_start_switch_dn_L_CMDhandler(phase, duration)
	if phase == 0 then
		if C90DR_powerplant_ign_start_switch_pos_L == 1 then
			C90DR_powerplant_ign_start_switch_pos_L = 0
			simCMD_igniter_off_L:once()
			simCMD_engage_starter_L:stop()
            C90DR_starter_relay_L = 0
		elseif C90DR_powerplant_ign_start_switch_pos_L == 0 then
			C90DR_powerplant_ign_start_switch_pos_L = -1
            C90DR_gen_tie_L = C90_ternary(C90DR_gen_sense_L == 0 or C90DR_electrical_cross_tie_switch_pos == -1, 0, 1)
            C90DR_gen_tie_R = C90_ternary(C90DR_gen_sense_R == 0 or C90DR_electrical_cross_tie_switch_pos == -1, 0, 1)
            simCMD_generator_L_off:once()
            C90DR_starter_relay_L = 1
		    simCMD_engage_starter_L:start()
		    avionics_surge()
		    run_at_interval(starter1_active, 1)
		end
		starter_torque()
	elseif phase == 2 then
		if C90DR_powerplant_ign_start_switch_pos_L == -1 then
			C90DR_powerplant_ign_start_switch_pos_L = 0
			simCMD_engage_starter_L:stop()
			starter_torque()
            C90DR_starter_relay_L = 0
		end
	end
end

-- STARTER 2 LOGIC                                           --IBAV8N, Jun2-21
function C90_powerplant_ign_start_switch_up_R_CMDhandler(phase, duration)
	if phase == 0 then
        if C90DR_powerplant_ign_start_switch_pos_R == 0 then
			C90DR_powerplant_ign_start_switch_pos_R = 1
            C90DR_gen_tie_L = C90_ternary(C90DR_gen_sense_L == 0 or C90DR_electrical_cross_tie_switch_pos == -1, 0, 1)
            C90DR_gen_tie_R = C90_ternary(C90DR_gen_sense_R == 0 or C90DR_electrical_cross_tie_switch_pos == -1, 0, 1)
            simCMD_generator_R_off:once()
		    C90DR_starter_relay_R = 1
		    simCMD_engage_starter_R:start()
		    simCMD_igniter_on_R:once()
		    avionics_surge()
		    run_at_interval(starter2_active, 1)
		end
		starter_torque()
	end
end

function C90_powerplant_ign_start_switch_dn_R_CMDhandler(phase, duration)
	if phase == 0 then
		if C90DR_powerplant_ign_start_switch_pos_R == 1 then
			C90DR_powerplant_ign_start_switch_pos_R = 0
			simCMD_igniter_off_R:once()
			simCMD_engage_starter_R:stop()
            C90DR_starter_relay_R = 0
		elseif C90DR_powerplant_ign_start_switch_pos_R == 0 then
			C90DR_powerplant_ign_start_switch_pos_R = -1
            C90DR_gen_tie_L = C90_ternary(C90DR_gen_sense_L == 0 or C90DR_electrical_cross_tie_switch_pos == -1, 0, 1)
            C90DR_gen_tie_R = C90_ternary(C90DR_gen_sense_R == 0 or C90DR_electrical_cross_tie_switch_pos == -1, 0, 1)
            simCMD_generator_R_off:once()
		    C90DR_starter_relay_R = 1
		    simCMD_engage_starter_R:start()
		    avionics_surge()
		    run_at_interval(starter2_active, 1)
		end
		starter_torque()
	elseif phase == 2 then
		if C90DR_powerplant_ign_start_switch_pos_R == -1 then
			C90DR_powerplant_ign_start_switch_pos_R = 0
			simCMD_engage_starter_R:stop()
			starter_torque()
            C90DR_starter_relay_R = 0
		end
	end
end

-- PROPELLERS
function C90_powerplant_prop_gov_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_powerplant_prop_gov_switch_pos = 1 - C90DR_powerplant_prop_gov_switch_pos
		if C90DR_powerplant_prop_gov_switch_pos <= 0.1 then
			simCMD_sys_overspd_test:stop()
		elseif C90DR_powerplant_prop_gov_switch_pos >= 0.9 then
			simCMD_sys_overspd_test:start()
		end
	end
end

function C90_powerplant_prop_gov_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_powerplant_prop_gov_switch_pos = math.min(1, C90DR_powerplant_prop_gov_switch_pos + 1)
		simCMD_sys_overspd_test:start()
	end
end

function C90_powerplant_prop_gov_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_powerplant_prop_gov_switch_pos = math.max(0, C90DR_powerplant_prop_gov_switch_pos - 1)
		simCMD_sys_overspd_test:stop()
	end
end

function C90_powerplant_autofeather_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_prop_feather_mode_switch == 2 then
			simDR_prop_feather_mode_switch = 0
		elseif simDR_prop_feather_mode_switch == 0 then
			simDR_prop_feather_mode_switch = 1
		end
	end
end

function C90_powerplant_autofeather_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_prop_feather_mode_switch == 1 then
			simDR_prop_feather_mode_switch = 0
		elseif simDR_prop_feather_mode_switch == 0 then
			simDR_prop_feather_mode_switch = 2
		end
	elseif phase == 2 then
		if simDR_prop_feather_mode_switch == 2 then
			simDR_prop_feather_mode_switch = 0
		end
	end
end

function C90_powerplant_autofeather_switch_toggle_CMDhandler(phase, duration)       --IBAV8N, Mar16-22
	if phase == 0 then
        if simDR_prop_feather_mode_switch < 2 then
            simDR_prop_feather_mode_switch = 1 - simDR_prop_feather_mode_switch
        end
	end
end

-- POWER LEVERS NORMAL/BETA/REVERSE
function C90_powerplant_beta_man_CMDhandler(phase, duration)                        --IBAV8N, automatically switch to beta @ 40kts, manually engage reverse above 45 kts
    if phase == 0 then
        C90_beta_alt = 1
        beta_logic()
    end
end

function C90_powerplant_beta_throt_CMDhandler(phase, duration)                      --IBAV8N, automatically switch to beta @ 40kts, > 80% throttle engages reverse above 45 kts
    if phase == 0 then
        C90_beta_alt = 2
        beta_logic()
    end
end

function beta_logic()
    local ringler_override = C90_ternary(C90_beta_alt == 1 and simDR_airspeed > 45, 1, 0)
    local on_ground = C90_ternary(
        simDR_gear_on_ground[1] == 1 or
        simDR_gear_on_ground[2] == 1
        , 1, 0)
    if on_ground == 1 then
        if (simDR_prop_mode_L == 1 or simDR_prop_mode_R == 1) and
            simDR_beta_rev_ratio_L < 0.1 and simDR_beta_rev_ratio_R < 0.1 then
            simDR_prop_mode_L = 2
            simDR_prop_mode_R = 2
            if simDR_airspeed > 45 then
                C90_beta_ctrl = 1
            end
        elseif (simDR_prop_mode_L == 2 or simDR_prop_mode_R == 2) then
            if ringler_override == 1 then
                simDR_prop_mode_L = 3
                simDR_prop_mode_R = 3
            elseif simDR_beta_rev_ratio_L > -0.1 and simDR_beta_rev_ratio_R > -0.1 then
                simDR_prop_mode_L = 1
                simDR_prop_mode_R = 1
                C90_beta_ctrl = 0
            else
                simDR_prop_mode_L = 2
                simDR_prop_mode_R = 2
            end
        elseif (simDR_prop_mode_L == 3 or simDR_prop_mode_R == 3) then
            if C90_beta_alt == 1 and                --EMERGENCY ALPHA
                simDR_beta_rev_ratio_L > -1.1 and
                simDR_beta_rev_ratio_R > -1.1 then
                simDR_prop_mode_L = 1
                simDR_prop_mode_R = 1
                C90_beta_ctrl = 0
            else
                simDR_prop_mode_L = 2
                simDR_prop_mode_R = 2
            end
        end
    else
        simDR_prop_mode_L = 1
        simDR_prop_mode_R = 1
    end
end

function C90_beta()
    if C90_beta_alt > 0 and (simDR_prop_mode_L > 1 or simDR_prop_mode_R > 1) then
        local braking = simDR_tire_part_brake[1] > 0 or simDR_tire_part_brake[2] > 0
        if simDR_airspeed < 111 then         --let props windmill over 110 kts
            if C90_beta_ctrl == 1 then                  --medicine for Ringler effect
                local beta_fade = math.max(-5, (-1.56 * simDR_airspeed) + 80.8)
                if simDR_act_prop_rotation_speed_rad_sec[0] < 191 then          --negative pitch bottom-end governor
                    simDR_POINT_pitch_deg_use[0] = math.min(beta_fade, simDR_POINT_pitch_deg_use[0] + ((-5.6 * simDR_alpha_el[29]) + 33) * SIM_PERIOD)
                elseif simDR_act_prop_rotation_speed_rad_sec[0] > 191.1 then    --negative pitch top-end governor
                    simDR_POINT_pitch_deg_use[0] = math.min(-11.25, simDR_POINT_pitch_deg_use[0] - 45 * SIM_PERIOD)
                end
                if simDR_act_prop_rotation_speed_rad_sec[1] < 191 then
                    simDR_POINT_pitch_deg_use[1] = math.min(beta_fade, simDR_POINT_pitch_deg_use[1] + ((-5.6 * simDR_alpha_el[69]) + 33) * SIM_PERIOD)
                elseif simDR_act_prop_rotation_speed_rad_sec[1] > 191.1 then
                    simDR_POINT_pitch_deg_use[1] = math.min(-11.25, simDR_POINT_pitch_deg_use[1] - 45 * SIM_PERIOD)
                end
                local throt_pitch = 2.71 + (simDR_beta_rev_ratio_all * 17.7)

                if (math.max(simDR_prop_mode_L, simDR_prop_mode_R) == 3 and simDR_alpha_el[29] > -14.5 and simDR_alpha_el[69] > -14.5) or
                    (math.max(simDR_prop_mode_L, simDR_prop_mode_R) == 2 and simDR_alpha_el[29] > -10 and simDR_alpha_el[69] > -10 and
                    throt_pitch < (simDR_POINT_pitch_deg_use[0] or simDR_POINT_pitch_deg_use[1])) then
                    C90_beta_ctrl = 0   --allow Ringler effect after props have lost energy and commanded beta is deeper than governed
                end
            end
            simDR_override_prop_pitch = C90_beta_ctrl
            simDR_prop_angle_degrees[0] = simDR_POINT_pitch_deg_use[0]  --setting this dref to our override pitch returns fmod reverse pitch sound
            simDR_prop_angle_degrees[1] = simDR_POINT_pitch_deg_use[1]
        end
        if simDR_prop_mode_L == 2 and C90_beta_alt == 2
            and simDR_airspeed > 45 and simDR_beta_rev_ratio_L < -0.8 then --if throttle-beta and >45 kts, must be above 80% throttle
            simDR_prop_mode_L = 3                                               --switch from beta to reverse
        elseif simDR_prop_mode_L == 3 then
            C90_max_brake = 1
            if simDR_airspeed < 40 or                                           --if below 40 kts in all cases
                (C90_beta_alt == 2 and simDR_beta_rev_ratio_L > -1.75) then   --in throttle beta or brake beta and levers are below 75%
                simDR_prop_mode_L = 2                                   --switch from reverse to beta to protect engines from FOD
            end
        end
        if simDR_prop_mode_R == 2 and C90_beta_alt == 2
            and simDR_airspeed > 45 and simDR_beta_rev_ratio_R < -0.8 then --if throttle-beta and >45 kts, must be above 80% throttle
            simDR_prop_mode_R = 3                                               --switch from beta to reverse
        elseif simDR_prop_mode_R == 3 then
            C90_max_brake = 1
            if simDR_airspeed < 40 or                                           --if below 40 kts in all cases
                (C90_beta_alt == 2 and simDR_beta_rev_ratio_R > -1.75) then   --in throttle beta or brake beta and levers are below 75%
                simDR_prop_mode_R = 2                                   --switch from reverse to beta to protect engines from FOD
            end
        end
    end
    C90DR_engine_throttle_detent[0] = (simDR_prop_mode_L - 1) * 0.0125  --set left detent
    C90DR_engine_throttle_detent[1] = (simDR_prop_mode_R - 1) * 0.0125  --set right detent

    --CONDITION COMMANDS (Here for now)
    if C90_condition_adj > 0 then
        if C90_condition_adj == 2 then
            if simDR_mixture_ratio_L == simDR_mixture_ratio_R then
                if simDR_mixture_ratio_L == 1 then
                    C90_condition_adj = 0
                else
                    simDR_mixture_ratio_L = math.min(1, simDR_mixture_ratio_L + 1 * SIM_PERIOD)
                    simDR_mixture_ratio_R = math.min(1, simDR_mixture_ratio_R + 1 * SIM_PERIOD)
                end
            elseif simDR_mixture_ratio_L > simDR_mixture_ratio_R then
                simDR_mixture_ratio_R = math.min(simDR_mixture_ratio_L, simDR_mixture_ratio_R + 1 * SIM_PERIOD)
            else
                simDR_mixture_ratio_L = math.min(simDR_mixture_ratio_R, simDR_mixture_ratio_L + 1 * SIM_PERIOD)
            end
        elseif C90_condition_adj == 1 then
            if simDR_mixture_ratio_L == simDR_mixture_ratio_R then
                if simDR_mixture_ratio_L > 0.5 then
                    simDR_mixture_ratio_L = math.max(0.5, simDR_mixture_ratio_L - 0.66 * SIM_PERIOD)
                    simDR_mixture_ratio_R = math.max(0.5, simDR_mixture_ratio_R - 0.66 * SIM_PERIOD)
                elseif simDR_mixture_ratio_L < 0.5 then
                    simDR_mixture_ratio_L = math.min(0.5, simDR_mixture_ratio_L + 1 * SIM_PERIOD)
                    simDR_mixture_ratio_R = math.min(0.5, simDR_mixture_ratio_R + 1 * SIM_PERIOD)
                else
                    C90_condition_adj = 0
                end
            elseif simDR_mixture_ratio_L > simDR_mixture_ratio_R then
                if simDR_mixture_ratio_R < 0.5 then
                    simDR_mixture_ratio_R = math.min(0.5, simDR_mixture_ratio_R + 1 * SIM_PERIOD)
                else
                    simDR_mixture_ratio_L = math.max(simDR_mixture_ratio_R, simDR_mixture_ratio_L - 0.66 * SIM_PERIOD)
                end
            elseif simDR_mixture_ratio_R > simDR_mixture_ratio_L then
                if simDR_mixture_ratio_L < 0.5 then
                    simDR_mixture_ratio_L = math.min(0.5, simDR_mixture_ratio_L + 1 * SIM_PERIOD)
                else
                    simDR_mixture_ratio_R = math.max(simDR_mixture_ratio_L, simDR_mixture_ratio_R - 0.66 * SIM_PERIOD)
                end
            end
        end
    end
end

-- SMOOTH BRAKING                                                               --IBAV8N, Apr8-22, Smooth braking for button-users
function C90_smooth_brakes_CMDhandler(phase, duration)
    C90_brakes = phase
    if C90_brakes > 0 then
        simDR_parking_brake = 0
        if simDR_groundspeed > 23.2 and simDR_flaprqst == 0 then                --RTO - enable max braking if above 45kts and flaps up
            C90_max_brake = 1
        end
        if is_timer_scheduled(smooth_brakes) == false then
            run_at_interval(smooth_brakes, 0.04)
        end
    end
end

function smooth_brakes()
    local soft = 0.33
    local hard = 1
    if C90_brakes == 1 then
        if C90_max_brake == 1 or simDR_torque_L > 500 or simDR_torque_R > 500 then  --if max braking enabled or run-up for takeoff, go hard
            C90_left_brake = math.min(hard, C90_left_brake + 0.05)
            C90_right_brake = math.min(hard, C90_right_brake + 0.05)
        elseif C90_left_brake > soft then                                           --if reducing brake pressure from hard to soft
            C90_left_brake = math.max(soft, C90_left_brake - 0.005)
            C90_right_brake = math.max(soft, C90_right_brake - 0.005)
        else                                                                        --normal taxiing pressure advance
            C90_left_brake = math.min(soft, C90_left_brake + 0.02)
            C90_right_brake = math.min(soft, C90_right_brake + 0.02)
        end
    elseif C90_brakes == 2 then
        if C90_left_brake > soft then
            if simDR_groundspeed < 1 then                                           --quick letoff for run-up release
                C90_left_brake = 0
                C90_right_brake = 0
            else
                C90_left_brake = math.max(0, C90_left_brake - 0.2)                  --reduce from hard braking upon brake release
                C90_right_brake = math.max(0, C90_right_brake - 0.2)
            end
        else
            C90_left_brake = math.max(0, C90_left_brake - 0.04)                     --reduce from soft braking upon brake release
            C90_right_brake = math.max(0, C90_right_brake - 0.04)
        end
        if simDR_l_brake_add == 0 and simDR_r_brake_add == 0 then                   --end max braking if brakes fully released
            C90_max_brake = 0
            stop_timer(smooth_brakes)
        end
    end
    simDR_l_brake_add = C90_left_brake
    simDR_r_brake_add = C90_right_brake
end

----- PNEUMATIC -------------------------------------------------------------------------
function C90_pneumatic_bleed_air_switch_L_CMDhandler(phase, duration)       -- BLEED AIR SWITCH LEFT
	if phase == 0 then
		C90DR_pneumatic_bleed_air_switch_pos_L = 1 - C90DR_pneumatic_bleed_air_switch_pos_L
	end
end

function C90_pneumatic_bleed_air_switch_L_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_pneumatic_bleed_air_switch_pos_L = 1
	end
end

function C90_pneumatic_bleed_air_switch_L_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_pneumatic_bleed_air_switch_pos_L = 0
	end
end

function C90_pneumatic_bleed_air_switch_R_CMDhandler(phase, duration)       -- BLEED AIR SWITCH RIGHT
	if phase == 0 then
		C90DR_pneumatic_bleed_air_switch_pos_R = 1 - C90DR_pneumatic_bleed_air_switch_pos_R
	end
end

function C90_pneumatic_bleed_air_switch_R_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_pneumatic_bleed_air_switch_pos_R = 1
	end
end

function C90_pneumatic_bleed_air_switch_R_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_pneumatic_bleed_air_switch_pos_R = 0
	end
end

----- AIR CONDITIONING ------------------------------------------------------------------
function C90_airCon_manual_temp_control_switch_up_CMDhandler(phase, duration)       --IBAV8N,Jan10-22  New system
    C90DR_airCon_manual_temp_control_switch_pos = C90_ternary(phase == 2, 0, 1)
	if phase == 1 then
        man_bypass_up()
	elseif phase == 2 then
        stop_timer(man_bypass_up)
	end
end

function C90_airCon_manual_temp_control_switch_dn_CMDhandler(phase, duration)       --IBAV8N,Jan10-22  New system
    C90DR_airCon_manual_temp_control_switch_pos = C90_ternary(phase == 2, 0, -1)
	if phase == 1 then
        man_bypass_down()
	elseif phase == 2 then
        stop_timer(man_bypass_down)
	end
end

function C90_airCon_cabin_temp_mode_dial_up_CMDhandler(phase, duration)             --IBAV8N, May3-21, follows detents now
	if phase == 0 then
	    if C90DR_airCon_cabin_temp_mode_dial_pos == 2 then
	        C90DR_airCon_cabin_temp_mode_dial_pos = 3
	    elseif C90DR_airCon_cabin_temp_mode_dial_pos == 3 then
	        C90DR_airCon_cabin_temp_mode_dial_pos = 0
	    else C90DR_airCon_cabin_temp_mode_dial_pos = 1
	    end
	end
end

function C90_airCon_cabin_temp_mode_dial_dn_CMDhandler(phase, duration)             --IBAV8N, May3-21, follows detents now
	if phase == 0 then
	    if C90DR_airCon_cabin_temp_mode_dial_pos == 1 then
	        C90DR_airCon_cabin_temp_mode_dial_pos = 0
	    elseif C90DR_airCon_cabin_temp_mode_dial_pos == 0 then
	        C90DR_airCon_cabin_temp_mode_dial_pos = 3
	    else C90DR_airCon_cabin_temp_mode_dial_pos = 2
	    end
	end
end

----- ICE & RAIN PROTECTION -------------------------------------------------------------
function C90_iceRain_engine_act_motor_sel_switch_L_CMDhandler(phase, duration)      -- ENGINE INERTIAL SEPERATOR: STANDBY ACTUATOR
	if phase == 0 then
		C90DR_iceRain_engine_act_motor_sel_switch_pos_L = 1 - C90DR_iceRain_engine_act_motor_sel_switch_pos_L
		if C90DR_iceRain_engine_act_motor_sel_switch_pos_L == 1 then
			sep1 = simDR_eng0_alt_air_fail
			simDR_eng0_alt_air_fail = math.random(6,106)
		elseif C90DR_iceRain_engine_act_motor_sel_switch_pos_L == 0 then
			simDR_eng0_alt_air_fail = sep1
		end
	end
end

function C90_iceRain_engine_act_motor_sel_switch_L_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_engine_act_motor_sel_switch_pos_L = math.min(1, C90DR_iceRain_engine_act_motor_sel_switch_pos_L + 1)
	end
end

function C90_iceRain_engine_act_motor_sel_switch_L_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_engine_act_motor_sel_switch_pos_L = math.max(0, C90DR_iceRain_engine_act_motor_sel_switch_pos_L - 1)
	end
end

function C90_iceRain_engine_act_motor_sel_switch_R_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_engine_act_motor_sel_switch_pos_R = 1 - C90DR_iceRain_engine_act_motor_sel_switch_pos_R
		if phase == 0 then
			if C90DR_iceRain_engine_act_motor_sel_switch_pos_R == 1 then
				sep2 = simDR_eng1_alt_air_fail
				simDR_eng1_alt_air_fail = math.random(6,106)
			elseif C90DR_iceRain_engine_act_motor_sel_switch_pos_R == 0 then
				simDR_eng1_alt_air_fail = sep2
			end
		end
	end
end

function C90_iceRain_engine_act_motor_sel_switch_R_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_engine_act_motor_sel_switch_pos_R = math.min(1, C90DR_iceRain_engine_act_motor_sel_switch_pos_R + 1)
	end
end

function C90_iceRain_engine_act_motor_sel_switch_R_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_engine_act_motor_sel_switch_pos_R = math.max(0, C90DR_iceRain_engine_act_motor_sel_switch_pos_R - 1)
	end
end

function C90_iceRain_engine_antiice_sel_switch_both_CMDhandler(phase, duration)     --IBAV8N, Mar16-22, one command to toggle both engine anti-ice switches
	if phase == 0 then
        if simDR_engine_antiice_left ~= simDR_engine_antiice_right then
            simDR_engine_antiice_right = simDR_engine_antiice_left
        else simDR_engine_antiice_left = 1 - simDR_engine_antiice_left
            simDR_engine_antiice_right = 1 - simDR_engine_antiice_right
        end
    end
end

function C90_iceRain_engine_antiice_sel_switch_L_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_engine_antiice_left = 1 - simDR_engine_antiice_left
	end
end

function C90_iceRain_engine_antiice_sel_switch_L_Up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_engine_antiice_left = math.min(1, simDR_engine_antiice_left + 1)
	end
end

function C90_iceRain_engine_antiice_sel_switch_L_Down_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_engine_antiice_left = math.max(0, simDR_engine_antiice_left - 1)
	end
end

function C90_iceRain_engine_antiice_sel_switch_R_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_engine_antiice_right = 1 - simDR_engine_antiice_right
	end
end

function C90_iceRain_engine_antiice_sel_switch_R_Up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_engine_antiice_right = math.min(1, simDR_engine_antiice_right + 1)
	end
end

function C90_iceRain_engine_antiice_sel_switch_R_Down_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_engine_antiice_right = math.max(0, simDR_engine_antiice_right - 1)
	end
end

function C90_iceRain_windshield_antiice_switch_up_L_CMDhandler(phase, duration) --IBAV8N Aug23-23 switches now use XP12 drefs
	if phase == 0 then
		C90DR_iceRain_windshield_antiice_switch_pos_L = math.min(1, C90DR_iceRain_windshield_antiice_switch_pos_L + 1)
        C90_windshield_anti_ice()
	end
end

function C90_iceRain_windshield_antiice_switch_dn_L_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_windshield_antiice_switch_pos_L = math.max(-1, C90DR_iceRain_windshield_antiice_switch_pos_L - 1)
        C90_windshield_anti_ice()
	end
end

function C90_iceRain_windshield_antiice_switch_up_R_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_windshield_antiice_switch_pos_R = math.min(1, C90DR_iceRain_windshield_antiice_switch_pos_R + 1)
        C90_windshield_anti_ice()
	end
end

function C90_iceRain_windshield_antiice_switch_dn_R_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_windshield_antiice_switch_pos_R = math.max(-1, C90DR_iceRain_windshield_antiice_switch_pos_R - 1)
        C90_windshield_anti_ice()
	end
end

function C90_windshield_anti_ice()
    simDR_heat_on_window_pilot_norm = C90_ternary(C90DR_iceRain_windshield_antiice_switch_pos_L > 0, 1, 0)
    simDR_heat_on_window_pilot_hi = C90_ternary(C90DR_iceRain_windshield_antiice_switch_pos_L < 0, 1, 0)
    simDR_heat_on_window_copilot_norm = C90_ternary(C90DR_iceRain_windshield_antiice_switch_pos_R > 0, 1, 0)
    simDR_heat_on_window_copilot_hi = C90_ternary(C90DR_iceRain_windshield_antiice_switch_pos_R < 0, 1, 0)
    if is_timer_scheduled(C90_compass_emi) == false then
        run_at_interval(C90_compass_emi, 1)
    end
    if is_timer_scheduled(C90_windshield_cooling) == false then
        run_at_interval(C90_windshield_cooling, 1)
    end
end

function C90_iceRain_fuel_vent_switch_L_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_fuel_vent_deice_switch_pos_L = 1 - C90DR_iceRain_fuel_vent_deice_switch_pos_L
	end
end

function C90_iceRain_fuel_vent_switch_L_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_fuel_vent_deice_switch_pos_L = math.min(1, C90DR_iceRain_fuel_vent_deice_switch_pos_L + 1)
	end
end

function C90_iceRain_fuel_vent_switch_L_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_fuel_vent_deice_switch_pos_L = math.max(0, C90DR_iceRain_fuel_vent_deice_switch_pos_L - 1)
	end
end

function C90_iceRain_fuel_vent_switch_R_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_fuel_vent_deice_switch_pos_R = 1 - C90DR_iceRain_fuel_vent_deice_switch_pos_R
	end
end

function C90_iceRain_fuel_vent_switch_R_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_fuel_vent_deice_switch_pos_R = math.min(1, C90DR_iceRain_fuel_vent_deice_switch_pos_R + 1)
	end
end

function C90_iceRain_fuel_vent_switch_R_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_fuel_vent_deice_switch_pos_R = math.max(0, C90DR_iceRain_fuel_vent_deice_switch_pos_R - 1)
	end
end

function C90_iceRain_stall_warn_heat_CMDhandler(phase, duration)
	if phase == 0 then
        C90DR_stall_warn_heat_pos = 1 - C90DR_stall_warn_heat_pos
        simDR_AOA_heat = C90DR_stall_warn_heat_pos
        simDR_AOA_heat2 = C90DR_stall_warn_heat_pos
	end
end

function C90_iceRain_stall_warn_heat_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_stall_warn_heat_pos = math.min(1, C90DR_stall_warn_heat_pos + 1)
        simDR_AOA_heat = C90DR_stall_warn_heat_pos
        simDR_AOA_heat2 = C90DR_stall_warn_heat_pos
	end
end

function C90_iceRain_stall_warn_heat_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_stall_warn_heat_pos = math.max(0, C90DR_stall_warn_heat_pos - 1)
        simDR_AOA_heat = C90DR_stall_warn_heat_pos
        simDR_AOA_heat2 = C90DR_stall_warn_heat_pos
	end
end

function C90_iceRain_surface_deice_switch_up_CMDhandler(phase, duration)    -- SINGLE CYCLE
	if phase == 0 then
		C90DR_iceRain_surface_deice_switch_pos = 1
        C90.iceRain.current_action = 1 -- cycle
        C90.iceRain.surface_deice_phase = 1
	elseif phase == 2 then
		C90DR_iceRain_surface_deice_switch_pos = 0
	end
end

function C90_iceRain_surface_deice_switch_dn_CMDhandler(phase, duration)    -- MANUAL
	if phase == 0 then
		C90DR_iceRain_surface_deice_switch_pos = -1
	elseif phase == 1 then
        C90.iceRain.current_action = 2 -- inflate
	elseif phase == 2 then
        C90DR_iceRain_surface_deice_switch_pos = 0
        C90.iceRain.current_action = 3 -- deflate
	end
end

function C90_iceRain_prop_deice_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_prop_deice_switch_pos = 1 - C90DR_iceRain_prop_deice_switch_pos
	    C90_prop_deice()
	end
end

function C90_iceRain_prop_deice_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_prop_deice_switch_pos = 1
	    C90_prop_deice()
	end
end

function C90_iceRain_prop_deice_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_iceRain_prop_deice_switch_pos = 0
	    C90_prop_deice()
	end
end

----- AVIONICS SWITCH ON -----------------------------------------------------------------
function C90_avionics_on_toggle_CMDhandler(phase, duration)             --IBAV8N, Jan19-22
	if phase == 0 then
        C90DR_avionics_on_sw_pos = 1 - C90DR_avionics_on_sw_pos
	end
    if C90DR_avionics_on_sw_pos == 0 then
        simDR_EFIS_1_sel_pilot = 1
        simDR_EFIS_2_sel_pilot = 1
    end
end

function C90_avionics_on_switch_up_CMDhandler(phase, duration)          --IBAV8N,May22-22
	if phase == 0 then
        C90DR_avionics_on_sw_pos = 1
    end
end

function C90_avionics_on_switch_dn_CMDhandler(phase, duration)          --IBAV8N,May22-22
	if phase == 0 then
        C90DR_avionics_on_sw_pos = 0
        simDR_EFIS_1_sel_pilot = 1
        simDR_EFIS_2_sel_pilot = 1
    end
end

----- CABIN ALT --------------------------------------------------------------------------
function C90_cabin_alt_down_CMDhandler(phase, duration)
	if phase == 0 then
		cabin_down()
	elseif phase == 1 then
		if duration > 0.5 then cabin_down() end
	elseif phase == 2 then
		stop_timer(cabin_down)
	end
end

function cabin_down()
    simDR_pressure_cabin_alt_ft = simDR_pressure_cabin_alt_ft - 25
    if simDR_pressure_cabin_alt_ft < -1000 then simDR_pressure_cabin_alt_ft = -1000 end
end

function C90_cabin_alt_up_CMDhandler(phase, duration)
	if phase == 0 then
		cabin_up()
	elseif phase == 1 then
		if duration > 0.5 then cabin_up() end
	elseif phase == 2 then
		stop_timer(cabin_up)
	end
end

function cabin_up()
    simDR_pressure_cabin_alt_ft = simDR_pressure_cabin_alt_ft + 25
    if simDR_pressure_cabin_alt_ft > 10000 then simDR_pressure_cabin_alt_ft = 10000 end
end

-- PILOT'S AUTO COMM SELECTOR
function C90_avionics_auto_comm_switch_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_auto_comm_switch_pos_pilot = 1 - C90DR_avionics_auto_comm_switch_pos_pilot
		autocomm()
	end
end

-- PILOT'S COM1 SWITCH
function C90_avionics_com1_audio_switch_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_com1_audio_switch_pos_pilot = 1 - C90DR_avionics_com1_audio_switch_pos_pilot
		autocomm()
	end
end

-- PILOT'S COM2 SWITCH
function C90_avionics_com2_audio_switch_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_com2_audio_switch_pos_pilot = 1 - C90DR_avionics_com2_audio_switch_pos_pilot
		autocomm()
	end
end

-- FUNCTION PILOT'S COM1 UP
function C90_avionics_audio_sel_com1_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_com1_audio_switch_pos_pilot = math.min(1, C90DR_avionics_com1_audio_switch_pos_pilot + 1)
		autocomm()
	end
end

-- FUNCTION PILOT'S COM1 DOWN
function C90_avionics_audio_sel_com1_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_com1_audio_switch_pos_pilot = math.max(0, C90DR_avionics_com1_audio_switch_pos_pilot - 1)
		autocomm()
	end
end

-- FUNCTION PILOT'S COM2 UP
function C90_avionics_audio_sel_com2_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_com2_audio_switch_pos_pilot = math.min(1, C90DR_avionics_com2_audio_switch_pos_pilot + 1)
		autocomm()
	end
end

-- FUNCTION PILOT'S COM2 DOWN
function C90_avionics_audio_sel_com2_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_com2_audio_switch_pos_pilot = math.max(0, C90DR_avionics_com2_audio_switch_pos_pilot - 1)
		autocomm()
	end
end

-- FUNCTION PILOT'S NAV1 UP
function C90_avionics_audio_sel_nav1_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_audio_selection_nav1 = math.min(1, simDR_audio_selection_nav1 + 1)
	end
end

-- FUNCTION PILOT'S NAV1 DOWN
function C90_avionics_audio_sel_nav1_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_audio_selection_nav1 = math.max(0, simDR_audio_selection_nav1 - 1)
	end
end

-- FUNCTION PILOT'S NAV2 UP
function C90_avionics_audio_sel_nav2_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_audio_selection_nav2 = math.min(1, simDR_audio_selection_nav2 + 1)
	end
end

-- FUNCTION PILOT'S NAV2 DOWN
function C90_avionics_audio_sel_nav2_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_audio_selection_nav2 = math.max(0, simDR_audio_selection_nav2 - 1)
	end
end

-- PILOT'S BKN 1 SWITCH
function C90_avionics_mkr_bkn1_switch_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot = 1 - C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot
        beaconfail()
	end
end

-- PILOT'S BKN 2 SWITCH
function C90_avionics_mkr_bkn2_switch_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mkr_audio_bkn2_switch_pos_pilot = 1 - C90DR_avionics_mkr_audio_bkn2_switch_pos_pilot
        beaconfail()
	end
end

-- FUNCTION PILOT'S ADF UP
function C90_avionics_audio_sel_adf1_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_audio_selection_adf1 = math.min(1, simDR_audio_selection_adf1 + 1)
	end
end

-- FUNCTION PILOT'S ADF DOWN
function C90_avionics_audio_sel_adf1_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_audio_selection_adf1 = math.max(0, simDR_audio_selection_adf1 - 1)
	end
end

-- FUNCTION PILOT'S DME UP
function C90_avionics_audio_sel_dme_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
	end
end

-- FUNCTION PILOT'S DME DOWN
function C90_avionics_audio_sel_dme_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
	end
end

-- FUNCTION PILOT'S MKR UP
function C90_avionics_audio_sel_mkr_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot = math.min(1, C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot + 1)
		simDR_audio_selected_mkr = C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot
	end
end

-- FUNCTION PILOT'S MKR DOWN
function C90_avionics_audio_sel_mkr_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot = math.max(0, C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot - 1)
		simDR_audio_selected_mkr = C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot
	end
end

-- PILOT'S MIC SELECT UP (BIG BLACK KNOB)
function C90_avionics_mmic_sel_dial_up_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mic_sel_dial_pos_pilot = math.min(2, C90DR_avionics_mic_sel_dial_pos_pilot + 1)
    elseif phase ==2 then
        simDR_com1_monitor = 0
        simDR_com2_monitor = 0
		run_after_time(autocomm, 0.05)
	end
end

-- PILOT'S MIC SELECT DOWN (BIG BLACK KNOB)
function C90_avionics_mmic_sel_dial_dn_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mic_sel_dial_pos_pilot = math.max(0, C90DR_avionics_mic_sel_dial_pos_pilot - 1)
    elseif phase ==2 then
        simDR_com1_monitor = 0
        simDR_com2_monitor = 0
		run_after_time(autocomm, 0.05)
	end
end

-- HEADSET AUDIO  		--IBAV8N, modified headset function, different volumes outside
function C90_avionics_audio_spkr_switch_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_audio_spkr_switch_pos_pilot = 1 - C90DR_avionics_audio_spkr_switch_pos_pilot
		if C90DR_avionics_audio_spkr_switch_pos_pilot == 1 then
			run_at_interval(noise, 0.02)
		elseif C90DR_avionics_audio_spkr_switch_pos_pilot == 0 then
			simDR_volume_engine = save_volume_engine
			simDR_volume_environment = save_volume_environment
			simDR_volume_interior = save_volume_interior
            stop_timer(noise)
		end
	end
end

function C90_avionics_audio_spkr_reset_CMDhandler(phase, duration)
    save_volume_engine = 1
    save_volume_environment = 1
    save_volume_interior = 1
end

function noise()
    local atten = 0
    if simDR_view_is_external == 0 then
        if simDR_head_pos_z < 0 then
            atten = 2
        else atten = 1
        end
    else atten = 0
    end
    if atten == 0 then                                      --outside
        simDR_volume_engine = 1
        simDR_volume_environment = 1
        simDR_volume_interior = 1
    elseif atten == 1 then                                  --cabin
        simDR_volume_engine = 0.5
        simDR_volume_environment = 0.7
        simDR_volume_interior = 0.6
    elseif atten == 2 then                                  --cockpit
	    simDR_volume_engine = volume_engine
	    simDR_volume_environment = volume_environment
	    simDR_volume_interior = volume_interior
    end
end

-- AUDIO EMERGENCY
function C90_avionics_audio_emer_norm_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_audio_emer_norm_switch_pos = 1 - C90DR_avionics_audio_emer_norm_switch_pos
		if C90DR_avionics_audio_emer_norm_switch_pos == 1 then
			com1_fail = simDR_com1_fail
			com2_fail = simDR_com2_fail
			if firstcom == 0 then
				firstcomfail = math.random(0,1)
				if firstcomfail == 0 then
					simDR_com1_fail = 0
					simDR_com2_fail = 0
					firstcom = 1
					com1_fix = 0
					com2_fix = 0
				elseif firstcomfail == 1 then
					simDR_com1_fail	= com1_fail
					simDR_com2_fail = com2_fail
					firstcom = 1
				end
			elseif firstcom == 1 then
				if firstcomfail == 0 then
					simDR_com1_fail = com1_fix
					simDR_com2_fail = com2_fix
				elseif firstcomfail == 1 then
					simDR_com1_fail	= com1_fail
					simDR_com2_fail = com2_fail
				end
			end
		elseif C90DR_avionics_audio_emer_norm_switch_pos == 0 then
			simDR_com1_fail	= com1_fail
			simDR_com2_fail = com2_fail
		end
	end
end

-- PILOTEDGE CONNECT/DISCONNECT
function C90_avionics_voice_range_switch_up_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_voice_range_switch_pos_pilot = math.min(1, C90DR_avionics_voice_range_switch_pos_pilot + 1)
		if C90DR_avionics_voice_range_switch_pos_pilot == 1 and simDR_pilotedge_connected == true then
			simCMD_pilotedge_connect:once()
		end
	end
end

function C90_avionics_voice_range_switch_dn_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_voice_range_switch_pos_pilot = math.max(-1, C90DR_avionics_voice_range_switch_pos_pilot - 1)
		if C90DR_avionics_voice_range_switch_pos_pilot == -1 and simDR_pilotedge_connected == true then
			simCMD_pilotedge_disconnect:once()
		end
	end
end

-- DME AUDIO
function C90_avionics_dme_channel_sel_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_dme_channel_sel_switch_pos = 1 - C90DR_avionics_dme_channel_sel_switch_pos
	end
end

-- ALTIMETER ENCODER FAIL
function C90_avionics_encd_atim_sel_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_encd_atim_sel_switch_pos = 1 - C90DR_avionics_encd_atim_sel_switch_pos
		if C90DR_avionics_encd_atim_sel_switch_pos == 0 then
			if encdone == 6 then
				simDR_xpndr_fail = 6
			elseif encdone == 0 then
				simDR_xpndr_fail = 0
			end
		elseif C90DR_avionics_encd_atim_sel_switch_pos == 1 then
			if simDR_xpndr_fail == 6 then
				encdone = 6
				if encdtwo == 1 then
					simDR_xpndr_fail = math.random(6,10)
					if simDR_xpndr_fail == 6 then
					   encdtwo = 6
					elseif simDR_xpndr_fail ~= 6 then
					   encdtwo = 0
					end
				elseif encdtwo == 6 then
					simDR_xpndr_fail = 6
				elseif encdtwo == 0 then
					simDR_xpndr_fail = 0
				end
			elseif simDR_xpndr_fail == 0 then
				encdone = 0
			end
		end
	end
end

-- GROUND COMMUNICATION POWER
function C90_avionics_grd_pwr_comm_switch_CMDhandler(phase, duration) 		--IBAV8N, Jan25-22
	if phase == 0 then
        C90DR_avionics_grd_pwr_comm_switch_pos = 1 - C90DR_avionics_grd_pwr_comm_switch_pos
    elseif phase == 2 then
        if C90DR_power == 1 then
            C90DR_avionics_grd_pwr_comm_switch_pos = 0
        end
    end
end

-- ALTITUDE ALERT CANX SWITCH
function C90_autopilot_altAlert_canx_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_autopilot_altAlert_canx_switch_pos = 1
		C90.pre80.alert_canx = 1
	elseif phase == 2 then
		C90DR_autopilot_altAlert_canx_switch_pos = 0
	end
end

-- ALTITUDE ALERT SEL100 SWITCH
function C90_autopilot_altSel100_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_autopilot_altSel100_switch_pos = 1 - C90DR_autopilot_altSel100_switch_pos
	end
end

-- COPILOT'S COM1 SWITCH
function C90_avionics_com1_audio_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_com1_audio_switch_pos_copilot = 1 - C90DR_avionics_com1_audio_switch_pos_copilot
	end
end

-- COPILOT'S COM2 SWITCH
function C90_avionics_com2_audio_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_com2_audio_switch_pos_copilot = 1 - C90DR_avionics_com2_audio_switch_pos_copilot
	end
end

-- COPILOT'S NAV1 SWITCH
function C90_avionics_nav1_audio_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_nav1_audio_switch_pos_copilot = 1 - C90DR_avionics_nav1_audio_switch_pos_copilot
	end
end

-- COPILOT'S NAV2 SWITCH
function C90_avionics_nav2_audio_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_nav2_audio_switch_pos_copilot = 1 - C90DR_avionics_nav2_audio_switch_pos_copilot
	end
end

-- COPILOT'S BKN 1 SWITCH
function C90_avionics_mkr_bkn1_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mkr_audio_bkn1_switch_pos_copilot = 1 - C90DR_avionics_mkr_audio_bkn1_switch_pos_copilot
	end
end

-- COPILOT'S BKN2 SWITCH
function C90_avionics_mkr_bkn2_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mkr_audio_bkn2_switch_pos_copilot = 1 - C90DR_avionics_mkr_audio_bkn2_switch_pos_copilot
	end
end

-- COPILOT'S DME SWITCH
function C90_avionics_dme_audio_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_dme_audio_switch_pos_copilot = 1 - C90DR_avionics_dme_audio_switch_pos_copilot
	end
end

-- COPILOT'S ADF SWITCH
function C90_avionics_adf1_audio_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_adf1_audio_switch_pos_copilot = 1 - C90DR_avionics_adf1_audio_switch_pos_copilot
	end
end

-- COPILOT'S AUTOCOMM SWITCH
function C90_avionics_auto_comm_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_auto_comm_switch_pos_copilot = 1 - C90DR_avionics_auto_comm_switch_pos_copilot
	end
end

-- FSECONOMY CONNECT/START
function C90_avionics_voice_range_switch_up_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_voice_range_switch_pos_copilot = math.min(1, C90DR_avionics_voice_range_switch_pos_copilot + 1)
		if C90DR_avionics_voice_range_switch_pos_copilot == 1 and simCMD_fseconomy_connect == true then
			simCMD_fseconomy_connect:once()
			stop_timer(fse_finish)
			run_at_interval(fse_start, 2)
		end
	end
end

-- FSECONOMY FINISH
function C90_avionics_voice_range_switch_dn_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_voice_range_switch_pos_copilot = math.max(-1, C90DR_avionics_voice_range_switch_pos_copilot - 1)
	    if C90DR_avionics_voice_range_switch_pos_copilot == -1 and simCMD_fseconomy_connect == true then
			stop_timer(fse_start)
			run_at_interval(fse_finish, 2)
		end
	end
end

function fse_start()
	if simDR_cabindoor == 0 then
		simCMD_fseconomy_start:once()
		stop_timer(fse_start)
	end
end

function fse_finish()
	if simDR_cabindoor == 1 then
		simCMD_fseconomy_finish:once()
		simCMD_fseconomy_finish:once()
		stop_timer(fse_finish)
	end
end

-- HOT INTERPHONE
function C90_avionics_hot_intph_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_hot_intph_switch_pos = 1 - C90DR_avionics_hot_intph_switch_pos
	end
end

-- GPS POWER
function C90_avionics_gps_power_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_gps_power_switch_pos = 1 - C90DR_avionics_gps_power_switch_pos
	end
end

-- COPILOT'S MIC SELECT UP (BIG BLACK KNOB)
function C90_avionics_mmic_sel_dial_up_copilot_CMDhandler(phase, duration)                                      --laminar/c90/avionics/dial/mic_sel_up_copilot
	if phase == 0 then
		C90DR_avionics_mic_sel_dial_pos_copilot = math.min(2, C90DR_avionics_mic_sel_dial_pos_copilot + 1)      --C90DR_avionics_mic_sel_dial_pos_copilot=laminar/c90/avionics/dial/mic_sel_pos_copilot
	end
end

-- COPILOT'S MIC SELECT DOWN (BIG BLACK KNOB)
function C90_avionics_mmic_sel_dial_dn_copilot_CMDhandler(phase, duration)                                      --laminar/c90/avionics/dial/mic_sel_dn_copilot
	if phase == 0 then
		C90DR_avionics_mic_sel_dial_pos_copilot = math.max(0, C90DR_avionics_mic_sel_dial_pos_copilot - 1)
	end
end

-- MARKER BEACON SENSE SWITCH
function C90_avionics_mkr_bkn_sense_switch_CMDhandler(phase, duration)  --IBAV8N,Jun16-21
	if phase == 0 then
		C90DR_avionics_mkr_bkn_sense_switch_pos = 1 - C90DR_avionics_mkr_bkn_sense_switch_pos
	    simDR_radio_marker_sens = C90DR_avionics_mkr_bkn_sense_switch_pos
	end
end

-- ANNUNCIATOR BRIGHTNESS AMBIENT LIGHT SENSOR
function C90_avionics_annun_brt_switch_CMDhandler(phase, duration) --IBAV8N, This needs work.
	--if phase == 0 then
		--if brightness == 0 then
			--run_at_interval(annunciator, 1)
		--elseif brightness == 1 then
		--	stop_timer(annunciator)
		--	brightness = 0
		--	simDR_switch_instr_brightness_ratio[10] = 1
		--end
	--end
end

--function annunciator()
--	simDR_switch_instr_brightness_ratio[10] = math.min(0.7 / simDR_cockpit_ambient_light, 1)
--	brightness = 1
--end

function C90_avionics_decision_height_dial_up_CMDhandler(phase, duration)   --IBAV8N, Apr26-22, variable speed with keypress time
	if phase == 0 then
		C90DR_avionics_decision_height_dial_pos = math.min(999, C90DR_avionics_decision_height_dial_pos + 1)
	elseif phase == 1 then
		C90DR_avionics_decision_height_dial_pos = math.min(999, C90DR_avionics_decision_height_dial_pos + 0.2 * math.min(duration, 100))
	end
end

function C90_avionics_decision_height_dial_dn_CMDhandler(phase, duration)   --IBAV8N, DH cannot go below zero now
	if phase == 0 then
		C90DR_avionics_decision_height_dial_pos = math.max(0, C90DR_avionics_decision_height_dial_pos - 1)
	elseif phase == 1 then
		C90DR_avionics_decision_height_dial_pos = math.max(0, C90DR_avionics_decision_height_dial_pos - 0.2 * math.min(duration, 100))
	end
end

function C90_avionics_nav_data_sel_dial_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_nav_data_sel_dial_pos = math.min(3, C90DR_avionics_nav_data_sel_dial_pos + 1)
	end
    C90_EFIS_map_mode()
end

function C90_avionics_nav_data_sel_dial_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_nav_data_sel_dial_pos = math.max(0, C90DR_avionics_nav_data_sel_dial_pos - 1)
	end
    C90_EFIS_map_mode()
end

-- MICROPHONE OXYGEN
function C90_avionics_mic_sel_switch_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mic_sel_switch_pos_pilot = 1 - C90DR_avionics_mic_sel_switch_pos_pilot
	end
    C90_oxygen()
end

function C90_avionics_mic_sel_switch_copilot_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_mic_sel_switch_pos_copilot = 1 - C90DR_avionics_mic_sel_switch_pos_copilot
	end
    C90_oxygen()
end

function C90_oxygen()
    local function one_or_two(weight)
        if weight > 91 then return 2
        elseif weight > 0 then return 1
        else return 0
        end
    end
    local oxy_on = math.max(C90DR_avionics_mic_sel_switch_pos_pilot, C90DR_avionics_mic_sel_switch_pos_copilot)
    local station_1 = one_or_two(simDR_m_stations[1])
    local station_2 = one_or_two(simDR_m_stations[2])
    local station_3 = C90_ternary(simDR_m_stations[3] > 0, 1, 0)
    local station_4 = C90_ternary(simDR_m_stations[4] > 0, 1, 0)
    simDR_o2_valve_on = oxy_on
    simDR_demand_flow_setting = oxy_on
    simDR_num_plugged_in_o2 = oxy_on * (4 + station_1 + station_2 + station_3 + station_4)
end

function C90_crs_sel_timeout()
	C90_stop_sel_cycle()
end

function C90_stop_sel_cycle()
	if is_timer_scheduled(C90_crs_sel_timeout) == true then
		stop_timer(C90_crs_sel_timeout)
	end
	C90DR_avionics_crs_sel_cycle_active = 0
	C90DR_avionics_crs_sel_cycle_index = 0
    C90.avionics.crs_sel_trigger = 0
end

function C90_set_crs_sel_index()                                                                    --IBAV8N, Jan22-22, called upon to determine which nav sources are available
	local index = C90DR_avionics_crs_sel_cycle_index + 1
	local crs_sel_found = false
	repeat
        -- NONE                                                                                     --IF NO RADIO SOURCES AVAILABLE, ALLOW TO SET COURSE AND GAIN ALT TO FIND SIGNAL
        if index == 0 and C90.avionics.vor_avail == 0 and C90.avionics.loc_avail == 0 then
			C90DR_avionics_crs_sel_cycle_index = 0
			crs_sel_found = true
		-- VOR                                                                                      --VOR SIGNAL AVAILABLE, SELECT AUTOMATICALLY
		elseif index == 1 and C90.avionics.vor_avail == 1 then
			C90DR_avionics_crs_sel_cycle_index = 1
			crs_sel_found = true
		-- LOC                                                                                      --LOC SIGNAL AVAILABLE, SELECT AUTOMATICALLY
		elseif index == 2 and C90.avionics.loc_avail == 1 then
			C90DR_avionics_crs_sel_cycle_index = 2
			crs_sel_found = true
		-- GPS                                                                                      --GPS POWER ON AND SIGNAL AVAILABLE, OPTIONAL
		elseif index == 3 and simDR_gps530_power == 1 then
			C90DR_avionics_crs_sel_cycle_index = 3
			crs_sel_found = true
		else
			index = index + 1
			if index > 3 then index = 0 end
		end
	until crs_sel_found
end

function C90_avionics_crs_sel_switch_CMDhandler(phase, duration) 				                        --IBAV8N, May7-22, added PRE mode to CRS SEL
	if phase == 0 then
		C90DR_avionics_crs_sel_switch_pos = 1	                                                        -- SET THE SWITCH AMIMATION
        if C90DR_avionics_crs_sensor_sel_dial_pos == 0 then	                                            -- IN PRE MODE?
            if C90DR_avionics_EFIS_map_mode_sel_dial_pos == 2 then                                      -- IN HSI MODE?
			    C90DR_avionics_EFIS_pre_sel_cycle_active = 1                                            -- SHOW WHITE PRE SELECTION BOX
		    end
        elseif C90DR_avionics_crs_sensor_sel_dial_pos == 1 then	                                        -- IN ACT MODE?
		    if C90DR_avionics_crs_sel_cycle_active == 0 then                                            -- COURSE SELECT CYCLE IS INACTIVE?
		        C90DR_avionics_crs_sel_cycle_index = C90DR_avionics_cur_crs_sel_index                   -- CYCLE INDEX = CURRENT INDEX
                C90DR_avionics_crs_sel_cycle_active = 1                                                 -- SET COURSE SELECT CYCLE TO ACTIVE
			    run_after_time(C90_crs_sel_timeout, 5)	                                                -- START THE 5 SECOND COURSE SELECT CYCLE TIMEOUT
            end
        end
	elseif phase == 1 then
        if C90DR_avionics_crs_sensor_sel_dial_pos == 1 then                                             -- HOLDING CRS SEL IN ACT MODE?
		    if duration > 0.5 then                                                                      -- CRS SEL PRESSED FOR MORE THAN 1/2 SECOND?
			    if C90.avionics.crs_sel_hold_flag == 0 then                                             -- NOT ALREADY IN PROGRESS?
                    if C90DR_avionics_crs_sel_cycle_active == 1 then                                    -- COURSE SELECT CYCLE IS ACTIVE?
					    C90DR_avionics_cur_crs_sel_index = C90DR_avionics_crs_sel_cycle_index           -- SET CURRENT INDEX = CYCLE INDEX
					    if C90DR_avionics_cur_crs_sel_index < 3 then                                    -- HSI SOURCE IS VOR OR LOC?
						    simDR_hsi_source_sel_pilot = 0		                                        -- USE GREEN BC MAP
					    else
						    simDR_hsi_source_sel_pilot = 2	                                            -- OTHERWISE USE WHITE MAP FOR GPS
					    end
                        C90.avionics.crs_sel_trigger = 0                                                -- RESET THE TRIGGER
					    C90_stop_sel_cycle()                                                            -- STOP THE SELECT CYCLE PROCESS, HIDE WHITE BOX
				    end
			    end
			    C90.avionics.crs_sel_hold_flag = 1	                                                    -- SET THE HOLD FLAG TO PREVENT REPETITION OF THE HOLD LOGIC
		    end
	    end
	elseif phase == 2 then
		C90DR_avionics_crs_sel_switch_pos = 0                                                           -- SET THE SWITCH AMIMATION
	    if C90DR_avionics_crs_sensor_sel_dial_pos == 0  then                                            -- LOGIC FOR "PRE" POSITION OF COURSE SENSOR SELECTOR
            if C90DR_avionics_EFIS_map_mode_sel_dial_pos == 2 then                                      -- MUST BE IN HSI MODE
		        C90DR_avionics_EFIS_pre_crs_cycle_index = 1 - C90DR_avionics_EFIS_pre_crs_cycle_index   -- FLIP LOC OR VOR CYCLE INDEX
		        C90DR_avionics_EFIS_pre_crs_sel_index = C90DR_avionics_EFIS_pre_crs_cycle_index         -- MAKE SELECTED INDEX = CYCLE INDEX
			    if C90DR_avionics_EFIS_pre_crs_sel_index == 0 then                                      -- IF SEL INDEX = 0 THEN LOC
			        if C90DR_avionics_EFIS_pre_loc_active == 1 then                                     -- IF LOC WAS PREVIOUSLY MODIFIED
				        simDR_radio_nav1_OBS_deg_co = C90DR_avionics_EFIS_pre_loc_crs                   -- SET OBS TO LOC PRE
				    else
                        simDR_radio_nav1_OBS_deg_co = 0                                                 -- IF LOC WAS NOT PREV. SET, SET OBS TO ZERO
                    end
			    elseif C90DR_avionics_EFIS_pre_crs_sel_index == 1 then                                  -- IF SEL INDEX = 1 THEN VOR
				    if C90DR_avionics_EFIS_pre_vor_active == 1 then                                     -- IF VOR WAS PREVIOUSLY MODIFIED
				        simDR_radio_nav1_OBS_deg_co = C90DR_avionics_EFIS_pre_vor_crs                   -- SET OBS TO VOR PRE
				    else
                        simDR_radio_nav1_OBS_deg_co = 0                                                 -- IF VOR WAS NOT PREV. SET, SET OBS TO ZERO
                    end
			    end
		        C90DR_avionics_EFIS_pre_sel_cycle_active = 0                                            -- HIDE WHITE PRE SELECTION BOX
                navneedles()
            end
	    elseif C90DR_avionics_crs_sensor_sel_dial_pos == 1 then                                         -- LOGIC FOR "ACT" POSITION	OF COURSE SENSOR SELECTOR
		    if C90DR_avionics_crs_sel_cycle_active == 1 then                                            -- COURSE SELECT CYCLE IS ACTIVE
			    run_after_time(C90_crs_sel_timeout, 5)                                                  -- RESET THE SELECTION CYCLE TIMER
                if C90.avionics.crs_sel_trigger == 1 then
				    C90_set_crs_sel_index()	                                                  	        -- SET THE CRS SELECTION INDEX
                end
                C90.avionics.crs_sel_trigger = 1
		    end
	    end
	    C90.avionics.crs_sel_hold_flag = 0	                                                            -- RESET THE COURSE HOLD FLAG - BUTTON NO LONGER PRESSED
	end
end

function C90_avionics_crs_sensor_sel_dial_up_CMDhandler(phase, duration)                                        --IBAV8N,Apr13-21, XFR function
	if phase == 0 then
	    C90DR_avionics_crs_sensor_sel_dial_pos = math.min(2, C90DR_avionics_crs_sensor_sel_dial_pos + 1)        --PRE/ACT/XFR dial go up one
	    if C90DR_avionics_crs_sensor_sel_dial_pos == 2 then                                                     --if dial goes to XFR
            if C90DR_avionics_EFIS_map_mode_sel_dial_pos == 2 then                                              --in HSI mode
		        gps_pri = simDR_hsi_source_sel_pilot                                                            --save gps activeness
			    if C90.avionics.loc_avail == 1 then                                                             --is nav1 tuned to loc?
                    C90DR_avionics_cur_crs_sel_index = 0                                                        --if so, reset index
				    simDR_nav1_obs_degm = C90DR_avionics_EFIS_pre_loc_crs                                       --active obs becomes pre loc crs
				    simDR_hsi_source_sel_pilot = 0                                                              --nav source set to nav1
				    C90DR_avionics_EFIS_pre_loc_dsply = 0                                                       --pre loc no longer displayed
                    C90DR_avionics_EFIS_pre_loc_active = 0                                                      --pre loc no longer active
			    elseif C90.avionics.vor_avail == 1 then                                                         --is nav1 tuned to vor?
                    C90DR_avionics_cur_crs_sel_index = 0                                                        --if so, reset index
				    xfr_vor = simDR_nav1_obs_degm                                                               --store active vor crs
				    simDR_nav1_obs_degm = C90DR_avionics_EFIS_pre_vor_crs                                       --set nav1 OBS to saved pre vor crs
				    C90DR_avionics_EFIS_pre_vor_crs = xfr_vor                                                   --active obs becomes pre vor crs
				    simDR_hsi_source_sel_pilot = 0                                                              --nav source set to nav1
				    C90DR_avionics_EFIS_pre_vor_dsply = 0                                                       --pre vor no longer displayed
                    C90DR_avionics_EFIS_pre_vor_active = 0                                                      --pre vor no longer active
			    else simDR_hsi_source_sel_pilot = gps_pri                                                       --maintain gps if nav1 not tuned to active freq
			    end
            end
	    end
	elseif phase == 2 then                                          							                --IBAV8N,Mar9-21, crs sensor dial springs back to ACT from XFR.
        if C90DR_avionics_crs_sensor_sel_dial_pos == 2 then
            C90DR_avionics_crs_sensor_sel_dial_pos = 1
        end
	end
end

function C90_avionics_crs_sensor_sel_dial_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_crs_sensor_sel_dial_pos = math.max(0, C90DR_avionics_crs_sensor_sel_dial_pos - 1)
	end
end

--CRS PUSH DIRECT BUTTON
function C90_avionics_crs_sync_sel_switch_CMDhandler(phase, duration)   --IBAV8N, Sept3-23, NEW CODE - CENTER THE PRE NEEDLE, HOLDING WILL CONTIN. UPDATE
   if C90.avionics.vor_avail == 1 then                                  --TUNED VOR IS AVAILABLE
        if C90DR_avionics_crs_sensor_sel_dial_pos == 0                  --PRE
            and C90DR_avionics_EFIS_pre_crs_cycle_index == 1            --PRE-VOR ANNUN
            and C90DR_avionics_EFIS_map_mode_sel_dial_pos == 2 then     --HSI
	        if phase == 0 then          
                navneedles_show()
	        elseif phase == 1 then
	            simDR_radio_nav1_OBS_deg_co = simDR_radio_nav1_bearing_deg      --SYNC THE COURSE
	            C90DR_avionics_EFIS_pre_vor_active = 1                          --PRE VOR IS ACTIVE
	            C90DR_avionics_EFIS_pre_vor_crs = simDR_radio_nav1_OBS_deg_co   --SET THE PRE COURSE IN MEMORY
            end
        elseif C90DR_avionics_crs_sensor_sel_dial_pos == 1 and simDR_hsi_source_sel_pilot == 0 and phase == 1 then  --ACT MODE AND IS HSI SOURCE    
            simDR_nav1_obs_degm = simDR_radio_nav1_bearing_deg                                                      --SYNC THE COURSE
        end
    end
end

function navneedles_show()                                      --IBAV8N, Sept3-23, SHOW THE PRE NEEDLE, CALL TO CENTER THE PRE NEEDLE
    if C90DR_avionics_EFIS_pre_crs_cycle_index == 0 then        --PRE-LOC
        if C90DR_avionics_EFIS_pre_loc_dsply == 0 then          --IF LOC CDI IS NOT VISIBLE         
            C90DR_avionics_EFIS_pre_loc_dsply = 1               --MAKE PRE LOC CDI VISIBLE
            navneedles()                                        --CENTER THE CDI
        end
    elseif C90DR_avionics_EFIS_pre_crs_cycle_index == 1 then    --PRE-VOR
        if C90DR_avionics_EFIS_pre_vor_dsply == 0 then          --IF VOR CDI IS NOT VISIBLE
            C90DR_avionics_EFIS_pre_vor_dsply = 1               --MAKE PRE VOR CDI VISIBLE
            navneedles()                                        --CENTER THE CDI
        end
    end
end

function navneedles()                                           --IBAV8N, Sept3-23, CENTER THE PRE NEEDLE
    C90.avionics.gps_crs_sel = 1
    simDR_override_nav1_needles = 1
    simDR_nav1_hdef_dot2 = 0
    run_after_time(navneedles_end, 1)
end

function navneedles_end()                                       --IBAV8N, Sept3-23, ALLOW PRE NEEDLE TO ALIGN
    simDR_override_nav1_needles = 0
    C90.avionics.gps_crs_sel = 0
end

function sim_obs_HSI_up_CMDhandler(phase, duration)		--IBAV8N
	if phase == 0 then
		obs_up()
	elseif phase == 1 then
		if duration > 0.5 then obs_up() end
	elseif phase == 2 then
		stop_timer(obs_up)
	end
end

function obs_up()										                                            --IBAV8N, Apr23-22, will now use 360, not 000
	if C90DR_avionics_crs_sensor_sel_dial_pos == 0 then                                             --IF IN -PRE MODE
        if C90DR_avionics_EFIS_map_mode_sel_dial_pos == 2 then                                      --IF IN HSI MODE
		    if C90DR_avionics_EFIS_pre_crs_cycle_index == 0 then                                    --IF IN PRE LOC MODE
                simDR_radio_nav1_OBS_deg_co = C90DR_avionics_EFIS_pre_loc_crs                       --COPILOT NAV1 OBS COURSE FOLLOWS PRE LOC COURSE
                C90DR_avionics_EFIS_pre_loc_active = 1                                              --MAKE PRE LOC ACTIVE
			    simDR_radio_nav1_OBS_deg_co = simDR_radio_nav1_OBS_deg_co + 1                       --INCREASE COPILOT NAV1 OBS BY 1
			    if simDR_radio_nav1_OBS_deg_co > 360.5 then simDR_radio_nav1_OBS_deg_co = 1 end     --IF COPILOT NAV1 OBS OVER 360.5 SET TO ONE
		        C90DR_avionics_EFIS_pre_loc_crs = simDR_radio_nav1_OBS_deg_co                       --IF COPILOT NAV1 OBS IS RESET DO SAME TO PRE LOC
		    elseif C90DR_avionics_EFIS_pre_crs_cycle_index == 1 then                                --IF IN PRE VOR MODE
	            simDR_radio_nav1_OBS_deg_co = C90DR_avionics_EFIS_pre_vor_crs                       --COPILOT NAV1 OBS COURSE FOLLOWS PRE VOR COURSE
                C90DR_avionics_EFIS_pre_vor_active = 1                                              --MAKE PRE VOR ACTIVE
			    simDR_radio_nav1_OBS_deg_co = simDR_radio_nav1_OBS_deg_co + 1                       --INCREASE COPILOT NAV1 OBS BY 1
			    if simDR_radio_nav1_OBS_deg_co > 360.5 then simDR_radio_nav1_OBS_deg_co = 1 end     --IF COPILOT NAV1 OBS OVER 360.5 SET TO ONE
			    C90DR_avionics_EFIS_pre_vor_crs = simDR_radio_nav1_OBS_deg_co                       --IF COPILOT NAV1 OBS IS RESET DO SAME TO PRE VOR
		    end
            navneedles_show()
        end
	elseif C90DR_avionics_crs_sensor_sel_dial_pos == 1 then                                         --IF IN ACT MODE
        if simDR_hsi_source_sel_pilot < 2 then                                                      --IF IN RADIO
            simDR_nav1_obs_degm = simDR_nav1_obs_degm + 1                                           --INCREASE PILOT NAV1 OBS BY 1
	        if simDR_nav1_obs_degm > 360.5 then simDR_nav1_obs_degm = 1 end                         --IF COPILOT NAV1 OBS OVER 360.5 SET TO ONE
        else                                                                                        --ELSE IN GPS
            simDR_gps_obs_degm = simDR_gps_obs_degm + 1                                             --INCREASE GPS OBS BY 1
	        if simDR_gps_obs_degm > 360.5 then simDR_gps_obs_degm = 1 end                           --IF GPS OBS OVER 360.5 SET TO ONE
        end
	end
end

function sim_obs_HSI_down_CMDhandler(phase, duration)	--IBAV8N
	if phase == 0 then
		obs_down()
	elseif phase == 1 then
		if duration > 0.5 then obs_down() end
	elseif phase == 2 then
		stop_timer(obs_down)
	end
end

function obs_down()										                                            --IBAV8N, Apr23-22, will now use 360, not 000
	if C90DR_avionics_crs_sensor_sel_dial_pos == 0 then                                             --IF IN -PRE MODE
        if C90DR_avionics_EFIS_map_mode_sel_dial_pos == 2 then                                      --IF IN HSI MODE
		    if C90DR_avionics_EFIS_pre_crs_cycle_index == 0 then                                    --IF IN PRE LOC MODE
		        simDR_radio_nav1_OBS_deg_co = C90DR_avionics_EFIS_pre_loc_crs                       --COPILOT NAV1 OBS COURSE FOLLOWS PRE LOC COURSE
                C90DR_avionics_EFIS_pre_loc_active = 1                                              --MAKE PRE LOC ACTIVE
			    simDR_radio_nav1_OBS_deg_co = simDR_radio_nav1_OBS_deg_co - 1                       --REDUCE COPILOT NAV1 OBS BY 1
			    if simDR_radio_nav1_OBS_deg_co < 0.5 then simDR_radio_nav1_OBS_deg_co = 360 end     --IF COPILOT NAV1 OBS LESS THAN ZERO SET TO 359
		        C90DR_avionics_EFIS_pre_loc_crs = simDR_radio_nav1_OBS_deg_co                       --IF COPILOT NAV1 OBS IS RESET DO SAME TO PRE LOC
		    elseif C90DR_avionics_EFIS_pre_crs_cycle_index == 1 then                                --IF IN PRE VOR MODE
		        simDR_radio_nav1_OBS_deg_co = C90DR_avionics_EFIS_pre_vor_crs                       --COPILOT NAV1 OBS COURSE FOLLOWS PRE VOR COURSE
                C90DR_avionics_EFIS_pre_vor_active = 1                                              --MAKE PRE VOR ACTIVE
			    simDR_radio_nav1_OBS_deg_co = simDR_radio_nav1_OBS_deg_co - 1                       --REDUCE COPILOT NAV1 OBS BY 1
			    if simDR_radio_nav1_OBS_deg_co < 0.5 then simDR_radio_nav1_OBS_deg_co = 360 end     --IF COPILOT NAV1 OBS LESS THAN ZERO SET TO 360
			    C90DR_avionics_EFIS_pre_vor_crs = simDR_radio_nav1_OBS_deg_co                       --IF COPILOT NAV1 OBS IS RESET DO SAME TO PRE VOR
		    end
            navneedles_show()
        end
	elseif C90DR_avionics_crs_sensor_sel_dial_pos == 1 then                                         --IF IN ACT MODE
        if simDR_hsi_source_sel_pilot < 2 then                                                      --IF IN RADIO
            simDR_nav1_obs_degm = simDR_nav1_obs_degm - 1                                           --REDUCE PILOT NAV1 OBS BY 1
	        if simDR_nav1_obs_degm < 0.5 then simDR_nav1_obs_degm = 360 end                         --IF PILOT NAV1 OBS LESS THAN ZERO SET TO 360
        else                                                                                        --ELSE IN GPS
            simDR_gps_obs_degm = simDR_gps_obs_degm - 1                                             --INCREASE GPS OBS BY 1
	        if simDR_gps_obs_degm < 0.5 then simDR_gps_obs_degm = 360 end                           --IF GPS OBS LESS THAN ZERO SET TO 360
        end
	end
end

function sim_copilot_obs_HSI_up_CMDhandler(phase, duration)     --IBAV8N, Apr24-21
	if phase == 0 then
		copilot_obs_up()
	elseif phase == 1 then
		if duration > 0.5 then copilot_obs_up() end
	elseif phase == 2 then
		stop_timer(copilot_obs_up)
	end
end

function copilot_obs_up()										--IBAV8N, Apr23-22, will now use 360, not 000
    simDR_radio_nav2_OBS_deg_co = simDR_radio_nav2_OBS_deg_co + 1
    if simDR_radio_nav2_OBS_deg_co > 360.5 then simDR_radio_nav2_OBS_deg_co = 1 end
end

function sim_copilot_obs_HSI_down_CMDhandler(phase, duration)   --IBAV8N, Apr24-21
	if phase == 0 then
		copilot_obs_down()
	elseif phase == 1 then
		if duration > 0.5 then copilot_obs_down() end
	elseif phase == 2 then
		stop_timer(copilot_obs_down)
	end
end

function copilot_obs_down()										--IBAV8N, Apr23-22, will now use 360, not 000
    simDR_radio_nav2_OBS_deg_co = simDR_radio_nav2_OBS_deg_co - 1
    if simDR_radio_nav2_OBS_deg_co < 0.5 then simDR_radio_nav2_OBS_deg_co = 360 end
end

function C90_avionics_brg_ptr1_sel_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_brg_ptr1_sel_switch_pos = 1
		simDR_EFIS_1_sel_pilot = simDR_EFIS_1_sel_pilot + 1
		if simDR_EFIS_1_sel_pilot == 3 then simDR_EFIS_1_sel_pilot = 0 end
	elseif phase == 2 then
		C90DR_avionics_brg_ptr1_sel_switch_pos = 0
	end
end

function C90_avionics_brg_ptr2_sel_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_brg_ptr2_sel_switch_pos = 1
		if simDR_EFIS_2_sel_pilot == 2 then simDR_EFIS_2_sel_pilot = 1 else simDR_EFIS_2_sel_pilot = 2 end
	elseif phase == 2 then
		C90DR_avionics_brg_ptr2_sel_switch_pos = 0
	end
end

-- WEATHER RADAR BOOT UP SEQUENCE
function weatheralpha()
	if radaron == 0 and radar_failed == 0 then
		if simDR_weather_alpha < 0.5 then
			simDR_weather_alpha = simDR_weather_alpha + 0.01
		elseif simDR_weather_alpha > 0.5 then
			radaron = 1
		end
	elseif radaron == 1 then
		simDR_weather_alpha	= 0.51 + (0.0012 * simDR_pulse)
		if radar_failed == 1 then
			simDR_weather_alpha = 0
		end
	end
	if simDR_efis1_fail == 6 then
		radar_failed = 1
	end
end

function C90_avionics_EFIS_map_mode_sel_dial_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_map_mode_sel_dial_pos = math.min(4, C90DR_avionics_EFIS_map_mode_sel_dial_pos + 1)
        C90_EFIS_map_mode()
    end
end

function C90_avionics_EFIS_map_mode_sel_dial_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_map_mode_sel_dial_pos = math.max(0, C90DR_avionics_EFIS_map_mode_sel_dial_pos - 1)
        C90_EFIS_map_mode()
    end
end

function C90_EFIS_map_mode()
    if C90DR_avionics_nav_data_sel_dial_pos == 1 then            --Wind
        C90_show_wind()
        if is_timer_scheduled(C90_show_wind) == false then
            run_at_interval(C90_show_wind, 1)
         end	 
    else
        stop_timer(C90_show_wind)
    end
    if C90DR_avionics_EFIS_map_mode_sel_dial_pos < 3 then       --Weather radar
        simDR_EFIS_weather_on = 0
        simDR_weather_alpha = 0
        radaron = 0
        stop_timer(weatheralpha)
    else
        simDR_EFIS_weather_on = 1
        simDR_weather_alpha = 0.81
        radaron = 1
        if is_timer_scheduled(weatheralpha) == false then
            run_at_interval(weatheralpha, 0.15)
        end
    end
    if C90DR_avionics_EFIS_map_mode_sel_dial_pos == 2 then
        simDR_EFIS_is_HSI = 1
        C90DR_avionics_EFIS_pre_loc_dsply = C90DR_avionics_EFIS_pre_loc_active
        C90DR_avionics_EFIS_pre_vor_dsply = C90DR_avionics_EFIS_pre_vor_active
    else
        simDR_EFIS_is_HSI = 0
        C90DR_avionics_EFIS_pre_loc_dsply = 0
        C90DR_avionics_EFIS_pre_vor_dsply = 0
    end
    if C90DR_avionics_EFIS_map_mode_sel_dial_pos == 0 then    -- MAP MODE
        simDR_EFIS_map_mode 		= 2
        simDR_EFIS_tcas_on 			= 0
        simDR_EFIS_airport_on 		= 1
        simDR_EFIS_vor_on 			= 1
        simDR_EFIS_ndb_on 			= 1
    elseif C90DR_avionics_EFIS_map_mode_sel_dial_pos == 1 then  -- ARC MODE
        simDR_EFIS_map_mode 		= 1
        simDR_EFIS_tcas_on 			= 0
        simDR_EFIS_airport_on 		= 0
        simDR_EFIS_vor_on 			= 0
        simDR_EFIS_ndb_on 			= 0
    elseif C90DR_avionics_EFIS_map_mode_sel_dial_pos == 2 then  -- HSI MODE
        simDR_EFIS_map_mode 		= 0
        simDR_EFIS_tcas_on 			= 0
        simDR_EFIS_airport_on 		= 0
        simDR_EFIS_vor_on 			= 0
        simDR_EFIS_ndb_on 			= 0
    elseif C90DR_avionics_EFIS_map_mode_sel_dial_pos == 3 then  -- ARC MODE + WEATHER
        simDR_EFIS_map_mode 		= 1
        simDR_EFIS_tcas_on 			= 1
        simDR_EFIS_airport_on 		= 0
        simDR_EFIS_vor_on 			= 0
        simDR_EFIS_ndb_on 			= 0
    elseif C90DR_avionics_EFIS_map_mode_sel_dial_pos == 4 then  -- MAP MODE + WEATHER
        simDR_EFIS_map_mode 		= 2
        simDR_EFIS_tcas_on 			= 1
        simDR_EFIS_airport_on 		= 1
        simDR_EFIS_vor_on 			= 1
        simDR_EFIS_ndb_on 			= 1
	end
end

function C90_show_wind()
    C90DR_avionics_EFIS_show_wind = C90_ternary(simDR_airspeed > 45 and simDR_wind_speed_kts > 1, 1, 0)
end

function C90_avionics_EFIS_power_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_power_switch_pos = 1 - C90DR_avionics_EFIS_power_switch_pos
        C90_reset_bearing_pointers()
	end
end

function C90_avionics_EFIS_power_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_power_switch_pos = 1
        C90_reset_bearing_pointers()
	end
end

function C90_avionics_EFIS_power_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_power_switch_pos = 0
        C90_reset_bearing_pointers()
	end
end

function C90_reset_bearing_pointers()
    simDR_EFIS_1_sel_pilot = 1
    simDR_EFIS_2_sel_pilot = 1
end

--- EFIS COMPOSITE/REVISIONARY MODE
function composite()
	if C90DR_avionics_EFIS_rev_mode_switch_pos == 1 then
		if simDR_efis1_fail == 6 or simDR_pilot_ahz_fail == 6 or simDR_efis2_fail == 6 or simDR_pilot_dg_fail == 6 then
			if simDR_copilot_dg_fail == 0 and simDR_copilot_ahz_fail == 0 then
			    simDR_efis1_fail = 0
			    simDR_pilot_ahz_fail = 0
			    simDR_efis2_fail = 0
			    simDR_pilot_dg_fail = 0
			elseif simDR_copilot_dg_fail == 0 and simDR_copilot_ahz_fail == 1 then
			    simDR_efis1_fail = 0
			    simDR_pilot_ahz_fail = 0
			elseif simDR_copilot_dg_fail == 1 and simDR_copilot_ahz_fail == 0 then
			    simDR_efis2_fail = 0
			    simDR_pilot_dg_fail = 0
			end
		end
	end
end

function C90_avionics_EFIS_rev_mode_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_rev_mode_switch_pos = 1 - C90DR_avionics_EFIS_rev_mode_switch_pos
		if C90DR_avionics_EFIS_rev_mode_switch_pos == 1 then
			efis1fail = simDR_efis1_fail
			efis2fail = simDR_efis2_fail
			run_at_interval(composite, 1)
		elseif C90DR_avionics_EFIS_rev_mode_switch_pos == 0 then
			stop_timer(composite)
			simDR_efis1_fail = efis1fail
			simDR_efis2_fail = efis2fail
		end
	end
end

function C90_avionics_EFIS_rev_mode_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_rev_mode_switch_pos = math.min(1, C90DR_avionics_EFIS_rev_mode_switch_pos + 1)
	end
end

function C90_avionics_EFIS_rev_mode_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_rev_mode_switch_pos = math.max(0, C90DR_avionics_EFIS_rev_mode_switch_pos - 1)
	end
end

-- EFIS TEST & AVIONICS START-UP/BOOT SEQUENCE
function C90_avionics_EFIS_test_switch_CMDhandler(phase, duration)
    C90DR_avionics_EFIS_test_switch_pos = C90_ternary(phase == 2, 0, 1)
end

function C90_avionics_EFIS_dh_test_switch_CMDhandler(phase, duration)
    C90DR_avionics_EFIS_dh_test_switch_pos = C90_ternary(phase == 2, 0, 1)
	if phase == 0 then
		C90DR_avionics_EFIS_dh = 50
	elseif phase == 2 then
		C90DR_avionics_EFIS_dh = simDR_radio_alt_bug_ft_pilot	--IBAV8N, consolid. to one dref
	end
end

function C90_avionics_EFIS_timer_dial_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_timer_dial_pos = C90DR_avionics_EFIS_timer_dial_pos + 1
		if C90DR_avionics_EFIS_et_timer_status == STOP
			or C90DR_avionics_EFIS_et_timer_status == COUNTDOWN_SET
		then
			C90DR_avionics_EFIS_et_timer_status = COUNTDOWN_SET
			C90_countdown_timer_total_seconds_set = math.min(35999, C90_countdown_timer_total_seconds_set + 1)
			C90DR_avionics_EFIS_et_timer_hours = math.floor(C90_countdown_timer_total_seconds_set / 3600)
			C90DR_avionics_EFIS_et_timer_minutes = math.floor(C90_countdown_timer_total_seconds_set/60 - (C90DR_avionics_EFIS_et_timer_hours*60))
			C90DR_avionics_EFIS_et_timer_seconds = math.floor(C90_countdown_timer_total_seconds_set - C90DR_avionics_EFIS_et_timer_hours*3600 - C90DR_avionics_EFIS_et_timer_minutes*60)
		end
	end
end

function C90_avionics_EFIS_timer_dial_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_timer_dial_pos = C90DR_avionics_EFIS_timer_dial_pos - 1
		if C90DR_avionics_EFIS_et_timer_status == STOP
			or C90DR_avionics_EFIS_et_timer_status == COUNTDOWN_SET
		then
			C90DR_avionics_EFIS_et_timer_status = COUNTDOWN_SET
			C90_countdown_timer_total_seconds_set = math.max(0, C90_countdown_timer_total_seconds_set - 1)
			C90DR_avionics_EFIS_et_timer_hours = math.floor(C90_countdown_timer_total_seconds_set / 3600)
			C90DR_avionics_EFIS_et_timer_minutes = math.floor(C90_countdown_timer_total_seconds_set/60 - (C90DR_avionics_EFIS_et_timer_hours*60))
			C90DR_avionics_EFIS_et_timer_seconds = math.floor(C90_countdown_timer_total_seconds_set - C90DR_avionics_EFIS_et_timer_hours*3600 - C90DR_avionics_EFIS_et_timer_minutes*60)
		end
	end
end

function C90_EFIS_et_timer()
	if simDR_time_paused == 0 then
		if C90DR_avionics_EFIS_et_timer_status == COUNTUP then
			C90_EFIS_timer_total_seconds = C90_EFIS_timer_total_seconds + 1
			C90DR_avionics_EFIS_et_timer_hours = math.floor(C90_EFIS_timer_total_seconds / 3600)
			C90DR_avionics_EFIS_et_timer_minutes = math.floor(C90_EFIS_timer_total_seconds/60 - (C90DR_avionics_EFIS_et_timer_hours*60))
			C90DR_avionics_EFIS_et_timer_seconds = math.floor(C90_EFIS_timer_total_seconds - C90DR_avionics_EFIS_et_timer_hours*3600 - C90DR_avionics_EFIS_et_timer_minutes*60)
		elseif C90DR_avionics_EFIS_et_timer_status == COUNTDOWN then
			C90_EFIS_timer_total_seconds = C90_EFIS_timer_total_seconds - 1
			C90DR_avionics_EFIS_et_timer_hours = math.floor(C90_EFIS_timer_total_seconds / 3600)
			C90DR_avionics_EFIS_et_timer_minutes = math.floor(C90_EFIS_timer_total_seconds/60 - (C90DR_avionics_EFIS_et_timer_hours*60))
			C90DR_avionics_EFIS_et_timer_seconds = math.floor(C90_EFIS_timer_total_seconds - C90DR_avionics_EFIS_et_timer_hours*3600 - C90DR_avionics_EFIS_et_timer_minutes*60)
			if C90_EFIS_timer_total_seconds == 0 then
				C90DR_avionics_EFIS_et_timer_status = STOP
			end
		end
	end
end

function C90_avionics_EFIS_timer_ss_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_timer_ss_switch_pos = 1
		C90DR_avionics_EFIS_aux_timer_ss_switch_pos = 1
		if C90DR_avionics_EFIS_et_timer_status == STOP then
			C90DR_avionics_EFIS_et_timer_status = COUNTUP
			run_at_interval(C90_EFIS_et_timer, 1)
		elseif C90DR_avionics_EFIS_et_timer_status == COUNTDOWN_SET then
			C90DR_avionics_EFIS_et_timer_status = COUNTDOWN
			C90_EFIS_timer_total_seconds = (C90DR_avionics_EFIS_et_timer_hours*3600) + (C90DR_avionics_EFIS_et_timer_minutes*60) + C90DR_avionics_EFIS_et_timer_seconds
			run_at_interval(C90_EFIS_et_timer, 1)
		elseif C90DR_avionics_EFIS_et_timer_status == COUNTUP then
			C90DR_avionics_EFIS_et_timer_status = COUNTUP_PAUSE
			stop_timer(C90_EFIS_et_timer)
		elseif C90DR_avionics_EFIS_et_timer_status == COUNTDOWN then
			C90DR_avionics_EFIS_et_timer_status = COUNTDOWN_PAUSE
			stop_timer(C90_EFIS_et_timer)
		elseif C90DR_avionics_EFIS_et_timer_status == COUNTUP_PAUSE
			or C90DR_avionics_EFIS_et_timer_status == COUNTDOWN_PAUSE
		then
			C90DR_avionics_EFIS_et_timer_status = STOP
			C90DR_avionics_EFIS_et_timer_seconds = 0
			C90DR_avionics_EFIS_et_timer_minutes = 0
			C90DR_avionics_EFIS_et_timer_hours = 0
			C90_countdown_timer_total_seconds_set = 0
			C90_EFIS_timer_total_seconds = 0
		end
	elseif phase == 2 then
		C90DR_avionics_EFIS_timer_ss_switch_pos = 0
		C90DR_avionics_EFIS_aux_timer_ss_switch_pos = 0
	end
end

function C90_avionics_EFIS_aux_pwr_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_aux_pwr_on_switch_pos = math.min(1, C90DR_avionics_EFIS_aux_pwr_on_switch_pos + 1)
	end
end

function C90_avionics_EFIS_aux_pwr_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_aux_pwr_on_switch_pos = math.max(-1, C90DR_avionics_EFIS_aux_pwr_on_switch_pos - 1)
	elseif phase == 2 then
		C90DR_avionics_EFIS_aux_pwr_on_switch_pos = 0
	end
end

function C90_avionics_EFIS_aux_horn_silence_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_EFIS_aux_horn_silence_switch_pos = 1
        	C90.electrical.efis_aux_silence = C90.electrical.efis_aux_trigger
	elseif phase ==2 then
		C90DR_avionics_EFIS_aux_horn_silence_switch_pos = 0
	end
end

function C90_avionics_fd_switch_CMDhandler(phase, duration)                         --IBAV8N, Apr2-22, switch had no means of disabling FD
	if phase == 0 then
		C90DR_avionics_EFIS_fd_switch_pos = 1 - C90DR_avionics_EFIS_fd_switch_pos
	end
end

function C90_avionics_fd_switch_up_CMDhandler(phase, duration)                      --IBAV8N, Apr2-22, cleaned up
	if phase == 0 then
		C90DR_avionics_EFIS_fd_switch_pos = math.min(1, C90DR_avionics_EFIS_fd_switch_pos + 1)
	end
end

function C90_avionics_fd_switch_dn_CMDhandler(phase, duration)                      --IBAV8N, Apr2-22, switch had no means of disabling FD
	if phase == 0 then
		C90DR_avionics_EFIS_fd_switch_pos = math.max(0, C90DR_avionics_EFIS_fd_switch_pos - 1)
	end
end

----- FLIGHT INSTRUMENTS ----------------------------------------------------------------
function C90_fltInst_ccu65_slave_mode_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fltInst_ccu65_mode_switch_pos = 1 - C90DR_fltInst_ccu65_mode_switch_pos
		simDR_gyro_free_slaved[2] = 1 - C90DR_fltInst_ccu65_mode_switch_pos
	end
end

function C90_annunciator_clear_masters_CMDhandler(phase, duration)
	if phase == 0 then
        simCMD_clear_master_warning:once()
        simCMD_clear_master_caution:once()
    end
end
----- AUTOPILOT -------------------------------------------------------------------------

----- FCP-65 AUTOPILOT TEST BUTTON ---------------------------------------------------------------

--[[

	GROUND TEST MODE =
		0 =	GROUND TEST OFF
		1 = GROUND TEST ACTIVATED (BY SHORT BUTTON PRESS)
		2 = LAMP TEST MODE ENABLED
		3 = LAMP TEST MODE DISABLED
		4 = GROUND TEST ENABLED
		5 = GROUND TEST & SYSTEM DIAGNOSTIC TEST ENABLED
		6 = GROUND TEST COMPLETE

	AIRBORNE TEST MODE =
		0 =	AIRBORNE TEST OFF
		1 = AIRBORNE TEST ACTIVATED (HOLD TEST BUTTON DOWN)
		2 = LAMP FLASH ENABLED FOR 2.5 SEC
		3 = LAMP TEST MODE DISABLED
		4 = SYSTEM DIAGNOSTIC MODE ENABLED
        5 = RETURN TO MODE 2 IF BUTTON STILL HELD DOWN
--]]

function C90_autopilot_test_switch_CMDhandler(phase, duration)
    local ground_start = C90_ternary(C90.autopilot.ground_test_mode == 0        -- GROUND TEST MODE = "OFF"
        and simDR_gear_on_ground[2] == 1 				                        -- RIGHT MAIN SQUAT SWITCH CLOSED
        and simDR_airspeed < 60, 1, 0)	                                        -- AIRSPEED MUST BE LESS THAN 60 KNOTS
	if phase == 0 then                                                          -- INITIAL BUTTON PRESS
		C90DR_autopilot_annun_test_switch_pos = 1                               -- SET THE BUTTON ANIMATION
	elseif phase == 1 and C90.electrical.ap_power > 0 then                                                      -- BUTTON IS BEING HELD DOWN
        C90DR_lighting_annun_ap_test = 1
		if duration > 2 then                                                    -- USER HAS HELD THE BUTTON DOWN FOR LONGER THAN 2 SECONDS
			if (ground_start == 0 and C90.autopilot.airborne_test_mode == 0)    -- IN THE AIR
                or C90.autopilot.ground_test_mode == 6 then                     -- GROUND TEST MODE COMPLETED
                if C90.autopilot.ground_test_mode == 6 then
			        C90_exitGroundTestMode()					                -- EXIT GROUND TEST MODE
                end
				C90.autopilot.airborne_test_mode = 1			                -- ACTIVATE THE AIRBORNE TEST
			elseif C90.autopilot.airborne_test_mode == 1 then                   -- AIRBORNE TEST MODE = "LAMP TEST ENABLED"
	            C90.autopilot.sys_diag_test	= 1
                C90.autopilot.lamp_test = 1
                C90.autopilot.airborne_test_mode = 2
			elseif C90.autopilot.airborne_test_mode == 2 then                   -- AIRBORNE TEST MODE = "LAMP TEST DISABLED"
					if is_timer_scheduled(C90_airborneLampTestTimeout) == false then
						run_after_time(C90_airborneLampTestTimeout, 1)
					end
			elseif C90.autopilot.airborne_test_mode == 3 then       -- AIRBORNE TEST MODE = "SYSTEM DIAGNOSTIC TEST ENABLED"
				C90.autopilot.sys_diag_test = 3					    -- TURN ON THE SYSTEM DIAGNOSTIC TEST
			    if not is_timer_scheduled(C90_airborneDiagnosticTestTimeout) then
			        run_after_time(C90_airborneDiagnosticTestTimeout, 0.5 + (2.5 * simDR_autopilot_ready))
			    end
			elseif C90.autopilot.airborne_test_mode == 4 then       -- AIRBORNE TEST MODE = "AIRBORNE TEST COMPLETE"
                --Will enable this when dref:simDR_autopilot_ready is fixed
				--if simDR_autopilot_ready == 1 then			    -- AUTOPILOT NOT READY, CONTINUE TO DISPLAY FAULT INDICATORS
                --    C90.autopilot.sys_diag_test = 1
				--else		                                        -- AUTOPILOT READY
				--	C90.autopilot.sys_diag_test = 0				    -- INIT
                    C90.autopilot.airborne_test_mode = 1
				--end
			end
		end
	elseif phase == 2 then                                          -- BUTTON HAS BEEN RELEASED	
		C90DR_autopilot_annun_test_switch_pos = 0                   -- SET THE BUTTON ANIMATION
        if C90.electrical.ap_power > 0 then
            C90DR_lighting_annun_ap_test = 0
		    if duration > 2 then                                    -- USER PUSHED AND HELD BUTTON DOWN (AIRBORNE TEST)
			    if C90.autopilot.airborne_test_mode > 0 then 	    -- AIRBORNE TEST MODE IS ACTIVE
				    C90_exitAirborneTestMode()                      -- EXIT THE AIRBORNE TEST MODE
			    end
            elseif ground_start == 1 then
                C90.autopilot.ground_test_mode = 1				    -- ACTIVATE THE GROUND TEST
		    elseif C90.autopilot.ground_test_mode > 0 then		    -- GROUND TEST MODE IS "ACTIVE"
                C90_exitGroundTestMode()                            -- EXIT THE GROUND TEST MODE
		    end
        end
	end
end

----- GROUND TEST ------------------------------------------------------------------------------------
function C90_autopilot_groundSelfTest()         --Runs constantly
	if C90.autopilot.ground_test_mode == 1 then
		C90_enableGroundLampTest()
	end
end

function C90_enableGroundLampTest()
	C90.autopilot.sys_diag_test	= 1
	C90.autopilot.lamp_test = 1						                -- ENABLE THE ANNUNCIATOR LAMP TEST
	run_after_time(C90_disableGroundLampTest, 3)			        -- DISABLE THE ANNUNCIATOR LAMP TEST AFTER n SECONDS
	C90.autopilot.ground_test_mode = 2							    -- SET THE GROUND TEST MODE TO "LAMP TEST MODE ENABLED"
end

function C90_disableGroundLampTest()
	C90.autopilot.lamp_test	= 0							            -- DISABLE THE ANNUNCIATOR LAMP TEST
	C90.autopilot.ground_test_mode = 3							    -- SET THE GROUND TEST MODE TO "LAMP TEST MODE DISABLED"
	run_after_time(C90_enableGroundTest, 0.25)
end

function C90_enableGroundTest()
	C90.autopilot.ground_test = 1							        -- SET THE GROUND TEST TO "ENABLED"
	C90.autopilot.ground_test_mode = 4							    -- SET THE GROUND TEST MODE TO "GROUND TEST ENABLED"
    run_after_time(C90_enableGroundSystemDiagnosticTest, 0.25)
end

function C90_enableGroundSystemDiagnosticTest()
	C90.autopilot.sys_diag_test	= 2							        -- SET THE SYSTEM DIAGNOSTIC TEST TO "ENABLED"
	C90.autopilot.ground_test_mode = 5							    -- SET THE GROUND TEST MODE TO "GROUND TEST & SYSTEM DIAGNOSTIC TEST ENABLED"
    run_after_time(C90_groundTestComplete, 0.25)
end

function C90_groundTestComplete()
	C90.autopilot.ground_test_mode = 6							    -- SET THE GROUND TEST MODE TO "GROUND TEST COMPLETE"
end

function C90_exitGroundTestMode()
	C90.autopilot.ground_test_mode = 0						        -- EXIT THE GROUND TEST, SET MODE = "OFF"
	C90.autopilot.lamp_test	= 0						                -- CANCEL THE LAMP TEST
	C90.autopilot.ground_test = 0						            -- CANCEL THE GROUND TEST
	C90.autopilot.sys_diag_test	= 0						            -- CANCEL THE SYSTEM DIAGNOSTICS TEST
	stop_timer(C90_disableGroundLampTest)
end

----- AIRBORNE TEST ----------------------------------------------------------------------------------
function C90_airborneLampTestTimeout()
    C90.autopilot.lamp_test = 0
	C90.autopilot.airborne_test_mode = 3						    -- ADVANCE THE MODE
end

function C90_airborneDiagnosticTestTimeout()
	C90.autopilot.sys_diag_test	= 0
	C90.autopilot.airborne_test_mode = 4						    -- ADVANCE THE MODE
end

function C90_exitAirborneTestMode()
	stop_timer(C90_airborneLampTestTimeout)
	stop_timer(C90_airborneDiagnosticTestTimeout)
	C90.autopilot.airborne_test_mode = 0						    -- EXIT THE AIRBORNE TEST, SET MODE = "OFF"
	C90.autopilot.lamp_test	= 0						                -- CANCEL THE LAMP TEST
	C90.autopilot.ground_test = 0						            -- CANCEL THE GROUND TEST
	C90.autopilot.sys_diag_test	= 0						            -- CANCEL THE SYSTEM DIAGNOSTICS TEST
end

----- CABIN PRESSURIZATION  --------------------------------------------------------------------
function C90_pressure_control_switch_up_CMDhandler(phase, duration)         --IBAV8N, Jun22-21, works in conjunction with new C90_cabin_pressure().
	if phase == 0 then
		C90DR_pressure_control_switch_pos = 1
		simCMD_dump_cabin_press_on:once()
	end
end

function C90_pressure_control_switch_dn_CMDhandler(phase, duration)
	if phase == 1 then
        if C90DR_pressure_control_switch_pos == 1 then
		    C90DR_pressure_control_switch_pos = 0
		    if simDR_door_open_ratio[0] == 0 then
		        simCMD_dump_cabin_press_off:once()
            end
        elseif C90DR_pressure_control_switch_pos == 0 then
		    C90DR_pressure_control_switch_pos = - 1
		    simCMD_pressurization_test:start()
        end
	elseif phase == 2 and C90DR_pressure_control_switch_pos == - 1 then
	    C90DR_pressure_control_switch_pos = 0
	    simCMD_pressurization_test:stop()
	end
end

----- FLIGHT CONTROLS ------------------------------------------------------------------
-- RUDDER BOOST
function C90_rudderboost_check()
    if C90DR_fltctrl_rudder_boost_switch_pos == 1 then
        if is_timer_scheduled(rudderboost) == false then
            run_at_interval(rudderboost, 0.2)
        end
    elseif C90DR_fltctrl_rudder_boost_switch_pos == 0 then
        stop_timer(rudderboost)
        simDR_artstab_heading = 0
    end
end

function rudderboost()                                                      --IBAV8N, Dec22-21, reduced bleed ratio delta for ground check
    if simDR_autopilot_servos_on == 0 and C90DR_pneumatic_bleed_air_switch_pos_L > 0 and C90DR_pneumatic_bleed_air_switch_pos_R > 0 then
        local bbb = math.abs(simDR_torque_L - simDR_torque_R)
        if bbb < 814 then
            simDR_artstab_heading = 0
        elseif simDR_torque_L < simDR_torque_R then
            simDR_artstab_heading = -0.003152 * simDR_airspeed + 0.7
        else
            simDR_artstab_heading = (-0.003152 * simDR_airspeed + 0.7) * -1
        end
    else
        simDR_artstab_heading = 0
    end
end

function C90_fltctrl_rudder_boost_switch_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fltctrl_rudder_boost_switch_pos = 1 - C90DR_fltctrl_rudder_boost_switch_pos
        C90_rudderboost_check()
	end
end

function C90_fltctrl_rudder_boost_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fltctrl_rudder_boost_switch_pos = 1
        C90_rudderboost_check()
	end
end

function C90_fltctrl_rudder_boost_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fltctrl_rudder_boost_switch_pos = 0
        C90_rudderboost_check()
	end
end

-- ELECTRIC TRIM
function C90_fltctrl_elev_trim_control_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fltctrl_elev_trim_control_switch_pos = 1 - C90DR_fltctrl_elev_trim_control_switch_pos
	end
end

function C90_fltctrl_elev_trim_control_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fltctrl_elev_trim_control_switch_pos = 1
	end
end

function C90_fltctrl_elev_trim_control_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_fltctrl_elev_trim_control_switch_pos = 0
	end
end


----- LIGHTING --------------------------------------------------------------------------
function C90_lighting_cabin_brt_dim_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_lighting_cabin_brt_dim_switch_pos = math.min(1, C90DR_lighting_cabin_brt_dim_switch_pos + 1)
		if C90DR_lighting_cabin_brt_dim_switch_pos == 0 then    -- DIM
			simDR_generic_lights_switch[5] = 0.5
		elseif C90DR_lighting_cabin_brt_dim_switch_pos == 1 then -- BRIGHT
			simDR_generic_lights_switch[5] = 1
		end
	end
end

function C90_lighting_cabin_brt_dim_switch_dn_CMDhandler(phase, duration) --IBAV8N, Dec26-21 fixed logic
	if phase == 0 then
		C90DR_lighting_cabin_brt_dim_switch_pos = math.max(-1, C90DR_lighting_cabin_brt_dim_switch_pos - 1)
		if C90DR_lighting_cabin_brt_dim_switch_pos == 0 then  -- DIM
			simDR_generic_lights_switch[5] = 0.5
		elseif C90DR_lighting_cabin_brt_dim_switch_pos == -1 then -- OFF
			simDR_generic_lights_switch[5] = 0
		end
	end
end

function C90_lighting_no_smoke_fsb_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_lighting_no_smoke_fsb_switch_pos = math.min(1, C90DR_lighting_no_smoke_fsb_switch_pos + 1)
		if C90DR_lighting_no_smoke_fsb_switch_pos == -1 then        -- FASTEN SEAT BELT (ONLY)
			if simDR_no_smoking_switch > 0 then simCMD_no_smoking_toggle:once() end
			if simDR_seat_belts_switch == 0 then simCMD_seatbelt_sign_toggle:once()	end
		elseif C90DR_lighting_no_smoke_fsb_switch_pos == 1 then     -- NO SMOKING & FASTEN SEAT BELT
			if simDR_no_smoking_switch == 0 then simCMD_no_smoking_toggle:once() end
			if simDR_seat_belts_switch == 0 then simCMD_seatbelt_sign_toggle:once() end
		end
	end
end

function C90_lighting_no_smoke_fsb_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_lighting_no_smoke_fsb_switch_pos = math.max(-1, C90DR_lighting_no_smoke_fsb_switch_pos - 1)
		if C90DR_lighting_no_smoke_fsb_switch_pos == 0 then         -- OFF
			if simDR_no_smoking_switch > 0 then simCMD_no_smoking_toggle:once() end
			if simDR_seat_belts_switch > 0 then simCMD_seatbelt_sign_toggle:once() end
		elseif C90DR_lighting_no_smoke_fsb_switch_pos == -1 then    -- FASTEN SEAT BELT (ONLY)
			if simDR_no_smoking_switch > 0 then simCMD_no_smoking_toggle:once() end
			if simDR_seat_belts_switch == 0 then simCMD_seatbelt_sign_toggle:once()	end
		end
	end
end

function C90_lighting_wing_ice_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[1] = 1
	end
end

function C90_lighting_wing_ice_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[1] = 0
	end
end

function C90_lighting_recog_switch_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[2] = 1 - simDR_generic_lights_switch[2]
    end
end

function C90_lighting_recog_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[2] = 1
	end
end

function C90_lighting_recog_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[2] = 0
	end
end

function C90_lighting_tail_flood_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[3] = 1
	end
end

function C90_lighting_tail_flood_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[3] = math.max(0, simDR_generic_lights_switch[3] - 1)
	end
end

function C90_lighting_bar_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[4] = 1
	end
end

function C90_lighting_bar_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_generic_lights_switch[4] = 0
	end
end

function C90_avitab_enabled_toggle_CMDhandler(phase, duration)
    if phase == 0  then
        simDR_avitab_enabled = 1 - simDR_avitab_enabled
    end
end

function C90_electrical_annun_test_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_electrical_annun_test_on = 1
        C90DR_electrical_switch_pos_annun_test_on = 1
    elseif phase == 2 then
        C90DR_electrical_annun_test_on = 0
        C90DR_electrical_switch_pos_annun_test_on = 0
        C90DR_lighting_annun_master_warning = 0
        C90DR_lighting_annun_master_caution = 0
    end
end

function C90_avionics_crossfill_on_CMDhandler(phase, duration)
    if phase == 0 then C90DR_crossfill = 1
    end
end

function C90_avionics_crossfill_off_CMDhandler(phase, duration)
    if phase == 0 then C90DR_crossfill = 0
    end
end

-- GNS AUTOMATION COMMANDS
function C90_avionics_g430n1_com_vol_up_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n1_dial_com_vol = math.min(1, C90DR_avionics_g430n1_dial_com_vol + 0.1)
    elseif phase == 2 then
        if C90DR_avionics_g430n1_dial_com_vol > 0 then
            run_after_time(gps530, 1)
        end
    end
end

function C90_avionics_g430n1_com_vol_down_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n1_dial_com_vol = math.max(0, C90DR_avionics_g430n1_dial_com_vol - 0.1)
    elseif phase == 2 then
        if C90DR_avionics_g430n1_dial_com_vol == 0 then
            simDR_gps530_power = 0
        end
    end
end

function C90_avionics_g430n1_vloc_vol_up_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n1_dial_vloc_vol = math.min(1, C90DR_avionics_g430n1_dial_vloc_vol + 0.1)
    end
end

function C90_avionics_g430n1_vloc_vol_down_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n1_dial_vloc_vol = math.max(0, C90DR_avionics_g430n1_dial_vloc_vol - 0.1)
    end
end

function C90_avionics_g430n2_com_vol_up_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n2_dial_com_vol = math.min(1, C90DR_avionics_g430n2_dial_com_vol + 0.1)
    elseif phase == 2 then
        if C90DR_avionics_g430n2_dial_com_vol > 0 then
            run_after_time(gps430, 1.6)
        end
    end
end

function C90_avionics_g430n2_com_vol_down_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n2_dial_com_vol = math.max(0, C90DR_avionics_g430n2_dial_com_vol - 0.1)
    elseif phase == 2 then
        if C90DR_avionics_g430n2_dial_com_vol == 0 then
            simDR_gps430_power = 0
        end
    end
end

function C90_avionics_g430n2_vloc_vol_up_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n2_dial_vloc_vol = math.min(1, C90DR_avionics_g430n2_dial_vloc_vol + 0.1)
    end
end

function C90_avionics_g430n2_vloc_vol_down_CMDhandler(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n2_dial_vloc_vol = math.max(0, C90DR_avionics_g430n2_dial_vloc_vol - 0.1)
    end
end

--Placeholders until functions are written --IBAV8N
function C90_avionics_ctl22_com1_tst_switch_CMDhandler(phase, duration) end    --IBAV8N, COM1 TST Jan3-21
function C90_avionics_ctl22_com2_tst_switch_CMDhandler(phase, duration) end    --IBAV8N, COM2 TST Jan3-21
function C90_avionics_ctl32_nav1_tst_switch_CMDhandler(phase, duration) end    --IBAV8N, NAV1 TST Jan3-21
function C90_avionics_ctl32_nav2_tst_switch_CMDhandler(phase, duration) end    --IBAV8N, NAV2 TST Jan3-21
function C90_avionics_ctl62_adf_tst_switch_CMDhandler(phase, duration) end     --IBAV8N, ADF TST Jan3-21
function C90_avionics_ctl92_xpdr_tst_switch_CMDhandler(phase, duration) end    --IBAV8N, XPDR TST Jan3-21

-- COM1 ACT/STO/XFR/MEM FUNCTION							--IBAV8N
function C90_avionics_ctl22_com1_act_switch_CMDhandler(phase, duration)
    if phase == 0 and math.max(simDR_battery_2, simDR_avionics_power_on * simDR_com1_power) > 0 then
        if C90DR_avionics_ctl22_com1_act == 0 then
            C90DR_avionics_ctl22_com1_sto_index = 0                                     --turn off mem mode if on
            C90.avionics.ctl22_com1_sto_stack[0] = simDR_com1_stby_frequency
            simDR_com1_stby_frequency = simDR_com1_frequency                            --standby freq matches active
            C90DR_avionics_ctl22_com1_act = 1                                           --ACT function ON
            run_at_interval(com1_act, 0.02)                                             --run routine to match active to standby
        else
		    stop_timer(com1_act)                                                        --end routine
            simDR_com1_stby_frequency = C90.avionics.ctl22_com1_sto_stack[0]
            C90DR_avionics_ctl22_com1_act = 0                                           --ACT function OFF
        end
    end
end

function com1_act()
   simDR_com1_frequency = simDR_com1_stby_frequency                                     --make top display show what bottom display normally would
end

function C90_avionics_ctl22_com1_sto_switch_CMDhandler(phase, duration)
    if phase == 0 and math.max(simDR_battery_2, simDR_avionics_power_on * simDR_com1_power) > 0 then
		if C90DR_avionics_ctl22_com1_sto_index > 0 then
        	if C90.avionics.ctl22_com1_sto_count == 0 then
            	C90.avionics.ctl22_com1_sto_count = 1
        	else
            	C90.avionics.ctl22_com1_sto_stack[C90DR_avionics_ctl22_com1_sto_index] = simDR_com1_stby_frequency      --current slot = stby freq
            	C90.avionics.ctl22_com1_mem = 1
            	run_after_time(com1_mem,1)
            	C90.avionics.ctl22_com1_sto_count = 0
			end
        end
    end
end

function com1_mem()
    C90.avionics.ctl22_com1_mem = 0                                                                             --turn off the sto light
	if C90DR_avionics_ctl22_com1_sto_index < 6 then		                                                        --if not at the end of the stack
		C90DR_avionics_ctl22_com1_sto_index = C90DR_avionics_ctl22_com1_sto_index + 1                           --advance to the next sto index
	else
	    C90DR_avionics_ctl22_com1_sto_index = 0                                                                 --if at sto index 6, return to zero
        simDR_com1_stby_frequency = C90.avionics.ctl22_com1_sto_stack[0]                                        --return the stby freq from the variable
	end
    if C90.avionics.ctl22_com1_sto_stack[C90DR_avionics_ctl22_com1_sto_index] == 0 then                         --if sto index is zero
        simDR_com1_stby_frequency = C90.avionics.ctl22_com1_sto_stack[0]                                        --show the stby freq
    else
        simDR_com1_stby_frequency = C90.avionics.ctl22_com1_sto_stack[C90DR_avionics_ctl22_com1_sto_index]      --else show the existing sto index freq
    end
	stop_timer(com1_mem)
end

function C90_avionics_ctl22_com1_xfr_mem_dn_CMDhandler(phase, duration)
	if phase == 0 then
        C90DR_avionics_ctl22_com1_xfr_mem_switch_pos = -1                                                       --animate switch down
        if C90DR_avionics_ctl22_com1_act == 0 then                                                              --not in ACT mode
            if math.max(simDR_battery_2, simDR_avionics_power_on * simDR_com1_power) > 0 then
                C90.avionics.ctl22_com1_sto_count = 0
                if C90DR_avionics_ctl22_com1_sto_index == 0 then                                                --if @ MEM pos 0, or standby
                    C90.avionics.ctl22_com1_sto_stack[0] = simDR_com1_stby_frequency                            --save stby freq as index 0
                end
                run_after_time(com1_mem,0.02)
            end
        end
	elseif phase == 2 then
		C90DR_avionics_ctl22_com1_xfr_mem_switch_pos = 0                                                        --animate switch up
    end
end

function C90_avionics_ctl22_com1_xfr_mem_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl22_com1_xfr_mem_switch_pos = 1
        if math.max(simDR_battery_2, simDR_avionics_power_on * simDR_com1_power) > 0 then
            if C90DR_avionics_ctl22_com1_act == 0 then                                                          --not in ACT mode
                C90.avionics.ctl22_com1_sto_count = 0
                if C90DR_avionics_ctl22_com1_sto_index == 0 then                --if user is not using the mem function
                    simCMD_com1_freq_flip:once()                                --flip the stby like standard x-plane
                    C90.avionics.ctl22_com1_sto_stack[0] = simDR_com1_stby_frequency
                elseif C90DR_avionics_ctl22_com1_sto_index > 0 then
                    if C90.avionics.ctl22_com1_sto_stack[C90DR_avionics_ctl22_com1_sto_index] == 0 then
                        simDR_com1_frequency = simDR_com1_stby_frequency
                    else
                        simDR_com1_frequency = C90.avionics.ctl22_com1_sto_stack[C90DR_avionics_ctl22_com1_sto_index]
                    end
                end
            end
		end
	elseif phase == 2 then
		C90DR_avionics_ctl22_com1_xfr_mem_switch_pos = 0
        if math.max(simDR_battery_2, simDR_avionics_power_on * simDR_com1_power) > 0 then
            if C90DR_avionics_ctl22_com1_sto_index > 0 then
	            run_after_time(com1_xfr_reset,0.02)
            end
        end
	end
end

function com1_xfr_reset()
    if C90DR_avionics_ctl22_com1_sto_index > 0 then
        C90DR_avionics_ctl22_com1_sto_index = 0
        simDR_com1_stby_frequency = C90.avionics.ctl22_com1_sto_stack[0]
    end
    stop_timer(com1_xfr_reset)
end

-- COM2 ACT/STO/XFR/MEM FUNCTION							--IBAV8N
function C90_avionics_ctl22_com2_act_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_com2_power) > 0 then
        if C90DR_avionics_ctl22_com2_act == 0 then
            C90DR_avionics_ctl22_com2_sto_index = 0
            C90.avionics.ctl22_com2_sto_stack[0] = simDR_com2_stby_frequency
            simDR_com2_stby_frequency = simDR_com2_frequency
            C90DR_avionics_ctl22_com2_act = 1
            run_at_interval(com2_act, 0.02)
        else
		    stop_timer(com2_act)
            simDR_com2_stby_frequency = C90.avionics.ctl22_com2_sto_stack[0]
            C90DR_avionics_ctl22_com2_act = 0
        end
    end
end

function com2_act()
   simDR_com2_frequency = simDR_com2_stby_frequency
end

function C90_avionics_ctl22_com2_sto_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_com2_power) > 0 then
		if C90DR_avionics_ctl22_com2_sto_index > 0 then
        	if C90.avionics.ctl22_com2_sto_count == 0 then
            	C90.avionics.ctl22_com2_sto_count = 1
        	else
            	C90.avionics.ctl22_com2_sto_stack[C90DR_avionics_ctl22_com2_sto_index] = simDR_com2_stby_frequency      --current slot = stby freq
            	C90.avionics.ctl22_com2_mem = 1
            	run_after_time(com2_mem,1)
            	C90.avionics.ctl22_com2_sto_count = 0
			end
        end
    end
end

function com2_mem()
    C90.avionics.ctl22_com2_mem = 0                                                                                     --turn off the sto light
	if C90DR_avionics_ctl22_com2_sto_index < 6 then		                                                                --if not at the end of the stack
		C90DR_avionics_ctl22_com2_sto_index = C90DR_avionics_ctl22_com2_sto_index + 1                                   --advance to the next sto index
	else
	    C90DR_avionics_ctl22_com2_sto_index = 0                                                                         --if at sto index 6, return to zero
        simDR_com2_stby_frequency = C90.avionics.ctl22_com2_sto_stack[0]                                                --return the stby freq from the variable
	end
    if C90.avionics.ctl22_com2_sto_stack[C90DR_avionics_ctl22_com2_sto_index] == 0 then                                 --if sto index is zero
        simDR_com2_stby_frequency = C90.avionics.ctl22_com2_sto_stack[0]                                                --show the stby freq
    else
        simDR_com2_stby_frequency = C90.avionics.ctl22_com2_sto_stack[C90DR_avionics_ctl22_com2_sto_index]              --else show the existing sto index freq
    end
	stop_timer(com2_mem)
end

function C90_avionics_ctl22_com2_xfr_mem_dn_CMDhandler(phase, duration)
	if phase == 0 then
        C90DR_avionics_ctl22_com2_xfr_mem_switch_pos = -1                                                               --animate switch down
        if (simDR_avionics_power_on * simDR_com2_power) > 0 then
            if C90DR_avionics_ctl22_com2_act == 0 then                                                                  --not in ACT mode
                C90.avionics.ctl22_com2_sto_count = 0
                if C90DR_avionics_ctl22_com2_sto_index == 0 then                                                        --if @ MEM pos 0, or standby
                    C90.avionics.ctl22_com2_sto_stack[0] = simDR_com2_stby_frequency                                    --save stby freq as index 0
                end
                run_after_time(com2_mem,0.02)
            end
        end
	elseif phase == 2 then
		C90DR_avionics_ctl22_com2_xfr_mem_switch_pos = 0                                                                --animate switch up
    end
end

function C90_avionics_ctl22_com2_xfr_mem_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl22_com2_xfr_mem_switch_pos = 1
        if (simDR_avionics_power_on * simDR_com2_power) > 0 then
            if C90DR_avionics_ctl22_com2_act == 0 then                                                                  --not in ACT mode
                C90.avionics.ctl22_com2_sto_count = 0
                if C90DR_avionics_ctl22_com2_sto_index == 0 then                --if user is not using the mem function
                    simCMD_com2_freq_flip:once()                                --flip the stby like standard x-plane
                    C90.avionics.ctl22_com2_sto_stack[0] = simDR_com2_stby_frequency
                elseif C90DR_avionics_ctl22_com2_sto_index > 0 then
                    if C90.avionics.ctl22_com2_sto_stack[C90DR_avionics_ctl22_com2_sto_index] == 0 then
                        simDR_com2_frequency = simDR_com2_stby_frequency
                    else
                        simDR_com2_frequency = C90.avionics.ctl22_com2_sto_stack[C90DR_avionics_ctl22_com2_sto_index]
                    end
                end
            end
		end
	elseif phase == 2 then
		C90DR_avionics_ctl22_com2_xfr_mem_switch_pos = 0
        if (simDR_avionics_power_on * simDR_com2_power) > 0 then
            if C90DR_avionics_ctl22_com2_sto_index > 0 then
	            run_after_time(com2_xfr_reset,0.02)
            end
        end
	end
end

function com2_xfr_reset()
    if C90DR_avionics_ctl22_com2_sto_index > 0 then
        C90DR_avionics_ctl22_com2_sto_index = 0
        simDR_com2_stby_frequency = C90.avionics.ctl22_com2_sto_stack[0]
    end
    stop_timer(com2_xfr_reset)
end

-- NAV1 ACT/STO/XFR/MEM FUNCTION							--IBAV8N
function C90_avionics_ctl32_nav1_act_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_nav1_power) > 0 then
        if C90DR_avionics_ctl32_nav1_act == 0 then
            C90DR_avionics_ctl32_nav1_sto_index = 0
            C90.avionics.ctl32_nav1_sto_stack[0] = simDR_nav1_stby_frequency
            simDR_nav1_stby_frequency = simDR_nav1_frequency
            C90DR_avionics_ctl32_nav1_act = 1
            run_at_interval(nav1_act, 0.02)
        else
		    stop_timer(nav1_act)
            simDR_nav1_stby_frequency = C90.avionics.ctl32_nav1_sto_stack[0]
            C90DR_avionics_ctl32_nav1_act = 0
        end
    end
end

function nav1_act()
   simDR_nav1_frequency = simDR_nav1_stby_frequency
end

function C90_avionics_ctl32_nav1_sto_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_nav1_power) > 0 then
		if C90DR_avionics_ctl32_nav1_sto_index > 0 then
        	if C90.avionics.ctl32_nav1_sto_count == 0 then
            	C90.avionics.ctl32_nav1_sto_count = 1
        	else
            	C90.avionics.ctl32_nav1_sto_stack[C90DR_avionics_ctl32_nav1_sto_index] = simDR_nav1_stby_frequency      --current slot = stby freq
            	C90.avionics.ctl32_nav1_mem = 1
            	run_after_time(nav1_mem,1)
            	C90.avionics.ctl32_nav1_sto_count = 0
			end
        end
    end
end

function nav1_mem()
    C90.avionics.ctl32_nav1_mem = 0                                                                                     --turn off the sto light
	if C90DR_avionics_ctl32_nav1_sto_index < 4 then		                                                                --if not at the end of the stack
		C90DR_avionics_ctl32_nav1_sto_index = C90DR_avionics_ctl32_nav1_sto_index + 1                                   --advance to the next sto index
	else
	    C90DR_avionics_ctl32_nav1_sto_index = 0                                                                         --if at sto index 6, return to zero
        simDR_nav1_stby_frequency = C90.avionics.ctl32_nav1_sto_stack[0]                                                --return the stby freq from the variable
	end
    if C90.avionics.ctl32_nav1_sto_stack[C90DR_avionics_ctl32_nav1_sto_index] == 0 then                                 --if sto index is zero
        simDR_nav1_stby_frequency = C90.avionics.ctl32_nav1_sto_stack[0]                                                --show the stby freq
    else
        simDR_nav1_stby_frequency = C90.avionics.ctl32_nav1_sto_stack[C90DR_avionics_ctl32_nav1_sto_index]              --else show the existing sto index freq
    end
	stop_timer(nav1_mem)
end

function C90_avionics_ctl32_nav1_xfr_mem_dn_CMDhandler(phase, duration)
	if phase == 0 then
        C90DR_avionics_ctl32_nav1_xfr_mem_switch_pos = -1                                                               --animate switch down
        if (simDR_avionics_power_on * simDR_nav1_power) > 0 then
            if C90DR_avionics_ctl32_nav1_act == 0 then                                                                  --not in ACT mode
                C90.avionics.ctl32_nav1_sto_count = 0
                if C90DR_avionics_ctl32_nav1_sto_index == 0 then                                                        --if @ MEM pos 0, or standby
                    C90.avionics.ctl32_nav1_sto_stack[0] = simDR_nav1_stby_frequency                                    --save stby freq as index 0
                end
                run_after_time(nav1_mem,0.02)
            end
        end
	elseif phase == 2 then
		C90DR_avionics_ctl32_nav1_xfr_mem_switch_pos = 0                                                                --animate switch up
    end
end

function C90_avionics_ctl32_nav1_xfr_mem_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl32_nav1_xfr_mem_switch_pos = 1
        if (simDR_avionics_power_on * simDR_nav1_power) > 0 then
            if C90DR_avionics_ctl32_nav1_act == 0 then                                                                  --not in ACT mode
                C90.avionics.ctl32_nav1_sto_count = 0
                if C90DR_avionics_ctl32_nav1_sto_index == 0 then                                                        --if user is not using the mem function
                    simCMD_nav1_freq_flip:once()                                                                        --flip the stby like standard x-plane
                    C90.avionics.ctl32_nav1_sto_stack[0] = simDR_nav1_stby_frequency                                    --reset the dme to new nav1 stby freq
                    simDR_radio_dme_freq_hz = simDR_nav1_stby_frequency                                                 --update ind42 DME ch3
                elseif C90DR_avionics_ctl32_nav1_sto_index > 0 then
                    if C90.avionics.ctl32_nav1_sto_stack[C90DR_avionics_ctl32_nav1_sto_index] == 0 then
                        simDR_nav1_frequency = simDR_nav1_stby_frequency
                    else
                        simDR_nav1_frequency = C90.avionics.ctl32_nav1_sto_stack[C90DR_avionics_ctl32_nav1_sto_index]
                    end
                end
            end
		end
	elseif phase == 2 then
		C90DR_avionics_ctl32_nav1_xfr_mem_switch_pos = 0
        if (simDR_avionics_power_on * simDR_nav1_power) > 0 then
            if C90DR_avionics_ctl32_nav1_sto_index > 0 then
	            run_after_time(nav1_xfr_reset,0.02)
            end
        end
	end
end

function nav1_xfr_reset()
    if C90DR_avionics_ctl32_nav1_sto_index > 0 then
        C90DR_avionics_ctl32_nav1_sto_index = 0
        simDR_nav1_stby_frequency = C90.avionics.ctl32_nav1_sto_stack[0]
    end
    stop_timer(nav1_xfr_reset)
end

-- NAV2 ACT/STO/XFR/MEM FUNCTION							--IBAV8N
function C90_avionics_ctl32_nav2_act_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_nav2_power) > 0 then
        if C90DR_avionics_ctl32_nav2_act == 0 then
            C90DR_avionics_ctl32_nav2_sto_index = 0
            C90.avionics.ctl32_nav2_sto_stack[0] = simDR_nav2_stby_frequency
            simDR_nav2_stby_frequency = simDR_nav2_frequency
            C90DR_avionics_ctl32_nav2_act = 1
            run_at_interval(nav2_act, 0.02)
        else
		    stop_timer(nav2_act)
            simDR_nav2_stby_frequency = C90.avionics.ctl32_nav2_sto_stack[0]
            C90DR_avionics_ctl32_nav2_act = 0
        end
    end
end

function nav2_act()
   simDR_nav2_frequency = simDR_nav2_stby_frequency
end

function C90_avionics_ctl32_nav2_sto_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_nav2_power) > 0 then
		if C90DR_avionics_ctl32_nav2_sto_index > 0 then
        	if C90.avionics.ctl32_nav2_sto_count == 0 then
            	C90.avionics.ctl32_nav2_sto_count = 1
        	else
            	C90.avionics.ctl32_nav2_sto_stack[C90DR_avionics_ctl32_nav2_sto_index] = simDR_nav2_stby_frequency      --current slot = stby freq
            	C90.avionics.ctl32_nav2_mem = 1
            	run_after_time(nav2_mem,1)
            	C90.avionics.ctl32_nav2_sto_count = 0
			end
        end
    end
end

function nav2_mem()
    C90.avionics.ctl32_nav2_mem = 0                                                                                     --turn off the sto light
	if C90DR_avionics_ctl32_nav2_sto_index < 4 then		                                                                --if not at the end of the stack
		C90DR_avionics_ctl32_nav2_sto_index = C90DR_avionics_ctl32_nav2_sto_index + 1                                   --advance to the next sto index
	else
	    C90DR_avionics_ctl32_nav2_sto_index = 0                                                                         --if at sto index 6, return to zero
        simDR_nav2_stby_frequency = C90.avionics.ctl32_nav2_sto_stack[0]                                                --return the stby freq from the variable
	end
    if C90.avionics.ctl32_nav2_sto_stack[C90DR_avionics_ctl32_nav2_sto_index] == 0 then                                 --if sto index is zero
        simDR_nav2_stby_frequency = C90.avionics.ctl32_nav2_sto_stack[0]                                                --show the stby freq
    else
        simDR_nav2_stby_frequency = C90.avionics.ctl32_nav2_sto_stack[C90DR_avionics_ctl32_nav2_sto_index]              --else show the existing sto index freq
    end
	stop_timer(nav2_mem)
end

function C90_avionics_ctl32_nav2_xfr_mem_dn_CMDhandler(phase, duration)
	if phase == 0 then
        C90DR_avionics_ctl32_nav2_xfr_mem_switch_pos = -1                                                               --animate switch down
        if (simDR_avionics_power_on * simDR_nav2_power) > 0 then
            if C90DR_avionics_ctl32_nav2_act == 0 then                                                                  --not in ACT mode
                C90.avionics.ctl32_nav2_sto_count = 0
                if C90DR_avionics_ctl32_nav2_sto_index == 0 then                                                        --if @ MEM pos 0, or standby
                    C90.avionics.ctl32_nav2_sto_stack[0] = simDR_nav2_stby_frequency                                    --save stby freq as index 0
                end
                run_after_time(nav2_mem,0.02)
            end
        end
	elseif phase == 2 then
		C90DR_avionics_ctl32_nav2_xfr_mem_switch_pos = 0                                                                --animate switch up
    end
end

function C90_avionics_ctl32_nav2_xfr_mem_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl32_nav2_xfr_mem_switch_pos = 1
        if (simDR_avionics_power_on * simDR_nav1_power) > 0 then
            if C90DR_avionics_ctl32_nav2_act == 0 then                                                                  --not in ACT mode
                C90.avionics.ctl32_nav2_sto_count = 0
                if C90DR_avionics_ctl32_nav2_sto_index == 0 then                --if user is not using the mem function
                    simCMD_nav2_freq_flip:once()                                --flip the stby like standard x-plane
                    C90.avionics.ctl32_nav2_sto_stack[0] = simDR_nav2_stby_frequency
                elseif C90DR_avionics_ctl32_nav2_sto_index > 0 then
                    if C90.avionics.ctl32_nav2_sto_stack[C90DR_avionics_ctl32_nav2_sto_index] == 0 then
                        simDR_nav2_frequency = simDR_nav2_stby_frequency
                    else
                        simDR_nav2_frequency = C90.avionics.ctl32_nav2_sto_stack[C90DR_avionics_ctl32_nav2_sto_index]
                    end
                end
            end
		end
	elseif phase == 2 then
		C90DR_avionics_ctl32_nav2_xfr_mem_switch_pos = 0
        if (simDR_avionics_power_on * simDR_nav1_power) > 0 then
            if C90DR_avionics_ctl32_nav2_sto_index > 0 then
	            run_after_time(nav2_xfr_reset,0.02)
            end
        end
	end
end

function nav2_xfr_reset()
    if C90DR_avionics_ctl32_nav2_sto_index > 0 then
        C90DR_avionics_ctl32_nav2_sto_index = 0
        simDR_nav2_stby_frequency = C90.avionics.ctl32_nav2_sto_stack[0]
    end
    stop_timer(nav2_xfr_reset)
end

-- ADF ACT/STO/XFR/MEM FUNCTION							--IBAV8N
function C90_avionics_ctl62_adf_act_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_adf1_power) > 0 then
        if C90DR_avionics_ctl62_adf_act == 0 then
            C90DR_avionics_ctl62_adf_sto_index = 0
            C90DR_avionics_ctl62_adf_act_stby = simDR_adf_stby_frequency
            simDR_adf_stby_frequency = simDR_adf_frequency
            C90DR_avionics_ctl62_adf_act = 1
            run_at_interval(adf_act, 0.02)
        else
		    stop_timer(adf_act)
            simDR_adf_stby_frequency = C90DR_avionics_ctl62_adf_act_stby
            C90DR_avionics_ctl62_adf_act = 0
        end
    end
end

function adf_act()
   simDR_adf_frequency = simDR_adf_stby_frequency
   simDR_adf2_frequency = simDR_adf_frequency
end

function C90_avionics_ctl62_adf_sto_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_adf1_power) > 0 then
		if C90DR_avionics_ctl62_adf_sto_index > 0 then
        	if C90.avionics.ctl62_adf_sto_count == 0 then
            	C90.avionics.ctl62_adf_sto_count = 1
        	else
            	C90.avionics.ctl62_adf_sto_stack[C90DR_avionics_ctl62_adf_sto_index] = simDR_adf_stby_frequency     --current slot = stby freq
            	C90.avionics.ctl62_adf_mem = 1
            	run_after_time(adf_mem,1)
            	C90.avionics.ctl62_adf_sto_count = 0
			end
        end
    end
end

function adf_mem()
    C90.avionics.ctl62_adf_mem = 0                                                                                  --turn off the sto light
	if C90DR_avionics_ctl62_adf_sto_index < 4 then		                                                            --if not at the end of the stack
		C90DR_avionics_ctl62_adf_sto_index = C90DR_avionics_ctl62_adf_sto_index + 1                                 --advance to the next sto index
	else
	    C90DR_avionics_ctl62_adf_sto_index = 0                                                                      --if at sto index 4, return to zero
        simDR_adf_stby_frequency = C90.avionics.ctl62_adf_sto_stack[0]                                              --return the stby freq from the variable
	end
    if C90.avionics.ctl62_adf_sto_stack[C90DR_avionics_ctl62_adf_sto_index] == 0 then                               --if sto index is zero
        simDR_adf_stby_frequency = C90.avionics.ctl62_adf_sto_stack[0]                                              --show the stby freq
    else
        simDR_adf_stby_frequency = C90.avionics.ctl62_adf_sto_stack[C90DR_avionics_ctl62_adf_sto_index]             --else show the existing sto index freq
    end
	stop_timer(adf_mem)
end

function C90_avionics_ctl62_adf_xfr_mem_dn_CMDhandler(phase, duration)
	if phase == 0 then
        C90DR_avionics_ctl62_adf_xfr_mem_switch_pos = -1                                                            --animate switch down
        if (simDR_avionics_power_on * simDR_adf1_power) > 0 then
            if C90DR_avionics_ctl62_adf_act == 0 then                                                               --not in ACT mode
                C90.avionics.ctl62_adf_sto_count = 0
                if C90DR_avionics_ctl62_adf_sto_index == 0 then                                                     --if @ MEM pos 0, or standby
                    C90.avionics.ctl62_adf_sto_stack[0] = simDR_adf_stby_frequency                                  --save stby freq as index 0
                end
                run_after_time(adf_mem,0.02)
            end
        end
	elseif phase == 2 then
		C90DR_avionics_ctl62_adf_xfr_mem_switch_pos = 0                                                             --animate switch up
    end
end

function C90_avionics_ctl62_adf_xfr_mem_up_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl62_adf_xfr_mem_switch_pos = 1
        if (simDR_avionics_power_on * simDR_adf1_power) > 0 then
            if C90DR_avionics_ctl62_adf_act == 0 then                                                               --not in ACT mode
                C90.avionics.ctl62_adf_sto_count = 0
                if C90DR_avionics_ctl62_adf_sto_index == 0 then                                                     --if user is not using the mem function
                    simCMD_adf_freq_flip:once()                                                                     --flip the stby like standard radio
                    C90.avionics.ctl62_adf_sto_stack[0] = simDR_adf_stby_frequency
                elseif C90DR_avionics_ctl62_adf_sto_index > 0 then
                    if C90.avionics.ctl62_adf_sto_stack[C90DR_avionics_ctl62_adf_sto_index] == 0 then
                        simDR_adf_frequency = simDR_adf_stby_frequency
                    else
                        simDR_adf_frequency = C90.avionics.ctl62_adf_sto_stack[C90DR_avionics_ctl62_adf_sto_index]
                    end
                end
            end
		end
		simDR_adf2_frequency = simDR_adf_frequency
	elseif phase == 2 then
		C90DR_avionics_ctl62_adf_xfr_mem_switch_pos = 0
        if C90DR_avionics_ctl62_adf_sto_index > 0 then
	        run_after_time(adf_xfr_reset,0.02)
        end
	end
end

function adf_xfr_reset()
    if C90DR_avionics_ctl62_adf_sto_index > 0 then
        C90DR_avionics_ctl62_adf_sto_index = 0
        simDR_adf_stby_frequency = C90.avionics.ctl62_adf_sto_stack[0]
    end
    stop_timer(adf_xfr_reset)
end

function C90_avionics_ctl62_adf_mode_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_adf1_power = math.min(3, simDR_adf1_power + 1)
	end
end

function C90_avionics_ctl62_adf_mode_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_adf1_power = math.max(0, simDR_adf1_power - 1)
	end
end

-- TRANSPONDER							--IBAV8N
function C90_avionics_ctl92_xpdr_pre_switch_CMDhandler(phase, duration)
    if phase == 0 and (simDR_avionics_power_on * simDR_transponder_power) > 0 then
        if C90DR_avionics_ctl92_xpdr_pre_switch_pos == 0 then
            C90.avionics.ctl92_xpdr_ifr = simDR_transponder_code
            simDR_transponder_code = C90.avionics.ctl92_xpdr_vfr
            C90DR_avionics_ctl92_xpdr_pre_switch_pos = 1
        elseif C90DR_avionics_ctl92_xpdr_pre_switch_pos == 1 then
            C90.avionics.ctl92_xpdr_vfr = simDR_transponder_code
            simDR_transponder_code = C90.avionics.ctl92_xpdr_ifr
            C90DR_avionics_ctl92_xpdr_pre_switch_pos = 0
        end
    end
end

function C90_avionics_ctl92_xpdr_mode_up_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_transponder_mode = math.min(3, simDR_transponder_mode + 1)
	end
end

function C90_avionics_ctl92_xpdr_mode_dn_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_transponder_mode = math.max(0, simDR_transponder_mode - 1)
	end
end

function C90_avionics_ind42_power_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_ind42_power_switch_pos = 1 - C90DR_avionics_ind42_power_switch_pos
		if C90DR_avionics_ind42_power_switch_pos == 1 then
			C90DR_avionics_ind42_channel = 1
			C90DR_avionics_ind42_mode = 0
		end
	end
end

function C90_avionics_ind42_mode_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_ind42_mode_switch_pos = 1
		C90DR_avionics_ind42_mode = C90DR_avionics_ind42_mode + 1
		if C90DR_avionics_ind42_mode == 3 then C90DR_avionics_ind42_mode = 0 end
	elseif phase == 2 then
		C90DR_avionics_ind42_mode_switch_pos = 0
	end
end

function C90_avionics_ind42_channel_switch_CMDhandler(phase, duration)
	if phase == 0 then
		C90DR_avionics_ind42_channel_switch_pos = 1
		C90DR_avionics_ind42_channel = C90DR_avionics_ind42_channel + 1
		if C90DR_avionics_ind42_channel == 4 then C90DR_avionics_ind42_channel = 1 end
	elseif phase == 2 then
		C90DR_avionics_ind42_channel_switch_pos = 0
	end
end
--[[
-- Reality XP Plugin CMD Handlers - GTN
function C90_avionics_gtn_sd_card_pos_1_CMDHandler(phase, duration)
    if phase == 0 then
        if C90DR_avionics_gtn_sd_card_pos[0] == 0 then
            C90DR_avionics_gtn_sd_card_pos[0] = 1
        else
            C90DR_avionics_gtn_sd_card_pos[0] = 0
        end
    end
end

function C90_avionics_gtn_sd_card_pos_2_CMDHandler(phase, duration)
    if phase == 0 then
        if C90DR_avionics_gtn_sd_card_pos[1] == 0 then
            C90DR_avionics_gtn_sd_card_pos[1] = 1
        else
            C90DR_avionics_gtn_sd_card_pos[1] = 0
        end
    end
end
--]]
--*************************************************************************************--
--** 				             CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--
print("EVO: 9. LOADING Custom Command Handlers")
-- OVERHEAD PANEL
C90CMD_electrical_ovh_flood_toggle		        = create_command("laminar/c90/electrical/switch/ovh_flood_toggle", "Overhead Panel Flood Toggle", C90_electrical_ovh_flood_toggle_CMDhandler)
C90CMD_electrical_ovh_master_toggle		        = create_command("laminar/c90/electrical/switch/ovh_master_toggle", "Overhead Panel Master Switch Toggle", C90_electrical_ovh_master_toggle_CMDhandler)
C90CMD_electrical_ovh_master_up		            = create_command("laminar/c90/electrical/switch/ovh_master_up", "Overhead Panel Master Switch Up", C90_electrical_electrical_ovh_master_up_CMDhandler)
C90CMD_electrical_ovh_master_dn		            = create_command("laminar/c90/electrical/switch/ovh_master_dn", "Overhead Panel Master Switch Down", C90_electrical_electrical_ovh_master_dn_CMDhandler)
C90CMD_electrical_ovh_emerg_toggle		        = create_command("laminar/c90/electrical/switch/instrument_emerg_toggle", "Overhead Panel Emergency Switch Toggle", C90_electrical_ovh_emerg_toggle_CMDhandler)
C90CMD_electrical_ovh_emerg_up		            = create_command("laminar/c90/electrical/switch/instrument_emerg_up", "Overhead Panel Emergency Switch Up", C90_electrical_ovh_emerg_up_CMDhandler)
C90CMD_electrical_ovh_emerg_dn		            = create_command("laminar/c90/electrical/switch/instrument_emerg_dn", "Overhead Panel Emergency Switch Down", C90_electrical_ovh_emerg_dn_CMDhandler)
C90CMD_electrical_voltmeter_knob_up		        = create_command("laminar/c90/electrical/switch/voltmeter_knob_up", "Overhead Panel Voltmeter Knob Up", C90_electrical_voltmeter_knob_up_CMDhandler)  --IBAV8N, command handler for voltmeter knob
C90CMD_electrical_voltmeter_knob_dn		        = create_command("laminar/c90/electrical/switch/voltmeter_knob_dn", "Overhead Panel Voltmeter Knob Down", C90_electrical_voltmeter_knob_dn_CMDhandler)
-- FUEL PANEL
C90CMD_fuel_firewall_switch_guard_toggle_L		= create_command("laminar/c90/fuel/firewall_switch_guard_toggle_L", "Fuel Firewall Switch Guard Toggle Left", C90_fuel_firewall_switch_guard_toggle_L_CMDhandler)
C90CMD_fuel_firewall_switch_guard_toggle_R		= create_command("laminar/c90/fuel/firewall_switch_guard_toggle_R", "Fuel Firewall Switch Guard Toggle Right", C90_fuel_firewall_switch_guard_toggle_R_CMDhandler)
-- PILOT'S PANEL
C90CMD_annunciator_clear_masters			    = create_command("laminar/c90/annunciator/clear_masters", "Press Master Warning/Caution Together", C90_annunciator_clear_masters_CMDhandler)
C90CMD_fltInst_ccu65_slave_mode_switch			= create_command("laminar/c90/fltInst/ccu65/switch/slave_mode", "Flight Instruments Gyro Slave Mode Switch", C90_fltInst_ccu65_slave_mode_switch_CMDhandler)
C90CMD_avionics_EFIS_aux_pwr_switch_up			= create_command("laminar/c90/avionics/switch/EFIS_aux_pwr_up", "Avionics EFIS Auciliary Power Switch Up", C90_avionics_EFIS_aux_pwr_switch_up_CMDhandler)
C90CMD_avionics_EFIS_aux_pwr_switch_dn			= create_command("laminar/c90/avionics/switch/EFIS_aux_pwr_dn", "Avionics EFIS Auciliary Power Switch Down", C90_avionics_EFIS_aux_pwr_switch_dn_CMDhandler)
C90CMD_avionics_EFIS_aux_horn_silence			= create_command("laminar/c90/avionics/switch/EFIS_aux_horn_silence", "Avionics EFIS Auxiliary Horn Silence Switch", C90_avionics_EFIS_aux_horn_silence_switch_CMDhandler)
-- PILOT'S LEFT SUBPANEL
C90CMD_avionics_mic_sel_switch_pilot			= create_command("laminar/c90/avionics/switch/mic_sel_pilot", "Avionics Mic Selector Switch (Pilot)", C90_avionics_mic_sel_switch_pilot_CMDhandler)
C90CMD_avionics_on_switch_toggle                = create_command("laminar/c90/avionics/switch/avionics_sw_toggle", "Avionics Master Switch Toggle", C90_avionics_on_toggle_CMDhandler)  --IBAV8N,Jan19-21
C90CMD_avionics_on_switch_up			        = create_command("laminar/c90/avionics/switch/avionics_sw_up", "Avionics Master Switch Up", C90_avionics_on_switch_up_CMDhandler)       --IBAV8N,May22-22
C90CMD_avionics_on_switch_down			        = create_command("laminar/c90/avionics/switch/avionics_sw_dn", "Avionics Master Switch Down", C90_avionics_on_switch_dn_CMDhandler)     --IBAV8N,May22-22
C90CMD_electrical_inverter_sel_switch_up		= create_command("laminar/c90/electrical/switch/inverter_selector_up", "Electrical Inverter Selector Switch Up", C90_electrical_inverter_sel_switch_up_CMDhandler)
C90CMD_electrical_inverter_sel_switch_dn		= create_command("laminar/c90/electrical/switch/inverter_selector_dn", "Electrical Inverter Selector Switch Down", C90_electrical_inverter_sel_switch_dn_CMDhandler)
C90CMD_electrical_auto_ignition_switch_L		= create_command("laminar/c90/electrical/switch/auto_ignition_L", "Electrical Auto-Ignition Switch Left", C90_electrical_auto_ignition_switch_L_CMDhandler)
C90CMD_electrical_auto_ignition_switch_L_up		= create_command("laminar/c90/electrical/switch/auto_ignition_L_up", "Electrical Auto-Ignition Switch Left Up", C90_electrical_auto_ignition_switch_L_up_CMDhandler)
C90CMD_electrical_auto_ignition_switch_L_dn		= create_command("laminar/c90/electrical/switch/auto_ignition_L_dn", "Electrical Auto-Ignition Switch Left Down", C90_electrical_auto_ignition_switch_L_dn_CMDhandler)
C90CMD_electrical_auto_ignition_switch_R		= create_command("laminar/c90/electrical/switch/auto_ignition_R", "Electrical Auto-Ignition Switch Right", C90_electrical_auto_ignition_switch_R_CMDhandler)
C90CMD_electrical_auto_ignition_switch_R_up		= create_command("laminar/c90/electrical/switch/auto_ignition_R_up", "Electrical Auto-Ignition Switch Right Up", C90_electrical_auto_ignition_switch_R_up_CMDhandler)
C90CMD_electrical_auto_ignition_switch_R_dn		= create_command("laminar/c90/electrical/switch/auto_ignition_R_dn", "Electrical Auto-Ignition Switch Right Down", C90_electrical_auto_ignition_switch_R_dn_CMDhandler)
C90CMD_electrical_generator1_switch_up			= create_command("laminar/c90/electrical/switch/generator1_up", "Electrical Generator1 Switch Up", C90_electrical_generator_L_switch_up_CMDhandler)
C90CMD_electrical_generator1_switch_dn			= create_command("laminar/c90/electrical/switch/generator1_dn", "Electrical Generator1 Switch Down", C90_electrical_generator_L_switch_dn_CMDhandler)
C90CMD_electrical_generator2_switch_up			= create_command("laminar/c90/electrical/switch/generator2_up", "Electrical Generator2 Switch Up", C90_electrical_generator_R_switch_up_CMDhandler)
C90CMD_electrical_generator2_switch_dn			= create_command("laminar/c90/electrical/switch/generator2_dn", "Electrical Generator2 Switch Down", C90_electrical_generator_R_switch_dn_CMDhandler)
C90CMD_electrical_bus_sense_switch_up		 	= create_command("laminar/c90/electrical/switch/bus_sense_up", "Electrical Bus Sense Switch Up", C90_electrical_bus_sense_switch_up_CMDhandler)
C90CMD_electrical_bus_sense_switch_dn		 	= create_command("laminar/c90/electrical/switch/bus_sense_dn", "Electrical Bus Sense Switch Down", C90_electrical_bus_sense_switch_dn_CMDhandler)
C90CMD_electrical_cross_tie_switch_up		 	= create_command("laminar/c90/electrical/switch/cross_tie_up", "Electrical Cross Tie Switch Up", C90_electrical_cross_tie_switch_up_CMDhandler)			--IBAV8N, Jan25-21
C90CMD_electrical_cross_tie_switch_dn		 	= create_command("laminar/c90/electrical/switch/cross_tie_dn", "Electrical Cross Tie Switch Down", C90_electrical_cross_tie_switch_dn_CMDhandler)		--IBAV8N, Jan25-21
C90CMD_powerplant_ign_start_switch_up_L			= create_command("laminar/c90/powerplant/switch/ign_start_up_L", "Powerplant Ignition-Start Switch Up Left", C90_powerplant_ign_start_switch_up_L_CMDhandler)
C90CMD_powerplant_ign_start_switch_dn_L			= create_command("laminar/c90/powerplant/switch/ign_start_dn_L", "Powerplant Ignition-Start Switch Down Left", C90_powerplant_ign_start_switch_dn_L_CMDhandler)
C90CMD_powerplant_ign_start_switch_up_R			= create_command("laminar/c90/powerplant/switch/ign_start_up_R", "Powerplant Ignition-Start Switch Up Right", C90_powerplant_ign_start_switch_up_R_CMDhandler)
C90CMD_powerplant_ign_start_switch_dn_R			= create_command("laminar/c90/powerplant/switch/ign_start_dn_R", "Powerplant Ignition-Start Switch Down Right", C90_powerplant_ign_start_switch_dn_R_CMDhandler)
C90CMD_powerplant_autofeather_switch_up			= create_command("laminar/c90/powerplant/switch/autofeather_switch_up", "Powerplant Auto-Feather Switch Up", C90_powerplant_autofeather_switch_up_CMDhandler)
C90CMD_powerplant_autofeather_switch_dn			= create_command("laminar/c90/powerplant/switch/autofeather_switch_dn", "Powerplant Auto-Feather Switch Down", C90_powerplant_autofeather_switch_dn_CMDhandler)
C90CMD_powerplant_autofeather_switch_toggle	    = create_command("laminar/c90/powerplant/switch/autofeather_switch_toggle", "Powerplant Auto-Feather Switch On/Off Toggle", C90_powerplant_autofeather_switch_toggle_CMDhandler) --IBAV8N, Mar16-22
C90CMD_powerplant_prop_gov_switch				= create_command("laminar/c90/powerplant/switch/prop_gov", "Powerplant Prop-Gov Switch", C90_powerplant_prop_gov_switch_CMDhandler)
C90CMD_powerplant_prop_gov_switch_up			= create_command("laminar/c90/powerplant/switch/prop_gov_up", "Powerplant Prop-Gov Switch Up", C90_powerplant_prop_gov_switch_up_CMDhandler)
C90CMD_powerplant_prop_gov_switch_dn			= create_command("laminar/c90/powerplant/switch/prop_gov_dn", "Powerplant Prop-Gov Switch Down", C90_powerplant_prop_gov_switch_dn_CMDhandler)
C90CMD_avitab_enabled_toggle		            = create_command("laminar/c90/avitab_enabled_toggle", "Avitab tablet enable/remove", C90_avitab_enabled_toggle_CMDhandler)
-- PILOT'S RIGHT SUBPANEL
C90CMD_iceRain_engine_act_motor_sel_switch_L	= create_command("laminar/c90/iceRain/switch/engine_act_motor_sel_L", "Ice & Rain Protection - Engine Motor Switch Left", C90_iceRain_engine_act_motor_sel_switch_L_CMDhandler)
C90CMD_iceRain_engine_act_motor_sel_switch_L_up	= create_command("laminar/c90/iceRain/switch/engine_act_motor_sel_L_up", "Ice & Rain Protection - Engine Motor Switch Left Up", C90_iceRain_engine_act_motor_sel_switch_L_up_CMDhandler)
C90CMD_iceRain_engine_act_motor_sel_switch_L_dn	= create_command("laminar/c90/iceRain/switch/engine_act_motor_sel_L_dn", "Ice & Rain Protection - Engine Motor Switch Left Down", C90_iceRain_engine_act_motor_sel_switch_L_dn_CMDhandler)
C90CMD_iceRain_engine_act_motor_sel_switch_R	= create_command("laminar/c90/iceRain/switch/engine_act_motor_sel_R", "Ice & Rain Protection - Engine Motor Switch Right", C90_iceRain_engine_act_motor_sel_switch_R_CMDhandler)
C90CMD_iceRain_engine_act_motor_sel_switch_R_up	= create_command("laminar/c90/iceRain/switch/engine_act_motor_sel_R_up", "Ice & Rain Protection - Engine Motor Switch Right Up", C90_iceRain_engine_act_motor_sel_switch_R_up_CMDhandler)
C90CMD_iceRain_engine_act_motor_sel_switch_R_dn	= create_command("laminar/c90/iceRain/switch/engine_act_motor_sel_R_dn", "Ice & Rain Protection - Engine Motor Switch Right Down", C90_iceRain_engine_act_motor_sel_switch_R_dn_CMDhandler)
C90CMD_iceRain_engine_antiice_switch_toggle		= create_command("laminar/c90/iceRain/switch/engine_antiice_sel_both", "Ice & Rain Protection - Engine Anti-Ice Switch Toggle L&R", C90_iceRain_engine_antiice_sel_switch_both_CMDhandler)--IBAV8N, Mar16-22, one command to toggle both engine anti-ice switches
C90CMD_iceRain_engine_antiice_sel_switch_L		= create_command("laminar/c90/iceRain/switch/engine_antiice_sel_L", "Ice & Rain Protection - Engine Anti-Ice Switch Left Toggle", C90_iceRain_engine_antiice_sel_switch_L_CMDhandler)
C90CMD_iceRain_engine_antiice_sel_switch_L_up	= create_command("laminar/c90/iceRain/switch/engine_antiice_sel_L_up", "Ice & Rain Protection - Engine Anti-Ice Switch Left Up", C90_iceRain_engine_antiice_sel_switch_L_Up_CMDhandler)
C90CMD_iceRain_engine_antiice_sel_switch_L_dn	= create_command("laminar/c90/iceRain/switch/engine_antiice_sel_L_dn", "Ice & Rain Protection - Engine Anti-Ice Switch Left Down", C90_iceRain_engine_antiice_sel_switch_L_Down_CMDhandler)
C90CMD_iceRain_engine_antiice_sel_switch_R		= create_command("laminar/c90/iceRain/switch/engine_antiice_sel_R", "Ice & Rain Protection - Engine Anti-Ice Switch Right Toggle", C90_iceRain_engine_antiice_sel_switch_R_CMDhandler)
C90CMD_iceRain_engine_antiice_sel_switch_R_up	= create_command("laminar/c90/iceRain/switch/engine_antiice_sel_R_up", "Ice & Rain Protection - Engine Anti-Ice Switch Right Up", C90_iceRain_engine_antiice_sel_switch_R_Up_CMDhandler)
C90CMD_iceRain_engine_antiice_sel_switch_R_dn	= create_command("laminar/c90/iceRain/switch/engine_antiice_sel_R_dn", "Ice & Rain Protection - Engine Anti-Ice Switch Right Down", C90_iceRain_engine_antiice_sel_switch_R_Down_CMDhandler)
C90CMD_iceRain_windshield_antiice_switch_up_L	= create_command("laminar/c90/iceRain/switch/windshield_antiice_up_L", "Ice & Rain Protection - Windshied Anti-Ice Up Left", C90_iceRain_windshield_antiice_switch_up_L_CMDhandler)
C90CMD_iceRain_windshield_antiice_switch_dn_L	= create_command("laminar/c90/iceRain/switch/windshield_antiice_dn_L", "Ice & Rain Protection - Windshied Anti-Ice Down Left", C90_iceRain_windshield_antiice_switch_dn_L_CMDhandler)
C90CMD_iceRain_windshield_antiice_switch_up_R	= create_command("laminar/c90/iceRain/switch/windshield_antiice_up_R", "Ice & Rain Protection - Windshied Anti-Ice Up Right", C90_iceRain_windshield_antiice_switch_up_R_CMDhandler)
C90CMD_iceRain_windshield_antiice_switch_dn_R	= create_command("laminar/c90/iceRain/switch/windshield_antiice_dn_R", "Ice & Rain Protection - Windshied Anti-Ice Down Right", C90_iceRain_windshield_antiice_switch_dn_R_CMDhandler)
C90CMD_iceRain_fuel_vent_deice_switch_L			= create_command("laminar/c90/iceRain/switch/fuel_vent_deice_L", "Ice & Rain Protection - Fuel Vent Switch Left", C90_iceRain_fuel_vent_switch_L_CMDhandler)
C90CMD_iceRain_fuel_vent_deice_switch_L_up		= create_command("laminar/c90/iceRain/switch/fuel_vent_deice_L_up", "Ice & Rain Protection - Fuel Vent Switch Left Up", C90_iceRain_fuel_vent_switch_L_up_CMDhandler)
C90CMD_iceRain_fuel_vent_deice_switch_L_dn		= create_command("laminar/c90/iceRain/switch/fuel_vent_deice_L_dn", "Ice & Rain Protection - Fuel Vent Switch Left Down", C90_iceRain_fuel_vent_switch_L_dn_CMDhandler)
C90CMD_iceRain_fuel_vent_deice_switch_R			= create_command("laminar/c90/iceRain/switch/fuel_vent_deice_R", "Ice & Rain Protection - Fuel Vent Switch Right", C90_iceRain_fuel_vent_switch_R_CMDhandler)
C90CMD_iceRain_fuel_vent_deice_switch_R_up		= create_command("laminar/c90/iceRain/switch/fuel_vent_deice_R_up", "Ice & Rain Protection - Fuel Vent Switch Right Up", C90_iceRain_fuel_vent_switch_R_up_CMDhandler)
C90CMD_iceRain_fuel_vent_deice_switch_R_dn		= create_command("laminar/c90/iceRain/switch/fuel_vent_deice_R_dn", "Ice & Rain Protection - Fuel Vent Switch Right Down", C90_iceRain_fuel_vent_switch_R_dn_CMDhandler)
C90CMD_iceRain_stall_warn_heat			        = create_command("c90_evo/iceRain/switch/stall_warn_heat", "Ice & Rain Protection - Stall Warn Heat Toggle", C90_iceRain_stall_warn_heat_CMDhandler)
C90CMD_iceRain_stall_warn_heat_up			    = create_command("c90_evo/iceRain/switch/stall_warn_heat_up", "Ice & Rain Protection - Stall Warn Heat Up", C90_iceRain_stall_warn_heat_up_CMDhandler)
C90CMD_iceRain_stall_warn_heat_dn			    = create_command("c90_evo/iceRain/switch/stall_warn_heat_dn", "Ice & Rain Protection - Stall Warn Heat Down", C90_iceRain_stall_warn_heat_dn_CMDhandler)
C90CMD_iceRain_surface_deice_switch_up			= create_command("laminar/c90/iceRain/switch/surface_deice_up", "Ice & Rain Protection - Surface De-Ice Switch Up", C90_iceRain_surface_deice_switch_up_CMDhandler)
C90CMD_iceRain_surface_deice_switch_dn			= create_command("laminar/c90/iceRain/switch/surface_deice_dn", "Ice & Rain Protection - Surface De-Ice Switch Down", C90_iceRain_surface_deice_switch_dn_CMDhandler)
C90CMD_iceRain_prop_deice_switch				= create_command("laminar/c90/iceRain/switch/prop_deice", "Ice & Rain Protection - Prop De-Ice Switch", C90_iceRain_prop_deice_switch_CMDhandler)
C90CMD_iceRain_prop_deice_switch_up				= create_command("laminar/c90/iceRain/switch/prop_deice_up", "Ice & Rain Protection - Prop De-Ice Switch Up", C90_iceRain_prop_deice_switch_up_CMDhandler)
C90CMD_iceRain_prop_deice_switch_dn				= create_command("laminar/c90/iceRain/switch/prop_deice_dn", "Ice & Rain Protection - Prop De-Ice Switch Down", C90_iceRain_prop_deice_switch_dn_CMDhandler)
C90CMD_lighting_wing_ice_switch_up				= create_command("laminar/c90/lighting/switch/wing_ice_up", "Lighting - Wing Ice Switch Up", C90_lighting_wing_ice_switch_up_CMDhandler)
C90CMD_lighting_wing_ice_switch_dn				= create_command("laminar/c90/lighting/switch/wing_ice_dn", "Lighting - Wing Ice Switch Down", C90_lighting_wing_ice_switch_dn_CMDhandler)
C90CMD_lighting_recog_switch_toggle				= create_command("laminar/c90/lighting/switch/recog", "Lighting - Recognition Switch Toggle", C90_lighting_recog_switch_toggle_CMDhandler)  --IBAV8N, Apr24-22
C90CMD_lighting_recog_switch_up					= create_command("laminar/c90/lighting/switch/recog_up", "Lighting - Recognition Switch Up", C90_lighting_recog_switch_up_CMDhandler)
C90CMD_lighting_recog_switch_dn					= create_command("laminar/c90/lighting/switch/recog_dn", "Lighting - Recognition Switch Down", C90_lighting_recog_switch_dn_CMDhandler)
C90CMD_lighting_tail_flood_switch_up			= create_command("laminar/c90/lighting/switch/tail_flood_up", "Lighting - Tail Flood Switch Up", C90_lighting_tail_flood_switch_up_CMDhandler)
C90CMD_lighting_tail_flood_switch_dn			= create_command("laminar/c90/lighting/switch/tail_flood_dn", "Lighting - Tail Flood Switch Down", C90_lighting_tail_flood_switch_dn_CMDhandler)
C90CMD_electrical_annun_test		            = create_command("laminar/c90/electrical/switch/annun_test", "Panel Annunciator Test", C90_electrical_annun_test_CMDhandler)
-- COPILOT'S LEFT SUBPANEL
C90CMD_lighting_bar_switch_up					= create_command("laminar/c90/lighting/switch/bar_up", "Lighting - Bar Switch Up", C90_lighting_bar_switch_up_CMDhandler)
C90CMD_lighting_bar_switch_dn					= create_command("laminar/c90/lighting/switch/bar_dn", "Lighting - Bar Switch Down", C90_lighting_bar_switch_dn_CMDhandler)
C90CMD_lighting_cabin_brt_dim_switch_up			= create_command("laminar/c90/lighting/switch/cabin_brt_dim_up", "Lighting - Cabin Bright/Dim Switch Up", C90_lighting_cabin_brt_dim_switch_up_CMDhandler)
C90CMD_lighting_cabin_brt_dim_switch_dn			= create_command("laminar/c90/lighting/switch/cabin_brt_dim_dn", "Lighting - Cabin Bright/Dim Switch Donn", C90_lighting_cabin_brt_dim_switch_dn_CMDhandler)
C90CMD_lighting_no_smoke_fsb_switch_up			= create_command("laminar/c90/lighting/switch/no_smoke_fsb_up", "Lighting - No Smoking & Fasten Seat Belt Switch Up", C90_lighting_no_smoke_fsb_switch_up_CMDhandler)
C90CMD_lighting_no_smoke_fsb_switch_dn			= create_command("laminar/c90/lighting/switch/no_smoke_fsb_dn", "Lighting - No Smoking & Fasten Seat Belt Switch Down", C90_lighting_no_smoke_fsb_switch_dn_CMDhandler)
C90CMD_pneumatic_bleed_air_switch_L			    = create_command("laminar/c90/pneumatic/switch/bleed_air_L", "Pneumatic Bleed Air Switch L", C90_pneumatic_bleed_air_switch_L_CMDhandler)
C90CMD_pneumatic_bleed_air_switch_L_up			= create_command("laminar/c90/pneumatic/switch/bleed_air_L_up", "Pneumatic Bleed Air Switch L Up", C90_pneumatic_bleed_air_switch_L_up_CMDhandler)
C90CMD_pneumatic_bleed_air_switch_L_dn			= create_command("laminar/c90/pneumatic/switch/bleed_air_L_dn", "Pneumatic Bleed Air Switch L Down", C90_pneumatic_bleed_air_switch_L_dn_CMDhandler)
C90CMD_pneumatic_bleed_air_switch_R				= create_command("laminar/c90/pneumatic/switch/bleed_air_R", "Pneumatic Bleed Air Switch R", C90_pneumatic_bleed_air_switch_R_CMDhandler)
C90CMD_pneumatic_bleed_air_switch_R_up			= create_command("laminar/c90/pneumatic/switch/bleed_air_R_up", "Pneumatic Bleed Air Switch R Up", C90_pneumatic_bleed_air_switch_R_up_CMDhandler)
C90CMD_pneumatic_bleed_air_switch_R_dn			= create_command("laminar/c90/pneumatic/switch/bleed_air_R_dn", "Pneumatic Bleed Air Switch R Down", C90_pneumatic_bleed_air_switch_R_dn_CMDhandler)
C90CMD_airCon_manual_temp_control_switch_up		= create_command("laminar/c90/airCon/switch/manual_temp_control_up", "Air Conditioning Manual Temp Control Switch Up", C90_airCon_manual_temp_control_switch_up_CMDhandler)
C90CMD_airCon_manual_temp_control_switch_dn		= create_command("laminar/c90/airCon/switch/manual_temp_control_dn", "Air Conditioning Manual Temp Control Switch Down", C90_airCon_manual_temp_control_switch_dn_CMDhandler)
C90CMD_airCon_cabin_temp_mode_dial_up			= create_command("laminar/c90/airCon/dial/cabin_temp_mode_dial_up", "Air Conditioning Cabin Temp Mode Dial Up", C90_airCon_cabin_temp_mode_dial_up_CMDhandler)
C90CMD_airCon_cabin_temp_mode_dial_dn			= create_command("laminar/c90/airCon/dial/cabin_temp_mode_dial_dn", "Air Conditioning Cabin Temp Mode Dial Down", C90_airCon_cabin_temp_mode_dial_dn_CMDhandler)
-- COPILOT'S RIGHT SUBPANEL
C90CMD_avionics_mic_sel_switch_copilot			= create_command("laminar/c90/avionics/switch/mic_sel_copilot", "Avionics Mic Selector Switch (CoPilot)", C90_avionics_mic_sel_switch_copilot_CMDhandler)
-- THROTTLES/PROPS/CONDITION
C90CMD_powerplant_beta_man       		        = create_command("laminar/c90/powerplant/beta", "Prop alpha/beta/rev - auto beta @ 40kts, manual reverse > 45 kts", C90_powerplant_beta_man_CMDhandler) --IBAV8N
C90CMD_powerplant_beta_throt       		        = create_command("laminar/c90/powerplant/beta_throt", "Prop alpha/beta/rev - auto beta @ 40kts, > 80% throttle for reverse > 45 kts", C90_powerplant_beta_throt_CMDhandler) --IBAV8N
-- BRAKES
C90CMD_smooth_brakes       				        = create_command("laminar/c90/brakes/smooth", "Smooth Braking, ideal for key/button users", C90_smooth_brakes_CMDhandler) ----IBAV8N, Apr8-22
-- THROTTLE QUADRANT
C90CMD_quadrant_lever_toggle		            = create_command("c90_evo/quadrant-lever-toggle", "Quadrant lever visibility toggle", C90CMD_quadrant_lever_toggle_CMDhandler) --IMC JAN16-24

C90CMD_idle_toggle				                = create_command("laminar/c90/condition_toggle", "Condition Levers Toggle Low - High", C90_condition_toggle_CMDhandler)
C90CMD_idle_low				                    = create_command("laminar/c90/condition_low", "Condition Levers Low Idle", C90_condition_low_CMDhandler)

-- PEDESTAL
C90CMD_pressure_control_switch_up				= create_command("laminar/c90/pressure/switch/control_up", "Pressurization Control Switch Up", C90_pressure_control_switch_up_CMDhandler)
C90CMD_pressure_control_switch_dn				= create_command("laminar/c90/pressure/switch/control_dn", "Pressurization Control Switch Down", C90_pressure_control_switch_dn_CMDhandler)
C90CMD_fltctrl_rudder_boost_switch				= create_command("laminar/c90/fltctrl/switch/rudder_boost", "Flight Control Rudder Boost Switch Toggle", C90_fltctrl_rudder_boost_switch_toggle_CMDhandler)
C90CMD_fltctrl_rudder_boost_switch_up			= create_command("laminar/c90/fltctrl/switch/rudder_boost_up", "Flight Control Rudder Boost Switch Up", C90_fltctrl_rudder_boost_switch_up_CMDhandler)
C90CMD_fltctrl_rudder_boost_switch_dn			= create_command("laminar/c90/fltctrl/switch/rudder_boost_dn", "Flight Control Rudder Boost Switch Down", C90_fltctrl_rudder_boost_switch_dn_CMDhandler)
C90CMD_fltctrl_elev_trim_control_switch			= create_command("laminar/c90/fltctrl/switch/elev_trim_control", "Flight Control Elevator Trim Control Switch Toggle", C90_fltctrl_elev_trim_control_switch_CMDhandler)
C90CMD_fltctrl_elev_trim_control_switch_up		= create_command("laminar/c90/fltctrl/switch/elev_trim_control_up", "Flight Control Elevator Trim Control Switch Up", C90_fltctrl_elev_trim_control_switch_up_CMDhandler)
C90CMD_fltctrl_elev_trim_control_switch_dn		= create_command("laminar/c90/fltctrl/switch/elev_trim_control_dn", "Flight Control Elevator Trim Control Switch Down", C90_fltctrl_elev_trim_control_switch_dn_CMDhandler)
C90CMD_cabin_alt_down		                    = create_command("laminar/c90/pressure/cabin_alt_down", "Cabin Pressure Dial Down", C90_cabin_alt_down_CMDhandler)
C90CMD_cabin_alt_up		                        = create_command("laminar/c90/pressure/cabin_alt_up", "Cabin Pressure Dial Up", C90_cabin_alt_up_CMDhandler)
C90CMD_avionics_audio_spkr_switch_pilot			= create_command("laminar/c90/avionics/switch/audio_spkr_switch_pilot", "Headset Audio Mode", C90_avionics_audio_spkr_switch_pilot_CMDhandler)--IBAV8N uses this in all models.
C90CMD_avionics_audio_spkr_reset			    = create_command("laminar/c90/avionics/switch/audio_spkr_reset", "Reset saved headset volumes to 1", C90_avionics_audio_spkr_reset_CMDhandler)

if simDR_acf_descrip == "C90B - G1000, Blackhawk" then
    print("EVO: 10. LOADING G1000 Command Handlers")
    C90CMD_g1000_backup_battery_toggle			    = create_command("laminar/c90/avionics/switch/g1000_backup_battery_toggle", "G1000 backup battery On/Off", C90_g1000_backup_battery_CMDhandler)
else
    -- AUDIO PANEL
    C90CMD_avionics_auto_comm_switch_pilot		    = create_command("laminar/c90/avionics/switch/autocomm_pilot", "Auto-Comm Switch (Pilot)", C90_avionics_auto_comm_switch_pilot_CMDhandler)
    C90CMD_avionics_com1_audio_switch_pilot		    = create_command("laminar/c90/avionics/switch/com1_audio_pilot", "COM1 Audio Switch (Pilot)", C90_avionics_com1_audio_switch_pilot_CMDhandler)
    C90CMD_avionics_com2_audio_switch_pilot		    = create_command("laminar/c90/avionics/switch/com2_audio_pilot", "COM2 Audio Switch (Pilot)", C90_avionics_com2_audio_switch_pilot_CMDhandler)
    C90CMD_avionics_audio_sel_com1_switch_pilot_up	= create_command("laminar/c90/avionics/switch/audio_sel_com1_pilot_up", "COM1 Audio Selector Switch (Pilot) Up", C90_avionics_audio_sel_com1_pilot_up_CMDhandler)
    C90CMD_avionics_audio_sel_com1_switch_pilot_dn	= create_command("laminar/c90/avionics/switch/audio_sel_com1_pilot_dn", "COM1 Audio Selector Switch (Pilot) Down", C90_avionics_audio_sel_com1_pilot_dn_CMDhandler)
    C90CMD_avionics_audio_sel_com2_switch_pilot_up	= create_command("laminar/c90/avionics/switch/audio_sel_com2_pilot_up", "COM2 Audio Selector Switch (Pilot) Up", C90_avionics_audio_sel_com2_pilot_up_CMDhandler)
    C90CMD_avionics_audio_sel_com2_switch_pilot_dn	= create_command("laminar/c90/avionics/switch/audio_sel_com2_pilot_dn", "Avionics COM2 Audio Selector Switch (Pilot) Down", C90_avionics_audio_sel_com2_pilot_dn_CMDhandler)
    C90CMD_avionics_audio_sel_nav1_switch_pilot_up	= create_command("laminar/c90/avionics/switch/audio_sel_nav1_pilot_up", "Avionics NAV1 Audio Selector Switch (Pilot) Up", C90_avionics_audio_sel_nav1_pilot_up_CMDhandler)
    C90CMD_avionics_audio_sel_nav1_switch_pilot_dn	= create_command("laminar/c90/avionics/switch/audio_sel_nav1_pilot_dn", "Avionics NAV1 Audio Selector Switch (Pilot) Down", C90_avionics_audio_sel_nav1_pilot_dn_CMDhandler)
    C90CMD_avionics_audio_sel_nav2_switch_pilot_up	= create_command("laminar/c90/avionics/switch/audio_sel_nav2_pilot_up", "Avionics NAV2 Audio Selector Switch (Pilot) Up", C90_avionics_audio_sel_nav2_pilot_up_CMDhandler)
    C90CMD_avionics_audio_sel_nav2_switch_pilot_dn	= create_command("laminar/c90/avionics/switch/audio_sel_nav2_pilot_dn", "Avionics NAV2 Audio Selector Switch (Pilot) Down", C90_avionics_audio_sel_nav2_pilot_dn_CMDhandler)
    C90CMD_avionics_mkr_bkn1_switch_pilot			= create_command("laminar/c90/avionics/switch/mkr_bkn1_switch_pilot", "Avionics Marker Beacon 1 Switch (Pilot)", C90_avionics_mkr_bkn1_switch_pilot_CMDhandler)
    C90CMD_avionics_mkr_bkn2_switch_pilot			= create_command("laminar/c90/avionics/switch/mkr_bkn2_switch_pilot", "Avionics Marker Beacon 2 Switch (Pilot)", C90_avionics_mkr_bkn2_switch_pilot_CMDhandler)
    C90CMD_avionics_audio_sel_adf1_switch_pilot_up	= create_command("laminar/c90/avionics/switch/audio_sel_adf1_pilot_up", "Avionics ADF1 Audio Selector Switch (Pilot) Up", C90_avionics_audio_sel_adf1_pilot_up_CMDhandler)
    C90CMD_avionics_audio_sel_adf1_switch_pilot_dn	= create_command("laminar/c90/avionics/switch/audio_sel_adf1_pilot_dn", "Avionics ADF1 Audio Selector Switch (Pilot) Down", C90_avionics_audio_sel_adf1_pilot_dn_CMDhandler)
    C90CMD_avionics_audio_sel_dme_switch_pilot_up	= create_command("laminar/c90/avionics/switch/audio_sel_dme_pilot_up", "Avionics DME Audio Selector Switch (Pilot) Up", C90_avionics_audio_sel_dme_pilot_up_CMDhandler)
    C90CMD_avionics_audio_sel_dme_switch_pilot_dn	= create_command("laminar/c90/avionics/switch/audio_sel_dme_pilot_dn", "Avionics DME Audio Selector Switch (Pilot) Down", C90_avionics_audio_sel_dme_pilot_dn_CMDhandler)
    C90CMD_avionics_audio_sel_mkr_switch_pilot_up	= create_command("laminar/c90/avionics/switch/audio_sel_mkr_pilot_up", "Avionics MKR Audio Selector Switch (Pilot) Up", C90_avionics_audio_sel_mkr_pilot_up_CMDhandler)
    C90CMD_avionics_audio_sel_mkr_switch_pilot_dn	= create_command("laminar/c90/avionics/switch/audio_sel_mkr_pilot_dn", "Avionics MKR Audio Selector Switch (Pilot) Down", C90_avionics_audio_sel_mkr_pilot_dn_CMDhandler)
    C90CMD_avionics_mic_sel_dial_up_pilot			= create_command("laminar/c90/avionics/dial/mic_sel_up_pilot", "Avionics Mic Selector Dial Up (Pilot)", C90_avionics_mmic_sel_dial_up_pilot_CMDhandler)
    C90CMD_avionics_mic_sel_dial_dn_pilot			= create_command("laminar/c90/avionics/dial/mic_sel_dn_pilot", "Avionics Mic Selector Dial Down (Pilot)", C90_avionics_mmic_sel_dial_dn_pilot_CMDhandler)
    C90CMD_avionics_audio_emer_norm_switch			= create_command("laminar/c90/avionics/switch/audio_emer_norm_switch", "Avionics Emergency/Norm Switch", C90_avionics_audio_emer_norm_switch_CMDhandler)
    C90CMD_avionics_voice_range_switch_up_pilot		= create_command("laminar/c90/avionics/switch/voice_range_switch_up_pilot", "Avionics Voice Range Switch Up (Pilot)", C90_avionics_voice_range_switch_up_pilot_CMDhandler)
    C90CMD_avionics_voice_range_switch_dn_pilot		= create_command("laminar/c90/avionics/switch/voice_range_switch_dn_pilot", "Avionics Voice Range Switch Down (Pilot)", C90_avionics_voice_range_switch_dn_pilot_CMDhandler)
    C90CMD_avionics_dme_channel_sel_switch			= create_command("laminar/c90/avionics/switch/dme_channel_selector", "Avionics DME Channel Selector Switch", C90_avionics_dme_channel_sel_switch_CMDhandler)
    C90CMD_avionics_encd_atim_sel_switch			= create_command("laminar/c90/avionics/switch/encd_altim_selector", "Avionics Encoding Altimeter Selector Switch", C90_avionics_encd_atim_sel_switch_CMDhandler)
    C90CMD_avionics_grd_pwr_comm_switch				= create_command("laminar/c90/avionics/switch/grd_pwr_comm", "Avionics Ground Power Communication Switch", C90_avionics_grd_pwr_comm_switch_CMDhandler)
    C90CMD_autopilot_altAlert_canx_switch			= create_command("laminar/c90/autopilot/switch/altAlert_canx", "Autopilot Altitude Alert Canx Switch", C90_autopilot_altAlert_canx_switch_CMDhandler)
    C90CMD_autopilot_altSel100_swtich				= create_command("laminar/c90/autopilot/switch/altSel100", "Autopilot Altitude Select 100 Switch", C90_autopilot_altSel100_switch_CMDhandler)
    C90CMD_avionics_com1_audio_switch_copilot		= create_command("laminar/c90/avionics/switch/com1_audio_copilot", "Avionics COM1 Audio Switch (CoPilot)", C90_avionics_com1_audio_switch_copilot_CMDhandler)
    C90CMD_avionics_com2_audio_switch_copilot		= create_command("laminar/c90/avionics/switch/com2_audio_copilot", "Avionics COM2 Audio Switch (CoPilot)", C90_avionics_com2_audio_switch_copilot_CMDhandler)
    C90CMD_avionics_nav1_audio_switch_copilot		= create_command("laminar/c90/avionics/switch/nav1_audio_copilot", "Avionics NAV1 Audio Switch (CoPilot)", C90_avionics_nav1_audio_switch_copilot_CMDhandler)
    C90CMD_avionics_nav2_audio_switch_copilot		= create_command("laminar/c90/avionics/switch/nav2_audio_copilot", "Avionics NAV2 Audio Switch (CoPilot)", C90_avionics_nav2_audio_switch_copilot_CMDhandler)
    C90CMD_avionics_mkr_bkn1_switch_copilot			= create_command("laminar/c90/avionics/switch/mkr_bkn1_copilot", "Avionics Marker Beacon 1 Switch (CoPilot)", C90_avionics_mkr_bkn1_switch_copilot_CMDhandler)
    C90CMD_avionics_mkr_bkn2_switch_copilot			= create_command("laminar/c90/avionics/switch/mkr_bkn2_copilot", "Avionics Marker Beacon 2 Switch (CoPilot)", C90_avionics_mkr_bkn2_switch_copilot_CMDhandler)
    C90CMD_avionics_dme_audio_switch_copilot		= create_command("laminar/c90/avionics/switch/dme_audio_copilot", "Avionics DME Audio Switch (CoPilot)", C90_avionics_dme_audio_switch_copilot_CMDhandler)
    C90CMD_avionics_adf1_audio_switch_copilot		= create_command("laminar/c90/avionics/switch/adf1_audio_copilot", "Avionics ADF1 Audio Switch (CoPilot)", C90_avionics_adf1_audio_switch_copilot_CMDhandler)
    C90CMD_avionics_auto_comm_switch_copilot		= create_command("laminar/c90/avionics/switch/auto_comm_switch_copilot", "Avionics Auto-Comm Switch (CoPilot)", C90_avionics_auto_comm_switch_copilot_CMDhandler)
    C90CMD_avionics_voice_range_switch_up_copilot	= create_command("laminar/c90/avionics/switch/voice_range_sw_up_copilot", "Avionics Voice Range Switch Up (CoPilot)", C90_avionics_voice_range_switch_up_copilot_CMDhandler)
    C90CMD_avionics_voice_range_switch_dn_copilot	= create_command("laminar/c90/avionics/switch/voice_range_sw_dn_copilot", "Avionics Voice Range Switch Down (CoPilot)", C90_avionics_voice_range_switch_dn_copilot_CMDhandler)
    C90CMD_avionics_hot_intph_switch				= create_command("laminar/c90/avionics/switch/hot_intph", "Avionics Hot Interphone Switch", C90_avionics_hot_intph_switch_CMDhandler)
    C90CMD_avionics_gps_power_switch		        = create_command("laminar/c90/avionics/switch/audio_spkr_switch_copilot", "GPS Power Switch", C90_avionics_gps_power_switch_CMDhandler)
    C90CMD_avionics_mic_sel_dial_up_copilot			= create_command("laminar/c90/avionics/dial/mic_sel_up_copilot", "Avionics Mic Selector Dial Up (CoPilot)", C90_avionics_mmic_sel_dial_up_copilot_CMDhandler)
    C90CMD_avionics_mic_sel_dial_dn_copilot			= create_command("laminar/c90/avionics/dial/mic_sel_dn_copilot", "Avionics Mic Selector Dial Down (CoPilot)", C90_avionics_mmic_sel_dial_dn_copilot_CMDhandler)
    C90CMD_avionics_mkr_bkn_sense_switch			= create_command("laminar/c90/avionics/switch/mkr_bkn_sense", "Avionics Marker Beacon Sense Switch", C90_avionics_mkr_bkn_sense_switch_CMDhandler)
    C90CMD_avionics_annun_brt		                = create_command("laminar/c90/avionics/dial/annun_brt", "Annunciator Brightness", C90_avionics_annun_brt_switch_CMDhandler)
    -- RADIO STACK GNS/GTN
    C90CMD_avionics_ctl62_adf_xfr_mem_up			= create_command("laminar/c90/avionics/ctl62_adf/xfr_mem_up", "Avionics ADF XFR/MEM Switch Up", C90_avionics_ctl62_adf_xfr_mem_up_CMDhandler)
    C90CMD_avionics_ctl62_adf_xfr_mem_dn			= create_command("laminar/c90/avionics/ctl62_adf/xfr_mem_dn", "Avionics ADF XFR/MEM Switch Down", C90_avionics_ctl62_adf_xfr_mem_dn_CMDhandler)
    C90CMD_avionics_ctl62_adf_sto_switch			= create_command("laminar/c90/avionics/switch/ctl62_adf/sto", "Avionics ADF STO Button Press", C90_avionics_ctl62_adf_sto_switch_CMDhandler)
    C90CMD_avionics_ctl62_adf_tst_switch			= create_command("laminar/c90/avionics/switch/ctl62_adf/tst", "Avionics ADF TST Button Press", C90_avionics_ctl62_adf_tst_switch_CMDhandler)
    C90CMD_avionics_ctl62_adf_act_switch			= create_command("laminar/c90/avionics/switch/ctl62_adf/act", "Avionics ADF ACT Button Press", C90_avionics_ctl62_adf_act_switch_CMDhandler)
    C90CMD_avionics_ctl62_adf_mode_up				= create_command("laminar/c90/avionics/ctl62_adf/mode_up", "Avionics ADF Mode Switch Up", C90_avionics_ctl62_adf_mode_up_CMDhandler)
    C90CMD_avionics_ctl62_adf_mode_dn				= create_command("laminar/c90/avionics/ctl62_adf/mode_dn", "Avionics ADF Mode Switch Down", C90_avionics_ctl62_adf_mode_dn_CMDhandler)
    C90CMD_avionics_ind42_power_switch				= create_command("laminar/c90/ind42/avionics/switch/power", "Avionics IND42 Power Switch", C90_avionics_ind42_power_switch_CMDhandler)
    C90CMD_avionics_ind42_mode_switch				= create_command("laminar/c90/ind42/avionics/switch/mode", "Avionics IND42 Mode Selector Switch", C90_avionics_ind42_mode_switch_CMDhandler)
    C90CMD_avionics_ind42_channel_switch			= create_command("laminar/c90/ind42/avionics/switch/channel", "Avionics IND42 Channel Selector Switch", C90_avionics_ind42_channel_switch_CMDhandler)
    -- DISPLAY SELECT PANEL
    C90CMD_avionics_decision_height_dial_up			= create_command("laminar/c90/avionics/dial/decision_height_up", "Avionics Decision height Dial Up", C90_avionics_decision_height_dial_up_CMDhandler)
    C90CMD_avionics_decision_height_dial_dn			= create_command("laminar/c90/avionics/dial/decision_height_dn", "Avionics Decision height Dial Down", C90_avionics_decision_height_dial_dn_CMDhandler)
    C90CMD_avionics_nav_data_sel_dial_up			= create_command("laminar/c90/avionics/dial/nav_data_sel_up", "Avionics Nav Data Selector Dial Up", C90_avionics_nav_data_sel_dial_up_CMDhandler)
    C90CMD_avionics_nav_data_sel_dial_dn			= create_command("laminar/c90/avionics/dial/nav_data_sel_dn", "Avionics Nav Data Selector Dial Down", C90_avionics_nav_data_sel_dial_dn_CMDhandler)
    C90CMD_avionics_brg_ptr1_sel_switch				= create_command("laminar/c90/avionics/switch/brg_ptr1_sel", "Avionics Bearing Pointer 1 Selector Switch", C90_avionics_brg_ptr1_sel_switch_CMDhandler)
    C90CMD_avionics_brg_ptr2_sel_switch				= create_command("laminar/c90/avionics/switch/brg_ptr2_sel", "Avionics Bearing Pointer 2 Selector Switch", C90_avionics_brg_ptr2_sel_switch_CMDhandler)
    C90CMD_avionics_crs_sel_switch					= create_command("laminar/c90/avionics/switch/crs_sel", "Avionics Course Selector Switch", C90_avionics_crs_sel_switch_CMDhandler)
    C90CMD_avionics_crs_sensor_sel_dial_up			= create_command("laminar/c90/avionics/dial/crs_sensor_sel_up", "Avionics Course Sensor Selector Dial Up", C90_avionics_crs_sensor_sel_dial_up_CMDhandler)
    C90CMD_avionics_crs_sensor_sel_dial_dn			= create_command("laminar/c90/avionics/dial/crs_sensor_sel_dn", "Avionics Course Sensor Selector Dial Down", C90_avionics_crs_sensor_sel_dial_dn_CMDhandler)
    C90CMD_avionics_crs_sync_sel_switch				= create_command("laminar/c90/avionics/switch/crs_sync_sel", "Avionics Course Sync Selector Switch", C90_avionics_crs_sync_sel_switch_CMDhandler)
    C90CMD_avionics_EFIS_map_mode_sel_dial_up		= create_command("laminar/c90/avionics/dial/EFIS_map_mode_sel_up", "Avionics EFIS Map Mode Selector Dial Up", C90_avionics_EFIS_map_mode_sel_dial_up_CMDhandler)
    C90CMD_avionics_EFIS_map_mode_sel_dial_dn		= create_command("laminar/c90/avionics/dial/EFIS_map_mode_sel_dn", "Avionics EFIS Map Mode Selector Dial Down", C90_avionics_EFIS_map_mode_sel_dial_dn_CMDhandler)
    C90CMD_avionics_EFIS_dh_test_switch				= create_command("laminar/c90/avionics/switch/EFIS_dh_test", "Avionics EFIS Decision Height Test Switch", C90_avionics_EFIS_dh_test_switch_CMDhandler)
    C90CMD_avionics_EFIS_timer_dial_up				= create_command("laminar/c90/avionics/dial/EFIS_timer_up", "Avionics EFIS Timer DIal Up", C90_avionics_EFIS_timer_dial_up_CMDhandler)
    C90CMD_avionics_EFIS_timer_dial_dn				= create_command("laminar/c90/avionics/dial/EFIS_timer_dn", "Avionics EFIS Timer DIal Down", C90_avionics_EFIS_timer_dial_dn_CMDhandler)
    C90CMD_avionics_EFIS_timer_ss_switch			= create_command("laminar/c90/avionics/switch/EFIS_ss", "Avionics EFIS Timer Start/Stop Switch", C90_avionics_EFIS_timer_ss_switch_CMDhandler)
    -- AUTOPILOT PANEL
    C90CMD_autopilot_test_switch					= create_command("laminar/c90/autopilot/switch/test", "Autopilot Test Switch", C90_autopilot_test_switch_CMDhandler)
    -- LEFT BOTTOM PEDESTAL
    C90CMD_avionics_EFIS_fd_switch					= create_command("laminar/c90/avionics/switch/fd", "Avionics EFIS Flight Director ON/OFF Switch Toggle", C90_avionics_fd_switch_CMDhandler)
    C90CMD_avionics_EFIS_fd_switch_up				= create_command("laminar/c90/avionics/switch/fd_up", "Avionics EFIS Flight Director ON/OFF Switch Up", C90_avionics_fd_switch_up_CMDhandler)
    C90CMD_avionics_EFIS_fd_switch_dn				= create_command("laminar/c90/avionics/switch/fd_dn", "Avionics EFIS Flight Director ON/OFF Switch Down", C90_avionics_fd_switch_dn_CMDhandler)
    -- RIGHT PEDESTAL
    C90CMD_avionics_EFIS_power_switch				= create_command("laminar/c90/avionics/switch/EFIS_power", "Avionics EFIS Power Switch Toggle", C90_avionics_EFIS_power_switch_CMDhandler)
    C90CMD_avionics_EFIS_power_switch_up			= create_command("laminar/c90/avionics/switch/EFIS_power_up", "Avionics EFIS Power Switch Up", C90_avionics_EFIS_power_switch_up_CMDhandler)
    C90CMD_avionics_EFIS_power_switch_dn			= create_command("laminar/c90/avionics/switch/EFIS_power_dn", "Avionics EFIS Power Switch Down", C90_avionics_EFIS_power_switch_dn_CMDhandler)
    C90CMD_avionics_EFIS_rev_mode_switch			= create_command("laminar/c90/avionics/switch/EFIS_rev_mode", "Avionics EFIS Reversionary Mode Switch Toggle", C90_avionics_EFIS_rev_mode_switch_CMDhandler)
    C90CMD_avionics_EFIS_rev_mode_switch_up			= create_command("laminar/c90/avionics/switch/EFIS_rev_mode_up", "Avionics EFIS Reversionary Mode Switch Up", C90_avionics_EFIS_rev_mode_switch_up_CMDhandler)
    C90CMD_avionics_EFIS_rev_mode_switch_dn			= create_command("laminar/c90/avionics/switch/EFIS_rev_mode_dn", "Avionics EFIS Reversionary Mode Switch Down", C90_avionics_EFIS_rev_mode_switch_dn_CMDhandler)
    C90CMD_avionics_EFIS_test_switch				= create_command("laminar/c90/avionics/switch/EFIS_test", "Avionics EFIS Test Switch", C90_avionics_EFIS_test_switch_CMDhandler)
    if simDR_acf_descrip == "C90B EVO GNS" then
        print("EVO: 10. LOADING GNS Command Handlers")
        -- RADIO STACK GNS
        C90CMD_avionics_g430n1_com_vol_up               = create_command("laminar/c90/avionics/g430n1/com_vol_up", "Avionics G530 Power/Volume Up", C90_avionics_g430n1_com_vol_up_CMDhandler)
        C90CMD_avionics_g430n1_com_vol_down             = create_command("laminar/c90/avionics/g430n1/com_vol_down", "Avionics G530 Power/Volume Down", C90_avionics_g430n1_com_vol_down_CMDhandler)
        C90CMD_avionics_g430n1_vloc_vol_up	            = create_command("laminar/c90/avionics/g430n1/vloc_vol_up", "Avionics G530 VLOC Volume Up", C90_avionics_g430n1_vloc_vol_up_CMDhandler)
        C90CMD_avionics_g430n1_vloc_vol_down	        = create_command("laminar/c90/avionics/g430n1/vloc_vol_down", "Avionics G530 VLOC Volume Down", C90_avionics_g430n1_vloc_vol_down_CMDhandler)
        C90CMD_avionics_g430n2_com_vol_up               = create_command("laminar/c90/avionics/g430n2/com_vol_up", "Avionics G430 Power/Volume Up", C90_avionics_g430n2_com_vol_up_CMDhandler)
        C90CMD_avionics_g430n2_com_vol_down             = create_command("laminar/c90/avionics/g430n2/com_vol_down", "Avionics G430 Power/Volume Down", C90_avionics_g430n2_com_vol_down_CMDhandler)
        C90CMD_avionics_g430n2_vloc_vol_up	            = create_command("laminar/c90/avionics/g430n2/vloc_vol_up", "Avionics G430 VLOC Volume Up", C90_avionics_g430n2_vloc_vol_up_CMDhandler)
        C90CMD_avionics_g430n2_vloc_vol_down	        = create_command("laminar/c90/avionics/g430n2/vloc_vol_down", "Avionics G430 VLOC Volume Down", C90_avionics_g430n2_vloc_vol_down_CMDhandler)
        C90CMD_avionics_ctl22_com1_xfr_mem_up			= create_command("laminar/c90/avionics/ctl22_com1/xfr_mem_up", "Avionics COM1 XFR/MEM Switch Up", C90_avionics_ctl22_com1_xfr_mem_up_CMDhandler)
        C90CMD_avionics_ctl22_com1_xfr_mem_dn			= create_command("laminar/c90/avionics/ctl22_com1/xfr_mem_dn", "Avionics COM1 XFR/MEM Switch Down", C90_avionics_ctl22_com1_xfr_mem_dn_CMDhandler)
        C90CMD_avionics_ctl22_com1_sto_switch			= create_command("laminar/c90/avionics/switch/ctl22_com1/sto", "Avionics COM1 MEM Button Press", C90_avionics_ctl22_com1_sto_switch_CMDhandler)
        C90CMD_avionics_ctl22_com1_tst_switch			= create_command("laminar/c90/avionics/switch/ctl22_com1/tst", "Avionics COM1 TST Button Press", C90_avionics_ctl22_com1_tst_switch_CMDhandler)
        C90CMD_avionics_ctl22_com1_act_switch			= create_command("laminar/c90/avionics/switch/ctl22_com1/act", "Avionics COM1 ACT Button Press", C90_avionics_ctl22_com1_act_switch_CMDhandler)
        C90CMD_avionics_ctl22_com2_xfr_mem_up			= create_command("laminar/c90/avionics/ctl22_com2/xfr_mem_up", "Avionics COM2 XFR/MEM Switch Up", C90_avionics_ctl22_com2_xfr_mem_up_CMDhandler)
        C90CMD_avionics_ctl22_com2_xfr_mem_dn			= create_command("laminar/c90/avionics/ctl22_com2/xfr_mem_dn", "Avionics COM2 XFR/MEM Switch Down", C90_avionics_ctl22_com2_xfr_mem_dn_CMDhandler)
        C90CMD_avionics_ctl22_com2_sto_switch			= create_command("laminar/c90/avionics/switch/ctl22_com2/sto", "Avionics COM2 STO Button Press", C90_avionics_ctl22_com2_sto_switch_CMDhandler)
        C90CMD_avionics_ctl22_com2_tst_switch			= create_command("laminar/c90/avionics/switch/ctl22_com2/tst", "Avionics COM2 TST Button Press", C90_avionics_ctl22_com2_tst_switch_CMDhandler)
        C90CMD_avionics_ctl22_com2_act_switch			= create_command("laminar/c90/avionics/switch/ctl22_com2/act", "Avionics COM2 ACT Button Press", C90_avionics_ctl22_com2_act_switch_CMDhandler)
        C90CMD_avionics_ctl32_nav1_xfr_mem_up			= create_command("laminar/c90/avionics/ctl32_nav1/xfr_mem_up", "Avionics NAV1 XFR/MEM Switch Up", C90_avionics_ctl32_nav1_xfr_mem_up_CMDhandler)
        C90CMD_avionics_ctl32_nav1_xfr_mem_dn			= create_command("laminar/c90/avionics/ctl32_nav1/xfr_mem_dn", "Avionics NAV1 XFR/MEM Switch Down", C90_avionics_ctl32_nav1_xfr_mem_dn_CMDhandler)
        C90CMD_avionics_ctl32_nav1_sto_switch			= create_command("laminar/c90/avionics/switch/ctl32_nav1/sto", "Avionics NAV1 STO Button Press", C90_avionics_ctl32_nav1_sto_switch_CMDhandler)
        C90CMD_avionics_ctl32_nav1_tst_switch			= create_command("laminar/c90/avionics/switch/ctl32_nav1/tst", "Avionics NAV1 TST Button Press", C90_avionics_ctl32_nav1_tst_switch_CMDhandler)
        C90CMD_avionics_ctl32_nav1_act_switch			= create_command("laminar/c90/avionics/switch/ctl32_nav1/act", "Avionics NAV1 ACT Button Press", C90_avionics_ctl32_nav1_act_switch_CMDhandler)
        C90CMD_avionics_ctl32_nav2_xfr_mem_up			= create_command("laminar/c90/avionics/ctl32_nav2/xfr_mem_up", "Avionics NAV2 XFR/MEM Switch Up", C90_avionics_ctl32_nav2_xfr_mem_up_CMDhandler)
        C90CMD_avionics_ctl32_nav2_xfr_mem_dn			= create_command("laminar/c90/avionics/ctl32_nav2/xfr_mem_dn", "Avionics NAV2 XFR/MEM Switch Down", C90_avionics_ctl32_nav2_xfr_mem_dn_CMDhandler)
        C90CMD_avionics_ctl32_nav2_sto_switch			= create_command("laminar/c90/avionics/switch/ctl32_nav2/sto", "Avionics NAV2 STO Button Press", C90_avionics_ctl32_nav2_sto_switch_CMDhandler)
        C90CMD_avionics_ctl32_nav2_tst_switch			= create_command("laminar/c90/avionics/switch/ctl32_nav2/tst", "Avionics NAV2 TST Button Press", C90_avionics_ctl32_nav2_tst_switch_CMDhandler)
        C90CMD_avionics_ctl32_nav2_act_switch			= create_command("laminar/c90/avionics/switch/ctl32_nav2/act", "Avionics NAV2 ACT Button Press", C90_avionics_ctl32_nav2_act_switch_CMDhandler)
        C90CMD_avionics_ctl92_xpdr_mode_up				= create_command("laminar/c90/avionics/ctl92_xpdr/mode_up", "Avionics Transponder Mode Switch Up", C90_avionics_ctl92_xpdr_mode_up_CMDhandler)
        C90CMD_avionics_ctl92_xpdr_mode_dn				= create_command("laminar/c90/avionics/ctl92_xpdr/mode_dn", "Avionics Transponder Mode Switch Down", C90_avionics_ctl92_xpdr_mode_dn_CMDhandler)
        C90CMD_avionics_ctl92_xpdr_tst_switch			= create_command("laminar/c90/avionics/switch/ctl92_atc/tst", "Avionics Transponder TST Button Press", C90_avionics_ctl92_xpdr_tst_switch_CMDhandler)
        C90CMD_avionics_ctl92_xpdr_pre_switch			= create_command("laminar/c90/avionics/switch/ctl92_atc/pre", "Avionics Transponder PRE Button Press", C90_avionics_ctl92_xpdr_pre_switch_CMDhandler)
        -- COPILOT'S PANEL
        C90CMD_crossfill_switch_on					    = create_command("laminar/c90/avionics/dial/crossfill_on", "GPS Crossfill On", C90_avionics_crossfill_on_CMDhandler)
        C90CMD_crossfill_switch_off					    = create_command("laminar/c90/avionics/dial/crossfill_off", "GPS Crossfill Off", C90_avionics_crossfill_off_CMDhandler)
    end
--[[
    -- RADIO STACK GTN
    if simDR_acf_descrip == "C90B EVO GTN" then
        print("EVO: 10. LOADING GTN Command Handlers")
        C90CMD_avionics_gtn_sd_card_pos_1 = create_command("jp_evo/gtn/sd_card_pos_1", "SD Card Insert/Remove", C90_avionics_gtn_sd_card_pos_1_CMDHandler) -- @pilotmarcog animate SD Card insert/remove
        C90CMD_avionics_gtn_sd_card_pos_2 = create_command("jp_evo/gtn/sd_card_pos_2", "SD Card Insert/Remove", C90_avionics_gtn_sd_card_pos_2_CMDHandler)
    end
--]]
end



--*************************************************************************************--
--** 				       REPLACE X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--
print("EVO: 11. LOADING X-Plane Command Handlers")
function sim_firewall_lft_open_CMDhandler(phase, duration)  		    --IBAV8N, Apr22-21
    if phase == 0 then
        simDR_fuel_firewall_vlv_L = 0
    end
end

function sim_firewall_rgt_open_CMDhandler(phase, duration)  		    --IBAV8N, Apr22-21
    if phase == 0 then
        simDR_fuel_firewall_vlv_R = 0
    end
end

function sim_firewall_lft_closed_CMDhandler(phase, duration)  		    --IBAV8N, Apr22-21
    if phase == 0 then
        simDR_fuel_firewall_vlv_L = 1
    end
end

function sim_firewall_rgt_closed_CMDhandler(phase, duration)  		    --IBAV8N, Apr22-21
    if phase == 0 then
        simDR_fuel_firewall_vlv_R = 1
    end
end

function sim_wipers_up_CMDhandler(phase, duration)
    if phase == 0  then
        C90DR_wiper_knob_pos = math.min(2, C90DR_wiper_knob_pos + 1)
    end
end

function sim_wipers_dn_CMDhandler(phase, duration)
    if phase == 0  then
        C90DR_wiper_knob_pos = math.max(-1, C90DR_wiper_knob_pos - 1)
    elseif phase == 2 then
        if C90DR_wiper_knob_pos < 0 then
            C90DR_wiper_knob_pos = 0
        end
    end
end

function sim_landing_gear_down_CMDhandler(phase,duration)               --IBAV8N, May25-21
	if phase == 0 then
		C90DR_gear_handle = 1
		C90_gear_handle_DRhandler()
	end
end

function sim_landing_gear_up_CMDhandler(phase,duration)                 --IBAV8N, May25-21
	if phase == 0 then
		C90DR_gear_handle = 0
		C90_gear_handle_DRhandler()
	end
end

function sim_landing_gear_toggle_CMDhandler(phase,duration)             --IBAV8N, May25-21
	if phase == 0 then
		C90DR_gear_handle = 1 - C90DR_gear_handle
		C90_gear_handle_DRhandler()
	end
end

function sim_gear_warning_mute_CMDhandler(phase,duration)
	if phase == 0 then
        C90.gear_warn_muted = 1
    end
end

function sim_adf_mode4_CMDhandler(phase,duration) end

function C90_autopilot_alt_sel_up_CMDhandler(phase,duration)
	if phase == 0 then
		if C90DR_autopilot_altSel100_switch_pos == 0 then
			simDR_autopilot_alt_dial_ft = math.min(49900, simDR_autopilot_alt_dial_ft + 1000)
		elseif C90DR_autopilot_altSel100_switch_pos == 1 then
			simDR_autopilot_alt_dial_ft = math.min(49900, simDR_autopilot_alt_dial_ft + 100)
		end
		if math.fmod(simDR_autopilot_alt_dial_ft, 100) ~= 0 then
			C90_rndToIncr(simDR_autopilot_alt_dial_ft, 100)
		end
		C90.pre80.mode = 1			-- ACQUISTION ARMED MODE
	end
end

function C90_autopilot_alt_sel_dn_CMDhandler(phase,duration)
	if phase == 0 then
		if C90DR_autopilot_altSel100_switch_pos == 0 then
			simDR_autopilot_alt_dial_ft = math.max(0, simDR_autopilot_alt_dial_ft - 1000)
		elseif C90DR_autopilot_altSel100_switch_pos == 1 then
			simDR_autopilot_alt_dial_ft = math.max(0, simDR_autopilot_alt_dial_ft - 100)
		end
		if math.fmod(simDR_autopilot_alt_dial_ft, 100) ~= 0 then
			C90_rndToIncr(simDR_autopilot_alt_dial_ft, 100)
		end
		C90.pre80.mode = 1			-- ACQUISTION ARMED MODE
	end
end

--*************************************************************************************--
--** 				            REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--
simCMD_fuel_firewall_vlv_open_L		= replace_command("sim/fuel/fuel_firewall_valve_lft_open", sim_firewall_lft_open_CMDhandler)  		    --IBAV8N, Apr22-21
simCMD_fuel_firewall_vlv_open_R		= replace_command("sim/fuel/fuel_firewall_valve_rgt_open", sim_firewall_rgt_open_CMDhandler)  		    --IBAV8N, Apr22-21
simCMD_fuel_firewall_vlv_closed_L   = replace_command("sim/fuel/fuel_firewall_valve_lft_closed", sim_firewall_lft_closed_CMDhandler)  		--IBAV8N, Apr22-21
simCMD_fuel_firewall_vlv_closed_R   = replace_command("sim/fuel/fuel_firewall_valve_rgt_closed", sim_firewall_rgt_closed_CMDhandler)  		--IBAV8N, Apr22-21
simCMD_wipers_up				    = replace_command("sim/systems/wipers_up", sim_wipers_up_CMDhandler)  		                            --IBAV8N, Apr18-21
simCMD_wipers_dn				    = replace_command("sim/systems/wipers_dn", sim_wipers_dn_CMDhandler)  		                            --IBAV8N, Apr18-21
simCMD_landing_gear_down		    = replace_command("sim/flight_controls/landing_gear_down", sim_landing_gear_down_CMDhandler)
simCMD_landing_gear_up			    = replace_command("sim/flight_controls/landing_gear_up", sim_landing_gear_up_CMDhandler)
simCMD_landing_gear_toggle		    = replace_command("sim/flight_controls/landing_gear_toggle", sim_landing_gear_toggle_CMDhandler)
simCMD_gear_warning_mute		    = replace_command("sim/annunciator/gear_warning_mute", sim_gear_warning_mute_CMDhandler)
if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
    simCMD_obs_HSI_up				    = replace_command("sim/radios/obs_HSI_up", sim_obs_HSI_up_CMDhandler)  		                        --IBAV8N, Apr2-21
    simCMD_obs_HSI_down				    = replace_command("sim/radios/obs_HSI_down", sim_obs_HSI_down_CMDhandler)	                        --IBAV8N, Apr2-21
    simCMD_copilot_obs_HSI_up		    = replace_command("sim/radios/copilot_obs_HSI_up", sim_copilot_obs_HSI_up_CMDhandler)  		        --IBAV8N, Apr24-21
    simCMD_copilot_obs_HSI_down		    = replace_command("sim/radios/copilot_obs_HSI_down", sim_copilot_obs_HSI_down_CMDhandler)  		    --IBAV8N, Apr24-21
    simCMD_adf1_down				    = replace_command("sim/radios/power_adf1_dn", C90_avionics_ctl62_adf_mode_dn_CMDhandler)
    simCMD_adf1_up					    = replace_command("sim/radios/power_adf1_up", C90_avionics_ctl62_adf_mode_up_CMDhandler)
    simCMD_adf_mode4 				    = replace_command("sim/radios/adf1_power_mode_4", sim_adf_mode4_CMDhandler)
    simCMD_ap_alt_sel_up			    = replace_command("sim/autopilot/altitude_up", C90_autopilot_alt_sel_up_CMDhandler)
    simCMD_ap_alt_sel_dn			    = replace_command("sim/autopilot/altitude_down", C90_autopilot_alt_sel_dn_CMDhandler)
end
if simDR_acf_descrip == "C90B EVO GNS" then
    simCMD_transponder_mode_up	    = replace_command("sim/transponder/transponder_up", C90_avionics_ctl92_xpdr_mode_up_CMDhandler)
    simCMD_transponder_mode_dn	    = replace_command("sim/transponder/transponder_dn", C90_avionics_ctl92_xpdr_mode_dn_CMDhandler)
end

--*************************************************************************************--
--** 				          X-PLANE WRAP COMMAND HANDLERS                 	  	 **--
--*************************************************************************************--
function empty_CMDhandlerBefore(phase, duration) end

function empty_CMDhandlerAfter(phase, duration) end

function sim_clear_master_warning_CMDhandlerAfter(phase, duration)
    C90DR_switch_pos_master_warning = C90_ternary(phase == 2, 0, 1)
end

function sim_clear_master_caution_CMDhandlerAfter(phase, duration)
    C90DR_switch_pos_master_caution = C90_ternary(phase == 2, 0, 1)
end

function sim_free_gyro_up_CMDhandlerAfter(phase, duration)
    C90DR_fltInst_ccu65_slew_switch_pos_up = C90_ternary(phase == 2, 0, 1)
end

function sim_free_gyro_dn_CMDhandlerAfter(phase, duration)
    C90DR_fltInst_ccu65_slew_switch_pos_dn = C90_ternary(phase == 2, 0, 1)
end

function sim_autopilot_HDG_CMDhandlerAfter(phase, duration)
    C90DR_autopilot_HDG_switch_pos = C90_ternary(phase == 2, 0, 1)
end

function sim_autopilot_NAV_CMDhandlerAfter(phase, duration)
    C90DR_autopilot_NAV_switch_pos = C90_ternary(phase == 2, 0, 1)
end

function sim_autopilot_APPR_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_APPR_switch_pos = 1
		C90DR_autopilot_DSC_status = 0
        if simDR_autopilot_soft_ride > 0 then   --IBAV8N,Feb27-21, disable SR and 1/2 bank when APPR is pressed
            simCMD_autopilot_soft_ride:once()
        end
        if simDR_autopilot_half_bank > 0 then
            simCMD_autopilot_half_bank:once()
        end
	elseif phase == 2 then
		C90DR_autopilot_APPR_switch_pos = 0
	end
end

function sim_autopilot_BC_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_BC_switch_pos = 1
		C90DR_autopilot_DSC_status = 0
	elseif phase == 2 then
		C90DR_autopilot_BC_switch_pos = 0
	end
end

function sim_autopilot_ALT_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_ALT_switch_pos = 1
		C90DR_autopilot_DSC_status = 0
	elseif phase == 2 then
		C90DR_autopilot_ALT_switch_pos = 0
	end
end

function sim_autopilot_ALTSEL_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_ALTSEL_switch_pos = 1
	elseif phase == 2 then
		C90DR_autopilot_ALTSEL_switch_pos = 0
	end
end

function sim_autopilot_VS_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_VS_switch_pos = 1
		C90DR_autopilot_DSC_status = 0
	elseif phase == 2 then
		C90DR_autopilot_VS_switch_pos = 0
	end
end

function sim_autopilot_IAS_CMDhandlerBefore(phase, duration)
	simDR_autopilot_airspeed_dial_kts = math.max(101, simDR_airspeed)
end

function sim_autopilot_IAS_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_IAS_switch_pos = 1
		C90DR_autopilot_DSC_status = 0
	elseif phase == 2 then
		C90DR_autopilot_IAS_switch_pos = 0
	end
end

function sim_autopilot_yaw_damper_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_yaw_damper_switch_pos = 1
	elseif phase == 2 then
		C90DR_autopilot_yaw_damper_switch_pos = 0
	end
end

function sim_autopilot_engage_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_engage_switch_pos = 1
	elseif phase == 2 then
		C90DR_autopilot_engage_switch_pos = 0
		C90DR_autopilot_DSC_status = 0
	end
end

function sim_autopilot_soft_ride_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_soft_ride_switch_pos = 1
	elseif phase == 2 then
		C90DR_autopilot_soft_ride_switch_pos = 0
	end
end

function sim_autopilot_half_bank_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_autopilot_half_bank_switch_pos = 1
	elseif phase == 2 then
		C90DR_autopilot_half_bank_switch_pos = 0
	end
end

function sim_pressure_vvi_downCMDhandlerAfter(phase, duration)
	if phase == 0 then
		if simDR_pressure_cabin_vvi_fpm < 200 then simDR_pressure_cabin_vvi_fpm = 200 end
	end
end

function sim_pressure_vvi_upCMDhandlerAfter(phase, duration)
	if phase == 0 then
		if simDR_pressure_cabin_vvi_fpm > 2000 then simDR_pressure_cabin_vvi_fpm = 2000 end
	end
end

function sim_adf1_ones_tens_up_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl62_adf_ones_tens_dial_pos = C90DR_avionics_ctl62_adf_ones_tens_dial_pos + 10
		if C90DR_avionics_ctl62_adf_ones_tens_dial_pos > 360 then C90DR_avionics_ctl62_adf_ones_tens_dial_pos = 1 end
	end
end

function sim_adf1_ones_tens_dn_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl62_adf_ones_tens_dial_pos = C90DR_avionics_ctl62_adf_ones_tens_dial_pos - 10
		if C90DR_avionics_ctl62_adf_ones_tens_dial_pos < 0 then C90DR_avionics_ctl62_adf_ones_tens_dial_pos = 360 end
	end
end

function sim_adf1_hund_thous_up_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl62_adf_hund_thous_dial_pos = C90DR_avionics_ctl62_adf_hund_thous_dial_pos + 10
		if C90DR_avionics_ctl62_adf_hund_thous_dial_pos > 360 then C90DR_avionics_ctl62_adf_hund_thous_dial_pos = 1 end
	end
end

function sim_adf1_hund_thous_dn_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl62_adf_hund_thous_dial_pos = C90DR_avionics_ctl62_adf_hund_thous_dial_pos - 10
		if C90DR_avionics_ctl62_adf_hund_thous_dial_pos < 0 then C90DR_avionics_ctl62_adf_hund_thous_dial_pos = 360 end
	end
end

function sim_g430n1_coarse_up_CMDhandlerBefore(phase, duration)         --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n1_com1 = simDR_com1_stby_frequency
    g430n1_nav1 = simDR_nav1_stby_frequency
    g430n1_navcom_rmt = 1
    if C90DR_avionics_g430n1_dial_com_mega == 1 then
        C90DR_avionics_g430n1_dial_com_mega = 0
    end
end

function sim_g430n1_coarse_up_CMDhandlerAfter(phase, duration)          --IBAV8N, Sep27-22, employs RMT led in radio head
    if gps530_power == 0 then
        simDR_com1_stby_frequency = g430n1_com1
        simDR_nav1_stby_frequency = g430n1_nav1
    end
    if phase == 0 then
        C90DR_avionics_g430n1_dial_com_mega = math.min(1, C90DR_avionics_g430n1_dial_com_mega + 0.1)
    elseif phase == 2 then
        run_after_time(g430n1_navcom_rmt_kill, 0.33)
    end
end

function sim_g430n1_coarse_down_CMDhandlerBefore(phase, duration)         --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n1_com1 = simDR_com1_stby_frequency
    g430n1_nav1 = simDR_nav1_stby_frequency
    g430n1_navcom_rmt = 1
    if C90DR_avionics_g430n1_dial_com_mega == 0 then
        C90DR_avionics_g430n1_dial_com_mega = 1
    end
end

function sim_g430n1_coarse_down_CMDhandlerAfter(phase, duration)         --IBAV8N, Sep27-22, employs RMT led in radio head
    if gps530_power == 0 then
        simDR_com1_stby_frequency = g430n1_com1
        simDR_nav1_stby_frequency = g430n1_nav1
    end
    if phase == 0 then
        C90DR_avionics_g430n1_dial_com_mega = math.max(0, C90DR_avionics_g430n1_dial_com_mega - 0.1)
    elseif phase == 2 then
        run_after_time(g430n1_navcom_rmt_kill, 0.33)
    end
end

function sim_g430n1_fine_up_CMDhandlerBefore(phase, duration)           --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n1_com1 = simDR_com1_stby_frequency
    g430n1_nav1 = simDR_nav1_stby_frequency
    g430n1_navcom_rmt = 1
    if C90DR_avionics_g430n1_dial_com_kilo == 1 then
        C90DR_avionics_g430n1_dial_com_kilo = 0
    end
end

function sim_g430n1_fine_up_CMDhandlerAfter(phase, duration)            --IBAV8N, Sep27-22, employs RMT led in radio head
    if gps530_power == 0 then
        simDR_com1_stby_frequency = g430n1_com1
        simDR_nav1_stby_frequency = g430n1_nav1
    end
    if phase == 0 then
        C90DR_avionics_g430n1_dial_com_kilo = math.min(1, C90DR_avionics_g430n1_dial_com_kilo + 0.1)
    elseif phase == 2 then
        run_after_time(g430n1_navcom_rmt_kill, 0.33)
    end
end

function sim_g430n1_fine_down_CMDhandlerBefore(phase, duration)         --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n1_com1 = simDR_com1_stby_frequency
    g430n1_nav1 = simDR_nav1_stby_frequency
    g430n1_navcom_rmt = 1
    if C90DR_avionics_g430n1_dial_com_kilo == 0 then
        C90DR_avionics_g430n1_dial_com_kilo = 1
    end
end

function sim_g430n1_fine_down_CMDhandlerAfter(phase, duration)          --IBAV8N, Sep27-22, employs RMT led in radio head
    if gps530_power == 0 then
        simDR_com1_stby_frequency = g430n1_com1
        simDR_nav1_stby_frequency = g430n1_nav1
    end
    if phase == 0 then
        C90DR_avionics_g430n1_dial_com_kilo = math.max(0, C90DR_avionics_g430n1_dial_com_kilo - 0.1)
    elseif phase == 2 then
        run_after_time(g430n1_navcom_rmt_kill, 0.33)
    end
end

function g430n1_navcom_rmt_kill()               --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n1_navcom_rmt = 0
end

function sim_g430n1_chapter_up_CMDhandlerBefore(phase, duration)
    if C90DR_avionics_g430n1_dial_chapter == 1 then
        C90DR_avionics_g430n1_dial_chapter = 0
    end
end

function sim_g430n1_chapter_up_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n1_dial_chapter = math.min(1, C90DR_avionics_g430n1_dial_chapter + 0.1)
    end
end

function sim_g430n1_chapter_dn_CMDhandlerBefore(phase, duration)
    if C90DR_avionics_g430n1_dial_chapter == 0 then
        C90DR_avionics_g430n1_dial_chapter = 1
    end
end

function sim_g430n1_chapter_dn_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n1_dial_chapter = math.max(0, C90DR_avionics_g430n1_dial_chapter - 0.1)
    end
end

function sim_g430n1_page_up_CMDhandlerBefore(phase, duration)
    if C90DR_avionics_g430n1_dial_page == 1 then
        C90DR_avionics_g430n1_dial_page = 0
    end
end

function sim_g430n1_page_up_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n1_dial_page = math.min(1, C90DR_avionics_g430n1_dial_page + 0.1)
    end
end

function sim_g430n1_page_dn_CMDhandlerBefore(phase, duration)
    if C90DR_avionics_g430n1_dial_page == 0 then
        C90DR_avionics_g430n1_dial_page = 1
    end
end

function sim_g430n1_page_dn_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n1_dial_page = math.max(0, C90DR_avionics_g430n1_dial_page - 0.1)
    end
end

function sim_g430n1_com_ff_CMDhandlerBefore(phase, duration)
    g430n1_ff_com_rmt = 1
    g430n1_com_ff = simDR_com1_frequency
    g430n1_com_ff_stby = simDR_com1_stby_frequency
end

function sim_g430n1_com_ff_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_com_toggle = C90_ternary(phase == 2, 0, 1)
    if gps530_power == 0 then
        simDR_com1_frequency = g430n1_com_ff
        simDR_com1_stby_frequency = g430n1_com_ff_stby
    end
    if phase == 2 then
        g430n1_ff_com_rmt = 0
    end
end

function sim_g430n1_nav_ff_CMDhandlerBefore(phase, duration)
    g430n1_ff_nav_rmt = 1
    g430n1_nav_ff = simDR_nav1_frequency
    g430n1_nav_ff_stby = simDR_nav1_stby_frequency
end

function sim_g430n1_nav_ff_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_vloc_toggle = C90_ternary(phase == 2, 0, 1)
    if gps530_power == 0 then
        simDR_nav1_frequency = g430n1_nav_ff
        simDR_nav1_stby_frequency = g430n1_nav_ff_stby
    end
    if phase == 2 then
        C90DR_avionics_g430n1_switch_pos_vloc_toggle = 0
        g430n1_ff_nav_rmt = 0
    end
end

function sim_g430n1_nav_com_tog_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_com_push = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_cdi_CMDhandlerBefore(phase, duration)                                                   --IBAV8N, Jan22-22
    g430n1_cdi = simDR_hsi_source_sel_pilot
end

function sim_g430n1_cdi_CMDhandlerAfter(phase, duration)                                                    --IBAV8N, Jan22-22, when GNS CDI button is pressed
    C90DR_avionics_g430n1_switch_pos_cdi = C90_ternary(phase == 2, 0, 1)
    if gps530_power == 0 then
        simDR_hsi_source_sel_pilot = g430n1_cdi
    end
    if simDR_hsi_source_sel_pilot == 2 then                                                                 --if already using GPS as source
        C90DR_avionics_cur_crs_sel_index = 3                                                                --set course to GPS
    else  C90DR_avionics_cur_crs_sel_index = 0                                                              --otherwise revert to the radio selection
    end
end

function sim_g430n1_obs_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_obs = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_msg_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_msg = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_fpl_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_fpl = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_vnav_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_vnav = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_proc_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_proc = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_zoom_out_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_rng_down = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_zoom_in_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_rng_up = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_direct_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_dir = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_menu_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_menu = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_clr_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_clr = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_ent_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_ent = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n1_cursor_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n1_switch_pos_gps_push = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_coarse_up_CMDhandlerBefore(phase, duration)
        g430n2_com2 = simDR_com2_stby_frequency
        g430n2_nav2 = simDR_nav2_stby_frequency
        g430n2_navcom_rmt = 1
    if C90DR_avionics_g430n2_dial_com_mega == 1 then
        C90DR_avionics_g430n2_dial_com_mega = 0
    end
end

function sim_g430n2_coarse_up_CMDhandlerAfter(phase, duration)
    if gps430_power == 0 then
        simDR_com2_stby_frequency = g430n2_com2
        simDR_nav2_stby_frequency = g430n2_nav2
    end
    if phase == 0 then
        C90DR_avionics_g430n2_dial_com_mega = math.min(1, C90DR_avionics_g430n2_dial_com_mega + 0.1)
    elseif phase == 2 then
        run_after_time(g430n2_navcom_rmt_kill, 0.33)
    end
end

function sim_g430n2_coarse_down_CMDhandlerBefore(phase, duration)         --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n2_com2 = simDR_com2_stby_frequency
    g430n2_nav2 = simDR_nav2_stby_frequency
    g430n2_navcom_rmt = 1
    if C90DR_avionics_g430n2_dial_com_mega == 0 then
        C90DR_avionics_g430n2_dial_com_mega = 1
    end
end

function sim_g430n2_coarse_down_CMDhandlerAfter(phase, duration)         --IBAV8N, Sep27-22, employs RMT led in radio head
    if gps430_power == 0 then
        simDR_com2_stby_frequency = g430n2_com2
        simDR_nav2_stby_frequency = g430n2_nav2
    end
    if phase == 0 then
        C90DR_avionics_g430n2_dial_com_mega = math.max(0, C90DR_avionics_g430n2_dial_com_mega - 0.1)
    elseif phase == 2 then
        run_after_time(g430n2_navcom_rmt_kill, 0.33)
    end
end

function sim_g430n2_fine_up_CMDhandlerBefore(phase, duration)           --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n2_com2 = simDR_com2_stby_frequency
    g430n2_nav2 = simDR_nav2_stby_frequency
    g430n2_navcom_rmt = 1
    if C90DR_avionics_g430n2_dial_com_kilo == 1 then
        C90DR_avionics_g430n2_dial_com_kilo = 0
    end
end

function sim_g430n2_fine_up_CMDhandlerAfter(phase, duration)            --IBAV8N, Sep27-22, employs RMT led in radio head
    if gps430_power == 0 then
        simDR_com2_stby_frequency = g430n2_com2
        simDR_nav2_stby_frequency = g430n2_nav2
    end
    if phase == 0 then
        C90DR_avionics_g430n2_dial_com_kilo = math.min(1, C90DR_avionics_g430n2_dial_com_kilo + 0.1)
    elseif phase == 2 then
        run_after_time(g430n2_navcom_rmt_kill, 0.33)
    end
end

function sim_g430n2_fine_down_CMDhandlerBefore(phase, duration)         --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n2_com2 = simDR_com2_stby_frequency
    g430n2_nav2 = simDR_nav2_stby_frequency
    g430n2_navcom_rmt = 1
    if C90DR_avionics_g430n2_dial_com_kilo == 0 then
        C90DR_avionics_g430n2_dial_com_kilo = 1
    end
end

function sim_g430n2_fine_down_CMDhandlerAfter(phase, duration)         --IBAV8N, Sep27-22, employs RMT led in radio head
    if gps430_power == 0 then
        simDR_com2_stby_frequency = g430n2_com2
        simDR_nav2_stby_frequency = g430n2_nav2
    end
    if phase == 0 then
        C90DR_avionics_g430n2_dial_com_kilo = math.max(0, C90DR_avionics_g430n2_dial_com_kilo - 0.1)
    elseif phase == 2 then
        run_after_time(g430n2_navcom_rmt_kill, 0.33)
    end
end

function g430n2_navcom_rmt_kill()         --IBAV8N, Sep27-22, employs RMT led in radio head
    g430n2_navcom_rmt = 0
end


function sim_g430n2_chapter_up_CMDhandlerBefore(phase, duration)
    if C90DR_avionics_g430n2_dial_chapter == 1 then
        C90DR_avionics_g430n2_dial_chapter = 0
    end
end

function sim_g430n2_chapter_up_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n2_dial_chapter = math.min(1, C90DR_avionics_g430n2_dial_chapter + 0.1)
    end
end

function sim_g430n2_chapter_dn_CMDhandlerBefore(phase, duration)
    if C90DR_avionics_g430n2_dial_chapter == 0 then
        C90DR_avionics_g430n2_dial_chapter = 1
    end
end

function sim_g430n2_chapter_dn_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n2_dial_chapter = math.max(0, C90DR_avionics_g430n2_dial_chapter - 0.1)
    end
end

function sim_g430n2_page_up_CMDhandlerBefore(phase, duration)
    if C90DR_avionics_g430n2_dial_page == 1 then
        C90DR_avionics_g430n2_dial_page = 0
    end
end

function sim_g430n2_page_up_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n2_dial_page = math.min(1, C90DR_avionics_g430n2_dial_page + 0.1)
    end
end

function sim_g430n2_page_dn_CMDhandlerBefore(phase, duration)
    if C90DR_avionics_g430n2_dial_page == 0 then
        C90DR_avionics_g430n2_dial_page = 1
    end
end

function sim_g430n2_page_dn_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_g430n2_dial_page = math.max(0, C90DR_avionics_g430n2_dial_page - 0.1)
    end
end

function sim_g430n2_com_ff_CMDhandlerBefore(phase, duration)
    g430n2_ff_com_rmt = 1
    g430n2_com_ff = simDR_com2_frequency
    g430n2_com_ff_stby = simDR_com2_stby_frequency
end

function sim_g430n2_com_ff_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_com_toggle = C90_ternary(phase == 2, 0, 1)
    if gps430_power == 0 then
        simDR_com2_frequency = g430n2_com_ff
        simDR_com2_stby_frequency = g430n2_com_ff_stby
    end
    if phase == 2 then
        g430n2_ff_com_rmt = 0
    end
end

function sim_g430n2_nav_ff_CMDhandlerBefore(phase, duration)
    g430n2_ff_nav_rmt = 1
    g430n2_nav_ff = simDR_nav2_frequency
    g430n2_nav_ff_stby = simDR_nav2_stby_frequency
end

function sim_g430n2_nav_ff_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_vloc_toggle = C90_ternary(phase == 2, 0, 1)
    if gps430_power == 0 then
        simDR_nav2_frequency = g430n2_nav_ff
        simDR_nav2_stby_frequency = g430n2_nav_ff_stby
    end
    if phase == 2 then
        g430n2_ff_nav_rmt = 0
    end
end

function sim_g430n2_nav_com_tog_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_com_push = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_cdi_CMDhandlerAfter(phase, duration)                                                      --IBAV8N, May17-22
    C90DR_avionics_g430n2_switch_pos_cdi = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_obs_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_obs = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_msg_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_msg = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_fpl_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_fpl = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_proc_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_proc = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_zoom_out_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_rng_down = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_zoom_in_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_rng_up = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_direct_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_dir = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_menu_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_menu = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_clr_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_clr = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_ent_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_ent = C90_ternary(phase == 2, 0, 1)
end

function sim_g430n2_cursor_CMDhandlerAfter(phase, duration)
    C90DR_avionics_g430n2_switch_pos_gps_push = C90_ternary(phase == 2, 0, 1)
end

function sim_xpdr_12_up_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl92_xpdr_12_dial_pos = C90DR_avionics_ctl92_xpdr_12_dial_pos + 1
		if C90DR_avionics_ctl92_xpdr_12_dial_pos > 360 then C90DR_avionics_ctl92_xpdr_12_dial_pos = 1 end
	end
end

function sim_xpdr_12_dn_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl92_xpdr_12_dial_pos = C90DR_avionics_ctl92_xpdr_12_dial_pos - 1
		if C90DR_avionics_ctl92_xpdr_12_dial_pos < 0 then C90DR_avionics_ctl92_xpdr_12_dial_pos = 360 end
	end
end

function sim_xpdr_34_up_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl92_xpdr_34_dial_pos = C90DR_avionics_ctl92_xpdr_34_dial_pos + 1
		if C90DR_avionics_ctl92_xpdr_34_dial_pos > 360 then C90DR_avionics_ctl92_xpdr_34_dial_pos = 1 end
	end
end

function sim_xpdr_34_dn_CMDhandlerAfter(phase, duration)
	if phase == 0 then
		C90DR_avionics_ctl92_xpdr_34_dial_pos = C90DR_avionics_ctl92_xpdr_34_dial_pos - 1
		if C90DR_avionics_ctl92_xpdr_34_dial_pos < 0 then C90DR_avionics_ctl92_xpdr_34_dial_pos = 360 end
	end
end

function sim_xpdr_ident_CMDhandlerAfter(phase, duration)
    C90DR_avionics_ctl92_xpdr_ident_switch_pos = C90_ternary(phase == 2, 0, 1)
    C90DR_yoke_ident_switch_pos = C90_ternary(phase == 2, 0, 1)
end

function sim_stby_nav1_coarse_dn_CMDhandlerAfter(phase, duration)
    if C90DR_avionics_ctl32_nav1_sto_index == 0 and C90DR_avionics_ctl32_nav1_act == 0 then
        simDR_radio_dme_freq_hz = simDR_radio_nav1_stby_freq_hz
	else simDR_radio_dme_freq_hz = C90.avionics.ctl32_nav1_sto_stack[0] end
end

function sim_stby_nav1_coarse_up_CMDhandlerAfter(phase, duration)
    if C90DR_avionics_ctl32_nav1_sto_index == 0 and C90DR_avionics_ctl32_nav1_act == 0 then
        simDR_radio_dme_freq_hz = simDR_radio_nav1_stby_freq_hz
	else simDR_radio_dme_freq_hz = C90.avionics.ctl32_nav1_sto_stack[0] end
end

function sim_stby_nav1_fine_dn_CMDhandlerAfter(phase, duration)
    if C90DR_avionics_ctl32_nav1_sto_index == 0 and C90DR_avionics_ctl32_nav1_act == 0 then
        simDR_radio_dme_freq_hz = simDR_radio_nav1_stby_freq_hz
	else simDR_radio_dme_freq_hz = C90.avionics.ctl32_nav1_sto_stack[0] end
end

function sim_stby_nav1_fine_up_CMDhandlerAfter(phase, duration)
    if C90DR_avionics_ctl32_nav1_sto_index == 0 and C90DR_avionics_ctl32_nav1_act == 0 then
        simDR_radio_dme_freq_hz = simDR_radio_nav1_stby_freq_hz
	else simDR_radio_dme_freq_hz = C90.avionics.ctl32_nav1_sto_stack[0] end
end

function C90_autopilot_climb_CMDhandlerAfter(phase,duration)
	if phase == 0 then
		C90DR_autopilot_CLM_switch_pos = 1
	elseif phase == 2 then
		C90DR_autopilot_CLM_switch_pos = 0
	end
end

function C90_autopilot_descend_CMDhandlerAfter(phase,duration)
	if phase == 0 then
		C90DR_autopilot_DSC_switch_pos = 1
	elseif phase == 2 then
		C90DR_autopilot_DSC_switch_pos = 0
	end
end

function C90_autopilot_nose_down_CMDhandlerAfter(phase,duration)
	if phase == 0 then
		C90DR_autopilot_vert_control_switch_pos = 1
	elseif phase == 2 then
		C90DR_autopilot_vert_control_switch_pos = 0
	end
end

function C90_autopilot_nose_up_CMDhandlerAfter(phase,duration)
	if phase == 0 then
		C90DR_autopilot_vert_control_switch_pos = -1
	elseif phase == 2 then
		C90DR_autopilot_vert_control_switch_pos = 0
	end
end

function C90_altitude_alert_cancel_CMDhandlerAfter(phase,duration)
    C90DR_autopilot_altAlert_canx_switch_pos = C90_ternary(phase == 2, 0, 1)
end

function sim_battery_on_toggle_CMDhandlerAfter(phase, duration)                                             --IBAV8N, Aug23-23
    C90DR_avionics_grd_pwr_comm_switch_pos = 0
end 
     
function sim_battery_on_CMDhandlerAfter(phase, duration)                                                    --IBAV8N, Aug23-23
    C90DR_avionics_grd_pwr_comm_switch_pos = 0
end

function sim_GPU_toggle_CMDhandlerAfter(phase, duration)                                                    --IBAV8N, Aug23-23
    C90DR_avionics_grd_pwr_comm_switch_pos = 0
    C90DR_gen_tie_L = math.max(C90DR_gen_tie_L, C90.electrical.gpu_live)
    C90DR_gen_tie_R = math.max(C90DR_gen_tie_R, C90.electrical.gpu_live)
end    
         
function sim_GPU_on_CMDhandlerAfter(phase, duration)                                                        --IBAV8N, Aug23-23
    C90DR_avionics_grd_pwr_comm_switch_pos = 0
    C90DR_gen_tie_L = math.max(C90DR_gen_tie_L, C90.electrical.gpu_live)
    C90DR_gen_tie_R = math.max(C90DR_gen_tie_R, C90.electrical.gpu_live)
end                 

function sim_flaps_up_CMDhandlerAfter(phase, duration) flaps() end

function sim_flaps_down_CMDhandlerAfter(phase, duration) flaps() end
--[[
function C90_rxp_gtn_dto_1_CMDHandlerAfter(phase, duration)
    C90DR_avionics_gtn_dto[0] = C90_ternary(phase == 2, 0, 1)
end

function C90_rxp_gtn_dto_2_CMDHandlerAfter(phase, duration)
    C90DR_avionics_gtn_dto[1] = C90_ternary(phase == 2, 0, 1)
end

function C90_rxp_gtn_home_1_CMDHandlerAfter(phase, duration)
    C90DR_avionics_gtn_home[0] = C90_ternary(phase == 2, 0, 1)
end

function C90_rxp_gtn_home_2_CMDHandlerAfter(phase, duration)
    C90DR_avionics_gtn_home[1] = C90_ternary(phase == 2, 0, 1)
end

function C90_rxp_gtn_vol_push_1_CMDHandlerAfter(phase, duration)
    C90DR_avionics_gtn_vol_push[0] = C90_ternary(phase == 2, 0, 1)
end

function C90_rxp_gtn_vol_push_2_CMDHandlerAfter(phase, duration)
    C90DR_avionics_gtn_vol_push[1] = C90_ternary(phase == 2, 0, 1)
end

function C90_rxp_gtn_vol_ccw_1_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_volume[0] == 0 then
        C90DR_avionics_gtn_volume[0] = 1
    end
end

function C90_rxp_gtn_vol_ccw_1_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_volume[0] = math.max(0, C90DR_avionics_gtn_volume[0] - 0.1)
        C90DR_avionics_master_vol_ctrl_dial_pilot = C90DR_avionics_gtn_volume[0]
    end
end

function C90_rxp_gtn_vol_ccw_2_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_volume[1] == 0 then
        C90DR_avionics_gtn_volume[1] = 1
    end
end

function C90_rxp_gtn_vol_ccw_2_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_volume[1] = math.max(0, C90DR_avionics_gtn_volume[1] - 0.1)
        C90DR_avionics_master_vol_ctrl_dial_copilot = C90DR_avionics_gtn_volume[1]
    end
end

function C90_rxp_gtn_vol_cw_1_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_volume[0] == 1 then
        C90DR_avionics_gtn_volume[0] = 0
    end
end

function C90_rxp_gtn_vol_cw_1_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_volume[0] = math.min(1, C90DR_avionics_gtn_volume[0] + 0.1)
        C90DR_avionics_master_vol_ctrl_dial_pilot = C90DR_avionics_gtn_volume[0]
    end
end

function C90_rxp_gtn_vol_cw_2_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_volume[1] == 1 then
        C90DR_avionics_gtn_volume[1] = 0
    end
end

function C90_rxp_gtn_vol_cw_2_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_volume[1] = math.min(1, C90DR_avionics_gtn_volume[1] + 0.1)
        C90DR_avionics_master_vol_ctrl_dial_copilot = C90DR_avionics_gtn_volume[1]
    end
end

function C90_rxp_gtn_fms_push_1_CMDHandlerAfter(phase, duration)
    C90DR_avionics_gtn_fms_push[0] = C90_ternary(phase == 2, 0, 1)
end

function C90_rxp_gtn_fms_push_2_CMDHandlerAfter(phase, duration)
    C90DR_avionics_gtn_fms_push[1] = C90_ternary(phase == 2, 0, 1)
end

function C90_rxp_gtn_fms_outer_ccw_1_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_fms_outer[0] == 0 then
        C90DR_avionics_gtn_fms_outer[0] = 1
    end
end

function C90_rxp_gtn_fms_outer_ccw_1_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_fms_outer[0] = math.max(0, C90DR_avionics_gtn_fms_outer[0] - 0.1)
    end
end

function C90_rxp_gtn_fms_outer_ccw_2_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_fms_outer[1] == 0 then
        C90DR_avionics_gtn_fms_outer[1] = 1
    end
end

function C90_rxp_gtn_fms_outer_ccw_2_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_fms_outer[1] = math.max(0, C90DR_avionics_gtn_fms_outer[1] - 0.1)
    end
end

function C90_rxp_gtn_fms_outer_cw_1_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_fms_outer[0] == 1 then
        C90DR_avionics_gtn_fms_outer[0] = 0
    end
end

function C90_rxp_gtn_fms_outer_cw_1_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_fms_outer[0] = math.min(1, C90DR_avionics_gtn_fms_outer[0] + 0.1)
    end
end

function C90_rxp_gtn_fms_outer_cw_2_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_fms_outer[1] == 1 then
        C90DR_avionics_gtn_fms_outer[1] = 0
    end
end

function C90_rxp_gtn_fms_outer_cw_2_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_fms_outer[1] = math.min(1, C90DR_avionics_gtn_fms_outer[1] + 0.1)
    end
end

function C90_rxp_gtn_fms_inner_ccw_1_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_fms_inner[0] == 0 then
        C90DR_avionics_gtn_fms_inner[0] = 1
    end
end

function C90_rxp_gtn_fms_inner_ccw_1_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_fms_inner[0] = math.max(0, C90DR_avionics_gtn_fms_inner[0] - 0.1)
    end
end

function C90_rxp_gtn_fms_inner_ccw_2_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_fms_inner[1] == 0 then
        C90DR_avionics_gtn_fms_inner[1] = 1
    end
end

function C90_rxp_gtn_fms_inner_ccw_2_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_fms_inner[1] = math.max(0, C90DR_avionics_gtn_fms_inner[1] - 0.1)
    end
end

function C90_rxp_gtn_fms_inner_cw_1_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_fms_inner[0] == 1 then
        C90DR_avionics_gtn_fms_inner[0] = 0
    end
end

function C90_rxp_gtn_fms_inner_cw_1_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_fms_inner[0] = math.min(1, C90DR_avionics_gtn_fms_inner[0] + 0.1)
    end
end

function C90_rxp_gtn_fms_inner_cw_2_CMDHandlerBefore(phase, duration)
    if C90DR_avionics_gtn_fms_inner[1] == 1 then
        C90DR_avionics_gtn_fms_inner[1] = 0
    end
end

function C90_rxp_gtn_fms_inner_cw_2_CMDHandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_avionics_gtn_fms_inner[1] = math.min(1, C90DR_avionics_gtn_fms_inner[1] + 0.1)
    end
end
--]]
--GIVE G1000 VERSION PHASE=1 HOLD CAPABILITY FOR IAS/FLC ADJUSTMENTS
function sim_g1000n3_nose_down_CMDhandlerBefore(phase, duration)
    if phase == 1 and C90DR_imc_gfc710_indicator_flc == 1 and duration > 0.2 then
        if is_timer_scheduled(g1000n3_increase_ias) == false then
	        run_at_interval(g1000n3_increase_ias, 0.1)
        end
    else stop_timer(g1000n3_increase_ias)
    end
end

function sim_g1000n3_nose_up_CMDhandlerBefore(phase, duration)
    if phase == 1 and C90DR_imc_gfc710_indicator_flc == 1 and duration > 0.2 then
        if is_timer_scheduled(g1000n3_decrease_ias) == false then
	        run_at_interval(g1000n3_decrease_ias, 0.1)
        end
    else stop_timer(g1000n3_decrease_ias)
    end
end

function g1000n3_increase_ias()
    simDR_autopilot_airspeed_dial_kts = math.min(226, simDR_autopilot_airspeed_dial_kts + 1)
end

function g1000n3_decrease_ias()
    simDR_autopilot_airspeed_dial_kts = simDR_autopilot_airspeed_dial_kts - 1
end

----- TRIM SWITCH ANIMATION ---------------------------------------------------------------
function C90_pitch_trim_down_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_trim_switch = 1
        print("Pitch Trim Down")
    elseif phase == 2 then
        C90DR_trim_switch = 0
    end
end


function C90_pitch_trim_up_CMDhandlerAfter(phase, duration)
    if phase == 0 then
        C90DR_trim_switch = -1
        print("Pitch Trim Up")
    elseif phase == 2 then
        C90DR_trim_switch = 0
    end
end
--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--
simCMD_clear_master_warning	    = wrap_command("sim/annunciator/clear_master_warning", empty_CMDhandlerBefore, sim_clear_master_warning_CMDhandlerAfter)
simCMD_clear_master_caution	    = wrap_command("sim/annunciator/clear_master_caution", empty_CMDhandlerBefore, sim_clear_master_caution_CMDhandlerAfter)
simCMD_flaps_up		            = wrap_command("sim/flight_controls/flaps_up", empty_CMDhandlerBefore, sim_flaps_up_CMDhandlerAfter)                --IBAV8N, Jun1-21
simCMD_flaps_down		        = wrap_command("sim/flight_controls/flaps_down", empty_CMDhandlerBefore, sim_flaps_down_CMDhandlerAfter)            --IBAV8N, Jun1-21
simCMD_battery_on_toggle	    = wrap_command("sim/electrical/battery_1_toggle", empty_CMDhandlerBefore, sim_battery_on_toggle_CMDhandlerAfter)    --IBAV8N, May22-22
simCMD_battery_on	            = wrap_command("sim/electrical/battery_1_on", empty_CMDhandlerBefore, sim_battery_on_CMDhandlerAfter)               --IBAV8N, May22-22             --IBAV8N, May22-22
simCMD_GPU_toggle	            = wrap_command("sim/electrical/GPU_toggle", empty_CMDhandlerBefore, sim_GPU_toggle_CMDhandlerAfter)                 --IBAV8N, May22-22
simCMD_GPU_on	                = wrap_command("sim/electrical/GPU_on", empty_CMDhandlerBefore, sim_GPU_on_CMDhandlerAfter)                         --IBAV8N, May22-22
simCMD_pressure_vvi_down		= wrap_command("sim/pressurization/vvi_down", empty_CMDhandlerBefore, sim_pressure_vvi_downCMDhandlerAfter)
simCMD_pressure_vvi_up			= wrap_command("sim/pressurization/vvi_up", empty_CMDhandlerBefore, sim_pressure_vvi_upCMDhandlerAfter)
if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
    simCMD_g430n1_cdi		        = wrap_command("sim/GPS/g430n1_cdi", sim_g430n1_cdi_CMDhandlerBefore, sim_g430n1_cdi_CMDhandlerAfter)           --IBAV8N, Jan22-22
    simCMD_free_gyro_up				= wrap_command("sim/instruments/free_gyro_up", empty_CMDhandlerBefore, sim_free_gyro_up_CMDhandlerAfter)
    simCMD_free_gyro_dn				= wrap_command("sim/instruments/free_gyro_down", empty_CMDhandlerBefore, sim_free_gyro_dn_CMDhandlerAfter)
    simCMD_autopilot_HDG 			= wrap_command("sim/autopilot/heading", empty_CMDhandlerBefore, sim_autopilot_HDG_CMDhandlerAfter)
    simCMD_autopilot_NAV 			= wrap_command("sim/autopilot/NAV", empty_CMDhandlerBefore, sim_autopilot_NAV_CMDhandlerAfter)
    simCMD_autopilot_APPR 			= wrap_command("sim/autopilot/approach", empty_CMDhandlerBefore, sim_autopilot_APPR_CMDhandlerAfter)
    simCMD_autopilot_BC  			= wrap_command("sim/autopilot/back_course", empty_CMDhandlerBefore, sim_autopilot_BC_CMDhandlerAfter)
    simCMD_autopilot_ALT			= wrap_command("sim/autopilot/altitude_hold", empty_CMDhandlerBefore, sim_autopilot_ALT_CMDhandlerAfter)
    simCMD_autopilot_ALTSEL			= wrap_command("sim/autopilot/altitude_arm", empty_CMDhandlerBefore, sim_autopilot_ALTSEL_CMDhandlerAfter)
    simCMD_autopilot_VS 			= wrap_command("sim/autopilot/vertical_speed", empty_CMDhandlerBefore, sim_autopilot_VS_CMDhandlerAfter)
    simCMD_autopilot_IAS 			= wrap_command("sim/autopilot/level_change", sim_autopilot_IAS_CMDhandlerBefore, sim_autopilot_IAS_CMDhandlerAfter)
    simCMD_autopilot_yaw_damper 	= wrap_command("sim/systems/yaw_damper_toggle", empty_CMDhandlerBefore, sim_autopilot_yaw_damper_CMDhandlerAfter)
    simCMD_autopilot_engage 		= wrap_command("sim/autopilot/servos_toggle", empty_CMDhandlerBefore, sim_autopilot_engage_CMDhandlerAfter)
    simCMD_autopilot_soft_ride 		= wrap_command("sim/autopilot/soft_ride_toggle", empty_CMDhandlerBefore, sim_autopilot_soft_ride_CMDhandlerAfter)
    simCMD_autopilot_half_bank		= wrap_command("sim/autopilot/bank_limit_toggle", empty_CMDhandlerBefore, sim_autopilot_half_bank_CMDhandlerAfter)
    simCMD_adf1_ones_tens_up		= wrap_command("sim/radios/stby_adf1_ones_tens_up", empty_CMDhandlerBefore, sim_adf1_ones_tens_up_CMDhandlerAfter)
    simCMD_adf1_ones_tens_dn		= wrap_command("sim/radios/stby_adf1_ones_tens_down", empty_CMDhandlerBefore, sim_adf1_ones_tens_dn_CMDhandlerAfter)
    simCMD_adf1_hund_thous_up		= wrap_command("sim/radios/stby_adf1_hundreds_thous_up", empty_CMDhandlerBefore, sim_adf1_hund_thous_up_CMDhandlerAfter)
    simCMD_adf1_hund_thous_dn		= wrap_command("sim/radios/stby_adf1_hundreds_thous_down", empty_CMDhandlerBefore, sim_adf1_hund_thous_dn_CMDhandlerAfter)
    simCMD_ap_climb					= wrap_command("sim/autopilot/climb", empty_CMDhandlerBefore, C90_autopilot_climb_CMDhandlerAfter)
    simCMD_ap_descend				= wrap_command("sim/autopilot/descend", empty_CMDhandlerBefore, C90_autopilot_descend_CMDhandlerAfter)
    simCMD_ap_nose_down				= wrap_command("sim/autopilot/nose_down", empty_CMDhandlerBefore, C90_autopilot_nose_down_CMDhandlerAfter)
    simCMD_ap_nose_up				= wrap_command("sim/autopilot/nose_up", empty_CMDhandlerBefore, C90_autopilot_nose_up_CMDhandlerAfter)
    simCMD_alt_alert_canx			= wrap_command("sim/instruments/baro_alt_alert_cancel", empty_CMDhandlerBefore, C90_altitude_alert_cancel_CMDhandlerAfter)
    if simDR_acf_descrip == "C90B EVO GNS" then
        print("EVO: 12. LOADING GNS Command Wrappers")
        simCMD_g430n1_coarse_up     = wrap_command("sim/GPS/g430n1_coarse_up", sim_g430n1_coarse_up_CMDhandlerBefore, sim_g430n1_coarse_up_CMDhandlerAfter)
        simCMD_g430n1_coarse_down   = wrap_command("sim/GPS/g430n1_coarse_down", sim_g430n1_coarse_down_CMDhandlerBefore, sim_g430n1_coarse_down_CMDhandlerAfter)
        simCMD_g430n1_fine_up       = wrap_command("sim/GPS/g430n1_fine_up", sim_g430n1_fine_up_CMDhandlerBefore, sim_g430n1_fine_up_CMDhandlerAfter)
        simCMD_g430n1_fine_down     = wrap_command("sim/GPS/g430n1_fine_down", sim_g430n1_fine_down_CMDhandlerBefore, sim_g430n1_fine_down_CMDhandlerAfter)
        simCMD_g430n1_chapter_up    = wrap_command("sim/GPS/g430n1_chapter_up", sim_g430n1_chapter_up_CMDhandlerBefore, sim_g430n1_chapter_up_CMDhandlerAfter)
        simCMD_g430n1_chapter_dn    = wrap_command("sim/GPS/g430n1_chapter_dn", sim_g430n1_chapter_dn_CMDhandlerBefore, sim_g430n1_chapter_dn_CMDhandlerAfter)
        simCMD_g430n1_page_up       = wrap_command("sim/GPS/g430n1_page_up", sim_g430n1_page_up_CMDhandlerBefore, sim_g430n1_page_up_CMDhandlerAfter)
        simCMD_g430n1_page_dn       = wrap_command("sim/GPS/g430n1_page_dn", sim_g430n1_page_dn_CMDhandlerBefore, sim_g430n1_page_dn_CMDhandlerAfter)
        simCMD_g430n1_com_ff        = wrap_command("sim/GPS/g430n1_com_ff", sim_g430n1_com_ff_CMDhandlerBefore, sim_g430n1_com_ff_CMDhandlerAfter)
        simCMD_g430n1_nav_ff        = wrap_command("sim/GPS/g430n1_nav_ff", sim_g430n1_nav_ff_CMDhandlerBefore, sim_g430n1_nav_ff_CMDhandlerAfter)
        simCMD_g430n1_nav_com_tog   = wrap_command("sim/GPS/g430n1_nav_com_tog", empty_CMDhandlerBefore, sim_g430n1_nav_com_tog_CMDhandlerAfter)
        simCMD_g430n1_obs           = wrap_command("sim/GPS/g430n1_obs", empty_CMDhandlerBefore, sim_g430n1_obs_CMDhandlerAfter)
        simCMD_g430n1_msg           = wrap_command("sim/GPS/g430n1_msg", empty_CMDhandlerBefore, sim_g430n1_msg_CMDhandlerAfter)
        simCMD_g430n1_fpl           = wrap_command("sim/GPS/g430n1_fpl", empty_CMDhandlerBefore, sim_g430n1_fpl_CMDhandlerAfter)
        simCMD_g430n1_vnav          = wrap_command("sim/GPS/g430n1_vnav", empty_CMDhandlerBefore, sim_g430n1_vnav_CMDhandlerAfter)
        simCMD_g430n1_proc          = wrap_command("sim/GPS/g430n1_proc", empty_CMDhandlerBefore, sim_g430n1_proc_CMDhandlerAfter)
        simCMD_g430n1_zoom_out      = wrap_command("sim/GPS/g430n1_zoom_out", empty_CMDhandlerBefore, sim_g430n1_zoom_out_CMDhandlerAfter)
        simCMD_g430n1_zoom_in       = wrap_command("sim/GPS/g430n1_zoom_in", empty_CMDhandlerBefore, sim_g430n1_zoom_in_CMDhandlerAfter)
        simCMD_g430n1_direct        = wrap_command("sim/GPS/g430n1_direct", empty_CMDhandlerBefore, sim_g430n1_direct_CMDhandlerAfter)
        simCMD_g430n1_menu          = wrap_command("sim/GPS/g430n1_menu", empty_CMDhandlerBefore, sim_g430n1_menu_CMDhandlerAfter)
        simCMD_g430n1_clr           = wrap_command("sim/GPS/g430n1_clr", empty_CMDhandlerBefore, sim_g430n1_clr_CMDhandlerAfter)
        simCMD_g430n1_ent           = wrap_command("sim/GPS/g430n1_ent", empty_CMDhandlerBefore, sim_g430n1_ent_CMDhandlerAfter)
        simCMD_g430n1_cursor        = wrap_command("sim/GPS/g430n1_cursor", empty_CMDhandlerBefore, sim_g430n1_cursor_CMDhandlerAfter)
        simCMD_g430n2_coarse_up     = wrap_command("sim/GPS/g430n2_coarse_up", sim_g430n2_coarse_up_CMDhandlerBefore, sim_g430n2_coarse_up_CMDhandlerAfter)
        simCMD_g430n2_coarse_down   = wrap_command("sim/GPS/g430n2_coarse_down", sim_g430n2_coarse_down_CMDhandlerBefore, sim_g430n2_coarse_down_CMDhandlerAfter)
        simCMD_g430n2_fine_up       = wrap_command("sim/GPS/g430n2_fine_up", sim_g430n2_fine_up_CMDhandlerBefore, sim_g430n2_fine_up_CMDhandlerAfter)
        simCMD_g430n2_fine_down     = wrap_command("sim/GPS/g430n2_fine_down", sim_g430n2_fine_down_CMDhandlerBefore, sim_g430n2_fine_down_CMDhandlerAfter)
        simCMD_g430n2_chapter_up    = wrap_command("sim/GPS/g430n2_chapter_up", sim_g430n2_chapter_up_CMDhandlerBefore, sim_g430n2_chapter_up_CMDhandlerAfter)
        simCMD_g430n2_chapter_dn    = wrap_command("sim/GPS/g430n2_chapter_dn", sim_g430n2_chapter_dn_CMDhandlerBefore, sim_g430n2_chapter_dn_CMDhandlerAfter)
        simCMD_g430n2_page_up       = wrap_command("sim/GPS/g430n2_page_up", sim_g430n2_page_up_CMDhandlerBefore, sim_g430n2_page_up_CMDhandlerAfter)
        simCMD_g430n2_page_dn       = wrap_command("sim/GPS/g430n2_page_dn", sim_g430n2_page_dn_CMDhandlerBefore, sim_g430n2_page_dn_CMDhandlerAfter)
        simCMD_g430n2_com_ff        = wrap_command("sim/GPS/g430n2_com_ff", sim_g430n2_com_ff_CMDhandlerBefore, sim_g430n2_com_ff_CMDhandlerAfter)
        simCMD_g430n2_nav_ff        = wrap_command("sim/GPS/g430n2_nav_ff", sim_g430n2_nav_ff_CMDhandlerBefore, sim_g430n2_nav_ff_CMDhandlerAfter)
        simCMD_g430n2_nav_com_tog   = wrap_command("sim/GPS/g430n2_nav_com_tog", empty_CMDhandlerBefore, sim_g430n2_nav_com_tog_CMDhandlerAfter)
        simCMD_g430n2_cdi           = wrap_command("sim/GPS/g430n2_cdi", empty_CMDhandlerBefore, sim_g430n2_cdi_CMDhandlerAfter)
        simCMD_g430n2_obs           = wrap_command("sim/GPS/g430n2_obs", empty_CMDhandlerBefore, sim_g430n2_obs_CMDhandlerAfter)
        simCMD_g430n2_msg           = wrap_command("sim/GPS/g430n2_msg", empty_CMDhandlerBefore, sim_g430n2_msg_CMDhandlerAfter)
        simCMD_g430n2_fpl           = wrap_command("sim/GPS/g430n2_fpl", empty_CMDhandlerBefore, sim_g430n2_fpl_CMDhandlerAfter)
        simCMD_g430n2_proc          = wrap_command("sim/GPS/g430n2_proc", empty_CMDhandlerBefore, sim_g430n2_proc_CMDhandlerAfter)
        simCMD_g430n2_zoom_out      = wrap_command("sim/GPS/g430n2_zoom_out", empty_CMDhandlerBefore, sim_g430n2_zoom_out_CMDhandlerAfter)
        simCMD_g430n2_zoom_in       = wrap_command("sim/GPS/g430n2_zoom_in", empty_CMDhandlerBefore, sim_g430n2_zoom_in_CMDhandlerAfter)
        simCMD_g430n2_direct        = wrap_command("sim/GPS/g430n2_direct", empty_CMDhandlerBefore, sim_g430n2_direct_CMDhandlerAfter)
        simCMD_g430n2_menu          = wrap_command("sim/GPS/g430n2_menu", empty_CMDhandlerBefore, sim_g430n2_menu_CMDhandlerAfter)
        simCMD_g430n2_clr           = wrap_command("sim/GPS/g430n2_clr", empty_CMDhandlerBefore, sim_g430n2_clr_CMDhandlerAfter)
        simCMD_g430n2_ent           = wrap_command("sim/GPS/g430n2_ent", empty_CMDhandlerBefore, sim_g430n2_ent_CMDhandlerAfter)
        simCMD_g430n2_cursor        = wrap_command("sim/GPS/g430n2_cursor", empty_CMDhandlerBefore, sim_g430n2_cursor_CMDhandlerAfter)
        simCMD_xpdr_12_up				= wrap_command("sim/transponder/transponder_12_up", empty_CMDhandlerBefore, sim_xpdr_12_up_CMDhandlerAfter)
        simCMD_xpdr_12_dn				= wrap_command("sim/transponder/transponder_12_down", empty_CMDhandlerBefore, sim_xpdr_12_dn_CMDhandlerAfter)
        simCMD_xpdr_34_up				= wrap_command("sim/transponder/transponder_34_up", empty_CMDhandlerBefore, sim_xpdr_34_up_CMDhandlerAfter)
        simCMD_xpdr_34_dn				= wrap_command("sim/transponder/transponder_34_down", empty_CMDhandlerBefore, sim_xpdr_34_dn_CMDhandlerAfter)
        simCMD_xpdr_ident				= wrap_command("sim/transponder/transponder_ident", empty_CMDhandlerBefore, sim_xpdr_ident_CMDhandlerAfter)
        simCMD_stby_nav1_coarse_dn		= wrap_command("sim/radios/stby_nav1_coarse_down", empty_CMDhandlerBefore, sim_stby_nav1_coarse_dn_CMDhandlerAfter)
        simCMD_stby_nav1_coarse_up		= wrap_command("sim/radios/stby_nav1_coarse_up", empty_CMDhandlerBefore, sim_stby_nav1_coarse_up_CMDhandlerAfter)
        simCMD_stby_nav1_fine_dn		= wrap_command("sim/radios/stby_nav1_fine_down", empty_CMDhandlerBefore, sim_stby_nav1_fine_dn_CMDhandlerAfter)
        simCMD_stby_nav1_fine_up		= wrap_command("sim/radios/stby_nav1_fine_up", empty_CMDhandlerBefore, sim_stby_nav1_fine_up_CMDhandlerAfter)
    end
--[[
    if simDR_acf_descrip == "C90B EVO GTN" then
        print("EVO: 12. LOADING GTN Command Wrappers")
        simCMD_rxp_gtn_dto_1                    = wrap_command("RXP/GTN/DTO_1", empty_CMDhandlerBefore, C90_rxp_gtn_dto_1_CMDHandlerAfter)
        simCMD_rxp_gtn_dto_2                    = wrap_command("RXP/GTN/DTO_2", empty_CMDhandlerBefore, C90_rxp_gtn_dto_2_CMDHandlerAfter)
        simCMD_rxp_gtn_home_1                   = wrap_command("RXP/GTN/HOME_1", empty_CMDhandlerBefore, C90_rxp_gtn_home_1_CMDHandlerAfter)
        simCMD_rxp_gtn_home_2                   = wrap_command("RXP/GTN/HOME_2", empty_CMDhandlerBefore,C90_rxp_gtn_home_2_CMDHandlerAfter)
        simCMD_rxp_gtn_vol_push_1               = wrap_command("RXP/GTN/VOL_PUSH_1", empty_CMDhandlerBefore, C90_rxp_gtn_vol_push_1_CMDHandlerAfter)
        simCMD_rxp_gtn_vol_push_2               = wrap_command("RXP/GTN/VOL_PUSH_2", empty_CMDhandlerBefore, C90_rxp_gtn_vol_push_2_CMDHandlerAfter)
        simCMD_rxp_gtn_vol_ccw_1                = wrap_command("RXP/GTN/VOL_CCW_1", C90_rxp_gtn_vol_ccw_1_CMDHandlerBefore, C90_rxp_gtn_vol_ccw_1_CMDHandlerAfter)
        simCMD_rxp_gtn_vol_ccw_2                = wrap_command("RXP/GTN/VOL_CCW_2", C90_rxp_gtn_vol_ccw_2_CMDHandlerBefore, C90_rxp_gtn_vol_ccw_2_CMDHandlerAfter)
        simCMD_rxp_gtn_vol_cw_1                 = wrap_command("RXP/GTN/VOL_CW_1", C90_rxp_gtn_vol_cw_1_CMDHandlerBefore, C90_rxp_gtn_vol_cw_1_CMDHandlerAfter)
        simCMD_rxp_gtn_vol_cw_2                 = wrap_command("RXP/GTN/VOL_CW_2", C90_rxp_gtn_vol_cw_2_CMDHandlerBefore, C90_rxp_gtn_vol_cw_2_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_push_1               = wrap_command("RXP/GTN/FMS_PUSH_1", empty_CMDhandlerBefore, C90_rxp_gtn_fms_push_1_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_push_2               = wrap_command("RXP/GTN/FMS_PUSH_2", empty_CMDhandlerBefore, C90_rxp_gtn_fms_push_2_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_outer_ccw_1          = wrap_command("RXP/GTN/FMS_OUTER_CCW_1", C90_rxp_gtn_fms_outer_ccw_1_CMDHandlerBefore, C90_rxp_gtn_fms_outer_ccw_1_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_outer_ccw_2          = wrap_command("RXP/GTN/FMS_OUTER_CCW_2", C90_rxp_gtn_fms_outer_ccw_2_CMDHandlerBefore, C90_rxp_gtn_fms_outer_ccw_2_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_outer_cw_1           = wrap_command("RXP/GTN/FMS_OUTER_CW_1", C90_rxp_gtn_fms_outer_cw_1_CMDHandlerBefore, C90_rxp_gtn_fms_outer_cw_1_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_outer_cw_2           = wrap_command("RXP/GTN/FMS_OUTER_CW_2", C90_rxp_gtn_fms_outer_cw_2_CMDHandlerBefore, C90_rxp_gtn_fms_outer_cw_2_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_inner_ccw_1          = wrap_command("RXP/GTN/FMS_INNER_CCW_1", C90_rxp_gtn_fms_inner_ccw_1_CMDHandlerBefore, C90_rxp_gtn_fms_inner_ccw_1_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_inner_ccw_2          = wrap_command("RXP/GTN/FMS_INNER_CCW_2", C90_rxp_gtn_fms_inner_ccw_2_CMDHandlerBefore, C90_rxp_gtn_fms_inner_ccw_2_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_inner_cw_1           = wrap_command("RXP/GTN/FMS_INNER_CW_1", C90_rxp_gtn_fms_inner_cw_1_CMDHandlerBefore, C90_rxp_gtn_fms_inner_cw_1_CMDHandlerAfter)
        simCMD_rxp_gtn_fms_inner_cw_2           = wrap_command("RXP/GTN/FMS_INNER_CW_2", C90_rxp_gtn_fms_inner_cw_2_CMDHandlerBefore, C90_rxp_gtn_fms_inner_cw_2_CMDHandlerAfter)
    end
--]]
else
    print("EVO: 12. LOADING G1000 Command Wrappers")
    simCMD_g1000n3_nose_down	    = wrap_command("sim/GPS/g1000n3_nose_down", sim_g1000n3_nose_down_CMDhandlerBefore, empty_CMDhandlerAfter)
    simCMD_g1000n3_nose_up	        = wrap_command("sim/GPS/g1000n3_nose_up", sim_g1000n3_nose_up_CMDhandlerBefore, empty_CMDhandlerAfter)
end

-- YOKE
C90CMD_pitch_trim_down = wrap_command("sim/flight_controls/pitch_trim_down", empty_CMDhandlerBefore,
C90_pitch_trim_down_CMDhandlerAfter)
C90CMD_pitch_trim_up   = wrap_command("sim/flight_controls/pitch_trim_up", empty_CMDhandlerBefore,
C90_pitch_trim_up_CMDhandlerAfter)


-- STARTER SUBROUTINES
function starter_torque()                   --IBAV8N, Jun13-21, reduce available starter torque if corresp. gen is on, per workbook.
    if (C90DR_powerplant_ign_start_switch_pos_L ~= 0 and C90DR_electrical_gen_L_switch_pos > -1)
    or (C90DR_powerplant_ign_start_switch_pos_R ~= 0 and C90DR_electrical_gen_R_switch_pos > -1) then
        simDR_starter_torque_ratio = 0.083
    else simDR_starter_torque_ratio = 0.15
    end
end

-- GNS430 GNS530 GPS AUTOMATICALLY CROSS-FILL FLIGHT PLANS
function crossfill()
	if C90DR_crossfill * simDR_gps530_power * simDR_gps430_power == 1 then
		C90DR_gps530_crossfill_iterate = C90DR_gps530_crossfill_iterate + 1		-- @pilotmarcog Increase iteration count
		simCMD_flightplan:once()
		simCMD_menu:once()
		simCMD_down:once()
		simCMD_down:once()
		simCMD_down:once()
		simCMD_down:once()
		simCMD_down:once()
		simCMD_enter:once()
		simCMD_flightplan:once()
	end
end
--[[
function C90_gtn_brightness()
    simDR_switch_instr_brightness_ratio[5] = math.max(0.65, 1 - simDR_switch_instr_brightness_ratio[14])
end
--]]
function pilots_onboard()
    C90DR_pilots_onboard = math.max(simDR_engine_running[0], simDR_engine_running[1], simDR_battery_on)
    if simDR_avitab_power == 1 then             --IBAV8N, Apr7-22, use variable to record on/off setting for persistence
        C90.avitab_on = 1
    else C90.avitab_on = 0
    end
    if simDR_avitab_enabled == 1 then
        C90.avitab_enable = 1
    else C90.avitab_enable = 0
    end
end

--*************************************************************************************--
--** 					           OBJECT CONSTRUCTORS         	    	    		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 CREATE OBJECTS        	         				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                SYSTEM FUNCTIONS             	    			 **--
--*************************************************************************************--

----- ANIMATION UTILITY -----------------------------------------------------------------
function C90_set_animation_position(current_value, target, min, max, speed)
    local fps_factor = math.min(1, speed * SIM_PERIOD)
    if target >= (max - 0.001) and current_value >= (max - 0.001) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.001) then
       return min
    else
        return current_value + ((target - current_value) * fps_factor)
    end
end

---- ROUND A NUMBER TO A SPECIFIC INCREMENT (ie. 5,10,20,50,100, etc.) ------------------
function C90_rndToIncr(number, increment)
    local y = number / increment
    local q = math.floor(y + 0.5)
    return q * increment
end

----- RESCALE ---------------------------------------------------------------------------
function C90_rescale(in1, out1, in2, out2, x)
    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end

----- TERNARY CONDITIONAL ---------------------------------------------------------------
function C90_ternary(condition, ifTrue, ifFalse)
    if condition then return ifTrue else return ifFalse end
end

----- COMPASS DELTA ---------------------------------------------------------------
function C90_compass(deg1, deg2, zero_one_eighty)        --IBAV8N, Jan26-22, returns the +/- delta of two compass points. Sept5-23, for zero_one_eighty use 0 or 180.
    local x = deg2 - deg1 - zero_one_eighty
    local y = 0
    if x > 180 then
        y = x - 360
    elseif x < -180 then
        y = x + 360
    else y = x
    end
    return y * C90_ternary(zero_one_eighty > 0, 1, -1)
end



----- DEFERRED INIT ---------------------------------------------------------------------
function C90_flight_start_DeferredInit()

	-- AUTOPILOT
	simDR_autopilot_alt_dial_ft = C90_rndToIncr(simDR_autopilot_alt_dial_ft, 100)

    -- IGNITION
    simDR_auto_ignite_on[0] = C90DR_electrical_auto_ignition_switch_pos_L
    simDR_auto_ignite_on[1] = C90DR_electrical_auto_ignition_switch_pos_R
    simCMD_igniter_off_L:once()
    simCMD_igniter_off_R:once()

    -- RESET WARNING/CAUTION ARRAYS
    simCMD_clear_master_warning:once()
    simCMD_clear_master_caution:once()

    -- MATCH LANDING GEAR TO C90 SETTING
    C90_gear_handle_DRhandler()

    --FUEL PANEL
    if simDR_fuel_quantity_l_wing == 0 then
        simCMD_left_xfer_dn:once()      --IBAV8N, Nov23-23, set to on if wings have fuel
    end
    if simDR_fuel_quantity_r_wing == 0 then
        simCMD_right_xfer_dn:once()     --IBAV8N, Nov23-23, set to on if wings have fuel
    end

    --STARTUP RUNNING
    if simDR_startup_running == 1 then
        if simDR_radio_altitude_ft > 10 then    --if in the air...
            simDR_beta_rev_ratio_all = 0.4
            simDR_elevator_trim = 0.6
        else                                    --if on the ground...
            simDR_elevator_trim = 0.3
            simDR_engine_antiice_left = 1
            simDR_engine_antiice_right = 1
        end
    end
end

--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	        			 **--
--*************************************************************************************--

function aircraft_load()
    print("EVO: 13. Loading Aircraft")
    --DETERMINE WHICH SETTINGS FILE TO READ/WRITE TO    --IBAV8N, Jan4-21 Different settings files for the different versions (testing)
    if simDR_acf_descrip == "C90B EVO GNS" then C90.persistence = "./Output/preferences/C90B_EVO_GNS_XP12_settings.txt"
    --elseif simDR_acf_descrip == "C90B EVO GTN" then C90.persistence = "./Output/preferences/C90B_EVO_GTN_XP12_settings.txt"
    elseif simDR_acf_descrip == "C90B - G1000, Blackhawk" then C90.persistence = "./Output/preferences/C90B_EVO_G1000_settings.txt"--IMC SEPT10-23
    end
    --STORE PRIOR SOUND SETTINGS
    save_volume_engine          = simDR_volume_engine
    save_volume_environment     = simDR_volume_environment
    save_volume_interior        = simDR_volume_interior
end

function aircraft_unload()
    print("EVO: 20. Unloading Aircraft")
    --RESTORE PRIOR SOUND SETTINGS
    simDR_volume_engine         = save_volume_engine
    simDR_volume_environment    = save_volume_environment
    simDR_volume_interior       = save_volume_interior
    --RESET VARIOUS LIGHTS
    for i = 0, 3 do
        simDR_generic_lights_switch[i] = 0
    end
    for i = 6, 63 do
        simDR_generic_lights_switch[i] = 0
    end
    for i = 0, 3 do
        simDR_switch_panel_brightness_ratio[i] = 0.75
    end
    for i = 0, 10 do
        simDR_switch_instr_brightness_ratio[i] = 0.75
    end
    for i = 13, 15 do
        simDR_switch_instr_brightness_ratio[i] = 0.75
    end
    if simDR_all_gear_on_ground == 1 and        --IBAV8N, persistence only saves if plane is parked and powered down
        simDR_engine_running[0] == 0 and
        simDR_engine_running[1] == 0 and
        simDR_parking_brake == 1 and
        C90DR_power == 0 then
        if simDR_acf_descrip == "C90B EVO GNS" then
            save_gns_settings()
        --elseif simDR_acf_descrip == "C90B EVO GTN" then
        --    save_gtn_settings()
        elseif simDR_acf_descrip == "C90B - G1000, Blackhawk" then
            save_g1000_settings()
        end
    else
        print("EVO: 21. C90B EVO is not parked and engines cutoff.  Not saving to persistence.")
    end
	simDR_kill_G1000_engine = 0                     --IMC SEPT10-23
    print("EVO: 22. C90B EVO Unloaded.")
end

function flight_start()
    print("EVO: 14. Starting Flight")
    -- ALL MODES ------------------------------------------------------------------------
    C90.start_running = 0
    C90DR_no_animation = 0                                                                              -- NO ANIMATION
    C90DR_no_ref = 0
    simDR_starter_torque_ratio = 0.15
    brightness = 0
    encdtwo = 1
    simDR_override_artstab = 1
    C90DR_starter_relay_L = 0
    C90DR_starter_relay_R = 0
    simDR_vvi_step_ft = 200
    C90DR_quadrant_levers_hidden = 0                     --IMC JAN16-24 ensure the quadrant levers are initially visible
    --RESET WARNING/CAUTION ARRAYS                       --IBAV8N, Jul11-24, updated
    for i = 0, 12 do
        C90.warning.array[i] = 0
        C90.warning.status[i] = 0
    end
    for i = 0, 18 do
        C90.caution.array[i] = 0
        C90.caution.status[i] = 0
    end
    for i = 0, 7 do
        C90.advisory.status[i] = 0
    end
    --AVITAB
    simDR_avitab_power = 1  --IBAV8N, Sept21-23, users have had trouble finding this, read comments on .org
    simDR_avitab_enabled = 1
    --CONTROLS
    C90DR_gear_handle = 1
    simDR_elevator_trim = 0 --@pilotmarcog set trim wheel to zero for C&D startup
    simDR_prop_feather_mode_switch = 0
    --OVERHEAD LIGHTING SWITCHES/KNOBS
    C90DR_ovh_master = 0
    C90DR_ovh_emerg = 0
    C90DR_ovh_flood = 0	    --@pilotmarcog
    C90DR_ovh_indirect = 0.6
    C90DR_ovh_pilot_flt = 0.5	--IBAV8N
    C90DR_ovh_pilot_gyro = 0.5
    C90DR_ovh_eng_instru = 0.5
    C90DR_ovh_avion_pnl = 0.5
    C90DR_ovh_sub_pnl = 0.5
    C90DR_ovh_side_pnl = 0.5
    C90DR_ovh_copilot_gyro = 0.5
    C90DR_ovh_copilot_flt = 0.5
    C90DR_volt_bus_sel_dial = 1
    --LIGHTS (for reference)
    --simDR_generic_lights_switch[1]    WING ICE
    --simDR_generic_lights_switch[2]    RECOG
    --simDR_generic_lights_switch[3]    TAIL FLOOD
    --simDR_generic_lights_switch[4]    Lighting bar
    --simDR_generic_lights_switch[5]    CABIN LIGHT
    --simDR_generic_lights_switch[6]    Stair lights
    --simDR_generic_lights_switch[7]    Threshold light
    simDR_switch_panel_brightness_ratio[1] = 0       --Indirect panel lights
    simDR_switch_instr_brightness_ratio[2] = 0       --Pilot Flight Instrument Lights
    simDR_switch_instr_brightness_ratio[3] = 0       --Pilot Gyro Instrument Lights
    simDR_switch_instr_brightness_ratio[4] = 0       --Engine Instrument Lights
    simDR_switch_instr_brightness_ratio[6] = 0       --OH/SubPanel/Console Lights
    simDR_switch_instr_brightness_ratio[7] = 0       --Side Panel Lights
    simDR_switch_instr_brightness_ratio[8] = 0       --CoPilot Gyro Inst Lights
    simDR_switch_instr_brightness_ratio[9] = 0       --CoPilot Flight Instruments
    simDR_switch_instr_brightness_ratio[10] = 1      --Radio LED Brightness Control
    simDR_switch_instr_brightness_ratio[11] = 0.75   --EADI Lighting Control
    simDR_switch_instr_brightness_ratio[12] = 0.75   --EHSI Lighting Control
    simDR_switch_instr_brightness_ratio[14] = 0      --Avionics Panel Lights
    simDR_switch_instr_brightness_ratio[15] = 0.75   --
    simDR_switch_instr_brightness_ratio[30] = 1
    simDR_switch_instr_brightness_ratio[31] = 0.65
    simDR_generic_lights_switch[1] = 0		        -- WING ICE
    simDR_switch_instr_brightness_ratio[16]	= 1     -- PRE80 ALTITUDE ALERT BUTTON LIGHT
    --ICE
    simDR_ice_inlet_heat_L = 1		                                                                --IBAV8N,Jan19-21
    simDR_ice_inlet_heat_R = 1		                                                                --IBAV8N,Jan19-21
    C90DR_iceRain_windshield_antiice_switch_pos_L = 0
    C90DR_iceRain_windshield_antiice_switch_pos_R = 0
    C90DR_iceRain_fuel_vent_deice_switch_pos_L = 0
    C90DR_iceRain_fuel_vent_deice_switch_pos_R = 0
    C90DR_iceRain_surface_deice_switch_pos = 0
    pitot_left = 0
    pitot_right = 0
    --ELECTRICAL
    C90DR_ctr_sense = 1
    C90DR_gen_sense_L = 1
    C90DR_gen_sense_R = 1
    C90DR_electrical_cross_tie_switch_pos = 0			                                            --IBAV8N, Jan25-21
    --C90DR_battery_tie = 1
    C90DR_electrical_bus_sense_switch_pos = 0
    C90DR_powerplant_ign_start_switch_pos_L = 0
    C90DR_powerplant_ign_start_switch_pos_R = 0
    --PRESSURE/AC
    simDR_pressure_cabin_vvi_fpm = 477
    simDR_pressure_cabin_alt_ft	= 0
    C90.airCon.bypass_valve = 0.5
    C90DR_airCon_manual_temp_control_switch_pos = 0
    C90DR_airCon_cabin_temp_dial = 0.58     --71degF
    C90DR_airCon_elec_heat_switch_pos = 0
    --SUN VISORS
    C90DR_pilot_shade_flip = 1
    C90DR_copilot_shade_flip = 1
    --RADIO VOLUMES
    C90DR_avionics_com1_vol_control_dial = 1
    C90DR_avionics_com2_vol_control_dial = 1
    C90DR_avionics_nav1_vol_control_dial = 1
    C90DR_avionics_nav2_vol_control_dial = 1
    --ENGINE FAIL PARAMETERS
    max_torque = 2196 --for -135a engines
    max_itt = 840
    if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
        if simDR_acf_descrip == "C90B EVO GNS" then
            for i = 0, 6 do
                C90.avionics.ctl22_com1_sto_stack[i] = simDR_com1_stby_frequency
                C90.avionics.ctl22_com2_sto_stack[i] = simDR_com2_stby_frequency
            end
            for i = 0, 4 do
                C90.avionics.ctl32_nav1_sto_stack[i] = simDR_nav1_stby_frequency 
                C90.avionics.ctl32_nav2_sto_stack[i] = simDR_nav2_stby_frequency 
            end
            C90DR_avionics_adf1_vol_control_dial = 1
            simDR_radio_dme_freq_hz = C90.avionics.ctl32_nav1_sto_stack[0]
            simDR_HSI_is_arc_copilot = 0                                                                    --IBAV8N, Aug9-23, set to 0 to fix PRE HSI
        end
        for i = 0, 4 do
            C90.avionics.ctl62_adf_sto_stack[i] = 190
        end
        --EFIS/AP
        C90DR_avionics_EFIS_eadi_brightness         = 0.85
        C90DR_avionics_EFIS_ehsi_brightness         = 1
        C90DR_avionics_EFIS_pre_loc_crs             = 360   --IBAV8N, Apr12-22
        C90DR_avionics_EFIS_pre_vor_crs             = 360   --IBAV8N, Apr12-22
        C90DR_avionics_EFIS_pre_loc_active          = 0     --IBAV8N, Apr12-22
        C90DR_avionics_EFIS_pre_vor_active          = 0     --IBAV8N, Apr12-22
        C90DR_avionics_nav_data_sel_dial_pos		= 1     -- pilotmarcog display wind direction
        C90DR_avionics_EFIS_map_mode_sel_dial_pos   = 2
        simDR_EFIS_map_range                        = 3     -- pilotmarcog changed from 1 to 3
        simDR_EFIS_1_sel_pilot                      = 1
        simDR_EFIS_2_sel_pilot                      = 1
        C90_EFIS_map_mode()
        simDR_ehsi_range                            = 3
        simDR_EFIS_fix_on 			                = 0
        radar_failed                                = 0
        C90DR_avionics_crs_sensor_sel_dial_pos      = 1
        C90CMD_avionics_crs_sensor_sel_dial_up:once()
        C90DR_avionics_crs_sel_cycle_active	        = 0
        simDR_autopilot_vvi_dial_fpm                = 0
        C90DR_autopilot_turn_knob                   = 0
        C90DR_autopilot_turn_knob_pos               = 0
        C90DR_avionics_EFIS_et_timer_status	= STOP
        --RESET FD ANNUNCIATOR ARRAYS                       --IBAV8N, Apr23-22
        for i = 0, 5 do
            C90.autopilot.fd_saved[i] = 0
            C90.autopilot.fd_test_timer[i] = 0
            C90.autopilot.fd_ref[i] = 0
        end
        --AUDIO PANEL
        C90DR_avionics_mic_sel_dial_pos_pilot = 0
        C90DR_avionics_auto_comm_switch_pos_pilot = 1
        C90DR_avionics_master_vol_ctrl_dial_pilot = 1
        C90DR_avionics_audio_spkr_switch_pos_pilot = 0
        C90DR_avionics_mkr_audio_bkn1_switch_pos_pilot = 1
        C90DR_avionics_hot_intph_switch_pos = 1
        C90DR_avionics_paging_vol_dial = 0.5
        C90DR_avionics_interphone_vol_dial = 0.45
        C90DR_avionics_dme_vol_dial = 0.35
        C90DR_avionics_mkr_bkn_vol_dial = 0.45
        C90DR_avionics_auto_comm_switch_pos_copilot = 1
        C90DR_avionics_mkr_audio_bkn1_switch_pos_copilot = 1
        C90DR_avionics_master_vol_ctrl_dial_copilot = 1
        simCMD_xmit_audio_com1_man:once()
        --IND42
        C90DR_avionics_ind42_dash = "----"
        C90DR_avionics_ind42_channel = 1
        C90DR_avionics_ind42_mode = 0
        --NAV2
        simDR_hsi_course_copilot = 0                                                                    --Might cause a problem with GTN
        --INCLINOMETER (EADI)
        local inclinometer_spill_values_L 	= {0.92, 0.91, 0.69, 0, 0.08, 0.81915, 0.88, -0.12, 0}
        local inclinometer_spill_values_R 	= {0.92, 0.91, 0.69, 0, 0.08, 0.81915, -0.88, -0.12, 0}
        local alt_alert_spill_values		= {1, 0.42, 0, 0, 0.06, 1, 0, 0, 0}
        for i = 0, 8 do
            C90DR_lighting_inclinometer_spill_L[i] 	= inclinometer_spill_values_L[i+1]
            C90DR_lighting_inclinometer_spill_R[i] 	= inclinometer_spill_values_R[i+1]
	        C90DR_lighting_alt_alert_spill[i]		= alt_alert_spill_values[i+1]
        end
        -- RADAR
        simDR_EFIS_weather_mode = 2
        simDR_EFIS_weather_sector_width = 60
        simDR_EFIS_antenna_limit = 60
        simDR_EFIS_weather_auto_tilt = 1
    else
        simDR_battery_2 = 0
    end

    --COLD AND DARK
    if simDR_startup_running == 0 then
        print("EVO: 15. Flight is Cold & Dark")
        C90.start_running = 0
        C90DR_ovh_master = 0
        C90DR_avionics_EFIS_aux_pwr_on_switch_pos = 0
        simDR_engine_antiice_left = 0
		simDR_engine_antiice_right = 0
        C90DR_electrical_gen_L_switch_pos = -1
        C90DR_electrical_gen_R_switch_pos = -1
        C90DR_gen_tie_L = 0
        C90DR_gen_tie_R = 0
	    C90DR_electrical_inverter_switch_pos = 0
	    simDR_inverter_on[0] = 0
	    simDR_inverter_on[1] = 0
        C90DR_electrical_auto_ignition_switch_pos_L = 0
		C90DR_electrical_auto_ignition_switch_pos_R = 0
        C90DR_fltctrl_elev_trim_control_switch_pos = 0
        simDR_electric_trim = 0
        simDR_mixture_ratio_L = 0
        simDR_mixture_ratio_R = 0
        C90DR_avionics_on_sw_pos = 0				    --IBAV8N, Jan25-21
        C90DR_avionics_ind42_power_switch_pos = 0
        simDR_com1_power = 0                            --IBAV8N, Jan19-21
        simDR_nav1_power = 0
        simDR_com2_power = 0
        simDR_nav2_power = 0
        simDR_transponder_power = 0
        simDR_adf1_power = 0
        simDR_adf2_power = 0
        C90DR_avionics_gps_power_switch_pos = 0
        simDR_gps530_power = 0
		simDR_gps430_power = 0
        C90DR_airCon_cabin_temp_mode_dial_pos = 0
	    simDR_generic_lights_switch[2] = 0		        -- RECOG
	    simDR_generic_lights_switch[3] = 0		        -- TAIL FLOOD
        C90DR_lighting_cabin_brt_dim_switch_pos = -1
        C90DR_imc_cockpit_divider_door = 1  --cockpit door open
        run_after_time(cabin_temp_cold_and_dark, 0.1)   --IBAV8N, Jan17-24, assume the plane has spent the night on the ramp, cabin will be OAT.
    --ENGINES RUNNING
    elseif simDR_startup_running == 1 then
        print("EVO: 15. Flight is Engines Running")
        C90.start_running = 1                          --IBAV8N, Jan4-21 Set a value that survives unload_aircraft
        C90DR_ovh_master = 1
        simDR_cabindoor = 0
        C90DR_electrical_gen_L_switch_pos = 0
        C90DR_electrical_gen_R_switch_pos = 0
        simDR_generator_on_L = 1
        simDR_generator_on_R = 1
        C90DR_gen_tie_L = 1
        C90DR_gen_tie_R = 1
        C90DR_electrical_auto_ignition_switch_pos_R = 1
		C90DR_electrical_auto_ignition_switch_pos_L = 1
        simDR_fuel_firewall_vlv_L = 0
        simDR_fuel_firewall_vlv_R = 0
        C90DR_fuel_firewall_switch_guard_L = 0
        C90DR_fuel_firewall_switch_guard_R = 0
        simDR_auto_crossfeed = 1             --IBAV8N, Jan24-22, set to on for engines running
        simDR_mixture_ratio_L = 0.5
        simDR_mixture_ratio_R = 0.5
        C90DR_pneumatic_bleed_air_switch_pos_L = 1
	    C90DR_pneumatic_bleed_air_switch_pos_R = 1
	    simDR_generic_lights_switch[2] = 1		        -- RECOG
	    simDR_generic_lights_switch[3] = 1		        -- TAIL FLOOD
        C90DR_lighting_cabin_brt_dim_switch_pos = 0
        simDR_generic_lights_switch[5] = 0.5            --CABIN LIGHTS
        C90DR_lighting_no_smoke_fsb_switch_pos = 1
        C90DR_airCon_cabin_temp_mode_dial_pos = 1
        C90.airCon.cabin_temp = 71
        C90DR_avionics_gps_power_switch_pos = 1
        simDR_com1_power = 1                            --IBAV8N, Jan19-21
        simDR_com2_power = 1
        simDR_nav1_power = 1
        simDR_nav2_power = 1
        simDR_transponder_power = 1
        C90DR_fltctrl_rudder_boost_switch_pos = 1
        C90CMD_fltctrl_rudder_boost_switch_up:once()
        C90DR_fltctrl_elev_trim_control_switch_pos = 1
        simDR_electric_trim = 1
        C90DR_avionics_on_sw_pos = 1				--IBAV8N, Jan25-21
	    C90CMD_avionics_EFIS_aux_pwr_switch_up:once()
        simDR_prop_rot_speed_actuator[0] = 201.59
        simDR_prop_rot_speed_actuator[1] = 201.59
        C90DR_imc_cockpit_divider_door = 0  --cockpit door closed
        if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
            C90DR_electrical_inverter_switch_pos = 1
	        simDR_inverter_on[0] = 1
	        simDR_inverter_on[1] = 0
	        C90DR_avionics_ind42_power_switch_pos = 1
            simDR_adf1_power = 2
            simDR_adf2_power = 2
            simDR_gps530_power = 1
		    simDR_gps430_power = 1
            C90DR_avionics_EFIS_power_switch_pos = 1
	        C90CMD_avionics_EFIS_power_switch_up:once()
            C90DR_avionics_EFIS_fd_switch_pos = 1
        end
    end

    if simDR_acf_descrip == "C90B EVO GNS" then
        run_after_time(restore_gns_settings,0.1)
        run_after_time(gns_overrides, 0.12)
    --elseif simDR_acf_descrip == "C90B EVO GTN" then
    --    run_after_time(restore_gtn_settings,0.1)
    --    run_after_time(gtn_overrides, 0.12)
    elseif simDR_acf_descrip == "C90B - G1000, Blackhawk" then
        run_after_time(restore_g1000_settings,0.1)
        run_after_time(g1000_overrides, 0.12)
    end

    run_after_time(C90_flight_start_DeferredInit, 0.5)

    if simDR_acf_descrip == "C90B - G1000, Blackhawk" then
	    simDR_inverter_on[0] = 1
        C90DR_autopilot_altSel100_switch_pos = 1
        simDR_com2_power = 1
        simDR_nav2_power = 1
        simDR_adf1_audio_vol = 0                --this plane has no ADF
    else
        run_at_interval(C90_warning_EFIS_aux, 0.25)
        autocomm()
        C90_EFIS_map_mode()
    end
    C90_rudderboost_check()
    C90_firewall_guards()
    C90_gear_handle_DRhandler()
    C90_windshield_anti_ice()
    run_at_interval(ac_compressor, 10)              -- AIR CONDITIONING/PRESSURE        --IBAV8N, Jan7-22
    run_at_interval(one_battery, 10)                -- ELECTRICAL                       --IBAV8N, Jan25-21
    --run_at_interval(xpilot, 10)                   -- will add this when cockpit.obj gets updated
    run_at_interval(flaps, 5)                       -- FAILURES
    run_at_interval(pilots_onboard, 5)              -- SYS                              --IBAV8N, Aug23-23
    run_at_interval(eng_fail, 5)                    -- FAILURES
    run_at_interval(gear_check_down, 3)             -- FAILURES                         --IBAV8N, May25-21
    run_at_interval(pitotheattimer, 3)              -- PNEUMICE
    run_at_interval(ties_gens_status, 0.125)        -- ELECTRICAL                       --IBAV8N, Nov28-23

    print("EVO: 16. Callbacks Scheduled.")
end

function after_physics()
    if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
        -- ELECTRICAL
        GNS_GTN_avionics_power()
        -- AVIONICS
	    C90_EHSI_course_select()
	    C90_radio_lat_dev_type()
	    C90_radio_altitude()
        C90_ttg_time()                                                  --IBAV8N, Feb26-21
	    -- AUTOPILOT
        C90_autopilot_annun()
	    C90_ap_yd_disco()
	    C90_ap_altitude_alert()
	    C90_autopilot_fd_monitor()
	    C90_autopilot_groundSelfTest()
	    C90_warning_altitude_alert()
    else
        -- ELECTRICAL
        G1000_avionics_power()
    end
    -- AVIONICS
    C90_avionics_audio_vol()
	-- ELECTRICAL
    C90_electrics()
	-- LIGHTING
	C90_lighting_annun()
	-- PNEUMATICS/ANTI-ICE
	C90_pneumatic_pressure()
	C90_boots_icing_status()
	-- AIR CONDITIONING/PRESSURE
	C90_cabin_air_temp()
    C90_cabin_pressure()
	-- WARNING
	C90_warning_annunciators()
    -- PROPS
    C90_beta()

    if C90.test == 0 then print("EVO: 17. After physics routines executing.  Load successful.") C90.test = 1 end --only do this once
end

function after_replay()
    C90DR_gear_handle = simDR_gear_handle_down
    C90DR_lighting_annun_master_warning = 0
    C90DR_lighting_annun_master_caution = 0
    C90DR_electrical_gen_L_switch_pos = 0
    C90DR_electrical_gen_R_switch_pos = 0
    simDR_gps530_power = C90DR_avionics_gps_power_switch_pos
    simDR_gps430_power = C90DR_avionics_gps_power_switch_pos
    simDR_generator_on_L = 1
    simDR_generator_on_R = 1
    C90DR_avionics_on_sw_pos = 1
    pilots_onboard()
    C90_electrics()
    C90_beta()
    if simDR_acf_descrip ~= "C90B - G1000, Blackhawk" then
        C90DR_avionics_EFIS_power_switch_pos = 1
        GNS_GTN_avionics_power()
	    C90_radio_altitude()
    else
        G1000_avionics_power()
    end
end

--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--
dofile("C90_sys10_electrical.lua")
dofile("C90_sys11_settings.lua")
dofile("C90_sys12_failures.lua")
dofile("C90_sys20_pneumIce.lua")
dofile("C90_sys30_airConPress.lua")
dofile("C90_sys40_avionics.lua")
dofile("C90_sys50_autopilot.lua")
dofile("C90_sys60_warning.lua")
dofile("C90_sys70_lighting.lua")

