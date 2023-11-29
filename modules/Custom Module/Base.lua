--Load datarefs
local is_helicopter = globalProperty("sim/aircraft2/metadata/is_helicopter")
local joy_mapped_axis_avail = globalProperty("sim/joystick/joy_mapped_axis_avail")
local joy_mapped_axis_value = globalProperty("sim/joystick/joy_mapped_axis_value")
local override_joystick_pitch = globalProperty("sim/operation/override/override_joystick_pitch")
local override_joystick_roll = globalProperty("sim/operation/override/override_joystick_roll")
local override_joystick_heading = globalProperty("sim/operation/override/override_joystick_heading")
local yoke_pitch_ratio = globalProperty("sim/joystick/yoke_pitch_ratio")
local yoke_roll_ratio = globalProperty("sim/joystick/yoke_roll_ratio")
local yoke_heading_ratio = globalProperty("sim/joystick/yoke_heading_ratio")
local total_running_time_sec = globalProperty("sim/time/total_running_time_sec")
local elevator_trim = globalProperty("sim/cockpit2/controls/elevator_trim")
local aileron_trim = globalProperty("sim/cockpit2/controls/aileron_trim")
local rudder_trim = globalProperty("sim/cockpit2/controls/rudder_trim")
--Create Datarefs
local pitch_offset = createGlobalPropertyf("pom/HeliTrim/Base/pitch_offset",0)
local roll_offset = createGlobalPropertyf("pom/HeliTrim/Base/roll_offset",0)
local yaw_offset = createGlobalPropertyf("pom/HeliTrim/Base/yaw_offset",0)
local trim_pedals =  createGlobalPropertyi("pom/HeliTrim/Base/trim_pedals",0)
local trim_cyclic =  createGlobalPropertyi("pom/HeliTrim/Base/trim_cyclic",0)
local slow_reset_rate_sec = createGlobalPropertyf("pom/HeliTrim/Base/slow_reset_rate_sec",5)
local time_delta = createGlobalPropertyd("pom/HeliTrim/Base/time_delta",0)
local reset_trims = createGlobalPropertyi("pom/HeliTrim/Base/reset_trims",0)
local heli_beep = createGlobalPropertyi("pom/HeliTrim/Base/heli_beep",1)
local trim_rate_sec = createGlobalPropertyf("pom/HeliTrim/Base/trim_rate_sec",12)
--Create commands
local TrimButton = sasl.createCommand("pom/HeliTrim/Base/TrimButton", "HeliTrim button")
local TrimReset = sasl.createCommand("pom/HeliTrim/Base/TrimReset", "HeliTrim instant reset")
local SlowTrimReset = sasl.createCommand("pom/HeliTrim/Base/SlowTrimReset", "HeliTrim gradual reset")
---load commands
local pitch_trim_up = sasl.findCommand("sim/flight_controls/pitch_trim_up")
local pitch_trim_down = sasl.findCommand("sim/flight_controls/pitch_trim_down")
local aileron_trim_left = sasl.findCommand("sim/flight_controls/aileron_trim_left")
local aileron_trim_right = sasl.findCommand("sim/flight_controls/aileron_trim_right")
local rudder_trim_left = sasl.findCommand("sim/flight_controls/rudder_trim_left")
local rudder_trim_right = sasl.findCommand("sim/flight_controls/rudder_trim_right")

--Create variables
local cur_t = 0
local old_t = 0
local pitch = 0
local roll = 0
local yaw = 0


function fTrimButton(phase)
	if phase == SASL_COMMAND_BEGIN then
		pitch = get(joy_mapped_axis_value,2) + get(pitch_offset)
		roll = get(joy_mapped_axis_value,3) + get(roll_offset)
		yaw = get(joy_mapped_axis_value,4) + get(yaw_offset)
	elseif phase == SASL_COMMAND_CONTINUE then
		if get(trim_cyclic) == 1 then
			set(pitch_offset,pitch-get(joy_mapped_axis_value,2))
			set(roll_offset,roll-get(joy_mapped_axis_value,3))
		end
		if get(trim_pedals) == 1 then
			set(yaw_offset,yaw-get(joy_mapped_axis_value,4))
		end
	end
	return 0
end

function fTrimReset(phase)
	if phase == SASL_COMMAND_BEGIN then
		set(pitch_offset,0)
		set(roll_offset,0)
		set(yaw_offset,0)
		if get(reset_trims) == 1 then
			set(elevator_trim,0)
			set(aileron_trim,0)
			set(rudder_trim,0)
		end
	end
	return 0
end

