minetest.register_on_generated(function(minp, maxp, seed)
  --Start point of area generated
  local x0 = minp.x
  local y0 = minp.y
  local z0 = minp.z

  --End point  of area generated
  local x1 = maxp.x
  local y1 = maxp.y
  local z1 = maxp.z

  local sidelen = x1 - x0 + 1
  local chulens = {x = sidelen, y = sidelen, z = sidelen}
  local minpos = {x = x0, y = y0, z = z0}

  -- 3D noise for rough terrain

  local np_planets = {
    offset = -1.59,
    scale = 1,
    spread = {x = 20, y = 20, z = 20},
    seed = 92,
    octaves = 5,
    persist = 0.5
  }

  -- Voxel Area

   local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
   local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
   local data = vm:get_data()

   --get side length of the current mapgen block
   local side_length = maxp.x - minp.x + 1
   local map_lengths_xyz = {x=side_length, y=side_length, z=side_length}
   local perlin_map = minetest.get_perlin_map(np_planets, map_lengths_xyz):get_3d_map(minp)

   --loop
   local perlin_index = 1
   for z = minp.z, maxp.z do
      for y = minp.y, maxp.y do
         for x = minp.x, maxp.x do
            local vi = area:index(x, y, z)
             minetest.log("ERROR[Main] "..tostring(perlin_map[vi]))
             --more efficient coding - x++
             perlin_index = perlin_index + 1
             vi = vi + 1
         end
         --go back, one side_length
         perlin_index = perlin_index - side_length
      end
      --go forward, one side_length
      perlin_index = perlin_index + side_length
   end
end
)
