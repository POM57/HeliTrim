sasl.options.set3DRendering(false)
sasl.options.setAircraftPanelRendering(false)
sasl.options.setInteractivity(false)

x,y,width,height = sasl.windows.getScreenBoundsGlobal()
scale_offset = 0.05
scaleMP = 0.6

components = {
Base {},
config {}
}  


---------
local Settings_window = contextWindow {
	name			= "HeliTrim Settings",
	position		= {500, 500, 500, 440},
	maximumSize		= {1000,880},
	visible			= false,
	proportional	= true,
	vrAuto			= true,
	fbo 			= true,
	fpsLimit		= 30,
	components		= {settings{position={0, 0, 500, 440}}},
}
---------



function flip(p) 
	set(p, 1-get(p))
end
function flipa(p,pa) 
	set(p, 1-get(p,pa),pa)
end
function add(a,b)
	set(a,get(a)+b)
end
function adda(a,b,c)
	set(a,get(a,c)+b,c)
end
function clamprot(a)
	set(a,get(a)%360)
end
function clamp(a,b,c)
	if get(a) < b then
		set(a,b)
	elseif get(a) > c then
		set(a,c)
	end
end
----
function sh_settings()
	if Settings_window:isVisible() == true then
		Settings_window:setIsVisible(false)
	else
		Scale_settings ()
		Settings_window:setIsVisible(true)
	end
end

function Scale_settings ()
	getsizes()
	Settings_window:setPosition(x+50,height-((height/1080)*200+100),(height/1080)*500,(height/1080)*200)
end

function getsizes()
	x,y,width,height = sasl.windows.getScreenBoundsGlobal()
end

helitrim = sasl.appendMenuItem(PLUGINS_MENU_ID, "HeliTrim")
menu_windows = sasl.createMenu("HeliTrim", PLUGINS_MENU_ID, helitrim)
settings = sasl.appendMenuItem(menu_windows, "Settings", sh_settings)


