minetest.register_entity("ship:core", {
  collisionbox = {-1, -0.9, -0.9, 1, 0.9, 0.9},
	can_fly = true,
	can_go_down = true, -- Applies only when `can_fly` is enabled
	can_go_up = true, -- Applies only when `can_fly` is enabled
  player_rotation = {x=0,y=90,z=0},
  driver_attach_at = {x=-2,y=6.3,z=0},
  driver_eye_offset = {x=0, y=0, z=0},
	enable_crash = true,
	visual = "normal",
	textures = {"ship_core"},
	visual_size = {x=1, y=1},
	stepheight = 1.1,

	max_speed_forward = 10,
	max_speed_reverse = 10,
	max_speed_upwards = 10, -- Applies only when `can_fly` is enabled
	max_speed_downwards = 10, -- Applies only when `can_fly` is enabled

	accel = 10,
	braking = -5,
	turn_spd = 5,
	drop_on_destroy = {},
	driver = nil,
	passenge = nil,
	v = 0,
	v2 = 0,
	owner = "",
	hp_max = 200,

	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			lib_mount.detach(self, clicker, {x=1, y=0, z=1})
		elseif not self.driver then
			lib_mount.attach(self, clicker, false, 0)
		end
	end,
	on_punch = (print("WHAM")),
	on_step = function(self, dtime)
          if def.enable_crash == nil then
            def.enable_crash = true
          end
          lib_mount.drive(self, dtime, false, nil, nil, 0, def.can_fly, def.can_go_down, def.can_go_up, def.enable_crash)
	end,
})
