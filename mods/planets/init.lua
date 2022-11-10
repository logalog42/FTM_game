corenodes = {}
planetsbuilding = {}

function distance( first, second)
  return math.sqrt( (second.x-first.x)^2 + (second.y-first.y)^2 + (second.z-first.z)^2)
end

function seperation(corenodes, currentpos)
  if corenodes[1] == nil then
    return true
  else
    for node, v in ipairs(corenodes) do
      if distance( v, currentpos) >= 500 then
        return true
      else
        return false
      end
    end
  end
end

function buildplanet(planetcore)
  minetest.log("[INFO]", "In buildplanet function")
  local endpos = {
    x = planetcore.x + 64,
    y = planetcore.y + 64,
    z = planetcore.z + 64
  }
  local startpos = {
    x = planetcore.x - 64,
    y = planetcore.y - 64,
    z = planetcore.z - 64
  }

  local voxelm = VoxelManip(startpos, endpos)
  local innercore = minetest.get_content_id("default:stone")
  local emin, emax = voxelm:get_emerged_area()
  local vdata = voxelm:get_data()
  local varea = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

  for x = 0, 64 do
    for y = 0, 64 do
      for z = 0, 64 do
        local currentpos = {
          x = planetcore.x + x,
          y = planetcore.y + y,
          z = planetcore.z + z
        }
        local quad2 = {
          x = currentpos.x,
          y = 0 - currentpos.y,
          z = currentpos.z
        }
        local quad3 = {
          x = currentpos.x,
          y = - currentpos.y,
          z = - currentpos.z
        }
        local quad4 = {
          x = currentpos.x,
          y = currentpos.y,
          z = - currentpos.z
        }
        local quad5 = {
          x = - currentpos.x,
          y = currentpos.y,
          z = currentpos.z
        }
        local quad6 = {
          x = - currentpos.x,
          y = - currentpos.y,
          z = currentpos.z
        }
        local quad7 = {
          x = - currentpos.x,
          y = - currentpos.y,
          z = - currentpos.z
        }
        local quad8 = {
          x = - currentpos.x,
          y = currentpos.y,
          z = - currentpos.z
        }

        local quads = {currentpos, quad2} --, quad3, quad4, quad5, quad6, quad7, quad8}

        if distance(planetcore, currentpos) < 64 then
          for quad, v in ipairs(quads) do
            -- Get vmanip index
            local index = varea:index(v.x, v.y, v.z)
            if not index then
              return
            end

            -- Set node in vmanip
              vdata[index] = innercore
          end
        end
      end
    end
  end

  voxelm:set_data(vdata)
  voxelm:write_to_map()
  minetest.log("[INFO]", "Exiting planetsbuilding")
end


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

    -- Set node in vmanip
    if perlin_value >= 1.47 and seperation(corenodes, abspos) then
      vdata[index] = content_test_node
      table.insert(corenodes, abspos)
      buildplanet(abspos)
    end
  end
  end
  end

  -- Write all the changes to map
  vmanip:set_data(vdata)
  vmanip:write_to_map()
end
)
