--load datarefs
local trim_pedals =  globalProperty("pom/HeliTrim/Base/trim_pedals")
local trim_cyclic =  globalProperty("pom/HeliTrim/Base/trim_cyclic")
local slow_reset_rate_sec = globalProperty("pom/HeliTrim/Base/slow_reset_rate_sec")
local reset_trims = globalProperty("pom/HeliTrim/Base/reset_trims")
local heli_beep = globalProperty("pom/HeliTrim/Base/heli_beep")
local trim_rate_sec = globalProperty("pom/HeliTrim/Base/trim_rate_sec")
--create datarefs


--create commands
local loadconfig = sasl.createCommand("pom/HeliTrim/config/loadconfig", 'Load HeliTrim config file')
local saveconfig = sasl.createCommand("pom/HeliTrim/config/saveconfig", 'Save HeliTrim config file')
--load commands


--creating table
config_table = {} --creates table which will contain saved config
config_table.trim_pedals = 0
config_table.trim_cyclic = 1
config_table.slow_reset_rate_sec = 5
config_table.reset_trims = 0
config_table.heli_beep = 1
config_table.trim_rate_sec = 12
--creating other variables
Path = sasl.getProjectPath ()
HasConfigBeenLoaded = 0

function update()
	if HasConfigBeenLoaded == 0 then 
		sasl.commandOnce (loadconfig)
		HasConfigBeenLoaded = 1
	end
	
end

function load_config(phase)
if phase == SASL_COMMAND_BEGIN then
	if isFileExists(Path.."/config.ini") == true then
		if sasl.readConfig(Path.."/config.ini" , "ini" , "ini") == nil then
			config_table = {}
			print ("config file empty, using default values")
			verify_config()
		else
			config_table = sasl.readConfig(Path.."/config.ini" , "ini" , "ini")
			verify_config()
		end
	else
		print("config file not found, will load default values")
		set_config()
	end
end
end


function verify_config()
if config_table == nil then
	config_table = {}
	print ("config file missing, using default values")
end
if config_table.trim_cyclic == nil then
	config_table.trim_cyclic = 1
	print ("trim_cyclic missing, using default value of 1")
end
if config_table.trim_pedals == nil then
	config_table.trim_pedals = 0
	print ("trim_pedals missing, using default value of 0")
end
if config_table.slow_reset_rate_sec == nil then
	config_table.slow_reset_rate_sec = 5
	print ("slow_reset_rate_sec missing, using default value of 5")
end
if config_table.reset_trims == nil then
	config_table.reset_trims = 0
	print ("reset_trims missing, using default value of 0")
end
if config_table.heli_beep == nil then
	config_table.heli_beep = 1
	print ("heli_beep missing, using default value of 1")
end
if config_table.trim_rate_sec == nil then
	config_table.trim_rate_sec = 12
	print ("trim_rate_sec missing, using default value of 12")
end
set_config()
end

function set_config()
--panel
set(trim_cyclic,config_table.trim_cyclic)
set(trim_pedals,config_table.trim_pedals)
set(slow_reset_rate_sec,config_table.slow_reset_rate_sec)
set(reset_trims,config_table.reset_trims)
set(heli_beep,config_table.heli_beep)
set(trim_rate_sec,config_table.trim_rate_sec)
print ("config loaded")
end


function save_config(phase)
if phase == SASL_COMMAND_BEGIN then
	config_table.trim_cyclic = get(trim_cyclic)
	config_table.trim_pedals = get(trim_pedals)
	config_table.slow_reset_rate_sec = get(slow_reset_rate_sec)
	config_table.reset_trims = get(reset_trims)
	config_table.heli_beep = get(heli_beep)
	config_table.trim_rate_sec = get(trim_rate_sec)
	
	sasl.writeConfig (Path.."/config.ini" , "ini" , config_table )
	print ("config saved")

end
end

--register command handlers

sasl.registerCommandHandler(loadconfig, 0, load_config)
sasl.registerCommandHandler(saveconfig, 0, save_config)