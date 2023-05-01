--Load datarefs
local trim_pedals =  globalProperty("pom/HeliTrim/Base/trim_pedals")
local trim_cyclic =  globalProperty("pom/HeliTrim/Base/trim_cyclic")
local slow_reset_rate_sec = globalProperty("pom/HeliTrim/Base/slow_reset_rate_sec")
local reset_trims = globalProperty("pom/HeliTrim/Base/reset_trims")
local heli_beep = globalProperty("pom/HeliTrim/Base/heli_beep")
local trim_rate_sec = globalProperty("pom/HeliTrim/Base/trim_rate_sec")
local yaw_offset = globalProperty("pom/HeliTrim/Base/yaw_offset")

local elevator_trim = globalProperty("sim/cockpit2/controls/elevator_trim")
local aileron_trim = globalProperty("sim/cockpit2/controls/aileron_trim")
local rudder_trim = globalProperty("sim/cockpit2/controls/rudder_trim")

--Create Datarefs
--local wab_lang = createGlobalPropertyi("pom/z43/WaB/wab_language",1) --1-Cz, 2 - En

--Create commands

---load commands
local saveconfig = sasl.findCommand("pom/HeliTrim/config/saveconfig")
--Create variables

local mouse_pressed = 0
local mouse_y_when_press = 0
local saveclick = 0
local resetclick = 0
local x = size[1]
local y = size[2]
local pedals = ""
local cyclic = ""
local resettrim = ""
local trimhat = ""
--- 
local grey	= {0.5,0.5,0.5,1}
local white	= {1,1,1,1}
local black = {0.2,0.2,0.2,1}
local roboto = loadFont(getXPlanePath() .. "Resources/fonts/Roboto-Regular.ttf")




function draw()
	sasl.gl.drawRectangle(0,0,x,y,black)
	sasl.gl.drawText(roboto,x/2,y-50, "Reset to centre: "..string.format("%0.1f",get(slow_reset_rate_sec)) .. " sec" , 25, false, false, TEXT_ALIGN_CENTER, white)
	sasl.gl.drawRectangle(10,y-80,x-20,20,grey)
	sasl.gl.drawRectangle(11,y-79,get(slow_reset_rate_sec)*48-2,18,white)
	--
	sasl.gl.drawText(roboto,10,y-120, "Trim cyclic: " .. cyclic , 25, false, false, TEXT_ALIGN_LEFT, white)
	--
	sasl.gl.drawText(roboto,10,y-160, "Trim anti-torque pedals: " .. pedals , 25, false, false, TEXT_ALIGN_LEFT, white)
	--
	sasl.gl.drawText(roboto,10,y-200, "Reset default trim along with HeliTrim: " .. resettrim , 25, false, false, TEXT_ALIGN_LEFT, white)
	--
	sasl.gl.drawText(roboto,10,y-240, "Override default trim hat: " .. trimhat , 25, false, false, TEXT_ALIGN_LEFT, white)
	--
	sasl.gl.drawText(roboto,x/2,y-280, "Trim centre to max: "..string.format("%0.1f",get(trim_rate_sec)) .. " sec" , 25, false, false, TEXT_ALIGN_CENTER, white)
	sasl.gl.drawRectangle(10,y-310,x-20,20,grey)
	sasl.gl.drawRectangle(11,y-309,(get(trim_rate_sec)-5)*32-2,18,white)
	
	if resetclick == 0 then
		sasl.gl.drawRectangle(100,y-360,300,30,white)
		sasl.gl.drawText(roboto,x/2,y-355, "CLEAR DEFAULT TRIM" , 25, true, false, TEXT_ALIGN_CENTER, black)
	else
		sasl.gl.drawText(roboto,x/2,y-355, "CLEAR DEFAULT TRIM" , 25, true, false, TEXT_ALIGN_CENTER, white)
	end
	
	if saveclick == 0 then
		sasl.gl.drawRectangle(156,15,188,30,white)
		sasl.gl.drawText(roboto,x/2,20, "SAVE TO FILE" , 25, true, false, TEXT_ALIGN_CENTER, black)
	else
		sasl.gl.drawText(roboto,x/2,20, "SAVE TO FILE" , 25, true, false, TEXT_ALIGN_CENTER, white)
	end
	
end

function onMouseDown (component,X,Y,button)
	if button == MB_LEFT then
		mouse_pressed = 1
		mouse_y_when_press = Y
		--trim cyclic
		if X > 143 and X < 172 and Y > y-128 and Y < y-94 then
			set(yaw_offset,0)
			flip(trim_cyclic)
		end
		--trim pedals
		if X > 270 and X < 315 and Y > y-168 and Y < y-134 then
			set(yaw_offset,0)
			flip(trim_pedals)
		end
		--reset trims
		if X > 436 and X < 474 and Y > y-208 and Y < y-174 then
			flip(reset_trims)
		end
		--override hat
		if X > 285 and X < 330 and Y > y-248 and Y < y-214 then
			flip(heli_beep)
		end
		--clear default trims
		if X > 100 and X < 300 and Y > y-360 and Y < y-330 then
			resetclick = 1
			set(elevator_trim,0)
			set(aileron_trim,0)
			set(rudder_trim,0)
		end
		--save config to file
		if X > 156 and X < x-156 and Y > 15 and Y < 45 then
			saveclick = 1
			sasl.commandOnce(saveconfig)
		end
	elseif button == MB_RIGHT then
		saveclick = 0
		resetclick = 0
		--print(X .. " , " .. Y)
	end
	return true
end

function onMouseUp (component,X,Y,button)
	if button == MB_LEFT then
		mouse_pressed = 0
		mouse_y_when_press = 0
		saveclick = 0
		resetclick = 0
	end
	return true
end

function onMouseWheel (component,X,Y,button,parX,parY,val)
	if X > 10 and X < x-10 and Y > y-80 and Y < y-60 then
		add(slow_reset_rate_sec,val*0.1)
		clamp(slow_reset_rate_sec,0.1,10)
	elseif X > 10 and X < x-10 and Y > y-310 and Y < y-290 then
		add(trim_rate_sec,val*0.1)
		clamp(trim_rate_sec,5,20)
	end
	return true
end

function onMouseMove (component,X,Y,button)
	if button == MB_LEFT and mouse_pressed == 1 then
		if X > 10 and X < x-10 then
			if mouse_y_when_press > y-80 and mouse_y_when_press < y-60 then
				Drag_manip(X,slow_reset_rate_sec,48,0.1,10,0)
			elseif mouse_y_when_press > y-310 and mouse_y_when_press < y-290 then
				Drag_manip(X,trim_rate_sec,32,5,20,5)
			end
		end
	end
	return true
end

function Drag_manip (X,sec,mp,lo,hi,offset)
	set(sec,((X-10)/mp)+0.06+offset)
	clamp(sec,lo,hi)

end


function update()
 --WAB_update()
	if get(trim_cyclic) == 1 then
		cyclic = "[X]"
	else
		cyclic = "[   ]"
	end
	if get(trim_pedals) == 1 then
		pedals = "[X]"
	else
		pedals = "[   ]"
	end
	if get(reset_trims) == 1 then
		resettrim = "[X]"
	else
		resettrim = "[   ]"
	end
	if get(heli_beep) == 1 then
		trimhat = "[X]"
	else
		trimhat = "[   ]"
	end
end


--register command handlers
--sasl.registerCommandHandler(g430n1_coarse_down, 0, g430n1CoarseDown)





