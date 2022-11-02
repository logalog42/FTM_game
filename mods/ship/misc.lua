function get_eye_pos(player)
	local player_pos = player:get_pos()
	local eye_height = player:get_properties().eye_height
	local eye_offset = player:get_eye_offset()
	player_pos.y = player_pos.y + eye_height
	player_pos = vector.add(player_pos, eye_offset)

	return player_pos
end

function player_intersects_node(player, pos)
	local cb = player:get_properties().collisionbox
	local p_pos = player:get_pos()
	return 	p_pos.x + cb[1] >= pos.x + 0.5 or
			p_pos.x + cb[4] <= pos.x - 0.5 or
			p_pos.y + cb[2] >= pos.y + 0.5 or
			p_pos.y + cb[5] <= pos.y - 0.5 or
			p_pos.z + cb[3] >= pos.z + 0.5 or
			p_pos.z + cb[6] <= pos.z - 0.5
end

function ship.place_in_air(itemstack, user, pointed_thing)
	local pos = get_eye_pos(user)
	local look_dir = user:get_look_dir()
	look_dir = vector.multiply(look_dir, 0.5)
	while not player_intersects_node(user, vector.round(pos)) do
		pos = vector.add(pos, look_dir)
	end
	minetest.set_node(pos, {name = itemstack:get_name()})
  itemstack:take_item(1)
  return itemstack
end
