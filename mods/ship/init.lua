local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

ship = {}
--------------------------------------
--Allows ship_core to be placed on air
--------------------------------------



dofile(mod_path.."/misc.lua")
dofile(mod_path.."/components.lua")
dofile(mod_path.."/shipentity.lua")
