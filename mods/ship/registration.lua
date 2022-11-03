ship = {}
local drive = lib_mount.drive

function ship.register_vehicle(name, def)
	minetest.register_entity(name, {
		terrain_type = def.terrain_type,
		collisionbox = def.collisionbox,
		can_fly = def.can_fly,
		can_go_down = def.can_go_down, -- Applies only when `can_fly` is enabled
		can_go_up = def.can_go_up, -- Applies only when `can_fly` is enabled
		player_rotation = def.player_rotation,
		driver_attach_at = def.driver_attach_at,
		driver_eye_offset = def.driver_eye_offset,
		driver_detach_pos_offset = def.driver_detach_pos_offset,
		number_of_passengers = def.number_of_passengers,
		passenger_attach_at = def.passenger_attach_at,
		passenger_eye_offset = def.passenger_eye_offset,
		passenger_detach_pos_offset = def.passenger_detach_pos_offset,

		passenger2_attach_at = def.passenger2_attach_at,
		passenger2_eye_offset = def.passenger2_eye_offset,
		passenger2_detach_pos_offset = def.passenger2_detach_pos_offset,

		passenger3_attach_at = def.passenger3_attach_at,
		passenger3_eye_offset = def.passenger3_eye_offset,
		passenger3_detach_pos_offset = def.passenger3_detach_pos_offset,

		enable_crash = def.enable_crash,
		visual = def.visual,
		mesh = def.mesh,
		textures = def.textures,
		tiles = def.tiles,
		visual_size = def.visual_size,
		stepheight = def.stepheight,

		max_speed_forward = def.max_speed_forward,
		max_speed_reverse = def.max_speed_reverse,
		max_speed_upwards = def.max_speed_upwards, -- Applies only when `can_fly` is enabled
		max_speed_downwards = def.max_speed_downwards, -- Applies only when `can_fly` is enabled

		accel = def.accel,
		braking = def.braking,
		turn_spd = def.turn_speed,
		drop_on_destroy = def.drop_on_destroy or {},
		driver = nil,
		passenge = nil,
		v = 0,
		v2 = 0,
		mouselook = false,
		physical = true,
		removed = false,
		offset = {x=0, y=0, z=0},
		owner = "",
		on_rightclick = function(self, clicker)
			if not clicker or not clicker:is_player() then
				minetest.log("ERROR[Main]", "not clicker or not clicker:is_player")
				return
			end
			-- if there is already a driver
			if self.driver then
				-- if clicker is driver detach passengers and driver
				if clicker == self.driver then
					if self.passenger then
						lib_mount.detach(self.passenger, self.offset)
					end

					if self.passenger2 then
						lib_mount.detach(self.passenger2, self.offset)
					end

					if self.passenger3 then
						lib_mount.detach(self.passenger3, self.offset)
					end
					-- detach driver
					lib_mount.detach(self.driver, self.offset)
				-- if clicker is not the driver
				else
					-- if clicker is passenger
					-- detach passengers
					if clicker == self.passenger then
						lib_mount.detach(self.passenger, self.offset)

					elseif clicker == self.passenger2 then
						lib_mount.detach(self.passenger2, self.offset)

					elseif clicker == self.passenger3 then
						lib_mount.detach(self.passenger3, self.offset)
					-- if clicker is not passenger
					else
						-- attach passengers if possible
						if lib_mount.passengers[self.passenger] == self.passenger and self.number_of_passengers >= 1 then
							lib_mount.attach(self, clicker, true, 1)
						end
						if lib_mount.passengers[self.passenger2] == self.passenger2 and self.number_of_passengers >= 2 then
							lib_mount.attach(self, clicker, true, 2)
						end
						if lib_mount.passengers[self.passenger3] == self.passenger3 and self.number_of_passengers >= 3 then
							lib_mount.attach(self, clicker, true, 3)
						end
					end
				end
			-- if there is no driver
			else
				-- attach driver
				if self.owner == clicker:get_player_name() then
					lib_mount.attach(self, clicker, false, 0)
				end
			end
		end,
		on_activate = function(self, staticdata, dtime_s)
			self.object:set_armor_groups({immortal = 1})
			local tmp = minetest.deserialize(staticdata)
			if tmp then
				for _,stat in pairs(tmp) do
					if _ == "owner" then print(stat) end
					self[_] = stat
				end
			end
			print("owner: ", self.owner)
			self.v2 = self.v
		end,
		get_staticdata = function(self)
			local tmp = {}
			for _,stat in pairs(self) do
				local t = type(stat)
				if  t ~= 'function' and t ~= 'nil' and t ~= 'userdata' then
					tmp[_] = self[_]
				end
			end
			return core.serialize(tmp)
		end,
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
			if not puncher or not puncher:is_player() or self.removed or self.driver then
				return
			end
			local punchername = puncher:get_player_name()
			if self.owner == punchername or minetest.get_player_privs(punchername).protection_bypass then
			  self.removed = true
			  -- delay remove to ensure player is detached
			  minetest.after(0.1, function()
				self.object:remove()
			end)
			  puncher:get_inventory():add_item("main", self.name)
			end
		end,
		on_step = function(self, dtime)
			-- Automatically set `enable_crash` to true if there's no value found
			if def.enable_crash == nil then
				def.enable_crash = true
			end
			drive(self, dtime, false, nil, nil, 0, def.can_fly, def.can_go_down, def.can_go_up, def.enable_crash)
		end
	})

	local can_float = false
	if def.terrain_type == 2 or def.terrain_type == 3 then
		can_float = true
	end

	minetest.register_craftitem(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		wield_scale = def.wield_scale,
		liquids_pointable = can_float,
		on_secondary_use = function(itemstack, placer, pointed_thing)
			local ent
			local pos = get_eye_pos(placer)
			local look_dir = placer:get_look_dir()
			look_dir = vector.multiply(look_dir, 4)
			pos = vector.add(pos, look_dir)
			ent = minetest.add_entity(pos, name)

			if ent:get_luaentity().player_rotation.y == 90 then
				ent:set_yaw(placer:get_look_horizontal())
			else
				ent:set_yaw(placer:get_look_horizontal() - math.pi/2)
			end
			ent:get_luaentity().owner = placer:get_player_name()
			itemstack:take_item()
			return itemstack
		end
	})
end
