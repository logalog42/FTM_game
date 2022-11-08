local noiseparams = {
	offset = 0.0,
	scale = 1.0,
	spread = vector.new(10, 10, 10),
	seed = 0,
	octaves = 2,
	persistence = 0.5,
	lacunarity = 2.0,
	flags = "defaults",
}

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

  local time1 = minetest.get_us_time()

  local startpos = minpos
  local endpos = {x = x1, y = y1, z = z1}

  local y_max = endpos.y - startpos.y
  local vmanip, emin, emax, vdata, vdata2, varea
  local content_test_node, content_test_node_low

  vmanip = VoxelManip(startpos, endpos)
  emin, emax = vmanip:get_emerged_area()
  vdata = vmanip:get_data()
  vdata2 = vmanip:get_param2_data()
  varea = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

  content_test_node = minetest.get_content_id("default:stone")


  local perlin_map
  -- Initialize Perlin map
  -- The noise values will come from this
  local perlin_map_object = PerlinNoiseMap(noiseparams, chulens)
  perlin_map = perlin_map_object:get_3d_map(startpos)

  local x_max, z_max
  x_max = endpos.x - startpos.x
  z_max = endpos.z - startpos.z

  -- Main loop (time-critical!)
  for x=0, x_max do
  for y=0, y_max do
  for z=0, z_max do
    -- Note: This loop has been optimized for speed, so the code
    -- might not look pretty.
    -- Be careful of the performance implications when touching this
    -- loop

    -- Get Perlin value at current pos
    local abspos
    abspos = {
      x = startpos.x + x,
      y = startpos.y + y,
      z = startpos.z + z,
    }
    -- Apply sidelen transformation (pixelize)
    local indexpos = {
      x = abspos.x - startpos.x + 1,
      y = abspos.y - startpos.y + 1,
      z = abspos.z - startpos.z + 1,
    }

    -- Finally get the noise value
    local perlin_value
    perlin_value = perlin_map[indexpos.z][indexpos.y][indexpos.x]

    -- Get vmanip index
    local index = varea:indexp(abspos)
    if not index then
      return
    end

    -- Set node and param2 in vmanip
    if perlin_value >= 1.47 then
      vdata[index] = content_test_node
    end
  end
  end
  end

  -- Write all the changes to map
  vmanip:set_data(vdata)
  vmanip:write_to_map()

  local time2 = minetest.get_us_time()
  local timediff = time2 - time1
  minetest.log("verbose", "[perlin_explorer] Noisechunk calculated/generated in "..timediff.." µs")
end
)
