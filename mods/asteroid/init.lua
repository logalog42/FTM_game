-- Parameters

local YMIN = -31000
local YMAX = 31000
local XMIN = -31000
local XMAX = 31000
local ZMIN = -31000
local ZMAX = 31000

local ASCOT = 1.0 -- Asteroid / comet nucleus noise threshold.
local STOT = 0.125 -- Asteroid stone threshold.
local COBT = 0.05 -- Asteroid cobble threshold.
local GRAT = 0.02 -- Asteroid gravel threshold.
local ICET = 0.05 -- Comet ice threshold.

local DEBUG = true

-- 3D Perlin noise for large structures

local np_large = {
	offset = 0,
	scale = 3,
	spread = {x = 100, y = 100, z = 100},
	seed = -83928935,
	octaves = 1,
	persist = 0.6,
	lacunarity = 2.0,
	--flags = ""
}

-- Do files

dofile(minetest.get_modpath("asteroid").."/nodes.lua")


-- Constants

local c_air = minetest.CONTENT_AIR

local c_stone = minetest.get_content_id("asteroid:stone")
local c_cobble = minetest.get_content_id("asteroid:cobble")
local c_gravel = minetest.get_content_id("asteroid:gravel")
local c_dust = minetest.get_content_id("asteroid:dust")
local c_waterice = minetest.get_content_id("asteroid:waterice")
local c_snowblock = minetest.get_content_id("asteroid:snowblock")

-- Globalstep function for skybox, physics override, light override

local skybox_space = {
	"asteroid_skybox_ypos.png",
	"asteroid_skybox.png",
	"asteroid_skybox.png",
	"asteroid_skybox.png",
	"asteroid_skybox.png",
	"asteroid_skybox.png"
}

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		if math.random() < 0.03 then -- set gravity, skybox and override light
			local ppos = player:getpos()
			player:set_sky({r = 0, g = 0, b = 0, a = 0}, "skybox", skybox_space)
			player:override_day_night_ratio(1)
		end
	end
end)


-- Initialise noise objects to nil

local nobj_large = nil

-- Localise noise buffers

local nbuf_large

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.x < XMIN or maxp.x > XMAX
			or minp.y < YMIN or maxp.y > YMAX
			or minp.z < ZMIN or maxp.z > ZMAX then
		return
	end

	local t1 = os.clock()

	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z

	local sidelen = x1 - x0 + 1
	local chulens = {x = sidelen, y = sidelen, z = sidelen}
	local minpos = {x = x0, y = y0, z = z0}

	nobj_large = nobj_large or minetest.get_perlin_map(np_large, chulens)

	local nvals_large = nobj_large:get3dMap_flat(minpos, nbuf_large)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()

	local ni = 1
	for z = z0, z1 do
	for y = y0, y1 do
		local vi = area:index(x0, y, z)
		for x = x0, x1 do
			local n_large = nvals_large[ni]
			local nabs_large = math.abs(n_large)
			if nabs_large > ASCOT then -- if below surface
				local comet = n_large < -ASCOT
				local nlargedep = nabs_large - ASCOT -- zero at surface, positive beneath
				if not comet or (comet and nlargedep > (math.random() / 2) + ICET) then
					-- asteroid or asteroid materials in comet
					if nlargedep >= STOT then
						data[vi] = c_stone

					elseif nlargedep >= COBT then
						data[vi] = c_cobble
					elseif nlargedep >= GRAT then
						data[vi] = c_gravel
					else
						data[vi] = c_dust
					end
				else -- comet materials
					if nlargedep >= ICET then
						data[vi] = c_waterice
					else
						data[vi] = c_snowblock
					end
				end
		end

			ni = ni + 1
			vi = vi + 1
		end
	end
	end

	vm:set_data(data)
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:write_to_map(data)

	local chugent = math.ceil((os.clock() - t1) * 1000)
	if DEBUG then
		print ("[asteroid] chunk generation "..chugent.." ms")
	end
end)
