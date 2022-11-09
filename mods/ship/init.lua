local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

--------------------------------------
--Allows ship_core to be placed on air
--------------------------------------



dofile(mod_path.."/misc.lua")
dofile(mod_path.."/components.lua")
dofile(mod_path.."/registration.lua")

ship_names = {
  "starter",
}

for _, name in ipairs(ship_names) do
  minetest.log("[INFO]", name)
  dofile(mod_path.."/shipyard/"..name..".lua")
end