function fSlowTrimReset(phase)
	if phase == SASL_COMMAND_CONTINUE then
		if get(reset_trims) == 1 then
			set(pitch_offset,Anim(get(pitch_offset),0,1/get(slow_reset_rate_sec)))
			set(elevator_trim,Anim(get(elevator_trim),0,1/get(slow_reset_rate_sec)/2))
			
			set(roll_offset,Anim(get(roll_offset),0,1/get(slow_reset_rate_sec)))
			set(aileron_trim,Anim(get(aileron_trim),0,1/get(slow_reset_rate_sec)/2))
			
			set(yaw_offset,Anim(get(yaw_offset),0,1/get(slow_reset_rate_sec)))
			set(rudder_trim,Anim(get(rudder_trim),0,1/get(slow_reset_rate_sec)/2))
		
		else
			set(pitch_offset,Anim(get(pitch_offset),0,1/get(slow_reset_rate_sec)))
			set(roll_offset,Anim(get(roll_offset),0,1/get(slow_reset_rate_sec)))
			set(yaw_offset,Anim(get(yaw_offset),0,1/get(slow_reset_rate_sec)))
		end
	end
	return 0
end

function update()
if get(is_helicopter) == 1 then
	--time delta
	cur_t = get(total_running_time_sec)
	set(time_delta,math.abs(cur_t-old_t))
	old_t = cur_t
	--
	if get(trim_cyclic) == 1 then
		set(override_joystick_pitch,1)
		set(override_joystick_roll,1)
		set(yoke_pitch_ratio,get(joy_mapped_axis_value,2)+get(pitch_offset))
		set(yoke_roll_ratio,get(joy_mapped_axis_value,3)+get(roll_offset))
	else
		set(override_joystick_pitch,0)
		set(override_joystick_roll,0)
	end
	if get(trim_pedals) == 1 then
		set(override_joystick_heading,1)
		set(yoke_heading_ratio,get(joy_mapped_axis_value,4)+get(yaw_offset))
	else
		set(override_joystick_heading,0)
	end
end
end

function fpitch_trim_up()
	if get(heli_beep) == 1 and get(is_helicopter) == 1 and get(trim_cyclic) == 1 then
		add(pitch_offset,(1/get(trim_rate_sec))*get(time_delta))
		return 0
	end
end
function fpitch_trim_down()
	if get(heli_beep) == 1 and get(is_helicopter) == 1 and get(trim_cyclic) == 1 then
		add(pitch_offset,(1/get(trim_rate_sec))*-get(time_delta))
		return 0
	end
end
function faileron_trim_left()
	if get(heli_beep) == 1 and get(is_helicopter) == 1 and get(trim_cyclic) == 1 then
		add(roll_offset,(1/get(trim_rate_sec))*-get(time_delta))
		return 0
	end
end
function faileron_trim_right()
	if get(heli_beep) == 1 and get(is_helicopter) == 1 and get(trim_cyclic) == 1 then
		add(roll_offset,(1/get(trim_rate_sec))*get(time_delta))
		return 0
	end
end
function frudder_trim_left()
	if get(heli_beep) == 1 and get(is_helicopter) == 1 and get(trim_pedals) == 1 then
		add(yaw_offset,(1/get(trim_rate_sec))*-get(time_delta))
		return 0
	end
end
function frudder_trim_right()
	if get(heli_beep) == 1 and get(is_helicopter) == 1 and get(trim_pedals) == 1 then
		add(yaw_offset,(1/get(trim_rate_sec))*get(time_delta))
		return 0
	end
end

function onPlaneUnloaded()
	set(override_joystick_pitch,0)
	set(override_joystick_roll,0)
	set(override_joystick_heading,0)
end

function Anim(anim,target,rate)
	if math.abs(target-anim) < rate* get(time_delta) then
		anim = target
	elseif target > anim then
		anim = anim + rate * get(time_delta)
	else
		anim = anim - rate * get(time_delta)
	end
	return anim
end

--register command handlers
sasl.registerCommandHandler(TrimButton, 0, fTrimButton)
sasl.registerCommandHandler(TrimReset, 0, fTrimReset)
sasl.registerCommandHandler(SlowTrimReset, 0, fSlowTrimReset)

sasl.registerCommandHandler(pitch_trim_up, 1, fpitch_trim_up)
sasl.registerCommandHandler(pitch_trim_down, 1, fpitch_trim_down)
sasl.registerCommandHandler(aileron_trim_left, 1, faileron_trim_left)
sasl.registerCommandHandler(aileron_trim_right, 1, faileron_trim_right)
sasl.registerCommandHandler(rudder_trim_left, 1, frudder_trim_left)
sasl.registerCommandHandler(rudder_trim_right, 1, frudder_trim_right)

